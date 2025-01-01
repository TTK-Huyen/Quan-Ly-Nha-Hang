

// Hàm tải giỏ hàng từ sessionStorage
function loadCartFromSessionStorage() {
    const savedCart = sessionStorage.getItem('cartItems');
    return savedCart ? JSON.parse(savedCart) : [];
}

// Hiển thị giỏ hàng
function displayCartItems(cartItems) {
    const cartList = document.getElementById('cartItems');
    const cartTotal = document.getElementById('cartTotal');
    cartList.innerHTML = '';
    let total = 0;

    cartItems.forEach(item => {
        const li = document.createElement('li');
        li.innerHTML = `
            <img src="https://via.placeholder.com/50" alt="${item.TenMon}" />
            <div class="item-info">
                <p>${item.TenMon}</p>
                <p>${item.GiaHienTai} VND (x${item.quantity})</p>
            </div>
        `;
        cartList.appendChild(li);
        total += item.GiaHienTai * item.quantity;
    });

    cartTotal.textContent = `Tổng cộng: ${total} VND`;
}

// Hiển thị thông tin chi nhánh và khu vực đã chọn
async function loadBranchAndRegionInfo(maChiNhanh, maKhuVuc) {
    try {
        console.log(maChiNhanh);
        console.log(maKhuVuc);
        const response = await fetch(`/api/chinhanhkhuvuc_2?MaKhuVuc=${maKhuVuc}&MaChiNhanh=${maChiNhanh}`);
        const data = await response.json();
        console.log(data);
        if (response.ok) {
            document.getElementById('selectedRegion').textContent = data.TenKhuVuc || 'Không xác định';
            document.getElementById('selectedBranch').textContent = data.TenChiNhanh || 'Không xác định';
        } else {
            throw new Error(data.error || 'Lỗi không xác định');
        }
    } catch (error) {
        console.error('Lỗi khi tải thông tin:', error);
        alert('Không thể tải thông tin khu vực và chi nhánh. Vui lòng thử lại.');
    }
}
   // Kiểm tra giỏ hàng và thông tin khu vực/chi nhánh khi tải trang
   document.addEventListener('DOMContentLoaded', () => {
    const cartItems = loadCartFromSessionStorage();
    const maChiNhanh = sessionStorage.getItem('maChiNhanh');
    const maKhuVuc = sessionStorage.getItem('maKhuVuc');
    console.log(maChiNhanh);
    console.log(maKhuVuc);
    if (cartItems.length === 0) {
        alert('Giỏ hàng trống. Vui lòng thêm món vào giỏ hàng!');
        window.location.href = '/KhachHang/Order/menu.html';
        return;
    }

    if (maChiNhanh && maKhuVuc) {
        displayCartItems(cartItems); // Hiển thị giỏ hàng
        loadBranchAndRegionInfo(maChiNhanh, maKhuVuc); // Hiển thị khu vực và chi nhánh
    } else {
        alert('Không có thông tin khu vực và chi nhánh. Quay lại giỏ hàng.');
        window.location.href = '/KhachHang/Order/cart.html';
    }
});






// Xử lý khi nhấn nút "Hoàn Tất Đặt Hàng"
document.getElementById('checkoutForm').addEventListener('submit', async (e) => {
    e.preventDefault();

    // Lấy thông tin từ sessionStorage
    const cartItems = JSON.parse(sessionStorage.getItem('cartItems') || '[]');
    const maChiNhanh = sessionStorage.getItem('tempMaChiNhanh');
    const maKhuVuc = sessionStorage.getItem('tempMaKhuVuc');

    // Lấy thông tin khách hàng từ form
    const customerName = document.getElementById('customerName').value;
    const customerPhone = document.getElementById('customerPhone').value;
    const customerAddress = document.getElementById('customerAddress').value;

    // Kiểm tra dữ liệu đầu vào
    if (!cartItems.length || !maChiNhanh || !maKhuVuc) {
        alert('Dữ liệu không đầy đủ. Vui lòng kiểm tra lại!');
        return;
    }

    try {
        // Gửi dữ liệu lên server
        const response = await fetch('/api/order', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify({
                maChiNhanh,
                maKhuVuc,
                cartItems,
                customerInfo: {
                    name: customerName,
                    phone: customerPhone,
                    address: customerAddress,
                },
            }),
        });

        const result = await response.json();

        if (response.ok) {
            // Hiển thị thông báo đặt hàng thành công
            alert(`Đặt hàng thành công! Mã đơn hàng của bạn là: ${result.orderId}`);

            // Xóa thông tin giỏ hàng và khu vực/chi nhánh
            sessionStorage.removeItem('cartItems');
            sessionStorage.removeItem('tempMaChiNhanh');
            sessionStorage.removeItem('tempMaKhuVuc');

            // Điều hướng sang trang cảm ơn
            window.location.href = '/KhachHang/Order/thankyou.html';
        } else {
            // Hiển thị lỗi nếu API trả về lỗi
            alert(`Lỗi khi đặt hàng: ${result.error}`);
        }
    } catch (error) {
        console.error('Lỗi khi gửi yêu cầu đặt hàng:', error);
        alert('Không thể đặt hàng. Vui lòng thử lại sau.');
    }
});
