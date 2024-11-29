--PROCEDURE phân hệ ChiNhanh
GO
CREATE PROCEDURE THEM_CHI_NHANH @MACHINHANH INT,@TENCHINHANH NVARCHAR(255), @DIACHI VARCHAR(255), @THOIGIANMOCUA BIT, @THOIGIANDONGCUA BIT, @SDT CHAR(10), @BAIDOXEHOI BIT, @BAIDOXEMAY BIT, @NVQL INT, @MAKV INT, @GIAOHANG BIT
AS
BEGIN
	IF(@BAIDOXEHOI!=0 OR @BAIDOXEHOI!=1)
		BEGIN
			RAISERROR(N'Giá trị của thuộc tính bãi đỗ xe hơi chỉ là 0 hoặc 1',16,1)
		END
	ELSE
		BEGIN
			IF(@BAIDOXEMAY!=0 OR @BAIDOXEMAY!=1)
				BEGIN
					RAISERROR(N'Giá trị của thuộc tính bãi đỗ xe máy chỉ là 0 hoặc 1',16,1)
				END
			ELSE
				BEGIN
					IF EXISTS (SELECT 1 FROM NhanVien AS NV WHERE NV.MaNhanVien=@NVQL)
						BEGIN
							IF(@GIAOHANG!=0 OR @GIAOHANG!=1)
								BEGIN
									RAISERROR(N'Giá trị của thuộc tính giao hàng chỉ có thể là 0 hoặc 1',16,1)
								END
							ELSE
								BEGIN
									INSERT INTO ChiNhanh(MaChiNhanh, TenChiNhanh, DiaChi, ThoiGianMoCua, ThoiGianDongCua, SoDienThoai, BaiDoXeHoi, BaiDoXeMay, NhanVienQuanLy, MaKhuVuc, GiaoHang) values (@MACHINHANH, @TENCHINHANH, @DIACHI, @THOIGIANMOCUA, @THOIGIANDONGCUA, @SDT, @BAIDOXEHOI, @BAIDOXEMAY, @NVQL, @MAKV, @GIAOHANG)
								END
						END
					ELSE
						BEGIN
							RAISERROR(N'Không tìm thấy nhân viên quản lý phù hợp',16,1)
						END
				END
		END
END
GO

CREATE PROCEDURE XOA_CHINHANH @MACHINHANH INT
AS
BEGIN
	BEGIN TRY
			DELETE FROM DatCho WHERE MaChiNhanh = @MaChiNhanh;
			DELETE FROM Ban WHERE MaChiNhanh = @MaChiNhanh;
			DELETE FROM LichSuLamViec WHERE MaChiNhanh = @MaChiNhanh;
			DELETE FROM PhucVu WHERE MaChiNhanh = @MaChiNhanh;
			DELETE FROM PhieuDatMon WHERE MaChiNhanh = @MaChiNhanh;
			DELETE FROM DatTruoc WHERE MaChiNhanh = @MaChiNhanh;

			-- Cuối cùng, xóa chi nhánh
			DELETE FROM ChiNhanh WHERE MaChiNhanh = @MaChiNhanh;

			PRINT N'Xóa chi nhánh thành công'
	END TRY
	BEGIN CATCH
		PRINT 'Đã xảy ra lỗi. Giao dịch bị hủy.';
        ROLLBACK
        THROW
    END CATCH
END
GO


GO
CREATE PROCEDURE CAPNHAT_CHINHANH @MACHINHANH INT, @TENCHINHANH NVARCHAR(255),@DiaChi NVARCHAR(255), @ThoiGianMoCua TIME, @ThoiGianDongCua TIME, @SoDienThoai VARCHAR(10), @BaiDoXeHoi BIT, @BaiDoXeMay BIT, @NhanVienQuanLy VARCHAR(10), @MaKhuVuc INT, @GiaoHang BIT
AS
BEGIN
	IF NOT EXISTS (SELECT 1 FROM ChiNhanh WHERE MaChiNhanh = @MaChiNhanh)
		BEGIN
			RAISERROR(N'Chi nhánh không tồn tại',16,1)
		END
	ELSE
		BEGIN
			UPDATE ChiNhanh
				SET 
					TenChiNhanh = COALESCE(@TenChiNhanh, TenChiNhanh),
					DiaChi = COALESCE(@DiaChi, DiaChi),
					ThoiGianMoCua = COALESCE(@ThoiGianMoCua, ThoiGianMoCua),
					ThoiGianDongCua = COALESCE(@ThoiGianDongCua, ThoiGianDongCua),
					SoDienThoai = COALESCE(@SoDienThoai, SoDienThoai),
					BaiDoXeHoi = COALESCE(@BaiDoXeHoi, BaiDoXeHoi),
					BaiDoXeMay = COALESCE(@BaiDoXeMay, BaiDoXeMay),
					NhanVienQuanLy = COALESCE(@NhanVienQuanLy, NhanVienQuanLy),
					MaKhuVuc = COALESCE(@MaKhuVuc, MaKhuVuc),
					GiaoHang = COALESCE(@GiaoHang, GiaoHang)
				WHERE MaChiNhanh = @MaChiNhanh;

    PRINT 'Cập nhật thông tin chi nhánh thành công.';
		END
END
GO

GO
CREATE PROCEDURE THONGKE_DOANHTHU_CHINHANH (@MACN INT, @START_DAY DATE, @END_DAY DATE)
AS
BEGIN
	DECLARE @SLCN INT, @SLP INT, @SLHD INT, @DT DECIMAL(18,3)

	SELECT @SLCN=COUNT(*)
	FROM ChiNhanh AS CN

	SELECT @SLP=COUNT(*)
	FROM PhieuDatMon AS P

	SELECT @SLHD=COUNT(*)
	FROM HoaDon AS HD

	IF(@SLCN!=0)
		BEGIN
			IF(@SLP!=0)
				BEGIN
					IF(@SLHD!=0)
						BEGIN
							IF EXISTS (SELECT 1 FROM ChiNhanh AS CN WHERE CN.MaChiNhanh=@MACN)
								BEGIN
										SELECT @DT=ISNULL(SUM(HD.ThanhTien), 0)
										FROM ChiNhanh AS CN
										JOIN PhieuDatMon AS P ON P.MaChiNhanh=CN.MaChiNhanh
										JOIN HoaDon AS HD ON HD.MaPhieu=P.MaPhieu
										WHERE HD.NgayLap BETWEEN @START_DAY AND @END_DAY AND CN.MaChiNhanh=@MACN

										PRINT 'Doanh thu của chi nhánh từ ' +  CAST(@START_DAY AS NVARCHAR) + ' đến ' + CAST(@END_DAY AS NVARCHAR) + ' là: ' + CAST(@DT AS NVARCHAR);

								END
							ELSE
								BEGIN
									RAISERROR(N'Không tìm thấy mã chi nhánh',16,1)
								END
						END
					ELSE
						BEGIN
							RAISERROR(N'Không có dữ liệu trong bảng hóa đơn',16,1)
						END
				END
			ELSE
				BEGIN
					RAISERROR(N'Không có dữ liệu trong bảng phiếu đặt món',16,1)
				END
		END
	ELSE
		BEGIN
			RAISERROR(N'Không có dữ liệu trong bảng chi nhánh',16,1)
		END	

END
GO


GO
CREATE PROCEDURE THONGKE_DOANHTHU_KHUVUC @MAKHUVUC INT, @START_DAY DATE, @END_DAY DATE
AS
BEGIN
	IF EXISTS (SELECT 1 FROM KhuVuc AS KV WHERE KV.MaKhuVuc=@MAKHUVUC)
		BEGIN
			DECLARE @DT DECIMAL(18,3)
			SELECT @DT=SUM(HD.ThanhTien)
			FROM ChiNhanh AS CN
			JOIN PhieuDatMon AS P ON P.MaChiNhanh=CN.MaChiNhanh
			JOIN HoaDon AS HD ON HD.MaPhieu=P.MaPhieu
			WHERE CN.MaKhuVuc=@MAKHUVUC AND HD.NgayLap BETWEEN @START_DAY AND @END_DAY

			PRINT N'Tổng doanh thu khu vực cần tìm: '  +  CAST(@DT AS NVARCHAR)
		END
	ELSE
		BEGIN
			RAISERROR(N'Không tìm thấy mã khu vực',16,1)
		END
END
GO


GO
CREATE PROCEDURE DIEUDONG_QUANLI @MACN INT, @NVQL VARCHAR(10)
AS
BEGIN
	IF EXISTS (SELECT 1 FROM ChiNhanh AS CN WHERE CN.MaChiNhanh=@MACN)
		BEGIN
			IF EXISTS (SELECT 1 FROM NhanVien AS NV WHERE NV.MaNhanVien=@NVQL)
				BEGIN
					UPDATE ChiNhanh SET NhanVienQuanLy=@NVQL WHERE MaChiNhanh=@MACN
				END
			ELSE
				BEGIN
					RAISERROR(N'Không tìm thấy nhân viên phù hợp',16,1)
				END
		END
	ELSE
		BEGIN
			RAISERROR(N'Không tìm thấy mã chi nhánh',16,1)
		END
	
END
GO

CREATE PROCEDURE THEM_MON @MAMON INT, @MAMUC INT, @TENMON NVARCHAR(255), @GIAHIENTAI DECIMAL(18,3), @GIAOHANG BIT
AS
BEGIN
	IF NOT EXISTS (SELECT 1 FROM Mon AS M WHERE M.MaMon=@MAMON)
		BEGIN
			IF EXISTS(SELECT 1 FROM MucThucDon AS M WHERE M.MaMuc=@MAMUC)
				BEGIN
					IF(@GIAOHANG!=0 OR @GIAOHANG!=1)
						BEGIN
							RAISERROR(N'Thuộc tính GiaoHang chỉ được nhận 2 giá trị là 0 hoặc 1',16,1)
						END
					ELSE
						BEGIN
							IF(@GIAHIENTAI>0)
								BEGIN
									INSERT INTO MON(MaMon, MaMuc, TenMon, GiaHienTai, GiaoHang) VALUES (@MAMON, @MAMUC, @TENMON, @GIAHIENTAI, @GIAOHANG)
								END
							ELSE
								BEGIN
									RAISERROR(N'Giá món phải lớn hơn 0')
								END
						END
				END
			ELSE
				BEGIN
					RAISERROR(N'Không tìm thấy mục thực đơn',16,1)
				END
		END
	ELSE
		BEGIN
			RAISERROR(N'Mã món ăn đã bị trùng',16,1)
		END
END
GO


CREATE PROCEDURE THEMMON_VAOTHUCDON @MATHUCDON INT, @MAMON INT
AS
BEGIN
	IF EXISTS(SELECT 1 FROM ThucDon AS TD WHERE TD.MaThucDon=@MATHUCDON)
		BEGIN
			IF EXISTS(SELECT 1 FROM Mon AS M WHERE M.MaMon=@MAMON)
				BEGIN
					DELETE FROM ThucDon_Mon WHERE MaThucDon=@MATHUCDON AND MaMon=@MAMON
				END
			ELSE
				BEGIN
					RAISERROR(N'Không tìm thấy món phù hợp',16,1)
				END
		END
	ELSE
		BEGIN
			RAISERROR(N'Không tìm thấy mã thực đơn phù hợp',16,1)
		END
END
GO



CREATE PROCEDURE XOAMON_KHOITHUCDON @MATHUCDON INT, @MAMON INT
AS
BEGIN
	IF EXISTS(SELECT 1 FROM ThucDon AS TD WHERE TD.MaThucDon=@MATHUCDON)
		BEGIN
			IF EXISTS(SELECT 1 FROM Mon AS M WHERE M.MaMon=@MAMON)
				BEGIN
					INSERT INTO ThucDon_Mon (MaThucDon, MaMon) VALUES (@MATHUCDON, @MAMON)
				END
			ELSE
				BEGIN
					RAISERROR(N'Không tìm thấy món phù hợp',16,1)
				END
		END
	ELSE
		BEGIN
			RAISERROR(N'Không tìm thấy mã thực đơn phù hợp',16,1)
		END
END
GO
