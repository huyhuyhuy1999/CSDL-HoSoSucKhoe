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

{{BANG: LAN_DO}}

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

{{TRUYVAN: SELECT MIN(ThoiGianDo) AS LanDoDauTien, MAX(ThoiGianDo) AS LanDoCuoiCung, COUNT(*) AS TongSoLanDo, COUNT(DISTINCT MaNguoiDung) AS SoNguoi, COUNT(DISTINCT CAST(ThoiGianDo AS DATE)) AS SoNgayCoDo FROM LAN_DO}}

Mười lần đo cuối:

{{TRUYVAN: SELECT TOP (10) ld.MaLanDo, nd.HoTen, ld.ThoiGianDo, ld.NguonDuLieu, ld.MaThietBi, ld.GhiChu FROM LAN_DO AS ld JOIN NGUOI_DUNG AS nd ON nd.MaNguoiDung = ld.MaNguoiDung ORDER BY ld.ThoiGianDo DESC}}

## 4. Câu lệnh và kết quả

Các kết quả dưới đây được lấy bằng cách chạy script trên SQL Server 2022 với dữ liệu mẫu. Mọi lệnh thêm, sửa, xóa minh họa đều nằm trong giao dịch rồi `ROLLBACK`. Vì `IDENTITY` không lùi lại khi `ROLLBACK`, mã của các dòng minh họa có thể không liền sau mã của dữ liệu mẫu.

{{SQL: 07_lan_do.sql}}

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
