# Phần 1 — Phân tích yêu cầu và đặc tả hệ thống

**Người phụ trách:** Người 1 · **Đề tài:** Xây dựng cơ sở dữ liệu quản lý hồ sơ sức khỏe và lịch sử theo dõi chỉ số sức khỏe

## 1. Mô tả bài toán

Một phòng khám nhỏ, một trạm y tế hay một gia đình có người lớn tuổi đều cần theo dõi vài chỉ số sức khỏe cơ bản của từng người theo thời gian: nhiệt độ, nhịp tim, nồng độ oxy trong máu (SpO2) và huyết áp. Việc theo dõi này có ba đặc điểm:

- **Lặp lại nhiều lần.** Một người được đo mỗi ngày, có khi vài lần trong ngày. Giá trị của một lần đo đơn lẻ ít ý nghĩa; diễn biến qua nhiều lần đo mới cho thấy tình trạng sức khỏe.
- **Nhiều nguồn dữ liệu.** Số liệu có thể do thiết bị đo ghi nhận hoặc do người nhập tay sau khi đo bằng dụng cụ thông thường.
- **Cần phản ứng kịp thời.** Một giá trị vượt ngưỡng phải được chú ý ngay, không thể chờ ai đó dò lại sổ.

Hiện nay số liệu thường được ghi vào sổ giấy hoặc bảng tính. Cách làm này gặp các vấn đề:

| Vấn đề | Hậu quả |
|---|---|
| Thông tin cá nhân lặp lại ở mỗi dòng số liệu | Sửa số điện thoại phải sửa nhiều nơi, dễ sót và mâu thuẫn |
| Không có kiểm tra khi nhập | Nhịp tim "720" hay ngày đo ở tương lai vẫn được lưu |
| Khó tra cứu theo thời gian | Muốn xem huyết áp của một người trong tháng phải lọc thủ công |
| Không tự phát hiện bất thường | Giá trị nguy hiểm lẫn giữa hàng trăm dòng bình thường |
| Không biết số liệu đến từ đâu | Không phân biệt được số do máy đo với số nhập tay, không truy được thiết bị lỗi |

Bài toán đặt ra là xây dựng một **cơ sở dữ liệu quan hệ** lưu trữ hồ sơ sức khỏe của nhiều người và toàn bộ lịch sử đo của họ, bảo đảm dữ liệu đúng và nhất quán, tra cứu được theo người và theo thời gian, tự động ghi nhận cảnh báo khi có chỉ số bất thường, và cung cấp các số liệu thống kê.

## 2. Lý do chọn đề tài

- **Gần với thực tế.** Thiết bị đo cá nhân (máy đo huyết áp điện tử, máy đo SpO2 kẹp ngón, nhiệt kế hồng ngoại) ngày càng phổ biến; nhu cầu lưu và xem lại số liệu là có thật.
- **Phù hợp với nội dung môn học.** Bài toán có đủ các kiểu quan hệ cần học: 1–1 (người dùng – hồ sơ), 1–N (người dùng – lần đo), N–N (lần đo – loại chỉ số, được tách qua bảng trung gian), cùng các ràng buộc toàn vẹn phong phú.
- **Có dữ liệu theo thời gian.** Lịch sử đo tạo điều kiện luyện tập truy vấn theo ngày, tháng, khoảng thời gian, gom nhóm và thống kê.
- **Có quy tắc nghiệp vụ rõ ràng.** Ngưỡng cảnh báo là quy tắc có thể diễn đạt chính xác và kiểm chứng được, thích hợp để hiện thực bằng trigger.
- **Quy mô vừa sức.** Bảy thực thể đủ để phân công cho 12 thành viên, mỗi người một phần độc lập nhưng phải khớp với nhau.

## 3. Mục tiêu

**Mục tiêu chung:** thiết kế và triển khai một cơ sở dữ liệu đạt chuẩn 3NF để quản lý hồ sơ sức khỏe và lịch sử theo dõi chỉ số sức khỏe, kèm bộ truy vấn và một ứng dụng minh họa.

**Mục tiêu cụ thể:**

1. Lưu trữ thông tin cá nhân và hồ sơ sức khỏe của từng người, không trùng lặp.
2. Lưu trữ mọi lần đo với thời gian, nguồn dữ liệu và giá trị của từng chỉ số.
3. Ngăn dữ liệu sai ngay tại cơ sở dữ liệu bằng khóa chính, khóa ngoại, ràng buộc duy nhất, ràng buộc miền giá trị và trigger.
4. Tự động tạo cảnh báo khi một chỉ số nằm ngoài khoảng bình thường, theo quy tắc ngưỡng có thể điều chỉnh.
5. Đáp ứng các truy vấn tra cứu lịch sử theo người, ngày, tháng và khoảng thời gian.
6. Cung cấp các báo cáo thống kê: số lần đo, số cảnh báo, giá trị trung bình, lớn nhất, nhỏ nhất của từng chỉ số.
7. Có bộ dữ liệu mẫu và bộ ca kiểm thử để chứng minh thiết kế hoạt động đúng.

## 4. Phạm vi

### 4.1 Trong phạm vi

| Nhóm | Nội dung |
|---|---|
| Người dùng | Thông tin cá nhân của người được theo dõi sức khỏe |
| Hồ sơ sức khỏe | Chiều cao, cân nặng, nhóm máu, tiền sử bệnh, dị ứng, ngày cập nhật |
| Chỉ số | Danh mục năm chỉ số: nhiệt độ, nhịp tim, SpO2, huyết áp tâm thu, huyết áp tâm trương; đơn vị đo và các ngưỡng đánh giá |
| Lần đo | Người được đo, thời gian đo, nguồn dữ liệu, giá trị từng chỉ số |
| Thiết bị | Danh sách thiết bị đo, loại, mã định danh, trạng thái |
| Cảnh báo | Cảnh báo phát sinh từ giá trị đo bất thường, mức độ, trạng thái đã xem |
| Thống kê | Các báo cáo tổng hợp từ dữ liệu trên |

### 4.2 Ngoài phạm vi

- **Thiết bị thật.** Đề tài không lắp mạch, không đọc cảm biến và không truyền dữ liệu IoT. Thiết bị và số liệu đo là dữ liệu mô phỏng.
- **Đăng nhập và phân quyền.** Quyền nghiệp vụ của từng đối tượng được mô tả ở mục 5 để định hướng thiết kế, nhưng cơ sở dữ liệu không lưu tài khoản, mật khẩu hay vai trò.
- **Chẩn đoán y khoa.** Hệ thống chỉ so giá trị với ngưỡng; không đưa ra chẩn đoán hay lời khuyên điều trị. Các ngưỡng trong dữ liệu mẫu là giá trị tham khảo phục vụ đồ án.
- **Các nghiệp vụ khám chữa bệnh khác:** lịch hẹn, đơn thuốc, viện phí, bệnh án chi tiết.

## 5. Đối tượng sử dụng và quyền nghiệp vụ

| Đối tượng | Mô tả |
|---|---|
| **Nhân viên y tế** | Người quản lý dữ liệu: lập hồ sơ, quản lý thiết bị, cấu hình ngưỡng, theo dõi cảnh báo của mọi người |
| **Người dùng** | Người được theo dõi sức khỏe (hoặc người nhà): tự nhập số đo, xem lịch sử và cảnh báo của mình |
| **Thiết bị đo (mô phỏng)** | Nguồn phát sinh lần đo tự động; không thao tác nào khác |

Quyền nghiệp vụ (✓ = được thực hiện):

| Nghiệp vụ | Nhân viên y tế | Người dùng | Thiết bị đo |
|---|:---:|:---:|:---:|
| Thêm, sửa, xóa người dùng | ✓ | | |
| Lập và cập nhật hồ sơ sức khỏe | ✓ | | |
| Quản lý thiết bị | ✓ | | |
| Quản lý loại chỉ số và ngưỡng cảnh báo | ✓ | | |
| Ghi nhận lần đo | ✓ | ✓ (của mình) | ✓ |
| Xem lịch sử và chi tiết lần đo | ✓ (mọi người) | ✓ (của mình) | |
| Xem và đánh dấu cảnh báo | ✓ (mọi người) | ✓ (của mình) | |
| Xem thống kê | ✓ | ✓ (của mình) | |

Cảnh báo không do đối tượng nào tạo ra: hệ thống tự tạo khi ghi nhận giá trị đo.

## 6. Yêu cầu chức năng

### 6.1 Quản lý người dùng

| Mã | Yêu cầu |
|---|---|
| YC-01 | Thêm người dùng mới với họ tên, giới tính, ngày sinh; số điện thoại, email, địa chỉ là tùy chọn |
| YC-02 | Sửa thông tin của một người dùng |
| YC-03 | Xóa một người dùng cùng toàn bộ dữ liệu của người đó |
| YC-04 | Xem danh sách người dùng, kèm tuổi tính từ ngày sinh |
| YC-05 | Tìm người dùng theo tên, kể cả khi gõ không dấu |
| YC-06 | Lọc người dùng theo giới tính và theo độ tuổi |

### 6.2 Quản lý hồ sơ sức khỏe

| Mã | Yêu cầu |
|---|---|
| YC-07 | Lập hồ sơ sức khỏe cho một người dùng: chiều cao, cân nặng, nhóm máu, tiền sử bệnh, dị ứng |
| YC-08 | Cập nhật hồ sơ; hệ thống tự ghi nhận thời điểm cập nhật |
| YC-09 | Xem hồ sơ của một người dùng, kèm chỉ số khối cơ thể (BMI) tính từ chiều cao và cân nặng |
| YC-10 | Lọc hồ sơ theo nhóm máu, tiền sử bệnh, dị ứng |

### 6.3 Quản lý chỉ số sức khỏe

| Mã | Yêu cầu |
|---|---|
| YC-11 | Quản lý danh mục loại chỉ số: tên, đơn vị đo |
| YC-12 | Với mỗi loại chỉ số, khai báo khoảng giá trị hợp lệ, khoảng bình thường và khoảng cảnh báo |
| YC-13 | Thêm được loại chỉ số mới (ví dụ đường huyết) mà không phải thay đổi cấu trúc dữ liệu |

### 6.4 Quản lý lần đo và lịch sử

| Mã | Yêu cầu |
|---|---|
| YC-14 | Ghi nhận một lần đo: người được đo, thời gian, nguồn dữ liệu và giá trị của một hoặc nhiều chỉ số |
| YC-15 | Một lần đo không bắt buộc đủ cả năm chỉ số (máy đo SpO2 chỉ cho nhịp tim và SpO2) |
| YC-16 | Sửa giá trị đo nhập nhầm; xóa một lần đo |
| YC-17 | Xem lịch sử đo của một người, lần mới nhất trước |
| YC-18 | Xem lịch sử theo ngày, theo tháng và theo một khoảng thời gian bất kỳ |
| YC-19 | Xem chi tiết một lần đo: từng chỉ số, đơn vị, đánh giá so với ngưỡng |

### 6.5 Quản lý thiết bị và nguồn dữ liệu

| Mã | Yêu cầu |
|---|---|
| YC-20 | Thêm, sửa, xóa, xem thiết bị: tên, loại, mã định danh, trạng thái, mô tả |
| YC-21 | Chuyển trạng thái thiết bị: hoạt động, bảo trì, ngừng sử dụng |
| YC-22 | Tìm thiết bị theo tên hoặc mã định danh; lọc theo loại và trạng thái |
| YC-23 | Phân biệt lần đo do thiết bị ghi nhận với lần đo nhập thủ công |

### 6.6 Quản lý cảnh báo

| Mã | Yêu cầu |
|---|---|
| YC-24 | Tự động tạo cảnh báo khi một giá trị đo nằm ngoài khoảng bình thường |
| YC-25 | Phân cảnh báo thành hai mức: cần chú ý và nguy hiểm |
| YC-26 | Xem danh sách cảnh báo, mới nhất trước; lọc theo mức độ và trạng thái đã xem |
| YC-27 | Xem cảnh báo theo người và theo khoảng thời gian |
| YC-28 | Đánh dấu một cảnh báo hoặc toàn bộ cảnh báo là đã xem |

### 6.7 Thống kê

| Mã | Yêu cầu |
|---|---|
| YC-29 | Thống kê số lần đo theo người, theo ngày, theo thiết bị |
| YC-30 | Thống kê giá trị trung bình, nhỏ nhất, lớn nhất của từng chỉ số |
| YC-31 | Thống kê số cảnh báo theo người, theo chỉ số, theo mức độ |
| YC-32 | Tổng quan hệ thống: số người dùng, số lần đo, số cảnh báo chưa xem |

## 7. Yêu cầu phi chức năng

| Mã | Nhóm | Yêu cầu | Cách đáp ứng trong thiết kế |
|---|---|---|---|
| PCN-01 | Toàn vẹn dữ liệu | Dữ liệu sai không vào được cơ sở dữ liệu, dù được nhập từ ứng dụng hay bằng câu lệnh SQL trực tiếp | Ràng buộc và trigger đặt tại cơ sở dữ liệu, không chỉ kiểm tra ở giao diện |
| PCN-02 | Nhất quán | Một lần đo và các giá trị của nó được lưu trọn vẹn hoặc không lưu gì | Giao dịch (transaction) |
| PCN-03 | Không dư thừa | Mỗi thông tin chỉ lưu ở một nơi | Chuẩn hóa tới 3NF |
| PCN-04 | Hiệu năng | Tra cứu lịch sử của một người và lọc theo thời gian phải nhanh khi dữ liệu lớn dần | Chỉ mục trên các cột dùng để lọc và sắp xếp |
| PCN-05 | Mở rộng | Thêm loại chỉ số hoặc điều chỉnh ngưỡng không phải sửa cấu trúc bảng hay mã trigger | Ngưỡng là dữ liệu, không viết cứng trong mã |
| PCN-06 | Dễ dùng | Giao diện và thông báo lỗi bằng tiếng Việt; tìm kiếm được khi gõ không dấu | So sánh chuỗi không phân biệt dấu |
| PCN-07 | Dễ bảo trì | Script chia theo module; mọi ràng buộc đều có tên | Quy ước đặt tên `PK_`, `FK_`, `UQ_`, `CK_`, `DF_`, `IX_`, `TRG_` |
| PCN-08 | Kiểm chứng được | Mọi kết quả trong báo cáo có thể tái lập | Dữ liệu mẫu cố định; script chạy lại nhiều lần được; có script kiểm thử |
| PCN-09 | Riêng tư | Dữ liệu sức khỏe là dữ liệu nhạy cảm | Đồ án chỉ dùng dữ liệu giả; việc phân quyền và mã hóa nằm ngoài phạm vi |

Yêu cầu PCN-04 mới được đáp ứng ở mức thiết kế (có chỉ mục phù hợp với các truy vấn chính); đề tài chưa đo hiệu năng trên dữ liệu lớn.

## 8. Dữ liệu cần quản lý

Phần này liệt kê thông tin hệ thống phải lưu, **chưa quyết định cấu trúc bảng**; việc tổ chức thành thực thể và bảng thuộc về Phần 3 và Phần 4.

| Nhóm thông tin | Thông tin cần lưu | Ghi chú |
|---|---|---|
| Người được theo dõi | Họ tên, giới tính, ngày sinh, số điện thoại, email, địa chỉ | Tuổi không lưu mà tính từ ngày sinh |
| Tình trạng sức khỏe nền | Chiều cao, cân nặng, nhóm máu, tiền sử bệnh, dị ứng, thời điểm cập nhật | BMI không lưu mà tính từ chiều cao và cân nặng |
| Loại chỉ số | Tên, đơn vị đo, khoảng giá trị hợp lệ, khoảng bình thường, khoảng cảnh báo | Năm loại ban đầu; có thể bổ sung |
| Lần đo | Ai được đo, đo lúc nào, nguồn dữ liệu, ghi chú | |
| Giá trị đo | Giá trị của từng chỉ số trong một lần đo | Số chỉ số của mỗi lần đo có thể khác nhau |
| Thiết bị | Tên, loại, mã định danh phần cứng, trạng thái, mô tả | Dữ liệu mô phỏng |
| Cảnh báo | Phát sinh từ giá trị đo nào, mức độ, nội dung, thời điểm, đã xem hay chưa | Do hệ thống tạo |

Ước lượng khối lượng: mỗi người đo khoảng 1–2 lần mỗi ngày, mỗi lần 2–5 chỉ số. Với 1000 người, mỗi năm phát sinh khoảng nửa triệu lần đo và hai triệu giá trị đo. Dữ liệu lần đo và giá trị đo vì thế lớn hơn hẳn các nhóm còn lại, và là nơi cần chú ý nhất về chỉ mục.

## 9. Quy tắc nghiệp vụ

| Mã | Quy tắc |
|---|---|
| QT-01 | Mỗi người dùng có tối đa một hồ sơ sức khỏe; mỗi hồ sơ thuộc về đúng một người dùng |
| QT-02 | Một người dùng có thể có nhiều lần đo; mỗi lần đo thuộc về đúng một người dùng |
| QT-03 | Một lần đo gồm ít nhất một chỉ số; mỗi loại chỉ số xuất hiện nhiều nhất một lần trong một lần đo |
| QT-04 | Huyết áp phải được ghi đủ cả tâm thu và tâm trương, và tâm thu phải lớn hơn tâm trương |
| QT-05 | Nguồn dữ liệu của lần đo là "thiết bị" hoặc "thủ công". Lần đo từ thiết bị phải chỉ rõ thiết bị; lần đo thủ công không gắn với thiết bị nào |
| QT-06 | Thời gian đo không được ở tương lai |
| QT-07 | Giá trị đo phải nằm trong khoảng hợp lệ của loại chỉ số; giá trị ngoài khoảng này bị từ chối |
| QT-08 | Giá trị nằm ngoài khoảng bình thường phát sinh một cảnh báo: mức "cần chú ý" nếu còn trong khoảng cảnh báo, mức "nguy hiểm" nếu vượt ra ngoài |
| QT-09 | Mỗi giá trị đo có nhiều nhất một cảnh báo. Khi giá trị được sửa, cảnh báo được đánh giá lại |
| QT-10 | Cảnh báo mới ở trạng thái chưa xem cho đến khi có người đánh dấu đã xem |
| QT-11 | Xóa một người dùng thì hồ sơ, lần đo, giá trị đo và cảnh báo của người đó bị xóa theo |
| QT-12 | Không được xóa thiết bị đã có lần đo; khi không còn dùng, thiết bị được chuyển sang trạng thái "ngừng sử dụng" |
| QT-13 | Không được xóa loại chỉ số đã có giá trị đo |
| QT-14 | Email của người dùng không trùng nhau (người không có email thì không xét); mã định danh của thiết bị không trùng nhau |
| QT-15 | Giới tính nhận một trong: Nam, Nữ, Khác. Nhóm máu nhận một trong tám nhóm theo hệ ABO và Rh |
| QT-16 | Ngày sinh từ năm 1900 và không ở tương lai. Chiều cao từ 30 đến 250 cm; cân nặng từ 1 đến 300 kg |
| QT-17 | Với mỗi loại chỉ số, khoảng bình thường nằm trong khoảng cảnh báo, và khoảng cảnh báo nằm trong khoảng hợp lệ |

Bảng ngưỡng ban đầu của năm chỉ số (giá trị tham khảo cho đồ án):

| TenChiSo | DonViDo | KhoangHopLe | KhoangBinhThuong | KhoangCanhBao |
|---|---|---|---|---|
| Nhiệt độ | °C | 30 – 45 | 36.1 – 37.5 | 35 – 38.5 |
| Nhịp tim | bpm | 20 – 250 | 60 – 100 | 50 – 120 |
| SpO2 | % | 50 – 100 | 95 – 100 | 90 – 100 |
| Huyết áp tâm thu | mmHg | 50 – 260 | 90 – 129 | 85 – 139 |
| Huyết áp tâm trương | mmHg | 30 – 160 | 60 – 84 | 55 – 89 |

## 10. Báo cáo và truy vấn cần đáp ứng

Cột cuối chỉ ra nơi yêu cầu được hiện thực trong bộ script, để đối chiếu giữa phân tích và sản phẩm.

| Mã | Báo cáo / truy vấn | Hiện thực tại |
|---|---|---|
| BC-01 | Danh sách người dùng kèm tuổi; tìm theo tên, lọc theo giới tính và độ tuổi | `04_nguoi_dung.sql`, mục 1.3 và 5 |
| BC-02 | Hồ sơ sức khỏe của một người kèm BMI và phân loại | `05_ho_so_suc_khoe.sql`, mục 1.2 và 1.3 |
| BC-03 | Lịch sử đo của một người, mới nhất trước | `07_lan_do.sql`, mục 5.1 |
| BC-04 | Các lần đo trong một ngày, một tháng, một khoảng thời gian | `07_lan_do.sql`, mục 5.2 – 5.4 |
| BC-05 | Chi tiết một lần đo kèm đánh giá từng chỉ số | `06_chi_so.sql`, mục 2.2 |
| BC-06 | Giá trị mới nhất của từng chỉ số đối với một người | `06_chi_so.sql`, mục 3.4 |
| BC-07 | Cảnh báo chưa xem, mức nguy hiểm trước | `09_canh_bao.sql`, mục 3.2 |
| BC-08 | Cảnh báo của một người; cảnh báo trong một khoảng thời gian | `09_canh_bao.sql`, mục 4.1 và 4.2 |
| BC-09 | Số lần đo của từng người; số lần đo theo ngày | `10_thong_ke.sql`, mục E.1 và H.4 |
| BC-10 | Trung bình, nhỏ nhất, lớn nhất của từng chỉ số | `10_thong_ke.sql`, mục E.2 |
| BC-11 | Số cảnh báo theo người và theo chỉ số, tách theo mức độ | `09_canh_bao.sql`, mục 4.3 và 4.4 |
| BC-12 | Những người có nhiều cảnh báo nhất | `10_thong_ke.sql`, mục H.6 |
| BC-13 | Số lần đo và lần đo gần nhất của từng thiết bị | `08_thiet_bi.sql`, mục 6.1 |
| BC-14 | Diễn biến trung bình theo ngày của một chỉ số (để vẽ biểu đồ) | `10_thong_ke.sql`, mục H.5 |
| BC-15 | Tổng quan hệ thống trên một dòng | `10_thong_ke.sql`, mục H.1 |

## 11. Thuật ngữ

| Thuật ngữ | Giải thích |
|---|---|
| Người dùng | Người được theo dõi sức khỏe, không phải tài khoản đăng nhập |
| Hồ sơ sức khỏe | Thông tin sức khỏe nền, ít thay đổi, của một người |
| Lần đo | Một lần ghi nhận chỉ số của một người tại một thời điểm |
| Chỉ số | Một đại lượng đo được: nhiệt độ, nhịp tim, SpO2, huyết áp |
| SpO2 | Độ bão hòa oxy trong máu ngoại vi, tính bằng phần trăm |
| Huyết áp tâm thu / tâm trương | Áp lực máu khi tim co bóp / khi tim giãn, tính bằng mmHg |
| Khoảng hợp lệ | Khoảng giá trị có thể xảy ra về mặt sinh lý; ngoài khoảng này coi là nhập sai |
| Khoảng bình thường | Khoảng giá trị không cần chú ý |
| Khoảng cảnh báo | Khoảng mà nếu vượt ra ngoài thì cảnh báo ở mức nguy hiểm |
| BMI | Chỉ số khối cơ thể = cân nặng (kg) chia cho bình phương chiều cao (m) |
