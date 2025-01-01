    /* GIỎ HÀNG */
    const cartItems = []; // Mảng chứa các món trong giỏ

    // Lấy các phần tử HTML cần thiết
    const cartSidebar = document.getElementById('cartSidebar');
    const toggleCartButton = document.getElementById('toggleCart');
    const closeCartButton = document.getElementById('closeCart');

    // Mở sidebar và ẩn nút "Giỏ Hàng"
    toggleCartButton.addEventListener('click', () => {
        cartSidebar.classList.add('open');
        toggleCartButton.style.display = 'none';
    });

    // Đóng sidebar và hiện lại nút "Giỏ Hàng"
    closeCartButton.addEventListener('click', () => {
        cartSidebar.classList.remove('open');
        toggleCartButton.style.display = 'block';
    });

    // Hàm reset giỏ hàng
    function resetCart() {
        sessionStorage.removeItem('cartItems'); // Xóa giỏ hàng khỏi sessionStorage

        // Cập nhật giao diện giỏ hàng
        const cartList = document.getElementById('cartItems');
        const cartTotal = document.getElementById('cartTotal');
        if (cartList) cartList.innerHTML = '<p>Giỏ hàng trống.</p>';
        if (cartTotal) cartTotal.textContent = 'Tổng cộng: 0 VND';
    }

    // Hàm thêm món vào giỏ hàng
    function addToCart(item) {
        // Kiểm tra xem món đã tồn tại trong giỏ chưa
        const existingItem = cartItems.find(cartItem => cartItem.MaMon === item.MaMon);

        if (existingItem) {
            // Nếu đã tồn tại, tăng số lượng
            existingItem.quantity += 1;
        } else {
            // Nếu chưa tồn tại, thêm món mới với số lượng là 1
            cartItems.push({ ...item, quantity: 1 });
        }

        // Cập nhật giao diện giỏ hàng
        updateCartDisplay();

        // Hiển thị thông báo (có thể tùy chỉnh)
        alert(`${item.TenMon} đã được thêm vào giỏ hàng!`);
    }

    // Hàm tăng số lượng món
    function increaseQuantity(index) {
        cartItems[index].quantity += 1;
        updateCartDisplay(); // Cập nhật lại giao diện
    }

    // Hàm giảm số lượng món
    function decreaseQuantity(index) {
        if (cartItems[index].quantity > 1) {
            cartItems[index].quantity -= 1;
        } else {
            // Nếu số lượng là 1, hỏi người dùng có muốn xóa món không
            const confirmDelete = confirm("Bạn có muốn xóa món này khỏi giỏ hàng?");
            if (confirmDelete) {
                cartItems.splice(index, 1); // Xóa món
            }
        }
        updateCartDisplay(); // Cập nhật lại giao diện
    }

    function updateCartDisplay() {
        const cartList = document.getElementById('cartItems');
        const cartTotal = document.getElementById('cartTotal');
        cartList.innerHTML = ''; // Xóa nội dung cũ
        let total = 0;

        cartItems.forEach((item, index) => {
            const li = document.createElement('li');
            li.innerHTML = `
                <img src="https://via.placeholder.com/200" alt="${item.TenMon}" />
                <div>
                    <p>${item.TenMon}</p>
                    <p>${item.GiaHienTai} VND</p>
                    <div class="quantity-controls">
                        <button onclick="decreaseQuantity(${index})" class="quantity-btn">-</button>
                        <span>${item.quantity}</span>
                        <button onclick="increaseQuantity(${index})" class="quantity-btn">+</button>
                    </div>
                </div>
                <button class="remove-btn" onclick="removeFromCart(${index})">&times;</button>
            `;
            cartList.appendChild(li);
            total += item.GiaHienTai * item.quantity;
        });

        // Cập nhật tổng tiền
        cartTotal.textContent = `Tổng cộng: ${total} VND`;
    }


    // Hàm xóa món khỏi giỏ hàng
    function removeFromCart(index) {
        cartItems.splice(index, 1); // Xóa món tại vị trí index
        updateCartDisplay(); // Cập nhật giao diện
    }

    // Lưu trữ tạm thời trong session 
    // Hàm lưu giỏ hàng vào sessionStorage
    function saveCartToSessionStorage() {
        sessionStorage.setItem('cartItems', JSON.stringify(cartItems));
    }

    // Hàm lưu thông tin mã chi nhánh và khu vực tạm thời
    function saveTemporarySelection(maChiNhanh, maKhuVuc) {
        sessionStorage.setItem('tempMaChiNhanh', maChiNhanh);
        sessionStorage.setItem('tempMaKhuVuc', maKhuVuc);
        console.log('Lưu tạm thời thông tin:', { maChiNhanh, maKhuVuc });
    }
    
    // Hàm xóa thông tin tạm thời
    function clearTemporarySelection() {
        sessionStorage.removeItem('tempMaChiNhanh');
        sessionStorage.removeItem('tempMaKhuVuc');
        console.log('Đã xóa thông tin tạm thời.');
    }

    // Hàm chuyển hướng sang trang giao hàng
    function proceedToCheckout() {
        saveCartToSessionStorage(); // Lưu giỏ hàng vào sessionStorage
        const maChiNhanh = sessionStorage.getItem('maChiNhanh');
        const maKhuVuc = sessionStorage.getItem('maKhuVuc');

        if (!maChiNhanh || !maKhuVuc) {
            alert('Vui lòng chọn khu vực và chi nhánh trước khi thanh toán!');
            return;
        }
        window.location.href = '/KhachHang/Order/checkout.html'; // Chuyển sang trang giao hàng
    }

     
    // Gắn sự kiện vào nút "Thanh Toán"
    document.addEventListener('DOMContentLoaded', () => {
        const cartSidebar = document.getElementById('cartSidebar');
        const toggleCartButton = document.getElementById('toggleCart');
        const closeCartButton = document.getElementById('closeCart');
        const checkoutButton = document.getElementById('checkoutButton');
    
        if (toggleCartButton && closeCartButton && checkoutButton) {
            // Mở sidebar
            toggleCartButton.addEventListener('click', () => {
                cartSidebar.classList.add('open');
                toggleCartButton.style.display = 'none';
            });
    
            // Đóng sidebar
            closeCartButton.addEventListener('click', () => {
                cartSidebar.classList.remove('open');
                toggleCartButton.style.display = 'block';
            });
    
            // Chuyển sang trang thanh toán
            checkoutButton.addEventListener('click', proceedToCheckout);
        } else {
            console.error("Một hoặc nhiều phần tử của giỏ hàng không được tìm thấy!");
        }
    });

