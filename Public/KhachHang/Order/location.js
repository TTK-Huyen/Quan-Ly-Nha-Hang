// Load thông tin khu vực

async function loadKhuVucDropdown() {
    try {
        const response = await fetch('/api/KhuVuc'); // Gọi API lấy danh sách khu vực
        const khuVucList = await response.json();

        const dropdown = document.getElementById('khuVucDropdown');
        dropdown.innerHTML = '<option value="">-- Tất cả Khu Vực --</option>'; // Reset dropdown

        // Đổ dữ liệu khu vực vào dropdown
        khuVucList.forEach(khuVuc => {
            const option = document.createElement('option');
            option.value = khuVuc.MaKhuVuc;
            option.textContent = khuVuc.TenKhuVuc;
            dropdown.appendChild(option);
        });
    } catch (error) {
        console.error('Error loading Khu Vuc Dropdown:', error);
        alert('Không thể tải danh sách khu vực.');
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
// Load thông tin chi nhánh theo khu vực
async function loadChiNhanhOptions(khuVucId) {
    try {
        const response = await fetch(`/api/ChiNhanh?MaKhuVuc=${khuVucId}`);
        const chiNhanhList = await response.json();

        const chiNhanhDropdown = document.getElementById('chiNhanhDropdown');
        chiNhanhDropdown.innerHTML = '<option value="">-- Chọn Chi Nhánh --</option>'; // Reset dropdown
        chiNhanhList.forEach(chiNhanh => {
            const option = document.createElement('option');
            option.value = chiNhanh.MaChiNhanh;
            option.textContent = chiNhanh.TenChiNhanh;
            chiNhanhDropdown.appendChild(option);
        });

        console.log(`Danh sách chi nhánh cho khu vực ${khuVucId}:`, chiNhanhList);
    } catch (error) {
        console.error('Lỗi khi tải danh sách chi nhánh:', error);
    }
}

// Reset danh sách chi nhánh khi thay đổi khu vực và reset luôn giỏ hàng
function resetChiNhanhDropdown() {
    const chiNhanhDropdown = document.getElementById('chiNhanhDropdown');
    
    // Reset dropdown chi nhánh
    chiNhanhDropdown.innerHTML = '<option value="">-- Chọn Chi Nhánh --</option>'; // Reset danh sách
    chiNhanhDropdown.disabled = true; // Vô hiệu hóa dropdown
    resetCart(); // Reset giỏ hàng
}



// Load cả Dropdown 
async function loadDropdownAndMenu() {
    await loadKhuVucDropdown(); // Load khu vực vào dropdown
    // loadMenuByKhuVuc(); // Load tất cả món ăn ban đầu
}

function saveBranchAndRegion(maChiNhanh, maKhuVuc) {
    sessionStorage.setItem('maChiNhanh', maChiNhanh);
    sessionStorage.setItem('maKhuVuc', maKhuVuc);
    console.log('Lưu thông tin:', { maChiNhanh, maKhuVuc });
}




// Sự kiện thay đổi khu vực
document.getElementById('khuVucDropdown').addEventListener('change', (e) => {
    const khuVucId = e.target.value;

    if (khuVucId) {
        loadChiNhanhOptions(khuVucId); // Tải danh sách chi nhánh tương ứng
        document.getElementById('chiNhanhDropdown').disabled = false; // Bật dropdown chi nhánh
    } else {
        resetChiNhanhDropdown(); // Reset danh sách chi nhánh
    }

    // Kiểm tra và lưu thông tin
    checkSelectionsAndLoadMenu();
});

// Sự kiện thay đổi chi nhánh
document.getElementById('chiNhanhDropdown').addEventListener('change', (e) => {
    const selectedBranch = e.target.value;

    if (selectedBranch) {
        resetCart(); // Reset giỏ hàng khi thay đổi chi nhánh
    } else {
        alert('Vui lòng chọn chi nhánh.');
    }
});

document.addEventListener('DOMContentLoaded', () => {
    const khuVucDropdown = document.getElementById('khuVucDropdown');
    const chiNhanhDropdown = document.getElementById('chiNhanhDropdown');

    // Lấy thông tin lần chọn cuối
    const savedMaChiNhanh = sessionStorage.getItem('MaChiNhanh');
    const savedMaKhuVuc = sessionStorage.getItem('MaKhuVuc');

    if (khuVucDropdown && chiNhanhDropdown) {
        // Gọi hàm load dropdown khu vực
        loadKhuVucDropdown().then(() => {
            if (savedMaKhuVuc) {
                khuVucDropdown.value = savedMaKhuVuc; // Điền khu vực đã chọn
                loadChiNhanhOptions(savedMaKhuVuc).then(() => {
                    if (savedMaChiNhanh) {
                        chiNhanhDropdown.value = savedMaChiNhanh; // Điền chi nhánh đã chọn
                    }
                });
            }
        });

        // Gắn sự kiện change
        khuVucDropdown.addEventListener('change', (e) => {
            const khuVucId = e.target.value;

            if (khuVucId) {
                loadChiNhanhOptions(khuVucId);
                chiNhanhDropdown.disabled = false;
            } else {
                resetChiNhanhDropdown();
            }

            checkSelectionsAndLoadMenu();
        });

        chiNhanhDropdown.addEventListener('change', checkSelectionsAndLoadMenu);
    } else {
        console.error("Dropdown khu vực hoặc chi nhánh không được tìm thấy!");
    }
});