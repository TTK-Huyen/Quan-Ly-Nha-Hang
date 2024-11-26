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
