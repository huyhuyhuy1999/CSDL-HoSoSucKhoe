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

Các đối tượng và báo cáo ở trên tương ứng với những chức năng sau của ứng dụng:

| Đối tượng / truy vấn | Chức năng trên ứng dụng |
|---|---|
| `FN_TinhTuoi`, `FN_TinhBMI`, `FN_PhanLoaiBMI` | Tuổi, BMI và phân loại BMI ở danh sách và chi tiết hồ sơ |
| `FN_DanhGiaChiSo` | Nhãn "Bình thường" / "Cần chú ý" / "Nguy hiểm" của từng chỉ số ở chi tiết lần đo |
| `FN_ChiSoMoiNhat` | Mục "Chỉ số mới nhất" ở chi tiết hồ sơ |
| `V_HO_SO_TONG_HOP` | Danh sách hồ sơ: mỗi người một dòng kèm số lần đo và lần đo gần nhất |
| `V_LAN_DO_TONG_HOP` | Thẻ lần đo ở tab Lịch sử: các chỉ số trên một dòng, kèm mức độ nặng nhất |
| `V_CANH_BAO_CHI_TIET` | Tab Cảnh báo |
| `SP_ThemLanDo` | Form "Thêm lần đo": cùng các bước kiểm tra, lưu trong một giao dịch |
| `SP_LichSuDo` | Tab Lịch sử với bộ lọc theo người và khoảng thời gian |
| `SP_TimNguoiDung` | Ô tìm kiếm và chip lọc ở danh sách hồ sơ |
| `SP_ThongKeChiSo` và mục H | Màn hình Thống kê |
| Mục H.1 | Màn hình Tổng quan |
