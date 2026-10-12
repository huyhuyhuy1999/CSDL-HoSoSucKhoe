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

{{BANG: THIET_BI}}

Một số quyết định thiết kế:

- **Mã định danh là duy nhất.** `MaDinhDanh` (địa chỉ MAC hoặc số serial) là thứ phân biệt hai thiết bị cùng tên, cùng loại ngoài đời thực.
- **Khóa chính vẫn là số tự tăng.** Dù `MaDinhDanh` duy nhất, nó dài và có thể phải sửa (nhập sai, thay mô-đun); khóa thay thế `MaThietBi` ngắn gọn và ổn định hơn để làm khóa ngoại.
- **Ngừng dùng bằng trạng thái, không bằng xóa.** Thiết bị đã có lần đo thì không xóa được (mục 4.2); khi không còn dùng, chuyển `TrangThai` sang "Ngừng sử dụng" để lịch sử đo vẫn giữ nguyên nguồn gốc.

## 3. Dữ liệu mẫu

Sáu thiết bị mô phỏng, đủ ba trạng thái và bốn loại; thiết bị số 6 chưa từng được dùng để có trường hợp "thiết bị chưa có lần đo".

{{TRUYVAN: SELECT MaThietBi, TenThietBi, LoaiThietBi, MaDinhDanh, TrangThai, MoTa FROM THIET_BI ORDER BY MaThietBi}}

Mỗi loại thiết bị chỉ đo một số chỉ số, nên các lần đo của nó có số dòng `CHI_TIET_LAN_DO` khác nhau:

| Thiết bị | Chỉ số đo được |
|---|---|
| ESP32 Health Monitor (số 1 và số 5) | cả 5 chỉ số |
| Máy đo SpO2 kẹp ngón | nhịp tim, SpO2 |
| Nhiệt kế hồng ngoại | nhiệt độ |
| Máy đo huyết áp điện tử | nhịp tim, huyết áp tâm thu, huyết áp tâm trương |

## 4. Câu lệnh và kết quả

Các kết quả dưới đây được lấy bằng cách chạy script trên SQL Server 2022 với dữ liệu mẫu. Mọi lệnh thêm, sửa, xóa minh họa đều nằm trong giao dịch rồi `ROLLBACK`. Vì `IDENTITY` không lùi lại khi `ROLLBACK`, mã của các dòng minh họa có thể không liền sau mã của dữ liệu mẫu.

{{SQL: 08_thiet_bi.sql}}

## 5. Tương ứng trong ứng dụng

| Chức năng trên ứng dụng | Câu lệnh tương ứng |
|---|---|
| Màn hình "Thiết bị đo": danh sách kèm số lần đo | Mục 6.1 |
| Ô tìm theo tên hoặc mã định danh | Mục 5.1 |
| Chip lọc theo trạng thái | Mục 5.2 |
| Thẻ "Thiết bị" ở Tổng quan (4/6) | Mục 5.4 |
| Form "Thêm lần đo": danh sách thiết bị đang hoạt động | Mục 5.2 |
| Chip lọc "Thiết bị đo" / "Nhập thủ công" ở Lịch sử | Mục 6.3 |
