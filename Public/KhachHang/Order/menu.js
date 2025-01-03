// Hàm load danh mục từ API và thêm vào sidebar
async function loadMenuCategories() {
    try {
        const response = await fetch('/api/MucThucDon');
        console.log(response)
        const categories = await response.json();

        const menuCategories = document.getElementById('menuCategories');
        menuCategories.innerHTML = ''; // Xóa nội dung cũ nếu có

        categories.forEach(category => {
            const li = document.createElement('li');
            li.innerHTML = `<a href="#category-${category.MaMuc}">${category.TenMuc}</a>`;
            menuCategories.appendChild(li);

        });

    } catch (error) {
        console.error('Error loading menu categories:', error);
        alert('Không thể tải danh sách danh mục. Vui lòng thử lại.');
    }
} 

// Gọi hàm khi DOM đã tải xong
document.addEventListener('DOMContentLoaded', loadMenuCategories);


// // Định nghĩa các biến DOM
const searchContainer = document.getElementById('searchContainer');
const searchInput = document.getElementById('searchInput');

async function getTenMuc(maMuc) {
    try {
        const response = await fetch(`/api/getTenMuc?MaMuc=${maMuc}`);
        const data = await response.json();
        console.log(`Tên Mục cho MaMuc ${maMuc}:`, data.TenMuc || 'Không xác định');
        return data.TenMuc || 'Không xác định'; // Trả về tên mục hoặc fallback
    } catch (error) {
        console.error(`Lỗi khi lấy tên mục cho MaMuc ${maMuc}:`, error);
        return 'Không xác định'; // Trường hợp lỗi
    }
}



async function loadMenuByKhuVuc(maKhuVuc = null) {
    try {
        const response = await fetch('/api/ThucDonMon?khuVuc=' + (maKhuVuc || ''));
        const menuItems = await response.json();

        const menuContainer = document.getElementById('menuItems');
        menuContainer.innerHTML = ''; // Xóa nội dung cũ

        const groupedItems = {};
        menuItems.forEach(item => {
            if (!groupedItems[item.MaMuc]) {
                groupedItems[item.MaMuc] = [];
            }
            groupedItems[item.MaMuc].push(item);
        });

        for (const MaMuc in groupedItems) {
            const groupDiv = document.createElement('div');
            groupDiv.className = 'menu-group';
            groupDiv.id = `category-${MaMuc}`;

            const groupTitle = document.createElement('h3');
            groupTitle.textContent = groupedItems[MaMuc][0]?.TenMuc || 'Không xác định';
            groupDiv.appendChild(groupTitle);

            const itemsContainer = document.createElement('div');
            itemsContainer.className = 'menu-items';

            groupedItems[MaMuc].forEach(item => {
                const div = document.createElement('div');
                div.className = 'menu-item';
                div.innerHTML = `
                    <img src="https://via.placeholder.com/200" alt="${item.TenMon}" />
                    <h4>${item.TenMon}</h4>
                    <p>${item.GiaHienTai} VND</p>
                    <button class="btn">Add to Cart</button>
                `;

                // Gắn sự kiện Add to Cart
                const addToCartButton = div.querySelector('.btn');
                addToCartButton.addEventListener('click', () => addToCart(item));

                itemsContainer.appendChild(div);
            });

            groupDiv.appendChild(itemsContainer);
            menuContainer.appendChild(groupDiv);
        }
    } catch (error) {
        console.error('Error loading menu items:', error);
    }
}

function checkSelectionsAndLoadMenu() {
    const khuVuc = document.getElementById('khuVucDropdown').value;
    const chiNhanh = document.getElementById('chiNhanhDropdown').value;
    if (khuVuc && chiNhanh) {
        console.log(`Khu vực: ${khuVuc}, Chi nhánh: ${chiNhanh} đã được chọn.`);
        // Lưu thông tin lần chọn cuối vào sessionStorage
        saveBranchAndRegion(chiNhanh, khuVuc);
        loadMenuByKhuVuc(khuVuc); // Gọi hàm load menu
    } else {
        console.log('Chưa chọn đủ khu vực và chi nhánh.');
        document.getElementById('menuItems').innerHTML = '<p>Vui lòng chọn khu vực và chi nhánh để xem thực đơn.</p>';
    }
}
function updateMenuDisplay(menuItems) {
    const menuContainer = document.getElementById('menuItems');
    menuContainer.innerHTML = ''; // Xóa nội dung cũ

    if (menuItems.length === 0) {
        menuContainer.innerHTML = '<p>Không tìm thấy món ăn phù hợp.</p>';
        return;
    }

    // Nhóm dữ liệu theo MaMuc
    const groupedItems = {};
    menuItems.forEach(item => {
        if (!groupedItems[item.MaMuc]) {
            groupedItems[item.MaMuc] = [];
        }
        groupedItems[item.MaMuc].push(item);
    });

    // Hiển thị dữ liệu theo nhóm
    for (const MaMuc in groupedItems) {
        const groupDiv = document.createElement('div');
        groupDiv.className = 'menu-group';
        groupDiv.id = `category-${MaMuc}`;

        const groupTitle = document.createElement('h3');
        groupTitle.textContent = groupedItems[MaMuc][0]?.TenMuc || 'Không xác định';
        groupDiv.appendChild(groupTitle);

        const itemsContainer = document.createElement('div');
        itemsContainer.className = 'menu-items';

        groupedItems[MaMuc].forEach(item => {
            const div = document.createElement('div');
            div.className = 'menu-item';
            div.innerHTML = `
                <img src="https://via.placeholder.com/200" alt="${item.TenMon}" />
                <h4>${item.TenMon}</h4>
                <p>${item.GiaHienTai} VND</p>
                <button class="btn" onclick='addToCart(${JSON.stringify(item)})'>Add to Cart</button>
            `;
            itemsContainer.appendChild(div);
        });

        groupDiv.appendChild(itemsContainer);
        menuContainer.appendChild(groupDiv);
    }
}

searchInput.addEventListener('input', async () => {
    const searchValue = searchInput.value;
    const maKhuVuc = sessionStorage.getItem('maKhuVuc');
    const maChiNhanh = sessionStorage.getItem('maChiNhanh');
    console.log('MaKhuVuchientai:', maKhuVuc);
    console.log('MaChiNhanhhientai:', maChiNhanh);
    // Kiểm tra nếu chưa chọn khu vực hoặc chi nhánh
    if (!maKhuVuc || !maChiNhanh) {
        alert('Vui lòng chọn khu vực và chi nhánh trước khi tìm kiếm.');
        return;
    }

    // Gửi yêu cầu API
    try {
        const response = await fetch(`/api/search-menu?MaKhuVuc=${maKhuVuc}&MaChiNhanh=${maChiNhanh}&q=${encodeURIComponent(searchValue)}`);
        const menuItems = await response.json();
        console.log('Kết quả tìm kiếm:', menuItems);
        // Hiển thị kết quả tìm kiếm
        updateMenuDisplay(menuItems);
    } catch (error) {
        console.error('Lỗi khi tìm kiếm món ăn:', error);
        alert('Không thể tìm kiếm món ăn. Vui lòng thử lại.');
    }
});

function filterMenuItems(searchValue) {
    // Lấy tất cả các món ăn hiển thị trên giao diện
    const menuItems = document.querySelectorAll('.menu-item');

    menuItems.forEach(item => {
        // Lấy tên món ăn từ mỗi mục
        const itemName = item.querySelector('h4').textContent.toLowerCase();

        // Kiểm tra nếu tên món ăn khớp với từ khóa tìm kiếm
        if (itemName.includes(searchValue)) {
            item.style.display = 'block'; // Hiển thị món ăn
        } else {
            item.style.display = 'none'; // Ẩn món ăn không khớp
        }
    });
}





