# Phần 10 — Quản lý cảnh báo

**Người phụ trách:** Người 10 · **Bảng:** `CANH_BAO` · **Script:** [`sql/sqlserver/02_trigger.sql`](../sql/sqlserver/02_trigger.sql), [`sql/sqlserver/09_canh_bao.sql`](../sql/sqlserver/09_canh_bao.sql)

## 1. Mục đích

Khi một giá trị đo nằm ngoài khoảng bình thường, hệ thống phải ghi lại một cảnh báo để người theo dõi biết. Phần này trả lời ba câu hỏi:

1. Cảnh báo được **lưu** như thế nào và gắn với lần đo ra sao?
2. **Quy tắc ngưỡng** nào quyết định có cảnh báo và mức độ của nó?
3. Cảnh báo được **tạo tự động** bằng cách nào?

## 2. Cấu trúc bảng

{{BANG: CANH_BAO}}

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

{{TRUYVAN: SELECT TenChiSo, DonViDo, CONCAT(CAST(BinhThuongMin AS FLOAT), N' – ', CAST(BinhThuongMax AS FLOAT)) AS BinhThuong, CONCAT(CAST(CanhBaoMin AS FLOAT), N' – ', CAST(BinhThuongMin AS FLOAT), CASE WHEN CanhBaoMax > BinhThuongMax THEN CONCAT(N' hoặc ', CAST(BinhThuongMax AS FLOAT), N' – ', CAST(CanhBaoMax AS FLOAT)) ELSE N'' END) AS CanChuY, CONCAT(N'< ', CAST(CanhBaoMin AS FLOAT), CASE WHEN CanhBaoMax < GiaTriMax THEN CONCAT(N' hoặc > ', CAST(CanhBaoMax AS FLOAT)) ELSE N'' END) AS NguyHiem FROM LOAI_CHI_SO ORDER BY MaLoaiChiSo}}

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

{{TRUYVAN: SELECT MucDo, COUNT(*) AS SoCanhBao, SUM(CASE WHEN DaXem = 0 THEN 1 ELSE 0 END) AS ChuaXem FROM CANH_BAO GROUP BY MucDo ORDER BY MucDo}}

Năm cảnh báo mới nhất:

{{TRUYVAN: SELECT TOP (5) cb.MaCanhBao, nd.HoTen, cb.MucDo, cb.NoiDung, cb.ThoiGianTao, cb.DaXem FROM CANH_BAO AS cb JOIN LAN_DO AS ld ON ld.MaLanDo = cb.MaLanDo JOIN NGUOI_DUNG AS nd ON nd.MaNguoiDung = ld.MaNguoiDung ORDER BY cb.ThoiGianTao DESC, cb.MaCanhBao DESC}}

## 6. Câu lệnh và kết quả

Các kết quả dưới đây được lấy bằng cách chạy script trên SQL Server 2022 với dữ liệu mẫu. Mọi lệnh thêm, sửa, xóa minh họa đều nằm trong giao dịch rồi `ROLLBACK`. Vì `IDENTITY` không lùi lại khi `ROLLBACK`, mã của các dòng minh họa có thể không liền sau mã của dữ liệu mẫu.

{{SQL: 09_canh_bao.sql}}

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
