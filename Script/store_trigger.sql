USE QLNHAHANG
GO


--TRIGGER Phân hệ Chi Nhánh

-- Đã cài constraint tgiandong < tgianmo
/*
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
*/





-- Đã cài ràng buộc khóa ngoại ChiNhanh(MaKhuVuc) -> KhuVuc(MaKhuVuc)
/*
GO
CREATE TRIGGER CHECK_IU_CHINHANH
ON CHINHANH
AFTER INSERT, UPDATE
AS
BEGIN
	DECLARE @MAKV TINYINT
	
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
*/

-- Đã cài ràng buộc khóa ngoại
/*
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
*/ 



-- Đã cài ràng buộc khóa ngoại Mon(MaMuc) -> ThucDon(MaMuc)
/*
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
*/

/* -- ĐÃ CÀI FK MAMUC -> MUCTHUCDON
GO
CREATE TRIGGER CHECK_XOA_MUCTHUCDON
ON MucThucDon
AFTER DELETE
AS
BEGIN
	DECLARE @MAMUC TINYINT

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
*/

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

-- Đã cài trong SP
/*
-- Đóng thẻ phải làm SP chứ nhỉ
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
GO
*/

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

--	Mã phiếu trong phiếu đặt món phải là duy nhất để phân biệt với các mã phiếu khác. Mã bàn trong mỗi chi nhánh phải là duy nhất và tuân theo quy tắc sau: 
--o	o Đối với khách sử dụng dịch vụ trực tiếp tại bàn, mã số bàn sẽ là số thứ tự của các bàn trong chi nhánh (ví dụ: 1, 2, 3, …).
--o	 o Đối với khách mang về hoặc không sử dụng bàn tại quán, mã số bàn sẽ mang mã đặc biệt là MV (Mang Về).

-- Đã cài primary key
/* CREATE TRIGGER trg_UniqueOrderID
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
GO
*/

/*Đã cài primary key
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
GO
*/

-- Mã số bàn trong phiếu đặt món là NULL thì là đơn đem về
/*
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
GO
*/

--	Khách hàng có thể đặt hàng qua số điện thoại chi nhánh hoặc website. -- Cái này tui nghĩ không phải ràng buộc dữ liệu
/*
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
GO

*/

/*

CREATE TRIGGER trg_OrderViaWebsite -- cái này chắc là nghiệp vụ nha
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
GO

*/
--	Khi khách hàng cần thanh toán, nhân viên sẽ xuất hóa đơn thanh toán cho khách hàng -- Cái này không hợp lý lắm, vì trigger sẽ chạy ngay sau khi insert PhieuDatMon, nên đổi thành SP
/*
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

    PRINT N'Hóa đơn thanh toán đã được tạo và xuất cho khách hàng.';
END;
GO
*/


-- BANG HOA DON
--Thanh Tien = TongTien- GiamGia

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

/*
-- Kiểm tra thời gian xuất hóa đơn phải sau thời gian lập phiếu.
CREATE TRIGGER trg_ValidateInvoiceTime
ON HoaDon
AFTER INSERT
AS
BEGIN
    IF EXISTS (
        SELECT 1
        FROM inserted h
        JOIN PhieuDatMon p ON h.MaPhieu = p.MaPhieu
        WHERE h.NgayLap <= p.NgayLap
    )
    BEGIN
        RAISERROR ('Thời gian xuất hóa đơn phải sau thời gian lập phiếu.', 16, 1);
        ROLLBACK TRANSACTION;
    END
END;
GO

CREATE TRIGGER trg_UpdateLoyaltyPoints
ON HoaDon
AFTER INSERT
AS
BEGIN
    -- Cập nhật điểm tích lũy dựa trên `ThanhTien`
    UPDATE tk
    SET 
        tk.DiemTichLuy = tk.DiemTichLuy + (i.ThanhTien / 100000 ),
        tk.DiemHienTai = tk.DiemHienTai + (i.ThanhTien / 100000 )
    FROM TheKhachHang tk
    JOIN PhieuDatMon pd ON tk.MaKhachHang = pd.MaKhachHang
    JOIN inserted i ON pd.MaPhieu = i.MaPhieu;
END;
GO
*/
-- Công thức điểm khách hàng
-- Điểm hiện tại : tổng hóa đơn từ khi lập thẻ đến bây giờ/100000 
-- Điểm tích lũy : tổng hóa đơn từ ngày lập thẻ năm hiện tại đến bây giờ/100000
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
            WHERE kh.MaKhachHang = TheKhachHang.MaKhachHang
              AND h.NgayLap >= TheKhachHang.NgayLap
			  AND TheKhachHang.TrangThaiThe = 1
        )
    WHERE EXISTS (
        SELECT 1
        FROM inserted i
        JOIN PhieuDatMon p ON i.MaPhieu = p.MaPhieu
		JOIN KhachHang kh ON kh.SoDienThoai = p.SODIENTHOAI
        WHERE kh.MaKhachHang = TheKhachHang.MaKhachHang AND TheKhachHang.TrangThaiThe = 1
    )
    OR EXISTS (
        SELECT 1
        FROM deleted d
        JOIN PhieuDatMon p ON d.MaPhieu = p.MaPhieu
		JOIN KhachHang kh ON kh.SoDienThoai = p.SODIENTHOAI
        WHERE kh.MaKhachHang = TheKhachHang.MaKhachHang AND TheKhachHang.TrangThaiThe = 1
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







--BANG DAT CHO
-- Thời gian nhận bàn phải trễ hơn thời gian đặt trước. , đã cài constraint
/*
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
        RAISERROR ('Thời gian nhận bàn phải trễ hơn thời gian đặt trước!', 16, 1);
        ROLLBACK TRANSACTION;
    END
    ELSE
    BEGIN
        INSERT INTO DatCho
        SELECT * FROM inserted;
    END
END;
GO
*/
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
-- Thời gian truy cập phải nhỏ hơn giờ đến trong đặt trước. -- khách đặt món hay không thì vẫn lưu
/*
CREATE TRIGGER trg_ValidateAccessTime
ON ThongTinTruyCap
AFTER INSERT
AS
BEGIN
    -- Kiểm tra thời gian truy cập phải trước giờ đến đặt trước
    IF EXISTS (
        SELECT 1
        FROM inserted i
        JOIN DatTruoc dt ON i.MaDatTruoc = dt.MaDatTruoc
        WHERE i.ThoiDiemTruyCap >= dt.GioDen
    )
    BEGIN
        RAISERROR (N'Thời gian truy cập phải trước giờ đến.', 16, 1);
        ROLLBACK TRANSACTION;
    END;
END;
GO
*/
--	Đối với khách trực tuyến, hệ thống ghi nhận thêm thời điểm truy cập, thời gian truy cập nhằm cải thiện trải nghiệm của khách hàng.  -- Trigger này không có ý nghĩa ràng buộc dữ liệu
/*
CREATE TRIGGER trg_RecordOnlineAccess
ON ThongTinTruyCap
AFTER INSERT
AS
BEGIN
    -- Ghi nhận thời gian truy cập và thời điểm truy cập
    PRINT 'Thời điểm truy cập và thời gian truy cập đã được ghi nhận.'
END;
GO
*/
-- bang CHITIETPHIEU

--	Khách hàng có thể đặt trước một số món để nhà hàng chuẩn bị sẵn. -- này là chức năng không liên quan đến ràng buộc dữ liệu
/*
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
GO
*/


--	Trong quá trình đặt món nếu khách có yêu cầu thêm món, nhân viên sẽ bổ sung thêm thông tin và phiếu đặt món. này là chức năng không liên quan đến ràng buộc dữ liệu
/*
CREATE TRIGGER trg_UpdateOrderWithAdditionalDishes
ON ChiTietPhieu
AFTER INSERT
AS
BEGIN
    PRINT 'Thông tin món thêm đã được cập nhật vào phiếu đặt món.'
END;
GO
*/
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
