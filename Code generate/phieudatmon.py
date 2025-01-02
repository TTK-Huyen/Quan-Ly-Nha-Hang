import random
from datetime import datetime, timedelta

# Hàm tạo số điện thoại ngẫu nhiên
def generate_random_phone(existing_phones):
    while True:
        phone = f"098{random.randint(1000000, 9999999):07d}"
        if phone not in existing_phones:
            existing_phones.add(phone)
            return phone

# Hàm tạo dữ liệu SQL cho PhieuDatMon và DanhGia
def generate_phieudatmon_and_danhgia(phieudatmon_file, danhgia_file, total_records=100000):
    try:
        existing_phones = set()

        with open(phieudatmon_file, mode="w", encoding="utf-8") as pdm_file, open(
            danhgia_file, mode="w", encoding="utf-8"
        ) as dg_file:
            pdm_file.write("-- Tạo dữ liệu bảng PhieuDatMon\n")
            dg_file.write("-- Tạo dữ liệu bảng DanhGia\n")

            for i in range(total_records):
                # Tạo số điện thoại ngẫu nhiên
                phone = generate_random_phone(existing_phones)

                # Tạo dữ liệu cho PhieuDatMon
                ngay_lap = datetime.now() - timedelta(days=random.randint(0, 365))
                nhan_vien_lap = f"NV{random.randint(1, 100):03d}"
                ngay_dat_the = ngay_lap + timedelta(hours=random.randint(1, 24))

                pdm_sql = f"INSERT INTO PhieuDatMon (SoDienThoai, NgayLap, NhanVienLap, NgayDatThe) VALUES ('{phone}', '{ngay_lap.strftime('%Y-%m-%d %H:%M:%S')}', '{nhan_vien_lap}', '{ngay_dat_the.strftime('%Y-%m-%d %H:%M:%S')}');\n"
                pdm_file.write(pdm_sql)

                # Tạo dữ liệu cho DanhGia
                diem_phuc_vu = random.randint(1, 5)
                diem_vi_tri = random.randint(1, 5)
                diem_chat_luong = random.randint(1, 5)
                diem_gia_ca = random.randint(1, 5)
                diem_khong_gian = random.randint(1, 5)
                binh_luan = random.choice(
                    ["Tuyệt vời!", "Bình thường", "Cần cải thiện", None]
                )

                dg_sql = f"INSERT INTO DanhGia (MaPhieu, DiemPhucVu, DiemViTri, DiemChatLuong, DiemGiaCa, DiemKhongGian, BinhLuan) VALUES ({i+1}, {diem_phuc_vu}, {diem_vi_tri}, {diem_chat_luong}, {diem_gia_ca}, {diem_khong_gian}, {f'NULL' if not binh_luan else repr(binh_luan)});\n"
                dg_file.write(dg_sql)

                if i % 10000 == 0 and i > 0:
                    print(f"Đã tạo {i} dòng dữ liệu...")

        print(f"Tạo thành công dữ liệu cho PhieuDatMon và DanhGia!")
    except Exception as e:
        print(f"Lỗi khi tạo dữ liệu: {e}")

# Gọi hàm tạo dữ liệu
phieudatmon_file = "insert_phieudatmon.sql"
danhgia_file = "insert_danhgia.sql"

generate_phieudatmon_and_danhgia(phieudatmon_file, danhgia_file)
