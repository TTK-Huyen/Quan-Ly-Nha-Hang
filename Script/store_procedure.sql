USE QLNHAHANG
GO
--PROCEDURE phân hệ ChiNhanh -- sửa lại các sp có mã thuc đơn thành mã khu vực

CREATE PROCEDURE THEM_CHI_NHANH 
				(@MACHINHANH TINYINT,
				 @TENCHINHANH NVARCHAR(100), 
				 @DIACHI NVARCHAR(255), 
				 @THOIGIANMOCUA TIME, 
				 @THOIGIANDONGCUA TIME, 
				 @SDT VARCHAR(10), 
				 @BAIDOXEHOI BIT, 
				 @BAIDOXEMAY BIT, 
				 @NVQL CHAR(6), 
				 @MAKV TINYINT, 
				 @GIAOHANG BIT)
AS
BEGIN
	IF(@BAIDOXEHOI!=0 AND @BAIDOXEHOI!=1)
		BEGIN
			RAISERROR(N'Giá trị của thuộc tính bãi đỗ xe hơi chỉ là 0 hoặc 1',16,1)
		END
	ELSE
		BEGIN
			IF(@BAIDOXEMAY!=0 AND @BAIDOXEMAY!=1)
				BEGIN
					RAISERROR(N'Giá trị của thuộc tính bãi đỗ xe máy chỉ là 0 hoặc 1',16,1)
				END
			ELSE
				BEGIN
					IF EXISTS (SELECT 1 FROM NhanVien AS NV WHERE NV.MaNhanVien=@NVQL)
						BEGIN
							IF(@GIAOHANG!=0 AND @GIAOHANG!=1)
								BEGIN
									RAISERROR(N'Giá trị của thuộc tính giao hàng chỉ có thể là 0 hoặc 1',16,1)
								END
							ELSE
								IF(@THOIGIANMOCUA<@THOIGIANDONGCUA)
									BEGIN
										IF EXISTS (SELECT 1 FROM KhuVuc WHERE MaKhuVuc=@MAKV)
											BEGIN
												INSERT INTO ChiNhanh(MaChiNhanh, TenChiNhanh, DiaChi, ThoiGianMoCua, ThoiGianDongCua, SoDienThoai, BaiDoXeHoi, BaiDoXeMay, NhanVienQuanLy, MaKhuVuc, GiaoHang) values (@MACHINHANH, @TENCHINHANH, @DIACHI, @THOIGIANMOCUA, @THOIGIANDONGCUA, @SDT, @BAIDOXEHOI, @BAIDOXEMAY, @NVQL, @MAKV, @GIAOHANG)
											END
										ELSE
											BEGIN
												RAISERROR(N'Không tìm thấy mã khu vực',16,1)
											END
									END
								ELSE
									BEGIN
										RAISERROR(N'Thời gian mở cửa phải trước thời gian đóng cửa',16,1)
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

CREATE PROCEDURE XOA_CHINHANH 
				(@MACHINHANH TINYINT)
AS
BEGIN
	BEGIN TRY
			DELETE FROM DatCho WHERE MaChiNhanh = @MaChiNhanh;
			DELETE FROM Ban WHERE MaChiNhanh = @MaChiNhanh;
			DELETE FROM LichSuLamViec WHERE MaChiNhanh = @MaChiNhanh;
			DELETE FROM PhucVu WHERE MaChiNhanh = @MaChiNhanh;
			DELETE FROM PhieuDatMon WHERE MaChiNhanh = @MaChiNhanh;

			-- Cuối cùng, xóa chi nhánh
			DELETE FROM ChiNhanh WHERE MaChiNhanh = @MaChiNhanh;

			PRINT N'Xóa chi nhánh thành công'
	END TRY
	BEGIN CATCH
		PRINT 'Đã xảy ra lỗi. Giao dịch bị hủy.';
        ROLLBACK;
        THROW
    END CATCH
END
GO



CREATE PROCEDURE CAPNHAT_CHINHANH 
			   (@MACHINHANH TINYINT, 
				@TENCHINHANH NVARCHAR(100),
				@DiaChi NVARCHAR(255), 
				@ThoiGianMoCua TIME, 
				@ThoiGianDongCua TIME, 
				@SoDienThoai VARCHAR(10), 
				@BaiDoXeHoi BIT, 
				@BaiDoXeMay BIT, 
				@NhanVienQuanLy CHAR(6), 
				@MaKhuVuc TINYINT, 
				@GiaoHang BIT)
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


CREATE PROCEDURE THONGKE_DOANHTHU_CHINHANH 
				(@MACN TINYINT, 
				@START_DAY DATE, 
				@END_DAY DATE)
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
CREATE PROCEDURE THONGKE_DOANHTHU_KHUVUC 
				(@MAKHUVUC TINYINT, 
				@START_DAY DATE, 
				@END_DAY DATE)
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
CREATE PROCEDURE DIEUDONG_QUANLI 
				(@MACN TINYINT, 
				@NVQL CHAR(6))
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


CREATE PROCEDURE THEM_MON  
				(@MAMUC TINYINT, 
				@TENMON NVARCHAR(100), 
				@GIAHIENTAI DECIMAL(18,3), 
				@GIAOHANG BIT)
AS
BEGIN
	IF NOT EXISTS (SELECT 1 FROM Mon AS M WHERE M.TenMon=@TENMON)
		BEGIN
			IF EXISTS(SELECT 1 FROM MucThucDon AS M WHERE M.MaMuc=@MAMUC)
				BEGIN
					IF(@GIAOHANG != 0 AND  @GIAOHANG != 1)
						BEGIN
							RAISERROR(N'Thuộc tính GiaoHang chỉ được nhận 2 giá trị là 0 hoặc 1',16,1)
						END
					ELSE
						BEGIN
							IF(@GIAHIENTAI>0)
								BEGIN

										INSERT INTO MON(MaMuc, TenMon, GiaHienTai, GiaoHang) VALUES (@MAMUC, @TENMON, @GIAHIENTAI, @GIAOHANG)
						

								END
							ELSE
								BEGIN
									RAISERROR(N'Giá món phải lớn hơn 0',16,1);
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


CREATE PROCEDURE THEMMON_VAOTHUCDON 
				(@MAKHUVUC TINYINT, 
				@MAMON SMALLINT)
AS
BEGIN
	IF EXISTS(SELECT 1 FROM KhuVuc_ThucDon AS KT WHERE KT.MaKhuVuc=@MAKHUVUC)
		BEGIN
			IF EXISTS(SELECT 1 FROM Mon AS M WHERE M.MaMon=@MAMON)
				BEGIN
					INSERT INTO ThucDon_Mon (MaKhuVuc,  MaMon) 
					VALUES (@MAKHUVUC ,@MAMON );
				END
			ELSE
				BEGIN
					RAISERROR(N'Không tìm thấy món phù hợp',16,1);
				END
		END
	ELSE
		BEGIN
			RAISERROR(N'Không tìm thấy mã thực đơn phù hợp',16,1);
		END
END
GO



CREATE PROCEDURE XOAMON_KHOITHUCDON 
				(@MAKHUVUC TINYINT, 
				 @MAMON SMALLINT)
AS
BEGIN
	IF EXISTS(SELECT 1 FROM KhuVuc_ThucDon AS KT WHERE KT.MaKhuVuc=@MAKHUVUC)
		BEGIN
			IF EXISTS(SELECT 1 FROM Mon AS M WHERE M.MaMon=@MAMON)
				BEGIN
					DELETE FROM ThucDon_Mon WHERE MaKhuVuc = @MAKHUVUC  AND MaMon = @MAMON
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



--Store procedure PHÂN HỆ NHÂN VIÊN SP  TẠO PHIẾU ĐẶT MÓN
CREATE PROC THEMPDM
	(@NhanVienLap CHAR(6),
	@MaSoBan CHAR(2),
	@SoDienThoai char(10),
	@MaChiNhanh TINYINT,
	@MaPhieu INT OUTPUT) -- Thêm OUTPUT 
AS
BEGIN
	--Kiểm tra nhân viên có tồn tại không
	IF @NhanVienLap IS NOT NULL AND NOT EXISTS (SELECT 1
	FROM NhanVien
	WHERE MaNhanVien = @NhanVienLap
	)
	BEGIN
		RAISERROR (N'Mã nhân viên nhập vào không có trong hệ thống',16,1);
		RETURN;
	END;
	--Kiểm tra mã số bàn có tồn tại không
	IF NOT EXISTS (SELECT 1
	FROM Ban
	WHERE MaSoBan = @MaSoBan
	)
	BEGIN
		RAISERROR (N'Mã bàn nhập vào không có trong hệ thống',16,1);
		RETURN;
	END;

	 -- Kiểm tra mã chi nhánh
    IF NOT EXISTS (SELECT 1 FROM ChiNhanh WHERE MaChiNhanh = @MaChiNhanh)
    BEGIN
        RAISERROR (N'Mã chi nhánh nhập vào không tồn tại trong hệ thống. Vui lòng kiểm tra lại.', 16, 1);
        RETURN;
    END;

	BEGIN TRANSACTION
	INSERT INTO PhieuDatMon(NgayLap,NhanVienLap, MaSoBan, SODIENTHOAI, MaChiNhanh)
	VALUES (GETDATE(),@NhanVienLap, @MaSoBan, @SoDienThoai, @MaChiNhanh);
	SET @MaPhieu = SCOPE_IDENTITY();

    COMMIT TRANSACTION;
END
GO

CREATE OR ALTER PROC DAT_TRUOC
    (@SoDienThoai CHAR(10),
    @MaChiNhanh TINYINT,
    @SoLuongKhach TINYINT,
    @GioDen DATETIME,
    @GhiChu NVARCHAR(255),
    @NhanVienLap CHAR(6) = NULL) -- Cho phép NULL
AS
BEGIN
    BEGIN TRANSACTION;


    -- Kiểm tra chi nhánh
    IF NOT EXISTS (SELECT 1 FROM ChiNhanh WHERE MaChiNhanh = @MaChiNhanh)
    BEGIN
        RAISERROR(N'Mã chi nhánh không tồn tại!', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END;

    -- Tìm bàn phù hợp
    DECLARE @MaSoBan TINYINT;

    ;WITH AvailableTables AS (
        SELECT 
            B.MaSoBan, 
            B.SucChua, 
            ABS(B.SucChua - @SoLuongKhach) AS Distance
        FROM Ban AS B
        WHERE 
            B.MaChiNhanh = @MaChiNhanh -- Lọc theo chi nhánh
            AND B.TrangThai = 0 -- Bàn phải trống
            AND B.SucChua >= @SoLuongKhach -- Sức chứa phải >= số lượng khách
    )
    SELECT TOP 1 
        @MaSoBan = MaSoBan
    FROM AvailableTables
    ORDER BY Distance ASC, SucChua ASC;

    -- Nếu không tìm thấy bàn phù hợp
    IF @MaSoBan IS NULL
    BEGIN
        RAISERROR(N'Không có bàn phù hợp cho số lượng khách!', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END;

    -- Gọi thủ tục THEMPDM để tạo phiếu đặt món
    DECLARE @MaPhieu INT;

    BEGIN TRY
		EXEC THEMPDM 
			@NhanVienLap = @NhanVienLap, 
			@MaSoBan = @MaSoBan,
			@SoDienThoai = @SoDienThoai, 
			@MaChiNhanh = @MaChiNhanh,
			@MaPhieu = @MaPhieu OUTPUT; -- Lấy giá trị từ OUTPUT
	END TRY
	BEGIN CATCH
		RAISERROR(N'Lỗi khi tạo phiếu đặt món.', 16, 1);
		ROLLBACK TRANSACTION;
		RETURN;
	END CATCH;

		-- Cập nhật trạng thái bàn
    UPDATE Ban
    SET TrangThai = 1
    WHERE MaSoBan = @MaSoBan AND MaChiNhanh = @MaChiNhanh;

    -- Chèn dữ liệu vào bảng DatTruoc
    INSERT INTO DatTruoc (MaPhieu,SoDienThoai, ChiNhanh, SoLuongKhach, NgayDat ,GioDen, GhiChu)
    VALUES (@MaPhieu,  @SoDienThoai, @MaChiNhanh, @SoLuongKhach, GETDATE(),@GioDen, @GhiChu);

    COMMIT TRANSACTION;
    PRINT 'Đặt bàn thành công!';
END;
GO


			

--SP CẬP NHẬT PHIẾU ĐẶT MÓN: CHỈNH SỬA SỐ LƯỢNG VÀ GHI CHÚ MÓN, KHÔNG ĐƯỢC XÓA
CREATE PROC NVSUAPDM
	(@MaPhieu BIGINT,
	@MaMon TINYINT,
	@SoLuong TINYINT,
	@GhiChu NVARCHAR(200))
AS
BEGIN
	--Kiểm tra mã phiếu có tồn tại chưa
	IF NOT EXISTS (SELECT 1
	FROM PhieuDatMon
	WHERE MaPhieu = @MaPhieu
	)
	BEGIN
		RAISERROR (N'Mã phiếu đặt món nhập vào không có trong hệ thống',16,1);
		RETURN;
	END;
	--Kiểm tra mã món có tồn tại trong chi nhánh đó không
	IF NOT EXISTS (SELECT 1
	FROM PhucVu p
	WHERE p.MaMon = @MaMon AND p.MaChiNhanh  = 
	(SELECT MaChiNhanh
	FROM LichSuLamViec l
	WHERE l.NgayKetThuc IS NULL AND l.MaNhanVien = 
	(SELECT NhanVienLap
	FROM PhieuDatMon d
	WHERE d.MaPhieu = @MaPhieu)
	))
	BEGIN
		RAISERROR (N'Mã món ăn nhập vào không có trong hệ thống',16,1);
		RETURN;
	END;
	--Số lượng phải lớn hơn không
	IF @SoLuong <= 0
	BEGIN
		RAISERROR (N'Số lượng món nhập vào phải lớn hơn không',16,1);
		RETURN;
	END;

	--insert
	-- Insert or Update logic
	IF EXISTS (
		SELECT 1 
		FROM ChiTietPhieu
		WHERE MaPhieu = @MaPhieu AND MaMon = @MaMon
	)
	BEGIN
		-- Update existing record
		UPDATE ChiTietPhieu
		SET SoLuong = @SoLuong, GhiChu = @GhiChu
		WHERE MaPhieu = @MaPhieu AND MaMon = @MaMon;
	END
	ELSE
	BEGIN
		-- Insert new record
		INSERT INTO ChiTietPhieu ( MaMon, SoLuong, GhiChu)
		VALUES (@MaMon, @SoLuong, @GhiChu);
	END;
	
END;
GO

--SP XEM PDM THEO MÃ PDM
CREATE FUNCTION THEODOIPDM 
				(@MaPhieu BIGINT)
RETURNS @KETQUA TABLE (MAPHIEU BIGINT, NGAYLAP DATETIME, NHANVIENLAP CHAR(6), MASOBAN CHAR(2), SODIENTHOAI CHAR(10))
AS
BEGIN
	INSERT INTO @KETQUA  (MAPHIEU, NGAYLAP, NHANVIENLAP , MASOBAN , SODIENTHOAI )
	SELECT MaPhieu, NgayLap, NhanVienLap, MaSoBan, SODIENTHOAI
	FROM PhieuDatMon 
	WHERE MaPhieu = @MaPhieu

	RETURN;
END;
GO


use qlnhahang
go


--SP TẠO HÓA ĐƠN DỰA VÀO MÃ PDM
CREATE PROC TAOHOADON
			(@MaPhieu BIGINT)
AS
BEGIN
	--Kiểm tra mã phiếu đầu vào
	IF NOT EXISTS (SELECT 1
	FROM PhieuDatMon
	WHERE MaPhieu= @MaPhieu
	)
	BEGIN
		RAISERROR (N'Mã phiếu nhập vào không có trong hệ thống',16,1);
		RETURN;
	END;
	--Tạo các thông tin cho HÓA ĐƠN
	DECLARE @TongTien DECIMAL(10, 2)
    DECLARE @GiamGia DECIMAL(5, 2)
    DECLARE @ThanhTien DECIMAL(10, 2)

	SET @TongTien = 0;
	SET @GiamGia = 0;
	SET @ThanhTien = 0;

	SET @TongTien = 
	(SELECT SUM(m.GiaHienTai * c.SoLuong)
	 FROM ChiTietPhieu c INNER JOIN Mon m ON m.MaMon = c.MaMon
	 WHERE c.MaPhieu = @MaPhieu
			)


	DECLARE @Loai NVARCHAR(20)
	SET @Loai = 
	(SELECT LoaiThe
	FROM TheKhachHang 
	WHERE TrangThaiThe = 1 AND SoDienThoai = 
	(SELECT SoDienThoai
	FROM PhieuDatMon p
	WHERE p.MaPhieu = @MaPhieu
	)
	)
	IF @Loai IS NULL
	BEGIN
		 SET @GiamGia = 0;
	END;
	ELSE IF(@Loai = N'Membership')
	BEGIN
		SET @GiamGia = 0;
	END;
	ELSE IF(@Loai = N'Silver')
	BEGIN
		SET @GiamGia = 5;
	END;
	ELSE IF(@Loai = N'Gold')
	BEGIN
		SET @GiamGia = 10;
	END;

	SET @ThanhTien = @TongTien * (100 - @GiamGia) / 100.0;

	INSERT INTO HoaDon (MaPhieu, NgayLap, TongTien, GiamGia,ThanhTien)
	VALUES (@MaPhieu, Getdate(),@TongTien, @GiamGia, @ThanhTien)

END;
GO


CREATE PROC INHOADON
		(@MaPhieu BIGINT)

AS
BEGIN
    -- Kiểm tra mã phiếu
    IF NOT EXISTS (SELECT 1 FROM HoaDon WHERE MaPhieu = @MaPhieu)
    BEGIN
        RAISERROR (N'Hóa đơn không tồn tại cho mã phiếu đã nhập', 16, 1);
        RETURN;
    END;

    -- Thông tin hóa đơn
    PRINT N'========== THÔNG TIN HÓA ĐƠN =========='
    SELECT 
        h.MaPhieu AS [Số hóa đơn],
        h.NgayLap AS [Ngày lập hóa đơn],
        k.MaKhachHang AS [Mã khách hàng],
        k.HoTen AS [Tên khách hàng]
    FROM HoaDon h
    INNER JOIN PhieuDatMon p ON h.MaPhieu = p.MaPhieu
    LEFT JOIN KhachHang k ON  p.SODIENTHOAI = k.SoDienThoai

    WHERE h.MaPhieu = @MaPhieu;

    PRINT N'---------- DANH SÁCH MÓN ĂN -----------'
    -- Chi tiết phiếu
    SELECT 
        m.TenMon AS [Tên món ăn],
        c.SoLuong AS [Số lượng],
        m.GiaHienTai AS [Đơn giá (VND)],
        (m.GiaHienTai * c.SoLuong) AS [Thành tiền (VND)]
    FROM ChiTietPhieu c
    INNER JOIN Mon m ON c.MaMon = m.MaMon
    WHERE c.MaPhieu = @MaPhieu;

	PRINT N'========== THÔNG TIN THANH TOÁN =========='
    SELECT 
        h.TongTien AS [Tổng tiền (VND)],
        h.GiamGia AS [Giảm giá (%)],
        h.ThanhTien AS [Thành tiền (VND)]
    FROM HoaDon h
    INNER JOIN PhieuDatMon p ON h.MaPhieu = p.MaPhieu
    WHERE h.MaPhieu = @MaPhieu;

    PRINT N'========================================'
    PRINT N'Cảm ơn quý khách đã sử dụng dịch vụ. Hẹn gặp lại!'
END;
GO


--SP XEM THÔNG TIN NHÂN VIÊN CHÍNH MÌNH -- LIÊN QUAN ĐẾN PHÂN QUYỀN




---------STORE PROCEDURE PHÂN HỆ CHI NHÁNH
--SP TÌM KIẾM THÔNG TIN NHÂN VIÊN BẰNG MÃ NHÂN VIÊN/ TÊN NHÂN VIÊN/...
CREATE PROC TIMTTNV
    (@MaNhanVien CHAR(6))
AS
BEGIN
    -- Kiểm tra mã nhân viên
    IF NOT EXISTS (SELECT 1 FROM NhanVien WHERE MaNhanVien = @MaNhanVien)
    BEGIN
        RAISERROR (N'Mã nhân viên nhập vào không có trong hệ thống. Vui lòng kiểm tra lại.', 16, 1);
        RETURN;
    END;

    -- In thông tin nhân viên
    PRINT N'========== THÔNG TIN NHÂN VIÊN =========='
    SELECT 
        MaNhanVien AS [Mã nhân viên], 
        HoTen AS [Họ và tên], 
        FORMAT(NgaySinh, 'dd/MM/yyyy') AS [Ngày sinh], 
        CASE GioiTinh WHEN 'M' THEN N'Nam' ELSE N'Nữ' END AS [Giới tính],
        FORMAT(NgayVaoLam, 'dd/MM/yyyy') AS [Ngày vào làm], 
        FORMAT(NgayNghiViec, 'dd/MM/yyyy') AS [Ngày nghỉ việc], 
        MaBoPhan AS [Mã bộ phận], 
        DiemSo AS [Điểm số]
    FROM NhanVien
    WHERE MaNhanVien = @MaNhanVien;

    -- In lịch sử làm việc
    PRINT N'========== LỊCH SỬ LÀM VIỆC =========='
    SELECT 
        MaChiNhanh AS [Mã chi nhánh],
        FORMAT(NgayBatDau, 'dd/MM/yyyy') AS [Ngày bắt đầu],
        FORMAT(NgayKetThuc, 'dd/MM/yyyy') AS [Ngày kết thúc]
    FROM LichSuLamViec
    WHERE MaNhanVien = @MaNhanVien
    ORDER BY NgayBatDau DESC;

END;
GO

--EXEC TIMTTNV @MaNhanVien = 'NV001';
--SP XEM DANH SÁCH TẤT CẢ NHÂN VIÊN THUỘC HỆ THỐNG/KHU VỰC/ CHI NHÁNH
CREATE PROC XEMNVHT
AS
BEGIN
    PRINT N'========== DANH SÁCH TẤT CẢ NHÂN VIÊN =========='
    SELECT 
        MaNhanVien AS [Mã nhân viên], 
        HoTen AS [Họ và tên], 
        FORMAT(NgaySinh, 'dd/MM/yyyy') AS [Ngày sinh], 
        CASE GioiTinh WHEN 'M' THEN N'Nam' ELSE N'Nữ' END AS [Giới tính],
        FORMAT(NgayVaoLam, 'dd/MM/yyyy') AS [Ngày vào làm], 
        FORMAT(NgayNghiViec, 'dd/MM/yyyy') AS [Ngày nghỉ việc], 
        MaBoPhan AS [Mã bộ phận], 
        DiemSo AS [Điểm số]
    FROM NhanVien;
END;
GO


CREATE PROC XEMNVKHUVUC
    (@MaKhuVuc TINYINT)
AS
BEGIN
    -- Kiểm tra mã khu vực
    IF NOT EXISTS (SELECT 1 FROM KhuVuc WHERE MaKhuVuc = @MaKhuVuc)
    BEGIN
        RAISERROR (N'Mã khu vực nhập vào không tồn tại trong hệ thống. Vui lòng kiểm tra lại.', 16, 1);
        RETURN;
    END;

    PRINT N'========== DANH SÁCH NHÂN VIÊN KHU VỰC =========='
    SELECT 
        n.MaNhanVien AS [Mã nhân viên], 
        n.HoTen AS [Họ và tên], 
        FORMAT(n.NgaySinh, 'dd/MM/yyyy') AS [Ngày sinh], 
        CASE n.GioiTinh WHEN 'M' THEN N'Nam' ELSE N'Nữ' END AS [Giới tính],
        FORMAT(n.NgayVaoLam, 'dd/MM/yyyy') AS [Ngày vào làm], 
        FORMAT(n.NgayNghiViec, 'dd/MM/yyyy') AS [Ngày nghỉ việc]
    FROM 
        NhanVien n 
    INNER JOIN 
        LichSuLamViec l ON n.MaNhanVien = l.MaNhanVien
    WHERE 
        l.NgayKetThuc IS NULL 
        AND l.MaChiNhanh IN (SELECT MaChiNhanh FROM ChiNhanh WHERE MaKhuVuc = @MaKhuVuc);
END;
GO


CREATE PROC XEMNVCN
    (@MaChiNhanh TINYINT)
AS
BEGIN
    -- Kiểm tra mã chi nhánh
    IF NOT EXISTS (SELECT 1 FROM ChiNhanh WHERE MaChiNhanh = @MaChiNhanh)
    BEGIN
        RAISERROR (N'Mã chi nhánh nhập vào không tồn tại trong hệ thống. Vui lòng kiểm tra lại.', 16, 1);
        RETURN;
    END;

    PRINT N'========== DANH SÁCH NHÂN VIÊN CHI NHÁNH =========='
    SELECT 
        n.MaNhanVien AS [Mã nhân viên], 
        n.HoTen AS [Họ và tên], 
        FORMAT(n.NgaySinh, 'dd/MM/yyyy') AS [Ngày sinh], 
        CASE n.GioiTinh WHEN 'M' THEN N'Nam' ELSE N'Nữ' END AS [Giới tính],
        FORMAT(n.NgayVaoLam, 'dd/MM/yyyy') AS [Ngày vào làm], 
        FORMAT(n.NgayNghiViec, 'dd/MM/yyyy') AS [Ngày nghỉ việc]
    FROM 
        NhanVien n 
    INNER JOIN 
        LichSuLamViec l ON n.MaNhanVien = l.MaNhanVien
    WHERE 
        l.NgayKetThuc IS NULL 
        AND l.MaChiNhanh = @MaChiNhanh;
END;
GO


--SP THÊM NHÂN VIÊN MỚI VÀO BẢNG NHÂN VIÊN
CREATE PROC THEMNV
	(@HoTen NVARCHAR(255),
	@NgaySinh DATE,
	@GioiTinh nvarchar(4),
	@NgayVaoLam DATE,
	@MaBoPhan CHAR(4),
	@MaChiNhanh TINYINT)
	
AS
BEGIN
	--Kiểm tra mã chi nhánh có tồn tại không
	--Kiểm tra mã bộ phận có tồn tại không
    IF NOT EXISTS (SELECT 1 FROM ChiNhanh WHERE MaChiNhanh = @MaChiNhanh)
    BEGIN
        RAISERROR (N'Mã chi nhánh nhập vào không có trong hệ thống. Vui lòng kiểm tra lại.', 16, 1);
        RETURN;
    END;
	--Kiểm tra mã bộ phận có tồn tại không
    IF NOT EXISTS (SELECT 1 FROM BoPhan WHERE MaBoPhan = @MaBoPhan)
    BEGIN
        RAISERROR (N'Mã bộ phận nhập vào không có trong hệ thống. Vui lòng kiểm tra lại.', 16, 1);
        RETURN;
    END;

	DECLARE @MaNhanVien CHAR(6);

    -- Tìm số thứ tự bị thiếu trong dãy mã nhân viên
    SET @MaNhanVien = 
(
    SELECT TOP 1 
           'NV' + RIGHT('0000' + CAST(MissingNumber AS VARCHAR), 4)
    FROM 
    (
        SELECT t.Number + 1 AS MissingNumber
        FROM 
        (
            SELECT CAST(SUBSTRING(MaNhanVien, 3, LEN(MaNhanVien) - 2) AS INT) AS Number
            FROM NhanVien
        ) t
        WHERE NOT EXISTS 
        (
            SELECT 1
            FROM NhanVien n
            WHERE CAST(SUBSTRING(n.MaNhanVien, 3, LEN(n.MaNhanVien) - 2) AS INT) = t.Number + 1
        )
    ) MissingNumbers
    ORDER BY MissingNumber
);

    -- Nếu không tìm thấy số bị thiếu, tạo mã mới dựa trên số lớn nhất
    IF @MaNhanVien IS NULL
    BEGIN
        SET @MaNhanVien = 
        (
            SELECT 'NV' + RIGHT('0000' + CAST(ISNULL(MAX(CAST(SUBSTRING(MaNhanVien, 3, LEN(MaNhanVien) - 2) AS INT)), 0) + 1 AS VARCHAR), 4)
            FROM NhanVien
        );
    END;


    -- Kiểm tra lần cuối nếu @MaNhanVien vẫn NULL
    IF @MaNhanVien IS NULL
    BEGIN
        RAISERROR (N'Không thể tạo mã nhân viên mới. Vui lòng kiểm tra lại dữ liệu.', 16, 1);
        RETURN;
    END;



	INSERT INTO NhanVien (MaNhanVien, HoTen, NgaySinh, 
	GioiTinh, NgayVaoLam, NgayNghiViec,MaBoPhan)
	VALUES (@MaNhanVien, @HoTen, @NgaySinh, @GioiTinh, GETDATE(),NULL, @MaBoPhan);

	INSERT INTO LichSuLamViec(MaNhanVien,MaChiNhanh, NgayBatDau, NgayKetThuc)
	VALUES (@MaNhanVien, @MaChiNhanh, @NgayVaoLam,NULL)

	PRINT N'Thêm nhân viên thành công. Mã nhân viên mới là ' + @MaNhanVien;
END;
GO



--SP CẬP NHẬT THÔNG TIN NHÂN VIÊN: SỬA ĐIỂM, LƯƠNG, THÊM NGÀY NGHỈ VIỆC
CREATE PROCEDURE CAPNHAT_NHANVIEN 
				(@MANHANVIEN CHAR(6), 
				@HOTEN NVARCHAR(255), 
				@NGAYSINH DATE,
				@GIOITINH NVARCHAR(4), 
				@LUONG DECIMAL(18,3), 
				@NGAYVAOLAM DATE, 
				@NGAYNGHIVIEC DATE, 
				@MABOPHAN CHAR(4), 
				@DIEMSO DECIMAL(9,0))
AS
BEGIN
	IF NOT EXISTS (SELECT 1 FROM NhanVien WHERE MaNhanVien = @MANHANVIEN)
		BEGIN
			RAISERROR(N'Nhân viên không tồn tại',16,1)
		END
	ELSE
		BEGIN
			UPDATE NhanVien
				SET 
					HoTen = COALESCE(@HOTEN, HoTen),
					NgaySinh = COALESCE(@NGAYSINH, NgaySinh),
					GioiTinh = COALESCE(@GIOITINH, GioiTinh),
					NgayVaoLam = COALESCE(@NGAYVAOLAM, NgayVaoLam),
					NgayNghiViec = COALESCE(@NGAYNGHIVIEC, NgayNghiViec),
					MaBoPhan = COALESCE(@MABOPHAN, MaBoPhan),
					DiemSo = COALESCE(@DIEMSO, DiemSo)
				WHERE MaNhanVien = @MANHANVIEN;

    PRINT 'Cập nhật thông tin nhân viên thành công.';
		END
END
GO


--SP SỬA THÔNG TIN TRÊN BẢNG LỊCH SỬ LÀM VIỆC KHI NHÂN VIÊN NGHỈ VIỆC 
CREATE PROC NVNGHIVIEC
			(@MANHANVIEN CHAR(6))
AS
BEGIN
	IF NOT EXISTS (SELECT 1 FROM NhanVien WHERE MaNhanVien = @MaNhanVien)
    BEGIN
        RAISERROR (N'Mã nhân viên nhập vào không có trong hệ thống. Vui lòng kiểm tra lại.', 16, 1);
        RETURN;
    END;

	UPDATE LichSuLamViec
	SET NgayKetThuc = GETDATE()
	WHERE NgayKetThuc = NULL
	PRINT N'Thêm thông tin thành công';
END;
GO


-- SP ĐIỀU ĐỘNG SANG CHI NHÁNH KHÁC
CREATE PROC DIEUDONGNV
			(@MANHANVIEN CHAR(6), 
			@MACHINHANHCU TINYINT, 
			@MACHINHANHMOI TINYINT)
AS
BEGIN
	--KIEM TRA MA NHAN VIEN
	IF NOT EXISTS (SELECT 1 FROM NhanVien WHERE MaNhanVien = @MaNhanVien)
    BEGIN
        RAISERROR (N'Mã nhân viên nhập vào không có trong hệ thống. Vui lòng kiểm tra lại.', 16, 1);
        RETURN;
    END;
	-- Kiểm tra mã chi nhánh
    IF NOT EXISTS (SELECT 1 FROM ChiNhanh WHERE MaChiNhanh = @MACHINHANHCU)
    BEGIN
        RAISERROR (N'Mã chi nhánh cũ nhập vào không tồn tại trong hệ thống. Vui lòng kiểm tra lại.', 16, 1);
        RETURN;
    END;
	-- Kiểm tra mã chi nhánh
    IF NOT EXISTS (SELECT 1 FROM ChiNhanh WHERE MaChiNhanh = @MACHINHANHMOI)
    BEGIN
        RAISERROR (N'Mã chi nhánh mới nhập vào không tồn tại trong hệ thống. Vui lòng kiểm tra lại.', 16, 1);
        RETURN;
    END;

	UPDATE LichSuLamViec
	SET NgayKetThuc = GETDATE()
	WHERE NgayKetThuc = NULL AND MaChiNhanh = @MACHINHANHCU

	INSERT INTO LichSuLamViec (MaNhanVien, MaChiNhanh, NgayBatDau,NgayKetThuc)
	VALUES (@MANHANVIEN, @MACHINHANHMOI, GETDATE(),NULL)

	PRINT N'Thực hiện đổi chi nhánh thành công';
END;
GO



--SP CHỈNH SỬA TRẠNG THÁI PHỤC VỤ CỦA MÓN ĂN TRONG THỰC ĐƠN
CREATE PROC TRANGTHAIMONAN
			(@MACHINHANH TINYINT, 
			@MAMON TINYINT)
AS
BEGIN
	-- Kiểm tra mã chi nhánh
    IF NOT EXISTS (SELECT 1 FROM ChiNhanh WHERE MaChiNhanh = @MACHINHANH)
    BEGIN
        RAISERROR (N'Mã chi nhánh cũ nhập vào không tồn tại trong hệ thống. Vui lòng kiểm tra lại.', 16, 1);
        RETURN;
    END;
	-- Kiểm tra mã món
    IF NOT EXISTS (SELECT 1 FROM Mon WHERE MaMon = @MAMON)
    BEGIN
        RAISERROR (N'Mã món nhập vào không tồn tại trong hệ thống. Vui lòng kiểm tra lại.', 16, 1);
        RETURN;
    END;
	-- Kiểm tra mã món TRONG PHUC VU
    IF NOT EXISTS (SELECT 1 FROM PhucVu WHERE MaMon = @MAMON AND MaChiNhanh= @MACHINHANH)
    BEGIN
        RAISERROR (N'Chi nhánh này hiện chưa phục vụ món ăn bạn đang tìm. Vui lòng kiểm tra lại.', 16, 1);
        RETURN;
    END;

	UPDATE PhucVu
	SET CoPhucVuKhong = 0
	WHERE MaMon = @MAMON

	PRINT N'Sửa thông tin món ăn thành công';
END;
GO

--SP XÓA PHIEU DAT MON
CREATE PROC XOAPDM
	(@MAPHIEU BIGINT)
AS
BEGIN
	IF NOT EXISTS (SELECT 1
	FROM PhieuDatMon
	WHERE MaPhieu = @MAPHIEU
	)
	BEGIN
		RAISERROR (N'Mã phiếu đặt món nhập vào không có trong hệ thống',16,1);
		RETURN;
	END;

	DELETE FROM PhieuDatMon
	WHERE MaPhieu = @MAPHIEU
	PRINT N'Xóa phiếu đặt món thành công';
END;
GO

--XÓA THÔNG TIN MÓN TRÊN PHIẾU ĐẶT MÓN.
CREATE PROC XOATTPDM
	(@MAPHIEU BIGINT, 
	@MAMON TINYINT)
AS
BEGIN
	--Kiểm tra mã phiếu 
	IF NOT EXISTS (SELECT 1
	FROM PhieuDatMon
	WHERE MaPhieu = @MAPHIEU
	)
	BEGIN
		RAISERROR (N'Mã phiếu đặt món nhập vào không có trong hệ thống',16,1);
		RETURN;
	END;
	--Kiểm tra mã món
	IF NOT EXISTS (SELECT 1 FROM Mon WHERE MaMon = @MAMON)
    BEGIN
        RAISERROR (N'Mã món nhập vào không tồn tại trong hệ thống. Vui lòng kiểm tra lại.', 16, 1);
        RETURN;
    END;
	--Kiểm tra món có nằm trong phiếu đó không
	IF NOT EXISTS 
	(SELECT 1
	FROM ChiTietPhieu
	WHERE MaPhieu = @MAPHIEU AND MaMon = @MAMON)
	BEGIN
        RAISERROR (N'Món ăn này không có trong phiếu đặt món trên. Vui lòng kiểm tra lại.', 16, 1);
        RETURN;
    END;

	DELETE FROM ChiTietPhieu
	WHERE MaMon = @MAMON AND MaPhieu = @MAPHIEU
	PRINT N'Xóa món thành công';
END;
GO

use qlnhahang
go
--SP THÊM THÔNG TIN THẺ KHÁCH HÀNG 
CREATE PROC THEMTHEKH
	@SODIENTHOAI char(10), @NHANVIENLAP CHAR(6) 
AS
BEGIN
	--Kiểm tra mã khách hàng có tồn tại không
	IF NOT EXISTS (SELECT 1
	FROM KhachHang
	WHERE SoDienThoai = @SODIENTHOAI
	)
	BEGIN
		RAISERROR (N'Mã khách hàng nhập vào không có trong hệ thống',16,1);
		RETURN;
	END;
	--Kiểm tra khách hàng đã có thẻ trước đó hay không
	IF EXISTS (SELECT 1
	FROM TheKhachHang
	WHERE SoDienThoai = @SODIENTHOAI
	)
	BEGIN
		RAISERROR (N'Khách hàng đã có thẻ khách hàng trước đó',16,1);
		RETURN;
	END;
	--KIỂM TRA NHÂN VIÊN
	IF NOT EXISTS (SELECT 1 FROM NhanVien WHERE MaNhanVien = @NHANVIENLAP)
    BEGIN
        RAISERROR (N'Mã nhân viên nhập vào không có trong hệ thống. Vui lòng kiểm tra lại.', 16, 1);
        RETURN;
    END;

	DECLARE @MASOTHE INT
	SET @MASOTHE = (SELECT ISNULL(MAX(MaSoThe), 0) + 1 FROM TheKhachHang);
	--note
	INSERT INTO TheKhachHang(MaSoThe, SoDienThoai, NhanVienLap)
	VALUES (@MASOTHE, @SODIENTHOAI, @NHANVIENLAP)
	PRINT N'Thêm thẻ khách hàng thành công';
END;
GO


CREATE PROCEDURE CAPNHAT_THEKHACHHANG

	(@MASOTHE CHAR(12), 
	@SODIENTHOAI char(10), 
	@NGAYLAP DATE, 
	@NHANVIENLAP CHAR(6), 
	@TRANGTHAITHE BIT , 
	@DIEMHIENTAI INT, 
	@DIEMTICHLUY INT, 
	@NGAYDATTHE DATE, 
	@LOAITHE NVARCHAR(20))

AS
BEGIN
	--Kiểm tra mã số thẻ khách hàng có tồn tại không
	IF NOT EXISTS (SELECT 1
	FROM TheKhachHang
	WHERE MaSoThe = @MASOTHE
	)
	BEGIN
		RAISERROR (N'Mã số thẻ khách hàng nhập vào không có trong hệ thống',16,1);
		RETURN;
	END;
	--Kiểm tra mã khách hàng có tồn tại không
	IF NOT EXISTS (SELECT 1
	FROM KhachHang
	WHERE SoDienThoai = @SODIENTHOAI
	)
	BEGIN
		RAISERROR (N'Mã khách hàng nhập vào không có trong hệ thống',16,1);
		RETURN;
	END;
	--KIỂM TRA NHÂN VIÊN
	IF NOT EXISTS (SELECT 1 FROM NhanVien WHERE MaNhanVien = @NHANVIENLAP)
    BEGIN
        RAISERROR (N'Mã nhân viên nhập vào không có trong hệ thống. Vui lòng kiểm tra lại.', 16, 1);
        RETURN;
    END;

	UPDATE TheKhachHang
	SET 
					SoDienThoai = COALESCE(@SODIENTHOAI, SoDienThoai),
					NgayLap = COALESCE(@NGAYLAP, NgayLap),
					NhanVienLap = COALESCE(@NHANVIENLAP,NhanVienLap),
					TrangThaiThe = COALESCE(@TRANGTHAITHE, TrangThaiThe),
					DiemHienTai = COALESCE(@DIEMHIENTAI, DiemHienTai),
					DiemTichLuy = COALESCE(@DIEMTICHLUY, DiemTichLuy),
					--NgayDatThe = COALESCE(@MABOPHAN, MaBoPhan),
					LoaiThe = COALESCE(@LOAITHE, LoaiThe)
				WHERE MaSoThe = @MASOTHE;

    PRINT 'Cập nhật thông tin thẻ khách hàng thành công.';
END
GO


--SP ĐÓNG THẺ KHÁCH HÀNG KHI KHÁCH HÀNG BÁO MẤT THẺ
CREATE PROC XOATHEKH
	(@SOCCCD CHAR(12), 
	@HOTEN NVARCHAR(255), 
	@SODIENTHOAI CHAR(10))
AS
BEGIN
	--KIỂM TRA HỌ TÊN
	IF NOT EXISTS (SELECT 1 FROM KhachHang where HoTen= @HOTEN)
	BEGIN
        RAISERROR (N'Tên khách hàng không có trong hệ thống. Vui lòng kiểm tra lại.', 16, 1);
        RETURN;
    END;
	--KIỂM TRA SỐ ĐIỆN THOẠI
	IF NOT EXISTS (SELECT 1 FROM KhachHang where SoDienThoai = @SODIENTHOAI)
	BEGIN
        RAISERROR (N'Số điện thoại này không có trong hệ thống. Vui lòng kiểm tra lại.', 16, 1);
        RETURN;
    END;
	--KIỂM TRA SCCCD
	IF NOT EXISTS (SELECT 1 FROM KhachHang WHERE SoCCCD = @SOCCCD)
    BEGIN
        RAISERROR (N'Số CCCD này không có trong hệ thống. Vui lòng kiểm tra lại.', 16, 1);
        RETURN;
    END;
	
	--KIỂM TRA KHÁCH HÀNG CÓ THẺ KHÁCH HÀNG KHÔNG
	IF NOT EXISTS (SELECT 1 FROM TheKhachHang WHERE SoDienThoai = 
	(SELECT SoDienThoai FROM KhachHang WHERE SoCCCD = @SOCCCD and TrangThaiThe = 1))
    BEGIN
        RAISERROR (N'Khách hàng này không có thẻ khách hàng đang hoạt động. Vui lòng kiểm tra lại.', 16, 1);
        RETURN;
    END;

	UPDATE TheKhachHang
	SET TrangThaiThe = 0
	WHERE SoDienThoai = (SELECT SoDienThoai FROM KhachHang WHERE SoCCCD = @SOCCCD)
	PRINT N'Đóng thẻ khách hàng thành công';
END;
GO






--STORED PROCEDURE PH KHACH HANG
-- Stored procedure phân hệ KHÁCH HÀNG

--1. ĐĂNG KÍ TÀI KHOẢN
CREATE PROCEDURE SP_DANGKI_TAIKHOAN
	(@HoTen NVARCHAR(255), 
	@SoDienThoai CHAR(10),
	@Email VARCHAR (255), 
	@SoCCCD CHAR (12),
	@GioiTinh NVARCHAR(4))
AS
BEGIN
	IF EXISTS (SELECT 1 FROM KhachHang WHERE SoCCCD = @SoCCCD 
		OR SoDienThoai = @SoDienThoai OR Email = @Email)
		BEGIN
			RAISERROR(N'Thông tin khách hàng đã tồn tại',16,1);
			RETURN;
		END;

		INSERT INTO KhachHang (SoCCCD, SoDienThoai, Email, HoTen, GioiTinh)
		VALUES (@SoCCCD, @SoDienThoai, @Email, @HoTen, @GioiTinh)
END;
GO

--2. ĐĂNG NHẬP
/*
CREATE PROCEDURE SP_DANGNHAP
    @Email NVARCHAR(50),
    @MatKhau VARCHAR(100)
AS
BEGIN
    SELECT * 
    FROM KhachHang
    WHERE Email = @Email AND MatKhau = @MatKhau;
END;

*/

--3. QUẢN LÝ THÔNG TIN CÁ NHÂN
----NOTE THÊM CHỈNH SỬA SOCCCD
CREATE PROCEDURE SP_CAPNHAT_THONGTINCANHAN  
		(@SoDienThoai CHAR(10),
		@Email VARCHAR(255), 
		@GioiTinh NVARCHAR(4))
AS
BEGIN
	IF EXISTS (SELECT 1 FROM KhachHang WHERE SoDienThoai = @SoDienThoai OR Email = @Email)
	BEGIN 
		RAISERROR('Thông tin vừa cập nhật giống với thông tin đã tồn tại',16,1);
		RETURN;
	END;

	UPDATE KhachHang
	SET SoDienThoai = COALESCE(@SoDienThoai, SoDienThoai),
		Email = COALESCE(@Email, Email),
		GioiTinh = COALESCE (@GioiTinh, GioiTinh)
	WHERE SoDienThoai = @SoDienThoai;
END;
GO
--4. ĐẶT BÀN TRỰC TUYẾN -- khi khách hàng đến, nhân viên sẽ kiểm tra các phiếu đặt món của khách hàng mà chưa có hóa đơn
-- Bổ sung thêm như quy trình trên mess đã miêu tả


CREATE PROCEDURE SP_DATBAN_TRUCTUYEN
   (@SoDienThoai char(10), 
	@MaChiNhanh TINYINT, 
	@SoLuongKhach TINYINT,
	@GioDen DATETIME, 
	@GhiChu NVARCHAR(255))
AS
BEGIN
	IF NOT EXISTS (SELECT 1 FROM KhachHang WHERE SoDienThoai = @SoDienThoai)
	BEGIN
		RAISERROR(N'Không tìm thấy mã khách hàng!', 16,1);
		RETURN;
	END;

	IF NOT EXISTS (SELECT 1 FROM ChiNhanh WHERE MaChiNhanh = @MaChiNhanh)
	BEGIN
		RAISERROR(N'Không tìm thấy mã chi nhánh', 16,1);
		RETURN;
	END;

	INSERT INTO DatTruoc (SoDienThoai, ChiNhanh, SoLuongKhach, GioDen, GhiChu)
	VALUES (@SoDienThoai, @MaChiNhanh, @SoLuongKhach, @GioDen, @GhiChu);
END;
GO
--5. ĐẶT MÓN TRỰC TUYẾN
--Phải tạo trước phiếu đặt món trước rồi mới thêm món được, không có nhập vào mã phiếu được
CREATE PROCEDURE SP_DATMON_TRUCTUYEN
	(@MaPhieu BIGINT, 
	@MaMon SMALLINT, 
	@SoLuong TINYINT, 
	@GhiChu NVARCHAR(200))
AS 
BEGIN
	IF NOT EXISTS (
		SELECT 1 FROM Mon M
		JOIN PhucVu P ON M.MaMon = P.MaMon
		WHERE M.MaMon = @MaMon AND P.CoPhucVuKhong = 0 )
	BEGIN 
		RAISERROR(N'Món ăn không tồn tại hoặc không được phục vụ', 16, 1);
		RETURN;
	END;
	
	INSERT INTO ChiTietPhieu (MaPhieu, MaMon, SoLuong, GhiChu)
	VALUES (@MaPhieu, @MaMon, @SoLuong, @GhiChu);
END;
GO
--6. THANH TOÁN TRỰC TUYỂN

CREATE PROCEDURE SP_THANHTOAN_TRUCTUYEN
    (@MaPhieu BIGINT)
AS
BEGIN
    IF EXISTS (SELECT 1 FROM HoaDon WHERE MaPhieu = @MaPhieu)
    BEGIN
        RAISERROR(N'Phiếu đặt món đã được thanh toán!', 16, 1);
        RETURN;
    END;

    DECLARE @TongTien DECIMAL(10, 2);
    SELECT @TongTien = SUM(CTP.SoLuong * M.GiaHienTai)
    FROM ChiTietPhieu CTP
    JOIN Mon M ON CTP.MaMon = M.MaMon
    WHERE CTP.MaPhieu = @MaPhieu;

    IF @TongTien IS NULL
    BEGIN
        RAISERROR(N'Không tìm thấy chi tiết phiếu đặt món!', 16, 1);
        RETURN;
    END;

    DECLARE @SoDienThoai INT;
    SELECT @SoDienThoai = PD.SODIENTHOAI
    FROM PhieuDatMon PD
    WHERE PD.MaPhieu = @MaPhieu;

    IF @SoDienThoai IS NULL
    BEGIN
        RAISERROR(N'Không tìm thấy khách hàng liên quan đến phiếu đặt món!', 16, 1);
        RETURN;
    END;

    DECLARE @LoaiThe NVARCHAR(20) = N'Membership';
    DECLARE @GiamGia DECIMAL(5, 2) = 0;

    SELECT @LoaiThe = TK.LoaiThe
    FROM TheKhachHang TK
    WHERE TK.SoDienThoai = @SoDienThoai;

    SET @GiamGia = CASE 
                      WHEN @LoaiThe = N'Gold' THEN @TongTien * 0.1
                      WHEN @LoaiThe = N'Silver' THEN @TongTien * 0.05
                      ELSE 0
                   END;

    INSERT INTO HoaDon (MaPhieu, NgayLap, TongTien, GiamGia, ThanhTien)
    VALUES (@MaPhieu, GETDATE(), @TongTien, @GiamGia, @TongTien - @GiamGia);

    PRINT N'Thanh toán thành công. Hóa đơn đã được tạo!';
END;
GO

--7. ĐÁNH GIÁ DỊCH VỤ
CREATE PROCEDURE SP_DANHGIA_DICHVU
	(@MaPhieu BIGINT, 
	@DiemPhucVu TINYINT,  
	@DiemViTri TINYINT,
    @DiemChatLuong TINYINT, 
	@DiemKhongGian TINYINT, 
	@BinhLuan NVARCHAR(MAX))
AS 
BEGIN
	IF @DiemPhucVu NOT BETWEEN 1 AND 5
	OR @DiemViTri NOT BETWEEN 1 AND 5
	OR @DiemChatLuong NOT BETWEEN 1 AND 5
	OR @DiemKhongGian NOT BETWEEN 1 AND 5
	BEGIN
		RAISERROR(N'Điểm đánh giá phải từ 1 đến 5!', 16, 1);
		RETURN;
	END;

	INSERT INTO DanhGia(MaPhieu, DiemPhucVu, DiemViTri, DiemChatLuong, DiemKhongGian, BinhLuan)
	VALUES (@MaPhieu, @DiemPhucVu, @DiemViTri, @DiemChatLuong, @DiemKhongGian, @BinhLuan);
END;
GO
--8. THEO DÕI LỊCH SỬ ĐẶT BÀN
CREATE PROCEDURE SP_LICHSU_DATBAN
	@SoDienThoai char(10)
AS
BEGIN
	SELECT MaDatTruoc, SoDienThoai, SoLuongKhach, GioDen, GhiChu
	FROM DatTruoc
	WHERE SoDienThoai = @SoDienThoai;
END;
GO
--9. THEO DÕI LỊCH SỬ ĐẶT MÓN

CREATE PROCEDURE SP_LICHSU_DATMON
	@SoDienThoai char(10)
AS
BEGIN 
	SELECT PD.MaPhieu, CTP.MaMon, CTP.SoLuong
	FROM PhieuDatMon PD
	JOIN ChiTietPhieu CTP ON PD.MaPhieu = CTP.MaPhieu
	WHERE PD.SODIENTHOAI = @SoDienThoai;
END;
GO


--10. XEM THÔNG TIN THẺ THÀNH VIÊN
CREATE PROCEDURE SP_XEMTHONGTIN_THETHANHVIEN
    (@SoDienThoai BIGINT)
AS
BEGIN
    SELECT LoaiThe, DiemHienTai, DiemTichLuy
    FROM TheKhachHang
    WHERE SoDienThoai = @SoDienThoai;
END;
GO
--11. GỬI PHẢN HỒI (CÁI NÀY GIỐNG ĐÁNH GIÁ)

--12. HỖ TRỢ GIAO HÀNG (THUỘC VỀ VẬN CHUYỂN)

--13. HỦY ĐƠN HÀNG
CREATE PROCEDURE SP_HUYDONHANG
    (@MaPhieu BIGINT)
AS
BEGIN
    DELETE FROM PhieuDatMon WHERE MaPhieu = @MaPhieu;
END;
GO
--14. ĐĂNG XUẤT - QUẢN LÝ SESSIONN Ở ỨNG DỤNG

--15. QUÊN MẬT KHẨU
CREATE PROCEDURE SP_QUENMATKHAU
    (@Email VARCHAR(255))
AS
BEGIN
    PRINT 'Mã đặt lại mật khẩu đã được gửi qua email.';
END;
GO
-- CẬP NHẬT LOẠI THẺ KHÁCH HÀNG
CREATE PROCEDURE SP_CAPNHAT_LOAITHEKHACHHANG
AS
BEGIN
    -- Cập nhật từ GOLD xuống SILVER
    UPDATE TheKhachHang
    SET LoaiThe = N'Silver',
        NgayDatThe = GETDATE()
    WHERE LoaiThe = N'Gold'
      AND DATEDIFF(DAY, NgayDatThe, GETDATE()) <= 365
      AND DiemTichLuy < 100;

    -- Cập nhật từ SILVER xuống Membership
    UPDATE TheKhachHang
    SET LoaiThe = N'Membership',
        NgayDatThe = GETDATE()
    WHERE LoaiThe = N'Silver'
      AND DATEDIFF(DAY, NgayDatThe, GETDATE()) <= 365
      AND DiemTichLuy < 50;

    -- Nâng từ SILVER lên GOLD
    UPDATE TheKhachHang
    SET LoaiThe = N'Gold',
        NgayDatThe = GETDATE()
    WHERE LoaiThe = N'Silver'
      AND DATEDIFF(DAY, NgayDatThe, GETDATE()) <= 365
      AND DiemTichLuy >= 100;

    -- Cập nhật hạng SILVER
    UPDATE TheKhachHang
    SET LoaiThe = N'Silver',
        NgayDatThe = GETDATE()
    WHERE LoaiThe = N'Membership'
      AND DiemTichLuy >= 100;

    UPDATE TheKhachHang
    SET LoaiThe = N'Membership',
        NgayDatThe = GETDATE()
    WHERE LoaiThe NOT IN (N'Membership', N'Silver', N'Gold');
END;
GO

CREATE OR ALTER PROCEDURE SP_THONGKEDOANHTHU_MONAN
    (@NGAYBATDAU DATE,       -- Ngày bắt đầu thống kê
    @NGAYKETHUC DATE,       -- Ngày kết thúc thống kê
    @MACHINHANH TINYINT,    -- Mã chi nhánh cần thống kê
    @MAKHUVUC TINYINT)      -- Mã khu vực cần thống kê
AS
BEGIN
    -- Kiểm tra logic: Ngày bắt đầu phải nhỏ hơn ngày kết thúc
    IF @NGAYBATDAU >= @NGAYKETHUC
    BEGIN
        RAISERROR ('Ngày bắt đầu phải nhỏ hơn ngày kết thúc.', 16, 1);
        RETURN;
    END

    -- Kiểm tra mã chi nhánh có hợp lệ hay không
    IF NOT EXISTS (SELECT 1 FROM CHINHANH WHERE MaChiNhanh = @MACHINHANH)
    BEGIN
        RAISERROR ('Mã chi nhánh không hợp lệ.', 16, 1);
        RETURN;
    END

    -- Kiểm tra mã khu vực có hợp lệ hay không
    IF NOT EXISTS (SELECT 1 FROM KHUVUC_THUCDON WHERE MaKhuVuc = @MAKHUVUC)
    BEGIN
        RAISERROR ('Mã khu vực không hợp lệ.', 16, 1);
        RETURN;
    END

    -- Thống kê doanh thu theo từng món
    PRINT 'Thống kê doanh thu theo từng món:';
    SELECT 
        M.MaMon, 
        M.TenMon,
        COUNT(*) AS SoLuongBan,
        COUNT(*) * M.GiaHienTai AS TongDoanhThu
    FROM MON M
    JOIN CHITIETPHIEU CTP ON M.MaMon = CTP.MaMon
    JOIN PHIEUDATMON PDM ON PDM.MaPhieu = CTP.MaPhieu
    JOIN HOADON HD ON PDM.MaPhieu = HD.MaPhieu
    JOIN CHINHANH CN ON PDM.MaChiNhanh = CN.MaChiNhanh
    JOIN KHUVUC_THUCDON KV ON KV.MaKhuVuc = CN.MaKhuVuc
    WHERE KV.MaKhuVuc = @MAKHUVUC
      AND CN.MaChiNhanh = @MACHINHANH
      AND HD.NgayLap >= @NGAYBATDAU 
      AND HD.NgayLap <= @NGAYKETHUC
    GROUP BY M.MaMon, M.TenMon, M.GiaHienTai
    ORDER BY TongDoanhThu DESC;

    -- Món chạy nhất (bán nhiều nhất)
    PRINT 'Món chạy nhất:';
    SELECT TOP 1 
        M.MaMon, 
        M.TenMon, 
        COUNT(*) AS SoLuongBan,
        COUNT(*) * M.GiaHienTai AS TongDoanhThu
    FROM MON M
    JOIN CHITIETPHIEU CTP ON M.MaMon = CTP.MaMon
    JOIN PHIEUDATMON PDM ON PDM.MaPhieu = CTP.MaPhieu
    JOIN HOADON HD ON PDM.MaPhieu = HD.MaPhieu
    JOIN CHINHANH CN ON PDM.MaChiNhanh = CN.MaChiNhanh
    JOIN KHUVUC_THUCDON KV ON KV.MaKhuVuc = CN.MaKhuVuc
    WHERE KV.MaKhuVuc = @MAKHUVUC
      AND CN.MaChiNhanh = @MACHINHANH
      AND HD.NgayLap >= @NGAYBATDAU 
      AND HD.NgayLap <= @NGAYKETHUC
    GROUP BY M.MaMon, M.TenMon, M.GiaHienTai
    ORDER BY SoLuongBan DESC;

    -- Món bán chậm nhất (bán ít nhất)
    PRINT 'Món bán chậm nhất:';
    SELECT TOP 1 
        M.MaMon, 
        M.TenMon, 
        COUNT(*) AS SoLuongBan,
        COUNT(*) * M.GiaHienTai AS TongDoanhThu
    FROM MON M
    JOIN CHITIETPHIEU CTP ON M.MaMon = CTP.MaMon
    JOIN PHIEUDATMON PDM ON PDM.MaPhieu = CTP.MaPhieu
    JOIN HOADON HD ON PDM.MaPhieu = HD.MaPhieu
    JOIN CHINHANH CN ON PDM.MaChiNhanh = CN.MaChiNhanh
    JOIN KHUVUC_THUCDON KV ON KV.MaKhuVuc = CN.MaKhuVuc
    WHERE KV.MaKhuVuc = @MAKHUVUC
      AND CN.MaChiNhanh = @MACHINHANH
      AND HD.NgayLap >= @NGAYBATDAU 
      AND HD.NgayLap <= @NGAYKETHUC
    GROUP BY M.MaMon, M.TenMon, M.GiaHienTai
    ORDER BY SoLuongBan ASC;
END;
<<<<<<< HEAD
GO


--DDIEU DONG NHAN VIEN
 CREATE OR ALTER   PROC MoveEmployee 
		@MaNhanVien CHAR(10),
		@MaChiNhanhMoi TINYINT
	AS
	BEGIN
		--Kiem tra ton tai ma nhan vien
		IF NOT EXISTS (SELECT 1 FROM NhanVien WHERE MaNhanVien = @MaNhanVien) OR 
		NOT EXISTS (SELECT 1 FROM LichSuLamViec WHERE MaNhanVien = @MaNhanVien AND NgayKetThuc IS NULL)
		BEGIN
			RAISERROR (N'NHÂN VIÊN KHÔNG TỒN TẠI TRONG HỆ THỐNG HOẶC ĐÃ NGƯNG LÀM VIỆC!',16,1);
			RETURN;
		END
		--KIEM TRA CHI NHANH MƠI
		IF NOT EXISTS (SELECT 1 FROM ChiNhanh WHERE MaChiNhanh = @MaChiNhanhMoi)
		BEGIN
			RAISERROR (N'CHI NHÁNH KHÔNG TỒN TẠI!',16,1);
			RETURN;
		END
		UPDATE LichSuLamViec 
		SET NgayKetThuc =  getdate()
		WHERE NgayKetThuc IS NULL

		INSERT INTO LichSuLamViec (MaNhanVien, NgayBatDau,MaChiNhanh)
		VALUES (@MaNhanVien, GETDATE(), @MaChiNhanhMoi)
		PRINT N'Chuyển nhân sự thành công';
	END
	GO



	--sp_9 Tìm nhân viên theo tên TRONG CHI NHANH 
	 CREATE OR ALTER  PROCEDURE sp_TimNhanVienTheoTen
		@HoTen NVARCHAR(255), @MACHINHANH TINYINT
	AS
	BEGIN
		IF NOT EXISTS (SELECT 1 FROM ChiNhanh WHERE MaChiNhanh = @MACHINHANH)
		BEGIN
			RAISERROR (N'Mã chi nhánh không tồn tại trong hệ thống',16,1);
			return ;
		END
		SELECT * 
		FROM NhanVien n JOIN LichSuLamViec l ON n.MaNhanVien = l.MaNhanVien
		WHERE l.MaChiNhanh = @MACHINHANH AND n.HoTen = @HoTen;
	END;
	go

	--sp_10 Tìm nhân viên theo Ngày sinh
	 CREATE OR ALTER  PROCEDURE sp_TimNhanVienTheoNgaySinh
		@NgaySinh DATE, @MACHINHANH TINYINT
	AS
	BEGIN
		IF NOT EXISTS (SELECT 1 FROM ChiNhanh WHERE MaChiNhanh = @MACHINHANH)
		BEGIN
			RAISERROR (N'Mã chi nhánh không tồn tại trong hệ thống',16,1);
			return ;
		END
		SELECT * 
		FROM NhanVien n JOIN LichSuLamViec l ON n.MaNhanVien = l.MaNhanVien
		WHERE l.MaChiNhanh = @MACHINHANH AND n.NgaySinh = @NgaySinh ;
	END;
	go

	--sp_11 Tìm nhân viên theo ngày vào làm
	 CREATE OR ALTER  PROCEDURE sp_TimNhanVienTheoNgayVaoLam
		@NgayVaoLam DATE, @MACHINHANH TINYINT
	AS
	BEGIN
		IF NOT EXISTS (SELECT 1 FROM ChiNhanh WHERE MaChiNhanh = @MACHINHANH)
		BEGIN
			RAISERROR (N'Mã chi nhánh không tồn tại trong hệ thống',16,1);
			return ;
		END
		SELECT * 
		FROM NhanVien n
		WHERE n.NgayVaoLam = @NgayVaoLam;
	END;
	go


	--sp_12 Tìm nhân viên theo bộ phận 
	 CREATE OR ALTER  PROCEDURE sp_TimNhanVienTheoBoPhan
		@MaBoPhan NVARCHAR(50), @MACHINHANH TINYINT
	AS
	BEGIN
		IF NOT EXISTS (SELECT 1 FROM ChiNhanh WHERE MaChiNhanh = @MACHINHANH)
		BEGIN
			RAISERROR (N'Mã chi nhánh không tồn tại trong hệ thống',16,1);
			return ;
		END
		SELECT * 
		FROM NhanVien n JOIN LichSuLamViec l ON n.MaNhanVien = l.MaNhanVien
		WHERE l.MaChiNhanh = @MACHINHANH AND n.MaBoPhan = @MaBoPhan;
	END;
	go 
	

	--xem tt nhan vien, diem phuc vu theo ngay
 CREATE OR ALTER  PROCEDURE sp_DiemPhucVuTheoNgay
    @Ngay DATE
AS
BEGIN
    SELECT 
        n.MaNhanVien,
        n.HoTen,
        AVG(dg.DiemPhucVu) AS TongDiemPhucVu,
        CONVERT(DATE, p.NgayLap) AS Ngay
    FROM 
        NhanVien n
    JOIN 
        PhieuDatMon p ON n.MaNhanVien = p.NhanVienLap
    JOIN 
        DanhGia dg ON p.MaPhieu = dg.MaPhieu
    WHERE 
        CONVERT(DATE, p.NgayLap) = @Ngay
    GROUP BY 
        n.MaNhanVien, n.HoTen, CONVERT(DATE, p.NgayLap)
    ORDER BY 
        Ngay DESC, n.MaNhanVien;
END;
go	
	
--sp_5 xem danh sách nhân viên, điểm phục vụ của từng nhân viên cuối mỗi tháng 
 CREATE OR ALTER  PROCEDURE sp_DiemPhucVuTheoThang
    @Thang INT,
    @Nam INT
AS
BEGIN
    SELECT 
        n.MaNhanVien,
        n.HoTen,
        AVG(dg.DiemPhucVu) AS TongDiemPhucVu,
        DATEPART(YEAR, p.NgayLap) AS Nam,
        DATEPART(MONTH, p.NgayLap) AS Thang
    FROM 
        NhanVien n
    JOIN 
        PhieuDatMon p ON n.MaNhanVien = p.NhanVienLap
    JOIN 
        DanhGia dg ON p.MaPhieu = dg.MaPhieu
    WHERE 
        DATEPART(YEAR, p.NgayLap) = @Nam AND DATEPART(MONTH, p.NgayLap) = @Thang
    GROUP BY 
        n.MaNhanVien, n.HoTen, DATEPART(YEAR, p.NgayLap), DATEPART(MONTH, p.NgayLap)
    ORDER BY 
        Nam DESC, Thang DESC, n.MaNhanVien;
END;
go
--sp_5 xem danh sách nhân viên, điểm phục vụ của từng nhân viên cuối mỗi quý 
 CREATE OR ALTER  PROCEDURE sp_DiemPhucVuTheoQuy
    @Quy INT,
    @Nam INT
AS
BEGIN
    SELECT 
        n.MaNhanVien,
        n.HoTen,
        AVG(dg.DiemPhucVu) AS TongDiemPhucVu,
        DATEPART(YEAR, p.NgayLap) AS Nam,
        DATEPART(QUARTER, p.NgayLap) AS Quy
    FROM 
        NhanVien n
    JOIN 
        PhieuDatMon p ON n.MaNhanVien = p.NhanVienLap
    JOIN 
        DanhGia dg ON p.MaPhieu = dg.MaPhieu
    WHERE 
        DATEPART(YEAR, p.NgayLap) = @Nam AND DATEPART(QUARTER, p.NgayLap) = @Quy
    GROUP BY 
        n.MaNhanVien, n.HoTen, DATEPART(YEAR, p.NgayLap), DATEPART(QUARTER, p.NgayLap)
    ORDER BY 
        Nam DESC, Quy DESC, n.MaNhanVien;
END;
go

--sp_5 xem danh sách nhân viên, điểm phục vụ của từng nhân viên cuối mỗi năm
	 CREATE OR ALTER  PROCEDURE sp_DiemPhucVuTheoNam
		@Nam INT
	AS
	BEGIN
		SELECT 
			n.MaNhanVien,
			n.HoTen,
			AVG(dg.DiemPhucVu) AS TongDiemPhucVu,
			DATEPART(YEAR, p.NgayLap) AS Nam
		FROM 
			NhanVien n
		JOIN 
			PhieuDatMon p ON n.MaNhanVien = p.NhanVienLap
		JOIN 
			DanhGia dg ON p.MaPhieu = dg.MaPhieu
		WHERE 
			DATEPART(YEAR, p.NgayLap) = @Nam
		GROUP BY 
			n.MaNhanVien, n.HoTen, DATEPART(YEAR, p.NgayLap)
		ORDER BY 
			Nam DESC, n.MaNhanVien;
	END;
	go

--TIMF HOA DON THEO KHACH HANG
 CREATE OR ALTER  PROC	 TIMHD_KH 
		@SODIENTHOAI CHAR(10)
	AS 
	BEGIN
		IF NOT EXISTS (SELECT 1 FROM KhachHang WHERE SoDienThoai = @SODIENTHOAI)
	BEGIN
		RAISERROR(N'Không tìm thấy khách hàng trong hệ thống!', 16,1);
		RETURN;
	END;
	SELECT* FROM HoaDon h JOIN PhieuDatMon p ON h.MaPhieu = p.MaPhieu 
	WHERE p.SODIENTHOAI = @SODIENTHOAI


	END
	GO

--TIMF HOA DON THEO NGAY
 CREATE OR ALTER  PROC	 TIMHD_NGAY 
		@NGAY DATE
	AS 
	BEGIN
		IF @NGAY > GETDATE()
	BEGIN
		RAISERROR(N'Ngày nhập vào không hợp lệ!', 16,1);
		RETURN;
	END;
	SELECT* FROM HoaDon h JOIN PhieuDatMon p ON h.MaPhieu = p.MaPhieu 
	WHERE p.NgayLap = @NGAY

	END
	GO




=======
GO
>>>>>>> parent of fe15bcf (Update)
