# Phần 9 — Quản lý thiết bị và nguồn dữ liệu

**Người phụ trách:** Người 9 · **Bảng:** `THIET_BI` · **Script:** [`sql/sqlserver/08_thiet_bi.sql`](../sql/sqlserver/08_thiet_bi.sql)

## 1. Mục đích

`THIET_BI` lưu các thiết bị đo: mã, tên, loại, mã định danh phần cứng và trạng thái. Nhờ bảng này, mỗi lần đo biết được dữ liệu của nó đến từ đâu.

> **Phạm vi:** đề tài không lắp mạch, không đọc cảm biến và không truyền dữ liệu IoT. Các thiết bị như ESP32 Health Monitor, cảm biến MAX30102 hay MLX90614 chỉ là **dữ liệu mô phỏng** trong cơ sở dữ liệu.

Một lần đo có một trong hai nguồn dữ liệu:

| Nguồn | `LAN_DO.NguonDuLieu` | `LAN_DO.MaThietBi` |
|---|---|---|
| Thiết bị đo | `Thiết bị` | mã của một thiết bị |
| Nhập thủ công | `Thủ công` | `NULL` |

## 2. Cấu trúc bảng

| Cột | Kiểu dữ liệu | Bắt buộc | Mặc định | Ý nghĩa |
|---|---|:---:|---|---|
| `MaThietBi` | INT IDENTITY | ✓ |  | Khóa chính, tự tăng |
| `TenThietBi` | NVARCHAR(100) | ✓ |  | Tên thiết bị |
| `LoaiThietBi` | NVARCHAR(50) | ✓ |  | Loại thiết bị |
| `MaDinhDanh` | VARCHAR(50) | ✓ |  | Địa chỉ MAC hoặc số serial |
| `TrangThai` | NVARCHAR(20) | ✓ | `N'Hoạt động'` | Hoạt động, Bảo trì hoặc Ngừng sử dụng |
| `MoTa` | NVARCHAR(300) |  |  | Ghi chú về thiết bị |

| Ràng buộc | Loại | Cột | Ý nghĩa |
|---|---|---|---|
| `PK_THIET_BI` | Khóa chính | MaThietBi | Mỗi thiết bị một mã duy nhất |
| `UQ_THIET_BI_MaDinhDanh` | Duy nhất | MaDinhDanh | Không có hai thiết bị trùng mã định danh |
| `CK_THIET_BI_LoaiThietBi` | CHECK | LoaiThietBi | Một trong 4 loại thiết bị |
| `CK_THIET_BI_TrangThai` | CHECK | TrangThai | Một trong 3 trạng thái |

Một số quyết định thiết kế:

- **Mã định danh là duy nhất.** `MaDinhDanh` (địa chỉ MAC hoặc số serial) là thứ phân biệt hai thiết bị cùng tên, cùng loại ngoài đời thực.
- **Khóa chính vẫn là số tự tăng.** Dù `MaDinhDanh` duy nhất, nó dài và có thể phải sửa (nhập sai, thay mô-đun); khóa thay thế `MaThietBi` ngắn gọn và ổn định hơn để làm khóa ngoại.
- **Ngừng dùng bằng trạng thái, không bằng xóa.** Thiết bị đã có lần đo thì không xóa được (mục 4.2); khi không còn dùng, chuyển `TrangThai` sang "Ngừng sử dụng" để lịch sử đo vẫn giữ nguyên nguồn gốc.

## 3. Dữ liệu mẫu

Sáu thiết bị mô phỏng, đủ ba trạng thái và bốn loại; thiết bị số 6 chưa từng được dùng để có trường hợp "thiết bị chưa có lần đo".

| MaThietBi | TenThietBi | LoaiThietBi | MaDinhDanh | TrangThai | MoTa |
|---|---|---|---|---|---|
| 1 | ESP32 Health Monitor | Thiết bị đa chỉ số | ESP32-A4:CF:12:9B:7E:01 | Hoạt động | Trạm đo đa chỉ số: nhiệt độ, nhịp tim, SpO2 và huyết áp. |
| 2 | Máy đo SpO2 kẹp ngón | Máy đo SpO2 | MAX30102-0007 | Hoạt động | Cảm biến MAX30102 đo SpO2 và nhịp tim. |
| 3 | Nhiệt kế hồng ngoại | Nhiệt kế | MLX90614-0012 | Hoạt động | Cảm biến MLX90614 đo nhiệt độ không tiếp xúc. |
| 4 | Máy đo huyết áp điện tử | Máy đo huyết áp | BP-HA01-2231 | Bảo trì | Đang hiệu chuẩn lại, tạm ngừng nhận dữ liệu. |
| 5 | ESP32 Health Monitor (cũ) | Thiết bị đa chỉ số | ESP32-A4:CF:12:3C:20:FE | Ngừng sử dụng | Bản thử nghiệm đầu tiên, đã thay bằng thiết bị số 1. |
| 6 | Máy đo SpO2 dự phòng | Máy đo SpO2 | MAX30102-0019 | Hoạt động | Thiết bị dự phòng, chưa đưa vào sử dụng. |

Mỗi loại thiết bị chỉ đo một số chỉ số, nên các lần đo của nó có số dòng `CHI_TIET_LAN_DO` khác nhau:

| Thiết bị | Chỉ số đo được |
|---|---|
| ESP32 Health Monitor (số 1 và số 5) | cả 5 chỉ số |
| Máy đo SpO2 kẹp ngón | nhịp tim, SpO2 |
| Nhiệt kế hồng ngoại | nhiệt độ |
| Máy đo huyết áp điện tử | nhịp tim, huyết áp tâm thu, huyết áp tâm trương |

## 4. Câu lệnh và kết quả

Các kết quả dưới đây được lấy bằng cách chạy script trên SQL Server 2022 với dữ liệu mẫu. Mọi lệnh thêm, sửa, xóa minh họa đều nằm trong giao dịch rồi `ROLLBACK`. Vì `IDENTITY` không lùi lại khi `ROLLBACK`, mã của các dòng minh họa có thể không liền sau mã của dữ liệu mẫu.

### 1. XEM (SELECT)

#### 1.1 Toàn bộ thiết bị

```sql
SELECT MaThietBi, TenThietBi, LoaiThietBi, MaDinhDanh, TrangThai
FROM THIET_BI
ORDER BY MaThietBi;
```

**Kết quả:**

| MaThietBi | TenThietBi | LoaiThietBi | MaDinhDanh | TrangThai |
|---|---|---|---|---|
| 1 | ESP32 Health Monitor | Thiết bị đa chỉ số | ESP32-A4:CF:12:9B:7E:01 | Hoạt động |
| 2 | Máy đo SpO2 kẹp ngón | Máy đo SpO2 | MAX30102-0007 | Hoạt động |
| 3 | Nhiệt kế hồng ngoại | Nhiệt kế | MLX90614-0012 | Hoạt động |
| 4 | Máy đo huyết áp điện tử | Máy đo huyết áp | BP-HA01-2231 | Bảo trì |
| 5 | ESP32 Health Monitor (cũ) | Thiết bị đa chỉ số | ESP32-A4:CF:12:3C:20:FE | Ngừng sử dụng |
| 6 | Máy đo SpO2 dự phòng | Máy đo SpO2 | MAX30102-0019 | Hoạt động |

#### 1.2 Một thiết bị theo khóa chính

```sql
SELECT MaThietBi, TenThietBi, LoaiThietBi, MaDinhDanh, TrangThai, MoTa
FROM THIET_BI
WHERE MaThietBi = 1;
```

**Kết quả:**

| MaThietBi | TenThietBi | LoaiThietBi | MaDinhDanh | TrangThai | MoTa |
|---|---|---|---|---|---|
| 1 | ESP32 Health Monitor | Thiết bị đa chỉ số | ESP32-A4:CF:12:9B:7E:01 | Hoạt động | Trạm đo đa chỉ số: nhiệt độ, nhịp tim, SpO2 và huyết áp. |

### 2. THÊM (INSERT)

Thêm một thiết bị mô phỏng; TrangThai lấy mặc định "Hoạt động"

```sql
BEGIN TRANSACTION;

    INSERT INTO THIET_BI (TenThietBi, LoaiThietBi, MaDinhDanh, MoTa)
    VALUES (N'ESP32 Health Monitor (phòng 2)', N'Thiết bị đa chỉ số',
            'ESP32-A4:CF:12:AA:01:9C', N'Trạm đo thứ hai, đặt tại phòng 2.');

    SELECT MaThietBi, TenThietBi, MaDinhDanh, TrangThai
    FROM THIET_BI
    WHERE MaThietBi = SCOPE_IDENTITY();

ROLLBACK TRANSACTION;
```

**Kết quả:**

| MaThietBi | TenThietBi | MaDinhDanh | TrangThai |
|---|---|---|---|
| 10 | ESP32 Health Monitor (phòng 2) | ESP32-A4:CF:12:AA:01:9C | Hoạt động |

### 3. SỬA (UPDATE)

#### 3.1 Đưa một thiết bị vào bảo trì

```sql
BEGIN TRANSACTION;

    UPDATE THIET_BI
    SET TrangThai = N'Bảo trì',
        MoTa      = N'Thay cảm biến, dự kiến hoạt động lại sau 3 ngày.'
    WHERE MaThietBi = 3;

    SELECT MaThietBi, TenThietBi, TrangThai, MoTa
    FROM THIET_BI
    WHERE MaThietBi = 3;

ROLLBACK TRANSACTION;
```

**Kết quả:**

| MaThietBi | TenThietBi | TrangThai | MoTa |
|---|---|---|---|
| 3 | Nhiệt kế hồng ngoại | Bảo trì | Thay cảm biến, dự kiến hoạt động lại sau 3 ngày. |

#### 3.2 Thiết bị bảo trì xong, hoạt động trở lại

```sql
BEGIN TRANSACTION;

    UPDATE THIET_BI
    SET TrangThai = N'Hoạt động'
    WHERE TrangThai = N'Bảo trì';

    SELECT @@ROWCOUNT AS SoThietBiHoatDongLai;

ROLLBACK TRANSACTION;
```

**Kết quả:**

| SoThietBiHoatDongLai |
|---|
| 1 |

### 4. XÓA (DELETE)

#### 4.1 Xóa được thiết bị chưa có lần đo nào (thiết bị số 6)

```sql
BEGIN TRANSACTION;

    DELETE FROM THIET_BI
    WHERE MaThietBi = 6;

    SELECT COUNT(*) AS SoThietBiConLai FROM THIET_BI;

ROLLBACK TRANSACTION;
```

**Kết quả:**

| SoThietBiConLai |
|---|
| 5 |

#### 4.2 KHÔNG xóa được thiết bị đã có lần đo: khóa ngoại FK_LAN_DO_THIET_BI chặn

lại để lịch sử đo không mất nguồn gốc. Muốn ngừng dùng thì đổi trạng thái.

```sql
BEGIN TRY
    DELETE FROM THIET_BI
    WHERE MaThietBi = 1;
END TRY
BEGIN CATCH
    SELECT ERROR_NUMBER() AS MaLoi, N'Không xóa được: thiết bị đã có lần đo.' AS ThongBao;
END CATCH;
```

**Kết quả:**

| MaLoi | ThongBao |
|---|---|
| 547 | Không xóa được: thiết bị đã có lần đo. |

### 5. TÌM KIẾM VÀ LỌC

#### 5.1 Tìm theo tên hoặc mã định danh

```sql
SELECT MaThietBi, TenThietBi, MaDinhDanh, TrangThai
FROM THIET_BI
WHERE TenThietBi LIKE N'%ESP32%'
   OR MaDinhDanh LIKE '%ESP32%';
```

**Kết quả:**

| MaThietBi | TenThietBi | MaDinhDanh | TrangThai |
|---|---|---|---|
| 1 | ESP32 Health Monitor | ESP32-A4:CF:12:9B:7E:01 | Hoạt động |
| 5 | ESP32 Health Monitor (cũ) | ESP32-A4:CF:12:3C:20:FE | Ngừng sử dụng |

#### 5.2 Lọc theo trạng thái

```sql
SELECT MaThietBi, TenThietBi, LoaiThietBi
FROM THIET_BI
WHERE TrangThai = N'Hoạt động'
ORDER BY TenThietBi;
```

**Kết quả:**

| MaThietBi | TenThietBi | LoaiThietBi |
|---|---|---|
| 1 | ESP32 Health Monitor | Thiết bị đa chỉ số |
| 6 | Máy đo SpO2 dự phòng | Máy đo SpO2 |
| 2 | Máy đo SpO2 kẹp ngón | Máy đo SpO2 |
| 3 | Nhiệt kế hồng ngoại | Nhiệt kế |

#### 5.3 Lọc theo loại thiết bị

```sql
SELECT MaThietBi, TenThietBi, TrangThai
FROM THIET_BI
WHERE LoaiThietBi = N'Thiết bị đa chỉ số';
```

**Kết quả:**

| MaThietBi | TenThietBi | TrangThai |
|---|---|---|
| 1 | ESP32 Health Monitor | Hoạt động |
| 5 | ESP32 Health Monitor (cũ) | Ngừng sử dụng |

#### 5.4 Số thiết bị theo trạng thái

```sql
SELECT TrangThai, COUNT(*) AS SoThietBi
FROM THIET_BI
GROUP BY TrangThai
ORDER BY SoThietBi DESC;
```

**Kết quả:**

| TrangThai | SoThietBi |
|---|---|
| Hoạt động | 4 |
| Ngừng sử dụng | 1 |
| Bảo trì | 1 |

#### 5.5 Số thiết bị theo loại

```sql
SELECT LoaiThietBi, COUNT(*) AS SoThietBi
FROM THIET_BI
GROUP BY LoaiThietBi
ORDER BY SoThietBi DESC, LoaiThietBi;
```

**Kết quả:**

| LoaiThietBi | SoThietBi |
|---|---|
| Máy đo SpO2 | 2 |
| Thiết bị đa chỉ số | 2 |
| Máy đo huyết áp | 1 |
| Nhiệt kế | 1 |

### 6. THIẾT BỊ VÀ NGUỒN DỮ LIỆU CỦA LẦN ĐO

#### 6.1 Số lần đo và lần đo gần nhất của từng thiết bị

LEFT JOIN để thiết bị chưa đo lần nào vẫn hiện với số lần đo bằng 0.

```sql
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
```

**Kết quả:**

| MaThietBi | TenThietBi | TrangThai | SoLanDo | LanDoGanNhat |
|---|---|---|---|---|
| 1 | ESP32 Health Monitor | Hoạt động | 123 | 2026-10-10 21:22:00 |
| 2 | Máy đo SpO2 kẹp ngón | Hoạt động | 31 | 2026-10-10 18:21:00 |
| 3 | Nhiệt kế hồng ngoại | Hoạt động | 23 | 2026-10-06 19:37:00 |
| 5 | ESP32 Health Monitor (cũ) | Ngừng sử dụng | 18 | 2026-09-19 19:30:00 |
| 4 | Máy đo huyết áp điện tử | Bảo trì | 15 | 2026-09-30 08:10:00 |
| 6 | Máy đo SpO2 dự phòng | Hoạt động | 0 | *NULL* |

#### 6.2 Thiết bị chưa từng được dùng để đo

```sql
SELECT tb.MaThietBi, tb.TenThietBi, tb.TrangThai
FROM THIET_BI AS tb
WHERE NOT EXISTS (SELECT 1 FROM LAN_DO AS ld WHERE ld.MaThietBi = tb.MaThietBi);
```

**Kết quả:**

| MaThietBi | TenThietBi | TrangThai |
|---|---|---|
| 6 | Máy đo SpO2 dự phòng | Hoạt động |

#### 6.3 Tỷ lệ lần đo theo nguồn dữ liệu

```sql
SELECT
    NguonDuLieu,
    COUNT(*) AS SoLanDo,
    CAST(100.0 * COUNT(*) / (SELECT COUNT(*) FROM LAN_DO) AS DECIMAL(5,1)) AS TyLePhanTram
FROM LAN_DO
GROUP BY NguonDuLieu
ORDER BY SoLanDo DESC;
```

**Kết quả:**

| NguonDuLieu | SoLanDo | TyLePhanTram |
|---|---|---|
| Thiết bị | 210 | 79.2 |
| Thủ công | 55 | 20.8 |

#### 6.4 Mỗi thiết bị đo những chỉ số nào

```sql
SELECT tb.TenThietBi, l.TenChiSo, COUNT(*) AS SoGiaTri
FROM THIET_BI        AS tb
JOIN LAN_DO          AS ld ON ld.MaThietBi = tb.MaThietBi
JOIN CHI_TIET_LAN_DO AS ct ON ct.MaLanDo = ld.MaLanDo
JOIN LOAI_CHI_SO     AS l  ON l.MaLoaiChiSo = ct.MaLoaiChiSo
GROUP BY tb.MaThietBi, tb.TenThietBi, l.MaLoaiChiSo, l.TenChiSo
ORDER BY tb.MaThietBi, l.MaLoaiChiSo;
```

**Kết quả:**

| TenThietBi | TenChiSo | SoGiaTri |
|---|---|---|
| ESP32 Health Monitor | Nhiệt độ | 123 |
| ESP32 Health Monitor | Nhịp tim | 123 |
| ESP32 Health Monitor | SpO2 | 123 |
| ESP32 Health Monitor | Huyết áp tâm thu | 123 |
| ESP32 Health Monitor | Huyết áp tâm trương | 123 |
| Máy đo SpO2 kẹp ngón | Nhịp tim | 31 |
| Máy đo SpO2 kẹp ngón | SpO2 | 31 |
| Nhiệt kế hồng ngoại | Nhiệt độ | 23 |
| Máy đo huyết áp điện tử | Nhịp tim | 15 |
| Máy đo huyết áp điện tử | Huyết áp tâm thu | 15 |
| Máy đo huyết áp điện tử | Huyết áp tâm trương | 15 |
| ESP32 Health Monitor (cũ) | Nhiệt độ | 18 |

*… còn 4 dòng nữa (tổng cộng 16 dòng).*

#### 6.5 Thiết bị không ở trạng thái "Hoạt động" nhưng vẫn có lần đo trong

7 ngày cuối của dữ liệu mẫu (cần kiểm tra lại trạng thái)

```sql
SELECT DISTINCT tb.MaThietBi, tb.TenThietBi, tb.TrangThai
FROM THIET_BI AS tb
JOIN LAN_DO   AS ld ON ld.MaThietBi = tb.MaThietBi
WHERE tb.TrangThai <> N'Hoạt động'
  AND ld.ThoiGianDo >= '2026-10-04';
```

**Kết quả:**

*(Truy vấn không trả về dòng nào.)*

## 5. Tương ứng trong ứng dụng

| Chức năng trên ứng dụng | Câu lệnh tương ứng |
|---|---|
| Màn hình "Thiết bị đo": danh sách kèm số lần đo | Mục 6.1 |
| Ô tìm theo tên hoặc mã định danh | Mục 5.1 |
| Chip lọc theo trạng thái | Mục 5.2 |
| Thẻ "Thiết bị" ở Tổng quan (4/6) | Mục 5.4 |
| Form "Thêm lần đo": danh sách thiết bị đang hoạt động | Mục 5.2 |
| Chip lọc "Thiết bị đo" / "Nhập thủ công" ở Lịch sử | Mục 6.3 |
