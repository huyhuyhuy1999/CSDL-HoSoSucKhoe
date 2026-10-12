-- ============================================================================
-- 04. QUẢN LÝ NGƯỜI DÙNG (Người 5)
--
-- Bảng: NGUOI_DUNG
-- Nội dung: xem, thêm, sửa, xóa; tìm kiếm theo tên, giới tính và độ tuổi.
--
-- Các lệnh thêm / sửa / xóa minh họa đều nằm trong giao dịch rồi ROLLBACK,
-- nên chạy file này không làm thay đổi dữ liệu mẫu.
-- ============================================================================

USE QuanLyHoSoSucKhoe;
GO

-- ============================================================================
-- 1. XEM (SELECT)
-- ============================================================================

-- 1.1 Toàn bộ người dùng
SELECT MaNguoiDung, HoTen, GioiTinh, NgaySinh, SoDienThoai, Email
FROM NGUOI_DUNG
ORDER BY MaNguoiDung;

-- 1.2 Một người dùng theo khóa chính
SELECT MaNguoiDung, HoTen, GioiTinh, NgaySinh, SoDienThoai, Email, DiaChi
FROM NGUOI_DUNG
WHERE MaNguoiDung = 7;

-- 1.3 Kèm tuổi tính đến hôm nay.
-- DATEDIFF(YEAR, ...) chỉ trừ số năm, nên phải bớt 1 nếu chưa tới sinh nhật năm nay.
SELECT
    MaNguoiDung,
    HoTen,
    NgaySinh,
    DATEDIFF(YEAR, NgaySinh, GETDATE())
      - CASE WHEN DATEADD(YEAR, DATEDIFF(YEAR, NgaySinh, GETDATE()), NgaySinh) > GETDATE()
             THEN 1 ELSE 0 END AS Tuoi
FROM NGUOI_DUNG
ORDER BY NgaySinh;
GO

-- ============================================================================
-- 2. THÊM (INSERT)
-- ============================================================================

-- 2.1 Thêm một người dùng; MaNguoiDung tự tăng, NgayTao lấy giá trị mặc định.
BEGIN TRANSACTION;

    INSERT INTO NGUOI_DUNG (HoTen, GioiTinh, NgaySinh, SoDienThoai, Email, DiaChi)
    VALUES (N'Trịnh Gia Bảo', N'Nam', '1999-02-14', '0935111222',
            'bao.trinh@example.com', N'9 Hai Bà Trưng, Hoàn Kiếm, Hà Nội');

    -- SCOPE_IDENTITY() trả về khóa chính vừa được sinh trong phạm vi hiện tại.
    DECLARE @MaMoi INT = SCOPE_IDENTITY();

    SELECT MaNguoiDung, HoTen, GioiTinh, NgaySinh, NgayTao
    FROM NGUOI_DUNG
    WHERE MaNguoiDung = @MaMoi;

ROLLBACK TRANSACTION;
GO

-- 2.2 Thêm nhiều người dùng trong một lệnh; các cột không bắt buộc để NULL.
BEGIN TRANSACTION;

    INSERT INTO NGUOI_DUNG (HoTen, GioiTinh, NgaySinh, SoDienThoai)
    VALUES (N'Mai Thị Hương', N'Nữ', '1988-12-01', '0977000111'),
           (N'Tạ Quang Vinh', N'Nam', '1971-04-22', NULL);

    SELECT COUNT(*) AS SoNguoiDungSauKhiThem FROM NGUOI_DUNG;

ROLLBACK TRANSACTION;
GO

-- ============================================================================
-- 3. SỬA (UPDATE)
-- ============================================================================

-- 3.1 Cập nhật số điện thoại và địa chỉ của một người
BEGIN TRANSACTION;

    UPDATE NGUOI_DUNG
    SET SoDienThoai = '0901999888',
        DiaChi      = N'25 Nguyễn Huệ, Quận 1, TP. Hồ Chí Minh'
    WHERE MaNguoiDung = 1;

    SELECT MaNguoiDung, HoTen, SoDienThoai, DiaChi
    FROM NGUOI_DUNG
    WHERE MaNguoiDung = 1;

ROLLBACK TRANSACTION;
GO

-- 3.2 Cập nhật nhiều dòng theo điều kiện: chuẩn hóa họ tên về dạng không thừa khoảng trắng
BEGIN TRANSACTION;

    UPDATE NGUOI_DUNG
    SET HoTen = LTRIM(RTRIM(HoTen))
    WHERE HoTen <> LTRIM(RTRIM(HoTen));

    SELECT @@ROWCOUNT AS SoDongDaSua;

ROLLBACK TRANSACTION;
GO

-- ============================================================================
-- 4. XÓA (DELETE)
-- ============================================================================

-- Xóa người dùng sẽ xóa dây chuyền hồ sơ, lần đo, chi tiết và cảnh báo của họ
-- (các khóa ngoại khai báo ON DELETE CASCADE).
BEGIN TRANSACTION;

    SELECT
        (SELECT COUNT(*) FROM HO_SO_SUC_KHOE WHERE MaNguoiDung = 12) AS HoSoTruocKhiXoa,
        (SELECT COUNT(*) FROM LAN_DO         WHERE MaNguoiDung = 12) AS LanDoTruocKhiXoa;

    DELETE FROM NGUOI_DUNG
    WHERE MaNguoiDung = 12;

    SELECT
        (SELECT COUNT(*) FROM NGUOI_DUNG     WHERE MaNguoiDung = 12) AS NguoiDungConLai,
        (SELECT COUNT(*) FROM HO_SO_SUC_KHOE WHERE MaNguoiDung = 12) AS HoSoConLai,
        (SELECT COUNT(*) FROM LAN_DO         WHERE MaNguoiDung = 12) AS LanDoConLai;

ROLLBACK TRANSACTION;
GO

-- ============================================================================
-- 5. TÌM KIẾM VÀ LỌC
-- ============================================================================

-- 5.1 Tìm theo một phần họ tên (có dấu)
SELECT MaNguoiDung, HoTen, GioiTinh
FROM NGUOI_DUNG
WHERE HoTen LIKE N'%Thị%'
ORDER BY HoTen;

-- 5.2 Tìm theo tên KHÔNG DẤU: gõ "duc" vẫn ra "Đức", gõ "duong" vẫn ra "Dương".
-- Cơ sở dữ liệu dùng collation Vietnamese_CI_AS (phân biệt dấu). Riêng phép so
-- sánh này ép sang Latin1_General_CI_AI: CI = không phân biệt hoa thường,
-- AI = không phân biệt dấu (kể cả đ/d, ư/u, ơ/o).
DECLARE @TuKhoa NVARCHAR(50) = N'duc';

SELECT MaNguoiDung, HoTen, GioiTinh
FROM NGUOI_DUNG
WHERE HoTen COLLATE Latin1_General_CI_AI LIKE N'%' + @TuKhoa + N'%'
ORDER BY HoTen;
GO

-- 5.3 Lọc theo giới tính
SELECT MaNguoiDung, HoTen, NgaySinh
FROM NGUOI_DUNG
WHERE GioiTinh = N'Nữ'
ORDER BY HoTen;

-- 5.4 Lọc theo khoảng tuổi: từ 40 đến 59 tuổi.
-- Tính tuổi một lần trong bảng dẫn xuất rồi lọc ở truy vấn ngoài.
SELECT MaNguoiDung, HoTen, GioiTinh, Tuoi
FROM (
    SELECT
        MaNguoiDung, HoTen, GioiTinh,
        DATEDIFF(YEAR, NgaySinh, GETDATE())
          - CASE WHEN DATEADD(YEAR, DATEDIFF(YEAR, NgaySinh, GETDATE()), NgaySinh) > GETDATE()
                 THEN 1 ELSE 0 END AS Tuoi
    FROM NGUOI_DUNG
) AS nd
WHERE Tuoi BETWEEN 40 AND 59
ORDER BY Tuoi;

-- 5.5 Kết hợp nhiều điều kiện: nam giới từ 50 tuổi, họ tên chứa "an" (không dấu)
SELECT MaNguoiDung, HoTen, Tuoi
FROM (
    SELECT
        MaNguoiDung, HoTen, GioiTinh,
        DATEDIFF(YEAR, NgaySinh, GETDATE())
          - CASE WHEN DATEADD(YEAR, DATEDIFF(YEAR, NgaySinh, GETDATE()), NgaySinh) > GETDATE()
                 THEN 1 ELSE 0 END AS Tuoi
    FROM NGUOI_DUNG
) AS nd
WHERE GioiTinh = N'Nam'
  AND Tuoi >= 50
  AND HoTen COLLATE Latin1_General_CI_AI LIKE N'%an%';

-- 5.6 Người lớn tuổi nhất và nhỏ tuổi nhất
SELECT TOP (1) WITH TIES N'Lớn tuổi nhất' AS Loai, HoTen, NgaySinh
FROM NGUOI_DUNG
ORDER BY NgaySinh ASC;

SELECT TOP (1) WITH TIES N'Nhỏ tuổi nhất' AS Loai, HoTen, NgaySinh
FROM NGUOI_DUNG
ORDER BY NgaySinh DESC;

-- 5.7 Người có sinh nhật trong tháng 10
SELECT HoTen, NgaySinh
FROM NGUOI_DUNG
WHERE MONTH(NgaySinh) = 10
ORDER BY DAY(NgaySinh);

-- 5.8 Người sống ở TP. Hồ Chí Minh (tìm trong địa chỉ)
SELECT HoTen, DiaChi
FROM NGUOI_DUNG
WHERE DiaChi LIKE N'%Hồ Chí Minh%';

-- 5.9 Người chưa có email
SELECT MaNguoiDung, HoTen, SoDienThoai
FROM NGUOI_DUNG
WHERE Email IS NULL;
GO

-- ============================================================================
-- 6. THỐNG KÊ ĐƠN GIẢN
-- ============================================================================

-- 6.1 Số người theo giới tính
SELECT GioiTinh, COUNT(*) AS SoNguoi
FROM NGUOI_DUNG
GROUP BY GioiTinh
ORDER BY SoNguoi DESC;

-- 6.2 Số người theo nhóm tuổi
SELECT NhomTuoi, COUNT(*) AS SoNguoi
FROM (
    SELECT
        CASE
            WHEN Tuoi < 18 THEN N'1. Dưới 18'
            WHEN Tuoi < 40 THEN N'2. 18 – 39'
            WHEN Tuoi < 60 THEN N'3. 40 – 59'
            ELSE N'4. Từ 60'
        END AS NhomTuoi
    FROM (
        SELECT
            DATEDIFF(YEAR, NgaySinh, GETDATE())
              - CASE WHEN DATEADD(YEAR, DATEDIFF(YEAR, NgaySinh, GETDATE()), NgaySinh) > GETDATE()
                     THEN 1 ELSE 0 END AS Tuoi
        FROM NGUOI_DUNG
    ) AS t
) AS nhom
GROUP BY NhomTuoi
ORDER BY NhomTuoi;
GO
