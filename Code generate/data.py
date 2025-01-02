import random
from datetime import datetime, timedelta

# Hàm tạo dữ liệu bảng bàn
def generate_ban_data(file_name):
    try:
        with open(file_name, "w", encoding="utf-8") as file:
            file.write("-- Dữ liệu bảng Ban\n")
            for chi_nhanh in range(1, 16):  # Mã chi nhánh từ 1 đến 15
                for ma_ban in range(1, 41):  # Mã bàn từ 1 đến 40
                    suc_chua = random.randint(2, 10)  # Sức chứa ngẫu nhiên từ 2 đến 10
                    file.write(f"INSERT INTO Ban (MaSoBan, SucChua, MaChiNhanh) VALUES ({ma_ban}, {suc_chua}, {chi_nhanh});\n")
            print(f"Tạo dữ liệu bảng Ban thành công, lưu vào {file_name}!")
    except Exception as e:
        print(f"Lỗi khi tạo dữ liệu bảng Ban: {e}")

# Tìm bàn phù hợp
def find_suitable_ban(so_luong_khach, ban_data, chi_nhanh):
    suitable_ban = [ban for ban in ban_data if ban["SucChua"] >= so_luong_khach and ban["ChiNhanh"] == chi_nhanh]
    return random.choice(suitable_ban)["MaBan"] if suitable_ban else None

# Hàm tạo số điện thoại ngẫu nhiên
def generate_random_phone(existing_phones):
    while True:
        phone = f"098{random.randint(1000000, 9999999):07d}"
        if phone not in existing_phones:
            existing_phones.add(phone)
            return phone

# Hàm tạo phiếu đặt món
def generate_phieu_dat_mon(ma_ban, so_dien_thoai, ma_phieu, ma_chi_nhanh, gio_den):
    ngay_lap = gio_den + timedelta(hours=1)  # Ngày lập là 1 tiếng sau giờ đến
    nhan_vien_lap = f"'NV{random.randint(1, 5):04d}'" if random.random() > 0.5 else "NULL"
    return f"INSERT INTO PhieuDatMon (MaPhieu, MaSoBan, SoDienThoai, NgayLap, NhanVienLap, MaChiNhanh) VALUES ({ma_phieu}, {ma_ban}, '{so_dien_thoai}', '{ngay_lap.strftime('%Y-%m-%d %H:%M:%S')}', {nhan_vien_lap}, {ma_chi_nhanh});\n"

# Hàm tạo chi tiết phiếu
def generate_chi_tiet_phieu(ma_phieu):
    so_mon = random.randint(5, 10)  # 5 đến 10 dòng chi tiết phiếu
    chi_tiet = []
    used_ma_mon = set()
    for _ in range(so_mon):
        while True:
            ma_mon = random.randint(1, 33)
            if ma_mon not in used_ma_mon:  # Đảm bảo mã món không bị trùng
                used_ma_mon.add(ma_mon)
                break
        so_luong = random.randint(1, 5)
        ghi_chu = "NULL" if random.random() > 0.7 else f"'Note {random.randint(1, 100)}'"
        chi_tiet.append(f"INSERT INTO ChiTietPhieu (MaPhieu, MaMon, SoLuong, GhiChu) VALUES ({ma_phieu}, {ma_mon}, {so_luong}, {ghi_chu});\n")
    return ''.join(chi_tiet)

# Hàm tạo dữ liệu
def generate_data_with_constraints(total_reservations=100000):
    try:
        existing_phones = set()
        ban_data = [
            {"MaBan": ma_ban, "SucChua": random.randint(2, 10), "ChiNhanh": chi_nhanh}
            for chi_nhanh in range(1, 16)
            for ma_ban in range(1, 41)
        ]

        with open("insert_dattruoc.sql", "w", encoding="utf-8") as dat_truoc_file, \
             open("insert_phieudatmon.sql", "w", encoding="utf-8") as phieu_file, \
             open("insert_chitietphieu.sql", "w", encoding="utf-8") as chitiet_file:

            for i in range(1, total_reservations + 1):
                so_dien_thoai = generate_random_phone(existing_phones)
                ngay_dat = datetime.now() - timedelta(days=random.randint(0, 365))
                gio_den = ngay_dat + timedelta(hours=random.randint(1, 12))
                ghi_chu = "NULL" if random.random() > 0.7 else f"'Note {random.randint(1, 100)}'"
                ma_chi_nhanh = random.randint(1, 15)
                so_luong_khach = random.randint(1, 10)

                # Tìm bàn phù hợp
                ma_ban = find_suitable_ban(so_luong_khach, ban_data, ma_chi_nhanh)

                # Nếu không tìm thấy bàn, gán NULL
                if ma_ban is None:
                    print(f"Không tìm thấy bàn phù hợp cho chi nhánh {ma_chi_nhanh} và số lượng khách {so_luong_khach}.")
                    ma_ban = "NULL"

                # Ghi dữ liệu vào DatTruoc
                dat_truoc_file.write(
                    f"INSERT INTO DatTruoc (SoDienThoai, NgayDat, GioDen, GhiChu, ChiNhanh, SoLuongKhach, MaPhieu) VALUES "
                    f"('{so_dien_thoai}', '{ngay_dat.strftime('%Y-%m-%d %H:%M:%S')}', '{gio_den.strftime('%Y-%m-%d %H:%M:%S')}', {ghi_chu}, {ma_chi_nhanh}, {so_luong_khach}, {i});\n"
                )

                # Ghi dữ liệu vào PhieuDatMon
                phieu_file.write(generate_phieu_dat_mon(ma_ban, so_dien_thoai, i, ma_chi_nhanh, gio_den))

                # Ghi dữ liệu vào ChiTietPhieu
                chitiet_file.write(generate_chi_tiet_phieu(i))

            print("Tạo dữ liệu thành công cho các bảng DatTruoc, PhieuDatMon, và ChiTietPhieu!")
    except Exception as e:
        print(f"Lỗi khi tạo dữ liệu: {e}")

# Gọi hàm tạo dữ liệu
ban_output_file = "insert_ban.sql"
generate_ban_data(ban_output_file)
generate_data_with_constraints(total_reservations=100000)

# Hàm tạo đánh giá
def generate_feedback(ma_phieu):
    diem_phuc_vu = random.randint(1, 5)
    diem_vi_tri = random.randint(1, 5)
    diem_chat_luong = random.randint(1, 5)
    diem_gia_ca = random.randint(1, 5)
    diem_khong_gian = random.randint(1, 5)
    binh_luan = "NULL" if random.random() < 0.3 else f"'Bình luận mẫu {random.randint(1, 1000)}'"
    return (f"INSERT INTO DanhGia (MaPhieu, DiemPhucVu, DiemViTri, DiemChatLuong, DiemGiaCa, DiemKhongGian, BinhLuan) "
            f"VALUES ({ma_phieu}, {diem_phuc_vu}, {diem_vi_tri}, {diem_chat_luong}, {diem_gia_ca}, {diem_khong_gian}, {binh_luan});\n")

# Hàm tạo dữ liệu đánh giá cho từng phiếu đặt món
def generate_feedback_data(file_name, total_phieu):
    try:
        with open(file_name, "w", encoding="utf-8") as file:
            file.write("-- Dữ liệu bảng DanhGia\n")
            for ma_phieu in range(1, total_phieu + 1):
                file.write(generate_feedback(ma_phieu))
            print(f"Tạo dữ liệu đánh giá thành công, lưu vào {file_name}!")
    except Exception as e:
        print(f"Lỗi khi tạo dữ liệu: {e}")

# Gọi hàm tạo dữ liệu đánh giá
output_file = "insert_danhgia.sql"
total_phieu_dat_mon = 100000  # Tổng số phiếu đặt món
generate_feedback_data(output_file, total_phieu_dat_mon)
