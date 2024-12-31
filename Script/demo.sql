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