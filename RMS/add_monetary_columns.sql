-- Add missing monetary columns to orders table
ALTER TABLE [dbo].[orders]
ADD [subtotal] [decimal](12, 2) NULL DEFAULT 0,
    [tax_amount] [decimal](12, 2) NULL DEFAULT 0,
    [discount_amount] [decimal](12, 2) NULL DEFAULT 0,
    [total_amount] [decimal](12, 2) NULL DEFAULT 0;