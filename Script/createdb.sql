-- Tạo bảng 

-- phân hệ chi nhánh
-- phân hệ khách hàng


CREATE TABLE Ban (
    MaSoBan INT PRIMARY KEY,
    MaChiNhanh INT,
    TrangThai BIT CHECK (TrangThai IN (0, 1)),  -- 0: Trống, 1: Đang sử dụng
    SucChua INT CHECK (SucChua > 0),
    FOREIGN KEY (MaChiNhanh) REFERENCES ChiNhanh(MaChiNhanh)
);

CREATE TABLE DatCho (
    MaSoBan INT,
    MaChiNhanh INT,
    MaDatTruoc INT,
    PRIMARY KEY (MaSoBan, MaChiNhanh, MaDatTruoc),
    FOREIGN KEY (MaSoBan, MaChiNhanh) REFERENCES Ban(MaSoBan, MaChiNhanh),
    FOREIGN KEY (MaDatTruoc) REFERENCES DatTruoc(MaDatTruoc)
);


CREATE TABLE DatTruoc (
    MaDatTruoc INT PRIMARY KEY,
    MaKhachHang INT,
    MaChiNhanh INT,
    SoLuongKhach INT CHECK (SoLuongKhach <= (SELECT SucChua FROM Ban WHERE MaSoBan = DatTruoc.MaSoBan)),
    GioDen DATETIME,
    GhiChu TEXT,
    FOREIGN KEY (MaKhachHang) REFERENCES KhachHang(MaKhachHang),
    FOREIGN KEY (MaChiNhanh) REFERENCES ChiNhanh(MaChiNhanh)
);

CREATE TABLE PhieuDatMon (
    MaPhieu INT PRIMARY KEY, -- Dùng INT vì đây là mã định danh duy nhất và tăng dần.
    NgayLap DATETIME, -- Dùng DATE để lưu trữ ngày tạo phiếu.
    NhanVienLap NVARCHAR(35), -- NVARCHAR để hỗ trợ tên nhân viên với khả năng lưu Unicode.
    MaSoBan varchar(2), -- Dùng varchar vì có thể là MV.
    MaKhachHang INT -- Dùng INT để liên kết đến bảng khách hàng.
	FOREIGN KEY (NhanVienLap) REFERENCES NhanVien(MaNhanVien)
	FOREIGN KEY (MaKhachHang) REFERENCES KhachHang(MaKhachHang)
	FOREIGN KEY (MaSoBan) REFERENCES Ban(MaSoBan)
);



CREATE TABLE ChiTietPhieu (
    MaPhieu INT, -- Khóa ngoại liên kết tới `PhieuDatMon`.
    MaMon INT, -- Mã món ăn (số nguyên).
    SoLuong INT, -- Số lượng món ăn đặt (nguyên dương).
    GhiChu NVARCHAR(200), -- Ghi chú bổ sung.
    PRIMARY KEY (MaPhieu, MaMon), -- Kết hợp 2 cột làm khóa chính.
    FOREIGN KEY (MaPhieu) REFERENCES PhieuDatMon(MaPhieu)
	FOREIGN KEY (MaMon) REFERENCES Mon(MaMon)

);


CREATE TABLE HoaDon (
    MaPhieu INT PRIMARY KEY, -- Khóa chính và khóa ngoại tham chiếu từ `PhieuDatMon`.
    NgayLap DATETIME, -- Dùng DATETIME để lưu ngày lập hóa đơn.
    TongTien DECIMAL(10, 2), -- Dùng DECIMAL để lưu số tiền chính xác đến 2 chữ số thập phân.
    GiamGia DECIMAL(5, 2), -- Tương tự DECIMAL, thường dùng cho tỷ lệ giảm giá (% hoặc giá trị cố định).
    ThanhTien DECIMAL(10, 2), -- Tổng tiền sau giảm giá.
    FOREIGN KEY (MaPhieu) REFERENCES PhieuDatMon(MaPhieu)
);

CREATE TABLE DanhGia (
    MaPhieu INT PRIMARY KEY, -- Khóa chính và liên kết từ `PhieuDatMon`.
    DiemPhucVu INT CHECK (DiemPhucVu BETWEEN 1 AND 5), -- Điểm đánh giá (1-5).
    DiemViTri INT CHECK (DiemViTri BETWEEN 1 AND 5), -- Điểm về vị trí.
    DiemChatLuong INT CHECK (DiemChatLuong BETWEEN 1 AND 5), -- Điểm chất lượng món.
    DiemKhongGian INT CHECK (DiemKhongGian BETWEEN 1 AND 5), -- Điểm không gian.
    BinhLuan NVARCHAR(MAX), -- Bảng lưu trữ bình luận, không giới hạn độ dài.
    FOREIGN KEY (MaPhieu) REFERENCES PhieuDatMon(MaPhieu)
);

-- phân hệ nhân viên


-- ràng buộc constraint 
-- phân hệ chi nhánh
-- phân hệ khách hàng
-- phân hệ nhân viên