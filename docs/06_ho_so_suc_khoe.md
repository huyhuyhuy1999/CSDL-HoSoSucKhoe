# Phần 6 — Quản lý hồ sơ sức khỏe

**Người phụ trách:** Người 6 · **Bảng:** `HO_SO_SUC_KHOE` · **Script:** [`sql/sqlserver/05_ho_so_suc_khoe.sql`](../sql/sqlserver/05_ho_so_suc_khoe.sql)

## 1. Mục đích

`HO_SO_SUC_KHOE` lưu thông tin sức khỏe nền của mỗi người: chiều cao, cân nặng, nhóm máu, tiền sử bệnh, dị ứng và ngày cập nhật. Đây là những thông tin ít thay đổi, khác với các chỉ số đo hằng ngày nằm ở `LAN_DO` và `CHI_TIET_LAN_DO`.

Phần này gồm:

- cấu trúc bảng và các ràng buộc;
- dữ liệu mẫu;
- thêm, sửa, xóa, xem;
- truy vấn hồ sơ theo người dùng, theo nhóm máu, tiền sử bệnh, dị ứng.

## 2. Cấu trúc bảng

| Cột | Kiểu dữ liệu | Bắt buộc | Mặc định | Ý nghĩa |
|---|---|:---:|---|---|
| `MaHoSo` | INT IDENTITY | ✓ |  | Khóa chính, tự tăng |
| `MaNguoiDung` | INT | ✓ |  | Người sở hữu hồ sơ |
| `ChieuCao` | DECIMAL(5,1) | ✓ |  | Chiều cao (cm) |
| `CanNang` | DECIMAL(5,1) | ✓ |  | Cân nặng (kg) |
| `NhomMau` | VARCHAR(3) | ✓ |  | Nhóm máu ABO kèm Rh |
| `TienSuBenh` | NVARCHAR(500) |  |  | Tiền sử bệnh |
| `DiUng` | NVARCHAR(300) |  |  | Dị ứng, phân cách bằng dấu phẩy |
| `NgayCapNhat` | DATETIME2(0) | ✓ | `SYSDATETIME()` | Lần cập nhật hồ sơ gần nhất |

| Ràng buộc | Loại | Cột | Ý nghĩa |
|---|---|---|---|
| `PK_HO_SO_SUC_KHOE` | Khóa chính | MaHoSo | Mỗi hồ sơ một mã duy nhất |
| `UQ_HO_SO_SUC_KHOE_MaNguoiDung` | Duy nhất | MaNguoiDung | Mỗi người tối đa một hồ sơ (quan hệ 1–1) |
| `FK_HO_SO_SUC_KHOE_NGUOI_DUNG` | Khóa ngoại → NGUOI_DUNG (xóa dây chuyền) | MaNguoiDung | Hồ sơ phải thuộc một người dùng có thật; xóa người thì xóa hồ sơ |
| `CK_HO_SO_SUC_KHOE_CanNang` | CHECK | CanNang | Từ 1 đến 300 kg |
| `CK_HO_SO_SUC_KHOE_ChieuCao` | CHECK | ChieuCao | Từ 30 đến 250 cm |
| `CK_HO_SO_SUC_KHOE_NhomMau` | CHECK | NhomMau | Một trong 8 nhóm máu |

Một số quyết định thiết kế:

- **Quan hệ 1–1 với người dùng.** Khóa ngoại `MaNguoiDung` có thêm ràng buộc `UNIQUE`, nên mỗi người có tối đa một hồ sơ. Người dùng có thể tồn tại mà chưa có hồ sơ (truy vấn 5.6).
- **Vì sao tách khỏi `NGUOI_DUNG`.** Thông tin định danh (họ tên, ngày sinh, liên hệ) và thông tin y tế có mục đích sử dụng, tần suất cập nhật và mức độ nhạy cảm khác nhau; tách bảng giúp phân quyền và cập nhật độc lập.
- **Không lưu BMI.** BMI tính được từ chiều cao và cân nặng (`CanNang / (ChieuCao/100)²`); lưu thêm sẽ tạo phụ thuộc bắc cầu và có nguy cơ lệch khi sửa cân nặng.
- **`NgayCapNhat` do trigger ghi.** Trigger `TRG_HO_SO_SUC_KHOE_NgayCapNhat` tự đặt thời điểm hiện tại mỗi khi hồ sơ được sửa, nên không phụ thuộc vào việc chương trình có nhớ gán hay không.

### Trigger ghi ngày cập nhật

```sql
CREATE OR ALTER TRIGGER TRG_HO_SO_SUC_KHOE_NgayCapNhat
ON HO_SO_SUC_KHOE
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    IF UPDATE(NgayCapNhat) RETURN;

    UPDATE hs
    SET NgayCapNhat = SYSDATETIME()
    FROM HO_SO_SUC_KHOE AS hs
    JOIN inserted AS i ON i.MaHoSo = hs.MaHoSo;
END;
```

`IF UPDATE(NgayCapNhat) RETURN` cho phép câu lệnh chủ động gán cột này (ví dụ khi nạp dữ liệu cũ) mà không bị trigger ghi đè.

## 3. Dữ liệu mẫu

Mỗi người dùng mẫu có một hồ sơ. Dữ liệu được chọn để có đủ các trường hợp: có và không có tiền sử bệnh, có và không có dị ứng, đủ các mức BMI.

| MaHoSo | HoTen | ChieuCao | CanNang | NhomMau | TienSuBenh | DiUng |
|---|---|---|---|---|---|---|
| 1 | Nguyễn Văn An | 168.0 | 72.0 | O+ | Tăng huyết áp (phát hiện năm 2019), đang điều trị ngoại trú. | Penicillin |
| 2 | Trần Thị Bích | 156.0 | 58.0 | A+ | Đái tháo đường type 2. | *NULL* |
| 3 | Lê Hoàng Cường | 174.0 | 68.0 | B+ | *NULL* | Hải sản |
| 4 | Phạm Thị Dung | 152.0 | 50.0 | AB+ | Bệnh phổi tắc nghẽn mạn tính (COPD). | *NULL* |
| 5 | Hoàng Minh Đức | 178.0 | 74.0 | O- | *NULL* | Phấn hoa |
| 6 | Vũ Thị Giang | 160.0 | 54.0 | A- | Hen phế quản. | Bụi nhà, lông mèo |
| 7 | Đặng Quốc Huy | 165.0 | 63.0 | B+ | Rung nhĩ, tăng huyết áp. | Aspirin |
| 8 | Bùi Thị Lan | 158.0 | 49.0 | O+ | Thiếu máu nhẹ. | *NULL* |
| 9 | Đỗ Thanh Long | 148.0 | 40.0 | A+ | *NULL* | Sữa bò |
| 10 | Ngô Thị Mai | 154.0 | 66.0 | B- | Tăng huyết áp, rối loạn mỡ máu. | *NULL* |
| 11 | Dương Văn Nam | 170.0 | 85.0 | AB- | Béo phì độ I. | *NULL* |
| 12 | Lý Thị Oanh | 162.0 | 52.0 | O+ | *NULL* | *NULL* |

## 4. Câu lệnh và kết quả

Các kết quả dưới đây được lấy bằng cách chạy script trên SQL Server 2022 với dữ liệu mẫu. Mọi lệnh thêm, sửa, xóa minh họa đều nằm trong giao dịch rồi `ROLLBACK`. Vì `IDENTITY` không lùi lại khi `ROLLBACK`, mã của các dòng minh họa có thể không liền sau mã của dữ liệu mẫu.

### 1. XEM (SELECT)

#### 1.1 Toàn bộ hồ sơ kèm tên người dùng

```sql
SELECT hs.MaHoSo, nd.HoTen, hs.ChieuCao, hs.CanNang, hs.NhomMau, hs.NgayCapNhat
FROM HO_SO_SUC_KHOE AS hs
JOIN NGUOI_DUNG     AS nd ON nd.MaNguoiDung = hs.MaNguoiDung
ORDER BY hs.MaHoSo;
```

**Kết quả:**

| MaHoSo | HoTen | ChieuCao | CanNang | NhomMau | NgayCapNhat |
|---|---|---|---|---|---|
| 1 | Nguyễn Văn An | 168.0 | 72.0 | O+ | 2026-08-31 09:00:00 |
| 2 | Trần Thị Bích | 156.0 | 58.0 | A+ | 2026-09-29 09:00:00 |
| 3 | Lê Hoàng Cường | 174.0 | 68.0 | B+ | 2026-10-03 09:00:00 |
| 4 | Phạm Thị Dung | 152.0 | 50.0 | AB+ | 2026-09-02 09:00:00 |
| 5 | Hoàng Minh Đức | 178.0 | 74.0 | O- | 2026-09-10 09:00:00 |
| 6 | Vũ Thị Giang | 160.0 | 54.0 | A- | 2026-10-03 09:00:00 |
| 7 | Đặng Quốc Huy | 165.0 | 63.0 | B+ | 2026-09-02 09:00:00 |
| 8 | Bùi Thị Lan | 158.0 | 49.0 | O+ | 2026-09-02 09:00:00 |
| 9 | Đỗ Thanh Long | 148.0 | 40.0 | A+ | 2026-09-17 09:00:00 |
| 10 | Ngô Thị Mai | 154.0 | 66.0 | B- | 2026-09-29 09:00:00 |
| 11 | Dương Văn Nam | 170.0 | 85.0 | AB- | 2026-09-18 09:00:00 |
| 12 | Lý Thị Oanh | 162.0 | 52.0 | O+ | 2026-09-27 09:00:00 |

#### 1.2 Hồ sơ của một người dùng

```sql
SELECT nd.HoTen, nd.GioiTinh, nd.NgaySinh,
       hs.ChieuCao, hs.CanNang, hs.NhomMau, hs.TienSuBenh, hs.DiUng, hs.NgayCapNhat
FROM NGUOI_DUNG     AS nd
JOIN HO_SO_SUC_KHOE AS hs ON hs.MaNguoiDung = nd.MaNguoiDung
WHERE nd.MaNguoiDung = 7;
```

**Kết quả:**

| HoTen | GioiTinh | NgaySinh | ChieuCao | CanNang | NhomMau | TienSuBenh | DiUng | NgayCapNhat |
|---|---|---|---|---|---|---|---|---|
| Đặng Quốc Huy | Nam | 1949-12-21 | 165.0 | 63.0 | B+ | Rung nhĩ, tăng huyết áp. | Aspirin | 2026-09-02 09:00:00 |

#### 1.3 Chỉ số khối cơ thể BMI = cân nặng (kg) / chiều cao (m)², phân loại theo

thang dành cho người châu Á.

```sql
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
```

**Kết quả:**

| HoTen | ChieuCao | CanNang | BMI | PhanLoai |
|---|---|---|---|---|
| Dương Văn Nam | 170.0 | 85.0 | 29.4 | Béo phì |
| Ngô Thị Mai | 154.0 | 66.0 | 27.8 | Béo phì |
| Nguyễn Văn An | 168.0 | 72.0 | 25.5 | Béo phì |
| Trần Thị Bích | 156.0 | 58.0 | 23.8 | Thừa cân |
| Hoàng Minh Đức | 178.0 | 74.0 | 23.4 | Thừa cân |
| Đặng Quốc Huy | 165.0 | 63.0 | 23.1 | Thừa cân |
| Lê Hoàng Cường | 174.0 | 68.0 | 22.5 | Bình thường |
| Phạm Thị Dung | 152.0 | 50.0 | 21.6 | Bình thường |
| Vũ Thị Giang | 160.0 | 54.0 | 21.1 | Bình thường |
| Lý Thị Oanh | 162.0 | 52.0 | 19.8 | Bình thường |
| Bùi Thị Lan | 158.0 | 49.0 | 19.6 | Bình thường |
| Đỗ Thanh Long | 148.0 | 40.0 | 18.3 | Thiếu cân |

### 2. THÊM (INSERT)

#### 2.1 Tạo người dùng mới rồi lập hồ sơ cho họ trong cùng một giao dịch

```sql
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
```

**Kết quả:**

| HoTen | MaHoSo | ChieuCao | CanNang | NhomMau | DiUng | NgayCapNhat |
|---|---|---|---|---|---|---|
| Trịnh Gia Bảo | 18 | 172.0 | 65.5 | A+ | Tôm, cua | 2026-10-12 18:54:09 |

### 3. SỬA (UPDATE)

#### 3.1 Cập nhật cân nặng và tiền sử bệnh. Không cần gán NgayCapNhat:

trigger TRG_HO_SO_SUC_KHOE_NgayCapNhat tự ghi thời điểm hiện tại.

```sql
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
```

**Kết quả:**

| MaHoSo | CanNang | TienSuBenh | NgayCapNhatCu |
|---|---|---|---|
| 11 | 85.0 | Béo phì độ I. | 2026-09-18 09:00:00 |

| MaHoSo | CanNang | TienSuBenh | NgayCapNhatMoi |
|---|---|---|---|
| 11 | 82.5 | Béo phì độ I, đang theo chế độ giảm cân. | 2026-10-12 18:54:10 |

### 4. XÓA (DELETE)

Xóa hồ sơ không xóa người dùng: người đó trở thành "chưa có hồ sơ".

```sql
BEGIN TRANSACTION;

    DELETE FROM HO_SO_SUC_KHOE
    WHERE MaNguoiDung = 12;

    SELECT nd.MaNguoiDung, nd.HoTen, hs.MaHoSo
    FROM NGUOI_DUNG          AS nd
    LEFT JOIN HO_SO_SUC_KHOE AS hs ON hs.MaNguoiDung = nd.MaNguoiDung
    WHERE nd.MaNguoiDung = 12;

ROLLBACK TRANSACTION;
```

**Kết quả:**

| MaNguoiDung | HoTen | MaHoSo |
|---|---|---|
| 12 | Lý Thị Oanh | *NULL* |

### 5. TRUY VẤN HỒ SƠ

#### 5.1 Lọc theo nhóm máu

```sql
SELECT nd.HoTen, hs.NhomMau
FROM HO_SO_SUC_KHOE AS hs
JOIN NGUOI_DUNG     AS nd ON nd.MaNguoiDung = hs.MaNguoiDung
WHERE hs.NhomMau IN ('O+', 'O-')
ORDER BY nd.HoTen;
```

**Kết quả:**

| HoTen | NhomMau |
|---|---|
| Bùi Thị Lan | O+ |
| Hoàng Minh Đức | O- |
| Lý Thị Oanh | O+ |
| Nguyễn Văn An | O+ |

#### 5.2 Số người theo nhóm máu

```sql
SELECT NhomMau, COUNT(*) AS SoNguoi
FROM HO_SO_SUC_KHOE
GROUP BY NhomMau
ORDER BY SoNguoi DESC, NhomMau;
```

**Kết quả:**

| NhomMau | SoNguoi |
|---|---|
| O+ | 3 |
| A+ | 2 |
| B+ | 2 |
| A- | 1 |
| AB- | 1 |
| AB+ | 1 |
| B- | 1 |
| O- | 1 |

#### 5.3 Người có tiền sử bệnh

```sql
SELECT nd.HoTen, hs.TienSuBenh
FROM HO_SO_SUC_KHOE AS hs
JOIN NGUOI_DUNG     AS nd ON nd.MaNguoiDung = hs.MaNguoiDung
WHERE hs.TienSuBenh IS NOT NULL
ORDER BY nd.HoTen;
```

**Kết quả:**

| HoTen | TienSuBenh |
|---|---|
| Bùi Thị Lan | Thiếu máu nhẹ. |
| Dương Văn Nam | Béo phì độ I. |
| Đặng Quốc Huy | Rung nhĩ, tăng huyết áp. |
| Ngô Thị Mai | Tăng huyết áp, rối loạn mỡ máu. |
| Nguyễn Văn An | Tăng huyết áp (phát hiện năm 2019), đang điều trị ngoại trú. |
| Phạm Thị Dung | Bệnh phổi tắc nghẽn mạn tính (COPD). |
| Trần Thị Bích | Đái tháo đường type 2. |
| Vũ Thị Giang | Hen phế quản. |

#### 5.4 Tìm theo từ khóa trong tiền sử bệnh

```sql
SELECT nd.HoTen, hs.TienSuBenh
FROM HO_SO_SUC_KHOE AS hs
JOIN NGUOI_DUNG     AS nd ON nd.MaNguoiDung = hs.MaNguoiDung
WHERE hs.TienSuBenh LIKE N'%huyết áp%';
```

**Kết quả:**

| HoTen | TienSuBenh |
|---|---|
| Nguyễn Văn An | Tăng huyết áp (phát hiện năm 2019), đang điều trị ngoại trú. |
| Đặng Quốc Huy | Rung nhĩ, tăng huyết áp. |
| Ngô Thị Mai | Tăng huyết áp, rối loạn mỡ máu. |

#### 5.5 Người có dị ứng

```sql
SELECT nd.HoTen, hs.DiUng
FROM HO_SO_SUC_KHOE AS hs
JOIN NGUOI_DUNG     AS nd ON nd.MaNguoiDung = hs.MaNguoiDung
WHERE hs.DiUng IS NOT NULL
ORDER BY nd.HoTen;
```

**Kết quả:**

| HoTen | DiUng |
|---|---|
| Đặng Quốc Huy | Aspirin |
| Đỗ Thanh Long | Sữa bò |
| Hoàng Minh Đức | Phấn hoa |
| Lê Hoàng Cường | Hải sản |
| Nguyễn Văn An | Penicillin |
| Vũ Thị Giang | Bụi nhà, lông mèo |

#### 5.6 Người dùng CHƯA có hồ sơ (LEFT JOIN rồi giữ những dòng không khớp)

Với dữ liệu mẫu, truy vấn này không trả về dòng nào.

```sql
SELECT nd.MaNguoiDung, nd.HoTen
FROM NGUOI_DUNG          AS nd
LEFT JOIN HO_SO_SUC_KHOE AS hs ON hs.MaNguoiDung = nd.MaNguoiDung
WHERE hs.MaHoSo IS NULL;
```

**Kết quả:**

*(Truy vấn không trả về dòng nào.)*

#### 5.7 Hồ sơ chưa được cập nhật trong 30 ngày tính đến một mốc cho trước

```sql
DECLARE @Moc DATE = '2026-10-10';

SELECT nd.HoTen, hs.NgayCapNhat,
       DATEDIFF(DAY, hs.NgayCapNhat, @Moc) AS SoNgayChuaCapNhat
FROM HO_SO_SUC_KHOE AS hs
JOIN NGUOI_DUNG     AS nd ON nd.MaNguoiDung = hs.MaNguoiDung
WHERE hs.NgayCapNhat < DATEADD(DAY, -30, @Moc)
ORDER BY hs.NgayCapNhat;
```

**Kết quả:**

| HoTen | NgayCapNhat | SoNgayChuaCapNhat |
|---|---|---|
| Nguyễn Văn An | 2026-08-31 09:00:00 | 40 |
| Phạm Thị Dung | 2026-09-02 09:00:00 | 38 |
| Đặng Quốc Huy | 2026-09-02 09:00:00 | 38 |
| Bùi Thị Lan | 2026-09-02 09:00:00 | 38 |

#### 5.8 Chiều cao, cân nặng trung bình theo giới tính

```sql
SELECT
    nd.GioiTinh,
    COUNT(*)                                  AS SoNguoi,
    CAST(AVG(hs.ChieuCao) AS DECIMAL(5,1))    AS ChieuCaoTrungBinh,
    CAST(AVG(hs.CanNang)  AS DECIMAL(5,1))    AS CanNangTrungBinh
FROM HO_SO_SUC_KHOE AS hs
JOIN NGUOI_DUNG     AS nd ON nd.MaNguoiDung = hs.MaNguoiDung
GROUP BY nd.GioiTinh;
```

**Kết quả:**

| GioiTinh | SoNguoi | ChieuCaoTrungBinh | CanNangTrungBinh |
|---|---|---|---|
| Nam | 6 | 167.2 | 67.0 |
| Nữ | 6 | 157.0 | 54.8 |

## 5. Tương ứng trong ứng dụng

| Chức năng trên ứng dụng | Câu lệnh tương ứng |
|---|---|
| Màn hình "Chi tiết hồ sơ" | Mục 1.2 và 1.3 |
| Ô BMI kèm phân loại | Mục 1.3 |
| Form "Thêm hồ sơ" (ghi người dùng và hồ sơ cùng lúc) | Mục 2.1 |
| Form "Sửa hồ sơ" | Mục 3.1 |
| Dòng "Cập nhật ngày …" | Trigger ghi ngày cập nhật |

Ứng dụng đọc hồ sơ qua view `V_HO_SO_TONG_HOP` (xem Phần 11), view này ghép sẵn người dùng, hồ sơ, tuổi, BMI và số liệu đo.
