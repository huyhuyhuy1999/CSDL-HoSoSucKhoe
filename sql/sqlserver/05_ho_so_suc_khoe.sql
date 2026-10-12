-- ============================================================================
-- 05. QUẢN LÝ HỒ SƠ SỨC KHỎE (Người 6)
--
-- Bảng: HO_SO_SUC_KHOE (quan hệ 1–1 với NGUOI_DUNG)
-- Nội dung: chiều cao, cân nặng, nhóm máu, tiền sử bệnh, dị ứng, ngày cập nhật;
--           xem, thêm, sửa, xóa và truy vấn hồ sơ theo người dùng.
--
-- Các lệnh thêm / sửa / xóa minh họa đều nằm trong giao dịch rồi ROLLBACK.
-- ============================================================================

USE QuanLyHoSoSucKhoe;
GO

-- ============================================================================
-- 1. XEM (SELECT)
-- ============================================================================

-- 1.1 Toàn bộ hồ sơ kèm tên người dùng
SELECT hs.MaHoSo, nd.HoTen, hs.ChieuCao, hs.CanNang, hs.NhomMau, hs.NgayCapNhat
FROM HO_SO_SUC_KHOE AS hs
JOIN NGUOI_DUNG     AS nd ON nd.MaNguoiDung = hs.MaNguoiDung
ORDER BY hs.MaHoSo;

-- 1.2 Hồ sơ của một người dùng
SELECT nd.HoTen, nd.GioiTinh, nd.NgaySinh,
       hs.ChieuCao, hs.CanNang, hs.NhomMau, hs.TienSuBenh, hs.DiUng, hs.NgayCapNhat
FROM NGUOI_DUNG     AS nd
JOIN HO_SO_SUC_KHOE AS hs ON hs.MaNguoiDung = nd.MaNguoiDung
WHERE nd.MaNguoiDung = 7;

-- 1.3 Chỉ số khối cơ thể BMI = cân nặng (kg) / chiều cao (m)², phân loại theo
--     thang dành cho người châu Á.
SELECT
    nd.HoTen,
    hs.ChieuCao,
    hs.CanNang,
    CAST(hs.CanNang / POWER(hs.ChieuCao / 100.0, 2) AS DECIMAL(4,1)) AS BMI,
    CASE
        WHEN hs.CanNang / POWER(hs.ChieuCao / 100.0, 2) < 18.5 THEN N'Thiếu cân'
        WHEN hs.CanNang / POWER(hs.ChieuCao / 100.0, 2) < 23   THEN N'Bình thường'
        WHEN hs.CanNang / POWER(hs.ChieuCao / 100.0, 2) < 25   THEN N'Thừa cân'
        ELSE N'Béo phì'
    END AS PhanLoai
FROM HO_SO_SUC_KHOE AS hs
JOIN NGUOI_DUNG     AS nd ON nd.MaNguoiDung = hs.MaNguoiDung
ORDER BY BMI DESC;
GO

-- ============================================================================
-- 2. THÊM (INSERT)
-- ============================================================================

-- 2.1 Tạo người dùng mới rồi lập hồ sơ cho họ trong cùng một giao dịch
BEGIN TRANSACTION;

    INSERT INTO NGUOI_DUNG (HoTen, GioiTinh, NgaySinh)
    VALUES (N'Trịnh Gia Bảo', N'Nam', '1999-02-14');

    DECLARE @MaNguoiDung INT = SCOPE_IDENTITY();

    INSERT INTO HO_SO_SUC_KHOE (MaNguoiDung, ChieuCao, CanNang, NhomMau, TienSuBenh, DiUng)
    VALUES (@MaNguoiDung, 172, 65.5, 'A+', NULL, N'Tôm, cua');

    SELECT nd.HoTen, hs.MaHoSo, hs.ChieuCao, hs.CanNang, hs.NhomMau, hs.DiUng, hs.NgayCapNhat
    FROM HO_SO_SUC_KHOE AS hs
    JOIN NGUOI_DUNG     AS nd ON nd.MaNguoiDung = hs.MaNguoiDung
    WHERE hs.MaNguoiDung = @MaNguoiDung;

ROLLBACK TRANSACTION;
GO

-- ============================================================================
-- 3. SỬA (UPDATE)
-- ============================================================================

-- 3.1 Cập nhật cân nặng và tiền sử bệnh. Không cần gán NgayCapNhat:
--     trigger TRG_HO_SO_SUC_KHOE_NgayCapNhat tự ghi thời điểm hiện tại.
BEGIN TRANSACTION;

    SELECT MaHoSo, CanNang, TienSuBenh, NgayCapNhat AS NgayCapNhatCu
    FROM HO_SO_SUC_KHOE
    WHERE MaNguoiDung = 11;

    UPDATE HO_SO_SUC_KHOE
    SET CanNang    = 82.5,
        TienSuBenh = N'Béo phì độ I, đang theo chế độ giảm cân.'
    WHERE MaNguoiDung = 11;

    SELECT MaHoSo, CanNang, TienSuBenh, NgayCapNhat AS NgayCapNhatMoi
    FROM HO_SO_SUC_KHOE
    WHERE MaNguoiDung = 11;

ROLLBACK TRANSACTION;
GO

-- ============================================================================
-- 4. XÓA (DELETE)
-- ============================================================================

-- Xóa hồ sơ không xóa người dùng: người đó trở thành "chưa có hồ sơ".
BEGIN TRANSACTION;

    DELETE FROM HO_SO_SUC_KHOE
    WHERE MaNguoiDung = 12;

    SELECT nd.MaNguoiDung, nd.HoTen, hs.MaHoSo
    FROM NGUOI_DUNG          AS nd
    LEFT JOIN HO_SO_SUC_KHOE AS hs ON hs.MaNguoiDung = nd.MaNguoiDung
    WHERE nd.MaNguoiDung = 12;

ROLLBACK TRANSACTION;
GO

-- ============================================================================
-- 5. TRUY VẤN HỒ SƠ
-- ============================================================================

-- 5.1 Lọc theo nhóm máu
SELECT nd.HoTen, hs.NhomMau
FROM HO_SO_SUC_KHOE AS hs
JOIN NGUOI_DUNG     AS nd ON nd.MaNguoiDung = hs.MaNguoiDung
WHERE hs.NhomMau IN ('O+', 'O-')
ORDER BY nd.HoTen;

-- 5.2 Số người theo nhóm máu
SELECT NhomMau, COUNT(*) AS SoNguoi
FROM HO_SO_SUC_KHOE
GROUP BY NhomMau
ORDER BY SoNguoi DESC, NhomMau;

-- 5.3 Người có tiền sử bệnh
SELECT nd.HoTen, hs.TienSuBenh
FROM HO_SO_SUC_KHOE AS hs
JOIN NGUOI_DUNG     AS nd ON nd.MaNguoiDung = hs.MaNguoiDung
WHERE hs.TienSuBenh IS NOT NULL
ORDER BY nd.HoTen;

-- 5.4 Tìm theo từ khóa trong tiền sử bệnh
SELECT nd.HoTen, hs.TienSuBenh
FROM HO_SO_SUC_KHOE AS hs
JOIN NGUOI_DUNG     AS nd ON nd.MaNguoiDung = hs.MaNguoiDung
WHERE hs.TienSuBenh LIKE N'%huyết áp%';

-- 5.5 Người có dị ứng
SELECT nd.HoTen, hs.DiUng
FROM HO_SO_SUC_KHOE AS hs
JOIN NGUOI_DUNG     AS nd ON nd.MaNguoiDung = hs.MaNguoiDung
WHERE hs.DiUng IS NOT NULL
ORDER BY nd.HoTen;

-- 5.6 Người dùng CHƯA có hồ sơ (LEFT JOIN rồi giữ những dòng không khớp).
--     Với dữ liệu mẫu, truy vấn này không trả về dòng nào.
SELECT nd.MaNguoiDung, nd.HoTen
FROM NGUOI_DUNG          AS nd
LEFT JOIN HO_SO_SUC_KHOE AS hs ON hs.MaNguoiDung = nd.MaNguoiDung
WHERE hs.MaHoSo IS NULL;

-- 5.7 Hồ sơ chưa được cập nhật trong 30 ngày tính đến một mốc cho trước
DECLARE @Moc DATE = '2026-10-10';

SELECT nd.HoTen, hs.NgayCapNhat,
       DATEDIFF(DAY, hs.NgayCapNhat, @Moc) AS SoNgayChuaCapNhat
FROM HO_SO_SUC_KHOE AS hs
JOIN NGUOI_DUNG     AS nd ON nd.MaNguoiDung = hs.MaNguoiDung
WHERE hs.NgayCapNhat < DATEADD(DAY, -30, @Moc)
ORDER BY hs.NgayCapNhat;
GO

-- 5.8 Chiều cao, cân nặng trung bình theo giới tính
SELECT
    nd.GioiTinh,
    COUNT(*)                                  AS SoNguoi,
    CAST(AVG(hs.ChieuCao) AS DECIMAL(5,1))    AS ChieuCaoTrungBinh,
    CAST(AVG(hs.CanNang)  AS DECIMAL(5,1))    AS CanNangTrungBinh
FROM HO_SO_SUC_KHOE AS hs
JOIN NGUOI_DUNG     AS nd ON nd.MaNguoiDung = hs.MaNguoiDung
GROUP BY nd.GioiTinh;
GO
