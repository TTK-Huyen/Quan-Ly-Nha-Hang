const express = require('express'); // Nhập thư viện express 
const session = require('express-session');
const bodyParser = require('body-parser'); // Để xử lý file request
const sql = require('mssql');
const path = require('path');
const app = express();
const PORT = 3000;

// Cấu hình để phục vụ các tệp tĩnh từ thư mục "frontend"
app.use(express.static(path.join(__dirname, 'frontend')));

// Chuyển hướng đến home.html khi truy cập đường dẫn gốc "/"
app.get('/', (req, res) => {
    res.sendFile(path.join(__dirname, 'frontend', 'home.html'));
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
const config = {
    server: 'LAPTOP-P8ETI0BS', // Địa chỉ IP của máy chủ SQL Server -- máy Huyền =)))
    port: 1433, // Cổng SQL Server
    database: 'QLNHAHANG',
    user: 'sa',
    password: '123456789',
    options: {
        encrypt: true, // Không cần mã hóa
        trustServerCertificate: true, // Bỏ qua xác thực chứng chỉ
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

// app.use(async (req, res, next) => {
//     if (req.session && req.session.user) {
//         const username = req.session.user.username;
//         const role = req.session.user.role;

//         if (role === 'khachhang') {
//             try {
//                 const pool = await sql.connect(config);

//                 // Cập nhật ThoiGianTruyCap trước khi session bị hủy
//                 const result = await pool.request()
//                     .input('username', sql.VarChar, username)
//                     .query(`
//                         UPDATE ThongTinTruyCap
//                         SET ThoiGianTruyCap = DATEDIFF(SECOND, ThoiDiemTruyCap, GETDATE())
//                         WHERE UserID = (
//                             SELECT MaKhachHang
//                             FROM KhachHang
//                             WHERE SoDienThoai = @username
//                         ) AND ThoiGianTruyCap = 0
//                     `);

//                 if (result.rowsAffected[0] === 0) {
//                     console.log('Không tìm thấy phiên đăng nhập để cập nhật!');
//                 } else {
//                     console.log('Thời gian truy cập được cập nhật thành công!');
//                 }
//             } catch (err) {
//                 console.error('Lỗi khi cập nhật thời gian truy cập:', err);
//             }
//         }
//     }
//     next(); // Tiếp tục các middleware khác
// });


// Khởi chạy server
app.listen(PORT, () => {
    console.log(`Server đang chạy tại http://localhost:${PORT}`);
});
