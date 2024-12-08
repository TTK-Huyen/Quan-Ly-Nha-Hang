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





--TRIGGER PHÂN HỆ NHÂN VIÊN

--NHÂN VIÊN CHỈ ĐƯỢC LÀM VIỆC TẠI 1 CHI NHÁNH TẠI 1 THỜI ĐIỂM
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
              SELECT 1
              FROM LichSuLamViec l
              WHERE l.MaNhanVien = c.NhanVienQuanLy
                AND l.MaChiNhanh = c.MaChiNhanh
          )
    )
    BEGIN
        RAISERROR ('Nhân viên quản lý phải làm việc tại chi nhánh mà họ quản lý!', 16, 1);
        ROLLBACK TRANSACTION;
    END
END;


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

--	Đăng ký thẻ giúp khách hàng được hưởng ưu đãi chiết khấu, giảm giá, tặng sản phẩm tùy theo chương trình. 
CREATE TRIGGER trg_RegisterCardDiscount
ON TheKhachHang
AFTER INSERT
AS
BEGIN
    -- Thông báo ưu đãi sau khi đăng ký thẻ
    PRINT 'Thẻ khách hàng đã được đăng ký. Bạn sẽ nhận được các ưu đãi chiết khấu và khuyến mãi.'
END;
GO

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
GO

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


--BANG KHACH HANG
-- Email của khách hàng phải hợp lệ.
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
GO

-- Số điện thoại của khách phải là số có 10 chữ số.
CREATE TRIGGER trg_ValidatePhoneNumber
ON KhachHang
INSTEAD OF INSERT
AS
BEGIN
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
        INSERT INTO KhachHang
        SELECT * FROM inserted;
    END
END;
GO

-- Số CCCD phải đúng định dạng (12 chữ số), không trùng lặp.
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
GO
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
GO
--BANG PHIEUDATMON

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
GO
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
GO

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
GO
	
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
GO
-- Phiếu đặt món phải có đầy đủ thông tin.
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
        RAISERROR ('Phiếu đặt món phải có đủ thông tin.', 16, 1);
        ROLLBACK TRANSACTION;
    END
    ELSE
    BEGIN
        INSERT INTO PhieuDatMon
        SELECT * FROM inserted;
    END
END;
GO

-- Mã phiếu phải là duy nhất.
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
        RAISERROR ('Mã phiếu phải là duy nhất!', 16, 1);
        ROLLBACK TRANSACTION;
    END
    ELSE
    BEGIN
        INSERT INTO PhieuDatMon
        SELECT * FROM inserted;
    END
END;
GO
-- BANG HOA DON
--Thanh Tien = TongTien- GiamGia
CREATE TRIGGER trg_ValidateHoaDon
ON HoaDon
INSTEAD OF INSERT
AS
BEGIN
    -- Kiểm tra tính hợp lệ của `TongTien` và `GiamGia`
    IF EXISTS (
        SELECT 1 
        FROM inserted
        WHERE TongTien <= 0 -- Tổng tiền phải lớn hơn 0
          OR GiamGia < 0 -- Giảm giá không được âm
          OR TongTien < GiamGia -- Tổng tiền phải lớn hơn hoặc bằng giảm giá
    )
    BEGIN
        RAISERROR (N'Dữ liệu không hợp lệ: Tổng tiền phải lớn hơn 0 và giảm giá không được vượt quá tổng tiền!', 16, 1);
        ROLLBACK TRANSACTION;
    END
    ELSE
    BEGIN
        -- Tính toán `ThanhTien` dựa trên `TongTien` và `GiamGia`
        INSERT INTO HoaDon (MaPhieu, NgayLap, TongTien, GiamGia, ThanhTien)
        SELECT 
            MaPhieu, 
            NgayLap, 
            TongTien, 
            GiamGia, 
            (TongTien - GiamGia) AS ThanhTien
        FROM inserted;
    END
END;
GO

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
        tk.DiemTichLuy = tk.DiemTichLuy + CAST(i.ThanhTien / 100000 AS INT),
        tk.DiemHienTai = tk.DiemHienTai + CAST(i.ThanhTien / 100000 AS INT)
    FROM TheKhachHang tk
    JOIN PhieuDatMon pd ON tk.MaKhachHang = pd.MaKhachHang
    JOIN inserted i ON pd.MaPhieu = i.MaPhieu;
END;
GO


-- Sau khi thanh toán hóa đơn, nhờ khách hàng đánh giá.
CREATE TRIGGER trg_RequestFeedback
ON HoaDon
AFTER INSERT
AS
BEGIN
    PRINT 'Hóa đơn đã được thanh toán. Vui lòng nhờ khách hàng đánh giá dịch vụ.';
END;

--	Số tiền giảm giá trong hóa đơn phải thấp hơn tổng tiền. 
CREATE TRIGGER trg_ValidateHoaDon
ON HoaDon
INSTEAD OF INSERT
AS
BEGIN
    IF EXISTS (
        SELECT 1 
        FROM inserted
        WHERE GiamGia < 0 -- Không cho phép giảm giá âm
          OR TongTien < GiamGia -- Tổng tiền phải lớn hơn hoặc bằng số tiền giảm giá
          OR ThanhTien != (TongTien - GiamGia) -- Thành tiền phải chính xác
    )
    BEGIN
        RAISERROR (N'Tổng tiền phải lớn hơn giảm giá và thành tiền phải bằng tổng tiền trừ giảm giá!', 16, 1);
        ROLLBACK TRANSACTION;
    END
    ELSE
    BEGIN
        INSERT INTO HoaDon
        SELECT * FROM inserted;
    END
END;
GO

--	Dựa vào tổng tiền tiêu dùng (sau khi đã giảm) trên hoá đơn, hệ thống sẽ tích luỹ cộng dồn điểm vào thẻ khách hàng: 1 điểm tương ứng 100.000 VNĐ. 
CREATE TRIGGER trg_UpdateLoyaltyPoints
ON HoaDon
AFTER INSERT
AS
BEGIN
    UPDATE TheKhachHang
    SET 
        DiemTichLuy = DiemTichLuy + CAST(i.ThanhTien / 100000 AS INT),
        DiemHienTai = DiemHienTai + CAST(i.ThanhTien / 100000 AS INT)
    FROM TheKhachHang tk
    JOIN PhieuDatMon pd ON tk.MaKhachHang = pd.MaKhachHang
    JOIN inserted i ON pd.MaPhieu = i.MaPhieu;
END;
GO

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
GO
-- nhac danh gia
CREATE TRIGGER trg_RequestFeedback
ON HoaDon
AFTER INSERT
AS
BEGIN
    PRINT N'Hóa đơn đã được thanh toán. Vui lòng nhờ khách hàng đánh giá dịch vụ.';
END;
GO

-- BANG DANH GIA
-- Cập nhật điểm của nhân viên khi thêm đánh giá.
CREATE TRIGGER trg_UpdateEmployeeScore
ON DanhGia
AFTER INSERT
AS
BEGIN
    UPDATE NhanVien
    SET DiemSo = DiemSo + (
        SELECT 
            ISNULL(DiemPhucVu, 0) + ISNULL(DiemViTri, 0) + ISNULL(DiemChatLuong, 0) + ISNULL(DiemKhongGian, 0)
        FROM inserted dg
        JOIN PhieuDatMon pd ON dg.MaPhieu = pd.MaPhieu
        WHERE NhanVien.MaNhanVien = pd.NhanVienLap
    )
    WHERE EXISTS (
        SELECT 1
        FROM inserted dg
        JOIN PhieuDatMon pd ON dg.MaPhieu = pd.MaPhieu
        WHERE NhanVien.MaNhanVien = pd.NhanVienLap
    );
END;
GO
-- khi thêm một đánh giá vào bảng đánh giá thì sẽ cập nhật điểm của nhân viên lập phiếu
CREATE TRIGGER trg_UpdateEmployeeScore
ON DanhGia
AFTER INSERT
AS
BEGIN
    -- Cập nhật điểm số cho nhân viên dựa trên đánh giá mới
    UPDATE NhanVien
    SET DiemSo = DiemSo + (
        SELECT 
            ISNULL(DiemPhucVu, 0) + ISNULL(DiemViTri, 0) + ISNULL(DiemChatLuong, 0) + ISNULL(DiemKhongGian, 0)
        FROM inserted dg
        JOIN PhieuDatMon pd ON dg.MaPhieu = pd.MaPhieu
        WHERE NhanVien.MaNhanVien = pd.NhanVienLap
    )
    WHERE EXISTS (
        SELECT 1
        FROM inserted dg
        JOIN PhieuDatMon pd ON dg.MaPhieu = pd.MaPhieu
        WHERE NhanVien.MaNhanVien = pd.NhanVienLap
    );

    PRINT 'Điểm số của nhân viên lập phiếu đã được cập nhật dựa trên đánh giá.';
END;
GO
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
GO
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
GO
--BANG DAT CHO
-- Thời gian nhận bàn phải trễ hơn thời gian đặt trước.
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
GO
-- BANG THONG TIN TRUY CAP
-- Thời gian truy cập phải nhỏ hơn giờ đến trong đặt trước.
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

--	Đối với khách trực tuyến, hệ thống ghi nhận thêm thời điểm truy cập, thời gian truy cập nhằm cải thiện trải nghiệm của khách hàng. 
CREATE TRIGGER trg_RecordOnlineAccess
ON ThongTinTruyCap
AFTER INSERT
AS
BEGIN
    -- Ghi nhận thời gian truy cập và thời điểm truy cập
    PRINT 'Thời điểm truy cập và thời gian truy cập đã được ghi nhận.'
END;
GO
-- bang CHITIETPHIEU

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
GO
--	Trong quá trình đặt món nếu khách có yêu cầu thêm món, nhân viên sẽ bổ sung thêm thông tin và phiếu đặt món. 
CREATE TRIGGER trg_UpdateOrderWithAdditionalDishes
ON ChiTietPhieu
AFTER INSERT
AS
BEGIN
    PRINT 'Thông tin món thêm đã được cập nhật vào phiếu đặt món.'
END;
GO
--BANG DAT TRUOC
--	Khách hàng đặt món trực tuyến phải lựa chọn khu vực và chi nhánh, số lượng khách, ngày đặt, giờ đến, một số ghi chú khác. 
CREATE TRIGGER trg_ValidateOnlineOrder
ON DatTruoc
INSTEAD OF INSERT
AS
BEGIN
    -- Kiểm tra thông tin cần thiết của đơn đặt trước
    IF EXISTS (
        SELECT 1
        FROM inserted
        WHERE MaChiNhanh IS NULL 
          OR SoLuongKhach IS NULL 
          OR SoLuongKhach <= 0
          OR GioDen IS NULL
    )
    BEGIN
        RAISERROR (N'Đơn đặt trước phải có đầy đủ thông tin: chi nhánh, số lượng khách hợp lệ, và giờ đến!', 16, 1);
        ROLLBACK TRANSACTION;
    END
    ELSE
    BEGIN
        INSERT INTO DatTruoc
        SELECT * FROM inserted;
    END;
END;
GO




