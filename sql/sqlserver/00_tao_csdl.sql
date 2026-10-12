-- ============================================================================
-- 00. TẠO CƠ SỞ DỮ LIỆU
-- Đề tài: Quản lý hồ sơ sức khỏe và lịch sử theo dõi chỉ số sức khỏe
-- Hệ quản trị: Microsoft SQL Server
--
-- Thứ tự chạy toàn bộ bộ script:
--   00_tao_csdl.sql  ->  01_tao_bang.sql  ->  02_trigger.sql
--   ->  03_du_lieu_mau.sql  ->  04 ... 11 (thứ tự bất kỳ sau khi đã có dữ liệu,
--   riêng 10_thong_ke.sql phải chạy trước 11_kiem_thu.sql)
--
-- Chạy lại file này sẽ XÓA cơ sở dữ liệu cũ và tạo lại từ đầu.
-- ============================================================================

USE master;
GO

IF DB_ID(N'QuanLyHoSoSucKhoe') IS NOT NULL
BEGIN
    -- Ngắt các kết nối đang mở để xóa được cơ sở dữ liệu.
    ALTER DATABASE QuanLyHoSoSucKhoe SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE QuanLyHoSoSucKhoe;
END
GO

-- Vietnamese_CI_AS: so sánh không phân biệt hoa thường, có phân biệt dấu,
-- và sắp xếp chuỗi theo bảng chữ cái tiếng Việt.
CREATE DATABASE QuanLyHoSoSucKhoe COLLATE Vietnamese_CI_AS;
GO

USE QuanLyHoSoSucKhoe;
GO

PRINT N'Đã tạo cơ sở dữ liệu QuanLyHoSoSucKhoe.';
GO
