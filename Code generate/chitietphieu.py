import random

# Đường dẫn file output
output_file = "insert_chitietphieu.sql"

# Dải giá trị MaPhieu và MaMon
ma_phieu_range = range(1, 100000)  # MaPhieu từ 1 đến 100000
ma_mon_pool = list(range(1, 34))   # MaMon từ 1 đến 33

# Danh sách các ghi chú ngẫu nhiên
ghi_chu_list = [
    "Đựng trong hộp mang về.",
    "Thêm đá.",
    "Không thêm đường.",
    "Thêm nước sốt.",
    "Gói riêng từng phần.",
    "Không hành.",
    "Ít cay.",
    "Mang ra nhanh nhất có thể.",
    "Không sử dụng hải sản.",
    "Dùng bát lớn."
]

# Tạo file SQL
with open(output_file, "w", encoding="utf-8") as file:
    file.write("-- File generated SQL for inserting MaPhieu and MaMon into ChiTietPhieu\n")
    
    for ma_phieu in ma_phieu_range:
        # Lấy ngẫu nhiên 5-10 món từ danh sách 10 món
        selected_ma_mon = random.sample(ma_mon_pool, random.randint(1,2))
        
        for ma_mon in selected_ma_mon:
            so_luong = random.randint(1, 10)  # Số lượng từ 1 đến 10
            ghi_chu = f"N'{random.choice(ghi_chu_list)}'" if random.random() > 0.5 else "NULL"  # 50% có ghi chú
            
            sql = f"INSERT INTO ChiTietPhieu (MaPhieu, MaMon, SoLuong, GhiChu) " \
                  f"VALUES ({ma_phieu}, {ma_mon}, {so_luong}, {ghi_chu});\n"
            file.write(sql)

print(f"File {output_file} đã được tạo thành công với các dòng INSERT.")
