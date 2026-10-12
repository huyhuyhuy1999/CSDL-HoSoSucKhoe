# Phần 8 — Quản lý lần đo và lịch sử

**Người phụ trách:** Người 8 · **Bảng:** `LAN_DO` · **Script:** [`sql/sqlserver/07_lan_do.sql`](../sql/sqlserver/07_lan_do.sql)

## 1. Mục đích

Mỗi dòng của `LAN_DO` là một lần đo: **ai** được đo, **lúc nào**, bằng **thiết bị nào** hay nhập thủ công. Giá trị của từng chỉ số nằm ở `CHI_TIET_LAN_DO` (Phần 7). Lịch sử theo dõi sức khỏe của một người chính là các lần đo của người đó sắp theo thời gian.

Phần này gồm:

- cấu trúc bảng và các ràng buộc;
- dữ liệu mẫu ở nhiều thời điểm;
- thêm, sửa, xóa, xem;
- truy vấn lịch sử theo người, theo ngày, theo tháng và theo khoảng thời gian.

## 2. Cấu trúc bảng

| Cột | Kiểu dữ liệu | Bắt buộc | Mặc định | Ý nghĩa |
|---|---|:---:|---|---|
| `MaLanDo` | INT IDENTITY | ✓ |  | Khóa chính, tự tăng |
| `MaNguoiDung` | INT | ✓ |  | Người được đo |
| `MaThietBi` | INT |  |  | Thiết bị đo; NULL nếu nhập thủ công |
| `NguonDuLieu` | NVARCHAR(20) | ✓ |  | Thiết bị hoặc Thủ công |
| `ThoiGianDo` | DATETIME2(0) | ✓ | `SYSDATETIME()` | Thời điểm đo |
| `GhiChu` | NVARCHAR(300) |  |  | Ghi chú của lần đo |

| Ràng buộc | Loại | Cột | Ý nghĩa |
|---|---|---|---|
| `PK_LAN_DO` | Khóa chính | MaLanDo | Mỗi lần đo một mã duy nhất |
| `FK_LAN_DO_NGUOI_DUNG` | Khóa ngoại → NGUOI_DUNG (xóa dây chuyền) | MaNguoiDung | Lần đo phải của một người dùng có thật; xóa người thì xóa lần đo |
| `FK_LAN_DO_THIET_BI` | Khóa ngoại → THIET_BI | MaThietBi | Thiết bị phải tồn tại; không xóa được thiết bị đã có lần đo |
| `CK_LAN_DO_NguonDuLieu` | CHECK | NguonDuLieu | Chỉ nhận Thiết bị, Thủ công |
| `CK_LAN_DO_NguonKhopThietBi` | CHECK | (nhiều cột) | Nguồn Thiết bị phải có mã thiết bị, nguồn Thủ công thì không |
| `CK_LAN_DO_ThoiGianDo` | CHECK | ThoiGianDo | Không ở tương lai |
| `IX_LAN_DO_MaThietBi` | Chỉ mục | MaThietBi | Tăng tốc thống kê theo thiết bị |
| `IX_LAN_DO_NguoiDung_ThoiGian` | Chỉ mục | MaNguoiDung, ThoiGianDo | Tăng tốc truy vấn lịch sử của một người |
| `IX_LAN_DO_ThoiGianDo` | Chỉ mục | ThoiGianDo | Tăng tốc truy vấn theo khoảng thời gian |

Một số quyết định thiết kế:

- **Nguồn dữ liệu và thiết bị phải khớp nhau.** Ràng buộc `CK_LAN_DO_NguonKhopThietBi` loại bỏ hai trạng thái vô nghĩa: nguồn "Thiết bị" mà không có mã thiết bị, và nguồn "Thủ công" mà lại có mã thiết bị.
- **Thời gian đo không ở tương lai.** `CK_LAN_DO_ThoiGianDo` cho phép lệch tối đa 5 phút để dung sai đồng hồ giữa máy nhập và máy chủ.
- **Xóa người dùng thì xóa lịch sử, nhưng không cho xóa thiết bị đã dùng.** Hai khóa ngoại có hành vi khác nhau vì ý nghĩa khác nhau: lịch sử đo không còn giá trị khi người dùng bị xóa, nhưng một lần đo mất thông tin thiết bị thì mất nguồn gốc dữ liệu.
- **Chỉ mục theo `(MaNguoiDung, ThoiGianDo DESC)`.** Truy vấn phổ biến nhất là "lịch sử của một người, mới nhất trước"; chỉ mục này phục vụ đúng truy vấn đó mà không cần sắp xếp lại.

### Lọc theo ngày mà vẫn dùng được chỉ mục

Để lấy các lần đo trong một ngày, có hai cách viết:

```sql
-- Cách 1: bọc cột trong hàm — SQL Server phải tính CAST cho mọi dòng
WHERE CAST(ThoiGianDo AS DATE) = '2026-10-10'

-- Cách 2: so sánh theo khoảng nửa mở — dùng được chỉ mục trên ThoiGianDo
WHERE ThoiGianDo >= '2026-10-10' AND ThoiGianDo < '2026-10-11'
```

Script dùng cách 2 cho mọi truy vấn lọc theo thời gian. Khoảng nửa mở `[đầu ngày, đầu ngày hôm sau)` cũng tránh được lỗi bỏ sót các lần đo lúc 23:59:59.

## 3. Dữ liệu mẫu

Dữ liệu mẫu có 265 lần đo của 12 người trong 30 ngày, từ 11/09/2026 đến 10/10/2026. Người có bệnh nền được đo dày hơn; mỗi ngày có buổi sáng và buổi tối.

| LanDoDauTien | LanDoCuoiCung | TongSoLanDo | SoNguoi | SoNgayCoDo |
|---|---|---|---|---|
| 2026-09-11 07:21:00 | 2026-10-10 21:22:00 | 265 | 12 | 30 |

Mười lần đo cuối:

| MaLanDo | HoTen | ThoiGianDo | NguonDuLieu | MaThietBi | GhiChu |
|---|---|---|---|---|---|
| 265 | Nguyễn Văn An | 2026-10-10 21:22:00 | Thiết bị | 1 | *NULL* |
| 264 | Ngô Thị Mai | 2026-10-10 19:51:00 | Thiết bị | 1 | *NULL* |
| 263 | Bùi Thị Lan | 2026-10-10 19:42:00 | Thiết bị | 1 | *NULL* |
| 262 | Phạm Thị Dung | 2026-10-10 18:35:00 | Thiết bị | 1 | *NULL* |
| 261 | Đặng Quốc Huy | 2026-10-10 18:21:00 | Thiết bị | 2 | *NULL* |
| 260 | Đặng Quốc Huy | 2026-10-10 18:12:00 | Thiết bị | 1 | Hồi hộp, đánh trống ngực. |
| 259 | Phạm Thị Dung | 2026-10-10 17:18:00 | Thiết bị | 2 | Đo sau khi đi bộ, hơi khó thở. |
| 258 | Lê Hoàng Cường | 2026-10-10 15:55:00 | Thiết bị | 1 | *NULL* |
| 257 | Phạm Thị Dung | 2026-10-10 08:07:00 | Thiết bị | 1 | *NULL* |
| 256 | Ngô Thị Mai | 2026-10-10 07:34:00 | Thủ công | *NULL* | *NULL* |

## 4. Câu lệnh và kết quả

Các kết quả dưới đây được lấy bằng cách chạy script trên SQL Server 2022 với dữ liệu mẫu. Mọi lệnh thêm, sửa, xóa minh họa đều nằm trong giao dịch rồi `ROLLBACK`. Vì `IDENTITY` không lùi lại khi `ROLLBACK`, mã của các dòng minh họa có thể không liền sau mã của dữ liệu mẫu.

### 1. XEM (SELECT)

#### 1.1 Mười lần đo mới nhất, kèm tên người được đo và nguồn dữ liệu

```sql
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
```

**Kết quả:**

| MaLanDo | HoTen | ThoiGianDo | NguonDuLieu | TenThietBi |
|---|---|---|---|---|
| 265 | Nguyễn Văn An | 2026-10-10 21:22:00 | Thiết bị | ESP32 Health Monitor |
| 264 | Ngô Thị Mai | 2026-10-10 19:51:00 | Thiết bị | ESP32 Health Monitor |
| 263 | Bùi Thị Lan | 2026-10-10 19:42:00 | Thiết bị | ESP32 Health Monitor |
| 262 | Phạm Thị Dung | 2026-10-10 18:35:00 | Thiết bị | ESP32 Health Monitor |
| 261 | Đặng Quốc Huy | 2026-10-10 18:21:00 | Thiết bị | Máy đo SpO2 kẹp ngón |
| 260 | Đặng Quốc Huy | 2026-10-10 18:12:00 | Thiết bị | ESP32 Health Monitor |
| 259 | Phạm Thị Dung | 2026-10-10 17:18:00 | Thiết bị | Máy đo SpO2 kẹp ngón |
| 258 | Lê Hoàng Cường | 2026-10-10 15:55:00 | Thiết bị | ESP32 Health Monitor |
| 257 | Phạm Thị Dung | 2026-10-10 08:07:00 | Thiết bị | ESP32 Health Monitor |
| 256 | Ngô Thị Mai | 2026-10-10 07:34:00 | Thủ công | *NULL* |

#### 1.2 Một lần đo theo khóa chính

```sql
SELECT ld.MaLanDo, nd.HoTen, ld.ThoiGianDo, ld.NguonDuLieu, tb.TenThietBi, ld.GhiChu
FROM LAN_DO        AS ld
JOIN NGUOI_DUNG    AS nd ON nd.MaNguoiDung = ld.MaNguoiDung
LEFT JOIN THIET_BI AS tb ON tb.MaThietBi = ld.MaThietBi
WHERE ld.MaLanDo = 260;
```

**Kết quả:**

| MaLanDo | HoTen | ThoiGianDo | NguonDuLieu | TenThietBi | GhiChu |
|---|---|---|---|---|---|
| 260 | Đặng Quốc Huy | 2026-10-10 18:12:00 | Thiết bị | ESP32 Health Monitor | Hồi hộp, đánh trống ngực. |

### 2. THÊM (INSERT)

#### 2.1 Thêm một lần đo từ thiết bị cùng các chỉ số của nó

Hai bảng phải được ghi trong cùng một giao dịch: nếu ghi chi tiết lỗi thì lần đo cũng không được lưu.

```sql
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
```

**Kết quả:**

| MaLanDo | ThoiGianDo | TenChiSo | GiaTri | DonViDo |
|---|---|---|---|---|
| 294 | 2026-10-10 20:15:00 | Nhiệt độ | 36.7 | °C |
| 294 | 2026-10-10 20:15:00 | Nhịp tim | 81.0 | bpm |
| 294 | 2026-10-10 20:15:00 | SpO2 | 98.0 | % |
| 294 | 2026-10-10 20:15:00 | Huyết áp tâm thu | 121.0 | mmHg |
| 294 | 2026-10-10 20:15:00 | Huyết áp tâm trương | 79.0 | mmHg |

#### 2.2 Thêm một lần đo nhập thủ công: không có thiết bị, thời gian mặc định là hiện tại

```sql
BEGIN TRANSACTION;

    INSERT INTO LAN_DO (MaNguoiDung, NguonDuLieu)
    VALUES (5, N'Thủ công');

    SELECT MaLanDo, MaNguoiDung, MaThietBi, NguonDuLieu, ThoiGianDo
    FROM LAN_DO
    WHERE MaLanDo = SCOPE_IDENTITY();

ROLLBACK TRANSACTION;
```

**Kết quả:**

| MaLanDo | MaNguoiDung | MaThietBi | NguonDuLieu | ThoiGianDo |
|---|---|---|---|---|
| 295 | 5 | *NULL* | Thủ công | 2026-10-12 18:54:15 |

### 3. SỬA (UPDATE)

Sửa ghi chú và giờ đo của một lần đo

```sql
BEGIN TRANSACTION;

    UPDATE LAN_DO
    SET GhiChu     = N'Đo lại sau khi nghỉ 15 phút',
        ThoiGianDo = DATEADD(MINUTE, 15, ThoiGianDo)
    WHERE MaLanDo = 260;

    SELECT MaLanDo, ThoiGianDo, GhiChu
    FROM LAN_DO
    WHERE MaLanDo = 260;

ROLLBACK TRANSACTION;
```

**Kết quả:**

| MaLanDo | ThoiGianDo | GhiChu |
|---|---|---|
| 260 | 2026-10-10 18:27:00 | Đo lại sau khi nghỉ 15 phút |

### 4. XÓA (DELETE)

Xóa một lần đo kéo theo các chi tiết và cảnh báo của nó (ON DELETE CASCADE)

```sql
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
```

**Kết quả:**

| ChiTietTruocKhiXoa | CanhBaoTruocKhiXoa |
|---|---|
| 5 | 3 |

| ChiTietConLai | CanhBaoConLai |
|---|---|
| 0 | 0 |

### 5. LỊCH SỬ ĐO

#### 5.1 Lịch sử của một người, mới nhất trước

```sql
SELECT TOP (10) ld.MaLanDo, ld.ThoiGianDo, ld.NguonDuLieu, tb.TenThietBi
FROM LAN_DO        AS ld
LEFT JOIN THIET_BI AS tb ON tb.MaThietBi = ld.MaThietBi
WHERE ld.MaNguoiDung = 7
ORDER BY ld.ThoiGianDo DESC;
```

**Kết quả:**

| MaLanDo | ThoiGianDo | NguonDuLieu | TenThietBi |
|---|---|---|---|
| 261 | 2026-10-10 18:21:00 | Thiết bị | Máy đo SpO2 kẹp ngón |
| 260 | 2026-10-10 18:12:00 | Thiết bị | ESP32 Health Monitor |
| 250 | 2026-10-09 18:41:00 | Thiết bị | ESP32 Health Monitor |
| 247 | 2026-10-09 07:20:00 | Thiết bị | ESP32 Health Monitor |
| 244 | 2026-10-08 21:19:00 | Thiết bị | ESP32 Health Monitor |
| 231 | 2026-10-07 07:38:00 | Thủ công | *NULL* |
| 206 | 2026-10-04 07:00:00 | Thiết bị | ESP32 Health Monitor |
| 201 | 2026-10-03 08:29:00 | Thiết bị | ESP32 Health Monitor |
| 184 | 2026-10-01 20:59:00 | Thiết bị | Nhiệt kế hồng ngoại |
| 175 | 2026-09-30 20:47:00 | Thiết bị | ESP32 Health Monitor |

#### 5.2 Các lần đo trong một ngày

So sánh theo khoảng [đầu ngày, đầu ngày hôm sau) để vẫn dùng được chỉ mục trên ThoiGianDo, thay vì bọc cột trong hàm CAST.

```sql
DECLARE @Ngay DATE = '2026-10-10';

SELECT ld.MaLanDo, nd.HoTen, CONVERT(VARCHAR(5), ld.ThoiGianDo, 108) AS Gio, ld.NguonDuLieu
FROM LAN_DO     AS ld
JOIN NGUOI_DUNG AS nd ON nd.MaNguoiDung = ld.MaNguoiDung
WHERE ld.ThoiGianDo >= @Ngay
  AND ld.ThoiGianDo <  DATEADD(DAY, 1, @Ngay)
ORDER BY ld.ThoiGianDo;
```

**Kết quả:**

| MaLanDo | HoTen | Gio | NguonDuLieu |
|---|---|---|---|
| 251 | Lê Hoàng Cường | 06:40 | Thiết bị |
| 252 | Nguyễn Văn An | 06:41 | Thiết bị |
| 253 | Lý Thị Oanh | 06:54 | Thiết bị |
| 254 | Dương Văn Nam | 06:57 | Thủ công |
| 255 | Trần Thị Bích | 07:11 | Thiết bị |
| 256 | Ngô Thị Mai | 07:34 | Thủ công |
| 257 | Phạm Thị Dung | 08:07 | Thiết bị |
| 258 | Lê Hoàng Cường | 15:55 | Thiết bị |
| 259 | Phạm Thị Dung | 17:18 | Thiết bị |
| 260 | Đặng Quốc Huy | 18:12 | Thiết bị |
| 261 | Đặng Quốc Huy | 18:21 | Thiết bị |
| 262 | Phạm Thị Dung | 18:35 | Thiết bị |

*… còn 3 dòng nữa (tổng cộng 15 dòng).*

#### 5.3 Số lần đo của từng người trong một tháng

```sql
SELECT nd.HoTen, COUNT(*) AS SoLanDo
FROM LAN_DO     AS ld
JOIN NGUOI_DUNG AS nd ON nd.MaNguoiDung = ld.MaNguoiDung
WHERE YEAR(ld.ThoiGianDo) = 2026 AND MONTH(ld.ThoiGianDo) = 10
GROUP BY nd.MaNguoiDung, nd.HoTen
ORDER BY SoLanDo DESC, nd.HoTen;
```

**Kết quả:**

| HoTen | SoLanDo |
|---|---|
| Phạm Thị Dung | 12 |
| Ngô Thị Mai | 10 |
| Trần Thị Bích | 10 |
| Đặng Quốc Huy | 9 |
| Nguyễn Văn An | 9 |
| Bùi Thị Lan | 7 |
| Đỗ Thanh Long | 7 |
| Lê Hoàng Cường | 6 |
| Lý Thị Oanh | 6 |
| Dương Văn Nam | 5 |
| Hoàng Minh Đức | 4 |
| Vũ Thị Giang | 4 |

#### 5.4 Lịch sử của một người trong một khoảng thời gian

```sql
DECLARE @TuNgay  DATE = '2026-10-04';
DECLARE @DenNgay DATE = '2026-10-10';

SELECT ld.MaLanDo, ld.ThoiGianDo, ld.NguonDuLieu
FROM LAN_DO AS ld
WHERE ld.MaNguoiDung = 1
  AND ld.ThoiGianDo >= @TuNgay
  AND ld.ThoiGianDo <  DATEADD(DAY, 1, @DenNgay)
ORDER BY ld.ThoiGianDo DESC;
```

**Kết quả:**

| MaLanDo | ThoiGianDo | NguonDuLieu |
|---|---|---|
| 265 | 2026-10-10 21:22:00 | Thiết bị |
| 252 | 2026-10-10 06:41:00 | Thiết bị |
| 245 | 2026-10-09 06:45:00 | Thiết bị |
| 232 | 2026-10-07 07:40:00 | Thiết bị |
| 217 | 2026-10-06 06:32:00 | Thủ công |

#### 5.5 Lịch sử kèm các chỉ số trên cùng một dòng (xoay dọc thành ngang)

Mỗi chỉ số là một cột; lần đo thiếu chỉ số nào thì cột đó NULL.

```sql
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
```

**Kết quả:**

| MaLanDo | ThoiGianDo | NhietDo | NhipTim | SpO2 | TamThu | TamTruong |
|---|---|---|---|---|---|---|
| 261 | 2026-10-10 18:21:00 | *NULL* | 96.0 | 95.0 | *NULL* | *NULL* |
| 260 | 2026-10-10 18:12:00 | 36.9 | 126.0 | 95.0 | 148.0 | 92.0 |
| 250 | 2026-10-09 18:41:00 | 36.4 | 82.0 | 96.0 | 141.0 | 82.0 |
| 247 | 2026-10-09 07:20:00 | 36.7 | 87.0 | 96.0 | 135.0 | 82.0 |
| 244 | 2026-10-08 21:19:00 | 36.7 | 93.0 | 97.0 | 123.0 | 86.0 |
| 231 | 2026-10-07 07:38:00 | 37.2 | 86.0 | 98.0 | 126.0 | 84.0 |
| 206 | 2026-10-04 07:00:00 | 36.9 | 111.0 | 95.0 | 145.0 | 86.0 |
| 201 | 2026-10-03 08:29:00 | 36.5 | 73.0 | 96.0 | 143.0 | 85.0 |
| 184 | 2026-10-01 20:59:00 | 36.7 | *NULL* | *NULL* | *NULL* | *NULL* |
| 175 | 2026-09-30 20:47:00 | 37.0 | 77.0 | 97.0 | 122.0 | 83.0 |

#### 5.6 Lần đo gần nhất của mỗi người (truy vấn con tương quan)

```sql
SELECT nd.HoTen, ld.MaLanDo, ld.ThoiGianDo
FROM NGUOI_DUNG AS nd
JOIN LAN_DO     AS ld ON ld.MaNguoiDung = nd.MaNguoiDung
WHERE ld.ThoiGianDo = (
    SELECT MAX(ld2.ThoiGianDo)
    FROM LAN_DO AS ld2
    WHERE ld2.MaNguoiDung = nd.MaNguoiDung
)
ORDER BY ld.ThoiGianDo DESC;
```

**Kết quả:**

| HoTen | MaLanDo | ThoiGianDo |
|---|---|---|
| Nguyễn Văn An | 265 | 2026-10-10 21:22:00 |
| Ngô Thị Mai | 264 | 2026-10-10 19:51:00 |
| Bùi Thị Lan | 263 | 2026-10-10 19:42:00 |
| Phạm Thị Dung | 262 | 2026-10-10 18:35:00 |
| Đặng Quốc Huy | 261 | 2026-10-10 18:21:00 |
| Lê Hoàng Cường | 258 | 2026-10-10 15:55:00 |
| Trần Thị Bích | 255 | 2026-10-10 07:11:00 |
| Dương Văn Nam | 254 | 2026-10-10 06:57:00 |
| Lý Thị Oanh | 253 | 2026-10-10 06:54:00 |
| Vũ Thị Giang | 246 | 2026-10-09 07:05:00 |
| Đỗ Thanh Long | 235 | 2026-10-07 18:11:00 |
| Hoàng Minh Đức | 223 | 2026-10-06 09:14:00 |

#### 5.7 Số lần đo theo từng ngày trong 7 ngày cuối của dữ liệu mẫu

```sql
SELECT CAST(ThoiGianDo AS DATE) AS Ngay, COUNT(*) AS SoLanDo
FROM LAN_DO
WHERE ThoiGianDo >= '2026-10-04' AND ThoiGianDo < '2026-10-11'
GROUP BY CAST(ThoiGianDo AS DATE)
ORDER BY Ngay;
```

**Kết quả:**

| Ngay | SoLanDo |
|---|---|
| 2026-10-04 | 8 |
| 2026-10-05 | 5 |
| 2026-10-06 | 13 |
| 2026-10-07 | 8 |
| 2026-10-08 | 7 |
| 2026-10-09 | 6 |
| 2026-10-10 | 15 |

#### 5.8 Số lần đo theo buổi trong ngày

```sql
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
```

**Kết quả:**

| Buoi | SoLanDo |
|---|---|
| 1. Sáng | 159 |
| 2. Chiều | 2 |
| 3. Tối | 104 |

#### 5.9 Người chưa đo lần nào trong 3 ngày cuối của dữ liệu mẫu

```sql
SELECT nd.MaNguoiDung, nd.HoTen
FROM NGUOI_DUNG AS nd
WHERE NOT EXISTS (
    SELECT 1
    FROM LAN_DO AS ld
    WHERE ld.MaNguoiDung = nd.MaNguoiDung
      AND ld.ThoiGianDo >= '2026-10-08'
)
ORDER BY nd.HoTen;
```

**Kết quả:**

| MaNguoiDung | HoTen |
|---|---|
| 9 | Đỗ Thanh Long |
| 5 | Hoàng Minh Đức |

## 5. Tương ứng trong ứng dụng

| Chức năng trên ứng dụng | Câu lệnh tương ứng |
|---|---|
| Tab "Lịch sử", chip "Mọi người" / chọn một người | Mục 5.1 |
| Chip "Hôm nay" | Mục 5.2 |
| Chip "Tháng này" | Mục 5.3 |
| Chip "7 ngày" và "Tùy chọn" | Mục 5.4 |
| Thẻ lần đo với bốn ô chỉ số | Mục 5.5 |
| Dòng "Đo gần nhất …" trong danh sách hồ sơ | Mục 5.6 |
| Biểu đồ "Số lần đo theo ngày" | Mục 5.7 |
| Form "Thêm lần đo" | Mục 2.1 và 2.2 |
| Nút xóa ở "Chi tiết lần đo" | Mục 4 |
