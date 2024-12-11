--Them thay doi thu
USE MASTER
GO
ALTER DATABASE QLNHAHANG SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
DROP DATABASE QLNHAHANG;

IF DB_ID('QLNHAHANG') IS NOT NULL
	DROP DATABASE QLNHAHANG
GO
CREATE DATABASE QLNHAHANG
GO
USE QLNHAHANG
GO
CREATE TABLE KhuVuc
(
	MaKhuVuc TINYINT IDENTITY(1,1),
	TenKhuVuc NVARCHAR(100) NOT NULL UNIQUE,
	CONSTRAINT PK_KhuVuc PRIMARY KEY (MaKhuVuc)
)

CREATE TABLE ChiNhanh
(
	MaChiNhanh TINYINT IDENTITY(1,1),
	TenChiNhanh NVARCHAR(100) NOT NULL UNIQUE,
	DiaChi NVARCHAR(255) NOT NULL UNIQUE,
	ThoiGianMoCua TIME,
	ThoiGianDongCua TIME,
	SoDienThoai VARCHAR(10) UNIQUE,
	BaiDoXeHoi  BIT DEFAULT 1 CHECK (BaiDoXeHoi IN (0,1)),
	BaiDoXeMay BIT DEFAULT 1 CHECK (BaiDoXeMay IN (0,1)),
	NhanVienQuanLy CHAR(6),
	MaKhuVuc TINYINT NOT NULL,
	GiaoHang BIT DEFAULT 1 CHECK (GiaoHang IN (0,1)),
	CONSTRAINT PK_ChiNhanh PRIMARY KEY(MaChiNhanh),
	
)
CREATE TABLE MucThucDon
(
	MaMuc TINYINT IDENTITY(1,1) ,
	TenMuc NVARCHAR(50) NOT NULL,
	CONSTRAINT PK_MucThucDon PRIMARY KEY (MaMuc)
)

CREATE TABLE ThucDon
(
	MaKhuVuc TINYINT,
	TenThucDon NVARCHAR(100) NOT NULL,
	CONSTRAINT PK_ThucDon PRIMARY KEY (MaKhuVuc),
	
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


CREATE TABLE ThucDon_Mon
(
	MaThucDon TINYINT,
	MaMon TINYINT,
	CONSTRAINT PK_ThucDon_Mon PRIMARY KEY (MaThucDon, MaMon)
)

CREATE TABLE PhucVu
(
	MaChiNhanh TINYINT NOT NULL,
	MaMon TINYINT NOT NULL,
	CoPhucVuKhong BIT DEFAULT 1 CHECK (CoPhucVuKhong IN (0,1)),
	
)

	
--Phân hệ nhân viên
CREATE TABLE NhanVien (
	MaNhanVien CHAR(6) NOT NULL,
	HoTen NVARCHAR(255) NOT NULL,
	NgaySinh DATE NOT NULL,
	GioiTinh NVARCHAR(4) NOT NULL CHECK (GioiTinh IN (N'Nam', N'Nữ', N'Khác')),
	Luong DECIMAL(18,3) DEFAULT 0 CHECK (Luong >= 0) ,
	NgayVaoLam DATE NOT NULL,
	NgayNghiViec DATE NULL,
	MaBoPhan CHAR(4) NOT NULL,
	DiemSo DECIMAL(9,0) DEFAULT 0 CHECK (DiemSo >= 0),
	-- note RCM THÊM THUỘC TÍNH SỐ LƯỢNG ĐÁNH GIÁ ĐỂ TÍNH TRUNG BÌNH ĐIỂM SỐ, CHỨ TÍNH TỔNG KÌ QUÁ
	CONSTRAINT PK_NV PRIMARY KEY (MaNhanVien),
	CONSTRAINT CK_NgayNghiViec CHECK (NgayNghiViec IS NULL OR NgayNghiViec >= NgayVaoLam)
);
	
	
CREATE TABLE BoPhan (
	MaBoPhan CHAR(4) default 'BP99',
	TenBoPhan NVARCHAR(50) NOT NULL UNIQUE,
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
    MaSoBan CHAR(3),
    MaChiNhanh TINYINT,
    TrangThai BIT DEFAULT 0 CHECK (TrangThai IN (0, 1))  -- 0: Trống, 1: Đang sử dụng
	PRIMARY KEY (MaSoBan, MaChiNhanh)
    
);


CREATE TABLE KhachHang (
	MaKhachHang INT IDENTITY(1,1) PRIMARY KEY, -- Mã định danh duy nhất cho khách hàng
	SoCCCD CHAR(12) UNIQUE NOT NULL, --Số CCCD của khách hàng, giới hạn 12 kí tự và không trùng lặp
	SoDienThoai CHAR(10) UNIQUE, -- Số điện thoại của khách hàng
	Email NVARCHAR(255) UNIQUE, -- Email của khách hàng
	HoTen NVARCHAR(255) NOT NULL, -- Họ tên của khách hàng
	GioiTinh NVARCHAR(4) CHECK (GioiTinh IN (N'Nam', N'Nữ', N'Khác')) -- giới tính của khách hàng.
);	

CREATE TABLE TheKhachHang (
	MaSoThe CHAR(10), -- Mã số thẻ
	MaKhachHang INT NOT NULL, -- Mã khách hàng, tham chiếu tới KhachHang
	NgayLap DATE DEFAULT GETDATE() NOT NULL, -- Ngày lập thẻ khách hàng
	NhanVienLap CHAR(6), -- Mã nhân viên lập thẻ, tham chiếu tới NhanVien
	TrangThaiThe BIT DEFAULT 1 CHECK (TrangThaiThe IN (0, 1)), -- Trạng thái thẻ khách hàng (0: đóng, 1: mở)
	DiemHienTai INT DEFAULT 0 CHECK (DiemHienTai >= 0), -- Điểm hiện tại trong thẻ, mặc định là 0
	DiemTichLuy INT DEFAULT 0 CHECK (DiemTichLuy >= 0), -- Điểm tích lũy, mặc định là 0
	NgayDatThe DATE DEFAULT GETDATE() NOT NULL, --Ngày đạt thẻ 
	LoaiThe NVARCHAR(20) DEFAULT N'Membership' CHECK (LoaiThe IN (N'Membership', N'Silver', N'Gold')), -- Loại thẻ, mặc định là Membership
	
);

CREATE TABLE PhieuDatMon (
    MaPhieu INT IDENTITY(1,1) PRIMARY KEY, -- Dùng INT vì đây là mã định danh duy nhất và tăng dần.
    NgayLap DATETIME NOT NULL, -- Dùng DATE để lưu trữ ngày tạo phiếu.
    NhanVienLap CHAR(6), -- NVARCHAR để hỗ trợ tên nhân viên với khả năng lưu Unicode.
    MaSoBan CHAR(3), -- Dùng varchar vì có thể là MV.
    MaKhachHang INT,-- Dùng INT để liên kết đến bảng khách hàng.
	MaChiNhanh TINYINT

);

CREATE TABLE ChiTietPhieu (
    MaPhieu INT, -- Khóa ngoại liên kết tới `PhieuDatMon`.
    MaMon TINYINT, -- Mã món ăn (số nguyên).
    SoLuong TINYINT DEFAULT 1 CHECK (SoLuong > 0), -- Số lượng món ăn đặt (nguyên dương).
    GhiChu NVARCHAR(200), -- Ghi chú bổ sung.
    PRIMARY KEY (MaPhieu, MaMon), -- Kết hợp 2 cột làm khóa chính.
);

CREATE TABLE DanhGia (
    MaPhieu INT PRIMARY KEY, -- Khóa chính và liên kết từ `PhieuDatMon`.
    DiemPhucVu TINYINT NOT NULL CHECK (DiemPhucVu BETWEEN 1 AND 5), -- Điểm đánh giá (1-5).
    DiemViTri TINYINT NOT NULL CHECK (DiemViTri BETWEEN 1 AND 5), -- Điểm về vị trí.
    DiemChatLuong TINYINT NOT NULL CHECK (DiemChatLuong BETWEEN 1 AND 5), -- Điểm chất lượng món.
    DiemKhongGian TINYINT NOT NULL CHECK (DiemKhongGian BETWEEN 1 AND 5), -- Điểm không gian.
    BinhLuan NVARCHAR(200) -- Bình luận tối đa 200 chữ
);

CREATE TABLE HoaDon (
    MaPhieu INT PRIMARY KEY, -- Khóa chính và khóa ngoại tham chiếu từ `PhieuDatMon`.
    NgayLap DATETIME NOT NULL, -- Dùng DATETIME để lưu ngày lập hóa đơn.
    TongTien INT NOT NULL, -- Dùng DECIMAL để lưu số tiền chính xác đến 2 chữ số thập phân.
    GiamGia DECIMAL(3, 2) NOT NULL DEFAULT 0.00, -- Tương tự DECIMAL, thường dùng cho tỷ lệ giảm giá (% hoặc giá trị cố định).
    ThanhTien INT NOT NULL  -- Tổng tiền sau giảm giá.
    
);
--note 404: NGHI VẤN HACK
CREATE TABLE DatTruoc (
    MaDatTruoc INT IDENTITY(1,1) PRIMARY KEY,
    MaKhachHang INT NOT NULL,
    SoLuongKhach TINYINT NOT NULL DEFAULT 1 CHECK (SoLuongKhach > 0),
    GioDen DATETIME NOT NULL,
    GhiChu NVARCHAR(255)
);

CREATE TABLE DatCho (
    MaSoBan CHAR(3) NOT NULL,
    MaChiNhanh TINYINT NOT NULL,
    MaDatTruoc INT,
    PRIMARY KEY (MaDatTruoc),

);
--404
CREATE TABLE ThongTinTruyCap (
	MaKhachHang INT NOT NULL, --Khóa ngoại liên kết đến 'KhachHang'
	MaDatTruoc INT  NOT NULL, -- Khóa ngoại liên kết đến 'DatTruoc'
	ThoiGianTruyCap TINYINT DEFAULT 0, -- Thời lượng khách hàng thao tác với website
	ThoiDiemTruyCap DATETIME  NOT NULL, -- Thời điểm khách hàng truy cập vào website
	PRIMARY KEY (MaKhachHang, MaDatTruoc), --Kết hợp 2 cột làm khóa chính
	--note
	--Khóa chính vì sao lại có mã đặt trước, những khách truy cập web mà không đặt thì sao, 
	--nên là mã kh với thời điểm truy cập làm khóa chính
);

-- ràng buộc constraint 
ALTER TABLE ChiNhanh
ADD CONSTRAINT FK_ChiNhanh_KhuVuc FOREIGN KEY (MaKhuVuc) REFERENCES KhuVuc(MaKhuVuc),
    CONSTRAINT FK_ChiNhanh_NhanVien FOREIGN KEY (NhanVienQuanLy) REFERENCES NhanVien(MaNhanVien),
	CONSTRAINT CK_ChiNhanh_ThoiGianMoCua CHECK (ThoiGianMoCua < ThoiGianDongCua);
-- Ràng buộc thực đơn
ALTER TABLE ThucDon
ADD CONSTRAINT FK_ThucDon_KhuVuc FOREIGN KEY (MaKhuVuc) REFERENCES KhuVuc(MaKhuVuc);

-- Ràng buộc món ăn
ALTER TABLE Mon
ADD CONSTRAINT FK_Mon_MucThucDon FOREIGN KEY (MaMuc) REFERENCES MucThucDon(MaMuc),
	CONSTRAINT CK_Mon_Gia CHECK (GiaHienTai >= 0);
-- Ràng buộc Thực đơn_Món
ALTER TABLE ThucDon_Mon
ADD CONSTRAINT FK_ThucDon_Mon_ThucDon FOREIGN KEY (MaThucDon) REFERENCES ThucDon(MaKhuVuc),
    CONSTRAINT FK_ThucDon_Mon_Mon FOREIGN KEY (MaMon) REFERENCES Mon(MaMon);

-- Ràng buộc phục vụ
ALTER TABLE PhucVu
ADD CONSTRAINT FK_PhucVu_ChiNhanh FOREIGN KEY (MaChiNhanh) REFERENCES ChiNhanh(MaChiNhanh),
    CONSTRAINT FK_PhucVu_Mon FOREIGN KEY (MaMon) REFERENCES Mon(MaMon);

-- Ràng buộc phân hệ nhân viên
ALTER TABLE NhanVien
ADD CONSTRAINT FK_NV_BP FOREIGN KEY (MaBoPhan) REFERENCES BoPhan(MaBoPhan);

-- Ràng buộc lịch sử làm việc
ALTER TABLE LichSuLamViec
ADD CONSTRAINT FK_LSLV_NV FOREIGN KEY (MaNhanVien) REFERENCES NhanVien(MaNhanVien),
    CONSTRAINT FK_LSLV_CN FOREIGN KEY (MaChiNhanh) REFERENCES ChiNhanh(MaChiNhanh);

-- Ràng buộc bàn
ALTER TABLE Ban
ADD CONSTRAINT FK_Ban_ChiNhanh FOREIGN KEY (MaChiNhanh) REFERENCES ChiNhanh(MaChiNhanh);

-- Ràng buộc thẻ khách hàng
ALTER TABLE TheKhachHang
ADD CONSTRAINT FK_TheKhachHang_KhachHang FOREIGN KEY (MaKhachHang) REFERENCES KhachHang(MaKhachHang),
    CONSTRAINT FK_TheKhachHang_NhanVien FOREIGN KEY (NhanVienLap) REFERENCES NhanVien(MaNhanVien);

-- Ràng buộc phiếu đặt món
ALTER TABLE PhieuDatMon
ADD CONSTRAINT FK_PhieuDatMon_NhanVien FOREIGN KEY (NhanVienLap) REFERENCES NhanVien(MaNhanVien),
    CONSTRAINT FK_PhieuDatMon_KhachHang FOREIGN KEY (MaKhachHang) REFERENCES KhachHang(MaKhachHang),
    CONSTRAINT FK_PhieuDatMon_Ban FOREIGN KEY (MaSoBan, MaChiNhanh) REFERENCES Ban(MaSoBan, MaChiNhanh);

-- Ràng buộc chi tiết phiếu
ALTER TABLE ChiTietPhieu
ADD CONSTRAINT FK_ChiTietPhieu_Phieu FOREIGN KEY (MaPhieu) REFERENCES PhieuDatMon(MaPhieu),
    CONSTRAINT FK_ChiTietPhieu_Mon FOREIGN KEY (MaMon) REFERENCES Mon(MaMon);

-- Ràng buộc đánh giá
ALTER TABLE DanhGia
ADD CONSTRAINT FK_DanhGia_Phieu FOREIGN KEY (MaPhieu) REFERENCES PhieuDatMon(MaPhieu);

-- Ràng buộc hóa đơn
ALTER TABLE HoaDon
ADD CONSTRAINT FK_HoaDon_Phieu FOREIGN KEY (MaPhieu) REFERENCES PhieuDatMon(MaPhieu);

-- Ràng buộc đặt trước
ALTER TABLE DatTruoc
ADD CONSTRAINT FK_DatTruoc_KhachHang FOREIGN KEY (MaKhachHang) REFERENCES KhachHang(MaKhachHang),
    CONSTRAINT FK_DatTruoc_ChiNhanh FOREIGN KEY (MaChiNhanh) REFERENCES ChiNhanh(MaChiNhanh);

-- Ràng buộc đặt chỗ
ALTER TABLE DatCho
ADD CONSTRAINT FK_DatCho_Ban FOREIGN KEY (MaSoBan, MaChiNhanh) REFERENCES Ban(MaSoBan, MaChiNhanh),
    CONSTRAINT FK_DatCho_DatTruoc FOREIGN KEY (MaDatTruoc) REFERENCES DatTruoc(MaDatTruoc);

-- Ràng buộc thông tin truy cập
ALTER TABLE ThongTinTruyCap
ADD CONSTRAINT FK_ThongTinTruyCap_KhachHang FOREIGN KEY (MaKhachHang) REFERENCES KhachHang(MaKhachHang),
    CONSTRAINT FK_ThongTinTruyCap_DatTruoc FOREIGN KEY (MaDatTruoc) REFERENCES DatTruoc(MaDatTruoc);
