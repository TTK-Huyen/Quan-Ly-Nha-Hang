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

