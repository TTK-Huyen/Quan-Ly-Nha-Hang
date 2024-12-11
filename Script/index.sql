-- Cài đặt các index để hỗ trợ truy vấn tại đây


-- phân hệ chi nhánh
-- phân hệ khách hàng
CREATE INDEX idx_PhieuDatMon on PhieuDatMon(MaChiNhanh,MaKhachHang)
CREATE INDEX idx_ChiTietPhieu on ChiTietPhieu(MaMon)
CREATE INDEX idx_HoaDon on HoaDon(NgayLap)

CREATE INDEX idx_DatTruoc on DatTruoc(NgayDat, SoLuongKhach)
CREATE INDEX idx_ThongTinTruyCap on ThongTinTruyCap(ThoiGianTruyCap, ThoiDiemTruyCap)
-- phân hệ nhân viên
