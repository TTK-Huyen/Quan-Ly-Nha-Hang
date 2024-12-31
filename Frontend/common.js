// Kiểm tra trạng thái đăng nhập và hiển thị nút Login/Logout phù hợp
async function initializeButtons() {
    try {
        const response = await fetch('/check-login', { method: 'GET' });
        const data = await response.json();

        if (response.ok && data.loggedIn) {
            // Nếu đã đăng nhập, hiển thị nút Logout
            document.getElementById('logout').style.display = 'block';
            document.getElementById('login').style.display = 'none';
        } else {
            // Nếu chưa đăng nhập, hiển thị nút Login
            document.getElementById('login').style.display = 'block';
            document.getElementById('logout').style.display = 'none';
        }
    } catch (err) {
        console.error('Lỗi khi kiểm tra trạng thái đăng nhập:', err);
    }
}

// Xử lý sự kiện Logout
async function handleLogout(event) {
    event.preventDefault(); // Ngăn chặn chuyển hướng mặc định

    try {
        const response = await fetch('/logout', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
        });

        if (response.ok) {
            alert('Bạn đã đăng xuất thành công!');
            window.location.href = '/home.html'; // Chuyển hướng về trang đăng nhập
        } else {
            const error = await response.json();
            alert(error.error || 'Đăng xuất thất bại!');
        }
    } catch (err) {
        console.error('Lỗi khi đăng xuất:', err);
        alert('Có lỗi xảy ra, vui lòng thử lại!');
    }
}

// Khởi tạo các sự kiện
function initializeEvents() {
    // Gắn sự kiện cho nút Logout
    const logoutLink = document.getElementById('logoutLink');
    if (logoutLink) {
        logoutLink.addEventListener('click', handleLogout);
    }

    // Kiểm tra trạng thái đăng nhập và hiển thị nút phù hợp
    initializeButtons();
}


function openModal() {
    document.getElementById('membershipModal').style.display = 'block';
}

function closeModal() {
    document.getElementById('membershipModal').style.display = 'none';
}

// Đóng modal khi người dùng nhấn ngoài modal
window.onclick = function (event) {
    const modal = document.getElementById('membershipModal');
    if (event.target === modal) {
        closeModal();
    }
};

// Tự động khởi tạo khi tải trang
window.onload = initializeEvents;
