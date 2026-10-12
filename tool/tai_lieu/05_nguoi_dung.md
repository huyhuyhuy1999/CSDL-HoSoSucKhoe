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

{{BANG: NGUOI_DUNG}}

Một số quyết định thiết kế:

- **Không lưu tuổi.** Tuổi thay đổi theo thời gian nên được tính từ `NgaySinh` mỗi khi truy vấn; lưu tuổi sẽ sai sau mỗi lần sinh nhật.
- **Email không bắt buộc nhưng không được trùng.** `UNIQUE` thông thường của SQL Server chỉ cho phép một dòng `NULL`, nên bảng dùng chỉ mục duy nhất có điều kiện (`WHERE Email IS NOT NULL`).
- **Số điện thoại chỉ gồm chữ số.** Việc trình bày có khoảng trắng (0901 234 567) là của giao diện, không phải của dữ liệu.
- **Xóa người dùng là xóa dây chuyền.** Hồ sơ, lần đo, giá trị đo và cảnh báo của người đó bị xóa theo nhờ `ON DELETE CASCADE` ở các bảng con.

## 3. Dữ liệu mẫu

Dữ liệu mẫu gồm 12 người dùng (6 nam, 6 nữ) từ 14 đến 76 tuổi, nằm trong file [`03_du_lieu_mau.sql`](../sql/sqlserver/03_du_lieu_mau.sql).

{{TRUYVAN: SELECT MaNguoiDung, HoTen, GioiTinh, NgaySinh, SoDienThoai, Email FROM NGUOI_DUNG ORDER BY MaNguoiDung}}

## 4. Câu lệnh và kết quả

Các kết quả dưới đây được lấy bằng cách chạy script trên SQL Server 2022 với dữ liệu mẫu. Mọi lệnh thêm, sửa, xóa minh họa đều nằm trong giao dịch rồi `ROLLBACK`, nên chạy script không làm thay đổi dữ liệu mẫu. Các truy vấn tính tuổi dùng ngày hiện tại nên kết quả về tuổi có thể khác đi khi chạy vào thời điểm khác.

{{SQL: 04_nguoi_dung.sql}}

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
