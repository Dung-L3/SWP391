-- Sample data for Inventory Management System
USE [RMS]
GO

-- =============================================
-- 1. SUPPLIERS (Nhà cung cấp)
-- =============================================
-- Xóa dữ liệu cũ nếu có (chỉ xóa nếu muốn insert lại từ đầu)
-- DELETE FROM [dbo].[suppliers] WHERE [supplier_id] IN (1, 2, 3, 4);
-- GO

SET IDENTITY_INSERT [dbo].[suppliers] ON
GO

-- Sử dụng MERGE để tránh insert trùng
MERGE [dbo].[suppliers] AS target
USING (VALUES
    (1, N'Công ty Thực phẩm Sạch Việt', N'Nguyễn Văn A', N'contact@thucphamsach.vn', N'0901234567', N'123 Trần Hưng Đạo, Hà Nội', N'ACTIVE', 1),
    (2, N'Công ty Rau Củ Đà Lạt', N'Trần Thị B', N'dalat@raucu.vn', N'0902345678', N'456 Lê Lợi, Đà Lạt', N'ACTIVE', 1),
    (3, N'Công ty Thịt Tươi Sạch', N'Lê Văn C', N'info@thittuoi.vn', N'0903456789', N'789 Nguyễn Huệ, TP.HCM', N'ACTIVE', 1),
    (4, N'Công ty Gia Vị Việt Nam', N'Phạm Thị D', N'sales@giavi.vn', N'0904567890', N'321 Hai Bà Trưng, Hà Nội', N'ACTIVE', 1)
) AS source ([supplier_id], [company_name], [contact_person], [email], [phone], [address], [status], [created_by])
ON target.[supplier_id] = source.[supplier_id]
WHEN NOT MATCHED THEN
    INSERT ([supplier_id], [company_name], [contact_person], [email], [phone], [address], [status], [created_by])
    VALUES (source.[supplier_id], source.[company_name], source.[contact_person], source.[email], source.[phone], source.[address], source.[status], source.[created_by]);
GO

SET IDENTITY_INSERT [dbo].[suppliers] OFF
GO

-- =============================================
-- 2. INVENTORY ITEMS (Nguyên liệu)
-- =============================================
-- Xóa dữ liệu cũ nếu có (chỉ xóa nếu muốn insert lại từ đầu)
-- DELETE FROM [dbo].[inventory_items] WHERE [item_id] BETWEEN 1 AND 30;
-- GO

SET IDENTITY_INSERT [dbo].[inventory_items] ON
GO

-- Sử dụng MERGE để tránh insert trùng
MERGE [dbo].[inventory_items] AS target
USING (VALUES
-- Thịt
(1, N'Thịt bò úc', N'Thịt', N'kg', 50.000, 10.000, 250000, 3, NULL, N'ACTIVE', 1),
(2, N'Thịt heo ba chỉ', N'Thịt', N'kg', 40.000, 10.000, 120000, 3, NULL, N'ACTIVE', 1),
(3, N'Thịt gà', N'Thịt', N'kg', 30.000, 8.000, 80000, 3, NULL, N'ACTIVE', 1),
(4, N'Tôm sú', N'Hải sản', N'kg', 15.000, 5.000, 350000, 3, NULL, N'ACTIVE', 1),
(5, N'Cá lóc', N'Hải sản', N'kg', 20.000, 5.000, 150000, 3, NULL, N'ACTIVE', 1),

-- Rau củ
(6, N'Rau muống', N'Rau củ', N'kg', 25.000, 5.000, 15000, 2, NULL, N'ACTIVE', 1),
(7, N'Rau xà lách', N'Rau củ', N'kg', 20.000, 5.000, 20000, 2, NULL, N'ACTIVE', 1),
(8, N'Cà chua', N'Rau củ', N'kg', 30.000, 5.000, 25000, 2, NULL, N'ACTIVE', 1),
(9, N'Hành tây', N'Rau củ', N'kg', 15.000, 3.000, 18000, 2, NULL, N'ACTIVE', 1),
(10, N'Tỏi', N'Rau củ', N'kg', 10.000, 2.000, 45000, 2, NULL, N'ACTIVE', 1),
(11, N'Gừng', N'Rau củ', N'kg', 8.000, 2.000, 35000, 2, NULL, N'ACTIVE', 1),

-- Gia vị & Nước chấm
(12, N'Nước mắm', N'Gia vị', N'lít', 50.000, 10.000, 35000, 4, NULL, N'ACTIVE', 1),
(13, N'Dầu ăn', N'Gia vị', N'lít', 40.000, 10.000, 45000, 4, NULL, N'ACTIVE', 1),
(14, N'Muối', N'Gia vị', N'kg', 30.000, 5.000, 8000, 4, NULL, N'ACTIVE', 1),
(15, N'Đường', N'Gia vị', N'kg', 25.000, 5.000, 18000, 4, NULL, N'ACTIVE', 1),
(16, N'Tiêu', N'Gia vị', N'kg', 5.000, 1.000, 120000, 4, NULL, N'ACTIVE', 1),

-- Bánh & Bột
(17, N'Bún tươi', N'Bột', N'kg', 40.000, 10.000, 25000, 1, NULL, N'ACTIVE', 1),
(18, N'Bánh phở', N'Bột', N'kg', 50.000, 10.000, 22000, 1, NULL, N'ACTIVE', 1),
(19, N'Bánh tráng', N'Bột', N'kg', 20.000, 5.000, 35000, 1, NULL, N'ACTIVE', 1),
(20, N'Cơm tấm', N'Bột', N'kg', 100.000, 20.000, 18000, 1, NULL, N'ACTIVE', 1),

-- Đồ uống
(21, N'Cà phê hạt', N'Đồ uống', N'kg', 15.000, 3.000, 280000, 4, NULL, N'ACTIVE', 1),
(22, N'Sữa đặc', N'Đồ uống', N'hộp', 50.000, 10.000, 15000, 1, NULL, N'ACTIVE', 1),
(23, N'Cam tươi', N'Đồ uống', N'kg', 40.000, 10.000, 35000, 2, NULL, N'ACTIVE', 1),
(24, N'Đá viên', N'Đồ uống', N'kg', 200.000, 50.000, 5000, 1, NULL, N'ACTIVE', 1),

-- Khác
(25, N'Hành lá', N'Rau gia vị', N'kg', 8.000, 2.000, 25000, 2, NULL, N'ACTIVE', 1),
(26, N'Ngò rí', N'Rau gia vị', N'kg', 6.000, 1.000, 30000, 2, NULL, N'ACTIVE', 1),
(27, N'Chanh', N'Trái cây', N'kg', 20.000, 5.000, 28000, 2, NULL, N'ACTIVE', 1),
(28, N'Đậu đỏ', N'Đậu', N'kg', 25.000, 5.000, 45000, 1, NULL, N'ACTIVE', 1),
(29, N'Nước dùng phở (cô đặc)', N'Nước dùng', N'lít', 30.000, 10.000, 55000, 1, NULL, N'ACTIVE', 1),
(30, N'Sườn heo', N'Thịt', N'kg', 35.000, 8.000, 135000, 3, NULL, N'ACTIVE', 1)
) AS source ([item_id], [item_name], [category], [uom], [current_stock], [minimum_stock], [unit_cost], [supplier_id], [expiry_date], [status], [created_by])
ON target.[item_id] = source.[item_id]
WHEN NOT MATCHED THEN
    INSERT ([item_id], [item_name], [category], [uom], [current_stock], [minimum_stock], [unit_cost], [supplier_id], [expiry_date], [status], [created_by])
    VALUES (source.[item_id], source.[item_name], source.[category], source.[uom], source.[current_stock], source.[minimum_stock], source.[unit_cost], source.[supplier_id], source.[expiry_date], source.[status], source.[created_by]);
GO

SET IDENTITY_INSERT [dbo].[inventory_items] OFF
GO

-- =============================================
-- 3. RECIPES (Công thức món ăn)
-- =============================================
-- Xóa dữ liệu cũ nếu có
DELETE FROM [dbo].[recipe_items];
DELETE FROM [dbo].[recipes];
GO

-- Reset IDENTITY seed
DBCC CHECKIDENT ('[dbo].[recipes]', RESEED, 0);
DBCC CHECKIDENT ('[dbo].[recipe_items]', RESEED, 0);
GO

SET IDENTITY_INSERT [dbo].[recipes] ON
GO

-- Công thức cho các món đã có (dựa vào menu_items)
-- menu_item_id 1: Gỏi cuốn tôm thịt
-- menu_item_id 2: Chả cá Lã Vọng
-- menu_item_id 3: Phở bò tái
-- menu_item_id 4: Bún chả Hà Nội
-- menu_item_id 5: Cơm tấm sườn nướng
-- menu_item_id 6: Rau muống xào tỏi
-- menu_item_id 7: Chè đậu đỏ
-- menu_item_id 8: Nước cam tươi
-- menu_item_id 9: Cà phê đen

INSERT INTO [dbo].[recipes] ([recipe_id], [menu_item_id], [version], [is_active], [note])
VALUES
(1, 1, 1, 1, N'Công thức Gỏi cuốn tôm thịt'),
(2, 3, 1, 1, N'Công thức Phở bò tái'),
(3, 4, 1, 1, N'Công thức Bún chả Hà Nội'),
(4, 5, 1, 1, N'Công thức Cơm tấm sườn nướng'),
(5, 6, 1, 1, N'Công thức Rau muống xào tỏi'),
(6, 7, 1, 1, N'Công thức Chè đậu đỏ'),
(7, 8, 1, 1, N'Công thức Nước cam tươi'),
(8, 9, 1, 1, N'Công thức Cà phê đen');

SET IDENTITY_INSERT [dbo].[recipes] OFF
GO

-- =============================================
-- 4. RECIPE ITEMS (Chi tiết nguyên liệu trong công thức)
-- =============================================
SET IDENTITY_INSERT [dbo].[recipe_items] ON
GO

INSERT INTO [dbo].[recipe_items] ([recipe_item_id], [recipe_id], [item_id], [qty])
VALUES
-- Recipe 1: Gỏi cuốn tôm thịt (6 cuốn)
(1, 1, 4, 0.150),   -- Tôm sú: 150g
(2, 1, 2, 0.100),   -- Thịt heo: 100g
(3, 1, 19, 0.050),  -- Bánh tráng: 50g (6 tờ)
(4, 1, 7, 0.100),   -- Rau xà lách: 100g
(5, 1, 25, 0.020),  -- Hành lá: 20g
(6, 1, 26, 0.010),  -- Ngò rí: 10g

-- Recipe 2: Phở bò tái (1 tô)
(7, 2, 1, 0.200),   -- Thịt bò: 200g
(8, 2, 18, 0.300),  -- Bánh phở: 300g
(9, 2, 29, 0.500),  -- Nước dùng phở: 500ml
(10, 2, 9, 0.050),  -- Hành tây: 50g
(11, 2, 25, 0.020), -- Hành lá: 20g
(12, 2, 26, 0.010), -- Ngò rí: 10g
(13, 2, 11, 0.010), -- Gừng: 10g

-- Recipe 3: Bún chả Hà Nội (1 suất)
(14, 3, 2, 0.200),  -- Thịt heo: 200g
(15, 3, 17, 0.300), -- Bún tươi: 300g
(16, 3, 12, 0.030), -- Nước mắm: 30ml
(17, 3, 15, 0.020), -- Đường: 20g
(18, 3, 8, 0.100),  -- Cà chua: 100g
(19, 3, 27, 0.030), -- Chanh: 30g

-- Recipe 4: Cơm tấm sườn nướng (1 suất)
(20, 4, 30, 0.250), -- Sườn heo: 250g
(21, 4, 20, 0.300), -- Cơm tấm: 300g
(22, 4, 8, 0.050),  -- Cà chua: 50g
(23, 4, 12, 0.020), -- Nước mắm: 20ml
(24, 4, 15, 0.015), -- Đường: 15g

-- Recipe 5: Rau muống xào tỏi (1 đĩa)
(25, 5, 6, 0.300),  -- Rau muống: 300g
(26, 5, 10, 0.020), -- Tỏi: 20g
(27, 5, 13, 0.020), -- Dầu ăn: 20ml
(28, 5, 14, 0.005), -- Muối: 5g
(29, 5, 12, 0.010), -- Nước mắm: 10ml

-- Recipe 6: Chè đậu đỏ (1 bát)
(30, 6, 28, 0.100), -- Đậu đỏ: 100g
(31, 6, 15, 0.050), -- Đường: 50g
(32, 6, 22, 0.050), -- Sữa đặc: 50ml

-- Recipe 7: Nước cam tươi (1 ly)
(33, 7, 23, 0.200), -- Cam tươi: 200g (2-3 trái)
(34, 7, 15, 0.015), -- Đường: 15g
(35, 7, 24, 0.050), -- Đá viên: 50g

-- Recipe 8: Cà phê đen (1 ly)
(36, 8, 21, 0.020), -- Cà phê hạt: 20g
(37, 8, 15, 0.010), -- Đường: 10g
(38, 8, 24, 0.050); -- Đá viên: 50g

SET IDENTITY_INSERT [dbo].[recipe_items] OFF
GO

PRINT N'✅ Đã thêm thành công:'
PRINT N'   - 4 nhà cung cấp'
PRINT N'   - 30 nguyên liệu'
PRINT N'   - 8 công thức món ăn'
PRINT N'   - 38 chi tiết nguyên liệu trong công thức'
GO

