import random

# Function to generate random Vietnamese names
def generate_name():
    first_names = ["Nguyen", "Tran", "Le", "Pham", "Hoang", "Phan", "Vu", "Dang", "Do", "Bui"]
    middle_names = ["Van", "Thi", "Ngoc", "Quoc", "Minh", "Bao", "Duy", "Huu", "Thanh", "Anh"]
    last_names = ["Anh", "Binh", "Duy", "Phuc", "Nam", "Ha", "Linh", "Son", "Trang", "Huong"]
    return f"{random.choice(first_names)} {random.choice(middle_names)} {random.choice(last_names)}"

# Function to generate a random phone number
def generate_phone():
    prefix = random.choice(["091", "090", "092", "093", "096", "097", "098"])
    return f"{prefix}{random.randint(1000000, 9999999)}"

# Function to generate random email
def generate_email(name):
    email_providers = ["@gmail.com", "@yahoo.com", "@example.com", "@hotmail.com"]
    name_part = name.lower().replace(" ", ".")
    return f"{name_part}{random.choice(email_providers)}"

# Function to generate gender
def generate_gender():
    return random.choice(["Nam", "Nữ", "Khác"])

# Generate SQL statements for 100,000 customers
output_file = "insert_khachhang_100k_corrected.sql"
with open(output_file, "w", encoding="utf-8") as file:
    for i in range(1, 100001):
        so_cccd = f"123456{str(i).zfill(6)}"  # Ensure exactly 12 digits
        name = generate_name()
        phone = generate_phone()
        email = generate_email(name)
        gender = generate_gender()

        # Write the SQL insert statement to the file
        file.write(
            f"INSERT INTO KhachHang (SoCCCD, SoDienThoai, Email, HoTen, GioiTinh) VALUES ('{so_cccd}', '{phone}', '{email}', '{name}', '{gender}');\n"
        )

print(f"File '{output_file}' has been created with 100,000 records.")