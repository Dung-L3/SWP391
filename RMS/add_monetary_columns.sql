-- Add missing monetary columns to orders table (only if they don't exist)
USE RMS;
GO

-- Check and add subtotal column
IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS 
               WHERE TABLE_SCHEMA = 'dbo' 
               AND TABLE_NAME = 'orders' 
               AND COLUMN_NAME = 'subtotal')
BEGIN
    ALTER TABLE [dbo].[orders]
    ADD [subtotal] [decimal](12, 2) NULL;
    ALTER TABLE [dbo].[orders]
    ADD CONSTRAINT [DF_orders_subtotal] DEFAULT 0 FOR [subtotal];
    PRINT 'Added column: subtotal';
END
ELSE
BEGIN
    PRINT 'Column subtotal already exists';
END
GO

-- Check and add tax_amount column
IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS 
               WHERE TABLE_SCHEMA = 'dbo' 
               AND TABLE_NAME = 'orders' 
               AND COLUMN_NAME = 'tax_amount')
BEGIN
    ALTER TABLE [dbo].[orders]
    ADD [tax_amount] [decimal](12, 2) NULL;
    ALTER TABLE [dbo].[orders]
    ADD CONSTRAINT [DF_orders_tax_amount] DEFAULT 0 FOR [tax_amount];
    PRINT 'Added column: tax_amount';
END
ELSE
BEGIN
    PRINT 'Column tax_amount already exists';
END
GO

-- Check and add discount_amount column
IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS 
               WHERE TABLE_SCHEMA = 'dbo' 
               AND TABLE_NAME = 'orders' 
               AND COLUMN_NAME = 'discount_amount')
BEGIN
    ALTER TABLE [dbo].[orders]
    ADD [discount_amount] [decimal](12, 2) NULL;
    ALTER TABLE [dbo].[orders]
    ADD CONSTRAINT [DF_orders_discount_amount] DEFAULT 0 FOR [discount_amount];
    PRINT 'Added column: discount_amount';
END
ELSE
BEGIN
    PRINT 'Column discount_amount already exists';
END
GO

-- Check and add total_amount column
IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS 
               WHERE TABLE_SCHEMA = 'dbo' 
               AND TABLE_NAME = 'orders' 
               AND COLUMN_NAME = 'total_amount')
BEGIN
    ALTER TABLE [dbo].[orders]
    ADD [total_amount] [decimal](12, 2) NULL;
    ALTER TABLE [dbo].[orders]
    ADD CONSTRAINT [DF_orders_total_amount] DEFAULT 0 FOR [total_amount];
    PRINT 'Added column: total_amount';
END
ELSE
BEGIN
    PRINT 'Column total_amount already exists';
END
GO