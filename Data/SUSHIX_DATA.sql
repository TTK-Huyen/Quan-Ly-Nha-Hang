USE QLNHAHANG

--Thêm data bảng BoPhan
INSERT INTO BoPhan (MaBoPhan, TenBoPhan) VALUES ('BP01', N'Bộ phận Bếp');
INSERT INTO BoPhan (MaBoPhan, TenBoPhan) VALUES ('BP02', N'Bộ phận Lễ tân');
INSERT INTO BoPhan (MaBoPhan, TenBoPhan) VALUES ('BP03', N'Bộ phận Phục vụ bàn');
INSERT INTO BoPhan (MaBoPhan, TenBoPhan) VALUES ('BP04', N'Bộ phận Thu ngân');
INSERT INTO BoPhan (MaBoPhan, TenBoPhan) VALUES ('BP05', N'Bộ phận Quản lý');
INSERT INTO BoPhan (MaBoPhan, TenBoPhan) VALUES ('BP06', N'Bộ phận Tạp vụ');
INSERT INTO BoPhan (MaBoPhan, TenBoPhan) VALUES ('BP07', N'Bộ phận Quầy bar');
INSERT INTO BoPhan (MaBoPhan, TenBoPhan) VALUES ('BP08', N'Bộ phận Kho vận');
INSERT INTO BoPhan (MaBoPhan, TenBoPhan) VALUES ('BP09', N'Bộ phận Chăm sóc khách hàng');
INSERT INTO BoPhan (MaBoPhan, TenBoPhan) VALUES ('BP10', N'Bộ phận Hành chính');




--Thêm data bảng KhuVuc
INSERT INTO KhuVuc (MaKhuVuc, TenKhuVuc) VALUES (1, N'Hồ Chí Minh');
INSERT INTO KhuVuc (MaKhuVuc, TenKhuVuc) VALUES (2, N'Hà Nội');
INSERT INTO KhuVuc (MaKhuVuc, TenKhuVuc) VALUES (3, N'Đà Nẵng');
INSERT INTO KhuVuc (MaKhuVuc, TenKhuVuc) VALUES (4, N'Hải Phòng');
INSERT INTO KhuVuc (MaKhuVuc, TenKhuVuc) VALUES (5, N'Cần Thơ');
INSERT INTO KhuVuc (MaKhuVuc, TenKhuVuc) VALUES (6, N'Vũng Tàu');



--Thêm data bảng ChiNhanh
INSERT INTO ChiNhanh (MaChiNhanh, TenChiNhanh, DiaChi, ThoiGianMoCua, ThoiGianDongCua, SoDienThoai, BaiDoXeHoi, BaiDoXeMay, NhanVienQuanLy, MaKhuVuc, GiaoHang) VALUES (1, N'Chi Nhánh 1', N'123 Lê Lợi, Quận 1', '08:00:00', '22:00:00', '0507390754', 1, 0, NULL, 3, 0);
INSERT INTO ChiNhanh (MaChiNhanh, TenChiNhanh, DiaChi, ThoiGianMoCua, ThoiGianDongCua, SoDienThoai, BaiDoXeHoi, BaiDoXeMay, NhanVienQuanLy, MaKhuVuc, GiaoHang) VALUES (2, N'Chi Nhánh 2', N'456 Nguyễn Trãi, Quận 5', '08:00:00', '22:00:00', '0646740590', 0, 0, NULL, 6, 1);
INSERT INTO ChiNhanh (MaChiNhanh, TenChiNhanh, DiaChi, ThoiGianMoCua, ThoiGianDongCua, SoDienThoai, BaiDoXeHoi, BaiDoXeMay, NhanVienQuanLy, MaKhuVuc, GiaoHang) VALUES (3, N'Chi Nhánh 3', N'789 Hà Nội, Quận 3', '08:00:00', '22:00:00', '0982027393', 0, 1, NULL, 1, 0);
INSERT INTO ChiNhanh (MaChiNhanh, TenChiNhanh, DiaChi, ThoiGianMoCua, ThoiGianDongCua, SoDienThoai, BaiDoXeHoi, BaiDoXeMay, NhanVienQuanLy, MaKhuVuc, GiaoHang) VALUES (4, N'Chi Nhánh 4', N'12 Nguyễn Du, Quận 1', '08:00:00', '22:00:00', '0977972265', 1, 1, NULL, 6, 1);
INSERT INTO ChiNhanh (MaChiNhanh, TenChiNhanh, DiaChi, ThoiGianMoCua, ThoiGianDongCua, SoDienThoai, BaiDoXeHoi, BaiDoXeMay, NhanVienQuanLy, MaKhuVuc, GiaoHang) VALUES (5, N'Chi Nhánh 5', N'56 Lý Thường Kiệt, Quận 10', '08:00:00', '22:00:00', '0814330690', 1, 0, NULL, 4, 0);
INSERT INTO ChiNhanh (MaChiNhanh, TenChiNhanh, DiaChi, ThoiGianMoCua, ThoiGianDongCua, SoDienThoai, BaiDoXeHoi, BaiDoXeMay, NhanVienQuanLy, MaKhuVuc, GiaoHang) VALUES (6, N'Chi Nhánh 6', N'34 Trần Hưng Đạo, Quận 1', '08:00:00', '22:00:00', '0171756309', 0, 1, NULL, 6, 1);
INSERT INTO ChiNhanh (MaChiNhanh, TenChiNhanh, DiaChi, ThoiGianMoCua, ThoiGianDongCua, SoDienThoai, BaiDoXeHoi, BaiDoXeMay, NhanVienQuanLy, MaKhuVuc, GiaoHang) VALUES (7, N'Chi Nhánh 7', N'98 Lê Văn Sỹ, Quận 3', '08:00:00', '22:00:00', '0621825994', 1, 0, NULL, 5, 0);
INSERT INTO ChiNhanh (MaChiNhanh, TenChiNhanh, DiaChi, ThoiGianMoCua, ThoiGianDongCua, SoDienThoai, BaiDoXeHoi, BaiDoXeMay, NhanVienQuanLy, MaKhuVuc, GiaoHang) VALUES (8, N'Chi Nhánh 8', N'2 Nguyễn Thị Minh Khai, Quận 1', '08:00:00', '22:00:00', '0181690805', 0, 1, NULL, 3, 0);
INSERT INTO ChiNhanh (MaChiNhanh, TenChiNhanh, DiaChi, ThoiGianMoCua, ThoiGianDongCua, SoDienThoai, BaiDoXeHoi, BaiDoXeMay, NhanVienQuanLy, MaKhuVuc, GiaoHang) VALUES (9, N'Chi Nhánh 9', N'101 Cộng Hòa, Tân Bình', '08:00:00', '22:00:00', '0677018293', 1, 1, NULL, 2, 1);
INSERT INTO ChiNhanh (MaChiNhanh, TenChiNhanh, DiaChi, ThoiGianMoCua, ThoiGianDongCua, SoDienThoai, BaiDoXeHoi, BaiDoXeMay, NhanVienQuanLy, MaKhuVuc, GiaoHang) VALUES (10, N'Chi Nhánh 10', N'150 Phan Xích Long, Phú Nhuận', '08:00:00', '22:00:00', '0669598958', 0, 0, NULL, 1, 1);
INSERT INTO ChiNhanh (MaChiNhanh, TenChiNhanh, DiaChi, ThoiGianMoCua, ThoiGianDongCua, SoDienThoai, BaiDoXeHoi, BaiDoXeMay, NhanVienQuanLy, MaKhuVuc, GiaoHang) VALUES (11, N'Chi Nhánh 11', N'300 Đường Láng, Quận Đống Đa', '08:00:00', '22:00:00', '0682773362', 0, 1, NULL, 3, 0);
INSERT INTO ChiNhanh (MaChiNhanh, TenChiNhanh, DiaChi, ThoiGianMoCua, ThoiGianDongCua, SoDienThoai, BaiDoXeHoi, BaiDoXeMay, NhanVienQuanLy, MaKhuVuc, GiaoHang) VALUES (12, N'Chi Nhánh 12', N'450 Phạm Văn Đồng, Cầu Giấy', '08:00:00', '22:00:00', '0988564246', 0, 0, NULL, 2, 1);
INSERT INTO ChiNhanh (MaChiNhanh, TenChiNhanh, DiaChi, ThoiGianMoCua, ThoiGianDongCua, SoDienThoai, BaiDoXeHoi, BaiDoXeMay, NhanVienQuanLy, MaKhuVuc, GiaoHang) VALUES (13, N'Chi Nhánh 13', N'100 Nguyễn Hoàng, Quận Nam Từ Liêm', '08:00:00', '22:00:00', '0426806530', 1, 1, NULL, 6, 0);
INSERT INTO ChiNhanh (MaChiNhanh, TenChiNhanh, DiaChi, ThoiGianMoCua, ThoiGianDongCua, SoDienThoai, BaiDoXeHoi, BaiDoXeMay, NhanVienQuanLy, MaKhuVuc, GiaoHang) VALUES (14, N'Chi Nhánh 14', N'25 Lê Đức Thọ, Mỹ Đình', '08:00:00', '22:00:00', '0914460242', 1, 0, NULL, 4, 0);
INSERT INTO ChiNhanh (MaChiNhanh, TenChiNhanh, DiaChi, ThoiGianMoCua, ThoiGianDongCua, SoDienThoai, BaiDoXeHoi, BaiDoXeMay, NhanVienQuanLy, MaKhuVuc, GiaoHang) VALUES (15, N'Chi Nhánh 15', N'1 Đại Cồ Việt, Hai Bà Trưng', '08:00:00', '22:00:00', '0298534272', 0, 1, NULL, 4, 0);

SELECT* FROM NhanVien


--Thêm data bảng nhân viên bằng sp
EXEC THEMNV N'Stephen Walsh', '1998-06-02', N'Nam', 12000000, '2023-09-09', 'BP02', 12;
EXEC THEMNV N'Jimmy Navarro', '1980-11-23', N'Nam', 12000000, '2022-05-05', 'BP02', 7;
EXEC THEMNV N'Kelsey Oneal', '1996-07-10', N'Nam', 17000000, '2021-06-18', 'BP07', 11;
EXEC THEMNV N'Patty Frederick', '1970-06-03', N'Nam', 13000000, '2021-02-13', 'BP08', 5;
EXEC THEMNV N'Linda Cook', '1980-05-20', N'Nam', 8000000, '2024-05-23', 'BP06', 14;
EXEC THEMNV N'Brian Cox', '1985-11-30', N'Nữ', 15000000, '2023-09-10', 'BP01', 10;
EXEC THEMNV N'Aaron Boyd', '1973-03-02', N'Nam', 15000000, '2021-07-13', 'BP01', 8;
EXEC THEMNV N'Melissa Wiley', '2001-04-18', N'Nam', 14000000, '2020-08-31', 'BP04', 8;
EXEC THEMNV N'Chad Graves', '2001-06-26', N'Nữ', 12000000, '2023-01-31', 'BP02', 10;
EXEC THEMNV N'Robert Morgan', '1963-12-28', N'Nữ', 16000000, '2020-11-02', 'BP10', 15;
EXEC THEMNV N'Theresa Landry', '1987-06-23', N'Nữ', 17000000, '2022-11-03', 'BP07', 9;
EXEC THEMNV N'Theodore Davis', '1994-04-03', N'Nữ', 16000000, '2022-10-07', 'BP10', 15;
EXEC THEMNV N'Adrian Palmer', '1969-07-27', N'Nam', 15000000, '2020-05-13', 'BP01', 1;
EXEC THEMNV N'Joshua Lawson', '1974-12-31', N'Nữ', 17000000, '2020-06-29', 'BP07', 15;
EXEC THEMNV N'Stephanie Scott', '1968-12-26', N'Nữ', 14000000, '2024-11-15', 'BP04', 10;
EXEC THEMNV N'Christina Bush', '1971-02-08', N'Nữ', 15000000, '2023-12-01', 'BP01', 13;
EXEC THEMNV N'Kenneth Hernandez', '1996-03-29', N'Nữ', 12000000, '2024-02-03', 'BP02', 10;
EXEC THEMNV N'Patrick Wilkerson Jr.', '1996-09-28', N'Nam', 12000000, '2023-10-22', 'BP02', 5;
EXEC THEMNV N'Jared Harris', '2002-08-11', N'Nam', 10000000, '2023-03-28', 'BP03', 4;
EXEC THEMNV N'Jessica Glass', '1996-01-08', N'Nữ', 16000000, '2022-11-25', 'BP10', 10;
EXEC THEMNV N'Steven Foster', '1983-01-01', N'Nam', 8000000, '2021-02-17', 'BP06', 15;
EXEC THEMNV N'Susan Lawrence', '1990-05-11', N'Nữ', 16000000, '2020-08-02', 'BP10', 4;
EXEC THEMNV N'Brittany Powell', '1971-02-16', N'Nữ', 10000000, '2020-05-26', 'BP03', 9;
EXEC THEMNV N'Stephanie Graham', '1982-03-07', N'Nữ', 12000000, '2020-04-04', 'BP02', 5;
EXEC THEMNV N'Douglas Garrison', '1965-05-05', N'Nam', 8000000, '2021-04-21', 'BP06', 7;
EXEC THEMNV N'Renee Berry', '1977-03-17', N'Nữ', 11000000, '2021-09-18', 'BP09', 15;
EXEC THEMNV N'Andrew Perez', '1988-11-26', N'Nam', 15000000, '2024-04-17', 'BP01', 2;
EXEC THEMNV N'Mindy Williams', '1965-09-16', N'Nữ', 8000000, '2021-01-03', 'BP06', 13;
EXEC THEMNV N'Jeremy Castaneda', '1989-11-06', N'Nữ', 8000000, '2020-11-04', 'BP06', 10;
EXEC THEMNV N'Jenna Smith', '1973-07-10', N'Nữ', 8000000, '2024-02-02', 'BP06', 1;
EXEC THEMNV N'Holly Zimmerman', '1970-01-25', N'Nam', 17000000, '2022-04-26', 'BP07', 8;
EXEC THEMNV N'Harry Cowan', '1984-05-17', N'Nam', 11000000, '2024-09-05', 'BP09', 9;
EXEC THEMNV N'Tracy Johnson', '1965-08-25', N'Nam', 20000000, '2024-11-05', 'BP05', 3;
EXEC THEMNV N'Angela Perez', '1990-05-26', N'Nam', 8000000, '2021-10-09', 'BP06', 6;
EXEC THEMNV N'Kathy Little', '1976-11-28', N'Nữ', 10000000, '2020-01-31', 'BP03', 5;
EXEC THEMNV N'Jeremiah Stevens', '1983-01-24', N'Nam', 17000000, '2024-06-11', 'BP07', 2;
EXEC THEMNV N'Ryan Sanford', '1984-06-26', N'Nam', 13000000, '2021-02-07', 'BP08', 3;
EXEC THEMNV N'Larry Wright', '1966-10-13', N'Nam', 10000000, '2021-11-01', 'BP03', 5;
EXEC THEMNV N'John Johnson', '1977-11-30', N'Nữ', 13000000, '2020-01-11', 'BP08', 6;
EXEC THEMNV N'Paul Dixon', '1972-01-15', N'Nữ', 20000000, '2024-02-07', 'BP05', 3;
EXEC THEMNV N'Deborah Fitzgerald', '2000-07-10', N'Nam', 16000000, '2021-09-17', 'BP10', 15;
EXEC THEMNV N'Erin Davidson', '1979-06-05', N'Nữ', 16000000, '2022-11-28', 'BP10', 9;
EXEC THEMNV N'Christopher Scott', '1983-06-23', N'Nam', 11000000, '2021-03-25', 'BP09', 2;
EXEC THEMNV N'Michael Hansen', '1998-06-14', N'Nữ', 17000000, '2020-07-21', 'BP07', 10;
EXEC THEMNV N'Scott Juarez', '1983-01-23', N'Nữ', 11000000, '2020-08-31', 'BP09', 9;
EXEC THEMNV N'Jennifer Ferrell', '1969-09-08', N'Nữ', 16000000, '2020-05-28', 'BP10', 11;
EXEC THEMNV N'Alexander Jones', '1972-05-13', N'Nữ', 12000000, '2022-10-16', 'BP02', 2;
EXEC THEMNV N'Tammy Flores', '1995-04-01', N'Nữ', 17000000, '2020-09-29', 'BP07', 7;
EXEC THEMNV N'Brett Lopez', '1997-02-28', N'Nữ', 20000000, '2022-03-08', 'BP05', 14;
EXEC THEMNV N'Ronald Ramirez', '1975-11-16', N'Nam', 12000000, '2022-08-03', 'BP02', 4;
EXEC THEMNV N'Charles Moore', '1978-09-07', N'Nữ', 15000000, '2022-03-04', 'BP01', 2;
EXEC THEMNV N'Madison Ruiz', '1976-07-18', N'Nữ', 11000000, '2020-08-19', 'BP09', 15;
EXEC THEMNV N'Barbara Martinez', '1991-04-14', N'Nữ', 13000000, '2022-02-23', 'BP08', 7;
EXEC THEMNV N'Alicia Hurley', '1976-10-28', N'Nữ', 17000000, '2020-05-08', 'BP07', 4;
EXEC THEMNV N'Johnny Lambert', '1990-11-16', N'Nam', 16000000, '2021-04-05', 'BP10', 10;
EXEC THEMNV N'Eric Horn', '2002-09-20', N'Nữ', 17000000, '2021-12-20', 'BP07', 8;
EXEC THEMNV N'Rebecca Martinez', '1969-07-28', N'Nam', 20000000, '2023-08-24', 'BP05', 12;
EXEC THEMNV N'Alexandra Brown', '2000-10-14', N'Nữ', 15000000, '2020-10-20', 'BP01', 8;
EXEC THEMNV N'Grant Cooper', '1980-09-25', N'Nữ', 20000000, '2020-03-14', 'BP05', 1;
EXEC THEMNV N'Holly Taylor PhD', '1979-12-22', N'Nữ', 14000000, '2023-03-30', 'BP04', 9;
EXEC THEMNV N'Denise Daugherty', '1975-05-05', N'Nữ', 11000000, '2023-12-04', 'BP09', 13;
EXEC THEMNV N'Matthew Stevenson', '1975-01-31', N'Nữ', 10000000, '2023-03-03', 'BP03', 13;
EXEC THEMNV N'Jessica Cantu', '1971-03-27', N'Nam', 17000000, '2024-08-15', 'BP07', 11;
EXEC THEMNV N'Rodney Gutierrez', '2000-10-10', N'Nữ', 15000000, '2022-05-10', 'BP01', 4;
EXEC THEMNV N'Angela Bray MD', '1985-11-12', N'Nam', 16000000, '2022-11-14', 'BP10', 15;
EXEC THEMNV N'Mercedes Davenport', '1993-06-04', N'Nam', 11000000, '2024-04-24', 'BP09', 11;
EXEC THEMNV N'Christopher Larson', '1992-10-05', N'Nữ', 10000000, '2024-02-16', 'BP03', 8;
EXEC THEMNV N'Benjamin Winters', '1966-09-18', N'Nam', 14000000, '2024-11-21', 'BP04', 11;
EXEC THEMNV N'Daniel Avila', '1986-09-19', N'Nam', 13000000, '2021-10-29', 'BP08', 8;
EXEC THEMNV N'Donald Murphy', '2002-01-10', N'Nữ', 16000000, '2023-08-27', 'BP10', 14;
EXEC THEMNV N'Michael Hall', '1975-10-05', N'Nam', 12000000, '2024-03-28', 'BP02', 8;
EXEC THEMNV N'Sara Keller', '1995-08-08', N'Nữ', 12000000, '2023-03-01', 'BP02', 9;
EXEC THEMNV N'Kimberly Huerta', '1976-02-17', N'Nam', 10000000, '2023-11-29', 'BP03', 1;
EXEC THEMNV N'Megan Gregory', '1965-09-19', N'Nam', 14000000, '2023-06-12', 'BP04', 13;
EXEC THEMNV N'Candice Kennedy', '2001-09-04', N'Nam', 8000000, '2021-05-27', 'BP06', 14;
EXEC THEMNV N'Jessica Washington', '1977-01-03', N'Nữ', 17000000, '2024-06-17', 'BP07', 5;
EXEC THEMNV N'Jerry Moore', '1977-10-19', N'Nam', 8000000, '2024-07-09', 'BP06', 6;
EXEC THEMNV N'Mr. Adam Patel', '1974-05-13', N'Nữ', 10000000, '2024-03-28', 'BP03', 4;
EXEC THEMNV N'Christopher Stevens', '1987-06-22', N'Nữ', 12000000, '2023-02-22', 'BP02', 2;
EXEC THEMNV N'Sara Baker', '1980-03-03', N'Nam', 8000000, '2024-04-17', 'BP06', 6;
EXEC THEMNV N'Emma Sanchez', '2001-07-27', N'Nam', 10000000, '2020-10-07', 'BP03', 5;
EXEC THEMNV N'Jonathan Patterson', '1977-04-28', N'Nữ', 14000000, '2021-09-12', 'BP04', 1;
EXEC THEMNV N'Juan Garcia', '1999-05-04', N'Nữ', 20000000, '2020-10-03', 'BP05', 14;
EXEC THEMNV N'Mark Rogers', '1971-11-04', N'Nam', 12000000, '2024-10-05', 'BP02', 6;
EXEC THEMNV N'Jane King', '1965-07-16', N'Nam', 11000000, '2023-04-16', 'BP09', 11;
EXEC THEMNV N'James Dunn', '1976-08-07', N'Nam', 13000000, '2024-09-13', 'BP08', 4;
EXEC THEMNV N'Jennifer Carey', '1983-09-20', N'Nữ', 12000000, '2020-11-15', 'BP02', 15;
EXEC THEMNV N'Timothy Sullivan', '1966-05-12', N'Nữ', 13000000, '2021-11-22', 'BP08', 7;
EXEC THEMNV N'Ryan Sullivan', '1965-04-21', N'Nữ', 13000000, '2022-11-17', 'BP08', 11;
EXEC THEMNV N'John Rhodes', '1966-02-05', N'Nữ', 20000000, '2022-08-28', 'BP05', 5;
EXEC THEMNV N'Emma Mann DDS', '1974-12-13', N'Nữ', 13000000, '2020-01-09', 'BP08', 10;
EXEC THEMNV N'Lisa Price', '1984-02-25', N'Nam', 13000000, '2021-05-02', 'BP08', 7;
EXEC THEMNV N'Angela Bailey', '1969-05-04', N'Nữ', 15000000, '2024-04-21', 'BP01', 12;
EXEC THEMNV N'Karen Stone', '1976-05-30', N'Nữ', 17000000, '2023-10-20', 'BP07', 13;
EXEC THEMNV N'Ryan Young', '1996-03-15', N'Nữ', 17000000, '2023-09-19', 'BP07', 3;
EXEC THEMNV N'Miranda Gates', '1993-05-18', N'Nam', 17000000, '2021-03-04', 'BP07', 7;
EXEC THEMNV N'Evan Jones', '1986-05-19', N'Nam', 11000000, '2020-08-10', 'BP09', 6;
EXEC THEMNV N'Mary Jones', '1964-04-18', N'Nam', 13000000, '2021-02-17', 'BP08', 1;
EXEC THEMNV N'Jennifer Brown', '1968-03-23', N'Nam', 14000000, '2021-08-08', 'BP04', 5;
EXEC THEMNV N'Timothy Cross', '1992-03-26', N'Nữ', 11000000, '2020-11-03', 'BP09', 12;
EXEC THEMNV N'Paul Smith', '1973-06-05', N'Nữ', 11000000, '2021-07-06', 'BP09', 15;
EXEC THEMNV N'Amber Conley', '1994-05-18', N'Nữ', 20000000, '2021-04-15', 'BP05', 11;
EXEC THEMNV N'Joseph Gordon', '1988-11-05', N'Nữ', 13000000, '2022-08-20', 'BP08', 10;
EXEC THEMNV N'Kristina Robinson', '1974-02-25', N'Nam', 12000000, '2021-02-07', 'BP02', 14;
EXEC THEMNV N'Jessica Mason', '1997-08-09', N'Nam', 13000000, '2023-03-28', 'BP08', 10;
EXEC THEMNV N'Charles Miller', '1972-09-07', N'Nữ', 17000000, '2021-08-27', 'BP07', 6;
EXEC THEMNV N'Judy Perkins', '1985-07-13', N'Nữ', 14000000, '2022-10-21', 'BP04', 4;
EXEC THEMNV N'Briana Williams', '1976-07-20', N'Nữ', 11000000, '2024-08-09', 'BP09', 2;
EXEC THEMNV N'Steven Dodson', '1968-07-28', N'Nữ', 14000000, '2024-10-13', 'BP04', 13;
EXEC THEMNV N'Daniel Phillips', '1984-02-10', N'Nam', 20000000, '2022-02-16', 'BP05', 9;
EXEC THEMNV N'Cody Phillips', '1993-08-18', N'Nam', 13000000, '2020-12-04', 'BP08', 2;
EXEC THEMNV N'Ryan Smith', '1998-05-31', N'Nam', 12000000, '2023-04-12', 'BP02', 7;
EXEC THEMNV N'Michelle Sosa', '1964-11-22', N'Nữ', 20000000, '2023-05-13', 'BP05', 9;
EXEC THEMNV N'Rebecca Collins', '1991-05-19', N'Nam', 20000000, '2020-01-19', 'BP05', 9;
EXEC THEMNV N'Jill George', '1977-03-07', N'Nam', 8000000, '2024-06-03', 'BP06', 11;
EXEC THEMNV N'Richard Perkins', '1969-09-26', N'Nữ', 10000000, '2024-11-09', 'BP03', 1;
EXEC THEMNV N'Lawrence Lambert', '1980-12-25', N'Nam', 8000000, '2024-10-01', 'BP06', 12;
EXEC THEMNV N'Melissa Leon', '1988-03-12', N'Nữ', 13000000, '2020-10-11', 'BP08', 5;
EXEC THEMNV N'Michael Ortiz', '1986-10-16', N'Nam', 11000000, '2023-05-15', 'BP09', 1;
EXEC THEMNV N'Jason Black', '1975-01-10', N'Nam', 17000000, '2024-08-15', 'BP07', 14;





