const sql = require('mssql');

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

async function queryDatabase() {
    try {
        // Kết nối đến SQL Server
        const pool = await sql.connect(config);

        // Truy vấn SQL
        const result = await pool.request()
            .query('SELECT * FROM KhuVuc'); // Thay 'KhuVuc' bằng bảng bất kỳ trong CSDL của bạn

        console.log('Kết quả truy vấn:', result.recordset);

        await pool.close(); // Đóng kết nối sau khi sử dụng
    } catch (err) {
        console.error('Truy vấn thất bại:', err.message);
    }
}

queryDatabase();
