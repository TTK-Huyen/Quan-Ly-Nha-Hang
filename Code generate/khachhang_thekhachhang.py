import random
from datetime import datetime, timedelta

# Hàm tạo SoCCCD duy nhất
def generate_unique_sosccd(existing_sosccd):
    while True:
        sosccd = f"123456{random.randint(100000, 999999):06d}"
        if sosccd not in existing_sosccd:
            existing_sosccd.add(sosccd)
            return sosccd

# Hàm tạo số điện thoại duy nhất
def generate_unique_phone(existing_phones):
    while True:
        phone = f"098{random.randint(1000000, 9999999):07d}"
        if phone not in existing_phones:
            existing_phones.add(phone)
            return phone

# Hàm tạo email duy nhất
def generate_unique_email(existing_emails, name):
    domains = ["gmail.com", "yahoo.com", "hotmail.com"]
    while True:
        email = f"{name.replace(' ', '.').lower()}.{random.randint(1, 9999)}@{random.choice(domains)}"
        if email not in existing_emails:
            existing_emails.add(email)
            return email

# Hàm tạo dữ liệu SQL cho KhachHang và TheKhachHang
def generate_combined_sql_files(khachhang_file, thekhachhang_file, total_records=100000):
    try:
        existing_sosccd = set()
        existing_phones = set()
        existing_emails = set()

        genders = ["Nam", "Nu"]
        first_names = ["Nguyen", "Tran", "Le", "Pham", "Hoang"]
        middle_names = ["Van", "Thi", "Minh", "Quoc", "Thu"]
        last_names = ["Anh", "Binh", "Chau", "Dung", "Giang", "Phuc"]

        with open(khachhang_file, mode='w', encoding='utf-8') as kh_file, open(thekhachhang_file, mode='w', encoding='utf-8') as th_file:
            kh_file.write("-- Tạo dữ liệu bảng KhachHang\n")
            th_file.write("-- Tạo dữ liệu bảng TheKhachHang\n")

            for _ in range(1, total_records):
                first_name = random.choice(first_names)
                middle_name = random.choice(middle_names)
                last_name = random.choice(last_names)
                name = f"{first_name} {middle_name} {last_name}"

                sosccd = generate_unique_sosccd(existing_sosccd)
                phone = generate_unique_phone(existing_phones)
                email = generate_unique_email(existing_emails, name)
                gender = random.choice(genders)

                # Tạo dữ liệu KhachHang
                kh_sql = f"INSERT INTO KhachHang (SoCCCD, SoDienThoai, Email, HoTen, GioiTinh) VALUES ('{sosccd}', '{phone}', '{email}', '{name}', '{gender}');\n"
                kh_file.write(kh_sql)

                # Tạo dữ liệu TheKhachHang
                ngay_lap = datetime.now() - timedelta(days=random.randint(0, 365))
                nhan_vien_lap = f"NV{random.randint(1, 501):04d}"
                ngay_dat_the = ngay_lap + timedelta(days=random.randint(0, 30))
                th_sql = f"INSERT INTO TheKhachHang (MaSoThe, SoDienThoai, NgayLap, NhanVienLap, NgayDatThe) VALUES ('{_}', '{phone}', '{ngay_lap.strftime('%Y-%m-%d %H:%M:%S')}', '{nhan_vien_lap}', '{ngay_dat_the.strftime('%Y-%m-%d %H:%M:%S')}');\n"
                th_file.write(th_sql)

                if _ % 10000 == 0 and _ > 0:
                    print(f"Đã tạo {_} dòng dữ liệu...")

        print(f"Tạo thành công {total_records} dòng dữ liệu cho KhachHang và TheKhachHang!")
    except Exception as e:
        print(f"Lỗi khi tạo dữ liệu: {e}")

# Gọi hàm tạo dữ liệu
khachhang_output = "insert_khachhang.sql"
thekhachhang_output = "insert_thekhachhang.sql"
generate_combined_sql_files(khachhang_output, thekhachhang_output)
