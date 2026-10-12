# Phần 4 — Chuẩn hóa và mô hình quan hệ

**Người phụ trách:** Người 4 · **Đầu vào:** ERD ở [Phần 3](03_erd.md) · **Script:** [`sql/sqlserver/01_tao_bang.sql`](../sql/sqlserver/01_tao_bang.sql)

## 1. Mục đích

Phần này làm ba việc:

1. **Kiểm tra** ERD của Phần 3.
2. **Chứng minh** thiết kế đạt chuẩn 3NF, bằng cách đi từ một bảng phẳng chưa chuẩn hóa (cách ghi sổ thông thường) qua 1NF, 2NF, 3NF và cho thấy kết quả trùng với các bảng suy ra từ ERD.
3. **Hoàn thiện** mô hình quan hệ cuối cùng và từ điển dữ liệu.

## 2. Kiểm tra ERD

| Tiêu chí | Kết quả |
|---|---|
| Mỗi thực thể có khóa | Đạt. Sáu thực thể mạnh có khóa riêng; thực thể yếu `CHI_TIET_LAN_DO` có khóa ghép từ hai thực thể chủ |
| Không có thuộc tính lặp lại ở hai thực thể | Đạt. Thông tin về người chỉ ở `NGUOI_DUNG`, về thiết bị chỉ ở `THIET_BI`, về chỉ số chỉ ở `LOAI_CHI_SO` |
| Không lưu thuộc tính dẫn xuất | Đạt. Tuổi và BMI được đánh dấu là dẫn xuất, không lưu |
| Quan hệ N – N đã được tách | Đạt. Lần đo – loại chỉ số được tách qua `CHI_TIET_LAN_DO` |
| Mọi quy tắc nghiệp vụ có chỗ thể hiện | Đạt, với hai quy tắc phải hiện thực bằng trigger hoặc thủ tục vì liên quan nhiều bảng hoặc nhiều dòng: QT-07 (khoảng hợp lệ nằm ở bảng khác) và QT-03, QT-04 (ràng buộc giữa các dòng của cùng một lần đo) |
| Thuộc tính đa trị | Cần lưu ý: `DiUng` (mục 8.4) |
| Thuộc tính kết hợp | "Ngưỡng đánh giá" của `LOAI_CHI_SO` được tách thành sáu cột khi chuyển sang mô hình quan hệ |

## 3. Điểm xuất phát: bảng chưa chuẩn hóa

Giả sử toàn bộ dữ liệu được ghi vào một sổ theo dõi duy nhất, mỗi dòng là một lần đo. Ba dòng dưới đây là dữ liệu thật trong dữ liệu mẫu (lần đo 256, 260 và 261), được ghép lại thành dạng sổ:

{{TRUYVAN: SELECT nd.HoTen, nd.NgaySinh, hs.NhomMau, ld.ThoiGianDo, ISNULL(tb.TenThietBi, N'(nhập thủ công)') AS ThietBi, STRING_AGG(CONCAT(l.TenChiSo, N' ', CAST(ct.GiaTri AS FLOAT), N' ', l.DonViDo), N'; ') WITHIN GROUP (ORDER BY ct.MaLoaiChiSo) AS CacChiSo, ISNULL((SELECT STRING_AGG(CONCAT(l2.TenChiSo, N': ', cb.MucDo), N'; ') FROM CANH_BAO AS cb JOIN LOAI_CHI_SO AS l2 ON l2.MaLoaiChiSo = cb.MaLoaiChiSo WHERE cb.MaLanDo = ld.MaLanDo), N'') AS CanhBao FROM LAN_DO AS ld JOIN NGUOI_DUNG AS nd ON nd.MaNguoiDung = ld.MaNguoiDung JOIN HO_SO_SUC_KHOE AS hs ON hs.MaNguoiDung = nd.MaNguoiDung LEFT JOIN THIET_BI AS tb ON tb.MaThietBi = ld.MaThietBi JOIN CHI_TIET_LAN_DO AS ct ON ct.MaLanDo = ld.MaLanDo JOIN LOAI_CHI_SO AS l ON l.MaLoaiChiSo = ct.MaLoaiChiSo WHERE ld.MaLanDo IN (256, 260, 261) GROUP BY ld.MaLanDo, nd.HoTen, nd.NgaySinh, hs.NhomMau, ld.ThoiGianDo, tb.TenThietBi ORDER BY ld.MaLanDo}}

Lược đồ đầy đủ của sổ:

```
SO_THEO_DOI(HoTen, GioiTinh, NgaySinh, SoDienThoai, Email, DiaChi,
            ChieuCao, CanNang, NhomMau, TienSuBenh, DiUng, NgayCapNhat,
            ThoiGianDo, NguonDuLieu, GhiChu,
            TenThietBi, LoaiThietBi, MaDinhDanh, TrangThai,
            { TenChiSo, DonViDo, Nguong, GiaTri, MucDoCanhBao, NoiDungCanhBao })
```

Phần trong ngoặc nhọn là một **nhóm lặp**: một dòng chứa nhiều chỉ số. Bảng này gặp đủ ba loại dị thường:

| Dị thường | Ví dụ |
|---|---|
| **Khi thêm** | Không ghi được một người chưa đo lần nào; không khai báo được một thiết bị mới hay một loại chỉ số mới khi chưa có lần đo dùng tới nó |
| **Khi sửa** | Đặng Quốc Huy đổi số điện thoại: phải sửa ở mọi dòng của ông; sót một dòng là dữ liệu mâu thuẫn. Đổi ngưỡng nhịp tim: phải sửa ở mọi dòng có nhịp tim |
| **Khi xóa** | Xóa lần đo duy nhất của một người thì mất luôn thông tin cá nhân và hồ sơ của người đó |

## 4. Phụ thuộc hàm

Để chuẩn hóa, trước hết bổ sung các mã định danh (`MaNguoiDung`, `MaHoSo`, `MaThietBi`, `MaLoaiChiSo`, `MaLanDo`, `MaCanhBao`), vì các thuộc tính tự nhiên không đủ tin cậy làm khóa: hai người có thể trùng họ tên và ngày sinh.

Các phụ thuộc hàm rút ra từ quy tắc nghiệp vụ:

| # | Phụ thuộc hàm | Căn cứ |
|---|---|---|
| F1 | `MaNguoiDung → HoTen, GioiTinh, NgaySinh, SoDienThoai, Email, DiaChi` | Mỗi mã xác định một người |
| F2 | `MaNguoiDung → MaHoSo, ChieuCao, CanNang, NhomMau, TienSuBenh, DiUng, NgayCapNhat` | QT-01: mỗi người tối đa một hồ sơ |
| F3 | `MaHoSo → MaNguoiDung` | QT-01: mỗi hồ sơ của đúng một người |
| F4 | `MaThietBi → TenThietBi, LoaiThietBi, MaDinhDanh, TrangThai` | Mỗi mã xác định một thiết bị |
| F5 | `MaDinhDanh → MaThietBi` | QT-14: mã định danh không trùng |
| F6 | `MaLoaiChiSo → TenChiSo, DonViDo, Nguong` | Mỗi mã xác định một loại chỉ số |
| F7 | `TenChiSo → MaLoaiChiSo` | Tên chỉ số không trùng |
| F8 | `MaLanDo → MaNguoiDung, MaThietBi, NguonDuLieu, ThoiGianDo, GhiChu` | QT-02: mỗi lần đo của đúng một người, tại một thời điểm |
| F9 | `MaLanDo, MaLoaiChiSo → GiaTri` | QT-03: mỗi chỉ số xuất hiện nhiều nhất một lần trong một lần đo |
| F10 | `MaLanDo, MaLoaiChiSo → MaCanhBao, MucDo, NoiDung, ThoiGianTao, DaXem` | QT-09: mỗi giá trị đo nhiều nhất một cảnh báo |
| F11 | `MaCanhBao → MaLanDo, MaLoaiChiSo` | Mỗi cảnh báo xuất phát từ đúng một giá trị đo |

## 5. Dạng chuẩn 1 (1NF)

**Yêu cầu:** mọi thuộc tính mang giá trị nguyên tố; không có nhóm lặp.

**Vi phạm:** nhóm lặp `{TenChiSo, DonViDo, Nguong, GiaTri, …}` — một dòng chứa nhiều chỉ số.

**Xử lý:** tách mỗi chỉ số thành một dòng riêng. Ba dòng ở mục 3 trở thành:

{{TRUYVAN: SELECT ld.MaLanDo, ct.MaLoaiChiSo, nd.HoTen, nd.NgaySinh, ld.ThoiGianDo, ISNULL(tb.TenThietBi, N'(nhập thủ công)') AS ThietBi, l.TenChiSo, l.DonViDo, CAST(ct.GiaTri AS FLOAT) AS GiaTri, ISNULL(cb.MucDo, N'') AS MucDoCanhBao FROM CHI_TIET_LAN_DO AS ct JOIN LAN_DO AS ld ON ld.MaLanDo = ct.MaLanDo JOIN NGUOI_DUNG AS nd ON nd.MaNguoiDung = ld.MaNguoiDung LEFT JOIN THIET_BI AS tb ON tb.MaThietBi = ld.MaThietBi JOIN LOAI_CHI_SO AS l ON l.MaLoaiChiSo = ct.MaLoaiChiSo LEFT JOIN CANH_BAO AS cb ON cb.MaLanDo = ct.MaLanDo AND cb.MaLoaiChiSo = ct.MaLoaiChiSo WHERE ld.MaLanDo IN (256, 260, 261) ORDER BY ld.MaLanDo, ct.MaLoaiChiSo}}

Quan hệ đạt 1NF, với khóa chính là `(MaLanDo, MaLoaiChiSo)`:

```
SO_THEO_DOI_1NF(MaLanDo, MaLoaiChiSo,
                MaNguoiDung, HoTen, GioiTinh, NgaySinh, SoDienThoai, Email, DiaChi,
                MaHoSo, ChieuCao, CanNang, NhomMau, TienSuBenh, DiUng, NgayCapNhat,
                ThoiGianDo, NguonDuLieu, GhiChu,
                MaThietBi, TenThietBi, LoaiThietBi, MaDinhDanh, TrangThai,
                TenChiSo, DonViDo, Nguong,
                GiaTri,
                MaCanhBao, MucDo, NoiDung, ThoiGianTao, DaXem)
```

Bảng đã hết nhóm lặp nhưng dư thừa còn nặng hơn: họ tên và ngày sinh của Đặng Quốc Huy giờ lặp lại ở bảy dòng chỉ cho hai lần đo.

## 6. Dạng chuẩn 2 (2NF)

**Yêu cầu:** đạt 1NF, và mọi thuộc tính không khóa phụ thuộc **đầy đủ** vào khóa chính (không phụ thuộc vào chỉ một phần của khóa).

**Vi phạm:** khóa là `(MaLanDo, MaLoaiChiSo)`, nhưng:

| Phụ thuộc bộ phận | Thuộc tính bị ảnh hưởng |
|---|---|
| Chỉ phụ thuộc `MaLanDo` (F8, rồi F1, F2, F4) | Người được đo, hồ sơ, thời gian, nguồn dữ liệu, thiết bị |
| Chỉ phụ thuộc `MaLoaiChiSo` (F6) | `TenChiSo`, `DonViDo`, `Nguong` |

Chỉ có `GiaTri` và nhóm thuộc tính cảnh báo phụ thuộc đầy đủ vào cả khóa (F9, F10).

**Xử lý:** tách mỗi nhóm phụ thuộc bộ phận thành một quan hệ riêng.

```
LAN_DO_2NF(MaLanDo,
           MaNguoiDung, HoTen, GioiTinh, NgaySinh, SoDienThoai, Email, DiaChi,
           MaHoSo, ChieuCao, CanNang, NhomMau, TienSuBenh, DiUng, NgayCapNhat,
           ThoiGianDo, NguonDuLieu, GhiChu,
           MaThietBi, TenThietBi, LoaiThietBi, MaDinhDanh, TrangThai)

LOAI_CHI_SO(MaLoaiChiSo, TenChiSo, DonViDo, Nguong)

CHI_TIET_2NF(MaLanDo, MaLoaiChiSo, GiaTri,
             MaCanhBao, MucDo, NoiDung, ThoiGianTao, DaXem)
```

Kết quả: tên và ngưỡng của mỗi chỉ số chỉ còn lưu một lần; khai báo được loại chỉ số mới trước khi có lần đo nào.

## 7. Dạng chuẩn 3 (3NF)

**Yêu cầu:** đạt 2NF, và không thuộc tính không khóa nào phụ thuộc **bắc cầu** vào khóa chính (qua một thuộc tính không khóa khác).

**Vi phạm trong `LAN_DO_2NF`:**

| Phụ thuộc bắc cầu | Qua |
|---|---|
| `MaLanDo → MaNguoiDung → HoTen, GioiTinh, NgaySinh, …` | F8 rồi F1 |
| `MaLanDo → MaNguoiDung → MaHoSo, ChieuCao, CanNang, …` | F8 rồi F2 |
| `MaLanDo → MaThietBi → TenThietBi, LoaiThietBi, MaDinhDanh, TrangThai` | F8 rồi F4 |

**Xử lý:** tách thông tin người dùng (kèm hồ sơ) và thiết bị ra khỏi lần đo, chỉ để lại khóa ngoại.

```
NGUOI_DUNG_VA_HO_SO(MaNguoiDung, HoTen, GioiTinh, NgaySinh, SoDienThoai, Email, DiaChi,
                    MaHoSo, ChieuCao, CanNang, NhomMau, TienSuBenh, DiUng, NgayCapNhat)

THIET_BI(MaThietBi, TenThietBi, LoaiThietBi, MaDinhDanh, TrangThai)

LAN_DO(MaLanDo, MaNguoiDung, MaThietBi, NguonDuLieu, ThoiGianDo, GhiChu)
```

`CHI_TIET_2NF` không có phụ thuộc bắc cầu: cả `GiaTri` lẫn nhóm thuộc tính cảnh báo đều phụ thuộc trực tiếp vào khóa `(MaLanDo, MaLoaiChiSo)`. Tới đây mọi quan hệ đã đạt 3NF.

## 8. Các bước tách thêm và những điểm cần bàn

Hai lần tách dưới đây **không do chuẩn hóa bắt buộc** — quan hệ trước khi tách đã đạt 3NF — mà do ý nghĩa của dữ liệu.

### 8.1 Tách hồ sơ sức khỏe khỏi người dùng

Trong `NGUOI_DUNG_VA_HO_SO`, mọi thuộc tính đều phụ thuộc trực tiếp vào `MaNguoiDung`; gộp chung vẫn đạt 3NF. Nhóm vẫn tách thành `NGUOI_DUNG` và `HO_SO_SUC_KHOE` (quan hệ 1 – 1) vì:

- **Hồ sơ là tùy chọn.** Gộp chung thì người chưa lập hồ sơ phải có ba cột bắt buộc (chiều cao, cân nặng, nhóm máu) ở trạng thái `NULL`, làm mất khả năng ràng buộc `NOT NULL` cho chúng.
- **Hai nhóm thông tin thay đổi theo nhịp khác nhau.** Thông tin liên lạc hiếm khi đổi; cân nặng, tiền sử bệnh được cập nhật định kỳ. `NgayCapNhat` chỉ có nghĩa với nhóm thứ hai.
- **Mức độ nhạy cảm khác nhau.** Thông tin y tế tách riêng thì dễ giới hạn quyền truy cập hơn khi hệ thống có phân quyền.

### 8.2 Tách cảnh báo khỏi giá trị đo

Trong `CHI_TIET_2NF`, nhóm thuộc tính cảnh báo phụ thuộc đầy đủ và trực tiếp vào khóa, nên không vi phạm 3NF. Nhưng dữ liệu mẫu cho thấy chỉ 108 trong 1110 giá trị đo có cảnh báo: gộp chung thì hơn 90% số dòng mang năm cột `NULL`. Tách thành `CANH_BAO` với quan hệ 1 – 0..1:

```
CHI_TIET_LAN_DO(MaLanDo, MaLoaiChiSo, GiaTri)
CANH_BAO(MaCanhBao, MaLanDo, MaLoaiChiSo, MucDo, NoiDung, ThoiGianTao, DaXem)
```

Cảnh báo cũng có vòng đời riêng (được đánh dấu đã xem, được liệt kê và lọc độc lập với giá trị đo), nên là một thực thể đúng nghĩa.

### 8.3 Dư thừa có kiểm soát

Thiết kế cuối cùng còn ba chỗ lưu thông tin có thể suy ra được. Cả ba đều là lựa chọn có chủ đích và đều có cơ chế giữ cho dữ liệu không mâu thuẫn:

| Cột | Suy ra được từ | Vì sao vẫn lưu | Cơ chế bảo đảm nhất quán |
|---|---|---|---|
| `LAN_DO.NguonDuLieu` | `MaThietBi` có `NULL` hay không | Yêu cầu của đề tài nêu rõ "quản lý nguồn dữ liệu"; truy vấn dễ đọc hơn; có chỗ cho nguồn mới sau này (nhập từ tệp, đồng bộ từ ứng dụng khác) | `CK_LAN_DO_NguonKhopThietBi` loại bỏ mọi tổ hợp mâu thuẫn |
| `CANH_BAO.MucDo`, `NoiDung` | `GiaTri` và ngưỡng trong `LOAI_CHI_SO` | Là **ảnh chụp tại thời điểm phát sinh**: nếu ngưỡng được chỉnh về sau, cảnh báo cũ vẫn giải thích đúng vì sao nó được tạo | Theo quy ước, không chương trình nào tự chèn vào `CANH_BAO`: cảnh báo chỉ do trigger tạo; sửa giá trị đo thì trigger tạo lại cảnh báo |
| `CANH_BAO.ThoiGianTao` | `LAN_DO.ThoiGianDo` | Liệt kê cảnh báo mới nhất là truy vấn thường xuyên; có cột này thì sắp xếp được bằng chỉ mục mà không phải nối bảng | Trigger gán bằng thời gian đo |

Xét chặt chẽ, với đúng hai nguồn dữ liệu như hiện tại thì `MaLanDo → MaThietBi → NguonDuLieu` là một phụ thuộc bắc cầu; nhóm chấp nhận điều này vì ràng buộc `CHECK` khiến hai cột không thể mâu thuẫn nhau.

### 8.4 Thuộc tính `DiUng` và 1NF

`DiUng` có thể chứa một danh sách (ví dụ "Bụi nhà, lông mèo" trong dữ liệu mẫu), tức về bản chất là thuộc tính đa trị. Nhóm coi nó là một đoạn **mô tả tự do** và lưu trong một cột văn bản, vì hệ thống không có yêu cầu nào cần tra cứu chính xác theo từng chất gây dị ứng; tìm theo từ khóa bằng `LIKE` là đủ. Nếu về sau cần thống kê theo chất gây dị ứng hoặc cảnh báo tương tác thuốc, phải tách thành bảng riêng:

```
DI_UNG(MaHoSo, TenChatGayDiUng)
```

`TienSuBenh` được xử lý tương tự.

### 8.5 Dạng chuẩn Boyce–Codd

Trong cả bảy bảng cuối cùng, vế trái của mọi phụ thuộc hàm đều là khóa (khóa chính hoặc một khóa dự tuyển như `Email`, `MaDinhDanh`, `KyHieu`, `TenChiSo`), nên thiết kế cũng đạt BCNF — ngoại trừ điểm đã nêu về `NguonDuLieu` ở mục 8.3.

## 9. Kiểm tra từng bảng

| Bảng | Khóa chính | Khóa dự tuyển khác | Thuộc tính không khóa phụ thuộc vào | Kết luận |
|---|---|---|---|:---:|
| `NGUOI_DUNG` | `MaNguoiDung` | `Email` (khi có) | Toàn bộ khóa chính, trực tiếp | 3NF |
| `HO_SO_SUC_KHOE` | `MaHoSo` | `MaNguoiDung` | Toàn bộ khóa chính, trực tiếp | 3NF |
| `THIET_BI` | `MaThietBi` | `MaDinhDanh` | Toàn bộ khóa chính, trực tiếp | 3NF |
| `LOAI_CHI_SO` | `MaLoaiChiSo` | `KyHieu`, `TenChiSo` | Toàn bộ khóa chính, trực tiếp | 3NF |
| `LAN_DO` | `MaLanDo` | — | Toàn bộ khóa chính; riêng `NguonDuLieu` xem mục 8.3 | 3NF (có ghi chú) |
| `CHI_TIET_LAN_DO` | `(MaLanDo, MaLoaiChiSo)` | — | `GiaTri` phụ thuộc đầy đủ vào cả hai thành phần của khóa | 3NF |
| `CANH_BAO` | `MaCanhBao` | `(MaLanDo, MaLoaiChiSo)` | Toàn bộ khóa chính, trực tiếp | 3NF |

Kết quả chuẩn hóa trùng với bảy bảng suy ra từ ERD ở Phần 3: hai con đường độc lập cho cùng một thiết kế.

## 10. Mô hình quan hệ cuối cùng

Khóa chính được **in đậm**, khóa ngoại được *in nghiêng*.

- NGUOI_DUNG(**MaNguoiDung**, HoTen, GioiTinh, NgaySinh, SoDienThoai, Email, DiaChi, NgayTao)
- HO_SO_SUC_KHOE(**MaHoSo**, *MaNguoiDung*, ChieuCao, CanNang, NhomMau, TienSuBenh, DiUng, NgayCapNhat)
- THIET_BI(**MaThietBi**, TenThietBi, LoaiThietBi, MaDinhDanh, TrangThai, MoTa)
- LOAI_CHI_SO(**MaLoaiChiSo**, KyHieu, TenChiSo, DonViDo, SoThapPhan, GiaTriMin, GiaTriMax, BinhThuongMin, BinhThuongMax, CanhBaoMin, CanhBaoMax)
- LAN_DO(**MaLanDo**, *MaNguoiDung*, *MaThietBi*, NguonDuLieu, ThoiGianDo, GhiChu)
- CHI_TIET_LAN_DO(***MaLanDo***, ***MaLoaiChiSo***, GiaTri)
- CANH_BAO(**MaCanhBao**, *MaLanDo*, *MaLoaiChiSo*, MucDo, NoiDung, ThoiGianTao, DaXem)

![Mô hình quan hệ](so_do/mo_hinh_quan_he.png)

So với ERD mức khái niệm, mô hình quan hệ bổ sung bốn cột kỹ thuật:

| Cột | Mục đích |
|---|---|
| `NGUOI_DUNG.NgayTao` | Ghi nhận thời điểm tạo bản ghi |
| `THIET_BI.MoTa` | Ghi chú tự do về thiết bị |
| `LOAI_CHI_SO.KyHieu` | Mã ngắn, ổn định (ví dụ `NHIP_TIM`) để chương trình nhận biết chỉ số mà không phụ thuộc vào tên hiển thị |
| `LOAI_CHI_SO.SoThapPhan` | Số chữ số thập phân khi hiển thị: nhiệt độ cần một chữ số, nhịp tim thì không |

## 11. Từ điển dữ liệu

Cấu trúc dưới đây được đọc trực tiếp từ cơ sở dữ liệu SQL Server sau khi chạy `01_tao_bang.sql`, nên luôn khớp với script.

### NGUOI_DUNG

{{BANG: NGUOI_DUNG}}

### HO_SO_SUC_KHOE

{{BANG: HO_SO_SUC_KHOE}}

### THIET_BI

{{BANG: THIET_BI}}

### LOAI_CHI_SO

{{BANG: LOAI_CHI_SO}}

### LAN_DO

{{BANG: LAN_DO}}

### CHI_TIET_LAN_DO

{{BANG: CHI_TIET_LAN_DO}}

### CANH_BAO

{{BANG: CANH_BAO}}

## 12. Quy ước đặt tên

| Đối tượng | Quy ước | Ví dụ |
|---|---|---|
| Bảng | Chữ hoa, không dấu, các từ nối bằng gạch dưới | `HO_SO_SUC_KHOE` |
| Cột | Viết hoa chữ đầu mỗi từ, không dấu | `NgayCapNhat` |
| Khóa chính | `PK_<Bảng>` | `PK_LAN_DO` |
| Khóa ngoại | `FK_<Bảng con>_<Bảng cha>` | `FK_LAN_DO_NGUOI_DUNG` |
| Duy nhất | `UQ_<Bảng>_<Cột>` | `UQ_THIET_BI_MaDinhDanh` |
| CHECK | `CK_<Bảng>_<Cột hoặc ý nghĩa>` | `CK_LAN_DO_NguonKhopThietBi` |
| Mặc định | `DF_<Bảng>_<Cột>` | `DF_CANH_BAO_DaXem` |
| Chỉ mục | `IX_<Bảng>_<Cột>` | `IX_LAN_DO_ThoiGianDo` |
| Trigger | `TRG_<Bảng>_<Ý nghĩa>` | `TRG_CHI_TIET_LAN_DO_CanhBao` |
| View, hàm, thủ tục | `V_`, `FN_`, `SP_` | `V_LAN_DO_TONG_HOP`, `FN_TinhBMI`, `SP_ThemLanDo` |

Mọi ràng buộc đều được đặt tên để thông báo lỗi chỉ rõ quy tắc nào bị vi phạm; bộ kiểm thử ở Phần 12 dựa vào chính các tên này.
