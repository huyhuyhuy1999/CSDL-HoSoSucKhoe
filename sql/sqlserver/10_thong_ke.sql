-- ============================================================================
-- 10. SQL NÂNG CAO VÀ THỐNG KÊ (Người 11)
--
-- Tổng hợp cả 7 bảng sau khi các module đã hoàn thành:
--   A. FUNCTION     hàm tính tuổi, BMI, đánh giá chỉ số
--   B. VIEW         các khung nhìn ghép bảng dùng lại nhiều lần
--   C. PROCEDURE    thủ tục thêm lần đo, tra lịch sử, thống kê, tìm kiếm
--   D. JOIN         ghép nhiều bảng
--   E. GROUP BY     COUNT, AVG, MAX, MIN
--   F. HAVING       lọc sau khi gom nhóm
--   G. SUBQUERY     truy vấn con, tập hợp, CTE, hàm cửa sổ
--   H. BÁO CÁO      các báo cáo thống kê tổng hợp
--
-- File này không làm thay đổi dữ liệu mẫu (các lệnh ghi nằm trong giao dịch
-- rồi ROLLBACK). Phải chạy trước 11_kiem_thu.sql.
-- ============================================================================

USE QuanLyHoSoSucKhoe;
GO

-- ============================================================================
-- A. FUNCTION
-- ============================================================================

-- A.1 Tuổi tính đến một ngày (NULL = hôm nay)
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
GO

-- A.2 Chỉ số khối cơ thể: cân nặng (kg) chia bình phương chiều cao (m)
CREATE OR ALTER FUNCTION dbo.FN_TinhBMI (@ChieuCao DECIMAL(5,1), @CanNang DECIMAL(5,1))
RETURNS DECIMAL(4,1)
AS
BEGIN
    IF @ChieuCao IS NULL OR @ChieuCao <= 0 RETURN NULL;
    RETURN CAST(@CanNang / POWER(@ChieuCao / 100.0, 2) AS DECIMAL(4,1));
END;
GO

-- A.3 Phân loại BMI theo thang dành cho người châu Á
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
GO

-- A.4 Mức độ của một giá trị đo theo ngưỡng của chỉ số
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
GO

-- A.5 Hàm trả về bảng: giá trị mới nhất của từng chỉ số đối với một người
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
GO

-- Dùng thử các hàm
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
GO

-- ============================================================================
-- B. VIEW
-- ============================================================================

-- B.1 Hồ sơ tổng hợp: người dùng + hồ sơ + tuổi + BMI + số liệu đo
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
GO

-- B.2 Từng giá trị đo kèm người, thời gian, chỉ số và mức độ đánh giá
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
GO

-- B.3 Mỗi lần đo một dòng: năm chỉ số thành năm cột, kèm mức độ nặng nhất
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
GO

-- B.4 Cảnh báo kèm người được đo, chỉ số và giá trị đo
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
GO

-- Dùng thử các view
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
GO

-- ============================================================================
-- C. PROCEDURE
-- ============================================================================

-- C.1 Thêm một lần đo cùng các chỉ số trong MỘT giao dịch.
--     Chỉ số nào không đo thì truyền NULL. Có @MaThietBi thì nguồn là
--     "Thiết bị", không có thì là "Thủ công". Cảnh báo do trigger tự tạo.
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
GO

-- C.2 Lịch sử đo theo người và khoảng thời gian (tham số NULL = không lọc)
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
GO

-- C.3 Thống kê từng chỉ số trong một khoảng thời gian
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
GO

-- C.4 Tìm người dùng theo tên (không dấu), giới tính và khoảng tuổi
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
GO

-- Dùng thử các thủ tục
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
GO

EXEC SP_LichSuDo @MaNguoiDung = 9, @TuNgay = '2026-10-06', @DenNgay = '2026-10-08';

EXEC SP_ThongKeChiSo @TuNgay = '2026-10-04', @DenNgay = '2026-10-10';

EXEC SP_TimNguoiDung @TuKhoa = N'thi', @GioiTinh = N'Nữ', @TuoiMin = 40;
GO

-- ============================================================================
-- D. JOIN
-- ============================================================================

-- D.1 INNER JOIN năm bảng: từ một giá trị đo lần ra người, thiết bị và chỉ số
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

-- D.2 LEFT JOIN: mọi người dùng, kể cả người không có cảnh báo chưa xem
SELECT nd.HoTen, COUNT(cb.MaCanhBao) AS SoCanhBaoChuaXem
FROM NGUOI_DUNG    AS nd
LEFT JOIN LAN_DO   AS ld ON ld.MaNguoiDung = nd.MaNguoiDung
LEFT JOIN CANH_BAO AS cb ON cb.MaLanDo = ld.MaLanDo AND cb.DaXem = 0
GROUP BY nd.MaNguoiDung, nd.HoTen
ORDER BY SoCanhBaoChuaXem DESC, nd.HoTen;

-- D.3 SELF JOIN: các cặp người dùng cùng nhóm máu
SELECT a.HoTen AS NguoiThuNhat, b.HoTen AS NguoiThuHai, ha.NhomMau
FROM HO_SO_SUC_KHOE AS ha
JOIN HO_SO_SUC_KHOE AS hb ON hb.NhomMau = ha.NhomMau AND hb.MaNguoiDung > ha.MaNguoiDung
JOIN NGUOI_DUNG     AS a  ON a.MaNguoiDung = ha.MaNguoiDung
JOIN NGUOI_DUNG     AS b  ON b.MaNguoiDung = hb.MaNguoiDung
ORDER BY ha.NhomMau, a.HoTen;

-- D.4 CROSS JOIN + LEFT JOIN: ma trận người × chỉ số, đếm số lần đã đo
--     (ô bằng 0 cho biết người đó chưa từng được đo chỉ số ấy)
SELECT nd.HoTen, l.TenChiSo, COUNT(ct.MaLanDo) AS SoLanDo
FROM NGUOI_DUNG       AS nd
CROSS JOIN LOAI_CHI_SO AS l
LEFT JOIN LAN_DO          AS ld ON ld.MaNguoiDung = nd.MaNguoiDung
LEFT JOIN CHI_TIET_LAN_DO AS ct ON ct.MaLanDo = ld.MaLanDo AND ct.MaLoaiChiSo = l.MaLoaiChiSo
WHERE nd.MaNguoiDung IN (5, 12)
GROUP BY nd.MaNguoiDung, nd.HoTen, l.MaLoaiChiSo, l.TenChiSo
ORDER BY nd.MaNguoiDung, l.MaLoaiChiSo;
GO

-- ============================================================================
-- E. GROUP BY với COUNT, AVG, MAX, MIN
-- ============================================================================

-- E.1 Số lần đo, lần đo đầu và cuối của từng người
SELECT
    nd.HoTen,
    COUNT(*)            AS SoLanDo,
    MIN(ld.ThoiGianDo)  AS LanDoDauTien,
    MAX(ld.ThoiGianDo)  AS LanDoGanNhat
FROM LAN_DO     AS ld
JOIN NGUOI_DUNG AS nd ON nd.MaNguoiDung = ld.MaNguoiDung
GROUP BY nd.MaNguoiDung, nd.HoTen
ORDER BY SoLanDo DESC;

-- E.2 Trung bình, thấp nhất, cao nhất của từng chỉ số
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

-- E.3 Gom theo hai cột: nhịp tim trung bình của từng người theo buổi đo
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

-- E.4 Số lần đo và số cảnh báo theo tuần
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

-- E.5 Số lần đo theo nhóm tuổi của người được đo
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
GO

-- ============================================================================
-- F. HAVING
-- ============================================================================

-- F.1 Người có từ 25 lần đo trở lên
SELECT nd.HoTen, COUNT(*) AS SoLanDo
FROM LAN_DO     AS ld
JOIN NGUOI_DUNG AS nd ON nd.MaNguoiDung = ld.MaNguoiDung
GROUP BY nd.MaNguoiDung, nd.HoTen
HAVING COUNT(*) >= 25
ORDER BY SoLanDo DESC;

-- F.2 Người có huyết áp tâm thu TRUNG BÌNH vượt khoảng bình thường
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

-- F.3 Ngày có từ 12 lần đo trở lên
SELECT CAST(ThoiGianDo AS DATE) AS Ngay, COUNT(*) AS SoLanDo
FROM LAN_DO
GROUP BY CAST(ThoiGianDo AS DATE)
HAVING COUNT(*) >= 12
ORDER BY SoLanDo DESC, Ngay;

-- F.4 WHERE lọc trước khi gom nhóm, HAVING lọc sau: người có từ 3 cảnh báo
--     NGUY HIỂM trở lên
SELECT nd.HoTen, COUNT(*) AS SoCanhBaoNguyHiem
FROM CANH_BAO   AS cb
JOIN LAN_DO     AS ld ON ld.MaLanDo = cb.MaLanDo
JOIN NGUOI_DUNG AS nd ON nd.MaNguoiDung = ld.MaNguoiDung
WHERE cb.MucDo = N'Nguy hiểm'
GROUP BY nd.MaNguoiDung, nd.HoTen
HAVING COUNT(*) >= 3
ORDER BY SoCanhBaoNguyHiem DESC;

-- F.5 Chỉ số có hơn 10% giá trị nằm ngoài khoảng bình thường
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
GO

-- ============================================================================
-- G. SUBQUERY, TẬP HỢP, CTE VÀ HÀM CỬA SỔ
-- ============================================================================

-- G.1 Truy vấn con vô hướng: lần đo có nhịp tim cao hơn mức trung bình chung
SELECT TOP (8) nd.HoTen, ld.ThoiGianDo, ct.GiaTri AS NhipTim,
       (SELECT CAST(AVG(GiaTri) AS DECIMAL(6,1))
          FROM CHI_TIET_LAN_DO WHERE MaLoaiChiSo = 2) AS TrungBinhChung
FROM CHI_TIET_LAN_DO AS ct
JOIN LAN_DO          AS ld ON ld.MaLanDo = ct.MaLanDo
JOIN NGUOI_DUNG      AS nd ON nd.MaNguoiDung = ld.MaNguoiDung
WHERE ct.MaLoaiChiSo = 2
  AND ct.GiaTri > (SELECT AVG(GiaTri) FROM CHI_TIET_LAN_DO WHERE MaLoaiChiSo = 2)
ORDER BY ct.GiaTri DESC;

-- G.2 Truy vấn con với IN: người từng có cảnh báo mức nguy hiểm
SELECT MaNguoiDung, HoTen
FROM NGUOI_DUNG
WHERE MaNguoiDung IN (
    SELECT ld.MaNguoiDung
    FROM CANH_BAO AS cb
    JOIN LAN_DO   AS ld ON ld.MaLanDo = cb.MaLanDo
    WHERE cb.MucDo = N'Nguy hiểm'
)
ORDER BY HoTen;

-- G.3 NOT EXISTS: người chưa từng có cảnh báo nào
SELECT nd.MaNguoiDung, nd.HoTen
FROM NGUOI_DUNG AS nd
WHERE NOT EXISTS (
    SELECT 1
    FROM CANH_BAO AS cb
    JOIN LAN_DO   AS ld ON ld.MaLanDo = cb.MaLanDo
    WHERE ld.MaNguoiDung = nd.MaNguoiDung
)
ORDER BY nd.HoTen;

-- G.4 Truy vấn con tương quan: lần có huyết áp tâm thu cao nhất của mỗi người
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

-- G.5 Truy vấn con trong FROM (bảng dẫn xuất): tỷ lệ lần đo bất thường của từng người
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

-- G.6 ALL: người có số lần đo nhiều hơn mọi người thuộc nhóm dưới 40 tuổi
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

-- G.7 EXCEPT: người có cảnh báo huyết áp nhưng không có cảnh báo nhịp tim
SELECT nd.HoTen
FROM V_CANH_BAO_CHI_TIET AS v
JOIN NGUOI_DUNG AS nd ON nd.MaNguoiDung = v.MaNguoiDung
WHERE v.MaLoaiChiSo IN (4, 5)
EXCEPT
SELECT nd.HoTen
FROM V_CANH_BAO_CHI_TIET AS v
JOIN NGUOI_DUNG AS nd ON nd.MaNguoiDung = v.MaNguoiDung
WHERE v.MaLoaiChiSo = 2;

-- G.8 UNION ALL: dòng thời gian của một người, trộn lần đo và cảnh báo
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
GO

-- G.9 CTE: xếp hạng người dùng theo số cảnh báo (RANK cho phép đồng hạng)
WITH SoCanhBaoTheoNguoi AS (
    SELECT MaNguoiDung, HoTen, COUNT(*) AS SoCanhBao
    FROM V_CANH_BAO_CHI_TIET
    GROUP BY MaNguoiDung, HoTen
)
SELECT RANK() OVER (ORDER BY SoCanhBao DESC) AS Hang, HoTen, SoCanhBao
FROM SoCanhBaoTheoNguoi
ORDER BY Hang, HoTen;

-- G.10 Hàm cửa sổ LAG: chênh lệch huyết áp tâm thu so với lần đo trước của cùng người
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

-- G.11 Trung bình trượt 3 lần đo gần nhất của nhịp tim
SELECT TOP (10)
    ThoiGianDo,
    NhipTim,
    CAST(AVG(NhipTim) OVER (ORDER BY ThoiGianDo
                            ROWS BETWEEN 2 PRECEDING AND CURRENT ROW)
         AS DECIMAL(6,1)) AS TrungBinh3LanGanNhat
FROM V_LAN_DO_TONG_HOP
WHERE MaNguoiDung = 7 AND NhipTim IS NOT NULL
ORDER BY ThoiGianDo DESC;
GO

-- ============================================================================
-- H. BÁO CÁO THỐNG KÊ
-- ============================================================================

-- H.1 Tổng quan hệ thống trên một dòng
SELECT
    (SELECT COUNT(*) FROM NGUOI_DUNG)                               AS SoNguoiDung,
    (SELECT COUNT(*) FROM HO_SO_SUC_KHOE)                           AS SoHoSo,
    (SELECT COUNT(*) FROM THIET_BI WHERE TrangThai = N'Hoạt động')  AS ThietBiHoatDong,
    (SELECT COUNT(*) FROM LAN_DO)                                   AS TongLanDo,
    (SELECT COUNT(*) FROM CHI_TIET_LAN_DO)                          AS TongGiaTriDo,
    (SELECT COUNT(*) FROM CANH_BAO)                                 AS TongCanhBao,
    (SELECT COUNT(*) FROM CANH_BAO WHERE DaXem = 0)                 AS CanhBaoChuaXem;

-- H.2 Báo cáo theo người: số lần đo, trung bình từng chỉ số, số cảnh báo
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

-- H.3 Phân bố kết quả lần đo theo mức độ
SELECT
    MucDo,
    COUNT(*) AS SoLanDo,
    CAST(100.0 * COUNT(*) / SUM(COUNT(*)) OVER () AS DECIMAL(5,1)) AS TyLePhanTram
FROM V_LAN_DO_TONG_HOP
GROUP BY MucDo
ORDER BY CASE MucDo WHEN N'Bình thường' THEN 1 WHEN N'Cần chú ý' THEN 2 ELSE 3 END;

-- H.4 Số lần đo và số cảnh báo theo ngày trong 7 ngày cuối của dữ liệu mẫu
SELECT
    CAST(ld.ThoiGianDo AS DATE)   AS Ngay,
    COUNT(DISTINCT ld.MaLanDo)    AS SoLanDo,
    COUNT(cb.MaCanhBao)           AS SoCanhBao
FROM LAN_DO        AS ld
LEFT JOIN CANH_BAO AS cb ON cb.MaLanDo = ld.MaLanDo
WHERE ld.ThoiGianDo >= '2026-10-04' AND ld.ThoiGianDo < '2026-10-11'
GROUP BY CAST(ld.ThoiGianDo AS DATE)
ORDER BY Ngay;

-- H.5 Trung bình theo ngày của nhịp tim và SpO2 trong 7 ngày cuối (dữ liệu vẽ biểu đồ)
SELECT
    CAST(ThoiGianDo AS DATE)                                              AS Ngay,
    CAST(AVG(CASE WHEN KyHieu = 'NHIP_TIM' THEN GiaTri END) AS DECIMAL(5,1)) AS NhipTimTB,
    CAST(AVG(CASE WHEN KyHieu = 'SPO2'     THEN GiaTri END) AS DECIMAL(5,1)) AS SpO2TB
FROM V_CHI_TIET_DANH_GIA
WHERE ThoiGianDo >= '2026-10-04' AND ThoiGianDo < '2026-10-11'
GROUP BY CAST(ThoiGianDo AS DATE)
ORDER BY Ngay;

-- H.6 Năm người có nhiều cảnh báo nhất, kèm tỷ lệ so với số lần đo
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

-- H.7 Hiệu suất sử dụng thiết bị: số lần đo, số người dùng, ngày hoạt động
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
GO
