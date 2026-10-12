-- ============================================================================
-- 09. QUẢN LÝ CẢNH BÁO (Người 10)
--
-- Bảng: CANH_BAO — sinh ra khi một giá trị đo nằm ngoài khoảng bình thường
--
-- Cách lưu: mỗi cảnh báo gắn với đúng một dòng CHI_TIET_LAN_DO qua khóa ngoại
-- kép (MaLanDo, MaLoaiChiSo). Từ đó suy ra được lần đo, người được đo và chỉ số.
--
-- Quy tắc ngưỡng nằm trong bảng LOAI_CHI_SO; trigger tạo cảnh báo ở file
-- 02_trigger.sql (phải chạy trước khi nạp dữ liệu mẫu).
--
-- Các lệnh thêm / sửa / xóa minh họa đều nằm trong giao dịch rồi ROLLBACK.
-- ============================================================================

USE QuanLyHoSoSucKhoe;
GO

-- ============================================================================
-- 1. QUY TẮC NGƯỠNG
-- ============================================================================

-- Bảng quy tắc: với mỗi chỉ số, giá trị rơi vào khoảng nào thì thuộc mức nào
SELECT
    TenChiSo,
    DonViDo,
    CONCAT(CAST(BinhThuongMin AS FLOAT), N' – ', CAST(BinhThuongMax AS FLOAT)) AS BinhThuong,
    CONCAT(
        CAST(CanhBaoMin AS FLOAT), N' – ', CAST(BinhThuongMin AS FLOAT),
        CASE WHEN CanhBaoMax > BinhThuongMax
             THEN CONCAT(N' hoặc ', CAST(BinhThuongMax AS FLOAT), N' – ', CAST(CanhBaoMax AS FLOAT))
             ELSE N'' END
    ) AS CanChuY,
    CONCAT(
        N'< ', CAST(CanhBaoMin AS FLOAT),
        CASE WHEN CanhBaoMax < GiaTriMax
             THEN CONCAT(N' hoặc > ', CAST(CanhBaoMax AS FLOAT))
             ELSE N'' END
    ) AS NguyHiem
FROM LOAI_CHI_SO
ORDER BY MaLoaiChiSo;
GO

-- ============================================================================
-- 2. TRIGGER TỰ TẠO CẢNH BÁO — minh họa hoạt động
-- ============================================================================

-- 2.1 Thêm một lần đo có nhịp tim 135 bpm (nguy hiểm) và SpO2 93% (cần chú ý):
--     không viết lệnh INSERT nào vào CANH_BAO, trigger tự tạo hai cảnh báo.
BEGIN TRANSACTION;

    INSERT INTO LAN_DO (MaNguoiDung, NguonDuLieu, ThoiGianDo)
    VALUES (1, N'Thủ công', '2026-10-10T21:00:00');

    DECLARE @MaLanDo INT = SCOPE_IDENTITY();

    INSERT INTO CHI_TIET_LAN_DO (MaLanDo, MaLoaiChiSo, GiaTri)
    VALUES (@MaLanDo, 1, 36.8),   -- nhiệt độ: bình thường, không cảnh báo
           (@MaLanDo, 2, 135),    -- nhịp tim: nguy hiểm
           (@MaLanDo, 3, 93);     -- SpO2: cần chú ý

    SELECT MaCanhBao, MucDo, NoiDung, ThoiGianTao, DaXem
    FROM CANH_BAO
    WHERE MaLanDo = @MaLanDo
    ORDER BY MaLoaiChiSo;

    -- 2.2 Sửa nhịp tim về 88 bpm (bình thường): cảnh báo của nó tự biến mất.
    UPDATE CHI_TIET_LAN_DO
    SET GiaTri = 88
    WHERE MaLanDo = @MaLanDo AND MaLoaiChiSo = 2;

    SELECT MaCanhBao, MucDo, NoiDung
    FROM CANH_BAO
    WHERE MaLanDo = @MaLanDo;

ROLLBACK TRANSACTION;
GO

-- 2.3 Giá trị ngoài khoảng hợp lệ (sửa nhịp tim thành 400 bpm) bị trigger từ chối
BEGIN TRY
    UPDATE CHI_TIET_LAN_DO
    SET GiaTri = 400
    WHERE MaLanDo = 260 AND MaLoaiChiSo = 2;
END TRY
BEGIN CATCH
    SELECT ERROR_NUMBER() AS MaLoi, ERROR_MESSAGE() AS ThongBao;
END CATCH;
GO

-- ============================================================================
-- 3. XEM VÀ CẬP NHẬT CẢNH BÁO
-- ============================================================================

-- 3.1 Mười cảnh báo mới nhất, kèm người được đo và giá trị đo
SELECT TOP (10)
    cb.MaCanhBao,
    nd.HoTen,
    l.TenChiSo,
    ct.GiaTri,
    cb.MucDo,
    cb.ThoiGianTao,
    cb.DaXem
FROM CANH_BAO        AS cb
JOIN CHI_TIET_LAN_DO AS ct ON ct.MaLanDo = cb.MaLanDo AND ct.MaLoaiChiSo = cb.MaLoaiChiSo
JOIN LAN_DO          AS ld ON ld.MaLanDo = cb.MaLanDo
JOIN NGUOI_DUNG      AS nd ON nd.MaNguoiDung = ld.MaNguoiDung
JOIN LOAI_CHI_SO     AS l  ON l.MaLoaiChiSo = cb.MaLoaiChiSo
ORDER BY cb.ThoiGianTao DESC, cb.MaCanhBao DESC;

-- 3.2 Cảnh báo chưa xem, mức nguy hiểm trước
SELECT cb.MaCanhBao, nd.HoTen, cb.MucDo, cb.NoiDung, cb.ThoiGianTao
FROM CANH_BAO   AS cb
JOIN LAN_DO     AS ld ON ld.MaLanDo = cb.MaLanDo
JOIN NGUOI_DUNG AS nd ON nd.MaNguoiDung = ld.MaNguoiDung
WHERE cb.DaXem = 0
ORDER BY CASE cb.MucDo WHEN N'Nguy hiểm' THEN 0 ELSE 1 END,
         cb.ThoiGianTao DESC;

-- 3.3 Đánh dấu một cảnh báo là đã xem
BEGIN TRANSACTION;

    UPDATE CANH_BAO
    SET DaXem = 1
    WHERE MaCanhBao = (SELECT MAX(MaCanhBao) FROM CANH_BAO WHERE DaXem = 0);

    SELECT COUNT(*) AS SoCanhBaoChuaXem FROM CANH_BAO WHERE DaXem = 0;

ROLLBACK TRANSACTION;
GO

-- 3.4 Đánh dấu đã xem toàn bộ cảnh báo của một người
BEGIN TRANSACTION;

    UPDATE cb
    SET cb.DaXem = 1
    FROM CANH_BAO AS cb
    JOIN LAN_DO   AS ld ON ld.MaLanDo = cb.MaLanDo
    WHERE ld.MaNguoiDung = 7 AND cb.DaXem = 0;

    SELECT @@ROWCOUNT AS SoCanhBaoVuaDanhDau;

ROLLBACK TRANSACTION;
GO

-- 3.5 Xóa các cảnh báo đã xem và cũ hơn 14 ngày tính từ ngày cuối của dữ liệu mẫu
BEGIN TRANSACTION;

    DELETE FROM CANH_BAO
    WHERE DaXem = 1
      AND ThoiGianTao < DATEADD(DAY, -14, '2026-10-10');

    SELECT @@ROWCOUNT AS SoCanhBaoDaXoa;

ROLLBACK TRANSACTION;
GO

-- ============================================================================
-- 4. TRUY VẤN CẢNH BÁO THEO NGƯỜI VÀ THỜI GIAN
-- ============================================================================

-- 4.1 Cảnh báo của một người
SELECT TOP (10) cb.MaCanhBao, cb.MucDo, cb.NoiDung, cb.ThoiGianTao
FROM CANH_BAO AS cb
JOIN LAN_DO   AS ld ON ld.MaLanDo = cb.MaLanDo
WHERE ld.MaNguoiDung = 7
ORDER BY cb.ThoiGianTao DESC, cb.MaCanhBao DESC;

-- 4.2 Cảnh báo trong một khoảng thời gian
DECLARE @TuNgay  DATE = '2026-10-08';
DECLARE @DenNgay DATE = '2026-10-10';

SELECT nd.HoTen, cb.MucDo, cb.NoiDung, cb.ThoiGianTao
FROM CANH_BAO   AS cb
JOIN LAN_DO     AS ld ON ld.MaLanDo = cb.MaLanDo
JOIN NGUOI_DUNG AS nd ON nd.MaNguoiDung = ld.MaNguoiDung
WHERE cb.ThoiGianTao >= @TuNgay
  AND cb.ThoiGianTao <  DATEADD(DAY, 1, @DenNgay)
  AND cb.MucDo = N'Nguy hiểm'
ORDER BY cb.ThoiGianTao DESC;
GO

-- 4.3 Số cảnh báo của từng người, tách theo mức độ
SELECT
    nd.HoTen,
    COUNT(*)                                                   AS TongCanhBao,
    SUM(CASE WHEN cb.MucDo = N'Nguy hiểm' THEN 1 ELSE 0 END)   AS NguyHiem,
    SUM(CASE WHEN cb.MucDo = N'Cần chú ý' THEN 1 ELSE 0 END)   AS CanChuY,
    SUM(CASE WHEN cb.DaXem = 0 THEN 1 ELSE 0 END)              AS ChuaXem
FROM CANH_BAO   AS cb
JOIN LAN_DO     AS ld ON ld.MaLanDo = cb.MaLanDo
JOIN NGUOI_DUNG AS nd ON nd.MaNguoiDung = ld.MaNguoiDung
GROUP BY nd.MaNguoiDung, nd.HoTen
ORDER BY TongCanhBao DESC;

-- 4.4 Số cảnh báo theo chỉ số và mức độ
SELECT l.TenChiSo, cb.MucDo, COUNT(*) AS SoCanhBao
FROM CANH_BAO    AS cb
JOIN LOAI_CHI_SO AS l ON l.MaLoaiChiSo = cb.MaLoaiChiSo
GROUP BY l.MaLoaiChiSo, l.TenChiSo, cb.MucDo
ORDER BY l.MaLoaiChiSo, cb.MucDo;

-- 4.5 Số cảnh báo theo ngày trong 7 ngày cuối của dữ liệu mẫu
SELECT CAST(ThoiGianTao AS DATE) AS Ngay, COUNT(*) AS SoCanhBao
FROM CANH_BAO
WHERE ThoiGianTao >= '2026-10-04' AND ThoiGianTao < '2026-10-11'
GROUP BY CAST(ThoiGianTao AS DATE)
ORDER BY Ngay;

-- 4.6 Lần đo có từ hai cảnh báo trở lên (nhiều chỉ số cùng bất thường)
SELECT ld.MaLanDo, nd.HoTen, ld.ThoiGianDo, COUNT(*) AS SoCanhBao
FROM CANH_BAO   AS cb
JOIN LAN_DO     AS ld ON ld.MaLanDo = cb.MaLanDo
JOIN NGUOI_DUNG AS nd ON nd.MaNguoiDung = ld.MaNguoiDung
GROUP BY ld.MaLanDo, nd.HoTen, ld.ThoiGianDo
HAVING COUNT(*) >= 2
ORDER BY SoCanhBao DESC, ld.ThoiGianDo DESC;

-- 4.7 Kiểm tra tính nhất quán: mọi giá trị ngoài khoảng bình thường đều phải có
--     cảnh báo, và ngược lại. Truy vấn đúng thì hai con số bằng nhau.
SELECT
    (SELECT COUNT(*)
     FROM CHI_TIET_LAN_DO AS ct
     JOIN LOAI_CHI_SO     AS l ON l.MaLoaiChiSo = ct.MaLoaiChiSo
     WHERE ct.GiaTri < l.BinhThuongMin OR ct.GiaTri > l.BinhThuongMax) AS SoGiaTriBatThuong,
    (SELECT COUNT(*) FROM CANH_BAO)                                    AS SoCanhBao;
GO
