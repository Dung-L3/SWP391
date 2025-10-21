-- Sample data for Order Management and Kitchen Display System
-- @author donny

USE [RMS]
GO

-- Insert sample orders
INSERT INTO [dbo].[orders] 
([order_type], [table_id], [waiter_id], [status], [subtotal], [tax_amount], [total_amount], [special_instructions], [created_by])
VALUES
('DINE_IN', 1, 1, 'NEW', 0.00, 0.00, 0.00, 'No special instructions', 1),
('DINE_IN', 2, 1, 'CONFIRMED', 0.00, 0.00, 0.00, 'Customer prefers spicy food', 1),
('DINE_IN', 3, 2, 'PREPARING', 0.00, 0.00, 0.00, 'VIP customer - priority service', 2);

-- Insert sample order items
INSERT INTO [dbo].[order_items] 
([order_id], [menu_item_id], [quantity], [special_instructions], [priority], [course], [base_unit_price], [final_unit_price], [total_price], [status], [created_by])
VALUES
-- Order 1 items
(1, 1, 2, 'Extra spicy', 'NORMAL', 'MAIN', 15.99, 15.99, 31.98, 'NEW', 1),
(1, 2, 1, 'No onions', 'NORMAL', 'APPETIZER', 8.99, 8.99, 8.99, 'NEW', 1),
(1, 3, 2, 'Extra ice', 'NORMAL', 'BEVERAGE', 4.99, 4.99, 9.98, 'NEW', 1),

-- Order 2 items
(2, 1, 1, 'Medium spicy', 'HIGH', 'MAIN', 15.99, 15.99, 15.99, 'SENT', 1),
(2, 4, 1, 'Well done', 'HIGH', 'MAIN', 22.99, 22.99, 22.99, 'SENT', 1),
(2, 5, 1, 'Extra cheese', 'NORMAL', 'DESSERT', 6.99, 6.99, 6.99, 'NEW', 1),

-- Order 3 items
(3, 2, 2, 'Crispy', 'URGENT', 'APPETIZER', 8.99, 8.99, 17.98, 'COOKING', 2),
(3, 6, 1, 'Rare', 'URGENT', 'MAIN', 28.99, 28.99, 28.99, 'COOKING', 2),
(3, 7, 1, 'No sugar', 'NORMAL', 'BEVERAGE', 3.99, 3.99, 3.99, 'READY', 2);

-- Insert sample kitchen tickets
INSERT INTO [dbo].[kitchen_tickets] 
([order_item_id], [station], [preparation_status], [received_time], [start_time], [ready_time], [estimated_minutes], [created_by])
VALUES
-- Order 2 items (SENT status)
(4, 'HOT', 'RECEIVED', SYSDATETIME(), NULL, NULL, 15, 1),
(5, 'GRILL', 'RECEIVED', SYSDATETIME(), NULL, NULL, 20, 1),

-- Order 3 items (COOKING status)
(7, 'HOT', 'COOKING', DATEADD(MINUTE, -10, SYSDATETIME()), DATEADD(MINUTE, -5, SYSDATETIME()), NULL, 15, 2),
(8, 'GRILL', 'COOKING', DATEADD(MINUTE, -8, SYSDATETIME()), DATEADD(MINUTE, -3, SYSDATETIME()), NULL, 25, 2),

-- Order 3 items (READY status)
(9, 'BEVERAGE', 'READY', DATEADD(MINUTE, -15, SYSDATETIME()), DATEADD(MINUTE, -12, SYSDATETIME()), DATEADD(MINUTE, -2, SYSDATETIME()), 5, 2);

-- Update order totals
UPDATE [dbo].[orders] 
SET [subtotal] = 50.95, [tax_amount] = 5.10, [total_amount] = 56.05
WHERE [order_id] = 1;

UPDATE [dbo].[orders] 
SET [subtotal] = 45.97, [tax_amount] = 4.60, [total_amount] = 50.57
WHERE [order_id] = 2;

UPDATE [dbo].[orders] 
SET [subtotal] = 50.96, [tax_amount] = 5.10, [total_amount] = 56.06
WHERE [order_id] = 3;

PRINT 'Sample data for Order Management and Kitchen Display System inserted successfully!'
