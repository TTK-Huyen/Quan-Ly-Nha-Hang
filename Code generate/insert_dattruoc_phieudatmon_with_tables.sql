import random
from datetime import datetime, timedelta

# Hàm tạo số điện thoại ngẫu nhiên
def generate_random_phone(existing_phones):
    while True:
        phone = f"098{random.randint(1000000, 9999999):07d}"
        if phone not in existing_phones:
            existing_phones.add(phone)
            return phone

# Hàm tìm bàn phù hợp
def find_table_or_null(so_luong_khach, chi_nhanh, existing_tables):
    # Tìm bàn phù hợp
    for table in existing_tables:
        if table["ChiNhanh"] == chi_nhanh and table["SucChua"] >= so_luong_khach:
            return table["MaBan"]
    return None  # Không tìm thấy bàn phù hợp

# Hàm tạo phiếu đặt món
def generate_phieu_dat_mon(ma_ban, so_dien_thoai, gio_den):
    ngay_lap = gio_den + timedelta(hours=1)  # Ngày lập là 1 giờ sau giờ đến
    nhan_vien_lap = f"NV{random.randint(1, 5):04d}" if random.random() > 0.5 else "NULL"
    ma_ban_value = "NULL" if ma_ban is None else ma_ban
    return f"INSERT INTO PhieuDatMon (MaBan, SoDienThoai, NgayLap, NhanVienLap) VALUES ({ma_ban_value}, '{so_dien_thoai}', '{ngay_lap.strftime('%Y-%m-%d %H:%M:%S')}', {nhan_vien_lap});\n"

# Hàm tạo chi tiết phiếu
def generate_chi_tiet_phieu(ma_phieu):
    so_mon = random.randint(5, 10)  # Số món trong phiếu
    chi_tiet = []
    for _ in range(so_mon):
        ma_mon = random.randint(1, 33)
        so_luong = random.randint(1, 5)
        ghi_chu = "NULL" if random.random() > 0.7 else f"'Note {random.randint(1, 100)}'"
        chi_tiet.append(f"INSERT INTO ChiTietPhieu (MaPhieu, MaMon, SoLuong, GhiChu) VALUES ({ma_phieu}, {ma_mon}, {so_luong}, {ghi_chu});\n")
    return ''.join(chi_tiet)

# Hàm tạo dữ liệu DatTruoc và liên kết với các bảng khác
def generate_data_with_reservations(output_file, total_reservations=100000):
    try:
        existing_phones = set()
        existing_tables = [
            {"MaBan": i + 1, "ChiNhanh": (i // 40) + 1, "SucChua": random.randint(2, 10)}
            for i in range(600)  # 40 bàn cho mỗi chi nhánh, tổng cộng 15 chi nhánh
        ]

        with open(output_file, mode="w", encoding="utf-8") as file:
            file.write("-- Dữ liệu bảng DatTruoc, PhieuDatMon và ChiTietPhieu\n")

            for ma_dat_truoc in range(1, total_reservations + 1):
                # Tạo dữ liệu đặt trước
                so_dien_thoai = generate_random_phone(existing_phones)
                ngay_dat = datetime.now() - timedelta(days=random.randint(0, 365))
                gio_den = ngay_dat + timedelta(hours=random.randint(1, 12))
                ghi_chu = "NULL" if random.random() > 0.7 else f"'Note {random.randint(1, 100)}'"
                chi_nhanh = random.randint(1, 15)
                so_luong_khach = random.randint(1, 10)

                sql_dat_truoc = (
                    f"INSERT INTO DatTruoc (SoDienThoai, NgayDat, GioDen, GhiChu, ChiNhanh, SoLuongKhach) "
                    f"VALUES ('{so_dien_thoai}', '{ngay_dat.strftime('%Y-%m-%d %H:%M:%S')}', "
                    f"'{gio_den.strftime('%Y-%m-%d %H:%M:%S')}', {ghi_chu}, {chi_nhanh}, {so_luong_khach});\n"
                )
                file.write(sql_dat_truoc)

                # Tìm bàn phù hợp
                ma_ban = find_table_or_null(so_luong_khach, chi_nhanh, existing_tables)

                # Tạo phiếu đặt món
                phieu_sql = generate_phieu_dat_mon(ma_ban, so_dien_thoai, gio_den)
                file.write(phieu_sql)

                # Tạo chi tiết phiếu đặt món
                chi_tiet_sql = generate_chi_tiet_phieu(ma_dat_truoc)
                file.write(chi_tiet_sql)

            print(f"Tạo thành công {total_reservations} dòng dữ liệu đặt trước và liên kết, lưu vào {output_file}!")
    except Exception as e:
        print(f"Lỗi khi tạo dữ liệu: {e}")

# Gọi hàm tạo dữ liệu
output_file = "insert_dattruoc_phieudatmon_null_tables.sql"
generate_data_with_reservations(output_file)
