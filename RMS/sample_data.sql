-- Script để thêm dữ liệu mẫu cho hệ thống RMS
USE RMS;
GO

-- Thêm roles
INSERT INTO roles (role_name, description, status) VALUES
('Manager', 'Quản lý hệ thống', 'ACTIVE'),
('Waiter', 'Nhân viên phục vụ', 'ACTIVE'),
('Chef', 'Đầu bếp', 'ACTIVE'),
('Receptionist', 'Lễ tân', 'ACTIVE'),
('Cashier', 'Thu ngân', 'ACTIVE'),
('Supervisor', 'Giám sát', 'ACTIVE');
GO

-- Thêm permissions
INSERT INTO permissions (permission_name, description, module, action) VALUES
('STAFF_CREATE', 'Tạo nhân viên mới', 'STAFF', 'CREATE'),
('STAFF_READ', 'Xem thông tin nhân viên', 'STAFF', 'READ'),
('STAFF_UPDATE', 'Cập nhật thông tin nhân viên', 'STAFF', 'UPDATE'),
('STAFF_DEACTIVATE', 'Vô hiệu hóa nhân viên', 'STAFF', 'DEACTIVATE'),
('ORDER_CREATE', 'Tạo đơn hàng', 'ORDER', 'CREATE'),
('ORDER_READ', 'Xem đơn hàng', 'ORDER', 'READ'),
('ORDER_UPDATE', 'Cập nhật đơn hàng', 'ORDER', 'UPDATE'),
('MENU_READ', 'Xem thực đơn', 'MENU', 'READ'),
('MENU_UPDATE', 'Cập nhật thực đơn', 'MENU', 'UPDATE');
GO

-- Gán permissions cho roles
-- Manager có tất cả quyền
INSERT INTO role_permissions (role_id, permission_id)
SELECT 1, permission_id FROM permissions;
GO

-- Waiter có quyền đơn hàng và thực đơn
INSERT INTO role_permissions (role_id, permission_id)
SELECT 2, permission_id FROM permissions WHERE module IN ('ORDER', 'MENU') AND action = 'READ';
GO

INSERT INTO role_permissions (role_id, permission_id)
SELECT 2, permission_id FROM permissions WHERE module = 'ORDER' AND action = 'CREATE';
GO

-- Chef có quyền đơn hàng và thực đơn
INSERT INTO role_permissions (role_id, permission_id)
SELECT 3, permission_id FROM permissions WHERE module IN ('ORDER', 'MENU') AND action = 'READ';
GO

-- Tạo admin user mặc định
INSERT INTO users (username, email, password_hash, first_name, last_name, phone, account_status) VALUES
('admin', 'admin@rms.com', 'XgvcL3qb9MCwLUtIEOhZwA==:jENIb93KR+EMfnXbl/geHrnQBAe9VfMgDQ7ueBvkXwI=', 'Admin', 'System', '0123456789', 'ACTIVE');
GO

-- Tạo staff cho admin
INSERT INTO staff (user_id, first_name, last_name, email, phone, position, hire_date, salary, status) VALUES
(1, 'Admin', 'System', 'admin@rms.com', '0123456789', 'Manager', GETDATE(), 15000000, 'ACTIVE');
GO

-- Gán role Manager cho admin
INSERT INTO user_roles (user_id, role_id) VALUES (1, 1);
GO

-- Tạo một số nhân viên mẫu
INSERT INTO users (username, email, password_hash, first_name, last_name, phone, account_status) VALUES
('waiter1', 'waiter1@rms.com', 'XgvcL3qb9MCwLUtIEOhZwA==:jENIb93KR+EMfnXbl/geHrnQBAe9VfMgDQ7ueBvkXwI=', 'Nguyễn', 'Văn A', '0123456780', 'ACTIVE'),
('chef1', 'chef1@rms.com', 'XgvcL3qb9MCwLUtIEOhZwA==:jENIb93KR+EMfnXbl/geHrnQBAe9VfMgDQ7ueBvkXwI=', 'Trần', 'Thị B', '0123456781', 'ACTIVE'),
('receptionist1', 'receptionist1@rms.com', 'XgvcL3qb9MCwLUtIEOhZwA==:jENIb93KR+EMfnXbl/geHrnQBAe9VfMgDQ7ueBvkXwI=', 'Lê', 'Văn C', '0123456782', 'ACTIVE');
GO

-- Tạo staff cho các user trên
INSERT INTO staff (user_id, first_name, last_name, email, phone, position, hire_date, salary, status, manager_id) VALUES
(2, 'Nguyễn', 'Văn A', 'waiter1@rms.com', '0123456780', 'Waiter', DATEADD(day, -30, GETDATE()), 8000000, 'ACTIVE', 1),
(3, 'Trần', 'Thị B', 'chef1@rms.com', '0123456781', 'Chef', DATEADD(day, -60, GETDATE()), 12000000, 'ACTIVE', 1),
(4, 'Lê', 'Văn C', 'receptionist1@rms.com', '0123456782', 'Receptionist', DATEADD(day, -15, GETDATE()), 7000000, 'ACTIVE', 1);
GO

-- Gán roles cho các user
INSERT INTO user_roles (user_id, role_id) VALUES 
(2, 2), -- Waiter
(3, 3), -- Chef
(4, 4); -- Receptionist
GO

-- Tạo table areas
INSERT INTO table_area (area_name, sort_order) VALUES
('Tầng 1', 1),
('Tầng 2', 2),
('Khu vực ngoài trời', 3);
GO

-- Tạo một số bàn mẫu
INSERT INTO dining_table (area_id, table_number, capacity, location, status, table_type, map_x, map_y, created_by) VALUES
(1, 'T1-01', 4, 'Gần cửa ra vào', 'VACANT', 'REGULAR', 100, 100, 1),
(1, 'T1-02', 2, 'Góc phòng', 'VACANT', 'REGULAR', 200, 100, 1),
(1, 'T1-03', 6, 'Giữa phòng', 'VACANT', 'REGULAR', 300, 100, 1),
(2, 'T2-01', 4, 'Gần cửa sổ', 'VACANT', 'REGULAR', 100, 200, 1),
(2, 'T2-02', 8, 'Phòng riêng', 'VACANT', 'VIP', 200, 200, 1),
(3, 'T3-01', 4, 'Ngoài trời', 'VACANT', 'OUTDOOR', 100, 300, 1);
GO

-- Tạo menu categories
INSERT INTO menu_categories (category_name, sort_order) VALUES
('Khai vị', 1),
('Món chính', 2),
('Món phụ', 3),
('Tráng miệng', 4),
('Đồ uống', 5);
GO

-- Tạo menu items mẫu
INSERT INTO menu_items (category_id, name, description, base_price, availability, preparation_time, is_active, created_by) VALUES
(1, 'Gỏi cuốn tôm thịt', 'Gỏi cuốn tươi ngon với tôm và thịt', 45000, 'AVAILABLE', 10, 1, 1),
(1, 'Chả cá Lã Vọng', 'Chả cá truyền thống Hà Nội', 65000, 'AVAILABLE', 15, 1, 1),
(2, 'Phở bò tái', 'Phở bò truyền thống', 75000, 'AVAILABLE', 20, 1, 1),
(2, 'Bún chả Hà Nội', 'Bún chả đặc sản Hà Nội', 70000, 'AVAILABLE', 15, 1, 1),
(2, 'Cơm tấm sườn nướng', 'Cơm tấm miền Nam', 60000, 'AVAILABLE', 12, 1, 1),
(3, 'Rau muống xào tỏi', 'Rau muống xào tỏi thơm ngon', 25000, 'AVAILABLE', 5, 1, 1),
(4, 'Chè đậu đỏ', 'Chè đậu đỏ truyền thống', 20000, 'AVAILABLE', 5, 1, 1),
(5, 'Nước cam tươi', 'Nước cam vắt tươi', 30000, 'AVAILABLE', 2, 1, 1),
(5, 'Cà phê đen', 'Cà phê đen đậm đà', 15000, 'AVAILABLE', 2, 1, 1);
GO

PRINT 'Dữ liệu mẫu đã được thêm thành công!';
PRINT 'Tài khoản admin: admin@rms.com / test';
PRINT 'Tài khoản waiter: waiter1@rms.com / test';
PRINT 'Tài khoản chef: chef1@rms.com / test';
PRINT 'Tài khoản receptionist: receptionist1@rms.com / test';
