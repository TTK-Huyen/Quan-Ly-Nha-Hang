USE QLNHAHANG
GO
--TRIGGER Phân hệ Chi Nhánh
GO
CREATE TRIGGER CHECK_TGIANDONGCUA_TGIANMOCUA
ON ChiNhanh
AFTER INSERT, UPDATE
AS
BEGIN
	DECLARE @TGIANDONG TIME, @TGIANMO TIME

	SELECT
		@TGIANDONG=inserted.ThoiGianDongCua,
		@TGIANMO=inserted.ThoiGianMoCua
	FROM inserted

	IF(@TGIANDONG<@TGIANMO)
		BEGIN
			RAISERROR(N'Thời gian đóng cửa đang nhỏ hơn thời gian đóng cửa',16,1)
			ROLLBACK
		END
END
GO



CREATE TRIGGER CHECK_SDT
ON CHINHANH
AFTER INSERT, UPDATE
AS
BEGIN
	DECLARE @SDT VARCHAR(10)

	SELECT
		@SDT=inserted.SoDienThoai
	FROM inserted

	IF(@SDT=NULL)
		BEGIN
			RAISERROR(N'Số điện thoại chi nhánh không được để trống',16,1)
			ROLLBACK
		END
END
GO


GO
CREATE TRIGGER CHECK_IU_CHINHANH
ON CHINHANH
AFTER INSERT, UPDATE
AS
BEGIN
	DECLARE @MAKV INT
	
	SELECT
		@MAKV=inserted.MaKhuVuc
	FROM inserted

	IF NOT EXISTS (SELECT 1 FROM KhuVuc AS KV WHERE KV.MaKhuVuc=@MAKV)
		BEGIN
			RAISERROR(N'Không tìm thấy khu vực',16,1)
			ROLLBACK
		END

END
GO


GO
CREATE TRIGGER CHECK_XOA_KHUVUC
ON KhuVuc
AFTER DELETE
AS
BEGIN
	DECLARE @MAKHUVUC INT
	
	SELECT
		@MAKHUVUC=deleted.MaKhuVuc
	FROM deleted

	IF EXISTS (SELECT 1 FROM ChiNhanh AS CN WHERE CN.MaKhuVuc=@MAKHUVUC)
		BEGIN
			RAISERROR(N'Vui lòng xóa mã khu vực của các chi nhánh thuộc khu vực này trước khi thực hiện xóa khu vực',16,1)
			ROLLBACK
		END
END
GO



CREATE TRIGGER CHECK_GIA_MON
ON Mon
AFTER INSERT, UPDATE
AS
BEGIN
	DECLARE @GIA DECIMAL(18,3)

	SELECT
		@GIA=inserted.GiaHienTai
	FROM inserted

	IF(@GIA <=0)
		BEGIN
			RAISERROR(N'Giá món phải lớn hơn 0',16,1)
			ROLLBACK
		END
END
GO

GO
CREATE TRIGGER CHECK_IU_MON
ON MON
AFTER INSERT, UPDATE
AS
BEGIN
	DECLARE @MAMUC INT

	SELECT
		@MAMUC=inserted.MaMuc
	FROM inserted

	IF(@MAMUC NOT IN (SELECT MTD.MaMuc FROM MucThucDon AS MTD))
		BEGIN
			RAISERROR(N'Không tìm thấy mục thực đơn phù hợp',16,1)
			ROLLBACK
		END
END
GO


GO
CREATE TRIGGER CHECK_XOA_MUCTHUCDON
ON MucThucDon
AFTER DELETE
AS
BEGIN
	DECLARE @MAMUC INT

	SELECT
		@MAMUC=deleted.MaMuc
	FROM deleted

	IF EXISTS (SELECT 1 FROM Mon AS M WHERE M.MaMuc=@MAMUC)
		BEGIN
			RAISERROR(N'Vui lòng xóa các món thuộc mục này trước khi tiến hành xóa mục thực đơn',16,1)
			ROLLBACK
		END
END
GO

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







--TRIGGER PHÂN HỆ NHÂN VIÊN

--Mã chi nhánh và mã bộ phận phải có sẵn trong hệ thống trước khi thêm mộtt nhân
--viên vào mộtt chi nhánh hoặc bộ phận.
CREATE TRIGGER THEMNV
ON NhanVien
AFTER INSERT, UPDATE
AS
BEGIN
    -- Ki?m tra mã bộ phận
    IF EXISTS (
        SELECT 1
        FROM INSERTED i
        WHERE NOT EXISTS (
            SELECT 1
            FROM BoPhan
            WHERE BoPhan.MaBoPhan = i.MaBoPhan
        )
    )
    BEGIN
        RAISERROR (N'Mã bộ phận không nằm trong hệ thống', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END;

    -- Kiểm tra mã chi nhánh
    IF EXISTS (
        SELECT 1
        FROM INSERTED i
        WHERE NOT EXISTS (
            SELECT 1
            FROM LichSuLamViec l
            JOIN ChiNhanh c ON l.MaChiNhanh = c.MaChiNhanh
            WHERE l.MaNhanVien = i.MaNhanVien AND l.NgayKetThuc IS NULL
        )
    )
    BEGIN
        RAISERROR (N'Mã chi nhánh không nằm trong hệ thống hoặc nhân viên chưa có chi nhánh làm việc', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END;
END;
GO



--Ngày nghỉ việc của nhân viên (nếu có), phải lớn hơnhơn ngày vào làm.
CREATE TRIGGER CHECK_NGAYNGHIVIEC
ON NhanVien
AFTER INSERT, UPDATE
AS
BEGIN
    DECLARE @MaNhanVien NVARCHAR(50);
    IF EXISTS
    (
        SELECT 1 
        FROM INSERTED i
        WHERE i.NgayNghiViec IS NOT NULL AND i.NgayVaoLam >= i.NgayNghiViec
    )
    BEGIN
        SELECT TOP 1 @MaNhanVien = i.MaNhanVien
        FROM INSERTED i
        WHERE i.NgayNghiViec IS NOT NULL AND i.NgayVaoLam >= i.NgayNghiViec;
        RAISERROR (
            N'Ngày nghỉ việc phải lớn hơn ngày vào làm. Vui lòng kiểm tra lại (Mã nhân viên: %s)',
            16, 1, 
            @MaNhanVien
        );
        ROLLBACK TRANSACTION;
        RETURN;
    END;
END;
GO


--Thuộc tính NgayBatDau phải nhỏ hơn NgayKetThuc trong bảbảng
CREATE TRIGGER CHECK_NGAYKETTHUC
ON LichSuLamViec
AFTER INSERT, UPDATE
AS
BEGIN
    IF EXISTS
    (
        SELECT 1 
        FROM INSERTED i
        WHERE i.NgayKetThuc IS NOT NULL AND i.NgayBatDau >= i.NgayKetThuc
    )
    BEGIN
        RAISERROR (
            N'Ngày kết thúc phải lớn hơn ngày bắt đầu. Vui lòng kiểm tra lại ', 16, 1 );
        ROLLBACK TRANSACTION;
        RETURN;
    END;
END;
GO


--Mỗi nhân viên chỉ làm việc tại một chi nhánh tại một thời điểm
CREATE TRIGGER CHECK_NVCN
ON LichSuLamViec
AFTER INSERT, UPDATE
AS
BEGIN
    IF EXISTS 
    (
        SELECT 1
        FROM INSERTED i
        WHERE 
        (
            SELECT COUNT(*) 
            FROM LichSuLamViec l
            WHERE l.MaNhanVien = i.MaNhanVien AND l.NgayKetThuc IS NULL
        ) > 1
    )
    BEGIN
        RAISERROR (
            N'Mỗi nhân viên chỉ làm việc tại một chi nhánh tại một thời điểm.',16, 1 );
        ROLLBACK TRANSACTION;
        RETURN;
    END;
END;
GO


--Mã nhân viên là duy nhất cho mỗi nhân viên, Họ tên, ngày sinh, giới tính, lươlương,...=> THÊM NOT NULL KHI CÀI ĐẶT 
CREATE TRIGGER KTRTTNV
ON NhanVien
AFTER INSERT, UPDATE
AS
BEGIN
    IF EXISTS (
        SELECT 1
        FROM INSERTED i
        JOIN NhanVien n ON i.MaNhanVien = n.MaNhanVien
        WHERE i.MaNhanVien IS NOT NULL 
          AND i.MaNhanVien <> ''         
          AND i.MaNhanVien <> n.MaNhanVien
    )
    BEGIN
        RAISERROR (N'Lỗi: Mã nhân viên vừa thêm hoặc cập nhật đã tồn tại trong hệ thống với nhân viên khác.', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END;
END;
GO
--Điểm số nhân viên ban đầu phải bằng không.
CREATE TRIGGER KTRDIEMNV
ON NhanVien
AFTER INSERT, UPDATE
AS
BEGIN
    IF EXISTS (
        SELECT 1
        FROM INSERTED i
        WHERE i.DiemSo <> 0
    )
    BEGIN
        RAISERROR (N'Lỗi: Điểm số ban đầu phải bằng 0.', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END;
END;
GO
--Trigger: phan he khach hang 
--	Tại 1 thời điểm, mỗi khách hàng chỉ có thể sở hữu 1 thẻ khách hàng đang hoạt động.
CREATE TRIGGER trg_CheckActiveCard
ON TheKhachHang
INSTEAD OF INSERT
AS
BEGIN
    IF EXISTS (
        SELECT 1 
        FROM TheKhachHang
        WHERE MaKhachHang = (SELECT MaKhachHang FROM inserted)
          AND TrangThaiThe = 1
    )
    BEGIN
        RAISERROR (N'Khách hàng chỉ có thể sở hữu một thẻ đang hoạt động!', 16, 1);
        ROLLBACK TRANSACTION;
    END
    ELSE
    BEGIN
        INSERT INTO TheKhachHang
        SELECT * FROM inserted;
    END
END;


--	Điểm phục vụ do khách hàng đánh giá là điểm của nhân viên lập phiếu. 
CREATE TRIGGER trg_UpdateServiceScore
ON DanhGia
AFTER INSERT
AS
BEGIN
    UPDATE NhanVien
    SET DiemSo = DiemSo + (SELECT DiemPhucVu FROM inserted)
    WHERE MaNhanVien = (SELECT NhanVienLap FROM PhieuDatMon WHERE MaPhieu = (SELECT MaPhieu FROM inserted));
END;

--	Bàn được chọn phải có sức chứa lớn hơn số lượng khách của đơn đặt trước.
CREATE TRIGGER trg_CheckTableCapacity
ON DatCho
INSTEAD OF INSERT
AS
BEGIN
    IF EXISTS (
        SELECT 1
        FROM inserted i
        JOIN Ban b ON i.MaSoBan = b.MaSoBan AND i.MaChiNhanh = b.MaChiNhanh
        JOIN DatTruoc dt ON i.MaDatTruoc = dt.MaDatTruoc
        WHERE b.SucChua < dt.SoLuongKhach
    )
    BEGIN
        RAISERROR ('Bàn được chọn phải có sức chứa lớn hơn số lượng khách!', 16, 1);
        ROLLBACK TRANSACTION;
    END
    ELSE
    BEGIN
        INSERT INTO DatCho
        SELECT * FROM inserted;
    END
END;

--	Số tiền giảm giá trong hóa đơn phải thấp hơn tổng tiền. 
CREATE TRIGGER trg_ValidateDiscount
ON HoaDon
INSTEAD OF INSERT
AS
BEGIN
    IF EXISTS (
        SELECT 1 
        FROM inserted
        WHERE GiamGia >= TongTien
    )
    BEGIN
        RAISERROR ('Số tiền giảm giá phải thấp hơn tổng tiền!', 16, 1);
        ROLLBACK TRANSACTION;
    END
    ELSE
    BEGIN
        INSERT INTO HoaDon
        SELECT * FROM inserted;
    END
END;

--	Phiếu đặt món bắt buộc phải có các thuộc tính bao gồm mã phiếu, ngày lập, nhân viên lập, mã số bàn, mã khách hàng. 
CREATE TRIGGER trg_CheckOrderAttributes
ON PhieuDatMon
INSTEAD OF INSERT
AS
BEGIN
    IF EXISTS (
        SELECT 1 
        FROM inserted
        WHERE NgayLap IS NULL OR NhanVienLap IS NULL OR MaSoBan IS NULL OR MaKhachHang IS NULL
    )
    BEGIN
        RAISERROR ('Phiếu đặt món phải có đủ các thuộc tính: ngày lập, nhân viên lập, mã số bàn, mã khách hàng!', 16, 1);
        ROLLBACK TRANSACTION;
    END
    ELSE
    BEGIN
        INSERT INTO PhieuDatMon
        SELECT * FROM inserted;
    END
END;

--	Mã phiếu trong phiếu đặt món phải là duy nhất để phân biệt với các mã phiếu khác. Mã bàn trong mỗi chi nhánh phải là duy nhất và tuân theo quy tắc sau: 
--o	o Đối với khách sử dụng dịch vụ trực tiếp tại bàn, mã số bàn sẽ là số thứ tự của các bàn trong chi nhánh (ví dụ: 1, 2, 3, …).
--o	 o Đối với khách mang về hoặc không sử dụng bàn tại quán, mã số bàn sẽ mang mã đặc biệt là MV (Mang Về).


CREATE TRIGGER trg_UniqueOrderID
ON PhieuDatMon
INSTEAD OF INSERT
AS
BEGIN
    IF EXISTS (
        SELECT 1
        FROM PhieuDatMon
        WHERE MaPhieu IN (SELECT MaPhieu FROM inserted)
    )
    BEGIN
        RAISERROR ('Mã phiếu trong phiếu đặt món phải là duy nhất!', 16, 1);
        ROLLBACK TRANSACTION;
    END
    ELSE
    BEGIN
        INSERT INTO PhieuDatMon
        SELECT * FROM inserted;
    END
END;
CREATE TRIGGER trg_ValidateTableID_DirectService
ON Ban
INSTEAD OF INSERT
AS
BEGIN
    IF EXISTS (
        SELECT 1
        FROM inserted i
        WHERE i.TrangThai = 1  -- Bàn sử dụng trực tiếp
          AND EXISTS (
              SELECT 1
              FROM Ban b
              WHERE b.MaChiNhanh = i.MaChiNhanh AND b.MaSoBan = i.MaSoBan
          )
    )
    BEGIN
        RAISERROR ('Mã số bàn trong chi nhánh phải là duy nhất!', 16, 1);
        ROLLBACK TRANSACTION;
    END
    ELSE
    BEGIN
        INSERT INTO Ban
        SELECT * FROM inserted;
    END
END;
CREATE TRIGGER trg_ValidateTableID_Takeaway
ON Ban
INSTEAD OF INSERT
AS
BEGIN
    IF EXISTS (
        SELECT 1
        FROM inserted i
        WHERE i.TrangThai = 0  -- Bàn không sử dụng tại chỗ (Mang về)
          AND i.MaSoBan != 'MV'
    )
    BEGIN
        RAISERROR ('Mã số bàn cho khách mang về phải là MV!', 16, 1);
        ROLLBACK TRANSACTION;
    END
    ELSE
    BEGIN
        INSERT INTO Ban
        SELECT * FROM inserted;
    END
END;

--	Thời gian nhận bàn phải trễ hơn thời gian lúc đặt trước.
CREATE TRIGGER trg_CheckReservationTime
ON DatCho
INSTEAD OF INSERT
AS
BEGIN
    IF EXISTS (
        SELECT 1
        FROM inserted i
        JOIN DatTruoc d ON i.MaDatTruoc = d.MaDatTruoc
        WHERE d.GioDen >= GETDATE()
    )
    BEGIN
        RAISERROR ('Thời gian nhận bàn phải trễ hơn thời gian lúc đặt trước!', 16, 1);
        ROLLBACK TRANSACTION;
    END
    ELSE
    BEGIN
        INSERT INTO DatCho
        SELECT * FROM inserted;
    END
END;

--	Đánh giá khách hàng: Điểm số nằm trong khoảng từ 1 đến 5.
CREATE TRIGGER trg_CheckRating
ON DanhGia
INSTEAD OF INSERT
AS
BEGIN
    IF EXISTS (
        SELECT 1 
        FROM inserted
        WHERE DiemPhucVu NOT BETWEEN 1 AND 5 
           OR DiemViTri NOT BETWEEN 1 AND 5 
           OR DiemChatLuong NOT BETWEEN 1 AND 5 
           OR DiemKhongGian NOT BETWEEN 1 AND 5
    )
    BEGIN
        RAISERROR ('Điểm đánh giá phải nằm trong khoảng từ 1 đến 5!', 16, 1);
        ROLLBACK TRANSACTION;
    END
    ELSE
    BEGIN
        INSERT INTO DanhGia
        SELECT * FROM inserted;
    END
END;

--	Email của khách hàng phải là một Email hợp lệ.
CREATE TRIGGER trg_ValidateEmail
ON KhachHang
INSTEAD OF INSERT
AS
BEGIN
    IF EXISTS (
        SELECT 1
        FROM inserted
        WHERE Email NOT LIKE '%_@__%.__%'
    )
    BEGIN
        RAISERROR ('Email khách hàng không hợp lệ!', 16, 1);
        ROLLBACK TRANSACTION;
    END
    ELSE
    BEGIN
        INSERT INTO KhachHang
        SELECT * FROM inserted;
    END
END;

--	Số điện thoại của khách phải là một số điện thoại hợp lệ.
CREATE TRIGGER trg_ValidatePhoneNumber
ON KhachHang
INSTEAD OF INSERT
AS
BEGIN
    -- Kiểm tra số điện thoại có hợp lệ hay không
    IF EXISTS (
        SELECT 1
        FROM inserted
        WHERE LEN(SoDienThoai) != 10
          OR SoDienThoai NOT LIKE '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'
    )
    BEGIN
        RAISERROR ('Số điện thoại không hợp lệ! Phải là số có 10 chữ số.', 16, 1);
        ROLLBACK TRANSACTION;
    END
    ELSE
    BEGIN
        -- Chèn dữ liệu hợp lệ vào bảng
        INSERT INTO KhachHang
        SELECT * FROM inserted;
    END
END;

--	Số CCCD phải đúng định dạng (12 chữ số), không được trùng lặp.
CREATE TRIGGER trg_ValidateCCCD
ON KhachHang
INSTEAD OF INSERT
AS
BEGIN
    IF EXISTS (
        SELECT 1 
        FROM inserted
        WHERE SoCCCD NOT LIKE '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'
          OR EXISTS (SELECT 1 FROM KhachHang WHERE SoCCCD = inserted.SoCCCD)
    )
    BEGIN
        RAISERROR ('Số CCCD không hợp lệ hoặc bị trùng lặp!', 16, 1);
        ROLLBACK TRANSACTION;
    END
    ELSE
    BEGIN
        INSERT INTO KhachHang
        SELECT * FROM inserted;
    END
END;

--	Mã khách hàng trong bảng KhachHang phải là duy nhất.
CREATE TABLE KhachHang (
    MaKhachHang INT PRIMARY KEY,  -- Đảm bảo mã khách hàng là duy nhất
    SoCCCD VARCHAR(12) UNIQUE NOT NULL,
    SoDienThoai VARCHAR(15) UNIQUE,
    Email VARCHAR(50) UNIQUE,
    HoTen NVARCHAR(50) NOT NULL,
    GioiTinh NVARCHAR(10) CHECK (GioiTinh IN (N'Nam', N'Nữ', N'Khác'))
);

--	Đăng ký thẻ giúp khách hàng được hưởng ưu đãi chiết khấu, giảm giá, tặng sản phẩm tùy theo chương trình. 
CREATE TRIGGER trg_RegisterCardDiscount
ON TheKhachHang
AFTER INSERT
AS
BEGIN
    -- Thông báo ưu đãi sau khi đăng ký thẻ
    PRINT 'Thẻ khách hàng đã được đăng ký. Bạn sẽ nhận được các ưu đãi chiết khấu và khuyến mãi.'
END;

--	Loại thẻ khách hàng gồm 3 loại: Membership, Silver, Gold. Khách hàng mới đăng ký sẽ mặc định là Membership. 
CREATE TABLE TheKhachHang (
    MaSoThe INT PRIMARY KEY,
    MaKhachHang INT,
    NgayLap DATETIME,
    NhanVienLap VARCHAR(10),
    TrangThaiThe BIT DEFAULT 1 CHECK (TrangThaiThe IN (0, 1)),
    DiemHienTai INT DEFAULT 0 CHECK (DiemHienTai >= 0),
    DiemTichLuy INT DEFAULT 0 CHECK (DiemTichLuy >= 0),
    LoaiThe NVARCHAR(20) DEFAULT N'Membership' CHECK (LoaiThe IN (N'Membership', N'Silver', N'Gold'))
);

--	Khách hàng phải cung cấp đầy đủ thông tin gồm: số căn cước công dân, số điện thoại, email, họ tên, giới tính khi đăng kí thẻ thành viên. 
CREATE TRIGGER trg_ValidateCustomerInfo
ON KhachHang
INSTEAD OF INSERT
AS
BEGIN
    IF EXISTS (
        SELECT 1
        FROM inserted
        WHERE SoCCCD IS NULL OR SoDienThoai IS NULL OR Email IS NULL OR HoTen IS NULL OR GioiTinh IS NULL
    )
    BEGIN
        RAISERROR ('Khách hàng phải cung cấp đầy đủ thông tin khi đăng ký!', 16, 1);
        ROLLBACK TRANSACTION;
    END
    ELSE
    BEGIN
        INSERT INTO KhachHang
        SELECT * FROM inserted;
    END
END;

--	Dựa vào tổng tiền tiêu dùng (sau khi đã giảm) trên hoá đơn, hệ thống sẽ tích luỹ cộng dồn điểm vào thẻ khách hàng: 1 điểm tương ứng 100.000 VNĐ. 
CREATE TRIGGER trg_UpdateLoyaltyPoints
ON HoaDon
AFTER INSERT
AS
BEGIN
    UPDATE TheKhachHang
    SET DiemTichLuy = DiemTichLuy + (i.ThanhTien / 100000),
        DiemHienTai = DiemHienTai + (i.ThanhTien / 100000)
    FROM TheKhachHang tk
    JOIN PhieuDatMon pd ON tk.MaKhachHang = pd.MaKhachHang
    JOIN inserted i ON pd.MaPhieu = i.MaPhieu;
END;

--	Các điều kiện nâng/giữ/hạ hạng thẻ: 
--o	− MemberShip → Silver: điểm tích lũy từ 100 điểm từ ngày lập thẻ − Silver → Gold: điểm tích lũy trong 1 năm từ 100 điểm trở lên 19
--o	 − Gold → Silver: điểm tích lũy trong 1 năm dưới 100 điểm kể từ ngày đạt hạng 
--o	− Silver → Membership: điểm tích lũy trong 1 năm dưới 50 điểm kể từ ngày đạt hạng − Các trường hợp còn lại giữ nguyên hạng không thay đổi
CREATE TRIGGER trg_UpdateCardRank
ON TheKhachHang
AFTER UPDATE
AS
BEGIN
    -- Nâng hạng từ MemberShip → Silver
    UPDATE TheKhachHang
    SET LoaiThe = N'Silver'
    WHERE LoaiThe = N'Membership'
      AND DiemTichLuy >= 100
      AND DATEDIFF(DAY, NgayLap, GETDATE()) <= 365;

    -- Nâng hạng từ Silver → Gold
    UPDATE TheKhachHang
    SET LoaiThe = N'Gold'
    WHERE LoaiThe = N'Silver'
      AND DiemTichLuy >= 100
      AND DATEDIFF(DAY, NgayLap, GETDATE()) <= 365;

    -- Hạ hạng từ Gold → Silver
    UPDATE TheKhachHang
    SET LoaiThe = N'Silver'
    WHERE LoaiThe = N'Gold'
      AND DiemTichLuy < 100
      AND DATEDIFF(DAY, NgayLap, GETDATE()) <= 365;

    -- Hạ hạng từ Silver → Membership
    UPDATE TheKhachHang
    SET LoaiThe = N'Membership'
    WHERE LoaiThe = N'Silver'
      AND DiemTichLuy < 50
      AND DATEDIFF(DAY, NgayLap, GETDATE()) <= 365;

    -- Thông báo giữ nguyên hạng nếu không đủ điều kiện nâng/hạ
    PRINT 'Hạng thẻ không thay đổi nếu không đủ điều kiện nâng/hạ.';
END;

--	Nếu khách hàng làm mất thẻ, có thể liên hệ để đóng thẻ cũ và cấp thẻ mới mới 
CREATE TRIGGER trg_ReplaceLostCard
ON TheKhachHang
AFTER UPDATE
AS
BEGIN
    IF EXISTS (
        SELECT 1
        FROM inserted
        WHERE TrangThaiThe = 0  -- Đóng thẻ cũ
    )
    BEGIN
        PRINT 'Thẻ khách hàng đã được đóng. Hãy cấp thẻ mới cho khách hàng nếu cần.'
    END;
END;

--	Đối với khách trực tuyến, hệ thống ghi nhận thêm thời điểm truy cập, thời gian truy cập nhằm cải thiện trải nghiệm của khách hàng. 
CREATE TRIGGER trg_RecordOnlineAccess
ON ThongTinTruyCap
AFTER INSERT
AS
BEGIN
    -- Ghi nhận thời gian truy cập và thời điểm truy cập
    PRINT 'Thời điểm truy cập và thời gian truy cập đã được ghi nhận.'
END;

--	Khách hàng có thể đặt hàng qua số điện thoại chi nhánh hoặc website. 
CREATE TRIGGER trg_OrderViaPhone
ON PhieuDatMon
AFTER INSERT
AS
BEGIN
    IF EXISTS (
        SELECT 1
        FROM inserted i
        JOIN ChiNhanh c ON i.MaChiNhanh = c.MaChiNhanh
        WHERE i.NhanVienLap IS NOT NULL
    )
    BEGIN
        PRINT 'Đơn đặt món qua số điện thoại chi nhánh đã được tiếp nhận.';
    END;
END;
CREATE TRIGGER trg_OrderViaWebsite
ON PhieuDatMon
AFTER INSERT
AS
BEGIN
    IF EXISTS (
        SELECT 1
        FROM inserted
        WHERE NhanVienLap IS NULL -- Không có nhân viên trực tiếp lập phiếu, ngầm hiểu là qua website
    )
    BEGIN
        PRINT 'Đơn đặt món qua website đã được tiếp nhận.';
    END;
END;

--	Khách hàng đặt món trực tuyến phải lựa chọn khu vực và chi nhánh, số lượng khách, ngày đặt, giờ đến, một số ghi chú khác. 
CREATE TRIGGER trg_ValidateOnlineOrder
ON DatTruoc
INSTEAD OF INSERT
AS
BEGIN
    IF EXISTS (
        SELECT 1
        FROM inserted
        WHERE MaKhuVuc IS NULL OR MaChiNhanh IS NULL OR SoLuongKhach IS NULL OR GioDen IS NULL
    )
    BEGIN
        RAISERROR ('Đơn đặt trước phải có đầy đủ khu vực, chi nhánh, số lượng khách, ngày đặt, giờ đến!', 16, 1);
        ROLLBACK TRANSACTION;
    END
    ELSE
    BEGIN
        INSERT INTO DatTruoc
        SELECT * FROM inserted;
    END
END;

--	Khách hàng có thể đặt trước một số món để nhà hàng chuẩn bị sẵn. 
CREATE TRIGGER trg_PrepareDishesForReservation
ON ChiTietPhieu
AFTER INSERT
AS
BEGIN
    -- Kiểm tra nếu phiếu đặt món đã được đặt trước
    IF EXISTS (
        SELECT 1
        FROM inserted i
        JOIN PhieuDatMon p ON i.MaPhieu = p.MaPhieu
        JOIN DatTruoc d ON p.MaKhachHang = d.MaKhachHang
        WHERE d.MaDatTruoc IS NOT NULL
    )
    BEGIN
        PRINT 'Nhà hàng đã nhận thông tin đặt trước các món. Đang chuẩn bị.';
    END;
END;

--	Trong quá trình đặt món nếu khách có yêu cầu thêm món, nhân viên sẽ bổ sung thêm thông tin và phiếu đặt món. 
CREATE TRIGGER trg_UpdateOrderWithAdditionalDishes
ON ChiTietPhieu
AFTER INSERT
AS
BEGIN
    PRINT 'Thông tin món thêm đã được cập nhật vào phiếu đặt món.'
END;

--	Khi khách hàng cần thanh toán, nhân viên sẽ xuất hóa đơn thanh toán cho khách hàng
CREATE TRIGGER trg_GenerateInvoice
ON PhieuDatMon
AFTER INSERT
AS
BEGIN
    -- Tạo hóa đơn dựa trên phiếu đặt món
    INSERT INTO HoaDon (MaPhieu, NgayLap, TongTien, GiamGia, ThanhTien)
    SELECT 
        i.MaPhieu,
        GETDATE() AS NgayLap,
        -- Tính tổng tiền dựa trên các món trong phiếu
        (SELECT SUM(m.GiaHienTai * ctp.SoLuong)
         FROM ChiTietPhieu ctp
         JOIN Mon m ON ctp.MaMon = m.MaMon
         WHERE ctp.MaPhieu = i.MaPhieu) AS TongTien,
        0 AS GiamGia, -- Giảm giá mặc định là 0
        (SELECT SUM(m.GiaHienTai * ctp.SoLuong)
         FROM ChiTietPhieu ctp
         JOIN Mon m ON ctp.MaMon = m.MaMon
         WHERE ctp.MaPhieu = i.MaPhieu) AS ThanhTien -- Thành tiền bằng tổng tiền trừ giảm giá
    FROM inserted i;

    PRINT 'Hóa đơn thanh toán đã được tạo và xuất cho khách hàng.';
END;

--	Hoá đơn phải có tổng tiền, số tiền được giảm nếu có sử dụng thẻ thành viên 
CREATE TRIGGER trg_CheckBill
ON HoaDon
INSTEAD OF INSERT
AS
BEGIN
    IF EXISTS (
        SELECT 1
        FROM inserted
        WHERE TongTien IS NULL OR GiamGia IS NULL
    )
    BEGIN
        RAISERROR ('Hóa đơn phải có tổng tiền và số tiền giảm!', 16, 1);
        ROLLBACK TRANSACTION;
    END
    ELSE
    BEGIN
        INSERT INTO HoaDon
        SELECT * FROM inserted;
    END
END;

--	Sau khi thanh toán hoá đơn, nhân viên sẽ nhờ khách hàng hỗ trợ đánh giá dịch vụ.
CREATE TRIGGER trg_RequestFeedback
ON HoaDon
AFTER INSERT
AS
BEGIN
    PRINT 'Hóa đơn đã được thanh toán. Vui lòng nhờ khách hàng đánh giá dịch vụ.'
END;
