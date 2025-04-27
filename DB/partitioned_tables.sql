USE QLNHAHANG88
GO

-- Tạo Partition Functions và Partition Schemes
-- Phân vùng theo ChiNhanh
CREATE PARTITION FUNCTION pf_ChiNhanh (TINYINT)
AS RANGE LEFT FOR VALUES (1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15); -- Các chi nhánh hiện tại

-- Phân vùng theo thời gian
CREATE PARTITION FUNCTION pf_ThoiGian (DATETIME)
AS RANGE LEFT FOR VALUES (
'2022-01-01 00:00:00', '2024-01-01 00:00:00', '2024-04-01 00:00:00',
    '2024-07-01 00:00:00', '2024-10-01 00:00:00', '2025-04-01 00:00:00'); -- Phân vùng theo quý

-- Phân vùng theo KhuVuc
CREATE PARTITION FUNCTION pf_KhuVuc (TINYINT)
AS RANGE LEFT FOR VALUES (1, 2, 3, 4, 5, 6); -- Các khu vực hiện tại

-- Phân vùng theo LoaiThe
CREATE PARTITION FUNCTION pf_LoaiThe (NVARCHAR(20) COLLATE SQL_Latin1_General_CP1_CI_AS)
AS RANGE LEFT FOR VALUES (N'Gold', N'Membership', N'Silver');

CREATE PARTITION SCHEME ps_ChiNhanh
AS PARTITION pf_ChiNhanh ALL TO ([PRIMARY]);

CREATE PARTITION SCHEME ps_ThoiGian
AS PARTITION pf_ThoiGian ALL TO ([PRIMARY]);

CREATE PARTITION SCHEME ps_KhuVuc
AS PARTITION pf_KhuVuc ALL TO ([PRIMARY]);

CREATE PARTITION SCHEME ps_LoaiThe
AS PARTITION pf_LoaiThe ALL TO ([PRIMARY]);


