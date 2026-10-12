-- ============================================================================
-- 02. TRIGGER — SQLite
--
-- Bản tương đương của sql/sqlserver/02_trigger.sql. Trigger của SQLite chạy
-- cho TỪNG DÒNG (dùng NEW / OLD) thay vì xử lý theo tập hợp như SQL Server,
-- và mỗi trigger chỉ gắn với một sự kiện nên phải tách riêng INSERT và UPDATE.
-- ============================================================================

-- ----------------------------------------------------------------------------
-- Giá trị đo phải nằm trong khoảng hợp lệ của chỉ số
-- ----------------------------------------------------------------------------
CREATE TRIGGER TRG_CHI_TIET_LAN_DO_KiemTra_Them
BEFORE INSERT ON CHI_TIET_LAN_DO
WHEN EXISTS (
    SELECT 1 FROM LOAI_CHI_SO
    WHERE MaLoaiChiSo = NEW.MaLoaiChiSo
      AND (NEW.GiaTri < GiaTriMin OR NEW.GiaTri > GiaTriMax)
)
BEGIN
    SELECT RAISE(ABORT, 'Giá trị đo nằm ngoài khoảng hợp lệ của chỉ số.');
END;

CREATE TRIGGER TRG_CHI_TIET_LAN_DO_KiemTra_Sua
BEFORE UPDATE OF GiaTri ON CHI_TIET_LAN_DO
WHEN EXISTS (
    SELECT 1 FROM LOAI_CHI_SO
    WHERE MaLoaiChiSo = NEW.MaLoaiChiSo
      AND (NEW.GiaTri < GiaTriMin OR NEW.GiaTri > GiaTriMax)
)
BEGIN
    SELECT RAISE(ABORT, 'Giá trị đo nằm ngoài khoảng hợp lệ của chỉ số.');
END;

-- ----------------------------------------------------------------------------
-- Tự tạo cảnh báo khi giá trị đo nằm ngoài khoảng bình thường
--   trong [CanhBaoMin, CanhBaoMax] : "Cần chú ý"
--   ngoài khoảng đó                 : "Nguy hiểm"
-- ----------------------------------------------------------------------------
CREATE TRIGGER TRG_CHI_TIET_LAN_DO_CanhBao_Them
AFTER INSERT ON CHI_TIET_LAN_DO
BEGIN
    INSERT INTO CANH_BAO (MaLanDo, MaLoaiChiSo, MucDo, NoiDung, ThoiGianTao)
    SELECT
        NEW.MaLanDo,
        NEW.MaLoaiChiSo,
        CASE WHEN NEW.GiaTri < l.CanhBaoMin OR NEW.GiaTri > l.CanhBaoMax
             THEN 'Nguy hiểm' ELSE 'Cần chú ý' END,
        -- Ví dụ: "Nhịp tim 126 bpm cao hơn khoảng bình thường (60 – 100 bpm)."
        l.TenChiSo || ' '
          || CASE WHEN l.SoThapPhan = 1
                  THEN replace(printf('%.1f', NEW.GiaTri), '.', ',')
                  ELSE CAST(CAST(NEW.GiaTri AS INTEGER) AS TEXT) END
          || ' ' || l.DonViDo
          || CASE WHEN NEW.GiaTri > l.BinhThuongMax THEN ' cao hơn' ELSE ' thấp hơn' END
          || ' khoảng bình thường ('
          || CASE WHEN l.SoThapPhan = 1
                  THEN replace(printf('%.1f', l.BinhThuongMin), '.', ',')
                  ELSE CAST(CAST(l.BinhThuongMin AS INTEGER) AS TEXT) END
          || ' – '
          || CASE WHEN l.SoThapPhan = 1
                  THEN replace(printf('%.1f', l.BinhThuongMax), '.', ',')
                  ELSE CAST(CAST(l.BinhThuongMax AS INTEGER) AS TEXT) END
          || ' ' || l.DonViDo || ').',
        -- Cảnh báo phát sinh tại thời điểm đo, không phải lúc nhập liệu.
        ld.ThoiGianDo
    FROM LOAI_CHI_SO AS l
    JOIN LAN_DO      AS ld ON ld.MaLanDo = NEW.MaLanDo
    WHERE l.MaLoaiChiSo = NEW.MaLoaiChiSo
      AND (NEW.GiaTri < l.BinhThuongMin OR NEW.GiaTri > l.BinhThuongMax);
END;

-- Sửa giá trị đo: bỏ cảnh báo cũ rồi đánh giá lại theo giá trị mới.
CREATE TRIGGER TRG_CHI_TIET_LAN_DO_CanhBao_Sua
AFTER UPDATE OF GiaTri ON CHI_TIET_LAN_DO
BEGIN
    DELETE FROM CANH_BAO
    WHERE MaLanDo = NEW.MaLanDo AND MaLoaiChiSo = NEW.MaLoaiChiSo;

    INSERT INTO CANH_BAO (MaLanDo, MaLoaiChiSo, MucDo, NoiDung, ThoiGianTao)
    SELECT
        NEW.MaLanDo,
        NEW.MaLoaiChiSo,
        CASE WHEN NEW.GiaTri < l.CanhBaoMin OR NEW.GiaTri > l.CanhBaoMax
             THEN 'Nguy hiểm' ELSE 'Cần chú ý' END,
        l.TenChiSo || ' '
          || CASE WHEN l.SoThapPhan = 1
                  THEN replace(printf('%.1f', NEW.GiaTri), '.', ',')
                  ELSE CAST(CAST(NEW.GiaTri AS INTEGER) AS TEXT) END
          || ' ' || l.DonViDo
          || CASE WHEN NEW.GiaTri > l.BinhThuongMax THEN ' cao hơn' ELSE ' thấp hơn' END
          || ' khoảng bình thường ('
          || CASE WHEN l.SoThapPhan = 1
                  THEN replace(printf('%.1f', l.BinhThuongMin), '.', ',')
                  ELSE CAST(CAST(l.BinhThuongMin AS INTEGER) AS TEXT) END
          || ' – '
          || CASE WHEN l.SoThapPhan = 1
                  THEN replace(printf('%.1f', l.BinhThuongMax), '.', ',')
                  ELSE CAST(CAST(l.BinhThuongMax AS INTEGER) AS TEXT) END
          || ' ' || l.DonViDo || ').',
        ld.ThoiGianDo
    FROM LOAI_CHI_SO AS l
    JOIN LAN_DO      AS ld ON ld.MaLanDo = NEW.MaLanDo
    WHERE l.MaLoaiChiSo = NEW.MaLoaiChiSo
      AND (NEW.GiaTri < l.BinhThuongMin OR NEW.GiaTri > l.BinhThuongMax);
END;

-- ----------------------------------------------------------------------------
-- Ràng buộc "không ở tương lai" (SQLite không cho dùng 'now' trong CHECK)
-- ----------------------------------------------------------------------------
CREATE TRIGGER TRG_NGUOI_DUNG_NgaySinh_Them
BEFORE INSERT ON NGUOI_DUNG
WHEN NEW.NgaySinh > date('now', 'localtime')
BEGIN
    SELECT RAISE(ABORT, 'Ngày sinh không được ở tương lai.');
END;

CREATE TRIGGER TRG_NGUOI_DUNG_NgaySinh_Sua
BEFORE UPDATE OF NgaySinh ON NGUOI_DUNG
WHEN NEW.NgaySinh > date('now', 'localtime')
BEGIN
    SELECT RAISE(ABORT, 'Ngày sinh không được ở tương lai.');
END;

CREATE TRIGGER TRG_LAN_DO_ThoiGianDo_Them
BEFORE INSERT ON LAN_DO
WHEN NEW.ThoiGianDo > datetime('now', 'localtime', '+5 minutes')
BEGIN
    SELECT RAISE(ABORT, 'Thời gian đo không được ở tương lai.');
END;

CREATE TRIGGER TRG_LAN_DO_ThoiGianDo_Sua
BEFORE UPDATE OF ThoiGianDo ON LAN_DO
WHEN NEW.ThoiGianDo > datetime('now', 'localtime', '+5 minutes')
BEGIN
    SELECT RAISE(ABORT, 'Thời gian đo không được ở tương lai.');
END;

-- ----------------------------------------------------------------------------
-- Sửa hồ sơ thì tự ghi lại ngày cập nhật (trừ khi lệnh UPDATE đã gán cột này)
-- ----------------------------------------------------------------------------
CREATE TRIGGER TRG_HO_SO_SUC_KHOE_NgayCapNhat
AFTER UPDATE OF ChieuCao, CanNang, NhomMau, TienSuBenh, DiUng ON HO_SO_SUC_KHOE
WHEN NEW.NgayCapNhat = OLD.NgayCapNhat
BEGIN
    UPDATE HO_SO_SUC_KHOE
    SET NgayCapNhat = datetime('now', 'localtime')
    WHERE MaHoSo = NEW.MaHoSo;
END;
