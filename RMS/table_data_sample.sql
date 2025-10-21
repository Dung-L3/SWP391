

USE RMS;
GO

-- Thêm khu vực bàn
INSERT INTO table_area (area_name, sort_order) VALUES
('Tầng 1', 1),
('Tầng 2', 2),
('Khu vực ngoài trời', 3),
('Khu VIP', 4);
GO

-- Thêm bàn ăn mẫu
INSERT INTO dining_table (area_id, table_number, capacity, location, status, table_type, map_x, map_y, created_by) VALUES
-- Tầng 1
(1, 'T1-01', 4, 'Gần cửa ra vào', 'VACANT', 'REGULAR', 100, 100, 1),
(1, 'T1-02', 2, 'Góc phòng', 'VACANT', 'REGULAR', 200, 100, 1),
(1, 'T1-03', 6, 'Giữa phòng', 'VACANT', 'REGULAR', 300, 100, 1),
(1, 'T1-04', 4, 'Cạnh cửa sổ', 'VACANT', 'REGULAR', 100, 150, 1),
(1, 'T1-05', 8, 'Bàn tròn lớn', 'VACANT', 'REGULAR', 200, 150, 1),

-- Tầng 2
(2, 'T2-01', 4, 'Gần cửa sổ', 'VACANT', 'REGULAR', 100, 200, 1),
(2, 'T2-02', 2, 'Góc yên tĩnh', 'VACANT', 'REGULAR', 200, 200, 1),
(2, 'T2-03', 6, 'Giữa phòng', 'VACANT', 'REGULAR', 300, 200, 1),
(2, 'T2-04', 4, 'Cạnh ban công', 'VACANT', 'REGULAR', 100, 250, 1),

-- Khu VIP
(4, 'VIP-01', 6, 'Phòng riêng VIP', 'VACANT', 'VIP', 400, 100, 1),
(4, 'VIP-02', 8, 'Phòng riêng VIP', 'VACANT', 'VIP', 500, 100, 1),
(4, 'VIP-03', 10, 'Phòng riêng VIP', 'VACANT', 'VIP', 400, 200, 1),

-- Ngoài trời
(3, 'N1-01', 4, 'Ngoài trời', 'VACANT', 'OUTDOOR', 100, 300, 1),
(3, 'N1-02', 2, 'Ngoài trời', 'VACANT', 'OUTDOOR', 200, 300, 1),
(3, 'N1-03', 6, 'Ngoài trời', 'VACANT', 'OUTDOOR', 300, 300, 1);
GO

-- Tạo một số phiên bàn mẫu (để test)
INSERT INTO table_session (table_id, open_time, status) VALUES
(1, DATEADD(minute, -30, SYSDATETIME()), 'OPEN'),
(2, DATEADD(minute, -15, SYSDATETIME()), 'OPEN');
GO

-- Cập nhật trạng thái bàn có phiên
UPDATE dining_table SET status = 'SEATED' WHERE table_id IN (1, 2);
GO

PRINT 'Dữ liệu mẫu bàn ăn đã được thêm thành công!';
PRINT 'Truy cập: http://localhost:8080/RMS/tables để xem bản đồ bàn';