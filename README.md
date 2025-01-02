# Quan-Ly-Nha-Hang
--test
# Hướng dẫn insert data vào csdl
Hướng dẫn sử dụng cơ sở dữ liệu QLNHAHANG

1. Tổng quan

Cơ sở dữ liệu QLNHAHANG được thiết kế để hỗ trợ hệ thống quản lý nhà hàng với các chức năng chính như quản lý chi nhánh, nhân viên, khách hàng, món ăn, hóa đơn, và các chi tiết liên quan.

2. Thứ tự thêm dữ liệu vào các bảng
Mở SQL và chạy file createdb.sql, store_procedures.sql, store_trigger.sql

Để tránh xung đột khoá ngoại (Foreign Key), vui lòng thêm dữ liệu theo thứ tự sau:

1. KhuVuc_ThucDon

Thông tin khu vực thực đơn.

MucThucDon

Danh mục thực đơn.

Mon

Danh sách các món ăn.

ThucDon_Mon

Quan hệ giữa thực đơn và món ăn.

BoPhan

Danh sách bộ phận trong nhà hàng.

NhanVien

Thông tin nhân viên, liên kết với BoPhan.

ChiNhanh

Thông tin các chi nhánh, liên kết với NhanVien (Quản lý chi nhánh).

LichSuLamViec

Lịch sử làm việc của nhân viên.

Ban

Thông tin bàn ăn, liên kết với ChiNhanh.

KhachHang

Thông tin khách hàng.

TheKhachHang

Thẻ khách hàng, liên kết với KhachHang.

PhieuDatMon

Phiếu đặt món ăn, liên kết với KhachHang, Ban, và NhanVien.

ChiTietPhieu

Chi tiết phiếu đặt món, liên kết với PhieuDatMon và Mon.

DanhGia

Đánh giá món ăn, liên kết với KhachHang và Mon.

HoaDon

Hóa đơn thanh toán, liên kết với PhieuDatMon và NhanVien.

DatTruoc

Đặt trước bàn ăn, liên kết với KhachHang và Ban.

ThongTinTruyCap

Thông tin truy cập hệ thống.

Users

Thông tin người dùng hệ thống.