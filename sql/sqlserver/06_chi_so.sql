-- ============================================================================
-- 06. QUẢN LÝ CHỈ SỐ SỨC KHỎE (Người 7)
--
-- Bảng: LOAI_CHI_SO      — danh mục chỉ số: tên, đơn vị đo, ngưỡng đánh giá
--       CHI_TIET_LAN_DO  — giá trị của từng chỉ số trong một lần đo
--
-- Năm chỉ số được theo dõi: nhiệt độ, nhịp tim, SpO2, huyết áp tâm thu và
-- huyết áp tâm trương.
--
-- Các lệnh thêm / sửa / xóa minh họa đều nằm trong giao dịch rồi ROLLBACK.
-- ============================================================================

USE QuanLyHoSoSucKhoe;
GO

-- ============================================================================
-- 1. LOAI_CHI_SO
-- ============================================================================

-- 1.1 Danh mục chỉ số: tên, đơn vị và các khoảng đánh giá
SELECT MaLoaiChiSo, KyHieu, TenChiSo, DonViDo,
       BinhThuongMin, BinhThuongMax, CanhBaoMin, CanhBaoMax
FROM LOAI_CHI_SO
ORDER BY MaLoaiChiSo;

-- 1.2 Thêm một loại chỉ số mới (ví dụ đường huyết)
BEGIN TRANSACTION;

    INSERT INTO LOAI_CHI_SO (KyHieu, TenChiSo, DonViDo, SoThapPhan,
                             GiaTriMin, GiaTriMax,
                             BinhThuongMin, BinhThuongMax,
                             CanhBaoMin, CanhBaoMax)
    VALUES ('DUONG_HUYET', N'Đường huyết', N'mmol/L', 1,
            1.0, 35.0,
            3.9, 6.4,
            3.0, 7.0);

    SELECT MaLoaiChiSo, KyHieu, TenChiSo, DonViDo
    FROM LOAI_CHI_SO
    ORDER BY MaLoaiChiSo;

ROLLBACK TRANSACTION;
GO

-- 1.3 Sửa đơn vị đo và nới khoảng bình thường của một chỉ số
BEGIN TRANSACTION;

    UPDATE LOAI_CHI_SO
    SET BinhThuongMax = 37.2
    WHERE KyHieu = 'NHIET_DO';

    SELECT TenChiSo, BinhThuongMin, BinhThuongMax
    FROM LOAI_CHI_SO
    WHERE KyHieu = 'NHIET_DO';

ROLLBACK TRANSACTION;
GO

-- 1.4 Xóa một loại chỉ số chưa được dùng. (Loại đã có giá trị đo thì không
--     xóa được vì bị khóa ngoại FK_CHI_TIET_LAN_DO_LOAI_CHI_SO chặn.)
BEGIN TRANSACTION;

    INSERT INTO LOAI_CHI_SO (KyHieu, TenChiSo, DonViDo, GiaTriMin, GiaTriMax,
                             BinhThuongMin, BinhThuongMax, CanhBaoMin, CanhBaoMax)
    VALUES ('NHIP_THO', N'Nhịp thở', N'lần/phút', 5, 60, 12, 20, 10, 24);

    DELETE FROM LOAI_CHI_SO
    WHERE KyHieu = 'NHIP_THO';

    SELECT COUNT(*) AS SoLoaiChiSo FROM LOAI_CHI_SO;

ROLLBACK TRANSACTION;
GO

-- ============================================================================
-- 2. CHI_TIET_LAN_DO
-- ============================================================================

-- 2.1 Các chỉ số của một lần đo, kèm tên và đơn vị
SELECT ct.MaLanDo, l.TenChiSo, ct.GiaTri, l.DonViDo
FROM CHI_TIET_LAN_DO AS ct
JOIN LOAI_CHI_SO     AS l ON l.MaLoaiChiSo = ct.MaLoaiChiSo
WHERE ct.MaLanDo = 260
ORDER BY ct.MaLoaiChiSo;

-- 2.2 Đánh giá từng giá trị của một lần đo theo ngưỡng của chỉ số
SELECT
    l.TenChiSo,
    ct.GiaTri,
    l.DonViDo,
    CONCAT(CAST(l.BinhThuongMin AS FLOAT), N' – ', CAST(l.BinhThuongMax AS FLOAT)) AS KhoangBinhThuong,
    CASE
        WHEN ct.GiaTri BETWEEN l.BinhThuongMin AND l.BinhThuongMax THEN N'Bình thường'
        WHEN ct.GiaTri BETWEEN l.CanhBaoMin    AND l.CanhBaoMax    THEN N'Cần chú ý'
        ELSE N'Nguy hiểm'
    END AS MucDo
FROM CHI_TIET_LAN_DO AS ct
JOIN LOAI_CHI_SO     AS l ON l.MaLoaiChiSo = ct.MaLoaiChiSo
WHERE ct.MaLanDo = 260
ORDER BY ct.MaLoaiChiSo;
GO

-- 2.3 Thêm chỉ số cho một lần đo. Lần đo 261 (máy đo SpO2) chỉ có nhịp tim và
--     SpO2; bổ sung nhiệt độ đo tay.
BEGIN TRANSACTION;

    INSERT INTO CHI_TIET_LAN_DO (MaLanDo, MaLoaiChiSo, GiaTri)
    VALUES (261, 1, 36.8);

    SELECT ct.MaLanDo, l.TenChiSo, ct.GiaTri, l.DonViDo
    FROM CHI_TIET_LAN_DO AS ct
    JOIN LOAI_CHI_SO     AS l ON l.MaLoaiChiSo = ct.MaLoaiChiSo
    WHERE ct.MaLanDo = 261
    ORDER BY ct.MaLoaiChiSo;

ROLLBACK TRANSACTION;
GO

-- 2.4 Sửa một giá trị đo bị nhập nhầm
BEGIN TRANSACTION;

    UPDATE CHI_TIET_LAN_DO
    SET GiaTri = 96
    WHERE MaLanDo = 261 AND MaLoaiChiSo = 3;

    SELECT MaLanDo, MaLoaiChiSo, GiaTri
    FROM CHI_TIET_LAN_DO
    WHERE MaLanDo = 261;

ROLLBACK TRANSACTION;
GO

-- 2.5 Xóa một chỉ số khỏi lần đo
BEGIN TRANSACTION;

    DELETE FROM CHI_TIET_LAN_DO
    WHERE MaLanDo = 260 AND MaLoaiChiSo = 1;

    SELECT COUNT(*) AS SoChiSoConLai
    FROM CHI_TIET_LAN_DO
    WHERE MaLanDo = 260;

ROLLBACK TRANSACTION;
GO

-- ============================================================================
-- 3. TRUY VẤN GIÁ TRỊ ĐO
-- ============================================================================

-- 3.1 Số giá trị đã ghi nhận của từng chỉ số
SELECT l.TenChiSo, l.DonViDo, COUNT(ct.MaLanDo) AS SoGiaTri
FROM LOAI_CHI_SO          AS l
LEFT JOIN CHI_TIET_LAN_DO AS ct ON ct.MaLoaiChiSo = l.MaLoaiChiSo
GROUP BY l.MaLoaiChiSo, l.TenChiSo, l.DonViDo
ORDER BY l.MaLoaiChiSo;

-- 3.2 Giá trị nhỏ nhất, lớn nhất, trung bình của từng chỉ số
SELECT
    l.TenChiSo,
    l.DonViDo,
    MIN(ct.GiaTri)                          AS NhoNhat,
    MAX(ct.GiaTri)                          AS LonNhat,
    CAST(AVG(ct.GiaTri) AS DECIMAL(6,1))    AS TrungBinh
FROM CHI_TIET_LAN_DO AS ct
JOIN LOAI_CHI_SO     AS l ON l.MaLoaiChiSo = ct.MaLoaiChiSo
GROUP BY l.MaLoaiChiSo, l.TenChiSo, l.DonViDo
ORDER BY l.MaLoaiChiSo;

-- 3.3 Các giá trị nhịp tim nằm ngoài khoảng bình thường
SELECT TOP (10) ct.MaLanDo, ct.GiaTri, l.BinhThuongMin, l.BinhThuongMax
FROM CHI_TIET_LAN_DO AS ct
JOIN LOAI_CHI_SO     AS l ON l.MaLoaiChiSo = ct.MaLoaiChiSo
WHERE l.KyHieu = 'NHIP_TIM'
  AND (ct.GiaTri < l.BinhThuongMin OR ct.GiaTri > l.BinhThuongMax)
ORDER BY ct.GiaTri DESC;

-- 3.4 Giá trị mới nhất của từng chỉ số đối với một người.
--     ROW_NUMBER() đánh số các giá trị của mỗi chỉ số từ mới tới cũ; dòng số 1
--     là giá trị mới nhất.
SELECT TenChiSo, GiaTri, DonViDo, ThoiGianDo
FROM (
    SELECT
        l.MaLoaiChiSo, l.TenChiSo, ct.GiaTri, l.DonViDo, ld.ThoiGianDo,
        ROW_NUMBER() OVER (PARTITION BY ct.MaLoaiChiSo
                           ORDER BY ld.ThoiGianDo DESC) AS ThuTu
    FROM CHI_TIET_LAN_DO AS ct
    JOIN LAN_DO          AS ld ON ld.MaLanDo = ct.MaLanDo
    JOIN LOAI_CHI_SO     AS l  ON l.MaLoaiChiSo = ct.MaLoaiChiSo
    WHERE ld.MaNguoiDung = 4
) AS t
WHERE ThuTu = 1
ORDER BY MaLoaiChiSo;

-- 3.5 Tỷ lệ giá trị theo mức độ của từng chỉ số
SELECT
    l.TenChiSo,
    SUM(CASE WHEN ct.GiaTri BETWEEN l.BinhThuongMin AND l.BinhThuongMax THEN 1 ELSE 0 END) AS BinhThuong,
    SUM(CASE WHEN ct.GiaTri NOT BETWEEN l.BinhThuongMin AND l.BinhThuongMax
              AND ct.GiaTri BETWEEN l.CanhBaoMin AND l.CanhBaoMax THEN 1 ELSE 0 END)       AS CanChuY,
    SUM(CASE WHEN ct.GiaTri NOT BETWEEN l.CanhBaoMin AND l.CanhBaoMax THEN 1 ELSE 0 END)   AS NguyHiem
FROM CHI_TIET_LAN_DO AS ct
JOIN LOAI_CHI_SO     AS l ON l.MaLoaiChiSo = ct.MaLoaiChiSo
GROUP BY l.MaLoaiChiSo, l.TenChiSo
ORDER BY l.MaLoaiChiSo;
GO
