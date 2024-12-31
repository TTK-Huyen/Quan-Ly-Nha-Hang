const express = require('express');
const sql = require('mssql');
const bodyParser = require('body-parser');
const path = require('path');


const app = express();
const port = 3000;

// Phục vụ file tĩnh (HTML, CSS, JS)
app.use(express.static(path.join(__dirname)));

app.listen(port, () => {
    console.log(`Server đang chạy tại http://localhost:${port}`);
});


// Cấu hình kết nối SQL Server
const config = {
    server: '192.168.102.1', // Địa chỉ IP của máy chủ SQL Server
    port: 1433, // Cổng SQL Server
    database: 'QLNHAHANG',
    user: 'sa',
    password: '1928374650Vy',
    options: {
        encrypt: false, // Không cần mã hóa
        enableArithAbort: true, // Bật xử lý lỗi số học
        connectTimeout: 30000, // Thời gian chờ 30 giây
    },
};



// Middleware
app.use(bodyParser.json());
app.use(express.static(path.join(__dirname)));

// Endpoint thêm nhân viên
app.post('/api/addEmployee', async (req, res) => {
    const { HoTen, NgaySinh, GioiTinh, Luong, NgayVaoLam, MaBoPhan, MaChiNhanh } = req.body;

    try {
        const pool = await sql.connect(config);

        await pool.request()
            .input('HoTen', sql.NVarChar, HoTen)
            .input('NgaySinh', sql.Date, NgaySinh)
            .input('GioiTinh', sql.NVarChar, GioiTinh)
            .input('NgayVaoLam', sql.Date, NgayVaoLam)
            .input('MaBoPhan', sql.Char(4), MaBoPhan)
            .input('MaChiNhanh', sql.TinyInt, MaChiNhanh)
            .execute('THEMNV');

        res.json({ message: 'Thêm nhân viên thành công!' });
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: err.message });
    }
});

//Endpoint thêm phiếu đặt món
app.post('/api/addOrderForm', async (req, res) => {
    const {NhanVienLap, MaSoBan, MaKhachHang,MaChiNhanh} = req.body;

    try {
        const pool = await sql.connect(config);

        await pool.request()
            .input('NhanVienLap', sql.Char, NhanVienLap)
            .input('MaSoBan', sql.VarChar, MaSoBan)
            .input('MaKhachhang', sql.BigInt, MaKhachHang)
            .input('MaChiNhanh', sql.TinyInt, MaChiNhanh)
            .execute('THEMPDM');

        res.json({ message: 'Thêm phiếu đặt món thành công!' });
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: err.message });
    }
});

app.post('/api/addCustomer', async(req,res) =>{
    const {HoTen, SoDienThoai,Email,SoCCCD,GioiTinh} = req.body;

    try{
        const pool = await sql.connect(config);

        await pool.request()
            .input('HoTen', sql.NVarChar, HoTen)
            .input('SoDienThoai', sql.Char, SoDienThoai)
            .input('Email', sql.VarChar, Email)
            .input('SoCCCD', sql.Char, SoCCCD)
            .input('GioiTinh', sql.NVarChar, GioiTinh)
            .execute('SP_DANGKI_TAIKHOAN')

        res.json({message: 'Thêm khách hàng thành công!'});
    }catch(err){
        console.error(err);
        res.status(500).json({ error: err.message });
    }
});



app.post('/api/addCustomerCard', async (req, res) => {
    const { MaKhachHang, NhanVienLap } = req.body;

    console.log('API received data:', { MaKhachHang, NhanVienLap }); // Log dữ liệu nhận được

    try {
        const pool = await sql.connect(config);

        await pool.request()
            .input('MaKhachHang', sql.BigInt, MaKhachHang)
            .input('NhanVienLap', sql.Char(6), NhanVienLap)
            .execute('THEMTHEKH');

        res.json({ message: 'Thêm thẻ khách hàng thành công!' });
    } catch (err) {
        console.error('Database error:', err);

        // Xử lý lỗi từ SQL Server
        let errorMessage = 'Lỗi không xác định từ SQL Server.';
        if (err.precedingErrors && err.precedingErrors.length > 0) {
            errorMessage = err.precedingErrors[0].message;
        } else if (err.originalError && err.originalError.info) {
            errorMessage = err.originalError.info.message;
        } else if (err.message) {
            errorMessage = err.message;
        }

        // Trả lỗi về frontend
        res.status(500).json({ error: errorMessage });
    }
});


const multer = require('multer');
const upload = multer({ storage: multer.memoryStorage() });

app.post('/api/addDish', upload.single('AnhMon'), async (req, res) => {
    console.log('File Info:', req.file);
    console.log('Request Body:', req.body);

    const { MaMuc, TenMon, GiaHienTai, GiaoHang } = req.body;
    const AnhMon = req.file ? req.file.buffer : null;

    try {
        const pool = await sql.connect(config);

        await pool.request()
            .input('MaMuc', sql.TinyInt, MaMuc)
            .input('TenMon', sql.NVarChar, TenMon)
            .input('GiaHienTai', sql.Decimal(18, 3), GiaHienTai)
            .input('GiaoHang', sql.Bit, GiaoHang)
            .input('AnhMon', sql.VarBinary(sql.MAX), AnhMon)
            .execute('THEM_MON');

        res.json({ message: 'Thêm món ăn thành công!' });
    } catch (error) {
        console.error('Error:', error);
        res.status(500).json({ error: 'Lỗi khi thêm món ăn.' });
    }
});




//Endpoint thêm chi nhánh
// app.post('/api/addBranch',async(req, res) =>{
//     const {TenChiNhanh, DiaChi, ThoiGianMoCua, ThoiGianDongCua, SoDienThoai, BaiDoXeHoi, BaiDoXeMay, NhanVienQuanLy, GiaoHang}

//     try{
//         const pool = await sql.connect(config);

//         await pool.request()
//         .input('TenDiaChi', sql.NVarChar, TenChiNhanh)
//         .input('DiaChi', sql.NVarChar,DiaChi)
//         .input('ThoiGianMoCua', sql.Time, ThoiGianMoCua)
//         .input('ThoiGianDongCua', sql.Time, ThoiGianDongCua)
//         .input('SoDienThoai', sql.VarChar, SoDienThoai)
//         .input('BaiDoXeHoi', sql.Bit, BaiDoXeHoi)
//         .input('BaiDoXeMay', sql.Bit, BaiDoXeMay)
//         .input('NhanVienQuanLy', sql.Char, NhanVienQuanLy)
//         .input ('GiaoHang', sql.Bit, GiaoHang)
//         .execute('THEM_CHI_NHANH')
//     }
// })

//Endpoint Xóa chi nhánh 
app.post ('/api/deleteBranch', async(req, res) => {
    const {MaChiNhanh} = req.body;

    try {
        const pool = await sql.connect(config);

        await pool.request()
            .input('MaChiNhanh', sql.TinyInt, MaChiNhanh )
            execute('XOA_CHINHANH');

        res.json({message:  'Xóa chi nhánh thành công!'});
    }catch (err) {
        console.error(err);
        res.status(500).json({ error: err.message });
    }

});




// API lấy dữ liệu từ bảng BoPhan
app.get('/api/bophan', async (req, res) => {
    try {
        const pool = await sql.connect(config);
        const result = await pool.request().query('SELECT * FROM BoPhan');
        res.json(result.recordset);
        await pool.close();
    } catch (err) {
        res.status(500).send('Lỗi: ' + err.message);
    }
});

// API lấy dữ liệu từ bảng ChiNhanh
app.get('/api/chinhanh', async (req, res) => {
    try {
        const pool = await sql.connect(config);
        const result = await pool.request().query('SELECT * FROM ChiNhanh');
        res.json(result.recordset);
        await pool.close();
    } catch (err) {
        res.status(500).send('Lỗi: ' + err.message);
    }
});


app.get('/api/MucThucDon', async (req, res) => {
    try {
        const pool = await sql.connect(config);
        const result = await pool.request().query('SELECT MaMuc, TenMuc FROM MucThucDon');
        res.json(result.recordset);
    } catch (error) {
        console.error('Error in /api/MucThucDon:', error);
        res.status(500).json({ error: 'Lỗi khi tải danh sách mục thực đơn.' });
    }
});



app.get('/api/KhuVuc', async (req, res) => {
    try {
        const pool = await sql.connect(config);
        const result = await pool.request()
            .query('SELECT MaKhuVuc, TenKhuVuc FROM KhuVuc_ThucDon');
        res.json(result.recordset);
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: 'Lỗi khi lấy danh sách khu vực' });
    }
});

app.get('/api/ThucDonMon', async (req, res) => {
    const maKhuVuc = req.query.khuVuc;

    try {
        const pool = await sql.connect(config);
        let query = `
            SELECT M.MaMon, M.TenMon, M.GiaHienTai, M.MaMuc
            FROM ThucDon_Mon TDM
            JOIN Mon M ON TDM.MaMon = M.MaMon
        `;

        if (maKhuVuc) {
            query += ` WHERE TDM.MaKhuVuc = @MaKhuVuc`;
        }

        const result = await pool.request()
            .input('MaKhuVuc', sql.TINYINT, maKhuVuc)
            .query(query);

        res.json(result.recordset);
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: 'Lỗi khi lấy thực đơn món theo khu vực.' });
    }
});



app.get('/api/ThucDonMon', async (req, res) => {
    const maKhuVuc = req.query.khuVuc;

    try {
        const pool = await sql.connect(config);
        let query = `
            SELECT M.MaMon, M.TenMon, M.GiaHienTai, M.MaMuc
            FROM ThucDon_Mon TDM
            JOIN Mon M ON TDM.MaMon = M.MaMon
        `;

        if (maKhuVuc) {
            query += ` WHERE TDM.MaKhuVuc = @MaKhuVuc`;
        }

        const result = await pool.request()
            .input('MaKhuVuc', sql.TINYINT, maKhuVuc)
            .query(query);

        res.json(result.recordset);
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: 'Lỗi khi lấy thực đơn món theo khu vực.' });
    }
});

app.get('/api/checkDatabase', async (req, res) => {
    try {
        await sql.connect(config);
        res.status(200).json({ message: 'Kết nối database thành công!' });
    } catch (err) {
        console.error('Lỗi khi kết nối đến database:', err.message);
        res.status(500).json({ error: 'Không thể kết nối đến database.', details: err.message });
    }
});
