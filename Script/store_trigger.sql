--Phân hệ Chi Nhánh
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
	DECLARE @SDT CHAR(10)

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
	DECLARE @GIA INT

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


