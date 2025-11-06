
-- Thay thế 'UQ_Customer_UserID' bằng tên ràng buộc UNIQUE hiện tại của bạn
IF EXISTS (SELECT * FROM sys.objects WHERE name = 'UQ_Customer_UserID' AND type = 'UQ')
BEGIN
    ALTER TABLE [RMS].[dbo].[customers] DROP CONSTRAINT UQ_Customer_UserID;
END

-- Hoặc xóa Index nếu nó được tạo dưới dạng Index
IF EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_Customer_UserID' AND object_id = OBJECT_ID('[RMS].[dbo].[customers]'))
BEGIN
    DROP INDEX IX_Customer_UserID ON [RMS].[dbo].[customers];
END
GO

-- Xóa ràng buộc UNIQUE cũ bằng tên chính xác mà hệ thống báo lỗi
ALTER TABLE [RMS].[dbo].[customers]
DROP CONSTRAINT UQ__customer__B9BE370E4FEB5160;
GO

-- Sau khi xóa ràng buộc, đảm bảo cột đó CHO PHÉP NULL. 
-- Chúng ta đã chạy lệnh này ở lần trước, nhưng chạy lại để chắc chắn.
ALTER TABLE [RMS].[dbo].[customers]
ALTER COLUMN [email] VARCHAR(255) NULL; -- Dùng kiểu dữ liệu hiện tại của email
GO

ALTER TABLE [RMS].[dbo].[customers]
ALTER COLUMN [phone] VARCHAR(20) NULL;  -- Dùng kiểu dữ liệu hiện tại của phone
GO