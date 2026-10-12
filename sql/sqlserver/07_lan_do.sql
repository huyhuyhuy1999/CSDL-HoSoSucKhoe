-- ============================================================================
-- 07. QUẢN LÝ LẦN ĐO VÀ LỊCH SỬ (Người 8)
--
-- Bảng: LAN_DO — ai được đo, đo lúc nào, bằng thiết bị nào hay nhập thủ công
-- Nội dung: xem, thêm, sửa, xóa; lịch sử theo người, ngày, tháng và khoảng
--           thời gian.
--
-- Các lệnh thêm / sửa / xóa minh họa đều nằm trong giao dịch rồi ROLLBACK.
-- ============================================================================

USE QuanLyHoSoSucKhoe;
GO

-- ============================================================================
-- 1. XEM (SELECT)
-- ============================================================================

-- 1.1 Mười lần đo mới nhất, kèm tên người được đo và nguồn dữ liệu
SELECT TOP (10)
    ld.MaLanDo,
    nd.HoTen,
    ld.ThoiGianDo,
    ld.NguonDuLieu,
    tb.TenThietBi
FROM LAN_DO        AS ld
JOIN NGUOI_DUNG    AS nd ON nd.MaNguoiDung = ld.MaNguoiDung
LEFT JOIN THIET_BI AS tb ON tb.MaThietBi = ld.MaThietBi   -- LEFT JOIN: lần đo thủ công không có thiết bị
ORDER BY ld.ThoiGianDo DESC;

-- 1.2 Một lần đo theo khóa chính
SELECT ld.MaLanDo, nd.HoTen, ld.ThoiGianDo, ld.NguonDuLieu, tb.TenThietBi, ld.GhiChu
FROM LAN_DO        AS ld
JOIN NGUOI_DUNG    AS nd ON nd.MaNguoiDung = ld.MaNguoiDung
LEFT JOIN THIET_BI AS tb ON tb.MaThietBi = ld.MaThietBi
WHERE ld.MaLanDo = 260;
GO

-- ============================================================================
-- 2. THÊM (INSERT)
-- ============================================================================

-- 2.1 Thêm một lần đo từ thiết bị cùng các chỉ số của nó.
--     Hai bảng phải được ghi trong cùng một giao dịch: nếu ghi chi tiết lỗi
--     thì lần đo cũng không được lưu.
BEGIN TRANSACTION;

    INSERT INTO LAN_DO (MaNguoiDung, MaThietBi, NguonDuLieu, ThoiGianDo, GhiChu)
    VALUES (2, 1, N'Thiết bị', '2026-10-10T20:15:00', N'Đo sau bữa tối');

    DECLARE @MaLanDo INT = SCOPE_IDENTITY();

    INSERT INTO CHI_TIET_LAN_DO (MaLanDo, MaLoaiChiSo, GiaTri)
    VALUES (@MaLanDo, 1, 36.7),   -- nhiệt độ
           (@MaLanDo, 2, 81),     -- nhịp tim
           (@MaLanDo, 3, 98),     -- SpO2
           (@MaLanDo, 4, 121),    -- huyết áp tâm thu
           (@MaLanDo, 5, 79);     -- huyết áp tâm trương

    SELECT ld.MaLanDo, ld.ThoiGianDo, l.TenChiSo, ct.GiaTri, l.DonViDo
    FROM LAN_DO          AS ld
    JOIN CHI_TIET_LAN_DO AS ct ON ct.MaLanDo = ld.MaLanDo
    JOIN LOAI_CHI_SO     AS l  ON l.MaLoaiChiSo = ct.MaLoaiChiSo
    WHERE ld.MaLanDo = @MaLanDo
    ORDER BY l.MaLoaiChiSo;

ROLLBACK TRANSACTION;
GO

-- 2.2 Thêm một lần đo nhập thủ công: không có thiết bị, thời gian mặc định là hiện tại
BEGIN TRANSACTION;

    INSERT INTO LAN_DO (MaNguoiDung, NguonDuLieu)
    VALUES (5, N'Thủ công');

    SELECT MaLanDo, MaNguoiDung, MaThietBi, NguonDuLieu, ThoiGianDo
    FROM LAN_DO
    WHERE MaLanDo = SCOPE_IDENTITY();

ROLLBACK TRANSACTION;
GO

-- ============================================================================
-- 3. SỬA (UPDATE)
-- ============================================================================

-- Sửa ghi chú và giờ đo của một lần đo
BEGIN TRANSACTION;

    UPDATE LAN_DO
    SET GhiChu     = N'Đo lại sau khi nghỉ 15 phút',
        ThoiGianDo = DATEADD(MINUTE, 15, ThoiGianDo)
    WHERE MaLanDo = 260;

    SELECT MaLanDo, ThoiGianDo, GhiChu
    FROM LAN_DO
    WHERE MaLanDo = 260;

ROLLBACK TRANSACTION;
GO

-- ============================================================================
-- 4. XÓA (DELETE)
-- ============================================================================

-- Xóa một lần đo kéo theo các chi tiết và cảnh báo của nó (ON DELETE CASCADE)
BEGIN TRANSACTION;

    SELECT
        (SELECT COUNT(*) FROM CHI_TIET_LAN_DO WHERE MaLanDo = 260) AS ChiTietTruocKhiXoa,
        (SELECT COUNT(*) FROM CANH_BAO        WHERE MaLanDo = 260) AS CanhBaoTruocKhiXoa;

    DELETE FROM LAN_DO
    WHERE MaLanDo = 260;

    SELECT
        (SELECT COUNT(*) FROM CHI_TIET_LAN_DO WHERE MaLanDo = 260) AS ChiTietConLai,
        (SELECT COUNT(*) FROM CANH_BAO        WHERE MaLanDo = 260) AS CanhBaoConLai;

ROLLBACK TRANSACTION;
GO

-- ============================================================================
-- 5. LỊCH SỬ ĐO
-- ============================================================================

-- 5.1 Lịch sử của một người, mới nhất trước
SELECT TOP (10) ld.MaLanDo, ld.ThoiGianDo, ld.NguonDuLieu, tb.TenThietBi
FROM LAN_DO        AS ld
LEFT JOIN THIET_BI AS tb ON tb.MaThietBi = ld.MaThietBi
WHERE ld.MaNguoiDung = 7
ORDER BY ld.ThoiGianDo DESC;

-- 5.2 Các lần đo trong một ngày.
--     So sánh theo khoảng [đầu ngày, đầu ngày hôm sau) để vẫn dùng được chỉ mục
--     trên ThoiGianDo, thay vì bọc cột trong hàm CAST.
DECLARE @Ngay DATE = '2026-10-10';

SELECT ld.MaLanDo, nd.HoTen, CONVERT(VARCHAR(5), ld.ThoiGianDo, 108) AS Gio, ld.NguonDuLieu
FROM LAN_DO     AS ld
JOIN NGUOI_DUNG AS nd ON nd.MaNguoiDung = ld.MaNguoiDung
WHERE ld.ThoiGianDo >= @Ngay
  AND ld.ThoiGianDo <  DATEADD(DAY, 1, @Ngay)
ORDER BY ld.ThoiGianDo;
GO

-- 5.3 Số lần đo của từng người trong một tháng
SELECT nd.HoTen, COUNT(*) AS SoLanDo
FROM LAN_DO     AS ld
JOIN NGUOI_DUNG AS nd ON nd.MaNguoiDung = ld.MaNguoiDung
WHERE YEAR(ld.ThoiGianDo) = 2026 AND MONTH(ld.ThoiGianDo) = 10
GROUP BY nd.MaNguoiDung, nd.HoTen
ORDER BY SoLanDo DESC, nd.HoTen;

-- 5.4 Lịch sử của một người trong một khoảng thời gian
DECLARE @TuNgay  DATE = '2026-10-04';
DECLARE @DenNgay DATE = '2026-10-10';

SELECT ld.MaLanDo, ld.ThoiGianDo, ld.NguonDuLieu
FROM LAN_DO AS ld
WHERE ld.MaNguoiDung = 1
  AND ld.ThoiGianDo >= @TuNgay
  AND ld.ThoiGianDo <  DATEADD(DAY, 1, @DenNgay)
ORDER BY ld.ThoiGianDo DESC;
GO

-- 5.5 Lịch sử kèm các chỉ số trên cùng một dòng (xoay dọc thành ngang).
--     Mỗi chỉ số là một cột; lần đo thiếu chỉ số nào thì cột đó NULL.
SELECT TOP (10)
    ld.MaLanDo,
    ld.ThoiGianDo,
    MAX(CASE WHEN ct.MaLoaiChiSo = 1 THEN ct.GiaTri END) AS NhietDo,
    MAX(CASE WHEN ct.MaLoaiChiSo = 2 THEN ct.GiaTri END) AS NhipTim,
    MAX(CASE WHEN ct.MaLoaiChiSo = 3 THEN ct.GiaTri END) AS SpO2,
    MAX(CASE WHEN ct.MaLoaiChiSo = 4 THEN ct.GiaTri END) AS TamThu,
    MAX(CASE WHEN ct.MaLoaiChiSo = 5 THEN ct.GiaTri END) AS TamTruong
FROM LAN_DO          AS ld
JOIN CHI_TIET_LAN_DO AS ct ON ct.MaLanDo = ld.MaLanDo
WHERE ld.MaNguoiDung = 7
GROUP BY ld.MaLanDo, ld.ThoiGianDo
ORDER BY ld.ThoiGianDo DESC;

-- 5.6 Lần đo gần nhất của mỗi người (truy vấn con tương quan)
SELECT nd.HoTen, ld.MaLanDo, ld.ThoiGianDo
FROM NGUOI_DUNG AS nd
JOIN LAN_DO     AS ld ON ld.MaNguoiDung = nd.MaNguoiDung
WHERE ld.ThoiGianDo = (
    SELECT MAX(ld2.ThoiGianDo)
    FROM LAN_DO AS ld2
    WHERE ld2.MaNguoiDung = nd.MaNguoiDung
)
ORDER BY ld.ThoiGianDo DESC;

-- 5.7 Số lần đo theo từng ngày trong 7 ngày cuối của dữ liệu mẫu
SELECT CAST(ThoiGianDo AS DATE) AS Ngay, COUNT(*) AS SoLanDo
FROM LAN_DO
WHERE ThoiGianDo >= '2026-10-04' AND ThoiGianDo < '2026-10-11'
GROUP BY CAST(ThoiGianDo AS DATE)
ORDER BY Ngay;

-- 5.8 Số lần đo theo buổi trong ngày
SELECT
    CASE
        WHEN DATEPART(HOUR, ThoiGianDo) < 12 THEN N'1. Sáng'
        WHEN DATEPART(HOUR, ThoiGianDo) < 18 THEN N'2. Chiều'
        ELSE N'3. Tối'
    END AS Buoi,
    COUNT(*) AS SoLanDo
FROM LAN_DO
GROUP BY
    CASE
        WHEN DATEPART(HOUR, ThoiGianDo) < 12 THEN N'1. Sáng'
        WHEN DATEPART(HOUR, ThoiGianDo) < 18 THEN N'2. Chiều'
        ELSE N'3. Tối'
    END
ORDER BY Buoi;

-- 5.9 Người chưa đo lần nào trong 3 ngày cuối của dữ liệu mẫu
SELECT nd.MaNguoiDung, nd.HoTen
FROM NGUOI_DUNG AS nd
WHERE NOT EXISTS (
    SELECT 1
    FROM LAN_DO AS ld
    WHERE ld.MaNguoiDung = nd.MaNguoiDung
      AND ld.ThoiGianDo >= '2026-10-08'
)
ORDER BY nd.HoTen;
GO
