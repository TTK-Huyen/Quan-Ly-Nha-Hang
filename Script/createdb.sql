-- Tạo bảng 
-- phân hệ nhân viên
-- phân hệ chi nhánh
CREATE TABLE KhuVuc
(
	MaKhuVuc INT,
	TenKhuVuc NVARCHAR(255)
	CONSTRAINT PK_KhuVuc PRIMARY KEY (MaKhuVuc)
)

CREATE TABLE ChiNhanh
(
	MaChiNhanh INT,
	TenChiNhanh NVARCHAR(255),
	DiaChi NVARCHAR(255),
	ThoiGianMoCua TIME,
	ThoiGianDongCua TIME,
	SoDienThoai VARCHAR(10),
	BaiDoXeHoi BIT CHECK (BaiDoXeHoi IN (0,1)),
	BaiDoXeMay BIT CHECK (BaiDoXeMay IN (0,1)),
	NhanVienQuanLy VARCHAR(10),
	MaKhuVuc INT,
	GiaoHang BIT CHECK (GiaoHang IN (0,1)),
	CONSTRAINT PK_ChiNhanh PRIMARY KEY(MaChiNhanh),
	CONSTRAINT FK_ChiNhanh_KhuVuc FOREIGN KEY (MaKhuVuc) REFERENCES KhuVuc(MaKhuVuc),
	CONSTRAINT PK_ChiNhanh_NhanVien FOREIGN KEY (NhanVienQuanLy) REFERENCES NhanVien(MaNhanVien)
)

CREATE TABLE MucThucDon
(
	MaMuc INT,
	TenMuc NVARCHAR(255),
	CONSTRAINT PK_MucThucDon PRIMARY KEY (MaMuc)
)

CREATE TABLE ThucDon
(
	MaThucDon INT,
	TenThucDon NVARCHAR(255),
	MaKhuVuc INT,
	CONSTRAINT PK_ThucDon PRIMARY KEY (MaThucDon),
	CONSTRAINT FK_ThucDon_KhuVuc FOREIGN KEY (MaKhuVuc) REFERENCES KhuVuc(MaKhuVuc)
)


CREATE TABLE Mon
(
	MaMon INT,
	MaMuc INT,
	TenMon NVARCHAR(255),
	GiaHienTai INT,
	GiaoHang BIT CHECK (GiaoHang IN (0,1)),
	CONSTRAINT PK_Mon PRIMARY KEY (MaMon),
	CONSTRAINT FK_Mon_MucThucDon FOREIGN KEY (MaMuc) REFERENCES MucThucDon (MaMuc)
)


CREATE TABLE ThucDon_Mon
(
	MaThucDon INT,
	MaMon INT,
	CONSTRAINT FK_ThucDon_Mon_ThucDon FOREIGN KEY (MaThucDon) REFERENCES ThucDon (MaThucDon),
	CONSTRAINT FK_ThucDon_Mon_Mon FOREIGN KEY (MaMon) REFERENCES Mon(MaMon)
)




CREATE TABLE PhucVu
(
	MaChiNhanh INT,
	MaMon INT,
	CoPhucVuKhong BIT CHECK (CoPhucVuKhong IN (0,1)),
	CONSTRAINT FK_PhucVu_ChiNhanh FOREIGN KEY (MaChiNhanh) REFERENCES ChiNhanh(MaChiNhanh),
	CONSTRAINT FK_PhucVu_Mon FOREIGN KEY (MaMon) REFERENCES Mon(MaMon)
)
CREATE TABLE BoPhan (
	MaBoPhan VARCHAR(10),
	TenBoPhan NVARCHAR(30)
	CONSTRAINT PK_BP PRIMARY KEY (MaBoPhan)
);
CREATE TABLE NhanVien (
	MaNhanVien VARCHAR(10),
	HoTen NVARCHAR(50),
	NgaySinh DATE,
	GioiTinh NVARCHAR(4),
	Luong DECIMAL(8,0),
	NgayVaoLam DATE,
	NgayNghiViec DATE,
	MaBoPhan VARCHAR(10),
	DiemSo DECIMAL(9,0)
	CONSTRAINT PK_NV PRIMARY KEY (MaNhanVien),
	CONSTRAINT FK_NV_BP FOREIGN KEY(MaBoPhan) REFERENCES BoPhan(MaBoPhan)
);

CREATE TABLE LichSuLamViec (
	MaNhanVien VARCHAR(10),
	MaChiNhanh INT,
	NgayBatDau DATE,
	NgayKetThuc DATE
	CONSTRAINT PK_LSLV PRIMARY KEY(MaNhanVien,MaChiNhanh), 
	CONSTRAINT FK_LSLV_NV FOREIGN KEY(MaNhanVien) REFERENCES NhanVien(MaNhanVien),
	CONSTRAINT FK_LSLV_CN FOREIGN KEY(MaChiNhanh) REFERENCES ChiNhanh(MaChiNhanh)
); 

-- phân hệ khách hàng

CREATE TABLE Ban (
    MaSoBan INT,
    MaChiNhanh INT,
    TrangThai BIT CHECK (TrangThai IN (0, 1)),  -- 0: Trống, 1: Đang sử dụng
    SucChua INT CHECK (SucChua > 0),
	PRIMARY KEY (MaSoBan, MaChiNhanh),
    FOREIGN KEY (MaChiNhanh) REFERENCES ChiNhanh(MaChiNhanh)
);


CREATE TABLE KhachHang (
	MaKhachHang INT PRIMARY KEY, -- Mã định danh duy nhất cho khách hàng
	SoCCCD VARCHAR(12) UNIQUE NOT NULL, --Số CCCD của khách hàng, giới hạn 12 kí tự và không trùng lặp
	SoDienThoai VARCHAR(15) UNIQUE, -- Số điện thoại của khách hàng
	Email VARCHAR(50) UNIQUE, -- Email của khách hàng
	HoTen NVARCHAR(50) NOT NULL, -- Họ tên của khách hàng
	GioiTinh NVARCHAR(10) CHECK (GioiTinh IN (N'Nam', N'Nữ', N'Khác')) -- giới tính của khách hàng.
);	

CREATE TABLE TheKhachHang (
	MaSoThe INT PRIMARY KEY, -- Mã định danh duy nhất cho thẻ khách hàng
	MaKhachHang INT, -- Mã khách hàng, tham chiếu tới KhachHang
	NgayLap DATETIME, -- Ngày, giờ lập thẻ khách hàng
	NhanVienLap VARCHAR(10), -- Mã nhân viên lập thẻ, tham chiếu tới NhanVien
	TrangThaiThe BIT DEFAULT 1 CHECK (TrangThaiThe IN (0, 1)), -- Trạng thái thẻ khách hàng (0: đóng, 1: mở)
	DiemHienTai INT DEFAULT 0 CHECK (DiemHienTai >= 0), -- Điểm hiện tại trong thẻ, mặc định là 0
	DiemTichLuy INT DEFAULT 0 CHECK (DiemTichLuy >= 0), -- Điểm tích lũy, mặc định là 0
	LoaiThe NVARCHAR(20) DEFAULT N'Membership' CHECK (LoaiThe IN (N'Membership', N'Silver', N'Gold')), -- Loại thẻ, mặc định là Membership
	FOREIGN KEY (MaKhachHang) REFERENCES KhachHang(MaKhachHang),
	FOREIGN KEY (NhanVienLap) REFERENCES NhanVien(MaNhanVien)
);

CREATE TABLE PhieuDatMon (
    MaPhieu INT PRIMARY KEY, -- Dùng INT vì đây là mã định danh duy nhất và tăng dần.
    NgayLap DATETIME, -- Dùng DATE để lưu trữ ngày tạo phiếu.
    NhanVienLap VARCHAR(10), -- NVARCHAR để hỗ trợ tên nhân viên với khả năng lưu Unicode.
    MaSoBan INT, -- Dùng varchar vì có thể là MV.
    MaKhachHang INT,-- Dùng INT để liên kết đến bảng khách hàng.
	MaChiNhanh INT
	FOREIGN KEY (NhanVienLap) REFERENCES NhanVien(MaNhanVien),
	FOREIGN KEY (MaKhachHang) REFERENCES KhachHang(MaKhachHang),
	FOREIGN KEY (MaSoBan, MaChiNhanh) REFERENCES Ban(MaSoBan, MaChiNhanh)
);

CREATE TABLE ChiTietPhieu (
    MaPhieu INT, -- Khóa ngoại liên kết tới `PhieuDatMon`.
    MaMon INT, -- Mã món ăn (số nguyên).
    SoLuong INT, -- Số lượng món ăn đặt (nguyên dương).
    GhiChu NVARCHAR(200), -- Ghi chú bổ sung.
    PRIMARY KEY (MaPhieu, MaMon), -- Kết hợp 2 cột làm khóa chính.
    FOREIGN KEY (MaPhieu) REFERENCES PhieuDatMon(MaPhieu),
	FOREIGN KEY (MaMon) REFERENCES Mon(MaMon)
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

CREATE TABLE HoaDon (
    MaPhieu INT PRIMARY KEY, -- Khóa chính và khóa ngoại tham chiếu từ `PhieuDatMon`.
    NgayLap DATETIME, -- Dùng DATETIME để lưu ngày lập hóa đơn.
    TongTien DECIMAL(10, 2), -- Dùng DECIMAL để lưu số tiền chính xác đến 2 chữ số thập phân.
    GiamGia DECIMAL(5, 2), -- Tương tự DECIMAL, thường dùng cho tỷ lệ giảm giá (% hoặc giá trị cố định).
    ThanhTien DECIMAL(10, 2), -- Tổng tiền sau giảm giá.
    FOREIGN KEY (MaPhieu) REFERENCES PhieuDatMon(MaPhieu)
);

CREATE TABLE DatTruoc (
    MaDatTruoc INT PRIMARY KEY,
    MaKhachHang INT,
    MaChiNhanh INT,
    SoLuongKhach INT,
    GioDen DATETIME,
    GhiChu TEXT,
    FOREIGN KEY (MaKhachHang) REFERENCES KhachHang(MaKhachHang),
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

CREATE TABLE ThongTinTruyCap (
	MaKhachHang INT, --Khóa ngoại liên kết đến 'KhachHang'
	MaDatTruoc INT, -- Khóa ngoại liên kết đến 'DatTruoc'
	ThoiGianTruyCap INT, -- Thời lượng khách hàng thao tác với website
	ThoiDiemTruyCap DATETIME, -- Thời điểm khách hàng truy cập vào website
	PRIMARY KEY (MaKhachHang, MaDatTruoc), --Kết hợp 2 cột làm khóa chính
	FOREIGN KEY (MaKhachHang) REFERENCES KhachHang(MaKhachHang),
	FOREIGN KEY (MaDatTruoc) REFERENCES DatTruoc(MaDatTruoc)
);

-- ràng buộc constraint 
-- phân hệ chi nhánh
-- phân hệ khách hàng
-- phân hệ nhân viên

