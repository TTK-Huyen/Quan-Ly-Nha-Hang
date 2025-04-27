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
});