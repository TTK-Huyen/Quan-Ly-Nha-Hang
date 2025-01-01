// Hàm load danh mục từ API và thêm vào sidebar
async function loadMenuCategories() {
    try {
        const response = await fetch('/api/MucThucDon');
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


