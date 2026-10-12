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

### A. FUNCTION

#### A.1 Tuổi tính đến một ngày (NULL = hôm nay)

```sql
CREATE OR ALTER FUNCTION dbo.FN_TinhTuoi (@NgaySinh DATE, @TinhDenNgay DATE)
RETURNS INT
AS
BEGIN
    DECLARE @Ngay DATE = ISNULL(@TinhDenNgay, CAST(GETDATE() AS DATE));

    -- DATEDIFF(YEAR) chỉ trừ số năm; bớt 1 nếu chưa tới sinh nhật trong năm đó.
    RETURN DATEDIFF(YEAR, @NgaySinh, @Ngay)
         - CASE WHEN DATEADD(YEAR, DATEDIFF(YEAR, @NgaySinh, @Ngay), @NgaySinh) > @Ngay
                THEN 1 ELSE 0 END;
END;
```

#### A.2 Chỉ số khối cơ thể: cân nặng (kg) chia bình phương chiều cao (m)

```sql
CREATE OR ALTER FUNCTION dbo.FN_TinhBMI (@ChieuCao DECIMAL(5,1), @CanNang DECIMAL(5,1))
RETURNS DECIMAL(4,1)
AS
BEGIN
    IF @ChieuCao IS NULL OR @ChieuCao <= 0 RETURN NULL;
    RETURN CAST(@CanNang / POWER(@ChieuCao / 100.0, 2) AS DECIMAL(4,1));
END;
```

#### A.3 Phân loại BMI theo thang dành cho người châu Á

```sql
CREATE OR ALTER FUNCTION dbo.FN_PhanLoaiBMI (@BMI DECIMAL(4,1))
RETURNS NVARCHAR(20)
AS
BEGIN
    RETURN CASE
        WHEN @BMI IS NULL THEN NULL
        WHEN @BMI < 18.5  THEN N'Thiếu cân'
        WHEN @BMI < 23    THEN N'Bình thường'
        WHEN @BMI < 25    THEN N'Thừa cân'
        ELSE N'Béo phì'
    END;
END;
```

#### A.4 Mức độ của một giá trị đo theo ngưỡng của chỉ số

```sql
CREATE OR ALTER FUNCTION dbo.FN_DanhGiaChiSo (@MaLoaiChiSo INT, @GiaTri DECIMAL(6,1))
RETURNS NVARCHAR(20)
AS
BEGIN
    DECLARE @MucDo NVARCHAR(20);

    SELECT @MucDo = CASE
        WHEN @GiaTri BETWEEN BinhThuongMin AND BinhThuongMax THEN N'Bình thường'
        WHEN @GiaTri BETWEEN CanhBaoMin    AND CanhBaoMax    THEN N'Cần chú ý'
        ELSE N'Nguy hiểm'
    END
    FROM LOAI_CHI_SO
    WHERE MaLoaiChiSo = @MaLoaiChiSo;

    RETURN @MucDo;
END;
```

#### A.5 Hàm trả về bảng: giá trị mới nhất của từng chỉ số đối với một người

```sql
CREATE OR ALTER FUNCTION dbo.FN_ChiSoMoiNhat (@MaNguoiDung INT)
RETURNS TABLE
AS
RETURN
    SELECT t.MaLoaiChiSo, t.TenChiSo, t.GiaTri, t.DonViDo, t.ThoiGianDo,
           dbo.FN_DanhGiaChiSo(t.MaLoaiChiSo, t.GiaTri) AS MucDo
    FROM (
        SELECT
            l.MaLoaiChiSo, l.TenChiSo, ct.GiaTri, l.DonViDo, ld.ThoiGianDo,
            ROW_NUMBER() OVER (PARTITION BY ct.MaLoaiChiSo
                               ORDER BY ld.ThoiGianDo DESC) AS ThuTu
        FROM CHI_TIET_LAN_DO AS ct
        JOIN LAN_DO          AS ld ON ld.MaLanDo = ct.MaLanDo
        JOIN LOAI_CHI_SO     AS l  ON l.MaLoaiChiSo = ct.MaLoaiChiSo
        WHERE ld.MaNguoiDung = @MaNguoiDung
    ) AS t
    WHERE t.ThuTu = 1;
```

#### A.6 Dùng thử các hàm

```sql
SELECT HoTen, NgaySinh,
       dbo.FN_TinhTuoi(NgaySinh, '2026-10-10') AS TuoiNgay10Thang10
FROM NGUOI_DUNG
WHERE MaNguoiDung IN (1, 9, 12);

SELECT dbo.FN_TinhBMI(168, 72)                          AS BMI,
       dbo.FN_PhanLoaiBMI(dbo.FN_TinhBMI(168, 72))      AS PhanLoai,
       dbo.FN_DanhGiaChiSo(2, 126)                      AS NhipTim126,
       dbo.FN_DanhGiaChiSo(3, 93)                       AS SpO2_93;

SELECT TenChiSo, GiaTri, DonViDo, ThoiGianDo, MucDo
FROM dbo.FN_ChiSoMoiNhat(7)
ORDER BY MaLoaiChiSo;
```

**Kết quả:**

| HoTen | NgaySinh | TuoiNgay10Thang10 |
|---|---|---|
| Nguyễn Văn An | 1968-03-12 | 58 |
| Đỗ Thanh Long | 2012-08-06 | 14 |
| Lý Thị Oanh | 2005-10-10 | 21 |

| BMI | PhanLoai | NhipTim126 | SpO2_93 |
|---|---|---|---|
| 25.5 | Béo phì | Nguy hiểm | Cần chú ý |

| TenChiSo | GiaTri | DonViDo | ThoiGianDo | MucDo |
|---|---|---|---|---|
| Nhiệt độ | 36.9 | °C | 2026-10-10 18:12:00 | Bình thường |
| Nhịp tim | 96.0 | bpm | 2026-10-10 18:21:00 | Bình thường |
| SpO2 | 95.0 | % | 2026-10-10 18:21:00 | Bình thường |
| Huyết áp tâm thu | 148.0 | mmHg | 2026-10-10 18:12:00 | Nguy hiểm |
| Huyết áp tâm trương | 92.0 | mmHg | 2026-10-10 18:12:00 | Nguy hiểm |

### B. VIEW

#### B.1 Hồ sơ tổng hợp: người dùng + hồ sơ + tuổi + BMI + số liệu đo

```sql
CREATE OR ALTER VIEW V_HO_SO_TONG_HOP
AS
SELECT
    nd.MaNguoiDung,
    nd.HoTen,
    nd.GioiTinh,
    nd.NgaySinh,
    dbo.FN_TinhTuoi(nd.NgaySinh, NULL)                         AS Tuoi,
    nd.SoDienThoai,
    nd.Email,
    nd.DiaChi,
    hs.MaHoSo,
    hs.ChieuCao,
    hs.CanNang,
    dbo.FN_TinhBMI(hs.ChieuCao, hs.CanNang)                    AS BMI,
    dbo.FN_PhanLoaiBMI(dbo.FN_TinhBMI(hs.ChieuCao, hs.CanNang)) AS PhanLoaiBMI,
    hs.NhomMau,
    hs.TienSuBenh,
    hs.DiUng,
    hs.NgayCapNhat,
    (SELECT COUNT(*) FROM LAN_DO AS ld
      WHERE ld.MaNguoiDung = nd.MaNguoiDung)                   AS SoLanDo,
    (SELECT MAX(ld.ThoiGianDo) FROM LAN_DO AS ld
      WHERE ld.MaNguoiDung = nd.MaNguoiDung)                   AS LanDoGanNhat,
    (SELECT COUNT(*) FROM CANH_BAO AS cb
       JOIN LAN_DO AS ld ON ld.MaLanDo = cb.MaLanDo
      WHERE ld.MaNguoiDung = nd.MaNguoiDung AND cb.DaXem = 0)  AS SoCanhBaoChuaXem
FROM NGUOI_DUNG          AS nd
LEFT JOIN HO_SO_SUC_KHOE AS hs ON hs.MaNguoiDung = nd.MaNguoiDung;
```

#### B.2 Từng giá trị đo kèm người, thời gian, chỉ số và mức độ đánh giá

```sql
CREATE OR ALTER VIEW V_CHI_TIET_DANH_GIA
AS
SELECT
    ct.MaLanDo,
    ld.MaNguoiDung,
    nd.HoTen,
    ld.ThoiGianDo,
    ct.MaLoaiChiSo,
    l.KyHieu,
    l.TenChiSo,
    ct.GiaTri,
    l.DonViDo,
    CASE
        WHEN ct.GiaTri BETWEEN l.BinhThuongMin AND l.BinhThuongMax THEN N'Bình thường'
        WHEN ct.GiaTri BETWEEN l.CanhBaoMin    AND l.CanhBaoMax    THEN N'Cần chú ý'
        ELSE N'Nguy hiểm'
    END AS MucDo,
    -- Thứ hạng của mức độ, để lấy mức nặng nhất bằng MAX().
    CASE
        WHEN ct.GiaTri BETWEEN l.BinhThuongMin AND l.BinhThuongMax THEN 0
        WHEN ct.GiaTri BETWEEN l.CanhBaoMin    AND l.CanhBaoMax    THEN 1
        ELSE 2
    END AS CapDo
FROM CHI_TIET_LAN_DO AS ct
JOIN LAN_DO          AS ld ON ld.MaLanDo = ct.MaLanDo
JOIN NGUOI_DUNG      AS nd ON nd.MaNguoiDung = ld.MaNguoiDung
JOIN LOAI_CHI_SO     AS l  ON l.MaLoaiChiSo = ct.MaLoaiChiSo;
```

#### B.3 Mỗi lần đo một dòng: năm chỉ số thành năm cột, kèm mức độ nặng nhất

```sql
CREATE OR ALTER VIEW V_LAN_DO_TONG_HOP
AS
SELECT
    ld.MaLanDo,
    ld.MaNguoiDung,
    nd.HoTen,
    ld.ThoiGianDo,
    ld.NguonDuLieu,
    ld.MaThietBi,
    tb.TenThietBi,
    ld.GhiChu,
    MAX(CASE WHEN ct.KyHieu = 'NHIET_DO'      THEN ct.GiaTri END) AS NhietDo,
    MAX(CASE WHEN ct.KyHieu = 'NHIP_TIM'      THEN ct.GiaTri END) AS NhipTim,
    MAX(CASE WHEN ct.KyHieu = 'SPO2'          THEN ct.GiaTri END) AS SpO2,
    MAX(CASE WHEN ct.KyHieu = 'HA_TAM_THU'    THEN ct.GiaTri END) AS HuyetApTamThu,
    MAX(CASE WHEN ct.KyHieu = 'HA_TAM_TRUONG' THEN ct.GiaTri END) AS HuyetApTamTruong,
    COUNT(ct.MaLoaiChiSo)                                         AS SoChiSo,
    SUM(CASE WHEN ct.CapDo > 0 THEN 1 ELSE 0 END)                 AS SoChiSoBatThuong,
    CASE MAX(ISNULL(ct.CapDo, 0))
        WHEN 2 THEN N'Nguy hiểm'
        WHEN 1 THEN N'Cần chú ý'
        ELSE N'Bình thường'
    END                                                           AS MucDo
FROM LAN_DO                   AS ld
JOIN NGUOI_DUNG               AS nd ON nd.MaNguoiDung = ld.MaNguoiDung
LEFT JOIN THIET_BI            AS tb ON tb.MaThietBi = ld.MaThietBi
LEFT JOIN V_CHI_TIET_DANH_GIA AS ct ON ct.MaLanDo = ld.MaLanDo
GROUP BY ld.MaLanDo, ld.MaNguoiDung, nd.HoTen, ld.ThoiGianDo, ld.NguonDuLieu,
         ld.MaThietBi, tb.TenThietBi, ld.GhiChu;
```

#### B.4 Cảnh báo kèm người được đo, chỉ số và giá trị đo

```sql
CREATE OR ALTER VIEW V_CANH_BAO_CHI_TIET
AS
SELECT
    cb.MaCanhBao,
    cb.MaLanDo,
    ld.MaNguoiDung,
    nd.HoTen,
    cb.MaLoaiChiSo,
    l.TenChiSo,
    ct.GiaTri,
    l.DonViDo,
    cb.MucDo,
    cb.NoiDung,
    cb.ThoiGianTao,
    cb.DaXem
FROM CANH_BAO        AS cb
JOIN CHI_TIET_LAN_DO AS ct ON ct.MaLanDo = cb.MaLanDo AND ct.MaLoaiChiSo = cb.MaLoaiChiSo
JOIN LAN_DO          AS ld ON ld.MaLanDo = cb.MaLanDo
JOIN NGUOI_DUNG      AS nd ON nd.MaNguoiDung = ld.MaNguoiDung
JOIN LOAI_CHI_SO     AS l  ON l.MaLoaiChiSo = cb.MaLoaiChiSo;
```

#### B.5 Dùng thử các view

```sql
SELECT HoTen, Tuoi, BMI, PhanLoaiBMI, NhomMau, SoLanDo, SoCanhBaoChuaXem
FROM V_HO_SO_TONG_HOP
ORDER BY SoLanDo DESC;

SELECT TOP (8) MaLanDo, HoTen, ThoiGianDo, NhietDo, NhipTim, SpO2,
               HuyetApTamThu, HuyetApTamTruong, MucDo
FROM V_LAN_DO_TONG_HOP
ORDER BY ThoiGianDo DESC;

SELECT TOP (5) HoTen, TenChiSo, GiaTri, DonViDo, MucDo, ThoiGianTao
FROM V_CANH_BAO_CHI_TIET
WHERE DaXem = 0
ORDER BY ThoiGianTao DESC, MaCanhBao DESC;
```

**Kết quả:**

| HoTen | Tuoi | BMI | PhanLoaiBMI | NhomMau | SoLanDo | SoCanhBaoChuaXem |
|---|---|---|---|---|---|---|
| Đặng Quốc Huy | 76 | 23.1 | Thừa cân | B+ | 35 | 6 |
| Phạm Thị Dung | 68 | 21.6 | Bình thường | AB+ | 33 | 3 |
| Nguyễn Văn An | 58 | 25.5 | Béo phì | O+ | 30 | 1 |
| Ngô Thị Mai | 62 | 27.8 | Béo phì | B- | 29 | 2 |
| Trần Thị Bích | 51 | 23.8 | Thừa cân | A+ | 28 | 0 |
| Vũ Thị Giang | 43 | 21.1 | Bình thường | A- | 19 | 0 |
| Dương Văn Nam | 47 | 29.4 | Béo phì | AB- | 18 | 1 |
| Bùi Thị Lan | 30 | 19.6 | Bình thường | O+ | 17 | 0 |
| Đỗ Thanh Long | 14 | 18.3 | Thiếu cân | A+ | 17 | 4 |
| Lý Thị Oanh | 21 | 19.8 | Bình thường | O+ | 15 | 0 |
| Lê Hoàng Cường | 35 | 22.5 | Bình thường | B+ | 12 | 0 |
| Hoàng Minh Đức | 25 | 23.4 | Thừa cân | O- | 12 | 0 |

| MaLanDo | HoTen | ThoiGianDo | NhietDo | NhipTim | SpO2 | HuyetApTamThu | HuyetApTamTruong | MucDo |
|---|---|---|---|---|---|---|---|---|
| 265 | Nguyễn Văn An | 2026-10-10 21:22:00 | 36.8 | 83.0 | 97.0 | 125.0 | 82.0 | Bình thường |
| 264 | Ngô Thị Mai | 2026-10-10 19:51:00 | 36.7 | 65.0 | 98.0 | 127.0 | 76.0 | Bình thường |
| 263 | Bùi Thị Lan | 2026-10-10 19:42:00 | 36.5 | 71.0 | 97.0 | 107.0 | 69.0 | Bình thường |
| 262 | Phạm Thị Dung | 2026-10-10 18:35:00 | 37.1 | 76.0 | 96.0 | 131.0 | 80.0 | Cần chú ý |
| 261 | Đặng Quốc Huy | 2026-10-10 18:21:00 | *NULL* | 96.0 | 95.0 | *NULL* | *NULL* | Bình thường |
| 260 | Đặng Quốc Huy | 2026-10-10 18:12:00 | 36.9 | 126.0 | 95.0 | 148.0 | 92.0 | Nguy hiểm |
| 259 | Phạm Thị Dung | 2026-10-10 17:18:00 | *NULL* | 88.0 | 92.0 | *NULL* | *NULL* | Cần chú ý |
| 258 | Lê Hoàng Cường | 2026-10-10 15:55:00 | 36.6 | 66.0 | 99.0 | 117.0 | 75.0 | Bình thường |

| HoTen | TenChiSo | GiaTri | DonViDo | MucDo | ThoiGianTao |
|---|---|---|---|---|---|
| Phạm Thị Dung | Huyết áp tâm thu | 131.0 | mmHg | Cần chú ý | 2026-10-10 18:35:00 |
| Đặng Quốc Huy | Huyết áp tâm trương | 92.0 | mmHg | Nguy hiểm | 2026-10-10 18:12:00 |
| Đặng Quốc Huy | Huyết áp tâm thu | 148.0 | mmHg | Nguy hiểm | 2026-10-10 18:12:00 |
| Đặng Quốc Huy | Nhịp tim | 126.0 | bpm | Nguy hiểm | 2026-10-10 18:12:00 |
| Phạm Thị Dung | SpO2 | 92.0 | % | Cần chú ý | 2026-10-10 17:18:00 |

### C. PROCEDURE

#### C.1 Thêm một lần đo cùng các chỉ số trong MỘT giao dịch

Chỉ số nào không đo thì truyền NULL. Có @MaThietBi thì nguồn là "Thiết bị", không có thì là "Thủ công". Cảnh báo do trigger tự tạo.

```sql
CREATE OR ALTER PROCEDURE SP_ThemLanDo
    @MaNguoiDung      INT,
    @MaThietBi        INT           = NULL,
    @ThoiGianDo       DATETIME2(0)  = NULL,
    @NhietDo          DECIMAL(6,1)  = NULL,
    @NhipTim          DECIMAL(6,1)  = NULL,
    @SpO2             DECIMAL(6,1)  = NULL,
    @HuyetApTamThu    DECIMAL(6,1)  = NULL,
    @HuyetApTamTruong DECIMAL(6,1)  = NULL,
    @GhiChu           NVARCHAR(300) = NULL,
    @MaLanDo          INT           = NULL OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    -- Kiểm tra các quy tắc nghiệp vụ mà ràng buộc trên bảng không diễn đạt được.
    IF COALESCE(@NhietDo, @NhipTim, @SpO2, @HuyetApTamThu, @HuyetApTamTruong) IS NULL
        THROW 50002, N'Một lần đo phải có ít nhất một chỉ số.', 1;

    IF (@HuyetApTamThu IS NULL AND @HuyetApTamTruong IS NOT NULL)
       OR (@HuyetApTamThu IS NOT NULL AND @HuyetApTamTruong IS NULL)
        THROW 50003, N'Huyết áp phải nhập đủ cả tâm thu và tâm trương.', 1;

    IF @HuyetApTamThu <= @HuyetApTamTruong
        THROW 50004, N'Huyết áp tâm thu phải lớn hơn huyết áp tâm trương.', 1;

    -- Kiểm tra khoảng hợp lệ TRƯỚC khi mở giao dịch. Trigger trên
    -- CHI_TIET_LAN_DO cũng chặn lỗi này, nhưng lệnh ROLLBACK trong trigger hủy
    -- cả giao dịch của nơi gọi; kiểm tra sớm ở đây giúp thủ tục vẫn an toàn
    -- khi được gọi bên trong một giao dịch khác.
    IF EXISTS (
        SELECT 1
        FROM (VALUES ('NHIET_DO',      @NhietDo),
                     ('NHIP_TIM',      @NhipTim),
                     ('SPO2',          @SpO2),
                     ('HA_TAM_THU',    @HuyetApTamThu),
                     ('HA_TAM_TRUONG', @HuyetApTamTruong)) AS v (KyHieu, GiaTri)
        JOIN LOAI_CHI_SO AS l ON l.KyHieu = v.KyHieu
        WHERE v.GiaTri < l.GiaTriMin OR v.GiaTri > l.GiaTriMax
    )
        THROW 50001, N'Giá trị đo nằm ngoài khoảng hợp lệ của chỉ số.', 1;

    BEGIN TRY
        BEGIN TRANSACTION;

        INSERT INTO LAN_DO (MaNguoiDung, MaThietBi, NguonDuLieu, ThoiGianDo, GhiChu)
        VALUES (@MaNguoiDung,
                @MaThietBi,
                CASE WHEN @MaThietBi IS NULL THEN N'Thủ công' ELSE N'Thiết bị' END,
                ISNULL(@ThoiGianDo, SYSDATETIME()),
                @GhiChu);

        SET @MaLanDo = SCOPE_IDENTITY();

        -- Chèn các chỉ số có giá trị; tra mã loại chỉ số qua ký hiệu.
        INSERT INTO CHI_TIET_LAN_DO (MaLanDo, MaLoaiChiSo, GiaTri)
        SELECT @MaLanDo, l.MaLoaiChiSo, v.GiaTri
        FROM (VALUES ('NHIET_DO',      @NhietDo),
                     ('NHIP_TIM',      @NhipTim),
                     ('SPO2',          @SpO2),
                     ('HA_TAM_THU',    @HuyetApTamThu),
                     ('HA_TAM_TRUONG', @HuyetApTamTruong)) AS v (KyHieu, GiaTri)
        JOIN LOAI_CHI_SO AS l ON l.KyHieu = v.KyHieu
        WHERE v.GiaTri IS NOT NULL
        ORDER BY l.MaLoaiChiSo;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        -- Lỗi ở bất kỳ bước nào thì hủy toàn bộ, không để lại lần đo dở dang.
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
END;
```

#### C.2 Lịch sử đo theo người và khoảng thời gian (tham số NULL = không lọc)

```sql
CREATE OR ALTER PROCEDURE SP_LichSuDo
    @MaNguoiDung INT  = NULL,
    @TuNgay      DATE = NULL,
    @DenNgay     DATE = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SELECT MaLanDo, HoTen, ThoiGianDo, NguonDuLieu, TenThietBi,
           NhietDo, NhipTim, SpO2, HuyetApTamThu, HuyetApTamTruong, MucDo
    FROM V_LAN_DO_TONG_HOP
    WHERE (@MaNguoiDung IS NULL OR MaNguoiDung = @MaNguoiDung)
      AND (@TuNgay  IS NULL OR ThoiGianDo >= @TuNgay)
      AND (@DenNgay IS NULL OR ThoiGianDo <  DATEADD(DAY, 1, @DenNgay))
    ORDER BY ThoiGianDo DESC;
END;
```

#### C.3 Thống kê từng chỉ số trong một khoảng thời gian

```sql
CREATE OR ALTER PROCEDURE SP_ThongKeChiSo
    @TuNgay      DATE,
    @DenNgay     DATE,
    @MaNguoiDung INT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        TenChiSo,
        DonViDo,
        COUNT(*)                              AS SoLanDo,
        CAST(AVG(GiaTri) AS DECIMAL(6,1))     AS TrungBinh,
        MIN(GiaTri)                           AS ThapNhat,
        MAX(GiaTri)                           AS CaoNhat,
        SUM(CASE WHEN CapDo > 0 THEN 1 ELSE 0 END) AS SoLanBatThuong
    FROM V_CHI_TIET_DANH_GIA
    WHERE ThoiGianDo >= @TuNgay
      AND ThoiGianDo <  DATEADD(DAY, 1, @DenNgay)
      AND (@MaNguoiDung IS NULL OR MaNguoiDung = @MaNguoiDung)
    GROUP BY MaLoaiChiSo, TenChiSo, DonViDo
    ORDER BY MaLoaiChiSo;
END;
```

#### C.4 Tìm người dùng theo tên (không dấu), giới tính và khoảng tuổi

```sql
CREATE OR ALTER PROCEDURE SP_TimNguoiDung
    @TuKhoa   NVARCHAR(100) = NULL,
    @GioiTinh NVARCHAR(5)   = NULL,
    @TuoiMin  INT           = NULL,
    @TuoiMax  INT           = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SELECT MaNguoiDung, HoTen, GioiTinh, Tuoi, NhomMau, SoLanDo
    FROM V_HO_SO_TONG_HOP
    WHERE (@TuKhoa IS NULL
           OR HoTen COLLATE Latin1_General_CI_AI LIKE N'%' + @TuKhoa + N'%')
      AND (@GioiTinh IS NULL OR GioiTinh = @GioiTinh)
      AND (@TuoiMin  IS NULL OR Tuoi >= @TuoiMin)
      AND (@TuoiMax  IS NULL OR Tuoi <= @TuoiMax)
    ORDER BY HoTen;
END;
```

#### C.5 Dùng thử các thủ tục

```sql
BEGIN TRANSACTION;

    DECLARE @MaMoi INT;

    EXEC SP_ThemLanDo
         @MaNguoiDung = 8, @MaThietBi = 1, @ThoiGianDo = '2026-10-10T21:30:00',
         @NhietDo = 36.5, @NhipTim = 78, @SpO2 = 98,
         @HuyetApTamThu = 86, @HuyetApTamTruong = 58,
         @GhiChu = N'Chóng mặt khi đứng dậy',
         @MaLanDo = @MaMoi OUTPUT;

    SELECT MaLanDo, HoTen, ThoiGianDo, NhipTim, HuyetApTamThu, HuyetApTamTruong,
           SoChiSoBatThuong, MucDo
    FROM V_LAN_DO_TONG_HOP
    WHERE MaLanDo = @MaMoi;

ROLLBACK TRANSACTION;
EXEC SP_LichSuDo @MaNguoiDung = 9, @TuNgay = '2026-10-06', @DenNgay = '2026-10-08';

EXEC SP_ThongKeChiSo @TuNgay = '2026-10-04', @DenNgay = '2026-10-10';

EXEC SP_TimNguoiDung @TuKhoa = N'thi', @GioiTinh = N'Nữ', @TuoiMin = 40;
```

**Kết quả:**

| MaLanDo | HoTen | ThoiGianDo | NhipTim | HuyetApTamThu | HuyetApTamTruong | SoChiSoBatThuong | MucDo |
|---|---|---|---|---|---|---|---|
| 297 | Bùi Thị Lan | 2026-10-10 21:30:00 | 78.0 | 86.0 | 58.0 | 2 | Cần chú ý |

| MaLanDo | HoTen | ThoiGianDo | NguonDuLieu | TenThietBi | NhietDo | NhipTim | SpO2 | HuyetApTamThu | HuyetApTamTruong | MucDo |
|---|---|---|---|---|---|---|---|---|---|---|
| 235 | Đỗ Thanh Long | 2026-10-07 18:11:00 | Thiết bị | ESP32 Health Monitor | 38.5 | 117.0 | 98.0 | 107.0 | 69.0 | Cần chú ý |
| 230 | Đỗ Thanh Long | 2026-10-07 07:34:00 | Thiết bị | ESP32 Health Monitor | 38.3 | 112.0 | 98.0 | 123.0 | 60.0 | Cần chú ý |
| 228 | Đỗ Thanh Long | 2026-10-06 21:02:00 | Thiết bị | ESP32 Health Monitor | 38.9 | 109.0 | 99.0 | 111.0 | 63.0 | Nguy hiểm |
| 220 | Đỗ Thanh Long | 2026-10-06 08:04:00 | Thiết bị | Nhiệt kế hồng ngoại | 38.5 | *NULL* | *NULL* | *NULL* | *NULL* | Cần chú ý |

| TenChiSo | DonViDo | SoLanDo | TrungBinh | ThapNhat | CaoNhat | SoLanBatThuong |
|---|---|---|---|---|---|---|
| Nhiệt độ | °C | 53 | 36.8 | 36.2 | 38.9 | 4 |
| Nhịp tim | bpm | 58 | 81.0 | 53.0 | 126.0 | 6 |
| SpO2 | % | 58 | 97.2 | 92.0 | 100.0 | 3 |
| Huyết áp tâm thu | mmHg | 49 | 120.7 | 96.0 | 148.0 | 13 |
| Huyết áp tâm trương | mmHg | 49 | 75.8 | 60.0 | 92.0 | 5 |

| MaNguoiDung | HoTen | GioiTinh | Tuoi | NhomMau | SoLanDo |
|---|---|---|---|---|---|
| 10 | Ngô Thị Mai | Nữ | 62 | B- | 29 |
| 4 | Phạm Thị Dung | Nữ | 68 | AB+ | 33 |
| 2 | Trần Thị Bích | Nữ | 51 | A+ | 28 |
| 6 | Vũ Thị Giang | Nữ | 43 | A- | 19 |

### D. JOIN

#### D.1 INNER JOIN năm bảng: từ một giá trị đo lần ra người, thiết bị và chỉ số

```sql
SELECT TOP (8)
    nd.HoTen,
    ld.ThoiGianDo,
    tb.TenThietBi,
    l.TenChiSo,
    ct.GiaTri,
    l.DonViDo
FROM CHI_TIET_LAN_DO AS ct
JOIN LAN_DO          AS ld ON ld.MaLanDo = ct.MaLanDo
JOIN NGUOI_DUNG      AS nd ON nd.MaNguoiDung = ld.MaNguoiDung
JOIN THIET_BI        AS tb ON tb.MaThietBi = ld.MaThietBi
JOIN LOAI_CHI_SO     AS l  ON l.MaLoaiChiSo = ct.MaLoaiChiSo
WHERE ld.ThoiGianDo >= '2026-10-10'
ORDER BY ld.ThoiGianDo DESC, l.MaLoaiChiSo;
```

**Kết quả:**

| HoTen | ThoiGianDo | TenThietBi | TenChiSo | GiaTri | DonViDo |
|---|---|---|---|---|---|
| Nguyễn Văn An | 2026-10-10 21:22:00 | ESP32 Health Monitor | Nhiệt độ | 36.8 | °C |
| Nguyễn Văn An | 2026-10-10 21:22:00 | ESP32 Health Monitor | Nhịp tim | 83.0 | bpm |
| Nguyễn Văn An | 2026-10-10 21:22:00 | ESP32 Health Monitor | SpO2 | 97.0 | % |
| Nguyễn Văn An | 2026-10-10 21:22:00 | ESP32 Health Monitor | Huyết áp tâm thu | 125.0 | mmHg |
| Nguyễn Văn An | 2026-10-10 21:22:00 | ESP32 Health Monitor | Huyết áp tâm trương | 82.0 | mmHg |
| Ngô Thị Mai | 2026-10-10 19:51:00 | ESP32 Health Monitor | Nhiệt độ | 36.7 | °C |
| Ngô Thị Mai | 2026-10-10 19:51:00 | ESP32 Health Monitor | Nhịp tim | 65.0 | bpm |
| Ngô Thị Mai | 2026-10-10 19:51:00 | ESP32 Health Monitor | SpO2 | 98.0 | % |

#### D.2 LEFT JOIN: mọi người dùng, kể cả người không có cảnh báo chưa xem

```sql
SELECT nd.HoTen, COUNT(cb.MaCanhBao) AS SoCanhBaoChuaXem
FROM NGUOI_DUNG    AS nd
LEFT JOIN LAN_DO   AS ld ON ld.MaNguoiDung = nd.MaNguoiDung
LEFT JOIN CANH_BAO AS cb ON cb.MaLanDo = ld.MaLanDo AND cb.DaXem = 0
GROUP BY nd.MaNguoiDung, nd.HoTen
ORDER BY SoCanhBaoChuaXem DESC, nd.HoTen;
```

**Kết quả:**

| HoTen | SoCanhBaoChuaXem |
|---|---|
| Đặng Quốc Huy | 6 |
| Đỗ Thanh Long | 4 |
| Phạm Thị Dung | 3 |
| Ngô Thị Mai | 2 |
| Dương Văn Nam | 1 |
| Nguyễn Văn An | 1 |
| Bùi Thị Lan | 0 |
| Hoàng Minh Đức | 0 |
| Lê Hoàng Cường | 0 |
| Lý Thị Oanh | 0 |
| Trần Thị Bích | 0 |
| Vũ Thị Giang | 0 |

#### D.3 SELF JOIN: các cặp người dùng cùng nhóm máu

```sql
SELECT a.HoTen AS NguoiThuNhat, b.HoTen AS NguoiThuHai, ha.NhomMau
FROM HO_SO_SUC_KHOE AS ha
JOIN HO_SO_SUC_KHOE AS hb ON hb.NhomMau = ha.NhomMau AND hb.MaNguoiDung > ha.MaNguoiDung
JOIN NGUOI_DUNG     AS a  ON a.MaNguoiDung = ha.MaNguoiDung
JOIN NGUOI_DUNG     AS b  ON b.MaNguoiDung = hb.MaNguoiDung
ORDER BY ha.NhomMau, a.HoTen;
```

**Kết quả:**

| NguoiThuNhat | NguoiThuHai | NhomMau |
|---|---|---|
| Trần Thị Bích | Đỗ Thanh Long | A+ |
| Lê Hoàng Cường | Đặng Quốc Huy | B+ |
| Bùi Thị Lan | Lý Thị Oanh | O+ |
| Nguyễn Văn An | Bùi Thị Lan | O+ |
| Nguyễn Văn An | Lý Thị Oanh | O+ |

#### D.4 CROSS JOIN + LEFT JOIN: ma trận người × chỉ số, đếm số lần đã đo

(ô bằng 0 cho biết người đó chưa từng được đo chỉ số ấy)

```sql
SELECT nd.HoTen, l.TenChiSo, COUNT(ct.MaLanDo) AS SoLanDo
FROM NGUOI_DUNG       AS nd
CROSS JOIN LOAI_CHI_SO AS l
LEFT JOIN LAN_DO          AS ld ON ld.MaNguoiDung = nd.MaNguoiDung
LEFT JOIN CHI_TIET_LAN_DO AS ct ON ct.MaLanDo = ld.MaLanDo AND ct.MaLoaiChiSo = l.MaLoaiChiSo
WHERE nd.MaNguoiDung IN (5, 12)
GROUP BY nd.MaNguoiDung, nd.HoTen, l.MaLoaiChiSo, l.TenChiSo
ORDER BY nd.MaNguoiDung, l.MaLoaiChiSo;
```

**Kết quả:**

| HoTen | TenChiSo | SoLanDo |
|---|---|---|
| Hoàng Minh Đức | Nhiệt độ | 9 |
| Hoàng Minh Đức | Nhịp tim | 12 |
| Hoàng Minh Đức | SpO2 | 11 |
| Hoàng Minh Đức | Huyết áp tâm thu | 10 |
| Hoàng Minh Đức | Huyết áp tâm trương | 10 |
| Lý Thị Oanh | Nhiệt độ | 12 |
| Lý Thị Oanh | Nhịp tim | 14 |
| Lý Thị Oanh | SpO2 | 14 |
| Lý Thị Oanh | Huyết áp tâm thu | 11 |
| Lý Thị Oanh | Huyết áp tâm trương | 11 |

### E. GROUP BY với COUNT, AVG, MAX, MIN

#### E.1 Số lần đo, lần đo đầu và cuối của từng người

```sql
SELECT
    nd.HoTen,
    COUNT(*)            AS SoLanDo,
    MIN(ld.ThoiGianDo)  AS LanDoDauTien,
    MAX(ld.ThoiGianDo)  AS LanDoGanNhat
FROM LAN_DO     AS ld
JOIN NGUOI_DUNG AS nd ON nd.MaNguoiDung = ld.MaNguoiDung
GROUP BY nd.MaNguoiDung, nd.HoTen
ORDER BY SoLanDo DESC;
```

**Kết quả:**

| HoTen | SoLanDo | LanDoDauTien | LanDoGanNhat |
|---|---|---|---|
| Đặng Quốc Huy | 35 | 2026-09-12 19:53:00 | 2026-10-10 18:21:00 |
| Phạm Thị Dung | 33 | 2026-09-11 07:21:00 | 2026-10-10 18:35:00 |
| Nguyễn Văn An | 30 | 2026-09-11 08:40:00 | 2026-10-10 21:22:00 |
| Ngô Thị Mai | 29 | 2026-09-14 06:49:00 | 2026-10-10 19:51:00 |
| Trần Thị Bích | 28 | 2026-09-11 08:35:00 | 2026-10-10 07:11:00 |
| Vũ Thị Giang | 19 | 2026-09-11 20:22:00 | 2026-10-09 07:05:00 |
| Dương Văn Nam | 18 | 2026-09-11 07:37:00 | 2026-10-10 06:57:00 |
| Bùi Thị Lan | 17 | 2026-09-12 09:22:00 | 2026-10-10 19:42:00 |
| Đỗ Thanh Long | 17 | 2026-09-11 09:10:00 | 2026-10-07 18:11:00 |
| Lý Thị Oanh | 15 | 2026-09-12 19:51:00 | 2026-10-10 06:54:00 |
| Lê Hoàng Cường | 12 | 2026-09-13 07:41:00 | 2026-10-10 15:55:00 |
| Hoàng Minh Đức | 12 | 2026-09-11 09:25:00 | 2026-10-06 09:14:00 |

#### E.2 Trung bình, thấp nhất, cao nhất của từng chỉ số

```sql
SELECT
    l.TenChiSo,
    l.DonViDo,
    COUNT(*)                               AS SoGiaTri,
    CAST(AVG(ct.GiaTri) AS DECIMAL(6,1))   AS TrungBinh,
    MIN(ct.GiaTri)                         AS ThapNhat,
    MAX(ct.GiaTri)                         AS CaoNhat
FROM CHI_TIET_LAN_DO AS ct
JOIN LOAI_CHI_SO     AS l ON l.MaLoaiChiSo = ct.MaLoaiChiSo
GROUP BY l.MaLoaiChiSo, l.TenChiSo, l.DonViDo
ORDER BY l.MaLoaiChiSo;
```

**Kết quả:**

| TenChiSo | DonViDo | SoGiaTri | TrungBinh | ThapNhat | CaoNhat |
|---|---|---|---|---|---|
| Nhiệt độ | °C | 219 | 36.7 | 36.2 | 38.9 |
| Nhịp tim | bpm | 242 | 80.5 | 53.0 | 126.0 |
| SpO2 | % | 227 | 97.1 | 92.0 | 100.0 |
| Huyết áp tâm thu | mmHg | 211 | 120.4 | 84.0 | 148.0 |
| Huyết áp tâm trương | mmHg | 211 | 76.7 | 59.0 | 92.0 |

#### E.3 Gom theo hai cột: nhịp tim trung bình của từng người theo buổi đo

```sql
SELECT
    nd.HoTen,
    CASE WHEN DATEPART(HOUR, ld.ThoiGianDo) < 12 THEN N'Sáng' ELSE N'Chiều tối' END AS Buoi,
    COUNT(*)                               AS SoLanDo,
    CAST(AVG(ct.GiaTri) AS DECIMAL(6,1))   AS NhipTimTrungBinh
FROM CHI_TIET_LAN_DO AS ct
JOIN LAN_DO          AS ld ON ld.MaLanDo = ct.MaLanDo
JOIN NGUOI_DUNG      AS nd ON nd.MaNguoiDung = ld.MaNguoiDung
JOIN LOAI_CHI_SO     AS l  ON l.MaLoaiChiSo = ct.MaLoaiChiSo
WHERE l.KyHieu = 'NHIP_TIM'
  AND nd.MaNguoiDung IN (1, 7)
GROUP BY nd.MaNguoiDung, nd.HoTen,
         CASE WHEN DATEPART(HOUR, ld.ThoiGianDo) < 12 THEN N'Sáng' ELSE N'Chiều tối' END
ORDER BY nd.HoTen, Buoi DESC;
```

**Kết quả:**

| HoTen | Buoi | SoLanDo | NhipTimTrungBinh |
|---|---|---|---|
| Đặng Quốc Huy | Sáng | 17 | 95.5 |
| Đặng Quốc Huy | Chiều tối | 16 | 96.2 |
| Nguyễn Văn An | Sáng | 17 | 75.9 |
| Nguyễn Văn An | Chiều tối | 10 | 74.7 |

#### E.4 Số lần đo và số cảnh báo theo tuần

```sql
SELECT
    DATEPART(ISO_WEEK, ld.ThoiGianDo)          AS Tuan,
    MIN(CAST(ld.ThoiGianDo AS DATE))           AS TuNgay,
    MAX(CAST(ld.ThoiGianDo AS DATE))           AS DenNgay,
    COUNT(DISTINCT ld.MaLanDo)                 AS SoLanDo,
    COUNT(cb.MaCanhBao)                        AS SoCanhBao
FROM LAN_DO        AS ld
LEFT JOIN CANH_BAO AS cb ON cb.MaLanDo = ld.MaLanDo
GROUP BY DATEPART(ISO_WEEK, ld.ThoiGianDo)
ORDER BY Tuan;
```

**Kết quả:**

| Tuan | TuNgay | DenNgay | SoLanDo | SoCanhBao |
|---|---|---|---|---|
| 37 | 2026-09-11 | 2026-09-13 | 30 | 9 |
| 38 | 2026-09-14 | 2026-09-20 | 59 | 23 |
| 39 | 2026-09-21 | 2026-09-27 | 60 | 27 |
| 40 | 2026-09-28 | 2026-10-04 | 62 | 22 |
| 41 | 2026-10-05 | 2026-10-10 | 54 | 27 |

#### E.5 Số lần đo theo nhóm tuổi của người được đo

```sql
SELECT
    CASE
        WHEN dbo.FN_TinhTuoi(nd.NgaySinh, '2026-10-10') < 18 THEN N'1. Dưới 18'
        WHEN dbo.FN_TinhTuoi(nd.NgaySinh, '2026-10-10') < 40 THEN N'2. 18 – 39'
        WHEN dbo.FN_TinhTuoi(nd.NgaySinh, '2026-10-10') < 60 THEN N'3. 40 – 59'
        ELSE N'4. Từ 60'
    END                             AS NhomTuoi,
    COUNT(DISTINCT nd.MaNguoiDung)  AS SoNguoi,
    COUNT(*)                        AS SoLanDo
FROM LAN_DO     AS ld
JOIN NGUOI_DUNG AS nd ON nd.MaNguoiDung = ld.MaNguoiDung
GROUP BY
    CASE
        WHEN dbo.FN_TinhTuoi(nd.NgaySinh, '2026-10-10') < 18 THEN N'1. Dưới 18'
        WHEN dbo.FN_TinhTuoi(nd.NgaySinh, '2026-10-10') < 40 THEN N'2. 18 – 39'
        WHEN dbo.FN_TinhTuoi(nd.NgaySinh, '2026-10-10') < 60 THEN N'3. 40 – 59'
        ELSE N'4. Từ 60'
    END
ORDER BY NhomTuoi;
```

**Kết quả:**

| NhomTuoi | SoNguoi | SoLanDo |
|---|---|---|
| 1. Dưới 18 | 1 | 17 |
| 2. 18 – 39 | 4 | 56 |
| 3. 40 – 59 | 4 | 95 |
| 4. Từ 60 | 3 | 97 |

### F. HAVING

#### F.1 Người có từ 25 lần đo trở lên

```sql
SELECT nd.HoTen, COUNT(*) AS SoLanDo
FROM LAN_DO     AS ld
JOIN NGUOI_DUNG AS nd ON nd.MaNguoiDung = ld.MaNguoiDung
GROUP BY nd.MaNguoiDung, nd.HoTen
HAVING COUNT(*) >= 25
ORDER BY SoLanDo DESC;
```

**Kết quả:**

| HoTen | SoLanDo |
|---|---|
| Đặng Quốc Huy | 35 |
| Phạm Thị Dung | 33 |
| Nguyễn Văn An | 30 |
| Ngô Thị Mai | 29 |
| Trần Thị Bích | 28 |

#### F.2 Người có huyết áp tâm thu TRUNG BÌNH vượt khoảng bình thường

```sql
SELECT
    nd.HoTen,
    COUNT(*)                               AS SoLanDo,
    CAST(AVG(ct.GiaTri) AS DECIMAL(6,1))   AS TamThuTrungBinh,
    MAX(l.BinhThuongMax)                   AS NguongBinhThuong
FROM CHI_TIET_LAN_DO AS ct
JOIN LAN_DO          AS ld ON ld.MaLanDo = ct.MaLanDo
JOIN NGUOI_DUNG      AS nd ON nd.MaNguoiDung = ld.MaNguoiDung
JOIN LOAI_CHI_SO     AS l  ON l.MaLoaiChiSo = ct.MaLoaiChiSo
WHERE l.KyHieu = 'HA_TAM_THU'
GROUP BY nd.MaNguoiDung, nd.HoTen
HAVING AVG(ct.GiaTri) > MAX(l.BinhThuongMax)
ORDER BY TamThuTrungBinh DESC;
```

**Kết quả:**

| HoTen | SoLanDo | TamThuTrungBinh | NguongBinhThuong |
|---|---|---|---|
| Đặng Quốc Huy | 25 | 133.6 | 129.0 |

#### F.3 Ngày có từ 12 lần đo trở lên

```sql
SELECT CAST(ThoiGianDo AS DATE) AS Ngay, COUNT(*) AS SoLanDo
FROM LAN_DO
GROUP BY CAST(ThoiGianDo AS DATE)
HAVING COUNT(*) >= 12
ORDER BY SoLanDo DESC, Ngay;
```

**Kết quả:**

| Ngay | SoLanDo |
|---|---|
| 2026-10-10 | 15 |
| 2026-10-06 | 13 |
| 2026-09-17 | 12 |
| 2026-09-25 | 12 |

#### F.4 WHERE lọc trước khi gom nhóm, HAVING lọc sau: người có từ 3 cảnh báo

NGUY HIỂM trở lên

```sql
SELECT nd.HoTen, COUNT(*) AS SoCanhBaoNguyHiem
FROM CANH_BAO   AS cb
JOIN LAN_DO     AS ld ON ld.MaLanDo = cb.MaLanDo
JOIN NGUOI_DUNG AS nd ON nd.MaNguoiDung = ld.MaNguoiDung
WHERE cb.MucDo = N'Nguy hiểm'
GROUP BY nd.MaNguoiDung, nd.HoTen
HAVING COUNT(*) >= 3
ORDER BY SoCanhBaoNguyHiem DESC;
```

**Kết quả:**

| HoTen | SoCanhBaoNguyHiem |
|---|---|
| Đặng Quốc Huy | 11 |

#### F.5 Chỉ số có hơn 10% giá trị nằm ngoài khoảng bình thường

```sql
SELECT
    TenChiSo,
    COUNT(*)                                                         AS SoGiaTri,
    SUM(CASE WHEN CapDo > 0 THEN 1 ELSE 0 END)                       AS SoBatThuong,
    CAST(100.0 * SUM(CASE WHEN CapDo > 0 THEN 1 ELSE 0 END) / COUNT(*)
         AS DECIMAL(5,1))                                            AS TyLePhanTram
FROM V_CHI_TIET_DANH_GIA
GROUP BY MaLoaiChiSo, TenChiSo
HAVING 100.0 * SUM(CASE WHEN CapDo > 0 THEN 1 ELSE 0 END) / COUNT(*) > 10
ORDER BY TyLePhanTram DESC;
```

**Kết quả:**

| TenChiSo | SoGiaTri | SoBatThuong | TyLePhanTram |
|---|---|---|---|
| Huyết áp tâm thu | 211 | 46 | 21.8 |
| Huyết áp tâm trương | 211 | 30 | 14.2 |

### G. SUBQUERY, TẬP HỢP, CTE VÀ HÀM CỬA SỔ

#### G.1 Truy vấn con vô hướng: lần đo có nhịp tim cao hơn mức trung bình chung

```sql
SELECT TOP (8) nd.HoTen, ld.ThoiGianDo, ct.GiaTri AS NhipTim,
       (SELECT CAST(AVG(GiaTri) AS DECIMAL(6,1))
          FROM CHI_TIET_LAN_DO WHERE MaLoaiChiSo = 2) AS TrungBinhChung
FROM CHI_TIET_LAN_DO AS ct
JOIN LAN_DO          AS ld ON ld.MaLanDo = ct.MaLanDo
JOIN NGUOI_DUNG      AS nd ON nd.MaNguoiDung = ld.MaNguoiDung
WHERE ct.MaLoaiChiSo = 2
  AND ct.GiaTri > (SELECT AVG(GiaTri) FROM CHI_TIET_LAN_DO WHERE MaLoaiChiSo = 2)
ORDER BY ct.GiaTri DESC;
```

**Kết quả:**

| HoTen | ThoiGianDo | NhipTim | TrungBinhChung |
|---|---|---|---|
| Đặng Quốc Huy | 2026-10-10 18:12:00 | 126.0 | 80.5 |
| Đặng Quốc Huy | 2026-09-19 07:57:00 | 124.0 | 80.5 |
| Đỗ Thanh Long | 2026-10-07 18:11:00 | 117.0 | 80.5 |
| Đỗ Thanh Long | 2026-10-07 07:34:00 | 112.0 | 80.5 |
| Đặng Quốc Huy | 2026-10-04 07:00:00 | 111.0 | 80.5 |
| Đặng Quốc Huy | 2026-09-26 08:53:00 | 110.0 | 80.5 |
| Đỗ Thanh Long | 2026-10-06 21:02:00 | 109.0 | 80.5 |
| Đặng Quốc Huy | 2026-09-21 07:40:00 | 108.0 | 80.5 |

#### G.2 Truy vấn con với IN: người từng có cảnh báo mức nguy hiểm

```sql
SELECT MaNguoiDung, HoTen
FROM NGUOI_DUNG
WHERE MaNguoiDung IN (
    SELECT ld.MaNguoiDung
    FROM CANH_BAO AS cb
    JOIN LAN_DO   AS ld ON ld.MaLanDo = cb.MaLanDo
    WHERE cb.MucDo = N'Nguy hiểm'
)
ORDER BY HoTen;
```

**Kết quả:**

| MaNguoiDung | HoTen |
|---|---|
| 8 | Bùi Thị Lan |
| 7 | Đặng Quốc Huy |
| 9 | Đỗ Thanh Long |
| 10 | Ngô Thị Mai |
| 1 | Nguyễn Văn An |

#### G.3 NOT EXISTS: người chưa từng có cảnh báo nào

```sql
SELECT nd.MaNguoiDung, nd.HoTen
FROM NGUOI_DUNG AS nd
WHERE NOT EXISTS (
    SELECT 1
    FROM CANH_BAO AS cb
    JOIN LAN_DO   AS ld ON ld.MaLanDo = cb.MaLanDo
    WHERE ld.MaNguoiDung = nd.MaNguoiDung
)
ORDER BY nd.HoTen;
```

**Kết quả:**

| MaNguoiDung | HoTen |
|---|---|
| 12 | Lý Thị Oanh |
| 6 | Vũ Thị Giang |

#### G.4 Truy vấn con tương quan: lần có huyết áp tâm thu cao nhất của mỗi người

```sql
SELECT nd.HoTen, ld.ThoiGianDo, ct.GiaTri AS TamThuCaoNhat
FROM CHI_TIET_LAN_DO AS ct
JOIN LAN_DO          AS ld ON ld.MaLanDo = ct.MaLanDo
JOIN NGUOI_DUNG      AS nd ON nd.MaNguoiDung = ld.MaNguoiDung
WHERE ct.MaLoaiChiSo = 4
  AND ct.GiaTri = (
      SELECT MAX(ct2.GiaTri)
      FROM CHI_TIET_LAN_DO AS ct2
      JOIN LAN_DO          AS ld2 ON ld2.MaLanDo = ct2.MaLanDo
      WHERE ct2.MaLoaiChiSo = 4
        AND ld2.MaNguoiDung = ld.MaNguoiDung
  )
ORDER BY ct.GiaTri DESC, ld.ThoiGianDo;
```

**Kết quả:**

| HoTen | ThoiGianDo | TamThuCaoNhat |
|---|---|---|
| Đặng Quốc Huy | 2026-10-10 18:12:00 | 148.0 |
| Ngô Thị Mai | 2026-09-25 20:47:00 | 141.0 |
| Ngô Thị Mai | 2026-10-06 07:37:00 | 141.0 |
| Dương Văn Nam | 2026-09-11 20:51:00 | 138.0 |
| Nguyễn Văn An | 2026-09-11 20:59:00 | 134.0 |
| Phạm Thị Dung | 2026-09-17 21:09:00 | 133.0 |
| Phạm Thị Dung | 2026-10-02 18:29:00 | 133.0 |
| Phạm Thị Dung | 2026-10-10 08:07:00 | 133.0 |
| Trần Thị Bích | 2026-10-02 09:27:00 | 132.0 |
| Trần Thị Bích | 2026-10-10 07:11:00 | 132.0 |
| Lê Hoàng Cường | 2026-10-04 19:49:00 | 123.0 |
| Đỗ Thanh Long | 2026-10-07 07:34:00 | 123.0 |

*… còn 5 dòng nữa (tổng cộng 17 dòng).*

#### G.5 Truy vấn con trong FROM (bảng dẫn xuất): tỷ lệ lần đo bất thường của từng người

```sql
SELECT HoTen, SoLanDo, SoLanBatThuong,
       CAST(100.0 * SoLanBatThuong / SoLanDo AS DECIMAL(5,1)) AS TyLePhanTram
FROM (
    SELECT HoTen,
           COUNT(*)                                                   AS SoLanDo,
           SUM(CASE WHEN MucDo <> N'Bình thường' THEN 1 ELSE 0 END)   AS SoLanBatThuong
    FROM V_LAN_DO_TONG_HOP
    GROUP BY MaNguoiDung, HoTen
) AS t
ORDER BY TyLePhanTram DESC;
```

**Kết quả:**

| HoTen | SoLanDo | SoLanBatThuong | TyLePhanTram |
|---|---|---|---|
| Đặng Quốc Huy | 35 | 23 | 65.7 |
| Ngô Thị Mai | 29 | 14 | 48.3 |
| Dương Văn Nam | 18 | 8 | 44.4 |
| Nguyễn Văn An | 30 | 12 | 40.0 |
| Phạm Thị Dung | 33 | 13 | 39.4 |
| Hoàng Minh Đức | 12 | 4 | 33.3 |
| Đỗ Thanh Long | 17 | 4 | 23.5 |
| Trần Thị Bích | 28 | 5 | 17.9 |
| Bùi Thị Lan | 17 | 2 | 11.8 |
| Lê Hoàng Cường | 12 | 1 | 8.3 |
| Lý Thị Oanh | 15 | 0 | .0 |
| Vũ Thị Giang | 19 | 0 | .0 |

#### G.6 ALL: người có số lần đo nhiều hơn mọi người thuộc nhóm dưới 40 tuổi

```sql
SELECT nd.HoTen, COUNT(*) AS SoLanDo
FROM LAN_DO     AS ld
JOIN NGUOI_DUNG AS nd ON nd.MaNguoiDung = ld.MaNguoiDung
GROUP BY nd.MaNguoiDung, nd.HoTen
HAVING COUNT(*) > ALL (
    SELECT COUNT(*)
    FROM LAN_DO     AS ld2
    JOIN NGUOI_DUNG AS nd2 ON nd2.MaNguoiDung = ld2.MaNguoiDung
    WHERE dbo.FN_TinhTuoi(nd2.NgaySinh, '2026-10-10') < 40
    GROUP BY nd2.MaNguoiDung
)
ORDER BY SoLanDo DESC;
```

**Kết quả:**

| HoTen | SoLanDo |
|---|---|
| Đặng Quốc Huy | 35 |
| Phạm Thị Dung | 33 |
| Nguyễn Văn An | 30 |
| Ngô Thị Mai | 29 |
| Trần Thị Bích | 28 |
| Vũ Thị Giang | 19 |
| Dương Văn Nam | 18 |

#### G.7 EXCEPT: người có cảnh báo huyết áp nhưng không có cảnh báo nhịp tim

```sql
SELECT nd.HoTen
FROM V_CANH_BAO_CHI_TIET AS v
JOIN NGUOI_DUNG AS nd ON nd.MaNguoiDung = v.MaNguoiDung
WHERE v.MaLoaiChiSo IN (4, 5)
EXCEPT
SELECT nd.HoTen
FROM V_CANH_BAO_CHI_TIET AS v
JOIN NGUOI_DUNG AS nd ON nd.MaNguoiDung = v.MaNguoiDung
WHERE v.MaLoaiChiSo = 2;
```

**Kết quả:**

| HoTen |
|---|
| Bùi Thị Lan |
| Dương Văn Nam |
| Ngô Thị Mai |
| Nguyễn Văn An |
| Phạm Thị Dung |
| Trần Thị Bích |

#### G.8 UNION ALL: dòng thời gian của một người, trộn lần đo và cảnh báo

```sql
SELECT ThoiGian, Loai, MoTa
FROM (
    SELECT ld.ThoiGianDo AS ThoiGian, N'Lần đo' AS Loai,
           CONCAT(N'Đo bằng ', ISNULL(tb.TenThietBi, N'nhập thủ công')) AS MoTa
    FROM LAN_DO        AS ld
    LEFT JOIN THIET_BI AS tb ON tb.MaThietBi = ld.MaThietBi
    WHERE ld.MaNguoiDung = 9 AND ld.ThoiGianDo >= '2026-10-06'

    UNION ALL

    SELECT cb.ThoiGianTao, N'Cảnh báo', cb.NoiDung
    FROM CANH_BAO AS cb
    JOIN LAN_DO   AS ld ON ld.MaLanDo = cb.MaLanDo
    WHERE ld.MaNguoiDung = 9 AND cb.ThoiGianTao >= '2026-10-06'
) AS dong_thoi_gian
ORDER BY ThoiGian, Loai DESC;
```

**Kết quả:**

| ThoiGian | Loai | MoTa |
|---|---|---|
| 2026-10-06 08:04:00 | Lần đo | Đo bằng Nhiệt kế hồng ngoại |
| 2026-10-06 08:04:00 | Cảnh báo | Nhiệt độ 38,5 °C cao hơn khoảng bình thường (36,1 – 37,5 °C). |
| 2026-10-06 21:02:00 | Lần đo | Đo bằng ESP32 Health Monitor |
| 2026-10-06 21:02:00 | Cảnh báo | Nhiệt độ 38,9 °C cao hơn khoảng bình thường (36,1 – 37,5 °C). |
| 2026-10-06 21:02:00 | Cảnh báo | Nhịp tim 109 bpm cao hơn khoảng bình thường (60 – 100 bpm). |
| 2026-10-07 07:34:00 | Lần đo | Đo bằng ESP32 Health Monitor |
| 2026-10-07 07:34:00 | Cảnh báo | Nhiệt độ 38,3 °C cao hơn khoảng bình thường (36,1 – 37,5 °C). |
| 2026-10-07 07:34:00 | Cảnh báo | Nhịp tim 112 bpm cao hơn khoảng bình thường (60 – 100 bpm). |
| 2026-10-07 18:11:00 | Lần đo | Đo bằng ESP32 Health Monitor |
| 2026-10-07 18:11:00 | Cảnh báo | Nhiệt độ 38,5 °C cao hơn khoảng bình thường (36,1 – 37,5 °C). |
| 2026-10-07 18:11:00 | Cảnh báo | Nhịp tim 117 bpm cao hơn khoảng bình thường (60 – 100 bpm). |

#### G.9 CTE: xếp hạng người dùng theo số cảnh báo (RANK cho phép đồng hạng)

```sql
WITH SoCanhBaoTheoNguoi AS (
    SELECT MaNguoiDung, HoTen, COUNT(*) AS SoCanhBao
    FROM V_CANH_BAO_CHI_TIET
    GROUP BY MaNguoiDung, HoTen
)
SELECT RANK() OVER (ORDER BY SoCanhBao DESC) AS Hang, HoTen, SoCanhBao
FROM SoCanhBaoTheoNguoi
ORDER BY Hang, HoTen;
```

**Kết quả:**

| Hang | HoTen | SoCanhBao |
|---|---|---|
| 1 | Đặng Quốc Huy | 38 |
| 2 | Ngô Thị Mai | 15 |
| 3 | Nguyễn Văn An | 13 |
| 3 | Phạm Thị Dung | 13 |
| 5 | Dương Văn Nam | 9 |
| 6 | Đỗ Thanh Long | 7 |
| 7 | Trần Thị Bích | 5 |
| 8 | Hoàng Minh Đức | 4 |
| 9 | Bùi Thị Lan | 3 |
| 10 | Lê Hoàng Cường | 1 |

#### G.10 Hàm cửa sổ LAG: chênh lệch huyết áp tâm thu so với lần đo trước của cùng người

```sql
SELECT TOP (10)
    HoTen,
    ThoiGianDo,
    HuyetApTamThu,
    LAG(HuyetApTamThu) OVER (PARTITION BY MaNguoiDung ORDER BY ThoiGianDo) AS LanTruoc,
    HuyetApTamThu
      - LAG(HuyetApTamThu) OVER (PARTITION BY MaNguoiDung ORDER BY ThoiGianDo) AS ChenhLech
FROM V_LAN_DO_TONG_HOP
WHERE MaNguoiDung = 7 AND HuyetApTamThu IS NOT NULL
ORDER BY ThoiGianDo DESC;
```

**Kết quả:**

| HoTen | ThoiGianDo | HuyetApTamThu | LanTruoc | ChenhLech |
|---|---|---|---|---|
| Đặng Quốc Huy | 2026-10-10 18:12:00 | 148.0 | 141.0 | 7.0 |
| Đặng Quốc Huy | 2026-10-09 18:41:00 | 141.0 | 135.0 | 6.0 |
| Đặng Quốc Huy | 2026-10-09 07:20:00 | 135.0 | 123.0 | 12.0 |
| Đặng Quốc Huy | 2026-10-08 21:19:00 | 123.0 | 126.0 | -3.0 |
| Đặng Quốc Huy | 2026-10-07 07:38:00 | 126.0 | 145.0 | -19.0 |
| Đặng Quốc Huy | 2026-10-04 07:00:00 | 145.0 | 143.0 | 2.0 |
| Đặng Quốc Huy | 2026-10-03 08:29:00 | 143.0 | 122.0 | 21.0 |
| Đặng Quốc Huy | 2026-09-30 20:47:00 | 122.0 | 143.0 | -21.0 |
| Đặng Quốc Huy | 2026-09-30 08:10:00 | 143.0 | 131.0 | 12.0 |
| Đặng Quốc Huy | 2026-09-28 20:38:00 | 131.0 | 142.0 | -11.0 |

#### G.11 Trung bình trượt 3 lần đo gần nhất của nhịp tim

```sql
SELECT TOP (10)
    ThoiGianDo,
    NhipTim,
    CAST(AVG(NhipTim) OVER (ORDER BY ThoiGianDo
                            ROWS BETWEEN 2 PRECEDING AND CURRENT ROW)
         AS DECIMAL(6,1)) AS TrungBinh3LanGanNhat
FROM V_LAN_DO_TONG_HOP
WHERE MaNguoiDung = 7 AND NhipTim IS NOT NULL
ORDER BY ThoiGianDo DESC;
```

**Kết quả:**

| ThoiGianDo | NhipTim | TrungBinh3LanGanNhat |
|---|---|---|
| 2026-10-10 18:21:00 | 96.0 | 101.3 |
| 2026-10-10 18:12:00 | 126.0 | 98.3 |
| 2026-10-09 18:41:00 | 82.0 | 87.3 |
| 2026-10-09 07:20:00 | 87.0 | 88.7 |
| 2026-10-08 21:19:00 | 93.0 | 96.7 |
| 2026-10-07 07:38:00 | 86.0 | 90.0 |
| 2026-10-04 07:00:00 | 111.0 | 87.0 |
| 2026-10-03 08:29:00 | 73.0 | 77.7 |
| 2026-09-30 20:47:00 | 77.0 | 85.3 |
| 2026-09-30 08:10:00 | 83.0 | 89.0 |

### H. BÁO CÁO THỐNG KÊ

#### H.1 Tổng quan hệ thống trên một dòng

```sql
SELECT
    (SELECT COUNT(*) FROM NGUOI_DUNG)                               AS SoNguoiDung,
    (SELECT COUNT(*) FROM HO_SO_SUC_KHOE)                           AS SoHoSo,
    (SELECT COUNT(*) FROM THIET_BI WHERE TrangThai = N'Hoạt động')  AS ThietBiHoatDong,
    (SELECT COUNT(*) FROM LAN_DO)                                   AS TongLanDo,
    (SELECT COUNT(*) FROM CHI_TIET_LAN_DO)                          AS TongGiaTriDo,
    (SELECT COUNT(*) FROM CANH_BAO)                                 AS TongCanhBao,
    (SELECT COUNT(*) FROM CANH_BAO WHERE DaXem = 0)                 AS CanhBaoChuaXem;
```

**Kết quả:**

| SoNguoiDung | SoHoSo | ThietBiHoatDong | TongLanDo | TongGiaTriDo | TongCanhBao | CanhBaoChuaXem |
|---|---|---|---|---|---|---|
| 12 | 12 | 4 | 265 | 1110 | 108 | 17 |

#### H.2 Báo cáo theo người: số lần đo, trung bình từng chỉ số, số cảnh báo

```sql
SELECT
    v.HoTen,
    COUNT(*)                                           AS SoLanDo,
    CAST(AVG(v.NhietDo)          AS DECIMAL(4,1))      AS NhietDoTB,
    CAST(AVG(v.NhipTim)          AS DECIMAL(5,0))      AS NhipTimTB,
    CAST(AVG(v.SpO2)             AS DECIMAL(5,1))      AS SpO2TB,
    CAST(AVG(v.HuyetApTamThu)    AS DECIMAL(5,0))      AS TamThuTB,
    CAST(AVG(v.HuyetApTamTruong) AS DECIMAL(5,0))      AS TamTruongTB,
    SUM(v.SoChiSoBatThuong)                            AS SoCanhBao
FROM V_LAN_DO_TONG_HOP AS v
GROUP BY v.MaNguoiDung, v.HoTen
ORDER BY SoCanhBao DESC, v.HoTen;
```

**Kết quả:**

| HoTen | SoLanDo | NhietDoTB | NhipTimTB | SpO2TB | TamThuTB | TamTruongTB | SoCanhBao |
|---|---|---|---|---|---|---|---|
| Đặng Quốc Huy | 35 | 36.7 | 96 | 96.3 | 134 | 84 | 38 |
| Ngô Thị Mai | 29 | 36.7 | 74 | 97.0 | 128 | 81 | 15 |
| Nguyễn Văn An | 30 | 36.7 | 75 | 97.4 | 126 | 83 | 13 |
| Phạm Thị Dung | 33 | 36.6 | 82 | 94.9 | 123 | 75 | 13 |
| Dương Văn Nam | 18 | 36.8 | 80 | 96.9 | 124 | 81 | 9 |
| Đỗ Thanh Long | 17 | 37.2 | 89 | 98.3 | 108 | 67 | 7 |
| Trần Thị Bích | 28 | 36.8 | 84 | 97.4 | 123 | 79 | 5 |
| Hoàng Minh Đức | 12 | 36.7 | 63 | 98.8 | 114 | 71 | 4 |
| Bùi Thị Lan | 17 | 36.6 | 79 | 97.9 | 100 | 66 | 3 |
| Lê Hoàng Cường | 12 | 36.6 | 70 | 98.3 | 116 | 73 | 1 |
| Lý Thị Oanh | 15 | 36.8 | 67 | 99.1 | 108 | 73 | 0 |
| Vũ Thị Giang | 19 | 36.7 | 85 | 96.7 | 109 | 69 | 0 |

#### H.3 Phân bố kết quả lần đo theo mức độ

```sql
SELECT
    MucDo,
    COUNT(*) AS SoLanDo,
    CAST(100.0 * COUNT(*) / SUM(COUNT(*)) OVER () AS DECIMAL(5,1)) AS TyLePhanTram
FROM V_LAN_DO_TONG_HOP
GROUP BY MucDo
ORDER BY CASE MucDo WHEN N'Bình thường' THEN 1 WHEN N'Cần chú ý' THEN 2 ELSE 3 END;
```

**Kết quả:**

| MucDo | SoLanDo | TyLePhanTram |
|---|---|---|
| Bình thường | 179 | 67.5 |
| Cần chú ý | 72 | 27.2 |
| Nguy hiểm | 14 | 5.3 |

#### H.4 Số lần đo và số cảnh báo theo ngày trong 7 ngày cuối của dữ liệu mẫu

```sql
SELECT
    CAST(ld.ThoiGianDo AS DATE)   AS Ngay,
    COUNT(DISTINCT ld.MaLanDo)    AS SoLanDo,
    COUNT(cb.MaCanhBao)           AS SoCanhBao
FROM LAN_DO        AS ld
LEFT JOIN CANH_BAO AS cb ON cb.MaLanDo = ld.MaLanDo
WHERE ld.ThoiGianDo >= '2026-10-04' AND ld.ThoiGianDo < '2026-10-11'
GROUP BY CAST(ld.ThoiGianDo AS DATE)
ORDER BY Ngay;
```

**Kết quả:**

| Ngay | SoLanDo | SoCanhBao |
|---|---|---|
| 2026-10-04 | 8 | 4 |
| 2026-10-05 | 5 | 1 |
| 2026-10-06 | 13 | 7 |
| 2026-10-07 | 8 | 5 |
| 2026-10-08 | 7 | 2 |
| 2026-10-09 | 6 | 3 |
| 2026-10-10 | 15 | 9 |

#### H.5 Trung bình theo ngày của nhịp tim và SpO2 trong 7 ngày cuối (dữ liệu vẽ biểu đồ)

```sql
SELECT
    CAST(ThoiGianDo AS DATE)                                              AS Ngay,
    CAST(AVG(CASE WHEN KyHieu = 'NHIP_TIM' THEN GiaTri END) AS DECIMAL(5,1)) AS NhipTimTB,
    CAST(AVG(CASE WHEN KyHieu = 'SPO2'     THEN GiaTri END) AS DECIMAL(5,1)) AS SpO2TB
FROM V_CHI_TIET_DANH_GIA
WHERE ThoiGianDo >= '2026-10-04' AND ThoiGianDo < '2026-10-11'
GROUP BY CAST(ThoiGianDo AS DATE)
ORDER BY Ngay;
```

**Kết quả:**

| Ngay | NhipTimTB | SpO2TB |
|---|---|---|
| 2026-10-04 | 83.5 | 96.9 |
| 2026-10-05 | 80.8 | 97.8 |
| 2026-10-06 | 78.8 | 97.9 |
| 2026-10-07 | 87.9 | 97.4 |
| 2026-10-08 | 80.0 | 97.4 |
| 2026-10-09 | 81.2 | 96.8 |
| 2026-10-10 | 78.1 | 96.5 |

#### H.6 Năm người có nhiều cảnh báo nhất, kèm tỷ lệ so với số lần đo

```sql
SELECT TOP (5)
    nd.HoTen,
    (SELECT COUNT(*) FROM LAN_DO AS ld2 WHERE ld2.MaNguoiDung = nd.MaNguoiDung) AS SoLanDo,
    COUNT(*)                                                                   AS SoCanhBao,
    SUM(CASE WHEN cb.MucDo = N'Nguy hiểm' THEN 1 ELSE 0 END)                   AS NguyHiem
FROM CANH_BAO   AS cb
JOIN LAN_DO     AS ld ON ld.MaLanDo = cb.MaLanDo
JOIN NGUOI_DUNG AS nd ON nd.MaNguoiDung = ld.MaNguoiDung
GROUP BY nd.MaNguoiDung, nd.HoTen
ORDER BY SoCanhBao DESC, nd.HoTen;
```

**Kết quả:**

| HoTen | SoLanDo | SoCanhBao | NguyHiem |
|---|---|---|---|
| Đặng Quốc Huy | 35 | 38 | 11 |
| Ngô Thị Mai | 29 | 15 | 2 |
| Nguyễn Văn An | 30 | 13 | 1 |
| Phạm Thị Dung | 33 | 13 | 0 |
| Dương Văn Nam | 18 | 9 | 0 |

#### H.7 Hiệu suất sử dụng thiết bị: số lần đo, số người dùng, ngày hoạt động

```sql
SELECT
    tb.TenThietBi,
    tb.TrangThai,
    COUNT(ld.MaLanDo)                             AS SoLanDo,
    COUNT(DISTINCT ld.MaNguoiDung)                AS SoNguoiDung,
    COUNT(DISTINCT CAST(ld.ThoiGianDo AS DATE))   AS SoNgayCoDo
FROM THIET_BI    AS tb
LEFT JOIN LAN_DO AS ld ON ld.MaThietBi = tb.MaThietBi
GROUP BY tb.MaThietBi, tb.TenThietBi, tb.TrangThai
ORDER BY SoLanDo DESC;
```

**Kết quả:**

| TenThietBi | TrangThai | SoLanDo | SoNguoiDung | SoNgayCoDo |
|---|---|---|---|---|
| ESP32 Health Monitor | Hoạt động | 123 | 12 | 30 |
| Máy đo SpO2 kẹp ngón | Hoạt động | 31 | 11 | 19 |
| Nhiệt kế hồng ngoại | Hoạt động | 23 | 11 | 15 |
| ESP32 Health Monitor (cũ) | Ngừng sử dụng | 18 | 10 | 6 |
| Máy đo huyết áp điện tử | Bảo trì | 15 | 7 | 13 |
| Máy đo SpO2 dự phòng | Hoạt động | 0 | 0 | 0 |

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
