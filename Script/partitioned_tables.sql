go
use QLNHAHANG
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

-- Tạo bảng sử dụng Partition
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

CREATE TABLE HoaDon (
MaPhieu INT PRIMARY KEY,
NgayLap DATETIME NOT NULL,
TongTien INT NOT NULL,
MaChiNhanh TINYINT NOT NULL
)
ON ps_ChiNhanh(MaChiNhanh);

CREATE TABLE PhieuDatMon (
MaPhieu INT IDENTITY(1,1) PRIMARY KEY,
NgayLap DATETIME NOT NULL,
NhanVienLap CHAR(6),
MaSoBan TINYINT,
SoDienThoai CHAR(10),
MaChiNhanh TINYINT NOT NULL
)
ON ps_ThoiGian(NgayLap);

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

CREATE TABLE KhuVuc_ThucDon (
MaKhuVuc TINYINT PRIMARY KEY,
TenKhuVuc NVARCHAR(100) NOT NULL,
TenThucDon NVARCHAR(100) NOT NULL
)
ON ps_KhuVuc(MaKhuVuc);

CREATE TABLE Ban (
MaSoBan TINYINT,
MaChiNhanh TINYINT,
TrangThai BIT DEFAULT 0 CHECK (TrangThai IN (0, 1)),
SucChua TINYINT,
PRIMARY KEY (MaSoBan, MaChiNhanh)
)
ON ps_ChiNhanh(MaChiNhanh);


