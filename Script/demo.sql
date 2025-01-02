	-- Viết các kịch bản truy vấn
	USE QLNHAHANG
	GO

	--1. thống kê doanh thu theo từng món, món chạy nhất, món bán chậm nhất trong 1 khoảng thời gian cụ thể theo chi nhánh, khu vực -- Huyền
		SET STATISTICS TIME ON;
		EXEC SP_THONGKEDOANHTHU_MONAN  '2025-01-02','2025-12-31', '12', '2';--CHUA CHAJY DUOC 
		
	--2. In hóa đơn khi khách hàng yêu cầu -- Huyền
		EXEC INHOADON 2
		select * from khachhang

	--3. XOA THE KHASCH HÀNG KHI KHÁCH HÀNG BÁO MẤT THẺ -- Huyền
		--EXEC XOATHEKH '123456180949', 'Pham Thi Phuc', '0981256880'
		--select * from KhachHang


	--4. xem danh sách nhân viên, điểm phục vụ của từng nhân viên cuối mỗi ngày/THÁNG/QUÝ/NĂM 
		--THEO NGÀY
		EXEC sp_DiemPhucVuTheoNgay '2023-07-12'
		--THEO THÁNG
		EXEC sp_DiemPhucVuTheoThang @Thang = 12, @Nam = 2023;
		--THEO QUÝ
		EXEC sp_DiemPhucVuTheoQuy @Quy = 2, @Nam = 2023;
		--THEO NĂM
		EXEC sp_DiemPhucVuTheoNam @Nam = 2023;
		select * from LichSuLamViec where MaNhanVien='NV0011'
	--5. Tìm nhân viên 
		--THEO MÃ 
		EXEC TIMTTNV 'NV0001', '8'
		--THEO TÊN 
		EXEC sp_TimNhanVienTheoTen 'Austin Gomez' , '3'
		--THEO NGÀY SINH
		EXEC sp_TimNhanVienTheoNgaySinh  '1987-06-23', '8'
		--THEO NGÀY VÀO LÀM
		EXEC sp_TimNhanVienTheoNgayVaoLam '2024-01-02', '7'
		--THEO BỘ PHẬN 
		EXEC sp_TimNhanVienTheoBoPhan 'BP03', '9'
		--THEO CHI NHÁNH 
		EXEC XEMNVCN @MaChiNhanh = 2

	--6. Điều động nhân viên
		--EXEC MoveEmployee 'NV0002', '6'

	--7. Xem doanh thu theo từng ngày, từng tháng, từng quý và từng năm
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

	--8. THÊM THÔNG TIN THẺ KHÁCH HÀNG 
		--EXEC THEMTHEKH 
			--@MAKHACHHANG = 1, 
			--@NHANVIENLAP = 'NV0234';
		--xem lai
		-- EXEC SP_XEMTHONGTIN_THETHANHVIEN @MaKhachHang = 1;


	--9. XÓA THÔNG TIN THẺ KHÁCH HÀNG
		/*EXEC XOATHEKH 
			@SOCCCD = '123456462096', 
			@HOTEN = N'Nguyen Thu Dung', 
			@SODIENTHOAI = '0984427970';
			select * from TheKhachHang*/
	--10. CẬP NHẬT THÔNG TIN THẺ KHÁCH HÀNG
		EXEC SP_XEMTHONGTIN_THETHANHVIEN @SODIENTHOAI = 0987583657;
		EXEC CAPNHAT_THEKHACHHANG 
			@MASOTHE = '1', 
			@SODIENTHOAI = '0989296300',
			@NGAYLAP = '2024-11-12', 
			@NHANVIENLAP = 'NV0151', 
			@TRANGTHAITHE = 1, 
			@DIEMHIENTAI = 0, 
			@DIEMTICHLUY = 0, 
			@NGAYDATTHE = '2024-12-10', 
			@LOAITHE = N'Membership';
	

	--11. THÊM NHÂN VIÊN
		EXEC THEMNV N'Thái Thị Kim Huyền', '2004-11-10', N'Nữ', '2023-10-04','BP08',5

	--12. THÊM PHIẾU ĐẶT MÓN 
		--thêm pdm
		DECLARE @MAPHIEU INT
		EXEC THEMPDM 'NV0034', 34, '0989389191', '4', @MAPHIEU;

		--sửa pdm
		-- EXEC NVSUAPDM '3',	'5', '5', N'Không cay';
		--XOA PDM 
		-- EXEC XOAPDM '2'

	--13. TÌM KIẾM HÓA ĐƠN 
		-- THEO khasch hang
		--EXEC TIMHD_KH '5'
		--THEO NGAY
		EXEC TIMHD_NGAY '2023-10-05'

	 SET STATISTICS TIME OFF;