# Phần 3 — Thiết kế ERD

**Người phụ trách:** Người 3 · **Đầu vào:** [Phần 1](01_phan_tich_yeu_cau.md), [Phần 2](02_use_case.md) · **Sơ đồ nguồn:** [`docs/so_do/erd_chen.puml`](so_do/erd_chen.puml)

## 1. Cách tiếp cận

Từ mục "Dữ liệu cần quản lý" và "Quy tắc nghiệp vụ" của Phần 1, việc thiết kế đi qua bốn bước:

1. Tìm các **thực thể**: những đối tượng có danh tính riêng và có thông tin cần lưu.
2. Gán **thuộc tính** cho từng thực thể và chọn **khóa**.
3. Xác định **mối kết hợp** giữa các thực thể cùng bản số, suy ra từ quy tắc nghiệp vụ.
4. Vẽ ERD theo ký hiệu Chen, rồi chuyển thành danh sách khóa chính và khóa ngoại.

## 2. Thực thể

| Thực thể | Ý nghĩa | Loại | Căn cứ (Phần 1) |
|---|---|---|---|
| `NGUOI_DUNG` | Người được theo dõi sức khỏe | Mạnh | Nhóm "Người được theo dõi" |
| `HO_SO_SUC_KHOE` | Thông tin sức khỏe nền của một người | Mạnh | Nhóm "Tình trạng sức khỏe nền" |
| `THIET_BI` | Thiết bị đo (mô phỏng) | Mạnh | Nhóm "Thiết bị" |
| `LOAI_CHI_SO` | Danh mục chỉ số và ngưỡng đánh giá | Mạnh | Nhóm "Loại chỉ số" |
| `LAN_DO` | Một lần ghi nhận chỉ số của một người | Mạnh | Nhóm "Lần đo" |
| `CHI_TIET_LAN_DO` | Giá trị của một chỉ số trong một lần đo | Yếu | Nhóm "Giá trị đo" |
| `CANH_BAO` | Cảnh báo phát sinh từ một giá trị đo bất thường | Mạnh | Nhóm "Cảnh báo" |

`CHI_TIET_LAN_DO` là **thực thể yếu**: một giá trị đo không có danh tính riêng, nó chỉ được xác định khi biết thuộc lần đo nào và là chỉ số nào. Khóa của nó ghép từ khóa của hai thực thể chủ là `LAN_DO` và `LOAI_CHI_SO`.

## 3. Thuộc tính

Khóa được **in đậm**. Cột "Bắt buộc" cho biết thuộc tính có được để trống hay không.

### NGUOI_DUNG

| Thuộc tính | Ý nghĩa | Bắt buộc | Ghi chú |
|---|---|:---:|---|
| **MaNguoiDung** | Mã người dùng | ✓ | Khóa, hệ thống tự cấp |
| HoTen | Họ và tên | ✓ | |
| GioiTinh | Giới tính | ✓ | Nam, Nữ, Khác |
| NgaySinh | Ngày sinh | ✓ | |
| SoDienThoai | Số điện thoại | | |
| Email | Thư điện tử | | Không trùng giữa các người dùng |
| DiaChi | Địa chỉ | | |
| *Tuoi* | Tuổi | | **Thuộc tính dẫn xuất**: tính từ `NgaySinh`, không lưu |

### HO_SO_SUC_KHOE

| Thuộc tính | Ý nghĩa | Bắt buộc | Ghi chú |
|---|---|:---:|---|
| **MaHoSo** | Mã hồ sơ | ✓ | Khóa, hệ thống tự cấp |
| ChieuCao | Chiều cao (cm) | ✓ | |
| CanNang | Cân nặng (kg) | ✓ | |
| NhomMau | Nhóm máu | ✓ | A+, A-, B+, B-, AB+, AB-, O+, O- |
| TienSuBenh | Tiền sử bệnh | | Mô tả tự do |
| DiUng | Dị ứng | | Mô tả tự do |
| NgayCapNhat | Lần cập nhật gần nhất | ✓ | Hệ thống tự ghi |
| *BMI* | Chỉ số khối cơ thể | | **Thuộc tính dẫn xuất**: tính từ `ChieuCao` và `CanNang`, không lưu |

### THIET_BI

| Thuộc tính | Ý nghĩa | Bắt buộc | Ghi chú |
|---|---|:---:|---|
| **MaThietBi** | Mã thiết bị | ✓ | Khóa, hệ thống tự cấp |
| TenThietBi | Tên thiết bị | ✓ | |
| LoaiThietBi | Loại thiết bị | ✓ | Thiết bị đa chỉ số, Máy đo SpO2, Nhiệt kế, Máy đo huyết áp |
| MaDinhDanh | Địa chỉ MAC hoặc số serial | ✓ | Không trùng giữa các thiết bị |
| TrangThai | Trạng thái | ✓ | Hoạt động, Bảo trì, Ngừng sử dụng |

### LOAI_CHI_SO

| Thuộc tính | Ý nghĩa | Bắt buộc | Ghi chú |
|---|---|:---:|---|
| **MaLoaiChiSo** | Mã loại chỉ số | ✓ | Khóa, hệ thống tự cấp |
| TenChiSo | Tên chỉ số | ✓ | Không trùng |
| DonViDo | Đơn vị đo | ✓ | |
| Ngưỡng đánh giá | Ba khoảng giá trị | ✓ | **Thuộc tính kết hợp**, gồm sáu thành phần: cận dưới và cận trên của khoảng hợp lệ, khoảng bình thường, khoảng cảnh báo |

### LAN_DO

| Thuộc tính | Ý nghĩa | Bắt buộc | Ghi chú |
|---|---|:---:|---|
| **MaLanDo** | Mã lần đo | ✓ | Khóa, hệ thống tự cấp |
| ThoiGianDo | Thời điểm đo | ✓ | |
| NguonDuLieu | Nguồn dữ liệu | ✓ | Thiết bị, Thủ công |
| GhiChu | Ghi chú | | |

### CHI_TIET_LAN_DO (thực thể yếu)

| Thuộc tính | Ý nghĩa | Bắt buộc | Ghi chú |
|---|---|:---:|---|
| GiaTri | Giá trị đo được | ✓ | Khóa của thực thể ghép từ `MaLanDo` và `MaLoaiChiSo` của hai thực thể chủ |

### CANH_BAO

| Thuộc tính | Ý nghĩa | Bắt buộc | Ghi chú |
|---|---|:---:|---|
| **MaCanhBao** | Mã cảnh báo | ✓ | Khóa, hệ thống tự cấp |
| MucDo | Mức độ | ✓ | Cần chú ý, Nguy hiểm |
| NoiDung | Câu mô tả | ✓ | |
| ThoiGianTao | Thời điểm phát sinh | ✓ | |
| DaXem | Đã xem hay chưa | ✓ | |

ERD ở mức khái niệm chỉ gồm các thuộc tính mang ý nghĩa nghiệp vụ. Một số cột kỹ thuật được bổ sung khi chuyển sang mô hình quan hệ (Phần 4): `NGUOI_DUNG.NgayTao`, `THIET_BI.MoTa`, `LOAI_CHI_SO.KyHieu` và `LOAI_CHI_SO.SoThapPhan`.

## 4. Mối kết hợp

| Mối kết hợp | Giữa | Bản số | Tham gia | Căn cứ |
|---|---|:---:|---|---|
| **CÓ** | `NGUOI_DUNG` – `HO_SO_SUC_KHOE` | 1 – 1 | Hồ sơ: bắt buộc. Người dùng: không bắt buộc | QT-01 |
| **ĐƯỢC ĐO** | `NGUOI_DUNG` – `LAN_DO` | 1 – N | Lần đo: bắt buộc. Người dùng: không bắt buộc | QT-02 |
| **GHI NHẬN** | `THIET_BI` – `LAN_DO` | 1 – N | Cả hai phía không bắt buộc | QT-05 |
| **GỒM** | `LAN_DO` – `CHI_TIET_LAN_DO` | 1 – N | Giá trị đo: bắt buộc (mối kết hợp xác định) | QT-03 |
| **THUỘC LOẠI** | `LOAI_CHI_SO` – `CHI_TIET_LAN_DO` | 1 – N | Giá trị đo: bắt buộc (mối kết hợp xác định) | QT-03 |
| **PHÁT SINH** | `CHI_TIET_LAN_DO` – `CANH_BAO` | 1 – 1 | Cảnh báo: bắt buộc. Giá trị đo: không bắt buộc | QT-08, QT-09 |

Giải thích:

- **CÓ (1 – 1).** Một người dùng có tối đa một hồ sơ. Hồ sơ không thể tồn tại nếu thiếu người dùng, nhưng người dùng có thể chưa được lập hồ sơ.
- **ĐƯỢC ĐO (1 – N).** Đây là mối kết hợp tạo nên "lịch sử theo dõi": một người có nhiều lần đo theo thời gian. Người mới thêm chưa có lần đo nào.
- **GHI NHẬN (1 – N, không bắt buộc ở cả hai phía).** Lần đo nhập thủ công không gắn với thiết bị nào; thiết bị mới chưa có lần đo nào.
- **GỒM và THUỘC LOẠI.** Hai mối kết hợp xác định của thực thể yếu `CHI_TIET_LAN_DO`: mỗi giá trị đo thuộc đúng một lần đo và đúng một loại chỉ số.
- **PHÁT SINH (1 – 1).** Một giá trị đo sinh ra nhiều nhất một cảnh báo; giá trị bình thường thì không có cảnh báo. Mỗi cảnh báo xuất phát từ đúng một giá trị đo.

### Quan hệ N – N giữa lần đo và loại chỉ số

Xét riêng `LAN_DO` và `LOAI_CHI_SO`: một lần đo gồm nhiều loại chỉ số, và một loại chỉ số xuất hiện trong nhiều lần đo. Đây là quan hệ **N – N**, và giá trị đo (`GiaTri`) là thuộc tính của chính mối kết hợp ấy chứ không của riêng bên nào.

```
LAN_DO  ──N──<  ĐO CHỈ SỐ (GiaTri)  >──N──  LOAI_CHI_SO
```

Trong ERD, mối kết hợp N – N này được nâng lên thành thực thể yếu `CHI_TIET_LAN_DO` với hai mối kết hợp 1 – N, vì hai lý do:

1. `CANH_BAO` cần tham chiếu tới **một giá trị đo cụ thể**; mà chỉ thực thể mới tham gia được vào mối kết hợp khác.
2. Khi chuyển sang mô hình quan hệ, quan hệ N – N đằng nào cũng trở thành một bảng trung gian có khóa ghép từ hai phía.

## 5. ERD

![ERD theo ký hiệu Chen](so_do/erd_chen.png)

Cách đọc ký hiệu:

| Ký hiệu | Ý nghĩa |
|---|---|
| Hình chữ nhật | Thực thể |
| Hình chữ nhật viền kép | Thực thể yếu (`CHI_TIET_LAN_DO`) |
| Hình thoi | Mối kết hợp |
| Hình thoi viền kép | Mối kết hợp xác định của thực thể yếu (GỒM, THUỘC LOẠI) |
| Hình elip | Thuộc tính |
| Thuộc tính gạch chân | Khóa |
| Đường đôi | Tham gia bắt buộc (toàn phần) |
| Đường đơn | Tham gia không bắt buộc (bộ phận) |
| `1`, `N` trên đường nối | Bản số |

## 6. Khóa chính và khóa ngoại

Khi chuyển ERD sang mô hình quan hệ:

- Mỗi thực thể mạnh thành một bảng; khóa của thực thể thành khóa chính.
- Mối kết hợp 1 – N: khóa của phía "1" trở thành khóa ngoại ở bảng phía "N".
- Mối kết hợp 1 – 1: khóa ngoại đặt ở phía tham gia bắt buộc, kèm ràng buộc duy nhất.
- Thực thể yếu: khóa chính ghép từ khóa của các thực thể chủ, mỗi phần đồng thời là khóa ngoại.

### Khóa chính

Danh sách dưới đây được đọc trực tiếp từ cơ sở dữ liệu SQL Server sau khi chạy `01_tao_bang.sql`.

{{TRUYVAN: SELECT OBJECT_NAME(kc.parent_object_id) AS Bang, kc.name AS KhoaChinh, STRING_AGG(c.name, ', ') WITHIN GROUP (ORDER BY ic.key_ordinal) AS Cot FROM sys.key_constraints AS kc JOIN sys.index_columns AS ic ON ic.object_id = kc.parent_object_id AND ic.index_id = kc.unique_index_id JOIN sys.columns AS c ON c.object_id = ic.object_id AND c.column_id = ic.column_id WHERE kc.type = 'PK' GROUP BY kc.parent_object_id, kc.name ORDER BY kc.parent_object_id}}

Sáu bảng dùng khóa thay thế là số nguyên tự tăng: ngắn, không đổi và không mang ý nghĩa nghiệp vụ, nên thích hợp làm đích của khóa ngoại. Riêng `CHI_TIET_LAN_DO` dùng khóa ghép tự nhiên, vừa xác định dòng vừa bảo đảm quy tắc "mỗi loại chỉ số xuất hiện nhiều nhất một lần trong một lần đo".

### Khóa ngoại

{{TRUYVAN: SELECT fk.name AS KhoaNgoai, OBJECT_NAME(fk.parent_object_id) AS Bang, STRING_AGG(pc.name, ', ') WITHIN GROUP (ORDER BY fkc.constraint_column_id) AS Cot, OBJECT_NAME(fk.referenced_object_id) AS BangThamChieu, CASE fk.delete_referential_action WHEN 1 THEN N'Xóa dây chuyền' ELSE N'Không cho xóa' END AS KhiXoaDongDuocThamChieu FROM sys.foreign_keys AS fk JOIN sys.foreign_key_columns AS fkc ON fkc.constraint_object_id = fk.object_id JOIN sys.columns AS pc ON pc.object_id = fkc.parent_object_id AND pc.column_id = fkc.parent_column_id GROUP BY fk.name, fk.parent_object_id, fk.referenced_object_id, fk.delete_referential_action ORDER BY fk.parent_object_id, fk.name}}

| Khóa ngoại | Hiện thực mối kết hợp | Vì sao chọn hành vi khi xóa |
|---|---|---|
| `FK_HO_SO_SUC_KHOE_NGUOI_DUNG` | CÓ | Hồ sơ vô nghĩa khi không còn người dùng |
| `FK_LAN_DO_NGUOI_DUNG` | ĐƯỢC ĐO | Lịch sử đo thuộc về người dùng; xóa người thì xóa lịch sử (QT-11) |
| `FK_LAN_DO_THIET_BI` | GHI NHẬN | Xóa thiết bị sẽ làm lần đo mất nguồn gốc; phải giữ thiết bị và đổi trạng thái (QT-12) |
| `FK_CHI_TIET_LAN_DO_LAN_DO` | GỒM | Giá trị đo là một phần của lần đo |
| `FK_CHI_TIET_LAN_DO_LOAI_CHI_SO` | THUỘC LOẠI | Xóa loại chỉ số sẽ làm giá trị đo mất ý nghĩa (QT-13) |
| `FK_CANH_BAO_CHI_TIET_LAN_DO` | PHÁT SINH | Cảnh báo vô nghĩa khi giá trị đo sinh ra nó không còn |

Hai mối kết hợp 1 – 1 cần thêm ràng buộc duy nhất trên khóa ngoại, nếu không chúng sẽ thành 1 – N:

| Mối kết hợp | Ràng buộc duy nhất |
|---|---|
| CÓ | `UQ_HO_SO_SUC_KHOE_MaNguoiDung` trên `HO_SO_SUC_KHOE(MaNguoiDung)` |
| PHÁT SINH | `UQ_CANH_BAO_ChiTiet` trên `CANH_BAO(MaLanDo, MaLoaiChiSo)` |

## 7. Các phương án đã cân nhắc

| Câu hỏi | Phương án được chọn | Phương án bị loại và lý do |
|---|---|---|
| Hồ sơ sức khỏe có gộp vào người dùng không? | Tách thành thực thể riêng, quan hệ 1 – 1 | Gộp chung: vẫn đúng về mặt chuẩn hóa, nhưng trộn thông tin liên lạc với thông tin y tế, và buộc mọi người dùng phải có đủ chiều cao, cân nặng, nhóm máu ngay khi tạo |
| Mỗi chỉ số là một cột của lần đo? | Tách `LOAI_CHI_SO` và `CHI_TIET_LAN_DO` | Năm cột `NhietDo`, `NhipTim`, …: thêm chỉ số mới phải sửa cấu trúc bảng; lần đo thiếu chỉ số phải để `NULL`; ngưỡng không có chỗ lưu |
| Ngưỡng cảnh báo lưu ở đâu? | Là thuộc tính của `LOAI_CHI_SO` | Viết cứng trong trigger: đổi ngưỡng phải sửa mã. Bảng ngưỡng riêng theo tuổi, giới tính: chính xác hơn về y khoa nhưng vượt phạm vi đồ án |
| Cảnh báo gắn với lần đo hay với giá trị đo? | Với giá trị đo (`CHI_TIET_LAN_DO`) | Gắn với lần đo: không biết chỉ số nào gây cảnh báo; một lần đo có hai chỉ số bất thường sẽ khó diễn đạt |
| Nguồn dữ liệu có là thực thể riêng? | Là thuộc tính của `LAN_DO` | Thực thể `NGUON_DU_LIEU`: chỉ có hai giá trị cố định, không có thuộc tính riêng nào để lưu |
| Xóa thiết bị đã dùng thì sao? | Không cho xóa; dùng thuộc tính `TrangThai` | Xóa dây chuyền: mất lịch sử đo. Gán `NULL`: lần đo từ thiết bị biến thành giống lần đo thủ công, sai nguồn gốc |
