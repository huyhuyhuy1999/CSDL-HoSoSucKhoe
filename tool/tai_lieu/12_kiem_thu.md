# Phần 12 — Giao diện và kiểm thử

**Người phụ trách:** Người 12 · **Script:** [`sql/sqlserver/11_kiem_thu.sql`](../sql/sqlserver/11_kiem_thu.sql) · **Test tự động:** [`test/`](../test)

## 1. Phạm vi kiểm thử

| Đối tượng | Cách kiểm thử | Số ca |
|---|---|---|
| Cơ sở dữ liệu SQL Server (sản phẩm nộp) | Script `11_kiem_thu.sql` chạy trên SQL Server 2022 | 85 |
| Cơ sở dữ liệu SQLite trong ứng dụng | `test/co_so_du_lieu_test.dart` | 37 |
| Ứng dụng, từ giao diện tới cơ sở dữ liệu | `test/app_smoke_test.dart` | 7 |
| Sự thống nhất giữa hai hệ quản trị | `tool/doi_chieu_hai_he.sh` | 27 phép đối chiếu |

Nội dung kiểm thử theo yêu cầu của đề tài: thêm / sửa / xóa, khóa chính, khóa ngoại, dữ liệu không hợp lệ, tìm kiếm, lọc và thống kê; bổ sung thêm ràng buộc duy nhất, xóa dây chuyền và trigger.

## 2. Môi trường

| Thành phần | Phiên bản |
|---|---|
| SQL Server | 2022 Developer, chạy trong Docker (`tool/sqlserver.sh`) |
| SQLite | bản đóng gói kèm gói `sqlite3` 3.7 của Dart |
| Flutter / Dart | 3.47 / 3.13 |
| Dữ liệu | Dữ liệu mẫu: 12 người dùng, 6 thiết bị, 265 lần đo, 1110 giá trị đo, 108 cảnh báo |

## 3. Phương pháp

Mỗi ca kiểm thử trên SQL Server chạy trong một giao dịch rồi `ROLLBACK`, nên các ca độc lập với nhau và dữ liệu mẫu còn nguyên sau khi kiểm thử. Có hai kiểu ca:

- **Ca phải bị từ chối** — chạy một lệnh vi phạm ràng buộc và đối chiếu **mã lỗi** cùng **tên ràng buộc** trong thông báo lỗi. Ca chỉ đạt khi lệnh bị chặn bởi đúng ràng buộc mong đợi, không phải bởi một lỗi tình cờ nào khác.
- **Ca phải cho đúng giá trị** — chạy một đoạn lệnh rồi so một con số với giá trị mong đợi.

Mã lỗi thường gặp của SQL Server:

| Mã | Ý nghĩa |
|---|---|
| 2627 | Trùng khóa chính hoặc ràng buộc `UNIQUE` |
| 2601 | Trùng chỉ mục duy nhất |
| 547 | Vi phạm khóa ngoại hoặc `CHECK` |
| 515 | Gán `NULL` cho cột `NOT NULL` |
| 50001 – 50004 | Lỗi do trigger và thủ tục của hệ thống tự báo |

## 4. Kết quả kiểm thử trên SQL Server

Bảng dưới đây là đầu ra của `11_kiem_thu.sql`.

{{KIEMTHU}}

Sau khi chạy xong, số dòng của các bảng vẫn như ban đầu:

{{TRUYVAN: SELECT (SELECT COUNT(*) FROM NGUOI_DUNG) AS NguoiDung, (SELECT COUNT(*) FROM HO_SO_SUC_KHOE) AS HoSo, (SELECT COUNT(*) FROM THIET_BI) AS ThietBi, (SELECT COUNT(*) FROM LAN_DO) AS LanDo, (SELECT COUNT(*) FROM CHI_TIET_LAN_DO) AS ChiTiet, (SELECT COUNT(*) FROM CANH_BAO) AS CanhBao}}

## 5. Đối chiếu SQL Server và SQLite

Script nộp bài viết cho SQL Server, còn ứng dụng chạy SQLite. Để chắc hai hệ chứa cùng dữ liệu và các view cho cùng kết quả, `tool/doi_chieu_hai_he.sh` chạy cùng một loạt truy vấn tổng hợp trên cả hai:

{{DOICHIEU}}

Dòng "Mã cảnh báo khớp lần đo" là một tổng kiểm tra trên `MaCanhBao × MaLanDo + MaLoaiChiSo`: nó chỉ khớp khi trigger của hai hệ sinh ra cùng những cảnh báo với cùng mã.

## 6. Kiểm thử trên ứng dụng

### 6.1 Cơ sở dữ liệu SQLite

`test/co_so_du_lieu_test.dart` mở một cơ sở dữ liệu mới trong bộ nhớ cho mỗi ca, từ chính các script ở `sql/sqlite/`. 37 ca thuộc các nhóm:

| Nhóm | Số ca | Nội dung |
|---|:---:|---|
| Tìm kiếm không dấu | 2 | Hàm `bo_dau()` trong Dart và trong SQL |
| Dữ liệu mẫu | 4 | Đủ số dòng; mốc thời gian được dịch về hiện tại; đặt lại dữ liệu mẫu |
| Khóa chính và duy nhất | 4 | Khóa chính kép, hồ sơ 1–1, email, mã định danh thiết bị |
| Khóa ngoại | 4 | Tham chiếu không tồn tại; không xóa được thiết bị đang dùng |
| Xóa dây chuyền | 2 | Xóa người dùng, xóa lần đo |
| Dữ liệu không hợp lệ | 6 | Giới tính, ngày sinh, số điện thoại, chiều cao, cân nặng, nhóm máu, nguồn dữ liệu, thời gian đo |
| Trigger cảnh báo | 7 | Từ chối giá trị sai; đúng mức độ; đúng câu mô tả; sửa giá trị |
| Trigger ngày cập nhật | 1 | `NgayCapNhat` được ghi lại khi sửa hồ sơ |
| View và thống kê | 5 | Số dòng của view, phân bố mức độ, `HAVING`, trung bình / lớn nhất / nhỏ nhất |
| Xử lý lỗi và giao dịch | 2 | Lỗi ràng buộc đổi thành thông báo tiếng Việt; giao dịch bị hủy trọn vẹn |

### 6.2 Từ giao diện tới cơ sở dữ liệu

`test/app_smoke_test.dart` dựng toàn bộ ứng dụng trên một cơ sở dữ liệu SQLite trong bộ nhớ rồi thao tác như người dùng:

| Ca | Thao tác | Kết quả kiểm tra |
|---|---|---|
| 1 | Mở ứng dụng | Tổng quan hiển thị số liệu từ cơ sở dữ liệu |
| 2 | Tab Hồ sơ, gõ "bich" | Liệt kê 12 hồ sơ; tìm không dấu ra đúng "Trần Thị Bích" |
| 3 | Mở lần lượt Lịch sử, Cảnh báo, Thống kê | Mỗi tab hiển thị nội dung của nó |
| 4 | Chạm vào một hồ sơ | Mở chi tiết hồ sơ |
| 5 | Thêm lần đo có nhịp tim 135 bpm | `LAN_DO` tăng 1, `CANH_BAO` tăng 1 (do trigger); màn hình chi tiết hiện "Nguy hiểm" và "Nhịp tim cao" |
| 6 | Thêm lần đo có nhịp tim 400 bpm | Form báo "Phải trong khoảng 20 – 250 bpm"; không ghi gì vào cơ sở dữ liệu |
| 7 | Xóa hồ sơ của Lý Thị Oanh | Người dùng còn 11, hồ sơ còn 11, lần đo giảm 15 (xóa dây chuyền) |

Chạy toàn bộ:

```bash
flutter test
```

Kết quả hiện tại: 44/44 ca đạt.

### 6.3 Giao diện

Các màn hình theo yêu cầu của đề tài — danh sách hồ sơ, chi tiết hồ sơ, lịch sử đo, chi tiết lần đo, cảnh báo và thống kê — được chụp lại tự động bằng `tool/chup_man_hinh_test.dart`:

| Danh sách hồ sơ | Chi tiết hồ sơ | Lịch sử đo |
|---|---|---|
| ![Danh sách hồ sơ](screenshots/03_ho_so_danh_sach.png) | ![Chi tiết hồ sơ](screenshots/04_ho_so_chi_tiet.png) | ![Lịch sử đo](screenshots/09_lich_su_do.png) |

| Chi tiết lần đo | Cảnh báo | Thống kê |
|---|---|---|
| ![Chi tiết lần đo](screenshots/10_lan_do_chi_tiet.png) | ![Cảnh báo](screenshots/12_canh_bao.png) | ![Thống kê](screenshots/14_thong_ke_bieu_do.png) |

Toàn bộ ảnh (gồm cả giao diện tối và các form nhập) nằm trong thư mục [`screenshots`](screenshots).

## 7. Lỗi phát hiện trong quá trình kiểm thử

| # | Hiện tượng | Nguyên nhân | Cách khắc phục |
|---|---|---|---|
| 1 | Tìm "duc" không ra "Hoàng Minh Đức", tìm "duong" không ra "Dương Văn Nam" | Collation `Vietnamese_CI_AI` coi đ, ư, ơ là chữ cái riêng chứ không phải chữ có dấu | Dùng `COLLATE Latin1_General_CI_AI` cho phép tìm kiếm (ca TK-02) |
| 2 | Mã cảnh báo của dữ liệu mẫu không theo thứ tự thời gian và khác nhau giữa hai hệ | Lệnh `INSERT … SELECT` trong trigger không có `ORDER BY`, nên thứ tự cấp `IDENTITY` không xác định | Thêm `ORDER BY MaLanDo, MaLoaiChiSo` vào trigger |
| 3 | Gọi `SP_ThemLanDo` với giá trị sai bên trong một giao dịch khác thì nhận lỗi 266 thay vì lỗi 50001 | `ROLLBACK` trong trigger hủy luôn giao dịch của nơi gọi | Thủ tục kiểm tra khoảng hợp lệ trước khi mở giao dịch (ca CR-09) |
| 4 | Thủ tục kiểm thử báo "Cannot resolve collation conflict" | Thủ tục tạm nằm trong `tempdb`, có collation khác với cơ sở dữ liệu | Thêm `COLLATE DATABASE_DEFAULT` khi so sánh chuỗi |
| 5 | Màn hình chi tiết lần đo bị tràn chữ ở dòng "Khoảng bình thường" | Hai đoạn chữ đặt cạnh nhau không co giãn | Cho đoạn chữ bên trái co lại khi thiếu chỗ (phát hiện bởi ca 5 ở mục 6.2) |

## 8. Giới hạn

- Bản IPA và APK của ứng dụng được build thành công nhưng **chưa được chạy trên thiết bị thật** trong quá trình kiểm thử này; ứng dụng mới được chạy ở chế độ debug trên iOS Simulator.
- Chưa có kiểm thử hiệu năng: dữ liệu mẫu chỉ có vài trăm lần đo.
- Ngưỡng cảnh báo là giá trị tham khảo phục vụ đồ án, chưa được chuyên gia y tế thẩm định.
