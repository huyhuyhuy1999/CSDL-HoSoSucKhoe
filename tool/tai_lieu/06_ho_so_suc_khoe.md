# Phần 6 — Quản lý hồ sơ sức khỏe

**Người phụ trách:** Người 6 · **Bảng:** `HO_SO_SUC_KHOE` · **Script:** [`sql/sqlserver/05_ho_so_suc_khoe.sql`](../sql/sqlserver/05_ho_so_suc_khoe.sql)

## 1. Mục đích

`HO_SO_SUC_KHOE` lưu thông tin sức khỏe nền của mỗi người: chiều cao, cân nặng, nhóm máu, tiền sử bệnh, dị ứng và ngày cập nhật. Đây là những thông tin ít thay đổi, khác với các chỉ số đo hằng ngày nằm ở `LAN_DO` và `CHI_TIET_LAN_DO`.

Phần này gồm:

- cấu trúc bảng và các ràng buộc;
- dữ liệu mẫu;
- thêm, sửa, xóa, xem;
- truy vấn hồ sơ theo người dùng, theo nhóm máu, tiền sử bệnh, dị ứng.

## 2. Cấu trúc bảng

{{BANG: HO_SO_SUC_KHOE}}

Một số quyết định thiết kế:

- **Quan hệ 1–1 với người dùng.** Khóa ngoại `MaNguoiDung` có thêm ràng buộc `UNIQUE`, nên mỗi người có tối đa một hồ sơ. Người dùng có thể tồn tại mà chưa có hồ sơ (truy vấn 5.6).
- **Vì sao tách khỏi `NGUOI_DUNG`.** Thông tin định danh (họ tên, ngày sinh, liên hệ) và thông tin y tế có mục đích sử dụng, tần suất cập nhật và mức độ nhạy cảm khác nhau; tách bảng giúp phân quyền và cập nhật độc lập.
- **Không lưu BMI.** BMI tính được từ chiều cao và cân nặng (`CanNang / (ChieuCao/100)²`); lưu thêm sẽ tạo phụ thuộc bắc cầu và có nguy cơ lệch khi sửa cân nặng.
- **`NgayCapNhat` do trigger ghi.** Trigger `TRG_HO_SO_SUC_KHOE_NgayCapNhat` tự đặt thời điểm hiện tại mỗi khi hồ sơ được sửa, nên không phụ thuộc vào việc chương trình có nhớ gán hay không.

### Trigger ghi ngày cập nhật

```sql
CREATE OR ALTER TRIGGER TRG_HO_SO_SUC_KHOE_NgayCapNhat
ON HO_SO_SUC_KHOE
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    IF UPDATE(NgayCapNhat) RETURN;

    UPDATE hs
    SET NgayCapNhat = SYSDATETIME()
    FROM HO_SO_SUC_KHOE AS hs
    JOIN inserted AS i ON i.MaHoSo = hs.MaHoSo;
END;
```

`IF UPDATE(NgayCapNhat) RETURN` cho phép câu lệnh chủ động gán cột này (ví dụ khi nạp dữ liệu cũ) mà không bị trigger ghi đè.

## 3. Dữ liệu mẫu

Mỗi người dùng mẫu có một hồ sơ. Dữ liệu được chọn để có đủ các trường hợp: có và không có tiền sử bệnh, có và không có dị ứng, đủ các mức BMI.

{{TRUYVAN: SELECT hs.MaHoSo, nd.HoTen, hs.ChieuCao, hs.CanNang, hs.NhomMau, hs.TienSuBenh, hs.DiUng FROM HO_SO_SUC_KHOE AS hs JOIN NGUOI_DUNG AS nd ON nd.MaNguoiDung = hs.MaNguoiDung ORDER BY hs.MaHoSo}}

## 4. Câu lệnh và kết quả

Các kết quả dưới đây được lấy bằng cách chạy script trên SQL Server 2022 với dữ liệu mẫu. Mọi lệnh thêm, sửa, xóa minh họa đều nằm trong giao dịch rồi `ROLLBACK`. Vì `IDENTITY` không lùi lại khi `ROLLBACK`, mã của các dòng minh họa có thể không liền sau mã của dữ liệu mẫu.

{{SQL: 05_ho_so_suc_khoe.sql}}

## 5. Tương ứng trong ứng dụng

| Chức năng trên ứng dụng | Câu lệnh tương ứng |
|---|---|
| Màn hình "Chi tiết hồ sơ" | Mục 1.2 và 1.3 |
| Ô BMI kèm phân loại | Mục 1.3 |
| Form "Thêm hồ sơ" (ghi người dùng và hồ sơ cùng lúc) | Mục 2.1 |
| Form "Sửa hồ sơ" | Mục 3.1 |
| Dòng "Cập nhật ngày …" | Trigger ghi ngày cập nhật |

Ứng dụng đọc hồ sơ qua view `V_HO_SO_TONG_HOP` (xem Phần 11), view này ghép sẵn người dùng, hồ sơ, tuổi, BMI và số liệu đo.
