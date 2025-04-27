USE QLNHAHANG
GO


--TRIGGER Phân hệ Chi Nhánh


-- Thêm bộ phận và tự động tạo mã bộ phận khi không được cung cấp
CREATE TRIGGER THEMBP
ON BoPhan
AFTER INSERT
AS
BEGIN
    DECLARE @InsertedMaBoPhan CHAR(4);
    DECLARE @GeneratedMaBoPhan CHAR(4);
    DECLARE @InsertedTenBoPhan NVARCHAR(50);

    -- Lấy mã bộ phận và tên bộ phận từ bảng INSERTED
    SELECT TOP 1 @InsertedMaBoPhan = MaBoPhan, @InsertedTenBoPhan = TenBoPhan
    FROM INSERTED;

    -- Kiểm tra nếu mã bộ phận là 'BP99'
    IF @InsertedMaBoPhan = 'BP99'
    BEGIN
        -- Tìm mã lớn nhất trong bảng, bỏ qua BP99
        SET @GeneratedMaBoPhan = 
        (
            SELECT 'BP' + RIGHT('00' + CAST(MAX(CAST(SUBSTRING(MaBoPhan, 3, LEN(MaBoPhan) - 2) AS INT)) + 1 AS VARCHAR), 2)
            FROM BoPhan
            WHERE MaBoPhan LIKE 'BP[0-9][0-9]' AND MaBoPhan <> 'BP99'
        );

        -- Cập nhật dòng vừa chèn với mã bộ phận mới
        UPDATE BoPhan
        SET MaBoPhan = @GeneratedMaBoPhan
        WHERE MaBoPhan = 'BP99' AND TenBoPhan = @InsertedTenBoPhan;
    END;
END;
GO



--Nhân viên quản lý phải làm việc tại chi nhánh

CREATE TRIGGER trg_ManagerMustWorkAtBranch
ON ChiNhanh
AFTER INSERT, UPDATE
AS
BEGIN
    -- Kiểm tra xem nhân viên quản lý có làm việc tại chi nhánh hay không
    IF EXISTS (
        SELECT 1
        FROM inserted c
        WHERE c.NhanVienQuanLy IS NOT NULL -- Chỉ kiểm tra khi NhanVienQuanLy không phải NULL
          AND NOT EXISTS (
              SELECT *
              FROM LichSuLamViec l
              WHERE l.MaNhanVien = 'NV0499'
                AND l.MaChiNhanh = 2
				AND l.NgayKetThuc is Null
          )
    )
    BEGIN
        RAISERROR (N'Nhân viên quản lý phải làm việc tại chi nhánh mà họ quản lý!', 16, 1);
        ROLLBACK TRANSACTION;
    END
END;
GO


--BANG THE KHACH HANG
--	Tại 1 thời điểm, mỗi khách hàng chỉ có thể sở hữu 1 thẻ khách hàng đang hoạt động.
CREATE TRIGGER trg_CheckActiveCard
ON TheKhachHang
INSTEAD OF INSERT
AS
BEGIN
    IF EXISTS (
        SELECT 1 
        FROM TheKhachHang
        WHERE SoDienThoai = (SELECT SoDienThoai FROM inserted)
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
GO

-- trigger thực hiện khi cập nhật điểm 
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
	IF EXISTS (
        SELECT 1
        FROM TheKhachHang
        WHERE LoaiThe = N'Membership'
          AND DiemTichLuy >= 100
		  AND TrangThaiThe = 1
    )
	BEGIN 
		UPDATE TheKhachHang
		SET LoaiThe = N'Silver', 
			DiemHienTai = DiemTichLuy + DiemHienTai, 
			DiemTichLuy = 0,
			NgayDatThe = GETDATE()
		WHERE LoaiThe = N'Membership'
		  AND DiemTichLuy >= 100;
		RETURN;
	END;

    -- Nâng hạng từ Silver → Gold
	IF EXISTS (
        SELECT 1
        FROM TheKhachHang
        WHERE LoaiThe = N'Silver'
          AND DiemTichLuy >= 100
          AND DATEDIFF(YEAR, NgayDatThe, GETDATE()) >= 1
		  AND TrangThaiThe = 1
    )
    BEGIN
		UPDATE TheKhachHang
		SET LoaiThe = N'Gold',
			DiemHienTai = DiemTichLuy + DiemHienTai, 
			DiemTichLuy = 0,
			NgayDatThe = GETDATE()
		WHERE LoaiThe = N'Silver'
		  AND DiemTichLuy >= 100
		  AND DATEDIFF(YEAR, NgayLap, GETDATE()) <= 1;
	END;

	-- Hạ hạng từ Gold → Silver
	IF EXISTS (
        SELECT 1
        FROM TheKhachHang
        WHERE LoaiThe = N'Gold'
          AND DiemTichLuy < 100
          AND DATEDIFF(YEAR, NgayDatThe, GETDATE()) >= 1
		  AND TrangThaiThe = 1
    )
	BEGIN
		UPDATE TheKhachHang
		SET LoaiThe = N'Silver',
			DiemHienTai = DiemTichLuy + DiemHienTai, 
			DiemTichLuy = 0,
			NgayDatThe = GETDATE()
		WHERE LoaiThe = N'Gold'
		  AND DiemTichLuy < 100
		  AND DATEDIFF(DAY, NgayLap, GETDATE()) >= 1;
	END
    -- Hạ hạng từ Silver → Membership
	IF EXISTS (
        SELECT 1
        FROM TheKhachHang
        WHERE LoaiThe = N'Silver'
          AND DiemTichLuy < 50
          AND DATEDIFF(YEAR, NgayDatThe, GETDATE()) >= 1
		  AND TrangThaiThe = 1
    )
	BEGIN
		UPDATE TheKhachHang
		SET LoaiThe = N'Membership'
		WHERE LoaiThe = N'Silver'
		  AND DiemTichLuy < 50
		  AND DATEDIFF(DAY, NgayLap, GETDATE()) >= 1;

	 END

    -- Thông báo giữ nguyên hạng nếu không đủ điều kiện nâng/hạ
    PRINT 'Hạng thẻ không thay đổi nếu không đủ điều kiện nâng/hạ.';
END;
GO


--BANG KHACH HANG
-- Email của khách hàng phải hợp lệ.
CREATE TRIGGER trg_ValidateEmail
ON KhachHang
INSTEAD OF INSERT
AS
BEGIN
    -- Kiểm tra email không hợp lệ trong bảng inserted
    IF EXISTS (
        SELECT 1
        FROM inserted
        WHERE Email NOT LIKE '%_@__%.__%'
    )
    BEGIN
        RAISERROR (N'Email khách hàng không hợp lệ!', 16, 1);
        RETURN;
    END;

    -- Chèn dữ liệu hợp lệ vào bảng KhachHang
    INSERT INTO KhachHang (SoCCCD, SoDienThoai, Email, HoTen)
    SELECT SoCCCD, SoDienThoai, Email, HoTen
    FROM inserted;
END;
GO

--BANG PHIEUDATMON

CREATE TRIGGER trg_ValidateHoaDon
ON HoaDon
AFTER INSERT
AS
BEGIN
    UPDATE h
    SET h.ThanhTien = i.TongTien * (1 - i.GiamGia / 100.0)
    FROM HoaDon h
    JOIN inserted i ON h.MaPhieu= i.MaPhieu;

END;
GO


CREATE TRIGGER trg_CapNhatDiemHienTai
ON HoaDon
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON; -- Tắt thông báo về số hàng bị ảnh hưởng

    -- Cập nhật DiemHienTai của khách hàng dựa trên các hóa đơn
    UPDATE TheKhachHang
    SET 
        DiemHienTai = (
            SELECT ISNULL(SUM(h.TongTien / 100000), 0)
            FROM HoaDon h
            JOIN PhieuDatMon p ON h.MaPhieu = p.MaPhieu
			JOIN KhachHang kh ON kh.SoDienThoai = p.SODIENTHOAI
            WHERE kh.SoDienThoai = TheKhachHang.SoDienThoai
              AND h.NgayLap >= TheKhachHang.NgayLap
			  AND TheKhachHang.TrangThaiThe = 1
        )
    WHERE EXISTS (
        SELECT 1
        FROM inserted i
        JOIN PhieuDatMon p ON i.MaPhieu = p.MaPhieu
		JOIN KhachHang kh ON kh.SoDienThoai = p.SODIENTHOAI
        WHERE kh.MaKhachHang = TheKhachHang.SoDienThoai AND TheKhachHang.TrangThaiThe = 1
    )
    OR EXISTS (
        SELECT 1
        FROM deleted d
        JOIN PhieuDatMon p ON d.MaPhieu = p.MaPhieu
		JOIN KhachHang kh ON kh.SoDienThoai = p.SODIENTHOAI
        WHERE kh.MaKhachHang = TheKhachHang.SoDienThoai AND TheKhachHang.TrangThaiThe = 1
    );
END;
GO



CREATE TRIGGER trg_UpdateEmployeeScore
ON DanhGia
AFTER INSERT
AS
BEGIN
	DECLARE @MAPHIEU BIGINT;
	DECLARE @SOLUONG BIGINT;

	SET @MAPHIEU = (SELECT i.MaPhieu
	FROM inserted i)

	SET @SOLUONG = (SELECT COUNT(*)
	FROM DanhGia dg JOIN PhieuDatMon p ON dg.MaPhieu = p.MaPhieu
	WHERE p.NhanVienLap = (SELECT NhanVienLap FROM PhieuDatMon WHERE MaPhieu = @MAPHIEU))
	IF @SOLUONG = 0
	begin
		set @SOLUONG += 1;
	end
    UPDATE NhanVien
    SET DiemSo = ((DiemSo * (@SOLUONG - 1)) +
	(SELECT i.DiemPhucVu
	FROM inserted i 
	)) / @SOLUONG
END;
GO


--	Bàn được chọn phải có sức chứa lớn hơn số lượng khách của đơn đặt trước.
CREATE TRIGGER trg_CheckTableCapacity
ON DatTruoc
INSTEAD OF INSERT
AS
BEGIN
    IF EXISTS (
        SELECT 1
        FROM inserted i
		JOIN PhieuDatMon p ON i.MaPhieu = p.MaPhieu
        JOIN Ban b ON p.MaSoBan = b.MaSoBan AND p.MaChiNhanh = b.MaChiNhanh
        WHERE b.SucChua < i.SoLuongKhach
    )
    BEGIN
        RAISERROR ('Bàn được chọn phải có sức chứa lớn hơn số lượng khách!', 16, 1);
        ROLLBACK TRANSACTION;
    END
    ELSE
    BEGIN
        INSERT INTO DatTruoc
        SELECT SoLuongKhach, NgayDat, GioDen ,GhiChu, ChiNhanh, SoDienThoai, MaPhieu 
		FROM inserted;
    END
END;
GO
-- BANG THONG TIN TRUY CAP

-- trigger thêm khách hàng, phân quyền cho khách hàng được thêm
CREATE TRIGGER trg_InsertUserOnCustomerAdd
ON KhachHang
AFTER INSERT
AS
BEGIN 
    SET NOCOUNT ON;

    -- Thêm thông tin username(sđt) cùng mật khẩu SushiX_{phone_number} vào bảng user với role khách hàng
    INSERT INTO Users(username, password, role)
    SELECT SoDienThoai, 'SushiX_' + SoDienThoai, 'khachhang'
    FROM INSERTED
END
GO
INSERT INTO KhachHang (SoCCCD, SoDienThoai, Email, HoTen, GioiTinh) VALUES ('123456000001', '0982712434', 'pham.thi.phuc@hotmail.com', 'Pham Thi Phuc', 'Nam');
delete from Users
use QLNHAHANG
go
select * from phieudatmon
SELECT * FROM PhieuDatMon where ngaylap > '2024-09-01' and  ngaylap < '2024-09-30'
select * from Users