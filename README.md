# Hồ Sơ Sức Khỏe

Đồ án Cơ sở dữ liệu **"Xây dựng cơ sở dữ liệu quản lý hồ sơ sức khỏe và lịch sử theo dõi chỉ số sức khỏe"**. Kho mã này chứa toàn bộ sản phẩm của 12 phần việc trong [bảng phân công](docs/Phan_cong_do_an_CSDL_quan_ly_ho_so_suc_khoe.docx):

| Sản phẩm | Vị trí |
|---|---|
| Tài liệu phân tích, thiết kế, mô tả từng module và kết quả kiểm thử (12 phần, Markdown và Word) | [`docs/`](docs/README.md) |
| Bộ script SQL Server: tạo bảng, trigger, dữ liệu mẫu, CRUD, truy vấn, thống kê, kiểm thử | [`sql/sqlserver/`](sql/sqlserver) |
| Bản SQLite tương đương, chạy bên trong ứng dụng | [`sql/sqlite/`](sql/sqlite) |
| Ứng dụng Flutter (iOS và Android) dùng cơ sở dữ liệu SQLite nhúng | [`lib/`](lib) |

| Tổng quan | Hồ sơ | Chi tiết lần đo | Thống kê |
|---|---|---|---|
| ![Tổng quan](docs/screenshots/01_tong_quan.png) | ![Chi tiết hồ sơ](docs/screenshots/05_ho_so_chi_so_xu_huong.png) | ![Chi tiết lần đo](docs/screenshots/10_lan_do_chi_tiet.png) | ![Thống kê](docs/screenshots/14_thong_ke_bieu_do.png) |

Toàn bộ ảnh chụp (kể cả giao diện tối) nằm trong [docs/screenshots](docs/screenshots).

## Cơ sở dữ liệu

Bảy bảng, đạt chuẩn 3NF:

![Mô hình quan hệ](docs/so_do/mo_hinh_quan_he.png)

- **Ràng buộc đặt tại cơ sở dữ liệu:** khóa chính, khóa ngoại, duy nhất, `CHECK`; mọi ràng buộc đều có tên.
- **Cảnh báo do trigger tạo:** khi một giá trị đo nằm ngoài khoảng bình thường, trigger tự chèn một dòng vào `CANH_BAO`. Ngưỡng nằm trong bảng `LOAI_CHI_SO`, không viết cứng trong mã.
- **Dữ liệu mẫu:** 12 người dùng, 6 thiết bị, 5 loại chỉ số, 265 lần đo, 1110 giá trị đo trong 30 ngày; 108 cảnh báo do trigger sinh ra.

### Chạy script trên SQL Server

Mở lần lượt các file trong `sql/sqlserver/` theo thứ tự số (`00` → `11`) bằng SSMS hoặc Azure Data Studio. Script chạy lại nhiều lần được: `00_tao_csdl.sql` xóa và tạo lại cơ sở dữ liệu `QuanLyHoSoSucKhoe`.

| File | Phần | Nội dung |
|---|---|---|
| `00_tao_csdl.sql`, `01_tao_bang.sql` | 3, 4 | Tạo cơ sở dữ liệu, 7 bảng, ràng buộc, chỉ mục |
| `02_trigger.sql` | 6, 10 | Trigger cảnh báo và trigger ngày cập nhật hồ sơ |
| `03_du_lieu_mau.sql` | 5 – 10 | Dữ liệu mẫu (sinh bằng `tool/sinh_du_lieu_mau.dart`) |
| `04_nguoi_dung.sql` | 5 | CRUD, tìm theo tên (kể cả không dấu), giới tính, độ tuổi |
| `05_ho_so_suc_khoe.sql` | 6 | CRUD, hồ sơ theo người dùng, BMI |
| `06_chi_so.sql` | 7 | Danh mục chỉ số, giá trị đo, đánh giá theo ngưỡng |
| `07_lan_do.sql` | 8 | CRUD, lịch sử theo người, ngày, tháng, khoảng thời gian |
| `08_thiet_bi.sql` | 9 | CRUD, tìm kiếm và lọc thiết bị, nguồn dữ liệu |
| `09_canh_bao.sql` | 10 | Quy tắc ngưỡng, minh họa trigger, truy vấn cảnh báo |
| `10_thong_ke.sql` | 11 | FUNCTION, VIEW, PROCEDURE, JOIN, GROUP BY, HAVING, subquery, báo cáo |
| `11_kiem_thu.sql` | 12 | 85 ca kiểm thử, in ĐẠT / KHÔNG ĐẠT cho từng ca |

Không có sẵn SQL Server? Chạy trong Docker (cần `colima` và `docker`; trên máy Apple Silicon cần thêm Rosetta):

```bash
tool/sqlserver.sh start
```

```bash
tool/sqlserver.sh run
```

Lệnh thứ hai tạo lại cơ sở dữ liệu và chạy mọi script; kết thúc bằng bảng kết quả kiểm thử.

### SQLite trong ứng dụng

Ứng dụng không cần máy chủ: lần mở đầu tiên, nó tạo một file SQLite từ các script trong `sql/sqlite/` (cùng cấu trúc, cùng trigger, cùng dữ liệu mẫu), rồi dịch mốc thời gian của dữ liệu mẫu về hiện tại để màn hình Tổng quan luôn có số liệu. Nút **Cơ sở dữ liệu** ở Tổng quan cho xem số dòng từng bảng và đặt lại dữ liệu mẫu.

SQLite không có `PROCEDURE` và `FUNCTION` viết bằng SQL, nên phần đó nằm ở các lớp `Sqlite*Repository`. Hai hệ được đối chiếu tự động:

```bash
tool/doi_chieu_hai_he.sh
```

## Tài liệu

Mục lục đầy đủ ở [`docs/README.md`](docs/README.md). Mỗi phần có bản Markdown trong `docs/` và bản Word trong `docs/word/`; file `docs/word/00_toan_bo_tai_lieu.docx` gộp cả 12 phần kèm mục lục.

Tài liệu của Phần 5 – 12 được **sinh từ chính các script**: mỗi câu lệnh đi kèm kết quả chạy thật trên SQL Server. Phần 1, 3 và 4 cũng lấy bảng ngưỡng, danh sách khóa và từ điển dữ liệu trực tiếp từ cơ sở dữ liệu. Sau khi sửa script hoặc bản mẫu trong `tool/tai_lieu/`:

```bash
python3 tool/sinh_tai_lieu.py
```

```bash
tool/xuat_tai_lieu.sh
```

## Ứng dụng

| Màn hình | Nội dung |
|---|---|
| Tổng quan | Hoạt động hôm nay, số hồ sơ / lần đo / cảnh báo / thiết bị, trung bình 7 ngày, cảnh báo và lần đo gần đây |
| Danh sách hồ sơ | Tìm theo họ tên (không phân biệt dấu), lọc theo giới tính và nhóm tuổi |
| Chi tiết hồ sơ | Thông tin cá nhân, chiều cao / cân nặng / BMI / nhóm máu, tiền sử bệnh, dị ứng, chỉ số mới nhất, biểu đồ xu hướng |
| Lịch sử đo | Lọc theo người, khoảng thời gian (hôm nay, 7 ngày, tháng, tùy chọn) và nguồn dữ liệu |
| Chi tiết lần đo | Từng chỉ số kèm đánh giá và thanh ngưỡng, cảnh báo liên quan |
| Cảnh báo | Lọc theo mức độ / chưa xem, đánh dấu đã xem |
| Thống kê | Diễn biến chỉ số, số lần đo theo ngày, phân loại kết quả, bảng TB / thấp nhất / cao nhất, xếp hạng cảnh báo |
| Thiết bị | Danh sách thiết bị mô phỏng và trạng thái |
| Form | Thêm / sửa hồ sơ, thêm lần đo — có kiểm tra dữ liệu nhập |

### Chạy

Cần Flutter 3.47 trở lên (Dart 3.13).

```bash
flutter pub get
```

```bash
flutter run
```

Mở bằng Xcode: `ios/Runner.xcworkspace`. Để chạy trên iPhone thật, chọn Team của bạn ở *Runner → Signing & Capabilities*.

### Build bản phát hành

```bash
tool/build_release.sh
```

Kết quả nằm trong `dist/`:

- `HoSoSucKhoe-<phiên bản>-unsigned.ipa` — bản iOS **chưa ký**. Cài lên iPhone bằng TrollStore, hoặc bằng công cụ tự ký như Sideloadly, AltStore.
- `HoSoSucKhoe-<phiên bản>.apk` — bản Android, ký bằng debug key mặc định của Flutter (cài trực tiếp được, chưa dùng để đưa lên Play Store).

Build riêng từng nền tảng: `tool/build_release.sh ios` hoặc `tool/build_release.sh android`.

### Kiến trúc

Feature-first clean architecture: mỗi tính năng có ba tầng `domain` (entity + interface repository), `data` (repository viết bằng SQL) và `presentation` (Cubit + màn hình).

```
lib/
├── main.dart
├── app/            Widget gốc, khung 5 tab, chế độ sáng/tối
├── core/
│   ├── database/   Mở SQLite, chạy script, đổi lỗi ràng buộc thành thông báo
│   └── …           Theme, router, DI, widget dùng chung, tiện ích
└── features/
    ├── tong_quan/  ├── ho_so/      ├── lan_do/
    ├── canh_bao/   ├── thong_ke/   └── thiet_bi/
```

| Việc | Thư viện |
|---|---|
| Cơ sở dữ liệu | `sqlite3` |
| Quản lý trạng thái | `flutter_bloc` (Cubit) + `freezed` |
| Điều hướng | `auto_route` |
| Dependency injection | `get_it` + `injectable` |
| Biểu đồ | `fl_chart` |

Giao diện chỉ gọi các interface `*Repository` ở tầng domain; các lớp `Sqlite*Repository` trong `lib/features/*/data/repository_impl/` hiện thực chúng bằng câu lệnh SQL. Repository trả về `Either<Failure, T>`: lỗi ràng buộc của SQLite được đổi thành thông báo tiếng Việt trong `lib/core/database/truy_van.dart`.

Sau khi sửa file có annotation (`@freezed`, `@injectable`, `@RoutePage`), sinh lại mã:

```bash
dart run build_runner build
```

## Kiểm thử

| Đối tượng | Lệnh | Số ca |
|---|---|:---:|
| SQL Server | `tool/sqlserver.sh run` (chạy `11_kiem_thu.sql` ở cuối) | 85 |
| SQLite: ràng buộc, trigger, view | `flutter test test/co_so_du_lieu_test.dart` | 37 |
| Ứng dụng, từ giao diện tới cơ sở dữ liệu | `flutter test test/app_smoke_test.dart` | 7 |
| Hai hệ quản trị cho cùng kết quả | `tool/doi_chieu_hai_he.sh` | 27 phép đối chiếu |

Kết quả chi tiết và danh sách lỗi đã phát hiện: [Phần 12](docs/12_kiem_thu.md).

## Công cụ

| Lệnh | Tác dụng |
|---|---|
| `tool/sqlserver.sh start \| run \| file \| query \| stop` | SQL Server 2022 trong Docker để chạy và kiểm chứng script |
| `dart run tool/sinh_du_lieu_mau.dart` | Sinh lại dữ liệu mẫu cho cả SQL Server lẫn SQLite từ cùng một nguồn |
| `tool/doi_chieu_hai_he.sh` | Đối chiếu SQL Server với SQLite |
| `python3 tool/sinh_tai_lieu.py` | Sinh `docs/*.md` từ bản mẫu, kèm kết quả chạy thật |
| `tool/xuat_tai_lieu.sh` | Dựng sơ đồ PlantUML và xuất tài liệu sang Word |
| `flutter test tool/chup_man_hinh_test.dart` | Chụp lại ảnh mọi màn hình vào `docs/screenshots/` |
| `flutter test tool/tao_icon_test.dart` rồi `dart run flutter_launcher_icons` | Vẽ lại icon app và hình màn hình khởi động |
| `tool/build_release.sh` | Build IPA chưa ký và APK |

## Giới hạn

- Đề tài không dùng thiết bị thật: thiết bị và số đo là dữ liệu mô phỏng.
- Ngưỡng cảnh báo là giá trị tham khảo phục vụ đồ án, không phải khuyến nghị y khoa.
- Ứng dụng không có đăng nhập và phân quyền; chưa có màn hình thêm, sửa, xóa thiết bị và chỉnh ngưỡng chỉ số (hai việc này làm được bằng script SQL).

## Tài nguyên bên thứ ba

- Font [Be Vietnam Pro](https://github.com/bettergui/BeVietnamPro) — SIL Open Font License 1.1 (`assets/fonts/BeVietnamPro-OFL.txt`).
- Icon [Phosphor](https://phosphoricons.com) — MIT (`assets/fonts/phosphor/LICENSE.txt`).
