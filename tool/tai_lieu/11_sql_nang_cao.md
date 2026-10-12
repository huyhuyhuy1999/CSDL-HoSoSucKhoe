# Phần 11 — SQL nâng cao và thống kê

**Người phụ trách:** Người 11 · **Bảng:** cả 7 bảng · **Script:** [`sql/sqlserver/10_thong_ke.sql`](../sql/sqlserver/10_thong_ke.sql)

## 1. Mục đích

Sau khi các module đã có bảng và dữ liệu, phần này tổng hợp chúng lại để trả lời các câu hỏi thống kê: ai đo nhiều nhất, chỉ số nào hay bất thường, cảnh báo tập trung vào ai, xu hướng theo ngày ra sao.

Nội dung:

| Mục | Nội dung | Số đối tượng / truy vấn |
|---|---|---|
| A | FUNCTION | 4 hàm vô hướng, 1 hàm trả về bảng |
| B | VIEW | 4 view |
| C | PROCEDURE | 4 thủ tục |
| D | JOIN | INNER, LEFT, SELF, CROSS |
| E | GROUP BY với COUNT, AVG, MAX, MIN | 5 truy vấn |
| F | HAVING | 5 truy vấn |
| G | Subquery, tập hợp, CTE, hàm cửa sổ | 11 truy vấn |
| H | Báo cáo thống kê | 7 báo cáo |

## 2. Quan hệ giữa các bảng

Mọi truy vấn trong phần này đi theo các đường nối sau:

![Mô hình quan hệ](so_do/mo_hinh_quan_he.png)

Đường nối dài nhất — từ một cảnh báo ra người được đo, thiết bị và loại chỉ số — đi qua cả 7 bảng.

## 3. Vì sao cần FUNCTION, VIEW và PROCEDURE

- **FUNCTION** gói một công thức dùng lại nhiều nơi. Công thức tính tuổi (trừ năm rồi bớt 1 nếu chưa tới sinh nhật) xuất hiện ở tìm kiếm, thống kê theo nhóm tuổi và view hồ sơ; viết một lần trong `FN_TinhTuoi` thì không nơi nào tính lệch.
- **VIEW** gói một phép ghép bảng dùng lại nhiều nơi. `V_LAN_DO_TONG_HOP` biến năm dòng `CHI_TIET_LAN_DO` của một lần đo thành năm cột trên một dòng — dạng mà cả màn hình lịch sử lẫn báo cáo đều cần.
- **PROCEDURE** gói một thao tác nhiều bước cần trọn vẹn. `SP_ThemLanDo` ghi một lần đo và các giá trị của nó trong một giao dịch: hoặc lưu đủ, hoặc không lưu gì.

## 4. Câu lệnh và kết quả

Các kết quả dưới đây được lấy bằng cách chạy script trên SQL Server 2022 với dữ liệu mẫu. Các lệnh ghi dữ liệu minh họa nằm trong giao dịch rồi `ROLLBACK`. Vì `IDENTITY` không lùi lại khi `ROLLBACK`, mã của các dòng minh họa có thể không liền sau mã của dữ liệu mẫu.

{{SQL: 10_thong_ke.sql}}

## 5. Tương ứng trong ứng dụng

Ứng dụng dùng SQLite, vốn không có FUNCTION và PROCEDURE viết bằng SQL. Các view được tạo lại trong `sql/sqlite/04_view.sql`; phần còn lại nằm trong các lớp repository.

| Trên SQL Server | Trên ứng dụng (SQLite) |
|---|---|
| `FN_TinhTuoi`, `FN_TinhBMI` | Công thức viết thẳng trong view `V_HO_SO_TONG_HOP` |
| `FN_DanhGiaChiSo` | Cột `MucDo` của view `V_CHI_TIET_DANH_GIA` |
| `V_HO_SO_TONG_HOP`, `V_CHI_TIET_DANH_GIA`, `V_LAN_DO_TONG_HOP`, `V_CANH_BAO_CHI_TIET` | Cùng tên, cùng ý nghĩa |
| `SP_ThemLanDo` | `SqliteLanDoRepository.them()` — cùng các bước kiểm tra, cùng một giao dịch |
| `SP_LichSuDo` | `SqliteLanDoRepository.layLichSu()` |
| `SP_ThongKeChiSo` và mục H | `SqliteThongKeRepository.layThongKe()` — màn hình Thống kê |
| `SP_TimNguoiDung` | `SqliteHoSoRepository.layDanhSach()` — danh sách hồ sơ |
| Mục H.1 | `SqliteTongQuanRepository.layTongQuan()` — màn hình Tổng quan |

Hai hệ được đối chiếu tự động bằng `tool/doi_chieu_hai_he.sh` (kết quả ở Phần 12).
