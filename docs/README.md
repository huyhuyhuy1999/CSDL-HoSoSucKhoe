# Tài liệu đồ án

**Đề tài:** Xây dựng cơ sở dữ liệu quản lý hồ sơ sức khỏe và lịch sử theo dõi chỉ số sức khỏe.

Mỗi phần tương ứng với một thành viên trong [bảng phân công](Phan_cong_do_an_CSDL_quan_ly_ho_so_suc_khoe.docx). Bản Word của từng phần nằm trong [`word/`](word); [`word/00_toan_bo_tai_lieu.docx`](word/00_toan_bo_tai_lieu.docx) gộp cả 12 phần kèm mục lục.

| Phần | Nội dung | Tài liệu | Word | Script liên quan |
|:---:|---|---|---|---|
| 1 | Phân tích yêu cầu và đặc tả hệ thống | [01_phan_tich_yeu_cau.md](01_phan_tich_yeu_cau.md) | [docx](word/01_phan_tich_yeu_cau.docx) | — |
| 2 | Use Case và phân tích nghiệp vụ | [02_use_case.md](02_use_case.md) | [docx](word/02_use_case.docx) | — |
| 3 | Thiết kế ERD | [03_erd.md](03_erd.md) | [docx](word/03_erd.docx) | `01_tao_bang.sql` |
| 4 | Chuẩn hóa và mô hình quan hệ | [04_chuan_hoa.md](04_chuan_hoa.md) | [docx](word/04_chuan_hoa.docx) | `01_tao_bang.sql` |
| 5 | Quản lý người dùng | [05_nguoi_dung.md](05_nguoi_dung.md) | [docx](word/05_nguoi_dung.docx) | `04_nguoi_dung.sql` |
| 6 | Quản lý hồ sơ sức khỏe | [06_ho_so_suc_khoe.md](06_ho_so_suc_khoe.md) | [docx](word/06_ho_so_suc_khoe.docx) | `05_ho_so_suc_khoe.sql` |
| 7 | Quản lý chỉ số sức khỏe | [07_chi_so_suc_khoe.md](07_chi_so_suc_khoe.md) | [docx](word/07_chi_so_suc_khoe.docx) | `06_chi_so.sql` |
| 8 | Quản lý lần đo và lịch sử | [08_lan_do_lich_su.md](08_lan_do_lich_su.md) | [docx](word/08_lan_do_lich_su.docx) | `07_lan_do.sql` |
| 9 | Quản lý thiết bị và nguồn dữ liệu | [09_thiet_bi.md](09_thiet_bi.md) | [docx](word/09_thiet_bi.docx) | `08_thiet_bi.sql` |
| 10 | Quản lý cảnh báo | [10_canh_bao.md](10_canh_bao.md) | [docx](word/10_canh_bao.docx) | `02_trigger.sql`, `09_canh_bao.sql` |
| 11 | SQL nâng cao và thống kê | [11_sql_nang_cao.md](11_sql_nang_cao.md) | [docx](word/11_sql_nang_cao.docx) | `10_thong_ke.sql` |
| 12 | Giao diện và kiểm thử | [12_kiem_thu.md](12_kiem_thu.md) | [docx](word/12_kiem_thu.docx) | `11_kiem_thu.sql`, `test/` |

Các script nằm trong [`sql/sqlserver/`](../sql/sqlserver).

## Sơ đồ

Nguồn PlantUML (`.puml`) và ảnh (`.png`) trong [`so_do/`](so_do):

| Sơ đồ | File | Dùng ở |
|---|---|---|
| Use Case tổng quát | `use_case` | Phần 2 |
| Activity: ghi nhận lần đo | `activity_ghi_nhan_lan_do` | Phần 2 |
| Activity: quản lý hồ sơ | `activity_quan_ly_ho_so` | Phần 2 |
| Activity: xem lịch sử và thống kê | `activity_lich_su_thong_ke` | Phần 2 |
| Activity: xử lý cảnh báo | `activity_xu_ly_canh_bao` | Phần 2 |
| ERD ký hiệu Chen | `erd_chen` | Phần 3 |
| Mô hình quan hệ | `mo_hinh_quan_he` | Phần 4, Phần 11 |

## Cách tài liệu được tạo ra

Các file `NN_*.md` trong thư mục này **không sửa trực tiếp**: chúng được sinh từ bản mẫu trong [`tool/tai_lieu/`](../tool/tai_lieu) bằng `tool/sinh_tai_lieu.py`. Bản mẫu là Markdown thường, thêm các chỉ thị:

| Chỉ thị | Được thay bằng |
|---|---|
| `{{BANG: TÊN_BẢNG}}` | Cấu trúc bảng và ràng buộc, đọc từ danh mục hệ thống của SQL Server |
| `{{SQL: tên_file.sql}}` | Từng mục của script kèm kết quả chạy thật |
| `{{TRUYVAN: SELECT …}}` | Kết quả của một câu truy vấn |
| `{{KIEMTHU}}` | Bảng kết quả của `11_kiem_thu.sql` |
| `{{DOICHIEU}}` | Bảng đối chiếu SQL Server với SQLite |

Nhờ vậy câu lệnh, cấu trúc bảng và kết quả trong tài liệu luôn khớp với script. Quy trình cập nhật:

```bash
tool/sqlserver.sh start
```

```bash
tool/sqlserver.sh run
```

```bash
python3 tool/sinh_tai_lieu.py
```

```bash
tool/xuat_tai_lieu.sh
```

## Ảnh chụp màn hình

Thư mục [`screenshots/`](screenshots) chứa ảnh mọi màn hình của ứng dụng, chụp tự động bằng `flutter test tool/chup_man_hinh_test.dart`.
