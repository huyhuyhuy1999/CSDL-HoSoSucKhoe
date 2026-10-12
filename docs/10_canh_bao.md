# Phần 10 — Quản lý cảnh báo

**Người phụ trách:** Người 10 · **Bảng:** `CANH_BAO` · **Script:** [`sql/sqlserver/02_trigger.sql`](../sql/sqlserver/02_trigger.sql), [`sql/sqlserver/09_canh_bao.sql`](../sql/sqlserver/09_canh_bao.sql)

## 1. Mục đích

Khi một giá trị đo nằm ngoài khoảng bình thường, hệ thống phải ghi lại một cảnh báo để người theo dõi biết. Phần này trả lời ba câu hỏi:

1. Cảnh báo được **lưu** như thế nào và gắn với lần đo ra sao?
2. **Quy tắc ngưỡng** nào quyết định có cảnh báo và mức độ của nó?
3. Cảnh báo được **tạo tự động** bằng cách nào?

## 2. Cấu trúc bảng

| Cột | Kiểu dữ liệu | Bắt buộc | Mặc định | Ý nghĩa |
|---|---|:---:|---|---|
| `MaCanhBao` | INT IDENTITY | ✓ |  | Khóa chính, tự tăng |
| `MaLanDo` | INT | ✓ |  | Lần đo phát sinh cảnh báo |
| `MaLoaiChiSo` | INT | ✓ |  | Chỉ số vượt ngưỡng |
| `MucDo` | NVARCHAR(20) | ✓ |  | Cần chú ý hoặc Nguy hiểm |
| `NoiDung` | NVARCHAR(300) | ✓ |  | Câu mô tả cảnh báo |
| `ThoiGianTao` | DATETIME2(0) | ✓ | `SYSDATETIME()` | Thời điểm phát sinh, bằng thời gian đo |
| `DaXem` | BIT | ✓ | `0` | 0 = chưa xem, 1 = đã xem |

| Ràng buộc | Loại | Cột | Ý nghĩa |
|---|---|---|---|
| `PK_CANH_BAO` | Khóa chính | MaCanhBao | Mỗi cảnh báo một mã duy nhất |
| `UQ_CANH_BAO_ChiTiet` | Duy nhất | MaLanDo, MaLoaiChiSo | Mỗi giá trị đo tối đa một cảnh báo |
| `FK_CANH_BAO_CHI_TIET_LAN_DO` | Khóa ngoại → CHI_TIET_LAN_DO (xóa dây chuyền) | MaLanDo, MaLoaiChiSo | Cảnh báo gắn với một giá trị đo có thật; xóa giá trị thì xóa cảnh báo |
| `CK_CANH_BAO_MucDo` | CHECK | MucDo | Chỉ nhận Cần chú ý, Nguy hiểm |
| `IX_CANH_BAO_DaXem` | Chỉ mục | DaXem, ThoiGianTao | Tăng tốc lọc cảnh báo chưa xem |
| `IX_CANH_BAO_ThoiGianTao` | Chỉ mục | ThoiGianTao | Tăng tốc liệt kê cảnh báo mới nhất |

### Cảnh báo gắn với lần đo như thế nào

Cảnh báo không chỉ gắn với lần đo mà gắn với **đúng một giá trị** của lần đo, thông qua khóa ngoại kép `(MaLanDo, MaLoaiChiSo)` trỏ tới `CHI_TIET_LAN_DO`:

```
NGUOI_DUNG ──< LAN_DO ──< CHI_TIET_LAN_DO ──o CANH_BAO
                                │
                          LOAI_CHI_SO
```

Từ một cảnh báo, lần ngược lên được lần đo (thời gian, thiết bị), người được đo và loại chỉ số (tên, đơn vị, ngưỡng) mà không cần lưu lặp bất kỳ thông tin nào trong `CANH_BAO`.

Một số quyết định thiết kế:

- **Mỗi giá trị đo tối đa một cảnh báo.** Ràng buộc `UQ_CANH_BAO_ChiTiet` bảo đảm điều này; quan hệ giữa `CHI_TIET_LAN_DO` và `CANH_BAO` là 1 – 0..1.
- **Chỉ có hai mức độ.** Giá trị bình thường không sinh cảnh báo, nên `MucDo` chỉ nhận "Cần chú ý" hoặc "Nguy hiểm".
- **`ThoiGianTao` bằng thời gian đo.** Cảnh báo phát sinh tại thời điểm đo chứ không phải lúc nhập liệu; nhờ vậy lần đo được nhập bù của hôm qua vẫn cho cảnh báo của hôm qua.
- **`NoiDung` được lưu sẵn.** Câu mô tả ghi lại ngưỡng tại thời điểm phát sinh; nếu sau này ngưỡng được chỉnh, cảnh báo cũ vẫn giải thích đúng vì sao nó được tạo.
- **Xóa dây chuyền.** Xóa giá trị đo, lần đo hoặc người dùng thì cảnh báo liên quan bị xóa theo.

## 3. Quy tắc ngưỡng

Quy tắc không viết cứng trong trigger mà nằm trong bảng `LOAI_CHI_SO` (Phần 7): mỗi chỉ số có ba khoảng lồng nhau. Muốn chỉnh ngưỡng chỉ cần sửa dữ liệu, không phải sửa mã.

| Điều kiện | Kết quả |
|---|---|
| `BinhThuongMin ≤ GiaTri ≤ BinhThuongMax` | Bình thường — không tạo cảnh báo |
| còn lại, nhưng `CanhBaoMin ≤ GiaTri ≤ CanhBaoMax` | Cảnh báo mức **Cần chú ý** |
| `GiaTri < CanhBaoMin` hoặc `GiaTri > CanhBaoMax` | Cảnh báo mức **Nguy hiểm** |
| `GiaTri < GiaTriMin` hoặc `GiaTri > GiaTriMax` | Không hợp lệ — từ chối lưu |

Bảng quy tắc với dữ liệu hiện tại (mục 1 của script):

| TenChiSo | DonViDo | BinhThuong | CanChuY | NguyHiem |
|---|---|---|---|---|
| Nhiệt độ | °C | 36.1 – 37.5 | 35 – 36.1 hoặc 37.5 – 38.5 | < 35 hoặc > 38.5 |
| Nhịp tim | bpm | 60 – 100 | 50 – 60 hoặc 100 – 120 | < 50 hoặc > 120 |
| SpO2 | % | 95 – 100 | 90 – 95 | < 90 |
| Huyết áp tâm thu | mmHg | 90 – 129 | 85 – 90 hoặc 129 – 139 | < 85 hoặc > 139 |
| Huyết áp tâm trương | mmHg | 60 – 84 | 55 – 60 hoặc 84 – 89 | < 55 hoặc > 89 |

Các ngưỡng trên là giá trị tham khảo phục vụ đồ án, không phải khuyến nghị y khoa.

## 4. Trigger tự tạo cảnh báo

Trigger `TRG_CHI_TIET_LAN_DO_CanhBao` chạy sau mỗi lệnh `INSERT` hoặc `UPDATE` trên `CHI_TIET_LAN_DO`. Nhờ trigger, **mọi** đường ghi dữ liệu (ứng dụng, thủ tục, nhập trực tiếp bằng SQL) đều sinh cảnh báo theo cùng một quy tắc; không chương trình nào phải tự viết lệnh chèn vào `CANH_BAO`.

```sql
CREATE OR ALTER TRIGGER TRG_CHI_TIET_LAN_DO_CanhBao
ON CHI_TIET_LAN_DO
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    -- Bước 1: chặn dữ liệu không hợp lệ (ràng buộc liên bảng, CHECK không làm được).
    IF EXISTS (
        SELECT 1
        FROM inserted AS i
        JOIN LOAI_CHI_SO AS l ON l.MaLoaiChiSo = i.MaLoaiChiSo
        WHERE i.GiaTri < l.GiaTriMin OR i.GiaTri > l.GiaTriMax
    )
    BEGIN
        ROLLBACK TRANSACTION;
        THROW 50001, N'Giá trị đo nằm ngoài khoảng hợp lệ của chỉ số.', 1;
    END;

    -- Bước 2: bỏ cảnh báo cũ của những giá trị vừa được ghi lại.
    DELETE cb
    FROM CANH_BAO AS cb
    JOIN inserted AS i
      ON i.MaLanDo = cb.MaLanDo AND i.MaLoaiChiSo = cb.MaLoaiChiSo;

    -- Bước 3: tạo cảnh báo mới cho giá trị ngoài khoảng bình thường.
    INSERT INTO CANH_BAO (MaLanDo, MaLoaiChiSo, MucDo, NoiDung, ThoiGianTao)
    SELECT
        i.MaLanDo,
        i.MaLoaiChiSo,
        CASE
            WHEN i.GiaTri < l.CanhBaoMin OR i.GiaTri > l.CanhBaoMax THEN N'Nguy hiểm'
            ELSE N'Cần chú ý'
        END,
        CONCAT(l.TenChiSo, N' ', /* giá trị, đơn vị, cao hơn / thấp hơn, khoảng bình thường */ ...),
        ld.ThoiGianDo
    FROM inserted AS i
    JOIN LOAI_CHI_SO AS l ON l.MaLoaiChiSo = i.MaLoaiChiSo
    JOIN LAN_DO      AS ld ON ld.MaLanDo = i.MaLanDo
    WHERE i.GiaTri < l.BinhThuongMin OR i.GiaTri > l.BinhThuongMax
    ORDER BY i.MaLanDo, i.MaLoaiChiSo;
END;
```

*(Đoạn ghép câu `NoiDung` được rút gọn ở đây; bản đầy đủ nằm trong `02_trigger.sql`.)*

Những điểm đáng chú ý:

- **Xử lý theo tập hợp.** Bảng ảo `inserted` có thể chứa nhiều dòng (một lệnh `INSERT` nhiều giá trị), nên trigger dùng `JOIN` với `inserted` thay vì giả định chỉ có một dòng.
- **Dùng chung cho `INSERT` và `UPDATE`.** Bước 2 xóa cảnh báo cũ rồi bước 3 đánh giá lại, nên khi sửa một giá trị thì cảnh báo luôn phản ánh giá trị mới: sửa về bình thường thì cảnh báo biến mất, sửa sang bất thường thì cảnh báo xuất hiện.
- **Ràng buộc liên bảng.** Khoảng hợp lệ nằm ở `LOAI_CHI_SO`, ngoài tầm với của `CHECK`, nên bước 1 đảm nhận việc từ chối.
- **Lưu ý về giao dịch.** `ROLLBACK TRANSACTION` trong trigger hủy cả giao dịch của nơi gọi. Vì vậy thủ tục `SP_ThemLanDo` (Phần 11) kiểm tra khoảng hợp lệ trước khi mở giao dịch; đây là lỗi được phát hiện trong quá trình kiểm thử (Phần 12, ca CR-09).
- **Dữ liệu mẫu cũng đi qua trigger.** File `03_du_lieu_mau.sql` không có lệnh `INSERT INTO CANH_BAO` nào: cả 108 cảnh báo mẫu đều do trigger sinh ra khi nạp 1110 giá trị đo. Vì thế `02_trigger.sql` phải chạy trước `03_du_lieu_mau.sql`.

## 5. Dữ liệu mẫu

| MucDo | SoCanhBao | ChuaXem |
|---|---|---|
| Cần chú ý | 92 | 13 |
| Nguy hiểm | 16 | 4 |

Năm cảnh báo mới nhất:

| MaCanhBao | HoTen | MucDo | NoiDung | ThoiGianTao | DaXem |
|---|---|---|---|---|---|
| 108 | Phạm Thị Dung | Cần chú ý | Huyết áp tâm thu 131 mmHg cao hơn khoảng bình thường (90 – 129 mmHg). | 2026-10-10 18:35:00 | 0 |
| 107 | Đặng Quốc Huy | Nguy hiểm | Huyết áp tâm trương 92 mmHg cao hơn khoảng bình thường (60 – 84 mmHg). | 2026-10-10 18:12:00 | 0 |
| 106 | Đặng Quốc Huy | Nguy hiểm | Huyết áp tâm thu 148 mmHg cao hơn khoảng bình thường (90 – 129 mmHg). | 2026-10-10 18:12:00 | 0 |
| 105 | Đặng Quốc Huy | Nguy hiểm | Nhịp tim 126 bpm cao hơn khoảng bình thường (60 – 100 bpm). | 2026-10-10 18:12:00 | 0 |
| 104 | Phạm Thị Dung | Cần chú ý | SpO2 92 % thấp hơn khoảng bình thường (95 – 100 %). | 2026-10-10 17:18:00 | 0 |

## 6. Câu lệnh và kết quả

Các kết quả dưới đây được lấy bằng cách chạy script trên SQL Server 2022 với dữ liệu mẫu. Mọi lệnh thêm, sửa, xóa minh họa đều nằm trong giao dịch rồi `ROLLBACK`. Vì `IDENTITY` không lùi lại khi `ROLLBACK`, mã của các dòng minh họa có thể không liền sau mã của dữ liệu mẫu.

### 1. QUY TẮC NGƯỠNG

Bảng quy tắc: với mỗi chỉ số, giá trị rơi vào khoảng nào thì thuộc mức nào

```sql
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
```

**Kết quả:**

| TenChiSo | DonViDo | BinhThuong | CanChuY | NguyHiem |
|---|---|---|---|---|
| Nhiệt độ | °C | 36.1 – 37.5 | 35 – 36.1 hoặc 37.5 – 38.5 | < 35 hoặc > 38.5 |
| Nhịp tim | bpm | 60 – 100 | 50 – 60 hoặc 100 – 120 | < 50 hoặc > 120 |
| SpO2 | % | 95 – 100 | 90 – 95 | < 90 |
| Huyết áp tâm thu | mmHg | 90 – 129 | 85 – 90 hoặc 129 – 139 | < 85 hoặc > 139 |
| Huyết áp tâm trương | mmHg | 60 – 84 | 55 – 60 hoặc 84 – 89 | < 55 hoặc > 89 |

### 2. TRIGGER TỰ TẠO CẢNH BÁO — minh họa hoạt động

#### 2.1 Thêm một lần đo có nhịp tim 135 bpm (nguy hiểm) và SpO2 93% (cần chú ý):

không viết lệnh INSERT nào vào CANH_BAO, trigger tự tạo hai cảnh báo.

```sql
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
```

**Kết quả:**

| MaCanhBao | MucDo | NoiDung | ThoiGianTao | DaXem |
|---|---|---|---|---|
| 125 | Nguy hiểm | Nhịp tim 135 bpm cao hơn khoảng bình thường (60 – 100 bpm). | 2026-10-10 21:00:00 | 0 |
| 126 | Cần chú ý | SpO2 93 % thấp hơn khoảng bình thường (95 – 100 %). | 2026-10-10 21:00:00 | 0 |

| MaCanhBao | MucDo | NoiDung |
|---|---|---|
| 126 | Cần chú ý | SpO2 93 % thấp hơn khoảng bình thường (95 – 100 %). |

#### 2.3 Giá trị ngoài khoảng hợp lệ (sửa nhịp tim thành 400 bpm) bị trigger từ chối

```sql
BEGIN TRY
    UPDATE CHI_TIET_LAN_DO
    SET GiaTri = 400
    WHERE MaLanDo = 260 AND MaLoaiChiSo = 2;
END TRY
BEGIN CATCH
    SELECT ERROR_NUMBER() AS MaLoi, ERROR_MESSAGE() AS ThongBao;
END CATCH;
```

**Kết quả:**

| MaLoi | ThongBao |
|---|---|
| 50001 | Giá trị đo nằm ngoài khoảng hợp lệ của chỉ số. |

### 3. XEM VÀ CẬP NHẬT CẢNH BÁO

#### 3.1 Mười cảnh báo mới nhất, kèm người được đo và giá trị đo

```sql
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
```

**Kết quả:**

| MaCanhBao | HoTen | TenChiSo | GiaTri | MucDo | ThoiGianTao | DaXem |
|---|---|---|---|---|---|---|
| 108 | Phạm Thị Dung | Huyết áp tâm thu | 131.0 | Cần chú ý | 2026-10-10 18:35:00 | 0 |
| 107 | Đặng Quốc Huy | Huyết áp tâm trương | 92.0 | Nguy hiểm | 2026-10-10 18:12:00 | 0 |
| 106 | Đặng Quốc Huy | Huyết áp tâm thu | 148.0 | Nguy hiểm | 2026-10-10 18:12:00 | 0 |
| 105 | Đặng Quốc Huy | Nhịp tim | 126.0 | Nguy hiểm | 2026-10-10 18:12:00 | 0 |
| 104 | Phạm Thị Dung | SpO2 | 92.0 | Cần chú ý | 2026-10-10 17:18:00 | 0 |
| 103 | Phạm Thị Dung | Huyết áp tâm thu | 133.0 | Cần chú ý | 2026-10-10 08:07:00 | 0 |
| 102 | Ngô Thị Mai | Huyết áp tâm thu | 134.0 | Cần chú ý | 2026-10-10 07:34:00 | 0 |
| 101 | Trần Thị Bích | Huyết áp tâm thu | 132.0 | Cần chú ý | 2026-10-10 07:11:00 | 1 |
| 100 | Dương Văn Nam | Huyết áp tâm trương | 86.0 | Cần chú ý | 2026-10-10 06:57:00 | 0 |
| 99 | Đặng Quốc Huy | Huyết áp tâm thu | 141.0 | Nguy hiểm | 2026-10-09 18:41:00 | 0 |

#### 3.2 Cảnh báo chưa xem, mức nguy hiểm trước

```sql
SELECT cb.MaCanhBao, nd.HoTen, cb.MucDo, cb.NoiDung, cb.ThoiGianTao
FROM CANH_BAO   AS cb
JOIN LAN_DO     AS ld ON ld.MaLanDo = cb.MaLanDo
JOIN NGUOI_DUNG AS nd ON nd.MaNguoiDung = ld.MaNguoiDung
WHERE cb.DaXem = 0
ORDER BY CASE cb.MucDo WHEN N'Nguy hiểm' THEN 0 ELSE 1 END,
         cb.ThoiGianTao DESC;
```

**Kết quả:**

| MaCanhBao | HoTen | MucDo | NoiDung | ThoiGianTao |
|---|---|---|---|---|
| 105 | Đặng Quốc Huy | Nguy hiểm | Nhịp tim 126 bpm cao hơn khoảng bình thường (60 – 100 bpm). | 2026-10-10 18:12:00 |
| 106 | Đặng Quốc Huy | Nguy hiểm | Huyết áp tâm thu 148 mmHg cao hơn khoảng bình thường (90 – 129 mmHg). | 2026-10-10 18:12:00 |
| 107 | Đặng Quốc Huy | Nguy hiểm | Huyết áp tâm trương 92 mmHg cao hơn khoảng bình thường (60 – 84 mmHg). | 2026-10-10 18:12:00 |
| 99 | Đặng Quốc Huy | Nguy hiểm | Huyết áp tâm thu 141 mmHg cao hơn khoảng bình thường (90 – 129 mmHg). | 2026-10-09 18:41:00 |
| 108 | Phạm Thị Dung | Cần chú ý | Huyết áp tâm thu 131 mmHg cao hơn khoảng bình thường (90 – 129 mmHg). | 2026-10-10 18:35:00 |
| 104 | Phạm Thị Dung | Cần chú ý | SpO2 92 % thấp hơn khoảng bình thường (95 – 100 %). | 2026-10-10 17:18:00 |
| 103 | Phạm Thị Dung | Cần chú ý | Huyết áp tâm thu 133 mmHg cao hơn khoảng bình thường (90 – 129 mmHg). | 2026-10-10 08:07:00 |
| 102 | Ngô Thị Mai | Cần chú ý | Huyết áp tâm thu 134 mmHg cao hơn khoảng bình thường (90 – 129 mmHg). | 2026-10-10 07:34:00 |
| 100 | Dương Văn Nam | Cần chú ý | Huyết áp tâm trương 86 mmHg cao hơn khoảng bình thường (60 – 84 mmHg). | 2026-10-10 06:57:00 |
| 98 | Đặng Quốc Huy | Cần chú ý | Huyết áp tâm thu 135 mmHg cao hơn khoảng bình thường (90 – 129 mmHg). | 2026-10-09 07:20:00 |
| 97 | Nguyễn Văn An | Cần chú ý | Huyết áp tâm thu 130 mmHg cao hơn khoảng bình thường (90 – 129 mmHg). | 2026-10-09 06:45:00 |
| 96 | Đặng Quốc Huy | Cần chú ý | Huyết áp tâm trương 86 mmHg cao hơn khoảng bình thường (60 – 84 mmHg). | 2026-10-08 21:19:00 |

*… còn 5 dòng nữa (tổng cộng 17 dòng).*

#### 3.3 Đánh dấu một cảnh báo là đã xem

```sql
BEGIN TRANSACTION;

    UPDATE CANH_BAO
    SET DaXem = 1
    WHERE MaCanhBao = (SELECT MAX(MaCanhBao) FROM CANH_BAO WHERE DaXem = 0);

    SELECT COUNT(*) AS SoCanhBaoChuaXem FROM CANH_BAO WHERE DaXem = 0;

ROLLBACK TRANSACTION;
```

**Kết quả:**

| SoCanhBaoChuaXem |
|---|
| 16 |

#### 3.4 Đánh dấu đã xem toàn bộ cảnh báo của một người

```sql
BEGIN TRANSACTION;

    UPDATE cb
    SET cb.DaXem = 1
    FROM CANH_BAO AS cb
    JOIN LAN_DO   AS ld ON ld.MaLanDo = cb.MaLanDo
    WHERE ld.MaNguoiDung = 7 AND cb.DaXem = 0;

    SELECT @@ROWCOUNT AS SoCanhBaoVuaDanhDau;

ROLLBACK TRANSACTION;
```

**Kết quả:**

| SoCanhBaoVuaDanhDau |
|---|
| 6 |

#### 3.5 Xóa các cảnh báo đã xem và cũ hơn 14 ngày tính từ ngày cuối của dữ liệu mẫu

```sql
BEGIN TRANSACTION;

    DELETE FROM CANH_BAO
    WHERE DaXem = 1
      AND ThoiGianTao < DATEADD(DAY, -14, '2026-10-10');

    SELECT @@ROWCOUNT AS SoCanhBaoDaXoa;

ROLLBACK TRANSACTION;
```

**Kết quả:**

| SoCanhBaoDaXoa |
|---|
| 50 |

### 4. TRUY VẤN CẢNH BÁO THEO NGƯỜI VÀ THỜI GIAN

#### 4.1 Cảnh báo của một người

```sql
SELECT TOP (10) cb.MaCanhBao, cb.MucDo, cb.NoiDung, cb.ThoiGianTao
FROM CANH_BAO AS cb
JOIN LAN_DO   AS ld ON ld.MaLanDo = cb.MaLanDo
WHERE ld.MaNguoiDung = 7
ORDER BY cb.ThoiGianTao DESC, cb.MaCanhBao DESC;
```

**Kết quả:**

| MaCanhBao | MucDo | NoiDung | ThoiGianTao |
|---|---|---|---|
| 107 | Nguy hiểm | Huyết áp tâm trương 92 mmHg cao hơn khoảng bình thường (60 – 84 mmHg). | 2026-10-10 18:12:00 |
| 106 | Nguy hiểm | Huyết áp tâm thu 148 mmHg cao hơn khoảng bình thường (90 – 129 mmHg). | 2026-10-10 18:12:00 |
| 105 | Nguy hiểm | Nhịp tim 126 bpm cao hơn khoảng bình thường (60 – 100 bpm). | 2026-10-10 18:12:00 |
| 99 | Nguy hiểm | Huyết áp tâm thu 141 mmHg cao hơn khoảng bình thường (90 – 129 mmHg). | 2026-10-09 18:41:00 |
| 98 | Cần chú ý | Huyết áp tâm thu 135 mmHg cao hơn khoảng bình thường (90 – 129 mmHg). | 2026-10-09 07:20:00 |
| 96 | Cần chú ý | Huyết áp tâm trương 86 mmHg cao hơn khoảng bình thường (60 – 84 mmHg). | 2026-10-08 21:19:00 |
| 80 | Cần chú ý | Huyết áp tâm trương 86 mmHg cao hơn khoảng bình thường (60 – 84 mmHg). | 2026-10-04 07:00:00 |
| 79 | Nguy hiểm | Huyết áp tâm thu 145 mmHg cao hơn khoảng bình thường (90 – 129 mmHg). | 2026-10-04 07:00:00 |
| 78 | Cần chú ý | Nhịp tim 111 bpm cao hơn khoảng bình thường (60 – 100 bpm). | 2026-10-04 07:00:00 |
| 76 | Cần chú ý | Huyết áp tâm trương 85 mmHg cao hơn khoảng bình thường (60 – 84 mmHg). | 2026-10-03 08:29:00 |

#### 4.2 Cảnh báo trong một khoảng thời gian

```sql
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
```

**Kết quả:**

| HoTen | MucDo | NoiDung | ThoiGianTao |
|---|---|---|---|
| Đặng Quốc Huy | Nguy hiểm | Nhịp tim 126 bpm cao hơn khoảng bình thường (60 – 100 bpm). | 2026-10-10 18:12:00 |
| Đặng Quốc Huy | Nguy hiểm | Huyết áp tâm thu 148 mmHg cao hơn khoảng bình thường (90 – 129 mmHg). | 2026-10-10 18:12:00 |
| Đặng Quốc Huy | Nguy hiểm | Huyết áp tâm trương 92 mmHg cao hơn khoảng bình thường (60 – 84 mmHg). | 2026-10-10 18:12:00 |
| Đặng Quốc Huy | Nguy hiểm | Huyết áp tâm thu 141 mmHg cao hơn khoảng bình thường (90 – 129 mmHg). | 2026-10-09 18:41:00 |

#### 4.3 Số cảnh báo của từng người, tách theo mức độ

```sql
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
```

**Kết quả:**

| HoTen | TongCanhBao | NguyHiem | CanChuY | ChuaXem |
|---|---|---|---|---|
| Đặng Quốc Huy | 38 | 11 | 27 | 6 |
| Ngô Thị Mai | 15 | 2 | 13 | 2 |
| Nguyễn Văn An | 13 | 1 | 12 | 1 |
| Phạm Thị Dung | 13 | 0 | 13 | 3 |
| Dương Văn Nam | 9 | 0 | 9 | 1 |
| Đỗ Thanh Long | 7 | 1 | 6 | 4 |
| Trần Thị Bích | 5 | 0 | 5 | 0 |
| Hoàng Minh Đức | 4 | 0 | 4 | 0 |
| Bùi Thị Lan | 3 | 1 | 2 | 0 |
| Lê Hoàng Cường | 1 | 0 | 1 | 0 |

#### 4.4 Số cảnh báo theo chỉ số và mức độ

```sql
SELECT l.TenChiSo, cb.MucDo, COUNT(*) AS SoCanhBao
FROM CANH_BAO    AS cb
JOIN LOAI_CHI_SO AS l ON l.MaLoaiChiSo = cb.MaLoaiChiSo
GROUP BY l.MaLoaiChiSo, l.TenChiSo, cb.MucDo
ORDER BY l.MaLoaiChiSo, cb.MucDo;
```

**Kết quả:**

| TenChiSo | MucDo | SoCanhBao |
|---|---|---|
| Nhiệt độ | Cần chú ý | 3 |
| Nhiệt độ | Nguy hiểm | 1 |
| Nhịp tim | Cần chú ý | 17 |
| Nhịp tim | Nguy hiểm | 2 |
| SpO2 | Cần chú ý | 9 |
| Huyết áp tâm thu | Cần chú ý | 35 |
| Huyết áp tâm thu | Nguy hiểm | 11 |
| Huyết áp tâm trương | Cần chú ý | 28 |
| Huyết áp tâm trương | Nguy hiểm | 2 |

#### 4.5 Số cảnh báo theo ngày trong 7 ngày cuối của dữ liệu mẫu

```sql
SELECT CAST(ThoiGianTao AS DATE) AS Ngay, COUNT(*) AS SoCanhBao
FROM CANH_BAO
WHERE ThoiGianTao >= '2026-10-04' AND ThoiGianTao < '2026-10-11'
GROUP BY CAST(ThoiGianTao AS DATE)
ORDER BY Ngay;
```

**Kết quả:**

| Ngay | SoCanhBao |
|---|---|
| 2026-10-04 | 4 |
| 2026-10-05 | 1 |
| 2026-10-06 | 7 |
| 2026-10-07 | 5 |
| 2026-10-08 | 2 |
| 2026-10-09 | 3 |
| 2026-10-10 | 9 |

#### 4.6 Lần đo có từ hai cảnh báo trở lên (nhiều chỉ số cùng bất thường)

```sql
SELECT ld.MaLanDo, nd.HoTen, ld.ThoiGianDo, COUNT(*) AS SoCanhBao
FROM CANH_BAO   AS cb
JOIN LAN_DO     AS ld ON ld.MaLanDo = cb.MaLanDo
JOIN NGUOI_DUNG AS nd ON nd.MaNguoiDung = ld.MaNguoiDung
GROUP BY ld.MaLanDo, nd.HoTen, ld.ThoiGianDo
HAVING COUNT(*) >= 2
ORDER BY SoCanhBao DESC, ld.ThoiGianDo DESC;
```

**Kết quả:**

| MaLanDo | HoTen | ThoiGianDo | SoCanhBao |
|---|---|---|---|
| 260 | Đặng Quốc Huy | 2026-10-10 18:12:00 | 3 |
| 206 | Đặng Quốc Huy | 2026-10-04 07:00:00 | 3 |
| 139 | Đặng Quốc Huy | 2026-09-26 21:01:00 | 3 |
| 235 | Đỗ Thanh Long | 2026-10-07 18:11:00 | 2 |
| 230 | Đỗ Thanh Long | 2026-10-07 07:34:00 | 2 |
| 228 | Đỗ Thanh Long | 2026-10-06 21:02:00 | 2 |
| 201 | Đặng Quốc Huy | 2026-10-03 08:29:00 | 2 |
| 171 | Đặng Quốc Huy | 2026-09-30 08:10:00 | 2 |
| 148 | Đặng Quốc Huy | 2026-09-27 19:17:00 | 2 |
| 135 | Đặng Quốc Huy | 2026-09-26 08:53:00 | 2 |
| 133 | Ngô Thị Mai | 2026-09-25 20:47:00 | 2 |
| 121 | Đặng Quốc Huy | 2026-09-24 19:35:00 | 2 |

*… còn 7 dòng nữa (tổng cộng 19 dòng).*

#### 4.7 Kiểm tra tính nhất quán: mọi giá trị ngoài khoảng bình thường đều phải có

cảnh báo, và ngược lại. Truy vấn đúng thì hai con số bằng nhau.

```sql
SELECT
    (SELECT COUNT(*)
     FROM CHI_TIET_LAN_DO AS ct
     JOIN LOAI_CHI_SO     AS l ON l.MaLoaiChiSo = ct.MaLoaiChiSo
     WHERE ct.GiaTri < l.BinhThuongMin OR ct.GiaTri > l.BinhThuongMax) AS SoGiaTriBatThuong,
    (SELECT COUNT(*) FROM CANH_BAO)                                    AS SoCanhBao;
```

**Kết quả:**

| SoGiaTriBatThuong | SoCanhBao |
|---|---|
| 108 | 108 |

## 7. Tương ứng trong ứng dụng

| Chức năng trên ứng dụng | Câu lệnh tương ứng |
|---|---|
| Tab "Cảnh báo": danh sách mới nhất trước | Mục 3.1 |
| Chip "Chưa xem" | Mục 3.2 |
| Chip "Nguy hiểm" / "Cần chú ý" | Mục 3.1, thêm điều kiện `MucDo = …` |
| Chạm vào cảnh báo → đánh dấu đã xem | Mục 3.3 |
| Nút "Đánh dấu đã xem tất cả" | Mục 3.4, bỏ điều kiện theo người |
| Mục "Cảnh báo" trong chi tiết hồ sơ | Mục 4.1 |
| Huy hiệu số trên thanh điều hướng | Mục 3.2 (đếm số dòng) |
| Mục "Cảnh báo của lần đo" trong chi tiết lần đo | Mục 4.1, lọc theo `MaLanDo` thay cho người dùng |

Trên ứng dụng (SQLite), trigger tương đương là `TRG_CHI_TIET_LAN_DO_CanhBao_Them` và `TRG_CHI_TIET_LAN_DO_CanhBao_Sua` trong `sql/sqlite/02_trigger.sql`. Khác biệt chính: trigger của SQLite chạy cho từng dòng (dùng `NEW`), và mỗi trigger chỉ gắn với một sự kiện.
