-- Database schema for Order Management and Kitchen Display System
-- @author donny

USE [RMS]
GO

-- 1. Orders table
IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='orders' AND xtype='U')
BEGIN
    CREATE TABLE [dbo].[orders](
        [order_id] [bigint] IDENTITY(1,1) NOT NULL,
        [order_type] [nvarchar](20) NOT NULL,
        [table_id] [int] NULL,
        [waiter_id] [int] NOT NULL,
        [status] [nvarchar](20) NOT NULL,
        [subtotal] [decimal](10,2) NOT NULL DEFAULT 0.00,
        [tax_amount] [decimal](10,2) NOT NULL DEFAULT 0.00,
        [total_amount] [decimal](10,2) NOT NULL DEFAULT 0.00,
        [special_instructions] [nvarchar](500) NULL,
        [created_at] [datetime2](0) NOT NULL DEFAULT SYSDATETIME(),
        [updated_at] [datetime2](0) NOT NULL DEFAULT SYSDATETIME(),
        [created_by] [int] NOT NULL,
        [updated_by] [int] NULL,
        CONSTRAINT [PK_orders] PRIMARY KEY CLUSTERED ([order_id] ASC)
    )
END
GO

-- 2. Order Items table
IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='order_items' AND xtype='U')
BEGIN
    CREATE TABLE [dbo].[order_items](
        [order_item_id] [bigint] IDENTITY(1,1) NOT NULL,
        [order_id] [bigint] NOT NULL,
        [menu_item_id] [int] NOT NULL,
        [quantity] [int] NOT NULL,
        [special_instructions] [nvarchar](500) NULL,
        [priority] [nvarchar](20) NOT NULL DEFAULT 'NORMAL',
        [course] [nvarchar](20) NOT NULL DEFAULT 'MAIN',
        [base_unit_price] [decimal](10,2) NOT NULL,
        [final_unit_price] [decimal](10,2) NOT NULL,
        [total_price] [decimal](10,2) NOT NULL,
        [status] [nvarchar](20) NOT NULL DEFAULT 'NEW',
        [created_at] [datetime2](0) NOT NULL DEFAULT SYSDATETIME(),
        [updated_at] [datetime2](0) NOT NULL DEFAULT SYSDATETIME(),
        [created_by] [int] NOT NULL,
        [updated_by] [int] NULL,
        CONSTRAINT [PK_order_items] PRIMARY KEY CLUSTERED ([order_item_id] ASC)
    )
END
GO

-- 3. Kitchen Tickets table
IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='kitchen_tickets' AND xtype='U')
BEGIN
    CREATE TABLE [dbo].[kitchen_tickets](
        [kitchen_ticket_id] [bigint] IDENTITY(1,1) NOT NULL,
        [order_item_id] [bigint] NOT NULL,
        [station] [nvarchar](20) NOT NULL,
        [preparation_status] [nvarchar](20) NOT NULL DEFAULT 'RECEIVED',
        [received_time] [datetime2](0) NOT NULL DEFAULT SYSDATETIME(),
        [start_time] [datetime2](0) NULL,
        [ready_time] [datetime2](0) NULL,
        [picked_time] [datetime2](0) NULL,
        [served_time] [datetime2](0) NULL,
        [notes] [nvarchar](500) NULL,
        [estimated_minutes] [int] NULL,
        [actual_minutes] [int] NULL,
        [created_at] [datetime2](0) NOT NULL DEFAULT SYSDATETIME(),
        [updated_at] [datetime2](0) NOT NULL DEFAULT SYSDATETIME(),
        [created_by] [int] NOT NULL,
        [updated_by] [int] NULL,
        CONSTRAINT [PK_kitchen_tickets] PRIMARY KEY CLUSTERED ([kitchen_ticket_id] ASC)
    )
END
GO

-- 4. Pricing Rules table
IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='pricing_rules' AND xtype='U')
BEGIN
    CREATE TABLE [dbo].[pricing_rules](
        [pricing_rule_id] [bigint] IDENTITY(1,1) NOT NULL,
        [rule_name] [nvarchar](100) NOT NULL,
        [rule_type] [nvarchar](20) NOT NULL,
        [day_of_week] [nvarchar](20) NULL,
        [start_time] [time](0) NULL,
        [end_time] [time](0) NULL,
        [adjustment_value] [decimal](10,2) NOT NULL,
        [adjustment_type] [nvarchar](20) NOT NULL,
        [menu_item_id] [int] NULL,
        [category_id] [int] NULL,
        [status] [nvarchar](20) NOT NULL DEFAULT 'ACTIVE',
        [description] [nvarchar](500) NULL,
        [priority] [int] NOT NULL DEFAULT 1,
        [valid_from] [datetime2](0) NULL,
        [valid_to] [datetime2](0) NULL,
        [created_at] [datetime2](0) NOT NULL DEFAULT SYSDATETIME(),
        [updated_at] [datetime2](0) NOT NULL DEFAULT SYSDATETIME(),
        [created_by] [int] NOT NULL,
        CONSTRAINT [PK_pricing_rules] PRIMARY KEY CLUSTERED ([pricing_rule_id] ASC)
    )
END
GO

-- Add Foreign Key Constraints
-- Orders table
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_orders_table')
BEGIN
    ALTER TABLE [dbo].[orders] 
    ADD CONSTRAINT [FK_orders_table] FOREIGN KEY([table_id]) 
    REFERENCES [dbo].[dining_table] ([table_id])
END
GO

IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_orders_waiter')
BEGIN
    ALTER TABLE [dbo].[orders] 
    ADD CONSTRAINT [FK_orders_waiter] FOREIGN KEY([waiter_id]) 
    REFERENCES [dbo].[users] ([user_id])
END
GO

-- Order Items table
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_order_items_order')
BEGIN
    ALTER TABLE [dbo].[order_items] 
    ADD CONSTRAINT [FK_order_items_order] FOREIGN KEY([order_id]) 
    REFERENCES [dbo].[orders] ([order_id]) ON DELETE CASCADE
END
GO

IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_order_items_menu')
BEGIN
    ALTER TABLE [dbo].[order_items] 
    ADD CONSTRAINT [FK_order_items_menu] FOREIGN KEY([menu_item_id]) 
    REFERENCES [dbo].[menu_items] ([item_id])
END
GO

-- Kitchen Tickets table
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_kitchen_tickets_order_item')
BEGIN
    ALTER TABLE [dbo].[kitchen_tickets] 
    ADD CONSTRAINT [FK_kitchen_tickets_order_item] FOREIGN KEY([order_item_id]) 
    REFERENCES [dbo].[order_items] ([order_item_id]) ON DELETE CASCADE
END
GO

-- Pricing Rules table
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_pricing_rules_menu_item')
BEGIN
    ALTER TABLE [dbo].[pricing_rules] 
    ADD CONSTRAINT [FK_pricing_rules_menu_item] FOREIGN KEY([menu_item_id]) 
    REFERENCES [dbo].[menu_items] ([item_id])
END
GO

IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_pricing_rules_category')
BEGIN
    ALTER TABLE [dbo].[pricing_rules] 
    ADD CONSTRAINT [FK_pricing_rules_category] FOREIGN KEY([category_id]) 
    REFERENCES [dbo].[menu_categories] ([category_id])
END
GO

-- Insert sample pricing rules
INSERT INTO [dbo].[pricing_rules] 
([rule_name], [rule_type], [day_of_week], [start_time], [end_time], [adjustment_value], [adjustment_type], [status], [description], [priority], [created_by])
VALUES
('Happy Hour - 20% Off', 'PERCENTAGE', 'WEEKDAY', '15:00:00', '17:00:00', 20.00, 'DECREASE', 'ACTIVE', 'Happy hour discount for weekdays 3-5 PM', 1, 1),
('Weekend Premium - 10% Up', 'PERCENTAGE', 'WEEKEND', NULL, NULL, 10.00, 'INCREASE', 'ACTIVE', 'Weekend premium pricing', 2, 1),
('Late Night - 15% Off', 'PERCENTAGE', 'WEEKDAY', '21:00:00', '23:59:59', 15.00, 'DECREASE', 'ACTIVE', 'Late night discount after 9 PM', 3, 1),
('Holiday Premium - 25% Up', 'PERCENTAGE', 'HOLIDAY', NULL, NULL, 25.00, 'INCREASE', 'ACTIVE', 'Holiday premium pricing', 1, 1);

-- Create indexes for better performance
CREATE NONCLUSTERED INDEX [IX_orders_table_status] ON [dbo].[orders] ([table_id], [status])
GO

CREATE NONCLUSTERED INDEX [IX_orders_waiter_status] ON [dbo].[orders] ([waiter_id], [status])
GO

CREATE NONCLUSTERED INDEX [IX_order_items_order_status] ON [dbo].[order_items] ([order_id], [status])
GO

CREATE NONCLUSTERED INDEX [IX_kitchen_tickets_station_status] ON [dbo].[kitchen_tickets] ([station], [preparation_status])
GO

CREATE NONCLUSTERED INDEX [IX_pricing_rules_active] ON [dbo].[pricing_rules] ([status], [priority])
GO

PRINT 'Order Management and Kitchen Display System schema created successfully!'
