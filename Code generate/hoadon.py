# Tạo file chứa các lệnh EXEC TaoHoaDon

def generate_exec_taohoadon(output_file, start_id=1, end_id=100000):
    try:
        with open(output_file, mode="w", encoding="utf-8") as file:
            file.write("-- File chứa các lệnh EXEC TaoHoaDon\n")

            for i in range(start_id, end_id + 1):
                file.write(f"EXEC TaoHoaDon {i};\n")

            print(f"Tạo thành công file {output_file} với {end_id - start_id + 1} lệnh EXEC TaoHoaDon.")
    except Exception as e:
        print(f"Lỗi khi tạo file: {e}")

# Gọi hàm tạo file
output_file = "exec_taohoadon.sql"
generate_exec_taohoadon(output_file)
