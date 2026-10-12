# Phần 7 — Quản lý chỉ số sức khỏe

**Người phụ trách:** Người 7 · **Bảng:** `LOAI_CHI_SO`, `CHI_TIET_LAN_DO` · **Script:** [`sql/sqlserver/06_chi_so.sql`](../sql/sqlserver/06_chi_so.sql)

## 1. Mục đích

Hệ thống theo dõi năm chỉ số: nhiệt độ, nhịp tim, SpO2, huyết áp tâm thu và huyết áp tâm trương. Hai bảng của phần này trả lời hai câu hỏi:

- `LOAI_CHI_SO` — hệ thống theo dõi **những chỉ số nào**, đơn vị gì, ngưỡng đánh giá ra sao;
- `CHI_TIET_LAN_DO` — trong **mỗi lần đo**, từng chỉ số có **giá trị bao nhiêu**.

## 2. Cấu trúc bảng

### 2.1 LOAI_CHI_SO

| Cột | Kiểu dữ liệu | Bắt buộc | Mặc định | Ý nghĩa |
|---|---|:---:|---|---|
| `MaLoaiChiSo` | INT IDENTITY | ✓ |  | Khóa chính, tự tăng |
| `KyHieu` | VARCHAR(20) | ✓ |  | Mã ngắn dùng trong chương trình |
| `TenChiSo` | NVARCHAR(50) | ✓ |  | Tên chỉ số |
| `DonViDo` | NVARCHAR(10) | ✓ |  | Đơn vị đo |
| `SoThapPhan` | TINYINT | ✓ | `0` | Số chữ số thập phân khi hiển thị (0 hoặc 1) |
| `GiaTriMin` | DECIMAL(6,1) | ✓ |  | Cận dưới của khoảng hợp lệ |
| `GiaTriMax` | DECIMAL(6,1) | ✓ |  | Cận trên của khoảng hợp lệ |
| `BinhThuongMin` | DECIMAL(6,1) | ✓ |  | Cận dưới của khoảng bình thường |
| `BinhThuongMax` | DECIMAL(6,1) | ✓ |  | Cận trên của khoảng bình thường |
| `CanhBaoMin` | DECIMAL(6,1) | ✓ |  | Dưới mức này là nguy hiểm |
| `CanhBaoMax` | DECIMAL(6,1) | ✓ |  | Trên mức này là nguy hiểm |

| Ràng buộc | Loại | Cột | Ý nghĩa |
|---|---|---|---|
| `PK_LOAI_CHI_SO` | Khóa chính | MaLoaiChiSo | Mỗi loại chỉ số một mã duy nhất |
| `UQ_LOAI_CHI_SO_KyHieu` | Duy nhất | KyHieu | Ký hiệu không trùng |
| `UQ_LOAI_CHI_SO_TenChiSo` | Duy nhất | TenChiSo | Tên chỉ số không trùng |
| `CK_LOAI_CHI_SO_SoThapPhan` | CHECK | SoThapPhan | Chỉ nhận 0 hoặc 1 |
| `CK_LOAI_CHI_SO_ThuTuNguong` | CHECK | (nhiều cột) | Ba khoảng ngưỡng phải lồng nhau đúng thứ tự |

Ba khoảng ngưỡng lồng nhau quyết định mức độ của một giá trị đo:

| Giá trị nằm trong | Mức độ |
|---|---|
| `[BinhThuongMin, BinhThuongMax]` | Bình thường |
| `[CanhBaoMin, CanhBaoMax]` nhưng ngoài khoảng bình thường | Cần chú ý |
| ngoài `[CanhBaoMin, CanhBaoMax]` nhưng trong `[GiaTriMin, GiaTriMax]` | Nguy hiểm |
| ngoài `[GiaTriMin, GiaTriMax]` | Không hợp lệ, bị từ chối |

Ràng buộc `CK_LOAI_CHI_SO_ThuTuNguong` bảo đảm ba khoảng luôn lồng nhau đúng thứ tự, nên không thể nhập một bộ ngưỡng vô nghĩa.

### 2.2 CHI_TIET_LAN_DO

| Cột | Kiểu dữ liệu | Bắt buộc | Mặc định | Ý nghĩa |
|---|---|:---:|---|---|
| `MaLanDo` | INT | ✓ |  | Lần đo chứa giá trị này |
| `MaLoaiChiSo` | INT | ✓ |  | Chỉ số được đo |
| `GiaTri` | DECIMAL(6,1) | ✓ |  | Giá trị đo được |

| Ràng buộc | Loại | Cột | Ý nghĩa |
|---|---|---|---|
| `PK_CHI_TIET_LAN_DO` | Khóa chính | MaLanDo, MaLoaiChiSo | Mỗi chỉ số chỉ xuất hiện một lần trong một lần đo |
| `FK_CHI_TIET_LAN_DO_LAN_DO` | Khóa ngoại → LAN_DO (xóa dây chuyền) | MaLanDo | Giá trị phải thuộc một lần đo có thật; xóa lần đo thì xóa giá trị |
| `FK_CHI_TIET_LAN_DO_LOAI_CHI_SO` | Khóa ngoại → LOAI_CHI_SO | MaLoaiChiSo | Chỉ số phải có trong danh mục; không xóa được loại đang dùng |
| `IX_CHI_TIET_LAN_DO_MaLoaiChiSo` | Chỉ mục | MaLoaiChiSo | Tăng tốc thống kê theo chỉ số |

Một số quyết định thiết kế:

- **Mỗi chỉ số một dòng, không phải mỗi chỉ số một cột.** Nếu `LAN_DO` có sẵn năm cột `NhietDo`, `NhipTim`…, thì lần đo bằng máy SpO2 (chỉ có hai chỉ số) phải để trống ba cột, và muốn theo dõi thêm chỉ số mới (ví dụ đường huyết) phải sửa cấu trúc bảng. Với thiết kế hiện tại, thêm chỉ số mới chỉ cần thêm một dòng vào `LOAI_CHI_SO` (mục 1.2).
- **Khóa chính kép `(MaLanDo, MaLoaiChiSo)`.** Một chỉ số không thể xuất hiện hai lần trong cùng một lần đo.
- **Kiểm tra khoảng hợp lệ bằng trigger.** `CHECK` chỉ nhìn được các cột của chính dòng đang ghi, trong khi khoảng hợp lệ nằm ở bảng `LOAI_CHI_SO`; vì vậy việc kiểm tra do trigger `TRG_CHI_TIET_LAN_DO_CanhBao` đảm nhận (xem Phần 10).
- **Đơn vị đo không lặp lại ở từng giá trị.** Đơn vị phụ thuộc vào loại chỉ số chứ không phụ thuộc vào từng lần đo, nên chỉ lưu một lần ở `LOAI_CHI_SO`.

## 3. Dữ liệu mẫu

Năm loại chỉ số và ngưỡng của chúng:

| MaLoaiChiSo | KyHieu | TenChiSo | DonViDo | GiaTriMin | GiaTriMax | BinhThuongMin | BinhThuongMax | CanhBaoMin | CanhBaoMax |
|---|---|---|---|---|---|---|---|---|---|
| 1 | NHIET_DO | Nhiệt độ | °C | 30.0 | 45.0 | 36.100000000000001 | 37.5 | 35.0 | 38.5 |
| 2 | NHIP_TIM | Nhịp tim | bpm | 20.0 | 250.0 | 60.0 | 100.0 | 50.0 | 120.0 |
| 3 | SPO2 | SpO2 | % | 50.0 | 100.0 | 95.0 | 100.0 | 90.0 | 100.0 |
| 4 | HA_TAM_THU | Huyết áp tâm thu | mmHg | 50.0 | 260.0 | 90.0 | 129.0 | 85.0 | 139.0 |
| 5 | HA_TAM_TRUONG | Huyết áp tâm trương | mmHg | 30.0 | 160.0 | 60.0 | 84.0 | 55.0 | 89.0 |

Các ngưỡng trên là giá trị tham khảo phục vụ đồ án, không phải khuyến nghị y khoa.

`CHI_TIET_LAN_DO` có 1110 giá trị thuộc 265 lần đo. Không phải lần đo nào cũng đủ năm chỉ số, vì mỗi loại thiết bị chỉ đo được một số chỉ số:

| SoChiSoTrongLanDo | SoLanDo |
|---|---|
| 1 | 23 |
| 2 | 31 |
| 3 | 15 |
| 5 | 196 |

## 4. Câu lệnh và kết quả

Các kết quả dưới đây được lấy bằng cách chạy script trên SQL Server 2022 với dữ liệu mẫu. Mọi lệnh thêm, sửa, xóa minh họa đều nằm trong giao dịch rồi `ROLLBACK`. Vì `IDENTITY` không lùi lại khi `ROLLBACK`, mã của các dòng minh họa có thể không liền sau mã của dữ liệu mẫu.

### 1. LOAI_CHI_SO

#### 1.1 Danh mục chỉ số: tên, đơn vị và các khoảng đánh giá

```sql
SELECT MaLoaiChiSo, KyHieu, TenChiSo, DonViDo,
       BinhThuongMin, BinhThuongMax, CanhBaoMin, CanhBaoMax
FROM LOAI_CHI_SO
ORDER BY MaLoaiChiSo;
```

**Kết quả:**

| MaLoaiChiSo | KyHieu | TenChiSo | DonViDo | BinhThuongMin | BinhThuongMax | CanhBaoMin | CanhBaoMax |
|---|---|---|---|---|---|---|---|
| 1 | NHIET_DO | Nhiệt độ | °C | 36.1 | 37.5 | 35.0 | 38.5 |
| 2 | NHIP_TIM | Nhịp tim | bpm | 60.0 | 100.0 | 50.0 | 120.0 |
| 3 | SPO2 | SpO2 | % | 95.0 | 100.0 | 90.0 | 100.0 |
| 4 | HA_TAM_THU | Huyết áp tâm thu | mmHg | 90.0 | 129.0 | 85.0 | 139.0 |
| 5 | HA_TAM_TRUONG | Huyết áp tâm trương | mmHg | 60.0 | 84.0 | 55.0 | 89.0 |

#### 1.2 Thêm một loại chỉ số mới (ví dụ đường huyết)

```sql
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
```

**Kết quả:**

| MaLoaiChiSo | KyHieu | TenChiSo | DonViDo |
|---|---|---|---|
| 1 | NHIET_DO | Nhiệt độ | °C |
| 2 | NHIP_TIM | Nhịp tim | bpm |
| 3 | SPO2 | SpO2 | % |
| 4 | HA_TAM_THU | Huyết áp tâm thu | mmHg |
| 5 | HA_TAM_TRUONG | Huyết áp tâm trương | mmHg |
| 10 | DUONG_HUYET | Đường huyết | mmol/L |

#### 1.3 Sửa đơn vị đo và nới khoảng bình thường của một chỉ số

```sql
BEGIN TRANSACTION;

    UPDATE LOAI_CHI_SO
    SET BinhThuongMax = 37.2
    WHERE KyHieu = 'NHIET_DO';

    SELECT TenChiSo, BinhThuongMin, BinhThuongMax
    FROM LOAI_CHI_SO
    WHERE KyHieu = 'NHIET_DO';

ROLLBACK TRANSACTION;
```

**Kết quả:**

| TenChiSo | BinhThuongMin | BinhThuongMax |
|---|---|---|
| Nhiệt độ | 36.1 | 37.2 |

#### 1.4 Xóa một loại chỉ số chưa được dùng. (Loại đã có giá trị đo thì không

xóa được vì bị khóa ngoại FK_CHI_TIET_LAN_DO_LOAI_CHI_SO chặn.)

```sql
BEGIN TRANSACTION;

    INSERT INTO LOAI_CHI_SO (KyHieu, TenChiSo, DonViDo, GiaTriMin, GiaTriMax,
                             BinhThuongMin, BinhThuongMax, CanhBaoMin, CanhBaoMax)
    VALUES ('NHIP_THO', N'Nhịp thở', N'lần/phút', 5, 60, 12, 20, 10, 24);

    DELETE FROM LOAI_CHI_SO
    WHERE KyHieu = 'NHIP_THO';

    SELECT COUNT(*) AS SoLoaiChiSo FROM LOAI_CHI_SO;

ROLLBACK TRANSACTION;
```

**Kết quả:**

| SoLoaiChiSo |
|---|
| 5 |

### 2. CHI_TIET_LAN_DO

#### 2.1 Các chỉ số của một lần đo, kèm tên và đơn vị

```sql
SELECT ct.MaLanDo, l.TenChiSo, ct.GiaTri, l.DonViDo
FROM CHI_TIET_LAN_DO AS ct
JOIN LOAI_CHI_SO     AS l ON l.MaLoaiChiSo = ct.MaLoaiChiSo
WHERE ct.MaLanDo = 260
ORDER BY ct.MaLoaiChiSo;
```

**Kết quả:**

| MaLanDo | TenChiSo | GiaTri | DonViDo |
|---|---|---|---|
| 260 | Nhiệt độ | 36.9 | °C |
| 260 | Nhịp tim | 126.0 | bpm |
| 260 | SpO2 | 95.0 | % |
| 260 | Huyết áp tâm thu | 148.0 | mmHg |
| 260 | Huyết áp tâm trương | 92.0 | mmHg |

#### 2.2 Đánh giá từng giá trị của một lần đo theo ngưỡng của chỉ số

```sql
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
```

**Kết quả:**

| TenChiSo | GiaTri | DonViDo | KhoangBinhThuong | MucDo |
|---|---|---|---|---|
| Nhiệt độ | 36.9 | °C | 36.1 – 37.5 | Bình thường |
| Nhịp tim | 126.0 | bpm | 60 – 100 | Nguy hiểm |
| SpO2 | 95.0 | % | 95 – 100 | Bình thường |
| Huyết áp tâm thu | 148.0 | mmHg | 90 – 129 | Nguy hiểm |
| Huyết áp tâm trương | 92.0 | mmHg | 60 – 84 | Nguy hiểm |

#### 2.3 Thêm chỉ số cho một lần đo. Lần đo 261 (máy đo SpO2) chỉ có nhịp tim và

SpO2; bổ sung nhiệt độ đo tay.

```sql
BEGIN TRANSACTION;

    INSERT INTO CHI_TIET_LAN_DO (MaLanDo, MaLoaiChiSo, GiaTri)
    VALUES (261, 1, 36.8);

    SELECT ct.MaLanDo, l.TenChiSo, ct.GiaTri, l.DonViDo
    FROM CHI_TIET_LAN_DO AS ct
    JOIN LOAI_CHI_SO     AS l ON l.MaLoaiChiSo = ct.MaLoaiChiSo
    WHERE ct.MaLanDo = 261
    ORDER BY ct.MaLoaiChiSo;

ROLLBACK TRANSACTION;
```

**Kết quả:**

| MaLanDo | TenChiSo | GiaTri | DonViDo |
|---|---|---|---|
| 261 | Nhiệt độ | 36.8 | °C |
| 261 | Nhịp tim | 96.0 | bpm |
| 261 | SpO2 | 95.0 | % |

#### 2.4 Sửa một giá trị đo bị nhập nhầm

```sql
BEGIN TRANSACTION;

    UPDATE CHI_TIET_LAN_DO
    SET GiaTri = 96
    WHERE MaLanDo = 261 AND MaLoaiChiSo = 3;

    SELECT MaLanDo, MaLoaiChiSo, GiaTri
    FROM CHI_TIET_LAN_DO
    WHERE MaLanDo = 261;

ROLLBACK TRANSACTION;
```

**Kết quả:**

| MaLanDo | MaLoaiChiSo | GiaTri |
|---|---|---|
| 261 | 2 | 96.0 |
| 261 | 3 | 96.0 |

#### 2.5 Xóa một chỉ số khỏi lần đo

```sql
BEGIN TRANSACTION;

    DELETE FROM CHI_TIET_LAN_DO
    WHERE MaLanDo = 260 AND MaLoaiChiSo = 1;

    SELECT COUNT(*) AS SoChiSoConLai
    FROM CHI_TIET_LAN_DO
    WHERE MaLanDo = 260;

ROLLBACK TRANSACTION;
```

**Kết quả:**

| SoChiSoConLai |
|---|
| 4 |

### 3. TRUY VẤN GIÁ TRỊ ĐO

#### 3.1 Số giá trị đã ghi nhận của từng chỉ số

```sql
SELECT l.TenChiSo, l.DonViDo, COUNT(ct.MaLanDo) AS SoGiaTri
FROM LOAI_CHI_SO          AS l
LEFT JOIN CHI_TIET_LAN_DO AS ct ON ct.MaLoaiChiSo = l.MaLoaiChiSo
GROUP BY l.MaLoaiChiSo, l.TenChiSo, l.DonViDo
ORDER BY l.MaLoaiChiSo;
```

**Kết quả:**

| TenChiSo | DonViDo | SoGiaTri |
|---|---|---|
| Nhiệt độ | °C | 219 |
| Nhịp tim | bpm | 242 |
| SpO2 | % | 227 |
| Huyết áp tâm thu | mmHg | 211 |
| Huyết áp tâm trương | mmHg | 211 |

#### 3.2 Giá trị nhỏ nhất, lớn nhất, trung bình của từng chỉ số

```sql
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
```

**Kết quả:**

| TenChiSo | DonViDo | NhoNhat | LonNhat | TrungBinh |
|---|---|---|---|---|
| Nhiệt độ | °C | 36.2 | 38.9 | 36.7 |
| Nhịp tim | bpm | 53.0 | 126.0 | 80.5 |
| SpO2 | % | 92.0 | 100.0 | 97.1 |
| Huyết áp tâm thu | mmHg | 84.0 | 148.0 | 120.4 |
| Huyết áp tâm trương | mmHg | 59.0 | 92.0 | 76.7 |

#### 3.3 Các giá trị nhịp tim nằm ngoài khoảng bình thường

```sql
SELECT TOP (10) ct.MaLanDo, ct.GiaTri, l.BinhThuongMin, l.BinhThuongMax
FROM CHI_TIET_LAN_DO AS ct
JOIN LOAI_CHI_SO     AS l ON l.MaLoaiChiSo = ct.MaLoaiChiSo
WHERE l.KyHieu = 'NHIP_TIM'
  AND (ct.GiaTri < l.BinhThuongMin OR ct.GiaTri > l.BinhThuongMax)
ORDER BY ct.GiaTri DESC;
```

**Kết quả:**

| MaLanDo | GiaTri | BinhThuongMin | BinhThuongMax |
|---|---|---|---|
| 260 | 126.0 | 60.0 | 100.0 |
| 77 | 124.0 | 60.0 | 100.0 |
| 235 | 117.0 | 60.0 | 100.0 |
| 230 | 112.0 | 60.0 | 100.0 |
| 206 | 111.0 | 60.0 | 100.0 |
| 135 | 110.0 | 60.0 | 100.0 |
| 228 | 109.0 | 60.0 | 100.0 |
| 92 | 108.0 | 60.0 | 100.0 |
| 20 | 106.0 | 60.0 | 100.0 |
| 139 | 102.0 | 60.0 | 100.0 |

#### 3.4 Giá trị mới nhất của từng chỉ số đối với một người

ROW_NUMBER() đánh số các giá trị của mỗi chỉ số từ mới tới cũ; dòng số 1 là giá trị mới nhất.

```sql
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
```

**Kết quả:**

| TenChiSo | GiaTri | DonViDo | ThoiGianDo |
|---|---|---|---|
| Nhiệt độ | 37.1 | °C | 2026-10-10 18:35:00 |
| Nhịp tim | 76.0 | bpm | 2026-10-10 18:35:00 |
| SpO2 | 96.0 | % | 2026-10-10 18:35:00 |
| Huyết áp tâm thu | 131.0 | mmHg | 2026-10-10 18:35:00 |
| Huyết áp tâm trương | 80.0 | mmHg | 2026-10-10 18:35:00 |

#### 3.5 Tỷ lệ giá trị theo mức độ của từng chỉ số

```sql
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
```

**Kết quả:**

| TenChiSo | BinhThuong | CanChuY | NguyHiem |
|---|---|---|---|
| Nhiệt độ | 215 | 3 | 1 |
| Nhịp tim | 223 | 17 | 2 |
| SpO2 | 218 | 9 | 0 |
| Huyết áp tâm thu | 165 | 35 | 11 |
| Huyết áp tâm trương | 181 | 28 | 2 |

## 5. Tương ứng trong ứng dụng

| Chức năng trên ứng dụng | Câu lệnh tương ứng |
|---|---|
| Màn hình "Chi tiết lần đo": từng chỉ số, khoảng bình thường, mức độ | Mục 2.1 và 2.2 |
| Lưới "Chỉ số mới nhất" trong chi tiết hồ sơ | Mục 3.4 |
| Form "Thêm lần đo": nhãn "BT: 60 – 100 bpm" và đánh giá tức thời | Mục 1.1 |
| Bảng "Thống kê theo chỉ số" | Mục 3.2 |
