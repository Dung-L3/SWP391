-- Complete Sample Data for RMS System
-- @author donny
-- This file contains all sample data for testing the system

USE [RMS]
GO

-- ============================================
-- CLEAR EXISTING DATA (Reverse order of foreign keys)
-- ============================================

-- Delete all related data first
DELETE FROM audit_log;
DELETE FROM kitchen_tickets;
DELETE FROM order_item_modifiers;
DELETE FROM order_items;
DELETE FROM orders;
DELETE FROM table_session;
DELETE FROM bill_items;
DELETE FROM bills;
DELETE FROM table_action_log;
DELETE FROM reservations;
DELETE FROM customers;
DELETE FROM dining_table;
DELETE FROM table_area;

DELETE FROM role_permissions;
DELETE FROM user_roles;
-- Only delete staff if no foreign key constraints
BEGIN TRY
    DELETE FROM staff;
END TRY
BEGIN CATCH
    PRINT 'Could not delete staff due to foreign key constraints'
END CATCH

-- Only delete users if no foreign key constraints
BEGIN TRY
    DELETE FROM users;
END TRY
BEGIN CATCH
    PRINT 'Could not delete users due to foreign key constraints'
END CATCH

DELETE FROM permissions;
DELETE FROM roles;

DELETE FROM menu_item_modifiers;
DELETE FROM menu_items;
DELETE FROM menu_categories;

-- Reset identity columns
-- Only reset if tables are empty, otherwise reseed to current max
IF (SELECT COUNT(*) FROM roles) = 0
    DBCC CHECKIDENT ('roles', RESEED, 0);
IF (SELECT COUNT(*) FROM permissions) = 0
    DBCC CHECKIDENT ('permissions', RESEED, 0);
IF (SELECT COUNT(*) FROM users) = 0
    DBCC CHECKIDENT ('users', RESEED, 0);
IF (SELECT COUNT(*) FROM staff) = 0
    DBCC CHECKIDENT ('staff', RESEED, 0);
IF (SELECT COUNT(*) FROM table_area) = 0
    DBCC CHECKIDENT ('table_area', RESEED, 0);
IF (SELECT COUNT(*) FROM dining_table) = 0
    DBCC CHECKIDENT ('dining_table', RESEED, 0);
IF (SELECT COUNT(*) FROM menu_categories) = 0
    DBCC CHECKIDENT ('menu_categories', RESEED, 0);
IF (SELECT COUNT(*) FROM menu_items) = 0
    DBCC CHECKIDENT ('menu_items', RESEED, 0);
IF (SELECT COUNT(*) FROM orders) = 0
    DBCC CHECKIDENT ('orders', RESEED, 0);
IF (SELECT COUNT(*) FROM order_items) = 0
    DBCC CHECKIDENT ('order_items', RESEED, 0);
IF (SELECT COUNT(*) FROM kitchen_tickets) = 0
    DBCC CHECKIDENT ('kitchen_tickets', RESEED, 0);
GO

-- ============================================
-- 1. ROLES AND PERMISSIONS
-- ============================================

-- Insert roles (will get IDs 1, 2, 3, 4)
INSERT INTO roles (role_name, description, status) VALUES
('Manager', 'Quản lý hệ thống', 'ACTIVE'),
('Waiter', 'Nhân viên phục vụ', 'ACTIVE'),
('Chef', 'Đầu bếp', 'ACTIVE'),
('Receptionist', 'Lễ tân (bao gồm thu ngân)', 'ACTIVE');
GO

-- Insert permissions (will get IDs 1-13)
INSERT INTO permissions (permission_name, description, module, action) VALUES
('STAFF_CREATE', 'Tạo nhân viên mới', 'STAFF', 'CREATE'),
('STAFF_READ', 'Xem thông tin nhân viên', 'STAFF', 'READ'),
('STAFF_UPDATE', 'Cập nhật thông tin nhân viên', 'STAFF', 'UPDATE'),
('STAFF_DEACTIVATE', 'Vô hiệu hóa nhân viên', 'STAFF', 'DEACTIVATE'),
('ORDER_CREATE', 'Tạo đơn hàng', 'ORDER', 'CREATE'),
('ORDER_READ', 'Xem đơn hàng', 'ORDER', 'READ'),
('ORDER_UPDATE', 'Cập nhật đơn hàng', 'ORDER', 'UPDATE'),
('MENU_READ', 'Xem thực đơn', 'MENU', 'READ'),
('MENU_UPDATE', 'Cập nhật thực đơn', 'MENU', 'UPDATE'),
('KDS_READ', 'Xem Kitchen Display System', 'KDS', 'READ'),
('KDS_UPDATE', 'Cập nhật trạng thái món ăn', 'KDS', 'UPDATE'),
('TABLE_READ', 'Xem bản đồ bàn', 'TABLE', 'READ'),
('TABLE_UPDATE', 'Cập nhật trạng thái bàn', 'TABLE', 'UPDATE');
GO

-- Gán permissions cho roles
-- Manager (role_id = 1) có tất cả quyền
INSERT INTO role_permissions (role_id, permission_id)
SELECT 1, permission_id FROM permissions;
GO

-- Waiter (role_id = 2) có quyền đơn hàng, thực đơn và bàn
INSERT INTO role_permissions (role_id, permission_id)
SELECT 2, permission_id FROM permissions WHERE module IN ('ORDER', 'MENU', 'TABLE') AND action = 'READ';
GO

INSERT INTO role_permissions (role_id, permission_id)
SELECT 2, permission_id FROM permissions WHERE module = 'ORDER' AND action = 'CREATE';
GO

INSERT INTO role_permissions (role_id, permission_id)
SELECT 2, permission_id FROM permissions WHERE module = 'TABLE' AND action = 'UPDATE';
GO

-- Chef (role_id = 3) có quyền đơn hàng, thực đơn và KDS
INSERT INTO role_permissions (role_id, permission_id)
SELECT 3, permission_id FROM permissions WHERE module IN ('ORDER', 'MENU', 'KDS') AND action = 'READ';
GO

INSERT INTO role_permissions (role_id, permission_id)
SELECT 3, permission_id FROM permissions WHERE module = 'KDS' AND action = 'UPDATE';
GO

-- Receptionist (role_id = 4) có quyền đọc tất cả và update bàn, đơn hàng
INSERT INTO role_permissions (role_id, permission_id)
SELECT 4, permission_id FROM permissions WHERE action = 'READ';
GO

INSERT INTO role_permissions (role_id, permission_id)
SELECT 4, permission_id FROM permissions WHERE module IN ('ORDER', 'TABLE') AND action = 'UPDATE';
GO

-- ============================================
-- 2. USERS AND STAFF
-- ============================================

-- Insert users (will get IDs 1, 2, 3, 4)
-- Password for all users: "test"
-- Hash format: Base64(salt):Base64(SHA256(salt + password))
INSERT INTO users (username, email, password_hash, first_name, last_name, phone, account_status) VALUES
('admin', 'admin@rms.com', 'XgvcL3qb9MCwLUtIEOhZwA==:jENIb93KR+EMfnXbl/geHrnQBAe9VfMgDQ7ueBvkXwI=', 'Admin', 'System', '0123456789', 'ACTIVE'),
('waiter1', 'waiter1@rms.com', 'XgvcL3qb9MCwLUtIEOhZwA==:jENIb93KR+EMfnXbl/geHrnQBAe9VfMgDQ7ueBvkXwI=', 'John', 'Waiter', '0123456789', 'ACTIVE'),
('chef1', 'chef1@rms.com', 'XgvcL3qb9MCwLUtIEOhZwA==:jENIb93KR+EMfnXbl/geHrnQBAe9VfMgDQ7ueBvkXwI=', 'Master', 'Chef', '0123456789', 'ACTIVE'),
('receptionist1', 'receptionist1@rms.com', 'XgvcL3qb9MCwLUtIEOhZwA==:jENIb93KR+EMfnXbl/geHrnQBAe9VfMgDQ7ueBvkXwI=', 'Jane', 'Receptionist', '0123456789', 'ACTIVE');
GO

-- Insert staff (will get IDs 1, 2, 3, 4)
INSERT INTO staff (user_id, first_name, last_name, email, phone, position, hire_date, salary, status) VALUES
(1, 'Admin', 'System', 'admin@rms.com', '0123456789', 'Manager', GETDATE(), 15000000, 'ACTIVE'),
(2, 'John', 'Waiter', 'waiter1@rms.com', '0123456789', 'Waiter', GETDATE(), 8000000, 'ACTIVE'),
(3, 'Master', 'Chef', 'chef1@rms.com', '0123456789', 'Chef', GETDATE(), 12000000, 'ACTIVE'),
(4, 'Jane', 'Receptionist', 'receptionist1@rms.com', '0123456789', 'Receptionist', GETDATE(), 9000000, 'ACTIVE');
GO

-- Gán roles cho users
INSERT INTO user_roles (user_id, role_id, status) VALUES 
(1, 1, 'ACTIVE'), -- admin -> Manager
(2, 2, 'ACTIVE'), -- waiter1 -> Waiter
(3, 3, 'ACTIVE'), -- chef1 -> Chef
(4, 4, 'ACTIVE'); -- receptionist1 -> Receptionist
GO

-- ============================================
-- 3. MENU CATEGORIES AND ITEMS
-- ============================================

-- Insert menu categories (will get IDs 1-5)
INSERT INTO menu_categories (category_name, sort_order) VALUES
('Khai vị', 1),
('Món chính', 2),
('Món phụ', 3),
('Tráng miệng', 4),
('Đồ uống', 5);
GO

-- Insert menu items (will get IDs 1-9)
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

-- ============================================
-- 4. TABLE AREAS AND DINING TABLES
-- ============================================

-- Insert table areas (will get IDs 1-3)
INSERT INTO table_area (area_name, sort_order) VALUES
('Tầng 1', 1),
('Tầng 2', 2),
('Khu vực ngoài trời', 3);
GO

-- Insert dining tables (will get IDs 1-7)
INSERT INTO dining_table (area_id, table_number, capacity, location, status, table_type, map_x, map_y, created_by) VALUES
(1, 'T1-01', 4, 'Gần cửa ra vào', 'VACANT', 'REGULAR', 100, 100, 1),
(1, 'T1-02', 2, 'Góc phòng', 'VACANT', 'REGULAR', 200, 100, 1),
(1, 'T1-03', 6, 'Giữa phòng', 'VACANT', 'REGULAR', 300, 100, 1),
(2, 'T2-01', 4, 'Ban công', 'VACANT', 'REGULAR', 100, 100, 1),
(2, 'T2-02', 2, 'Góc yên tĩnh', 'VACANT', 'REGULAR', 200, 100, 1),
(3, 'T3-01', 8, 'Ngoài trời lớn', 'VACANT', 'VIP', 100, 100, 1),
(3, 'T3-02', 4, 'Ngoài trời nhỏ', 'VACANT', 'REGULAR', 200, 100, 1);
GO

-- ============================================
-- 5. ORDERS, ORDER ITEMS, AND KITCHEN TICKETS
-- ============================================

-- Insert orders (will get IDs 1-3)
INSERT INTO orders (order_code, order_type, table_id, waiter_id, status, notes, opened_at)
VALUES
('ORD001', 'DINE_IN', 1, 2, 'OPEN', 'No special instructions', SYSDATETIME()),
('ORD002', 'DINE_IN', 2, 2, 'SENT_TO_KITCHEN', 'Customer prefers spicy food', SYSDATETIME()),
('ORD003', 'DINE_IN', 3, 2, 'COOKING', 'VIP customer - priority service', SYSDATETIME());
GO

-- Insert order items (will get IDs 1-9)
INSERT INTO order_items (order_id, menu_item_id, quantity, special_instructions, priority, course_no, base_unit_price, final_unit_price, status, created_at)
VALUES
-- Order 1 items
(1, 1, 2, 'Extra spicy', 'NORMAL', 1, 45000, 45000, 'NEW', SYSDATETIME()),
(1, 2, 1, 'No onions', 'NORMAL', 1, 65000, 65000, 'NEW', SYSDATETIME()),
(1, 3, 2, 'Extra ice', 'NORMAL', 1, 75000, 75000, 'NEW', SYSDATETIME()),

-- Order 2 items
(2, 1, 1, 'Medium spicy', 'HIGH', 1, 45000, 45000, 'SENT', SYSDATETIME()),
(2, 4, 1, 'Well done', 'HIGH', 1, 70000, 70000, 'SENT', SYSDATETIME()),
(2, 5, 1, 'Extra cheese', 'NORMAL', 1, 60000, 60000, 'NEW', SYSDATETIME()),

-- Order 3 items
(3, 2, 2, 'Crispy', 'HIGH', 1, 65000, 65000, 'COOKING', SYSDATETIME()),
(3, 6, 1, 'Rare', 'HIGH', 1, 25000, 25000, 'COOKING', SYSDATETIME()),
(3, 7, 1, 'No sugar', 'NORMAL', 1, 30000, 30000, 'READY', SYSDATETIME());
GO

-- Insert kitchen tickets (will get IDs 1-5)
INSERT INTO kitchen_tickets (order_item_id, station, preparation_status, received_time, start_time, ready_time, chef_id)
VALUES
-- Order 2 items (SENT status)
(4, 'HOT', 'RECEIVED', SYSDATETIME(), NULL, NULL, 3),
(5, 'GRILL', 'RECEIVED', SYSDATETIME(), NULL, NULL, 3),

-- Order 3 items (COOKING status)
(7, 'HOT', 'COOKING', DATEADD(MINUTE, -10, SYSDATETIME()), DATEADD(MINUTE, -5, SYSDATETIME()), NULL, 3),
(8, 'GRILL', 'COOKING', DATEADD(MINUTE, -8, SYSDATETIME()), DATEADD(MINUTE, -3, SYSDATETIME()), NULL, 3),

-- Order 3 items (READY status)
(9, 'BEVERAGE', 'READY', DATEADD(MINUTE, -15, SYSDATETIME()), DATEADD(MINUTE, -12, SYSDATETIME()), DATEADD(MINUTE, -2, SYSDATETIME()), 3);
GO

PRINT 'Complete sample data for RMS System has been inserted successfully!'
PRINT 'Users: admin/test (Manager), waiter1/test (Waiter), chef1/test (Chef)'
PRINT 'Password for all users: test'
GO
