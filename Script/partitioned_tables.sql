go
use QLNHAHANG_I
go

-- Tạo Partition Functions và Partition Schemes
-- Phân vùng theo ChiNhanh
CREATE PARTITION FUNCTION pf_ChiNhanh (TINYINT)
AS RANGE LEFT FOR VALUES (1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15); -- Các chi nhánh hiện tại

-- Phân vùng theo thời gian
CREATE PARTITION FUNCTION pf_ThoiGian (DATE)
AS RANGE LEFT FOR VALUES (
'2022-01-01', '2024-01-01', '2024-04-01', '2024-07-01', '2024-10-01', '2025-04-01'
); -- Phân vùng theo quý

-- Phân vùng theo KhuVuc
CREATE PARTITION FUNCTION pf_KhuVuc (TINYINT)
AS RANGE LEFT FOR VALUES (1, 2, 3, 4, 5, 6); -- Các khu vực hiện tại

-- Phân vùng theo LoaiThe
CREATE PARTITION FUNCTION pf_LoaiThe (NVARCHAR(20))
AS RANGE LEFT FOR VALUES (N'Membership', N'Silver', N'Gold');

CREATE PARTITION SCHEME ps_ChiNhanh
AS PARTITION pf_ChiNhanh ALL TO ([PRIMARY]);

CREATE PARTITION SCHEME ps_ThoiGian
AS PARTITION pf_ThoiGian ALL TO ([PRIMARY]);

CREATE PARTITION SCHEME ps_KhuVuc
AS PARTITION pf_KhuVuc ALL TO ([PRIMARY]);

CREATE PARTITION SCHEME ps_LoaiThe
AS PARTITION pf_LoaiThe ALL TO ([PRIMARY]);


CREATE TABLE ChiNhanh (
MaChiNhanh TINYINT IDENTITY(1,1) PRIMARY KEY,
TenChiNhanh NVARCHAR(100) NOT NULL UNIQUE,
DiaChi NVARCHAR(255) NOT NULL UNIQUE,
ThoiGianMoCua TIME,
ThoiGianDongCua TIME,
SoDienThoai VARCHAR(10) UNIQUE,
BaiDoXeHoi BIT DEFAULT 1 CHECK (BaiDoXeHoi IN (0, 1)),
BaiDoXeMay BIT DEFAULT 1 CHECK (BaiDoXeMay IN (0, 1)),
NhanVienQuanLy CHAR(6),
MaKhuVuc TINYINT NOT NULL,
GiaoHang BIT DEFAULT 1 CHECK (GiaoHang IN (0, 1))
)
ON ps_ChiNhanh(MaChiNhanh);

CREATE TABLE MucThucDon
(
	MaMuc TINYINT IDENTITY(1,1) ,
	TenMuc NVARCHAR(50) UNIQUE NOT NULL,
	CONSTRAINT PK_MucThucDon PRIMARY KEY (MaMuc)
)	


CREATE TABLE Mon
(
	MaMon TINYINT IDENTITY(1,1),
	MaMuc TINYINT NOT NULL,
	TenMon NVARCHAR(100) NOT NULL UNIQUE,
	GiaHienTai DECIMAL(18,3) NOT NULL CHECK (GiaHienTai >= 0),
	GiaoHang BIT DEFAULT 1 CHECK (GiaoHang IN (0,1)),
	CONSTRAINT PK_Mon PRIMARY KEY (MaMon)
)


CREATE TABLE PhucVu
(
	MaChiNhanh TINYINT NOT NULL,
	MaMon TINYINT NOT NULL,
	CoPhucVuKhong BIT DEFAULT 1 CHECK (CoPhucVuKhong IN (0,1)),
	
)


CREATE TABLE KhuVuc_ThucDon (
MaKhuVuc TINYINT PRIMARY KEY,
TenKhuVuc NVARCHAR(100) NOT NULL,
TenThucDon NVARCHAR(100) NOT NULL
)
ON ps_KhuVuc(MaKhuVuc);

-- Tạo bảng ThucDon_Mon
CREATE TABLE ThucDon_Mon (
    MaKhuVuc TINYINT NOT NULL,
    MaMon TINYINT NOT NULL,
    CONSTRAINT PK_ThucDon_Mon PRIMARY KEY (MaKhuVuc, MaMon),
);


	
--Phân hệ nhân viên

CREATE TABLE NhanVien (
MaNhanVien CHAR(6) PRIMARY KEY,
HoTen NVARCHAR(255) NOT NULL,
NgaySinh DATE NOT NULL,
GioiTinh NVARCHAR(4) NOT NULL CHECK (GioiTinh IN (N'Nam', N'Nữ', N'Khác')),
NgayVaoLam DATE NOT NULL,
NgayNghiViec DATE NULL,
MaBoPhan CHAR(4) NOT NULL,
DiemSo DECIMAL(9,0) DEFAULT 0 CHECK (DiemSo >= 0)
)
ON ps_ChiNhanh(MaBoPhan);

	
	
CREATE TABLE BoPhan (
	MaBoPhan CHAR(4) default 'BP99',
	TenBoPhan NVARCHAR(50) NOT NULL UNIQUE,
	Luong DECIMAL(18,3) DEFAULT 0 CHECK (Luong >= 0) ,
	CONSTRAINT PK_BP PRIMARY KEY (MaBoPhan)
);


CREATE TABLE LichSuLamViec (
	MaNhanVien CHAR(6),
	MaChiNhanh TINYINT,
	NgayBatDau DATE NOT NULL,
	NgayKetThuc DATE NULL,
	CONSTRAINT PK_LSLV PRIMARY KEY(MaNhanVien,MaChiNhanh), 
); 

-- phân hệ khách hàng

CREATE TABLE Ban (
MaSoBan TINYINT,
MaChiNhanh TINYINT,
TrangThai BIT DEFAULT 0 CHECK (TrangThai IN (0, 1)),
SucChua TINYINT,
PRIMARY KEY (MaSoBan, MaChiNhanh)
)
ON ps_ChiNhanh(MaChiNhanh);



CREATE TABLE KhachHang (
	MaKhachHang INT IDENTITY(1,1) PRIMARY KEY, -- Mã định danh duy nhất cho khách hàng
	SoCCCD CHAR(12) UNIQUE NOT NULL, --Số CCCD của khách hàng, giới hạn 12 kí tự và không trùng lặp
	SoDienThoai CHAR(10) UNIQUE, -- Số điện thoại của khách hàng
	Email NVARCHAR(255) UNIQUE, -- Email của khách hàng
	HoTen NVARCHAR(255) NOT NULL, -- Họ tên của khách hàng
	GioiTinh NVARCHAR(4) CHECK (GioiTinh IN (N'Nam', N'Nữ', N'Khác')) -- giới tính của khách hàng.
);	

CREATE TABLE TheKhachHang (
MaSoThe CHAR(10) PRIMARY KEY,
SoDienThoai CHAR(10) NOT NULL,
NgayLap DATE DEFAULT GETDATE() NOT NULL,
NhanVienLap CHAR(6),
TrangThaiThe BIT DEFAULT 1 CHECK (TrangThaiThe IN (0, 1)),
DiemHienTai INT DEFAULT 0 CHECK (DiemHienTai >= 0),
DiemTichLuy INT DEFAULT 0 CHECK (DiemTichLuy >= 0),
NgayDatThe DATE DEFAULT GETDATE() NOT NULL,
LoaiThe NVARCHAR(20) DEFAULT N'Membership' CHECK (LoaiThe IN (N'Membership', N'Silver', N'Gold'))
)
ON ps_LoaiThe(LoaiThe);

CREATE TABLE PhieuDatMon (
MaPhieu INT IDENTITY(1,1) PRIMARY KEY,
NgayLap DATETIME NOT NULL,
NhanVienLap CHAR(6),
MaSoBan TINYINT,
SoDienThoai CHAR(10),
MaChiNhanh TINYINT NOT NULL
)
ON ps_ThoiGian(NgayLap);


CREATE TABLE ChiTietPhieu (
    MaPhieu INT, -- Khóa ngoại liên kết tới `PhieuDatMon`.
    MaMon TINYINT, -- Mã món ăn (số nguyên).
    SoLuong TINYINT NOT NULL DEFAULT 1 CHECK (SoLuong > 0), -- Số lượng món ăn đặt (nguyên dương).
    GhiChu NVARCHAR(200), -- Ghi chú bổ sung.
    PRIMARY KEY (MaPhieu, MaMon), -- Kết hợp 2 cột làm khóa chính.
);

CREATE TABLE DanhGia (
MaPhieu INT PRIMARY KEY,
DiemPhucVu TINYINT NOT NULL CHECK (DiemPhucVu BETWEEN 1 AND 5),
DiemViTri TINYINT NOT NULL CHECK (DiemViTri BETWEEN 1 AND 5),
DiemChatLuong TINYINT NOT NULL CHECK (DiemChatLuong BETWEEN 1 AND 5),
DiemGiaCa TINYINT NOT NULL CHECK (DiemGiaCa BETWEEN 1 AND 5),
DiemKhongGian TINYINT NOT NULL CHECK (DiemKhongGian BETWEEN 1 AND 5),
BinhLuan NVARCHAR(200),
NgayDanhGia DATE NOT NULL
)
ON ps_ThoiGian(NgayDanhGia);

CREATE TABLE HoaDon (
MaPhieu INT PRIMARY KEY,
NgayLap DATETIME NOT NULL,
TongTien INT NOT NULL,
MaChiNhanh TINYINT NOT NULL
)
ON ps_ChiNhanh(MaChiNhanh);


CREATE TABLE DatTruoc (
MaDatTruoc INT IDENTITY(1,1) PRIMARY KEY,
SoLuongKhach TINYINT NOT NULL DEFAULT 1 CHECK (SoLuongKhach > 0),
NgayDat DATETIME NOT NULL,
GioDen DATETIME NOT NULL,
GhiChu NVARCHAR(255),
MaChiNhanh TINYINT NOT NULL,
SoDienThoai CHAR(10) NOT NULL
)
ON ps_ChiNhanh(MaChiNhanh);




CREATE TABLE ThongTinTruyCap (
	MaKhachHang INT NOT NULL, --Khóa ngoại liên kết đến 'KhachHang'
	SessionID INT PRIMARY KEY IDENTITY(1,1),-- Phiên đăng nhập của khách hàng
	ThoiGianTruyCap INT DEFAULT 0, -- Thời lượng khách hàng thao tác với website
	ThoiDiemTruyCap DATETIME DEFAULT GETDATE() NOT NULL, -- Thời điểm khách hàng truy cập vào website
);

CREATE TABLE Users (
    Username NVARCHAR(10) PRIMARY KEY,
    Password NVARCHAR(255) NOT NULL,
    Role NVARCHAR(20) NOT NULL CHECK (Role IN ('khachhang', 'quanlychinhanh', 'quanlycongty', 'nhanvien')) -- Vai trò
);




