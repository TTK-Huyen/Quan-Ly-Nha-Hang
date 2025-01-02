const express = require('express'); // Nhập thư viện express 
const session = require('express-session');
const bodyParser = require('body-parser'); // Để xử lý file request
const sql = require('mssql');
const path = require('path');
const app = express();
const PORT = 3000;

// Cấu hình để phục vụ các tệp tĩnh từ thư mục "frontend"
app.use(express.static(path.join(__dirname, 'public')));

// Chuyển hướng đến home.html khi truy cập đường dẫn gốc "/"
app.get('/', (req, res) => {
    res.sendFile(path.join(__dirname, 'public', 'DangNhap.html'));
});
// Middleware để parse JSON từ body
app.use(express.json());
app.use(express.urlencoded({ extended: true })); // Nếu cần xử lý form-urlencoded

// Cấu hình session
app.use(session({
    secret: 'your_secret_key', // Khóa bí mật để ký session ID
    resave: false, // Không lưu session nếu không có thay đổi
    saveUninitialized: true, // Lưu session dù không có dữ liệu
    cookie: { secure: false } // Cookie không yêu cầu HTTPS (chỉ cho local)
}));

// Cấu hình kết nối SQL Server
// const config = {
//     server: 'LAPTOP-P8ETI0BS', // Địa chỉ IP của máy chủ SQL Server -- máy Huyền =)))
//     port: 1433, // Cổng SQL Server
//     database: 'QLNHAHANG',
//     user: 'sa',
//     password: '123456789',
//     options: {
//         encrypt: true, // Không cần mã hóa
//         trustServerCertificate: true, // Bỏ qua xác thực chứng chỉ
//         enableArithAbort: true, // Bật xử lý lỗi số học
//         connectTimeout: 30000, // Thời gian chờ 30 giây
//     },
// };

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

// Hàm kiểm tra kết nối
async function testDatabaseConnection() {
    try {
        const pool = await sql.connect(config);
        console.log('Kết nối thành công đến cơ sở dữ liệu!');
        await pool.close();
    } catch (err) {
        console.error('Lỗi khi kết nối đến cơ sở dữ liệu:', err);
    }
}

// Gọi hàm kiểm tra khi server khởi động
testDatabaseConnection();

// Kiểm tra đăng nhập
app.get('/check-login', (req, res) => {
    if (!req.session.user) {
        return res.json({ loggedIn: false }); // Người dùng chưa đăng nhập
    }

    res.json({
        loggedIn: true, // Người dùng đã đăng nhập
        user: req.session.user // Thông tin người dùng (tuỳ chọn)
    });
});

// API xử lý đăng nhập
app.post('/login', async (req, res) => {
    console.log("Dữ liệu nhận được từ client:", req.body);

    const { username, password } = req.body;

    if (!username || !password) {
        console.log("Thiếu thông tin đăng nhập:", { username, password });
        return res.status(400).json({ error: 'Vui lòng nhập đầy đủ thông tin!' });
    }

    console.log("Username:", username);
    console.log("Password:", password);

    try {
        const pool = await sql.connect(config);
        console.log("Kết nối database thành công!");
        // Kiểm tra thông tin đăng nhập trong database

        const result = await pool.request()
            .input('Username', sql.NVarChar, username)
            .input('Password', sql.NVarChar, password)
            .query(`
                SELECT Username, Role
                FROM Users
                WHERE Username = @Username AND Password = @Password
            `);

        const user = result.recordset[0];
        console.log(result.recordset[0]);
        if (!user) {
            return res.status(401).json({ error: 'Tên đăng nhập hoặc mật khẩu không đúng' });
        }
        console.log("Vai trò từ database:", user.Role);
        // Lưu trạng thái người dùng vào session
        req.session.user = { id: user.Username, role: user.Role };
        // Chỉ lưu thông tin truy cập nếu role là 'khachhang'
        if (user.Role === 'khachhang') {
            await pool.request()
                .input('Username', sql.Char(10), user.Username)
                .query(`
                    INSERT INTO ThongTinTruyCap (MaKhachHang, ThoiDiemTruyCap)
                    SELECT MaKhachHang, GETDATE()
                    FROM KhachHang
                    WHERE SoDienThoai = @Username
                `);
        }
        res.json({ message: 'Đăng nhập thành công!', role: user.Role });
    } catch (err) {
        console.error(err.message);
        res.status(500).json({ error: 'Lỗi server' });
    }
});

// Xác thực quyền trước khi xài api
function authorizeRole(allowedRoles) {
    return (req, res, next) => {
        if (!req.session.user) {
            return res.status(401).json({ error: 'Bạn chưa đăng nhập' });
        }

        const userRole = req.session.user.role;

        // Kiểm tra xem vai trò có trong danh sách được phép không
        if (!allowedRoles.includes(userRole)) {
            return res.status(403).json({ error: 'Bạn không có quyền truy cập vào API này' });
        }

        next(); // Vai trò hợp lệ, tiếp tục xử lý API
    };
}

// API đăng xuất
app.post('/logout', async (req, res) => {
    if (!req.session.user) {
        return res.status(401).json({ error: 'Bạn chưa đăng nhập' });
    }

    try {
             // Chỉ thực hiện nếu vai trò là 'khachhang'
        if (req.session.user.role === 'khachhang') {
            const pool = await sql.connect(config);
            const username = req.session.user.id; // Lấy số điện thoại từ session
            console.log("Username được sử dụng:", username);
            // Cập nhật LogoutTime và ThoiGianTruyCap
            const result = await pool.request()
                .input('username', sql.VarChar, username)
                .query(`
                    UPDATE ThongTinTruyCap
                    SET ThoiGianTruyCap = DATEDIFF(SECOND, ThoiDiemTruyCap, GETDATE())
                    WHERE MaKhachHang = (
                        SELECT MaKhachHang
                        FROM KhachHang
                        WHERE SoDienThoai = @username
                    ) AND ThoiGianTruyCap = 0
                `);

            if (result.rowsAffected[0] === 0) {
                return res.status(404).json({ error: 'Không tìm thấy phiên đăng nhập để cập nhật!' });
            }   
        }

        // Xóa session
        req.session.destroy(err => {
            if (err) {
                return res.status(500).json({ error: 'Đăng xuất thất bại' });
            }
            res.json({ message: 'Đăng xuất thành công!' });
        });
    } catch (err) {
        console.error(err.message);
        res.status(500).json({ error: 'Lỗi server' });
    }
});

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

app.post('/api/addReservation', async (req, res) => {
    const { MaKhachHang, SoDienThoai, MaChiNhanh, SoLuongKhach, GioDen, GhiChu } = req.body;

    // Log dữ liệu nhận được
    console.log('API received data:', { MaKhachHang, SoDienThoai, MaChiNhanh, SoLuongKhach, GioDen, GhiChu });

    try {
        // Kết nối đến SQL Server
        const pool = await sql.connect(config);

        // Kiểm tra và chuyển đổi `GioDen` thành Date nếu cần
        const gioDenDate = new Date(GioDen);
        if (isNaN(gioDenDate)) {
            return res.status(400).json({ error: 'Thời gian đến (GioDen) không hợp lệ' });
        }

        // Gọi thủ tục DATTRUOC
        await pool.request()
            .input('MaKhachHang', sql.BigInt, MaKhachHang)
            .input('SoDienThoai', sql.Char(10), SoDienThoai)
            .input('MaChiNhanh', sql.TinyInt, MaChiNhanh)
            .input('SoLuongKhach', sql.TinyInt, SoLuongKhach)
            .input('GioDen', sql.DateTime, gioDenDate)
            .input('GhiChu', sql.NVarChar, GhiChu || null) // Ghi chú có thể để trống
            .execute('DAT_TRUOC');
            console.log({
                MaKhachHang,
                SoDienThoai,
                MaChiNhanh,
                SoLuongKhach,
                GioDen: gioDenDate,
                GhiChu
            });
        // Trả về phản hồi thành công
        res.status(200).json({ message: 'Đặt trước thành công!' });

    } catch (error) {
        console.error('Error while executing DATTRUOC:', error);

        // Xử lý lỗi cụ thể nếu có thể
        const errorMessage = error.originalError?.info?.message || 'Lỗi khi đặt trước';
        res.status(500).json({ error: errorMessage });
    }
});


const multer = require('multer');
const upload = multer({ storage: multer.memoryStorage() });

app.post('/api/addDish', async (req, res) => {
    console.log('File Info:', req.file);
    console.log('Request Body:', req.body);

    const { MaMuc, TenMon, GiaHienTai, GiaoHang } = req.body;
    try {
        const pool = await sql.connect(config);

        await pool.request()
            .input('MaMuc', sql.TinyInt, MaMuc)
            .input('TenMon', sql.NVarChar, TenMon)
            .input('GiaHienTai', sql.Decimal(18, 3), GiaHienTai)
            .input('GiaoHang', sql.Bit, GiaoHang)
            .execute('THEM_MON');

        res.json({ message: 'Thêm món ăn thành công!' });
    } catch (error) {
        console.error('Error:', error);
        res.status(500).json({ error: 'Lỗi khi thêm món ăn.' });
    }
});




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


app.get('/api/ChiNhanh', async (req, res) => {
    const { maKhuVuc } = req.query; // Lấy MaKhuVuc từ query string
    try {
        const pool = await sql.connect(config);
        let query = 'SELECT * FROM ChiNhanh'; // Truy vấn mặc định

        if (maKhuVuc) {
            // Nếu có MaKhuVuc, thêm điều kiện lọc
            query += ' WHERE MaKhuVuc = @MaKhuVuc';
        }

        const request = pool.request();
        if (maKhuVuc) {
            request.input('MaKhuVuc', sql.TinyInt, maKhuVuc); // Khai báo đúng tên biến
        }

        const result = await request.query(query);
        res.json(result.recordset); // Trả về danh sách chi nhánh
    } catch (err) {
        console.error('Error in /api/ChiNhanh:', err);
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
            SELECT M.MaMon, M.TenMon, M.GiaHienTai, M.MaMuc, MT.TenMuc
            FROM ThucDon_Mon TDM
            JOIN Mon M ON TDM.MaMon = M.MaMon
            JOIN MucThucDon MT ON M.MaMuc = MT.MaMuc
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


app.get('/api/getTenMuc', async (req, res) => {
    const { MaMuc } = req.query; // Lấy tham số MaMuc từ query string
    try {
        const pool = await sql.connect(config);
        const result = await pool.request()
            .input('MaMuc', sql.Int, MaMuc) // Sử dụng MaMuc trong truy vấn
            .query('SELECT TenMuc FROM MucThucDon WHERE MaMuc = @MaMuc');

        if (result.recordset.length > 0) {
            res.json({ TenMuc: result.recordset[0].TenMuc }); // Trả về tên mục
        } else {
            res.status(404).json({ error: 'Không tìm thấy tên mục.' });
        }
    } catch (err) {
        console.error('Lỗi khi gọi API /api/getTenMuc:', err);
        res.status(500).json({ error: 'Lỗi server.' });
    }
});

app.get('/api/ChiNhanhKV', async (req, res) => {
    const { maKhuVuc } = req.query; // Lấy MaKhuVuc từ query string
    try {
        const pool = await sql.connect(config);
        let query = 'SELECT * FROM ChiNhanh'; // Truy vấn mặc định

        if (maKhuVuc) {
            // Nếu có MaKhuVuc, thêm điều kiện lọc
            query += ' WHERE MaKhuVuc = @MaKhuVuc';
        }

        const request = pool.request();
        if (maKhuVuc) {
            request.input('MaKhuVuc', sql.TinyInt, maKhuVuc); // Khai báo đúng tên biến
        }

        const result = await request.query(query);
        res.json(result.recordset); // Trả về danh sách chi nhánh
    } catch (err) {
        console.error('Error in /api/ChiNhanh:', err);
        res.status(500).send('Lỗi: ' + err.message);
    }
});

// API lấy danh sách Chi Nhánh theo MaKhuVuc
app.get('/api/chinhanhkhuvuc', async (req, res) => {
    try {
        const { MaKhuVuc } = req.query; // Lấy tham số MaKhuVuc từ query string
        const pool = await sql.connect(config);

        // Nếu có MaKhuVuc, lọc theo khu vực, nếu không lấy toàn bộ
        const query = MaKhuVuc
            ? 'SELECT * FROM ChiNhanh WHERE MaKhuVuc = @MaKhuVuc'
            : 'SELECT * FROM ChiNhanh';

        const request = pool.request();
        if (MaKhuVuc) {
            request.input('MaKhuVuc', sql.TINYINT, MaKhuVuc);
        }

        const result = await request.query(query);
        res.json(result.recordset);
        await pool.close();
    } catch (err) {
        res.status(500).send('Lỗi: ' + err.message);
    }
});


app.get('/api/chinhanhkhuvuc_2', async (req, res) => {
    try {
        const { MaChiNhanh, MaKhuVuc } = req.query; // Lấy tham số MaKhuVuc và MaChiNhanh từ query string

        // Kiểm tra nếu thiếu một trong hai tham số
        if (!MaKhuVuc || !MaChiNhanh) {
            return res.status(400).json({ error: 'Vui lòng cung cấp đầy đủ MaKhuVuc và MaChiNhanh.' });
        }

        const pool = await sql.connect(config);

        // Truy vấn lấy thông tin chi nhánh và khu vực
        const query = `
            SELECT CN.MaChiNhanh, CN.TenChiNhanh, CN.DiaChi, KV.MaKhuVuc, KV.TenKhuVuc
            FROM ChiNhanh CN
            JOIN KhuVuc_ThucDon KV ON CN.MaKhuVuc = KV.MaKhuVuc
            WHERE CN.MaKhuVuc = @MaKhuVuc AND CN.MaChiNhanh = @MaChiNhanh
        `;

        const result = await pool.request()
            .input('MaKhuVuc', sql.TINYINT, MaKhuVuc)
            .input('MaChiNhanh', sql.TINYINT, MaChiNhanh)
            .query(query);

        // Trả về kết quả
        if (result.recordset.length > 0) {
            res.json(result.recordset[0]); // Trả về một đối tượng chi nhánh cụ thể
        } else {
            res.status(404).json({ error: 'Không tìm thấy chi nhánh trong khu vực này.' });
        }

        await pool.close();
    } catch (err) {
        console.error('Lỗi khi lấy chi nhánh và khu vực:', err.message);
        res.status(500).send('Lỗi: ' + err.message);
    }
});

app.get('/api/search-menu', async (req, res) => {
    const { MaKhuVuc, MaChiNhanh, q } = req.query;
    // Kiểm tra tham số bắt buộc
    if (!MaKhuVuc || !MaChiNhanh) {
        return res.status(400).json({ error: 'Vui lòng cung cấp MaKhuVuc và MaChiNhanh!' });
    }

    try {
        const pool = await sql.connect(config);
        console.log('Dang test'); 
        // Tạo câu truy vấn với điều kiện tìm kiếm
        const query = `
            SELECT M.MaMon, M.TenMon, M.GiaHienTai, M.MaMuc, MTD.TenMuc
            FROM ThucDon_Mon TDM
            JOIN Mon M ON TDM.MaMon = M.MaMon
            JOIN MucThucDon MTD ON M.MAMUC = MTD.MAMUC
            WHERE M.GiaoHang = 1 
              AND M.MaMon NOT IN (SELECT MaMon FROM PhucVu WHERE MaChiNhanh = @MaChiNhanh and CoPhucVuKhong = 0)
              AND TDM.MaKhuVuc = @MaKhuVuc
              ${q ? 'AND M.TenMon LIKE @SearchQuery' : ''}
        `;
        const request = pool.request()
            .input('MaKhuVuc', sql.TINYINT, MaKhuVuc)
            .input('MaChiNhanh', sql.TINYINT, MaChiNhanh);

        if (q) {
            request.input('SearchQuery', sql.NVarChar, `%${q}%`);
        }

        const result = await request.query(query);
        console.log('Kết quả trả về từ truy vấn:', result.recordset); // In ra kết quả
        res.json(result.recordset); // Gửi kết quả về client
    } catch (err) {
        console.error('Lỗi khi tìm kiếm món ăn a:', err.message);
        res.status(500).json({ error: 'Không thể tìm kiếm món ăn.' });
    }
});

app.post('/api/order', async (req, res) => {
    try {
        const {customerPhone, maChiNhanh, maKhuVuc, cartItems, customerAddress} = req.body;
        console.log('Dữ liệu nhận được:', { customerPhone, maChiNhanh, maKhuVuc, cartItems, customerAddress });
        // Kiểm tra dữ liệu đầu vào
        if (!customerPhone || !maChiNhanh || !maKhuVuc || !cartItems || !customerAddress) {
            return res.status(400).json({ error: 'Dữ liệu không đầy đủ!' });
        }

        const pool = await sql.connect(config);

        // Chèn vào bảng PhieuDatMon
        const phieuDatMonResult = await pool.request()
            .input('SoDienThoai', sql.VarChar(10), customerPhone)
            .input('MaChiNhanh', sql.TINYINT, maChiNhanh)
            .input('GhiChu', sql.NVarChar(200), customerAddress)
            .query(`
                INSERT INTO PhieuDatMon (NgayLap, SoDienThoai, MaChiNhanh, GhiChu)
                OUTPUT INSERTED.MaPhieu
                VALUES (GETDATE(), @SoDienThoai, @MaChiNhanh, @GhiChu)
            `);

        const maPhieu = phieuDatMonResult.recordset[0].MaPhieu;

        // Chèn vào bảng ChiTietPhieu
        const chiTietQuery = `
            INSERT INTO ChiTietPhieu (MaPhieu, MaMon, SoLuong)
            VALUES (@MaPhieu, @MaMon, @SoLuong)
        `;

        const chiTietRequest = pool.request();
        for (const item of cartItems) {
            try {
                await pool.request()
                    .input('MaPhieu', sql.INT, maPhieu)
                    .input('MaMon', sql.TINYINT, item.MaMon)
                    .input('SoLuong', sql.TINYINT, item.SoLuong)
                    .query(chiTietQuery);
            } catch (err) {
                console.error(`Lỗi khi thêm món ${item.MaMon}:`, err.message);
            }
        }

        res.status(201).json({ message: 'Dữ liệu đã được lưu!', maPhieu });
        await pool.close();
    } catch (err) {
        console.error('Lỗi khi chèn dữ liệu:', err.message);
        res.status(500).json({ error: 'Không thể lưu dữ liệu!' });
    }
});

// API lấy thông tin khách hàng
app.get('/api/customer-info', async (req, res) => {
    const customerId = req.query.customerId;

    if (!customerId) {
        return res.status(400).json({ error: 'Vui lòng cung cấp ID khách hàng!' });
    }

    try {
        const pool = await sql.connect(config);

        const query = `
            SELECT KH.HoTen, KH.SoCCCD, KH.Email, KH.SoDienThoai, SUM(T.diemTichLuy + T.DiemHienTai) AS TongDiem 
            FROM KhachHang KH JOIN THEKHACHHANG T ON KH.MaKhachHang = T.MaKhachHang
            WHERE KH.SoDienThoai = @CustomerId
            GROUP BY KH.HoTen, KH.SoCCCD, KH.Email, KH.SoDienThoai;
        `;
        const result = await pool.request()
            .input('CustomerId', sql.Int, customerId)
            .query(query);

        if (result.recordset.length === 0) {
            return res.status(404).json({ error: 'Không tìm thấy khách hàng!' });
        }
        console.log('Thông tin khách hàng:', result.recordset[0]);
        res.json(result.recordset[0]);
    } catch (err) {
        console.error('Lỗi khi lấy thông tin khách hàng:', err.message);
        res.status(500).json({ error: 'Không thể lấy thông tin khách hàng.' });
    }
});

app.post('/api/addReservations', async (req, res) => {
    const {SoDienThoai, MaChiNhanh, SoLuongKhach, GioDen, GhiChu } = req.body;

    // Log dữ liệu nhận được
    console.log('API received data:', {SoDienThoai, MaChiNhanh, SoLuongKhach, GioDen, GhiChu });

    try {
        // Kết nối đến SQL Server
        const pool = await sql.connect(config);

        // Kiểm tra và chuyển đổi `GioDen` thành Date nếu cần
        const gioDenDate = new Date(GioDen);
        if (isNaN(gioDenDate)) {
            return res.status(400).json({ error: 'Thời gian đến (GioDen) không hợp lệ' });
        }

        // Gọi thủ tục DATTRUOC
        await pool.request()
            .input('SoDienThoai', sql.Char(10), SoDienThoai)
            .input('MaChiNhanh', sql.TinyInt, MaChiNhanh)
            .input('SoLuongKhach', sql.TinyInt, SoLuongKhach)
            .input('GioDen', sql.DateTime, gioDenDate)
            .input('GhiChu', sql.NVarChar, GhiChu || null) // Ghi chú có thể để trống
            .execute('DAT_TRUOC');
            console.log({
                SoDienThoai,
                MaChiNhanh,
                SoLuongKhach,
                GioDen: gioDenDate,
                GhiChu
            });
        // Trả về phản hồi thành công
        res.status(200).json({ message: 'Đặt trước thành công!' });

    } catch (error) {
        console.error('Error while executing DATTRUOC:', error);

        // Xử lý lỗi cụ thể nếu có thể
        const errorMessage = error.originalError?.info?.message || 'Lỗi khi đặt trước';
        res.status(500).json({ error: errorMessage });
    }
});


// Khởi chạy server
app.listen(PORT, () => {
    console.log(`Server đang chạy tại http://localhost:${PORT}`);
});
