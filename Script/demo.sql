-- Viết các kịch bản truy vấn



--thống kê doanh thu theo từng món, món chạy nhất, món bán chậm nhất trong
--1 khoảng thời gian cụ thể theo chi nhánh, khu vực
USE QLNHAHANG
GO
-- Món, Mục thực đơn, Hóa đơn, phiếu đặt món,chi tiết phiếu, chi nhánh, khu vực_thực đơn 
CREATE PROCEDURE SP_THONGKEDOANHTHU_MONAN
	@NGAYBATDAU DATE,
	@NGAYKETHUC DATE,
	@MACHINHANH TINYINT,
	@MAKHUVUC TINYINT
AS
BEGIN
	-- CHECK 
	-- Kiểm tra ngày bắt đầu < ngày kết thúc
	-- Kiểm tra mã chi nhánh và mã khu vực


	
END;
GO

SELECT M.MaMon, M.TenMon,
       COUNT(*) * M.GiaHienTai AS TongTien
FROM MON M 
JOIN CHITIETPHIEU CTP ON M.MaMon = CTP.MaMon
JOIN PHIEUDATMON PDM ON PDM.MaPhieu = CTP.MaPhieu
JOIN HOADON HD ON PDM.MaPhieu = HD.MaPhieu
JOIN CHINHANH CN ON PDM.MaChiNhanh = CN.MaChiNhanh
JOIN KHUVUC_THUCDON KV ON KV.MaKhuVuc = CN.MaKhuVuc
WHERE KV.MaKhuVuc = 3 
  AND CN.MaChiNhanh = 1
  AND HD.NgayLap < '2025-1-30' AND HD.NgayLap > '2024-1-1'
GROUP BY M.MaMon, M.GiaHienTai, M.TenMon
ORDER BY TongTien DESC;

--xem danh sách nhân viên, điểm phục vụ của từng nhân viên cuối mỗi ngày 
SELECT 
    n.MaNhanVien,
    n.HoTen,
    AVG(dg.DiemPhucVu) AS TongDiemPhucVu,
    CONVERT(DATE, p.NgayLap) AS Ngay
FROM 
    NhanVien n
JOIN 
    PhieuDatMon p ON n.MaNhanVien = p.NhanVienLap
JOIN 
	DanhGia dg ON p.MaPhieu  = dg.MaPhieu
GROUP BY 
    n.MaNhanVien, n.HoTen, CONVERT(DATE, p.NgayLap)
ORDER BY 
    Ngay DESC, n.MaNhanVien;

CREATE PROCEDURE sp_DiemPhucVuTheoNgay
    @Ngay DATE
AS
BEGIN
    SELECT 
        n.MaNhanVien,
        n.HoTen,
        AVG(dg.DiemPhucVu) AS TongDiemPhucVu,
        CONVERT(DATE, p.NgayLap) AS Ngay
    FROM 
        NhanVien n
    JOIN 
        PhieuDatMon p ON n.MaNhanVien = p.NhanVienLap
    JOIN 
        DanhGia dg ON p.MaPhieu = dg.MaPhieu
    WHERE 
        CONVERT(DATE, p.NgayLap) = @Ngay
    GROUP BY 
        n.MaNhanVien, n.HoTen, CONVERT(DATE, p.NgayLap)
    ORDER BY 
        Ngay DESC, n.MaNhanVien;
END;
go
EXEC sp_DiemPhucVuTheoNgay @Ngay = '2023-12-21';

--xem danh sách nhân viên, điểm phục vụ của từng nhân viên cuối mỗi THÁNG 

SELECT 
    n.MaNhanVien,
    n.HoTen,
    AVG(dg.DiemPhucVu) AS TongDiemPhucVu,
    DATEPART(YEAR, p.NgayLap) AS Nam,
    DATEPART(MONTH, p.NgayLap) AS Thang
FROM 
    NhanVien n
JOIN 
    PhieuDatMon p ON n.MaNhanVien = p.NhanVienLap
JOIN 
    DanhGia dg ON p.MaPhieu = dg.MaPhieu
GROUP BY 
    n.MaNhanVien, n.HoTen, DATEPART(YEAR, p.NgayLap), DATEPART(MONTH, p.NgayLap)
ORDER BY 
    Nam DESC, Thang DESC, n.MaNhanVien;

CREATE PROCEDURE sp_DiemPhucVuTheoThang
    @Thang INT,
    @Nam INT
AS
BEGIN
    SELECT 
        n.MaNhanVien,
        n.HoTen,
        AVG(dg.DiemPhucVu) AS TongDiemPhucVu,
        DATEPART(YEAR, p.NgayLap) AS Nam,
        DATEPART(MONTH, p.NgayLap) AS Thang
    FROM 
        NhanVien n
    JOIN 
        PhieuDatMon p ON n.MaNhanVien = p.NhanVienLap
    JOIN 
        DanhGia dg ON p.MaPhieu = dg.MaPhieu
    WHERE 
        DATEPART(YEAR, p.NgayLap) = @Nam AND DATEPART(MONTH, p.NgayLap) = @Thang
    GROUP BY 
        n.MaNhanVien, n.HoTen, DATEPART(YEAR, p.NgayLap), DATEPART(MONTH, p.NgayLap)
    ORDER BY 
        Nam DESC, Thang DESC, n.MaNhanVien;
END;
go
EXEC sp_DiemPhucVuTheoThang @Thang = 12, @Nam = 2023;



--xem danh sách nhân viên, điểm phục vụ của từng nhân viên cuối mỗi quý

SELECT 
    n.MaNhanVien,
    n.HoTen,
    AVG(dg.DiemPhucVu) AS TongDiemPhucVu,
    DATEPART(YEAR, p.NgayLap) AS Nam,
    DATEPART(QUARTER, p.NgayLap) AS Quy
FROM 
    NhanVien n
JOIN 
    PhieuDatMon p ON n.MaNhanVien = p.NhanVienLap
JOIN 
    DanhGia dg ON p.MaPhieu = dg.MaPhieu
GROUP BY 
    n.MaNhanVien, n.HoTen, DATEPART(YEAR, p.NgayLap), DATEPART(QUARTER, p.NgayLap)
ORDER BY 
    Nam DESC, Quy DESC, n.MaNhanVien;

CREATE PROCEDURE sp_DiemPhucVuTheoQuy
    @Quy INT,
    @Nam INT
AS
BEGIN
    SELECT 
        n.MaNhanVien,
        n.HoTen,
        AVG(dg.DiemPhucVu) AS TongDiemPhucVu,
        DATEPART(YEAR, p.NgayLap) AS Nam,
        DATEPART(QUARTER, p.NgayLap) AS Quy
    FROM 
        NhanVien n
    JOIN 
        PhieuDatMon p ON n.MaNhanVien = p.NhanVienLap
    JOIN 
        DanhGia dg ON p.MaPhieu = dg.MaPhieu
    WHERE 
        DATEPART(YEAR, p.NgayLap) = @Nam AND DATEPART(QUARTER, p.NgayLap) = @Quy
    GROUP BY 
        n.MaNhanVien, n.HoTen, DATEPART(YEAR, p.NgayLap), DATEPART(QUARTER, p.NgayLap)
    ORDER BY 
        Nam DESC, Quy DESC, n.MaNhanVien;
END;
go

--xem danh sách nhân viên, điểm phục vụ của từng nhân viên cuối mỗi năm
SELECT 
    n.MaNhanVien,
    n.HoTen,
    AVG(dg.DiemPhucVu) AS TongDiemPhucVu,
    DATEPART(YEAR, p.NgayLap) AS Nam
FROM 
    NhanVien n
JOIN 
    PhieuDatMon p ON n.MaNhanVien = p.NhanVienLap
JOIN 
    DanhGia dg ON p.MaPhieu = dg.MaPhieu
GROUP BY 
    n.MaNhanVien, n.HoTen, DATEPART(YEAR, p.NgayLap)
ORDER BY 
    Nam DESC, n.MaNhanVien;


CREATE PROCEDURE sp_DiemPhucVuTheoNam
    @Nam INT
AS
BEGIN
    SELECT 
        n.MaNhanVien,
        n.HoTen,
        AVG(dg.DiemPhucVu) AS TongDiemPhucVu,
        DATEPART(YEAR, p.NgayLap) AS Nam
    FROM 
        NhanVien n
    JOIN 
        PhieuDatMon p ON n.MaNhanVien = p.NhanVienLap
    JOIN 
        DanhGia dg ON p.MaPhieu = dg.MaPhieu
    WHERE 
        DATEPART(YEAR, p.NgayLap) = @Nam
    GROUP BY 
        n.MaNhanVien, n.HoTen, DATEPART(YEAR, p.NgayLap)
    ORDER BY 
        Nam DESC, n.MaNhanVien;
END;
go
EXEC sp_DiemPhucVuTheoNam @Nam = 2023;


-- Tìm kiếm thông tin nhân viên, xem danh sách nhân viên theo chi nhánh
--Tất xem tất cả nhân viên
select * 
from NhanVien n
--Tìm nhân viên theo tên
select * 
from NhanVien n
where n.HoTen = 'Frederick Baxter'
--Tìm nhân viên theo Ngày sinh
select * 
from NhanVien n
where n.NgaySinh = '2001-06-26'
--Tìm nhân viên theo ngày vào làm
select * 
from NhanVien n
where n.NgayVaoLam = '2025-01-01'
--Tìm nhân viên theo bộ phận 
select * 
from NhanVien n
where n.MaBoPhan = 'BP02'
-- SP 1: Tìm nhân viên theo tên
CREATE PROCEDURE sp_TimNhanVienTheoTen
    @HoTen NVARCHAR(255)
AS
BEGIN
    SELECT * 
    FROM NhanVien n
    WHERE n.HoTen = @HoTen;
END;
go

-- SP 2: Tìm nhân viên theo ngày sinh
CREATE PROCEDURE sp_TimNhanVienTheoNgaySinh
    @NgaySinh DATE
AS
BEGIN
    SELECT * 
    FROM NhanVien n
    WHERE n.NgaySinh = @NgaySinh;
END;
go

-- SP 3: Tìm nhân viên theo ngày vào làm
CREATE PROCEDURE sp_TimNhanVienTheoNgayVaoLam
    @NgayVaoLam DATE
AS
BEGIN
    SELECT * 
    FROM NhanVien n
    WHERE n.NgayVaoLam = @NgayVaoLam;
END;
go

-- SP 4: Tìm nhân viên theo bộ phận
CREATE PROCEDURE sp_TimNhanVienTheoBoPhan
    @MaBoPhan NVARCHAR(50)
AS
BEGIN
    SELECT * 
    FROM NhanVien n
    WHERE n.MaBoPhan = @MaBoPhan;
END;
go 




--Tìm nhân viên theo chi nhánh 
SELECT 
    n.MaNhanVien,
    n.HoTen,
    n.NgaySinh,
    l.MaChiNhanh,
    l.NgayBatDau,
    l.NgayKetThuc
FROM 
    NhanVien n 
JOIN 
    LichSuLamViec l ON n.MaNhanVien = l.MaNhanVien
WHERE 
    l.NgayKetThuc IS NULL
GROUP BY 
    n.MaNhanVien, n.HoTen, n.NgaySinh, l.MaChiNhanh, l.NgayBatDau, l.NgayKetThuc
order by l.MaChiNhanh

-- SP 2: Lấy danh sách nhân viên và nhóm theo chi nhánh
CREATE PROCEDURE sp_NhanVienTheoChiNhanh
AS
BEGIN
    SELECT 
        l.MaChiNhanh,
        COUNT(n.MaNhanVien) AS SoLuongNhanVien
    FROM 
        NhanVien n 
    JOIN 
        LichSuLamViec l ON n.MaNhanVien = l.MaNhanVien
    WHERE 
        l.NgayKetThuc IS NULL
    GROUP BY 
        l.MaChiNhanh
    ORDER BY 
        SoLuongNhanVien DESC, l.MaChiNhanh;
END;
go

select* from LichSuLamViec n where n.MaNhanVien = 'NV0001'
exec MoveEmployee   'NV0001', '10'
CREATE  PROC MoveEmployee 
	@MaNhanVien CHAR(10),
	@MaChiNhanhMoi TINYINT
AS
BEGIN
	--Kiem tra ton tai ma nhan vien
	IF NOT EXISTS (SELECT 1 FROM NhanVien WHERE MaNhanVien = @MaNhanVien) OR 
	NOT EXISTS (SELECT 1 FROM LichSuLamViec WHERE MaNhanVien = @MaNhanVien AND NgayKetThuc IS NULL)
	BEGIN
		RAISERROR (N'NHÂN VIÊN KHÔNG TỒN TẠI TRONG HỆ THỐNG HOẶC ĐÃ NGƯNG LÀM VIỆC!',16,1);
		RETURN;
	END
	--KIEM TRA CHI NHANH MƠI
	IF NOT EXISTS (SELECT 1 FROM ChiNhanh WHERE MaChiNhanh = @MaChiNhanhMoi)
	BEGIN
		RAISERROR (N'CHI NHÁNH KHÔNG TỒN TẠI!',16,1);
		RETURN;
	END
	UPDATE LichSuLamViec 
	SET NgayKetThuc =  getdate()
	WHERE NgayKetThuc IS NULL

	INSERT INTO LichSuLamViec (MaNhanVien, NgayBatDau,MaChiNhanh)
	VALUES (@MaNhanVien, GETDATE(), @MaChiNhanhMoi)
	PRINT N'Chuyển nhân sự thành công';
END
GO
--- Xem doanh thu theo từng ngày, từng tháng, từng quý và từng năm
-- Theo ngay
EXEC THONGKE_DOANHTHU_CHINHANH @MACN = 1, @START_DAY = '2024-12-01', @END_DAY = '2024-12-31';
-- Theo thang
DECLARE @Year INT = 2024;
DECLARE @StartDate DATE = CAST(@Year AS VARCHAR) + '-01-01';
DECLARE @EndDate DATE = CAST(@Year AS VARCHAR) + '-12-31';

EXEC THONGKE_DOANHTHU_CHINHANH @MACN = 1, @START_DAY = @StartDate, @END_DAY = @EndDate;

--- Theo quy
EXEC THONGKE_DOANHTHU_CHINHANH @MACN = 1, @START_DAY = '2024-01-01', @END_DAY = '2024-03-31';
EXEC THONGKE_DOANHTHU_CHINHANH @MACN = 1, @START_DAY = '2024-04-01', @END_DAY = '2024-06-30';
EXEC THONGKE_DOANHTHU_CHINHANH @MACN = 1, @START_DAY = '2024-07-01', @END_DAY = '2024-09-30';
EXEC THONGKE_DOANHTHU_CHINHANH @MACN = 1, @START_DAY = '2024-10-01', @END_DAY = '2024-12-31';
--- Theo nam
EXEC THONGKE_DOANHTHU_CHINHANH @MACN = 1, @START_DAY = '2024-01-01', @END_DAY = '2024-12-31';

-- Them/xoa/cap nhat thong tin the khach hang
-- Them thongg tin the khach hang
EXEC THEMTHEKH 
    @MAKHACHHANG = 1, 
    @NHANVIENLAP = 'NV1234';
--xem lai
EXEC SP_XEMTHONGTIN_THETHANHVIEN @MaKhachHang = 1;


-- Xoa Thong tin the khach hang
EXEC XOATHEKH 
    @SOCCCD = '123456789012', 
    @HOTEN = N'Nguyễn Văn A', 
    @SODIENTHOAI = '0123456789';

-- Cap nhat thong tin the khach hang
EXEC CAPNHAT_THEKHACHHANG 
    @MASOTHE = 'TH123456', 
    @MAKHACHHANG = 1, 
    @NGAYLAP = '2025-01-01', 
    @NHANVIENLAP = 'NV1234', 
    @TRANGTHAITHE = 1, 
    @DIEMHIENTAI = 500, 
    @DIEMTICHLUY = 1000, 
    @NGAYDATTHE = '2025-01-01', 
    @LOAITHE = N'Gold';

--Them nhan vien
EXEC THEMNV N'Leonardo DiCaprio', '1974-11-11', N'Nam', '2023-10-04','BP08',5



