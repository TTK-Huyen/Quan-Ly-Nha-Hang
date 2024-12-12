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
            .input('Luong', sql.Decimal(18, 3), Luong)
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


// API lấy dữ liệu từ bảng KhuVuc
app.get('/api/khuvuc', async (req, res) => {
    try {
        const pool = await sql.connect(config);
        const result = await pool.request().query('SELECT * FROM KhuVuc');
        res.json(result.recordset); // Trả dữ liệu dưới dạng JSON
        await pool.close();
    } catch (err) {
        res.status(500).send('Lỗi: ' + err.message);
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
