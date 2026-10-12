-- ============================================================================
-- 02. TRIGGER
--
-- Phải chạy TRƯỚC 03_du_lieu_mau.sql: cảnh báo của dữ liệu mẫu do chính
-- trigger này sinh ra khi các giá trị đo được chèn vào.
--
--   TRG_CHI_TIET_LAN_DO_CanhBao   (Người 10) kiểm tra giá trị đo và tự tạo cảnh báo
--   TRG_HO_SO_SUC_KHOE_NgayCapNhat (Người 6) tự ghi lại ngày cập nhật hồ sơ
-- ============================================================================

USE QuanLyHoSoSucKhoe;
GO

-- ----------------------------------------------------------------------------
-- TRG_CHI_TIET_LAN_DO_CanhBao
--
-- Chạy sau khi THÊM hoặc SỬA giá trị đo. Trigger xử lý theo tập hợp (bảng ảo
-- `inserted` có thể chứa nhiều dòng), gồm ba bước:
--   1. Từ chối giá trị nằm ngoài khoảng hợp lệ của chỉ số.
--   2. Xóa cảnh báo cũ của các dòng vừa sửa (giá trị đã đổi nên phải đánh giá lại).
--   3. Tạo cảnh báo cho giá trị nằm ngoài khoảng bình thường.
--
-- Quy tắc xác định mức độ (dựa trên các cột ngưỡng của LOAI_CHI_SO):
--   BinhThuongMin <= GiaTri <= BinhThuongMax          : bình thường, không cảnh báo
--   CanhBaoMin <= GiaTri <= CanhBaoMax (còn lại)      : "Cần chú ý"
--   GiaTri < CanhBaoMin hoặc GiaTri > CanhBaoMax      : "Nguy hiểm"
-- ----------------------------------------------------------------------------
CREATE OR ALTER TRIGGER TRG_CHI_TIET_LAN_DO_CanhBao
ON CHI_TIET_LAN_DO
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    -- Bước 1: chặn dữ liệu không hợp lệ (ràng buộc liên bảng, CHECK không làm được).
    IF EXISTS (
        SELECT 1
        FROM inserted AS i
        JOIN LOAI_CHI_SO AS l ON l.MaLoaiChiSo = i.MaLoaiChiSo
        WHERE i.GiaTri < l.GiaTriMin OR i.GiaTri > l.GiaTriMax
    )
    BEGIN
        ROLLBACK TRANSACTION;
        THROW 50001, N'Giá trị đo nằm ngoài khoảng hợp lệ của chỉ số.', 1;
    END;

    -- Bước 2: bỏ cảnh báo cũ của những giá trị vừa được ghi lại.
    DELETE cb
    FROM CANH_BAO AS cb
    JOIN inserted AS i
      ON i.MaLanDo = cb.MaLanDo AND i.MaLoaiChiSo = cb.MaLoaiChiSo;

    -- Bước 3: tạo cảnh báo mới cho giá trị ngoài khoảng bình thường.
    INSERT INTO CANH_BAO (MaLanDo, MaLoaiChiSo, MucDo, NoiDung, ThoiGianTao)
    SELECT
        i.MaLanDo,
        i.MaLoaiChiSo,
        CASE
            WHEN i.GiaTri < l.CanhBaoMin OR i.GiaTri > l.CanhBaoMax THEN N'Nguy hiểm'
            ELSE N'Cần chú ý'
        END,
        -- Ví dụ: "Nhịp tim 126 bpm cao hơn khoảng bình thường (60 – 100 bpm)."
        CONCAT(
            l.TenChiSo, N' ',
            CASE WHEN l.SoThapPhan = 1
                 THEN REPLACE(CAST(i.GiaTri AS VARCHAR(10)), '.', ',')
                 ELSE CAST(CAST(i.GiaTri AS INT) AS VARCHAR(10)) END,
            N' ', l.DonViDo,
            CASE WHEN i.GiaTri > l.BinhThuongMax THEN N' cao hơn' ELSE N' thấp hơn' END,
            N' khoảng bình thường (',
            CASE WHEN l.SoThapPhan = 1
                 THEN REPLACE(CAST(l.BinhThuongMin AS VARCHAR(10)), '.', ',')
                 ELSE CAST(CAST(l.BinhThuongMin AS INT) AS VARCHAR(10)) END,
            N' – ',
            CASE WHEN l.SoThapPhan = 1
                 THEN REPLACE(CAST(l.BinhThuongMax AS VARCHAR(10)), '.', ',')
                 ELSE CAST(CAST(l.BinhThuongMax AS INT) AS VARCHAR(10)) END,
            N' ', l.DonViDo, N').'
        ),
        -- Cảnh báo phát sinh tại thời điểm đo, không phải lúc nhập liệu.
        ld.ThoiGianDo
    FROM inserted AS i
    JOIN LOAI_CHI_SO AS l ON l.MaLoaiChiSo = i.MaLoaiChiSo
    JOIN LAN_DO      AS ld ON ld.MaLanDo = i.MaLanDo
    WHERE i.GiaTri < l.BinhThuongMin OR i.GiaTri > l.BinhThuongMax
    -- Cấp MaCanhBao theo thứ tự lần đo, chỉ số để kết quả luôn như nhau.
    ORDER BY i.MaLanDo, i.MaLoaiChiSo;
END;
GO

-- ----------------------------------------------------------------------------
-- TRG_HO_SO_SUC_KHOE_NgayCapNhat
--
-- Mỗi lần sửa hồ sơ, tự ghi NgayCapNhat = thời điểm hiện tại, trừ khi câu lệnh
-- UPDATE đã chủ động gán cột này.
-- ----------------------------------------------------------------------------
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
GO

PRINT N'Đã tạo 2 trigger.';
GO
