# Phần 7 — Quản lý chỉ số sức khỏe

**Người phụ trách:** Người 7 · **Bảng:** `LOAI_CHI_SO`, `CHI_TIET_LAN_DO` · **Script:** [`sql/sqlserver/06_chi_so.sql`](../sql/sqlserver/06_chi_so.sql)

## 1. Mục đích

Hệ thống theo dõi năm chỉ số: nhiệt độ, nhịp tim, SpO2, huyết áp tâm thu và huyết áp tâm trương. Hai bảng của phần này trả lời hai câu hỏi:

- `LOAI_CHI_SO` — hệ thống theo dõi **những chỉ số nào**, đơn vị gì, ngưỡng đánh giá ra sao;
- `CHI_TIET_LAN_DO` — trong **mỗi lần đo**, từng chỉ số có **giá trị bao nhiêu**.

## 2. Cấu trúc bảng

### 2.1 LOAI_CHI_SO

{{BANG: LOAI_CHI_SO}}

Ba khoảng ngưỡng lồng nhau quyết định mức độ của một giá trị đo:

| Giá trị nằm trong | Mức độ |
|---|---|
| `[BinhThuongMin, BinhThuongMax]` | Bình thường |
| `[CanhBaoMin, CanhBaoMax]` nhưng ngoài khoảng bình thường | Cần chú ý |
| ngoài `[CanhBaoMin, CanhBaoMax]` nhưng trong `[GiaTriMin, GiaTriMax]` | Nguy hiểm |
| ngoài `[GiaTriMin, GiaTriMax]` | Không hợp lệ, bị từ chối |

Ràng buộc `CK_LOAI_CHI_SO_ThuTuNguong` bảo đảm ba khoảng luôn lồng nhau đúng thứ tự, nên không thể nhập một bộ ngưỡng vô nghĩa.

### 2.2 CHI_TIET_LAN_DO

{{BANG: CHI_TIET_LAN_DO}}

Một số quyết định thiết kế:

- **Mỗi chỉ số một dòng, không phải mỗi chỉ số một cột.** Nếu `LAN_DO` có sẵn năm cột `NhietDo`, `NhipTim`…, thì lần đo bằng máy SpO2 (chỉ có hai chỉ số) phải để trống ba cột, và muốn theo dõi thêm chỉ số mới (ví dụ đường huyết) phải sửa cấu trúc bảng. Với thiết kế hiện tại, thêm chỉ số mới chỉ cần thêm một dòng vào `LOAI_CHI_SO` (mục 1.2).
- **Khóa chính kép `(MaLanDo, MaLoaiChiSo)`.** Một chỉ số không thể xuất hiện hai lần trong cùng một lần đo.
- **Kiểm tra khoảng hợp lệ bằng trigger.** `CHECK` chỉ nhìn được các cột của chính dòng đang ghi, trong khi khoảng hợp lệ nằm ở bảng `LOAI_CHI_SO`; vì vậy việc kiểm tra do trigger `TRG_CHI_TIET_LAN_DO_CanhBao` đảm nhận (xem Phần 10).
- **Đơn vị đo không lặp lại ở từng giá trị.** Đơn vị phụ thuộc vào loại chỉ số chứ không phụ thuộc vào từng lần đo, nên chỉ lưu một lần ở `LOAI_CHI_SO`.

## 3. Dữ liệu mẫu

Năm loại chỉ số và ngưỡng của chúng:

{{TRUYVAN: SELECT MaLoaiChiSo, KyHieu, TenChiSo, DonViDo, CAST(GiaTriMin AS FLOAT) AS GiaTriMin, CAST(GiaTriMax AS FLOAT) AS GiaTriMax, CAST(BinhThuongMin AS FLOAT) AS BinhThuongMin, CAST(BinhThuongMax AS FLOAT) AS BinhThuongMax, CAST(CanhBaoMin AS FLOAT) AS CanhBaoMin, CAST(CanhBaoMax AS FLOAT) AS CanhBaoMax FROM LOAI_CHI_SO ORDER BY MaLoaiChiSo}}

Các ngưỡng trên là giá trị tham khảo phục vụ đồ án, không phải khuyến nghị y khoa.

`CHI_TIET_LAN_DO` có 1110 giá trị thuộc 265 lần đo. Không phải lần đo nào cũng đủ năm chỉ số, vì mỗi loại thiết bị chỉ đo được một số chỉ số:

{{TRUYVAN: SELECT SoChiSo AS SoChiSoTrongLanDo, COUNT(*) AS SoLanDo FROM (SELECT MaLanDo, COUNT(*) AS SoChiSo FROM CHI_TIET_LAN_DO GROUP BY MaLanDo) AS t GROUP BY SoChiSo ORDER BY SoChiSo}}

## 4. Câu lệnh và kết quả

Các kết quả dưới đây được lấy bằng cách chạy script trên SQL Server 2022 với dữ liệu mẫu. Mọi lệnh thêm, sửa, xóa minh họa đều nằm trong giao dịch rồi `ROLLBACK`. Vì `IDENTITY` không lùi lại khi `ROLLBACK`, mã của các dòng minh họa có thể không liền sau mã của dữ liệu mẫu.

{{SQL: 06_chi_so.sql}}

## 5. Tương ứng trong ứng dụng

| Chức năng trên ứng dụng | Câu lệnh tương ứng |
|---|---|
| Màn hình "Chi tiết lần đo": từng chỉ số, khoảng bình thường, mức độ | Mục 2.1 và 2.2 |
| Lưới "Chỉ số mới nhất" trong chi tiết hồ sơ | Mục 3.4 |
| Form "Thêm lần đo": nhãn "BT: 60 – 100 bpm" và đánh giá tức thời | Mục 1.1 |
| Bảng "Thống kê theo chỉ số" | Mục 3.2 |
