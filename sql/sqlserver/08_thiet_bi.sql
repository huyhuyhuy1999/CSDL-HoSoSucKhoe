-- ============================================================================
-- 08. QUẢN LÝ THIẾT BỊ VÀ NGUỒN DỮ LIỆU (Người 9)
--
-- Bảng: THIET_BI — mã, tên, loại, mã định danh và trạng thái của thiết bị đo
--
-- Đề tài không kết nối phần cứng thật: các thiết bị (ESP32, MAX30102,
-- MLX90614…) chỉ là dữ liệu mô phỏng. Nguồn dữ liệu của một lần đo là
-- "Thiết bị" (có MaThietBi) hoặc "Thủ công" (MaThietBi = NULL).
--
-- Các lệnh thêm / sửa / xóa minh họa đều nằm trong giao dịch rồi ROLLBACK.
-- ============================================================================

USE QuanLyHoSoSucKhoe;
GO

-- ============================================================================
-- 1. XEM (SELECT)
-- ============================================================================

-- 1.1 Toàn bộ thiết bị
SELECT MaThietBi, TenThietBi, LoaiThietBi, MaDinhDanh, TrangThai
FROM THIET_BI
ORDER BY MaThietBi;

-- 1.2 Một thiết bị theo khóa chính
SELECT MaThietBi, TenThietBi, LoaiThietBi, MaDinhDanh, TrangThai, MoTa
FROM THIET_BI
WHERE MaThietBi = 1;
GO

-- ============================================================================
-- 2. THÊM (INSERT)
-- ============================================================================

-- Thêm một thiết bị mô phỏng; TrangThai lấy mặc định "Hoạt động"
BEGIN TRANSACTION;

    INSERT INTO THIET_BI (TenThietBi, LoaiThietBi, MaDinhDanh, MoTa)
    VALUES (N'ESP32 Health Monitor (phòng 2)', N'Thiết bị đa chỉ số',
            'ESP32-A4:CF:12:AA:01:9C', N'Trạm đo thứ hai, đặt tại phòng 2.');

    SELECT MaThietBi, TenThietBi, MaDinhDanh, TrangThai
    FROM THIET_BI
    WHERE MaThietBi = SCOPE_IDENTITY();

ROLLBACK TRANSACTION;
GO

-- ============================================================================
-- 3. SỬA (UPDATE)
-- ============================================================================

-- 3.1 Đưa một thiết bị vào bảo trì
BEGIN TRANSACTION;

    UPDATE THIET_BI
    SET TrangThai = N'Bảo trì',
        MoTa      = N'Thay cảm biến, dự kiến hoạt động lại sau 3 ngày.'
    WHERE MaThietBi = 3;

    SELECT MaThietBi, TenThietBi, TrangThai, MoTa
    FROM THIET_BI
    WHERE MaThietBi = 3;

ROLLBACK TRANSACTION;
GO

-- 3.2 Thiết bị bảo trì xong, hoạt động trở lại
BEGIN TRANSACTION;

    UPDATE THIET_BI
    SET TrangThai = N'Hoạt động'
    WHERE TrangThai = N'Bảo trì';

    SELECT @@ROWCOUNT AS SoThietBiHoatDongLai;

ROLLBACK TRANSACTION;
GO

-- ============================================================================
-- 4. XÓA (DELETE)
-- ============================================================================

-- 4.1 Xóa được thiết bị chưa có lần đo nào (thiết bị số 6)
BEGIN TRANSACTION;

    DELETE FROM THIET_BI
    WHERE MaThietBi = 6;

    SELECT COUNT(*) AS SoThietBiConLai FROM THIET_BI;

ROLLBACK TRANSACTION;
GO

-- 4.2 KHÔNG xóa được thiết bị đã có lần đo: khóa ngoại FK_LAN_DO_THIET_BI chặn
--     lại để lịch sử đo không mất nguồn gốc. Muốn ngừng dùng thì đổi trạng thái.
BEGIN TRY
    DELETE FROM THIET_BI
    WHERE MaThietBi = 1;
END TRY
BEGIN CATCH
    SELECT ERROR_NUMBER() AS MaLoi, N'Không xóa được: thiết bị đã có lần đo.' AS ThongBao;
END CATCH;
GO

-- ============================================================================
-- 5. TÌM KIẾM VÀ LỌC
-- ============================================================================

-- 5.1 Tìm theo tên hoặc mã định danh
SELECT MaThietBi, TenThietBi, MaDinhDanh, TrangThai
FROM THIET_BI
WHERE TenThietBi LIKE N'%ESP32%'
   OR MaDinhDanh LIKE '%ESP32%';

-- 5.2 Lọc theo trạng thái
SELECT MaThietBi, TenThietBi, LoaiThietBi
FROM THIET_BI
WHERE TrangThai = N'Hoạt động'
ORDER BY TenThietBi;

-- 5.3 Lọc theo loại thiết bị
SELECT MaThietBi, TenThietBi, TrangThai
FROM THIET_BI
WHERE LoaiThietBi = N'Thiết bị đa chỉ số';

-- 5.4 Số thiết bị theo trạng thái
SELECT TrangThai, COUNT(*) AS SoThietBi
FROM THIET_BI
GROUP BY TrangThai
ORDER BY SoThietBi DESC;

-- 5.5 Số thiết bị theo loại
SELECT LoaiThietBi, COUNT(*) AS SoThietBi
FROM THIET_BI
GROUP BY LoaiThietBi
ORDER BY SoThietBi DESC, LoaiThietBi;
GO

-- ============================================================================
-- 6. THIẾT BỊ VÀ NGUỒN DỮ LIỆU CỦA LẦN ĐO
-- ============================================================================

-- 6.1 Số lần đo và lần đo gần nhất của từng thiết bị.
--     LEFT JOIN để thiết bị chưa đo lần nào vẫn hiện với số lần đo bằng 0.
SELECT
    tb.MaThietBi,
    tb.TenThietBi,
    tb.TrangThai,
    COUNT(ld.MaLanDo)   AS SoLanDo,
    MAX(ld.ThoiGianDo)  AS LanDoGanNhat
FROM THIET_BI    AS tb
LEFT JOIN LAN_DO AS ld ON ld.MaThietBi = tb.MaThietBi
GROUP BY tb.MaThietBi, tb.TenThietBi, tb.TrangThai
ORDER BY SoLanDo DESC;

-- 6.2 Thiết bị chưa từng được dùng để đo
SELECT tb.MaThietBi, tb.TenThietBi, tb.TrangThai
FROM THIET_BI AS tb
WHERE NOT EXISTS (SELECT 1 FROM LAN_DO AS ld WHERE ld.MaThietBi = tb.MaThietBi);

-- 6.3 Tỷ lệ lần đo theo nguồn dữ liệu
SELECT
    NguonDuLieu,
    COUNT(*) AS SoLanDo,
    CAST(100.0 * COUNT(*) / (SELECT COUNT(*) FROM LAN_DO) AS DECIMAL(5,1)) AS TyLePhanTram
FROM LAN_DO
GROUP BY NguonDuLieu
ORDER BY SoLanDo DESC;

-- 6.4 Mỗi thiết bị đo những chỉ số nào
SELECT tb.TenThietBi, l.TenChiSo, COUNT(*) AS SoGiaTri
FROM THIET_BI        AS tb
JOIN LAN_DO          AS ld ON ld.MaThietBi = tb.MaThietBi
JOIN CHI_TIET_LAN_DO AS ct ON ct.MaLanDo = ld.MaLanDo
JOIN LOAI_CHI_SO     AS l  ON l.MaLoaiChiSo = ct.MaLoaiChiSo
GROUP BY tb.MaThietBi, tb.TenThietBi, l.MaLoaiChiSo, l.TenChiSo
ORDER BY tb.MaThietBi, l.MaLoaiChiSo;

-- 6.5 Thiết bị không ở trạng thái "Hoạt động" nhưng vẫn có lần đo trong
--     7 ngày cuối của dữ liệu mẫu (cần kiểm tra lại trạng thái)
SELECT DISTINCT tb.MaThietBi, tb.TenThietBi, tb.TrangThai
FROM THIET_BI AS tb
JOIN LAN_DO   AS ld ON ld.MaThietBi = tb.MaThietBi
WHERE tb.TrangThai <> N'Hoạt động'
  AND ld.ThoiGianDo >= '2026-10-04';
GO
