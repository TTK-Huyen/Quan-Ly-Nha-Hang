
const sql = require('mssql');

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


// API đăng nhập
app.post('/api/login', async (req, res) => {
    const { username, password } = req.body;

    try {
        const pool = await sql.connect(config);

        // Lấy thông tin người dùng từ cơ sở dữ liệu
        const result = await pool.request()
            .input('Username', sql.NVarChar, username)
            .query('SELECT * FROM Users WHERE Username = @Username');
        
        const user = result.recordset[0];
        if (!user) return res.status(401).json({ error: 'User không tồn tại' });

        // Kiểm tra mật khẩu
        const isPasswordValid = await bcrypt.compare(password, user.Password);
        if (!isPasswordValid) return res.status(401).json({ error: 'Sai mật khẩu' });

        // Lấy quyền từ bảng Roles
        const roleResult = await pool.request()
            .input('Role', sql.NVarChar, user.Role)
            .query('SELECT Permissions FROM Roles WHERE Role = @Role');
        
        const permissions = roleResult.recordset[0]?.Permissions.split(',') || [];

        // Tạo JWT
        const token = jwt.sign(
            { id: user.Id, role: user.Role, permissions }, 
            SECRET_KEY, 
            { expiresIn: '1h' }
        );

        res.json({ token });
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: 'Lỗi server' });
    }
});
