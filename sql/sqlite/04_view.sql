-- ============================================================================
-- 04. VIEW — SQLite
--
-- Bản tương đương các view ở sql/sqlserver/10_thong_ke.sql. SQLite không có
-- FUNCTION / PROCEDURE do người dùng viết bằng SQL, nên công thức tính tuổi,
-- BMI và mức độ được viết thẳng trong view.
-- ============================================================================

-- Từng giá trị đo kèm người, thời gian, chỉ số và mức độ đánh giá
CREATE VIEW V_CHI_TIET_DANH_GIA AS
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
        WHEN ct.GiaTri BETWEEN l.BinhThuongMin AND l.BinhThuongMax THEN 'Bình thường'
        WHEN ct.GiaTri BETWEEN l.CanhBaoMin    AND l.CanhBaoMax    THEN 'Cần chú ý'
        ELSE 'Nguy hiểm'
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

-- Mỗi lần đo một dòng: năm chỉ số thành năm cột, kèm mức độ nặng nhất
CREATE VIEW V_LAN_DO_TONG_HOP AS
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
    COALESCE(SUM(ct.CapDo > 0), 0)                                AS SoChiSoBatThuong,
    COALESCE(MAX(ct.CapDo), 0)                                    AS CapDo,
    CASE COALESCE(MAX(ct.CapDo), 0)
        WHEN 2 THEN 'Nguy hiểm'
        WHEN 1 THEN 'Cần chú ý'
        ELSE 'Bình thường'
    END                                                           AS MucDo
FROM LAN_DO                   AS ld
JOIN NGUOI_DUNG               AS nd ON nd.MaNguoiDung = ld.MaNguoiDung
LEFT JOIN THIET_BI            AS tb ON tb.MaThietBi = ld.MaThietBi
LEFT JOIN V_CHI_TIET_DANH_GIA AS ct ON ct.MaLanDo = ld.MaLanDo
GROUP BY ld.MaLanDo;

-- Cảnh báo kèm người được đo, chỉ số và giá trị đo
CREATE VIEW V_CANH_BAO_CHI_TIET AS
SELECT
    cb.MaCanhBao,
    cb.MaLanDo,
    ld.MaNguoiDung,
    nd.HoTen,
    cb.MaLoaiChiSo,
    l.KyHieu,
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

-- Hồ sơ tổng hợp: người dùng + hồ sơ + tuổi + BMI + số liệu đo
CREATE VIEW V_HO_SO_TONG_HOP AS
SELECT
    nd.MaNguoiDung,
    nd.HoTen,
    nd.GioiTinh,
    nd.NgaySinh,
    -- Tuổi: so sánh dạng 'YYYY.MMDD' rồi lấy phần nguyên, tự xử lý trường hợp
    -- chưa tới sinh nhật trong năm.
    CAST(strftime('%Y.%m%d', 'now', 'localtime') - strftime('%Y.%m%d', nd.NgaySinh)
         AS INTEGER)                                           AS Tuoi,
    nd.SoDienThoai,
    nd.Email,
    nd.DiaChi,
    hs.MaHoSo,
    hs.ChieuCao,
    hs.CanNang,
    ROUND(hs.CanNang / ((hs.ChieuCao / 100.0) * (hs.ChieuCao / 100.0)), 1) AS BMI,
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
