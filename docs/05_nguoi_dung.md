# Phần 5 — Quản lý người dùng

**Người phụ trách:** Người 5 · **Bảng:** `NGUOI_DUNG` · **Script:** [`sql/sqlserver/04_nguoi_dung.sql`](../sql/sqlserver/04_nguoi_dung.sql)

## 1. Mục đích

`NGUOI_DUNG` lưu những người được theo dõi sức khỏe. Đây là bảng gốc của hệ thống: hồ sơ sức khỏe, lần đo và cảnh báo đều gắn với một người dùng.

Phần này gồm:

- cấu trúc bảng và các ràng buộc;
- dữ liệu mẫu;
- thêm, sửa, xóa, xem;
- tìm kiếm theo tên, giới tính và độ tuổi.

## 2. Cấu trúc bảng

| Cột | Kiểu dữ liệu | Bắt buộc | Mặc định | Ý nghĩa |
|---|---|:---:|---|---|
| `MaNguoiDung` | INT IDENTITY | ✓ |  | Khóa chính, tự tăng |
| `HoTen` | NVARCHAR(100) | ✓ |  | Họ và tên |
| `GioiTinh` | NVARCHAR(5) | ✓ |  | Nam, Nữ hoặc Khác |
| `NgaySinh` | DATE | ✓ |  | Ngày sinh |
| `SoDienThoai` | VARCHAR(15) |  |  | Số điện thoại, chỉ gồm chữ số |
| `Email` | VARCHAR(100) |  |  | Thư điện tử |
| `DiaChi` | NVARCHAR(200) |  |  | Địa chỉ liên hệ |
| `NgayTao` | DATETIME2(0) | ✓ | `SYSDATETIME()` | Thời điểm tạo bản ghi |

| Ràng buộc | Loại | Cột | Ý nghĩa |
|---|---|---|---|
| `PK_NGUOI_DUNG` | Khóa chính | MaNguoiDung | Mỗi người dùng một mã duy nhất |
| `CK_NGUOI_DUNG_Email` | CHECK | Email | Có dạng tên@miền.đuôi |
| `CK_NGUOI_DUNG_GioiTinh` | CHECK | GioiTinh | Chỉ nhận Nam, Nữ, Khác |
| `CK_NGUOI_DUNG_HoTen` | CHECK | HoTen | Họ tên có ít nhất 2 ký tự |
| `CK_NGUOI_DUNG_NgaySinh` | CHECK | NgaySinh | Từ năm 1900 và không ở tương lai |
| `CK_NGUOI_DUNG_SoDienThoai` | CHECK | SoDienThoai | 9 đến 12 ký tự, toàn chữ số |
| `UQ_NGUOI_DUNG_Email` | Chỉ mục duy nhất có điều kiện | Email | Email không trùng; cho phép nhiều dòng NULL |

Một số quyết định thiết kế:

- **Không lưu tuổi.** Tuổi thay đổi theo thời gian nên được tính từ `NgaySinh` mỗi khi truy vấn; lưu tuổi sẽ sai sau mỗi lần sinh nhật.
- **Email không bắt buộc nhưng không được trùng.** `UNIQUE` thông thường của SQL Server chỉ cho phép một dòng `NULL`, nên bảng dùng chỉ mục duy nhất có điều kiện (`WHERE Email IS NOT NULL`).
- **Số điện thoại chỉ gồm chữ số.** Việc trình bày có khoảng trắng (0901 234 567) là của giao diện, không phải của dữ liệu.
- **Xóa người dùng là xóa dây chuyền.** Hồ sơ, lần đo, giá trị đo và cảnh báo của người đó bị xóa theo nhờ `ON DELETE CASCADE` ở các bảng con.

## 3. Dữ liệu mẫu

Dữ liệu mẫu gồm 12 người dùng (6 nam, 6 nữ) từ 14 đến 76 tuổi, nằm trong file [`03_du_lieu_mau.sql`](../sql/sqlserver/03_du_lieu_mau.sql).

| MaNguoiDung | HoTen | GioiTinh | NgaySinh | SoDienThoai | Email |
|---|---|---|---|---|---|
| 1 | Nguyễn Văn An | Nam | 1968-03-12 | 0901234567 | an.nguyen@example.com |
| 2 | Trần Thị Bích | Nữ | 1975-07-25 | 0912345678 | bich.tran@example.com |
| 3 | Lê Hoàng Cường | Nam | 1990-11-02 | 0933456789 | cuong.le@example.com |
| 4 | Phạm Thị Dung | Nữ | 1958-01-30 | 0944567890 | dung.pham@example.com |
| 5 | Hoàng Minh Đức | Nam | 2001-05-18 | 0355678901 | duc.hoang@example.com |
| 6 | Vũ Thị Giang | Nữ | 1983-09-09 | 0366789012 | giang.vu@example.com |
| 7 | Đặng Quốc Huy | Nam | 1949-12-21 | 0977890123 | huy.dang@example.com |
| 8 | Bùi Thị Lan | Nữ | 1996-04-14 | 0988901234 | lan.bui@example.com |
| 9 | Đỗ Thanh Long | Nam | 2012-08-06 | 0399012345 | *NULL* |
| 10 | Ngô Thị Mai | Nữ | 1964-06-17 | 0909123456 | mai.ngo@example.com |
| 11 | Dương Văn Nam | Nam | 1979-02-28 | 0918234567 | nam.duong@example.com |
| 12 | Lý Thị Oanh | Nữ | 2005-10-10 | 0327345678 | oanh.ly@example.com |

## 4. Câu lệnh và kết quả

Các kết quả dưới đây được lấy bằng cách chạy script trên SQL Server 2022 với dữ liệu mẫu. Mọi lệnh thêm, sửa, xóa minh họa đều nằm trong giao dịch rồi `ROLLBACK`, nên chạy script không làm thay đổi dữ liệu mẫu. Các truy vấn tính tuổi dùng ngày hiện tại nên kết quả về tuổi có thể khác đi khi chạy vào thời điểm khác.

### 1. XEM (SELECT)

#### 1.1 Toàn bộ người dùng

```sql
SELECT MaNguoiDung, HoTen, GioiTinh, NgaySinh, SoDienThoai, Email
FROM NGUOI_DUNG
ORDER BY MaNguoiDung;
```

**Kết quả:**

| MaNguoiDung | HoTen | GioiTinh | NgaySinh | SoDienThoai | Email |
|---|---|---|---|---|---|
| 1 | Nguyễn Văn An | Nam | 1968-03-12 | 0901234567 | an.nguyen@example.com |
| 2 | Trần Thị Bích | Nữ | 1975-07-25 | 0912345678 | bich.tran@example.com |
| 3 | Lê Hoàng Cường | Nam | 1990-11-02 | 0933456789 | cuong.le@example.com |
| 4 | Phạm Thị Dung | Nữ | 1958-01-30 | 0944567890 | dung.pham@example.com |
| 5 | Hoàng Minh Đức | Nam | 2001-05-18 | 0355678901 | duc.hoang@example.com |
| 6 | Vũ Thị Giang | Nữ | 1983-09-09 | 0366789012 | giang.vu@example.com |
| 7 | Đặng Quốc Huy | Nam | 1949-12-21 | 0977890123 | huy.dang@example.com |
| 8 | Bùi Thị Lan | Nữ | 1996-04-14 | 0988901234 | lan.bui@example.com |
| 9 | Đỗ Thanh Long | Nam | 2012-08-06 | 0399012345 | *NULL* |
| 10 | Ngô Thị Mai | Nữ | 1964-06-17 | 0909123456 | mai.ngo@example.com |
| 11 | Dương Văn Nam | Nam | 1979-02-28 | 0918234567 | nam.duong@example.com |
| 12 | Lý Thị Oanh | Nữ | 2005-10-10 | 0327345678 | oanh.ly@example.com |

#### 1.2 Một người dùng theo khóa chính

```sql
SELECT MaNguoiDung, HoTen, GioiTinh, NgaySinh, SoDienThoai, Email, DiaChi
FROM NGUOI_DUNG
WHERE MaNguoiDung = 7;
```

**Kết quả:**

| MaNguoiDung | HoTen | GioiTinh | NgaySinh | SoDienThoai | Email | DiaChi |
|---|---|---|---|---|---|---|
| 7 | Đặng Quốc Huy | Nam | 1949-12-21 | 0977890123 | huy.dang@example.com | 63 Lê Duẩn, TP. Huế |

#### 1.3 Kèm tuổi tính đến hôm nay

DATEDIFF(YEAR, ...) chỉ trừ số năm, nên phải bớt 1 nếu chưa tới sinh nhật năm nay.

```sql
SELECT
    MaNguoiDung,
    HoTen,
    NgaySinh,
    DATEDIFF(YEAR, NgaySinh, GETDATE())
      - CASE WHEN DATEADD(YEAR, DATEDIFF(YEAR, NgaySinh, GETDATE()), NgaySinh) > GETDATE()
             THEN 1 ELSE 0 END AS Tuoi
FROM NGUOI_DUNG
ORDER BY NgaySinh;
```

**Kết quả:**

| MaNguoiDung | HoTen | NgaySinh | Tuoi |
|---|---|---|---|
| 7 | Đặng Quốc Huy | 1949-12-21 | 76 |
| 4 | Phạm Thị Dung | 1958-01-30 | 68 |
| 10 | Ngô Thị Mai | 1964-06-17 | 62 |
| 1 | Nguyễn Văn An | 1968-03-12 | 58 |
| 2 | Trần Thị Bích | 1975-07-25 | 51 |
| 11 | Dương Văn Nam | 1979-02-28 | 47 |
| 6 | Vũ Thị Giang | 1983-09-09 | 43 |
| 3 | Lê Hoàng Cường | 1990-11-02 | 35 |
| 8 | Bùi Thị Lan | 1996-04-14 | 30 |
| 5 | Hoàng Minh Đức | 2001-05-18 | 25 |
| 12 | Lý Thị Oanh | 2005-10-10 | 21 |
| 9 | Đỗ Thanh Long | 2012-08-06 | 14 |

### 2. THÊM (INSERT)

#### 2.1 Thêm một người dùng; MaNguoiDung tự tăng, NgayTao lấy giá trị mặc định

```sql
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
```

**Kết quả:**

| MaNguoiDung | HoTen | GioiTinh | NgaySinh | NgayTao |
|---|---|---|---|---|
| 37 | Trịnh Gia Bảo | Nam | 1999-02-14 | 2026-10-12 18:54:06 |

#### 2.2 Thêm nhiều người dùng trong một lệnh; các cột không bắt buộc để NULL

```sql
BEGIN TRANSACTION;

    INSERT INTO NGUOI_DUNG (HoTen, GioiTinh, NgaySinh, SoDienThoai)
    VALUES (N'Mai Thị Hương', N'Nữ', '1988-12-01', '0977000111'),
           (N'Tạ Quang Vinh', N'Nam', '1971-04-22', NULL);

    SELECT COUNT(*) AS SoNguoiDungSauKhiThem FROM NGUOI_DUNG;

ROLLBACK TRANSACTION;
```

**Kết quả:**

| SoNguoiDungSauKhiThem |
|---|
| 14 |

### 3. SỬA (UPDATE)

#### 3.1 Cập nhật số điện thoại và địa chỉ của một người

```sql
BEGIN TRANSACTION;

    UPDATE NGUOI_DUNG
    SET SoDienThoai = '0901999888',
        DiaChi      = N'25 Nguyễn Huệ, Quận 1, TP. Hồ Chí Minh'
    WHERE MaNguoiDung = 1;

    SELECT MaNguoiDung, HoTen, SoDienThoai, DiaChi
    FROM NGUOI_DUNG
    WHERE MaNguoiDung = 1;

ROLLBACK TRANSACTION;
```

**Kết quả:**

| MaNguoiDung | HoTen | SoDienThoai | DiaChi |
|---|---|---|---|
| 1 | Nguyễn Văn An | 0901999888 | 25 Nguyễn Huệ, Quận 1, TP. Hồ Chí Minh |

#### 3.2 Cập nhật nhiều dòng theo điều kiện: chuẩn hóa họ tên về dạng không thừa khoảng trắng

```sql
BEGIN TRANSACTION;

    UPDATE NGUOI_DUNG
    SET HoTen = LTRIM(RTRIM(HoTen))
    WHERE HoTen <> LTRIM(RTRIM(HoTen));

    SELECT @@ROWCOUNT AS SoDongDaSua;

ROLLBACK TRANSACTION;
```

**Kết quả:**

| SoDongDaSua |
|---|
| 0 |

### 4. XÓA (DELETE)

Xóa người dùng sẽ xóa dây chuyền hồ sơ, lần đo, chi tiết và cảnh báo của họ (các khóa ngoại khai báo ON DELETE CASCADE).

```sql
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
```

**Kết quả:**

| HoSoTruocKhiXoa | LanDoTruocKhiXoa |
|---|---|
| 1 | 15 |

| NguoiDungConLai | HoSoConLai | LanDoConLai |
|---|---|---|
| 0 | 0 | 0 |

### 5. TÌM KIẾM VÀ LỌC

#### 5.1 Tìm theo một phần họ tên (có dấu)

```sql
SELECT MaNguoiDung, HoTen, GioiTinh
FROM NGUOI_DUNG
WHERE HoTen LIKE N'%Thị%'
ORDER BY HoTen;
```

**Kết quả:**

| MaNguoiDung | HoTen | GioiTinh |
|---|---|---|
| 8 | Bùi Thị Lan | Nữ |
| 12 | Lý Thị Oanh | Nữ |
| 10 | Ngô Thị Mai | Nữ |
| 4 | Phạm Thị Dung | Nữ |
| 2 | Trần Thị Bích | Nữ |
| 6 | Vũ Thị Giang | Nữ |

#### 5.2 Tìm theo tên KHÔNG DẤU: gõ "duc" vẫn ra "Đức", gõ "duong" vẫn ra "Dương"

Cơ sở dữ liệu dùng collation Vietnamese_CI_AS (phân biệt dấu). Riêng phép so sánh này ép sang Latin1_General_CI_AI: CI = không phân biệt hoa thường, AI = không phân biệt dấu (kể cả đ/d, ư/u, ơ/o).

```sql
DECLARE @TuKhoa NVARCHAR(50) = N'duc';

SELECT MaNguoiDung, HoTen, GioiTinh
FROM NGUOI_DUNG
WHERE HoTen COLLATE Latin1_General_CI_AI LIKE N'%' + @TuKhoa + N'%'
ORDER BY HoTen;
```

**Kết quả:**

| MaNguoiDung | HoTen | GioiTinh |
|---|---|---|
| 5 | Hoàng Minh Đức | Nam |

#### 5.3 Lọc theo giới tính

```sql
SELECT MaNguoiDung, HoTen, NgaySinh
FROM NGUOI_DUNG
WHERE GioiTinh = N'Nữ'
ORDER BY HoTen;
```

**Kết quả:**

| MaNguoiDung | HoTen | NgaySinh |
|---|---|---|
| 8 | Bùi Thị Lan | 1996-04-14 |
| 12 | Lý Thị Oanh | 2005-10-10 |
| 10 | Ngô Thị Mai | 1964-06-17 |
| 4 | Phạm Thị Dung | 1958-01-30 |
| 2 | Trần Thị Bích | 1975-07-25 |
| 6 | Vũ Thị Giang | 1983-09-09 |

#### 5.4 Lọc theo khoảng tuổi: từ 40 đến 59 tuổi

Tính tuổi một lần trong bảng dẫn xuất rồi lọc ở truy vấn ngoài.

```sql
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
```

**Kết quả:**

| MaNguoiDung | HoTen | GioiTinh | Tuoi |
|---|---|---|---|
| 6 | Vũ Thị Giang | Nữ | 43 |
| 11 | Dương Văn Nam | Nam | 47 |
| 2 | Trần Thị Bích | Nữ | 51 |
| 1 | Nguyễn Văn An | Nam | 58 |

#### 5.5 Kết hợp nhiều điều kiện: nam giới từ 50 tuổi, họ tên chứa "an" (không dấu)

```sql
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
```

**Kết quả:**

| MaNguoiDung | HoTen | Tuoi |
|---|---|---|
| 1 | Nguyễn Văn An | 58 |
| 7 | Đặng Quốc Huy | 76 |

#### 5.6 Người lớn tuổi nhất và nhỏ tuổi nhất

```sql
SELECT TOP (1) WITH TIES N'Lớn tuổi nhất' AS Loai, HoTen, NgaySinh
FROM NGUOI_DUNG
ORDER BY NgaySinh ASC;

SELECT TOP (1) WITH TIES N'Nhỏ tuổi nhất' AS Loai, HoTen, NgaySinh
FROM NGUOI_DUNG
ORDER BY NgaySinh DESC;
```

**Kết quả:**

| Loai | HoTen | NgaySinh |
|---|---|---|
| Lớn tuổi nhất | Đặng Quốc Huy | 1949-12-21 |

| Loai | HoTen | NgaySinh |
|---|---|---|
| Nhỏ tuổi nhất | Đỗ Thanh Long | 2012-08-06 |

#### 5.7 Người có sinh nhật trong tháng 10

```sql
SELECT HoTen, NgaySinh
FROM NGUOI_DUNG
WHERE MONTH(NgaySinh) = 10
ORDER BY DAY(NgaySinh);
```

**Kết quả:**

| HoTen | NgaySinh |
|---|---|
| Lý Thị Oanh | 2005-10-10 |

#### 5.8 Người sống ở TP. Hồ Chí Minh (tìm trong địa chỉ)

```sql
SELECT HoTen, DiaChi
FROM NGUOI_DUNG
WHERE DiaChi LIKE N'%Hồ Chí Minh%';
```

**Kết quả:**

| HoTen | DiaChi |
|---|---|
| Nguyễn Văn An | 12 Lê Lợi, Quận 1, TP. Hồ Chí Minh |
| Hoàng Minh Đức | 102 Võ Văn Ngân, TP. Thủ Đức, TP. Hồ Chí Minh |

#### 5.9 Người chưa có email

```sql
SELECT MaNguoiDung, HoTen, SoDienThoai
FROM NGUOI_DUNG
WHERE Email IS NULL;
```

**Kết quả:**

| MaNguoiDung | HoTen | SoDienThoai |
|---|---|---|
| 9 | Đỗ Thanh Long | 0399012345 |

### 6. THỐNG KÊ ĐƠN GIẢN

#### 6.1 Số người theo giới tính

```sql
SELECT GioiTinh, COUNT(*) AS SoNguoi
FROM NGUOI_DUNG
GROUP BY GioiTinh
ORDER BY SoNguoi DESC;
```

**Kết quả:**

| GioiTinh | SoNguoi |
|---|---|
| Nam | 6 |
| Nữ | 6 |

#### 6.2 Số người theo nhóm tuổi

```sql
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
```

**Kết quả:**

| NhomTuoi | SoNguoi |
|---|---|
| 1. Dưới 18 | 1 |
| 2. 18 – 39 | 4 |
| 3. 40 – 59 | 4 |
| 4. Từ 60 | 3 |

## 5. Tương ứng trong ứng dụng

| Chức năng trên ứng dụng | Câu lệnh tương ứng |
|---|---|
| Danh sách hồ sơ, ô tìm theo họ tên | Mục 5.2 (tìm không dấu) |
| Chip lọc Nam / Nữ | Mục 5.3 |
| Chip lọc nhóm tuổi | Mục 5.4 |
| Form "Thêm hồ sơ" | Mục 2.1 |
| Form "Sửa hồ sơ" | Mục 3.1 |
| Nút "Xóa hồ sơ" | Mục 4 |

Ứng dụng dùng SQLite nên câu lệnh được viết lại theo cú pháp SQLite trong `lib/features/ho_so/data/repository_impl/sqlite_ho_so_repository.dart`; việc tìm không dấu dùng hàm `bo_dau()` do ứng dụng đăng ký thay cho `COLLATE Latin1_General_CI_AI`.
