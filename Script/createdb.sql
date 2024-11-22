-- Tạo bảng 

-- phân hệ chi nhánh
-- phân hệ khách hàng

CREATE TABLE Ban (
    MaSoBan INT PRIMARY KEY,
    MaChiNhanh INT,
    TrangThai BIT CHECK (TrangThai IN (0, 1)),  -- 0: Trống, 1: Đang sử dụng
    SucChua INT CHECK (SucChua > 0),
    FOREIGN KEY (MaChiNhanh) REFERENCES ChiNhanh(MaChiNhanh)
);

CREATE TABLE DatCho (
    MaSoBan INT,
    MaChiNhanh INT,
    MaDatTruoc INT,
    PRIMARY KEY (MaSoBan, MaChiNhanh, MaDatTruoc),
    FOREIGN KEY (MaSoBan, MaChiNhanh) REFERENCES Ban(MaSoBan, MaChiNhanh),
    FOREIGN KEY (MaDatTruoc) REFERENCES DatTruoc(MaDatTruoc)
);


CREATE TABLE DatTruoc (
    MaDatTruoc INT PRIMARY KEY,
    MaKhachHang INT,
    MaChiNhanh INT,
    SoLuongKhach INT CHECK (SoLuongKhach <= (SELECT SucChua FROM Ban WHERE MaSoBan = DatTruoc.MaSoBan)),
    GioDen TIME,
    GhiChu TEXT,
    FOREIGN KEY (MaKhachHang) REFERENCES KhachHang(MaKhachHang),
    FOREIGN KEY (MaChiNhanh) REFERENCES ChiNhanh(MaChiNhanh)
);

-- phân hệ nhân viên


-- ràng buộc constraint 
-- phân hệ chi nhánh
-- phân hệ khách hàng
-- phân hệ nhân viên