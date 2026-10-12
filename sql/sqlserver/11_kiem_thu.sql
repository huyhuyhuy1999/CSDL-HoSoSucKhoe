-- ============================================================================
-- 11. KIỂM THỬ (Người 12)
--
-- Chạy sau khi đã chạy 00 → 10. Mỗi ca kiểm thử chạy trong một giao dịch rồi
-- ROLLBACK, nên file này không làm thay đổi dữ liệu mẫu.
--
-- Kết quả nằm ở bảng cuối cùng: mỗi dòng một ca, cột KetLuan là ĐẠT hoặc
-- KHÔNG ĐẠT. Dòng tổng kết cho biết số ca đạt trên tổng số ca.
--
-- Nhóm ca kiểm thử:
--   PK  khóa chính            UQ  ràng buộc duy nhất      FK  khóa ngoại
--   CS  xóa dây chuyền        CK  dữ liệu không hợp lệ    TG  trigger
--   CR  thêm / sửa / xóa      TK  tìm kiếm và lọc         ST  thống kê
-- ============================================================================

USE QuanLyHoSoSucKhoe;
GO

SET NOCOUNT ON;
GO

IF OBJECT_ID('tempdb..#KetQua') IS NOT NULL DROP TABLE #KetQua;

CREATE TABLE #KetQua (
    STT      INT IDENTITY(1,1) PRIMARY KEY,
    Ma       VARCHAR(10)   NOT NULL,
    MoTa     NVARCHAR(150) NOT NULL,
    MongDoi  NVARCHAR(100) NOT NULL,
    ThucTe   NVARCHAR(300) NOT NULL,
    KetLuan  NVARCHAR(10)  NOT NULL
);
GO

-- ----------------------------------------------------------------------------
-- Thủ tục phụ 1: chạy một lệnh PHẢI BỊ TỪ CHỐI và đối chiếu lỗi nhận được.
--   @MaLoi       mã lỗi mong đợi (2627/2601 trùng khóa, 547 FK hoặc CHECK,
--                515 NOT NULL, 5000x lỗi do trigger / thủ tục tự báo)
--   @TenRangBuoc tên ràng buộc phải xuất hiện trong thông báo lỗi (nếu có)
-- ----------------------------------------------------------------------------
CREATE OR ALTER PROCEDURE #KT_PhaiLoi
    @Ma          VARCHAR(10),
    @MoTa        NVARCHAR(150),
    @Lenh        NVARCHAR(MAX),
    @MaLoi       INT,
    @TenRangBuoc NVARCHAR(100) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @MongDoi NVARCHAR(100) = CONCAT(N'Bị từ chối, lỗi ', @MaLoi,
        CASE WHEN @TenRangBuoc IS NULL THEN N'' ELSE CONCAT(N' (', @TenRangBuoc, N')') END);
    DECLARE @ThucTe  NVARCHAR(300);
    DECLARE @Dat     BIT = 0;

    BEGIN TRY
        BEGIN TRANSACTION;
        EXEC sp_executesql @Lenh;
        SET @ThucTe = N'Lệnh chạy thành công, không bị chặn';
    END TRY
    BEGIN CATCH
        SET @ThucTe = CONCAT(N'Lỗi ', ERROR_NUMBER(), N': ', LEFT(ERROR_MESSAGE(), 200));
        -- COLLATE DATABASE_DEFAULT: thủ tục tạm nằm trong tempdb, nơi có thể dùng
        -- collation khác với cơ sở dữ liệu này.
        IF ERROR_NUMBER() = @MaLoi
           AND (@TenRangBuoc IS NULL
                OR ERROR_MESSAGE() COLLATE DATABASE_DEFAULT
                   LIKE N'%' + @TenRangBuoc COLLATE DATABASE_DEFAULT + N'%')
            SET @Dat = 1;
    END CATCH;

    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;

    INSERT INTO #KetQua (Ma, MoTa, MongDoi, ThucTe, KetLuan)
    VALUES (@Ma, @MoTa, @MongDoi, @ThucTe, CASE WHEN @Dat = 1 THEN N'ĐẠT' ELSE N'KHÔNG ĐẠT' END);
END;
GO

-- ----------------------------------------------------------------------------
-- Thủ tục phụ 2: chạy một đoạn lệnh PHẢI THÀNH CÔNG và trả về một con số qua
-- biến @kq, rồi so với giá trị mong đợi.
-- ----------------------------------------------------------------------------
CREATE OR ALTER PROCEDURE #KT_BangGiaTri
    @Ma      VARCHAR(10),
    @MoTa    NVARCHAR(150),
    @Lenh    NVARCHAR(MAX),
    @MongDoi INT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @kq     INT;
    DECLARE @ThucTe NVARCHAR(300);

    BEGIN TRY
        BEGIN TRANSACTION;
        EXEC sp_executesql @Lenh, N'@kq INT OUTPUT', @kq = @kq OUTPUT;
        SET @ThucTe = ISNULL(CAST(@kq AS NVARCHAR(20)), N'NULL');
    END TRY
    BEGIN CATCH
        SET @kq = NULL;
        SET @ThucTe = CONCAT(N'Lỗi ', ERROR_NUMBER(), N': ', LEFT(ERROR_MESSAGE(), 200));
    END CATCH;

    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;

    INSERT INTO #KetQua (Ma, MoTa, MongDoi, ThucTe, KetLuan)
    VALUES (@Ma, @MoTa, CAST(@MongDoi AS NVARCHAR(20)), @ThucTe,
            CASE WHEN @kq = @MongDoi THEN N'ĐẠT' ELSE N'KHÔNG ĐẠT' END);
END;
GO

-- ============================================================================
-- PK — KHÓA CHÍNH
-- ============================================================================

EXEC #KT_PhaiLoi 'PK-01', N'Thêm người dùng trùng MaNguoiDung = 1',
    N'SET IDENTITY_INSERT NGUOI_DUNG ON;
      INSERT INTO NGUOI_DUNG (MaNguoiDung, HoTen, GioiTinh, NgaySinh)
      VALUES (1, N''Người Trùng Mã'', N''Nam'', ''2000-01-01'');',
    2627, N'PK_NGUOI_DUNG';

EXEC #KT_PhaiLoi 'PK-02', N'Thêm lại chỉ số đã có trong lần đo (trùng khóa chính kép)',
    N'INSERT INTO CHI_TIET_LAN_DO (MaLanDo, MaLoaiChiSo, GiaTri) VALUES (260, 2, 80);',
    2627, N'PK_CHI_TIET_LAN_DO';

EXEC #KT_PhaiLoi 'PK-03', N'Thêm thiết bị trùng MaThietBi = 1',
    N'SET IDENTITY_INSERT THIET_BI ON;
      INSERT INTO THIET_BI (MaThietBi, TenThietBi, LoaiThietBi, MaDinhDanh)
      VALUES (1, N''Thiết bị trùng mã'', N''Nhiệt kế'', ''TRUNG-MA-001'');',
    2627, N'PK_THIET_BI';

-- ============================================================================
-- UQ — RÀNG BUỘC DUY NHẤT
-- ============================================================================

EXEC #KT_PhaiLoi 'UQ-01', N'Lập hồ sơ thứ hai cho cùng một người (vi phạm quan hệ 1–1)',
    N'INSERT INTO HO_SO_SUC_KHOE (MaNguoiDung, ChieuCao, CanNang, NhomMau)
      VALUES (1, 170, 65, ''O+'');',
    2627, N'UQ_HO_SO_SUC_KHOE_MaNguoiDung';

EXEC #KT_PhaiLoi 'UQ-02', N'Thêm thiết bị trùng mã định danh',
    N'INSERT INTO THIET_BI (TenThietBi, LoaiThietBi, MaDinhDanh)
      VALUES (N''ESP32 giả mạo'', N''Thiết bị đa chỉ số'', ''ESP32-A4:CF:12:9B:7E:01'');',
    2627, N'UQ_THIET_BI_MaDinhDanh';

EXEC #KT_PhaiLoi 'UQ-03', N'Thêm người dùng trùng email',
    N'INSERT INTO NGUOI_DUNG (HoTen, GioiTinh, NgaySinh, Email)
      VALUES (N''Người Trùng Email'', N''Nữ'', ''1995-05-05'', ''an.nguyen@example.com'');',
    2601, N'UQ_NGUOI_DUNG_Email';

EXEC #KT_BangGiaTri 'UQ-04', N'Hai người dùng cùng không có email vẫn thêm được',
    N'INSERT INTO NGUOI_DUNG (HoTen, GioiTinh, NgaySinh)
      VALUES (N''Không Email Một'', N''Nam'', ''1990-01-01''),
             (N''Không Email Hai'', N''Nữ'', ''1991-02-02'');
      SELECT @kq = COUNT(*) FROM NGUOI_DUNG WHERE Email IS NULL;',
    3;

EXEC #KT_PhaiLoi 'UQ-05', N'Thêm loại chỉ số trùng ký hiệu',
    N'INSERT INTO LOAI_CHI_SO (KyHieu, TenChiSo, DonViDo, GiaTriMin, GiaTriMax,
                               BinhThuongMin, BinhThuongMax, CanhBaoMin, CanhBaoMax)
      VALUES (''NHIP_TIM'', N''Nhịp tim (bản sao)'', N''bpm'', 20, 250, 60, 100, 50, 120);',
    2627, N'UQ_LOAI_CHI_SO_KyHieu';

-- ============================================================================
-- FK — KHÓA NGOẠI
-- ============================================================================

EXEC #KT_PhaiLoi 'FK-01', N'Lập hồ sơ cho người dùng không tồn tại',
    N'INSERT INTO HO_SO_SUC_KHOE (MaNguoiDung, ChieuCao, CanNang, NhomMau)
      VALUES (9999, 170, 65, ''O+'');',
    547, N'FK_HO_SO_SUC_KHOE_NGUOI_DUNG';

EXEC #KT_PhaiLoi 'FK-02', N'Thêm lần đo cho người dùng không tồn tại',
    N'INSERT INTO LAN_DO (MaNguoiDung, NguonDuLieu) VALUES (9999, N''Thủ công'');',
    547, N'FK_LAN_DO_NGUOI_DUNG';

EXEC #KT_PhaiLoi 'FK-03', N'Thêm lần đo bằng thiết bị không tồn tại',
    N'INSERT INTO LAN_DO (MaNguoiDung, MaThietBi, NguonDuLieu) VALUES (1, 9999, N''Thiết bị'');',
    547, N'FK_LAN_DO_THIET_BI';

EXEC #KT_PhaiLoi 'FK-04', N'Thêm giá trị đo cho loại chỉ số không tồn tại',
    N'INSERT INTO CHI_TIET_LAN_DO (MaLanDo, MaLoaiChiSo, GiaTri) VALUES (260, 99, 50);',
    547, N'FK_CHI_TIET_LAN_DO_LOAI_CHI_SO';

EXEC #KT_PhaiLoi 'FK-05', N'Thêm giá trị đo cho lần đo không tồn tại',
    N'INSERT INTO CHI_TIET_LAN_DO (MaLanDo, MaLoaiChiSo, GiaTri) VALUES (99999, 2, 80);',
    547, N'FK_CHI_TIET_LAN_DO_LAN_DO';

EXEC #KT_PhaiLoi 'FK-06', N'Xóa thiết bị đã có lần đo',
    N'DELETE FROM THIET_BI WHERE MaThietBi = 1;',
    547, N'FK_LAN_DO_THIET_BI';

EXEC #KT_PhaiLoi 'FK-07', N'Xóa loại chỉ số đã có giá trị đo',
    N'DELETE FROM LOAI_CHI_SO WHERE MaLoaiChiSo = 2;',
    547, N'FK_CHI_TIET_LAN_DO_LOAI_CHI_SO';

EXEC #KT_PhaiLoi 'FK-08', N'Thêm cảnh báo cho giá trị đo không tồn tại',
    N'INSERT INTO CANH_BAO (MaLanDo, MaLoaiChiSo, MucDo, NoiDung)
      VALUES (261, 4, N''Nguy hiểm'', N''Cảnh báo không có giá trị đo'');',
    547, N'FK_CANH_BAO_CHI_TIET_LAN_DO';

-- ============================================================================
-- CS — XÓA DÂY CHUYỀN (ON DELETE CASCADE)
-- ============================================================================

EXEC #KT_BangGiaTri 'CS-01', N'Xóa người dùng 12: hồ sơ, lần đo, giá trị đo của họ mất theo',
    N'DELETE FROM NGUOI_DUNG WHERE MaNguoiDung = 12;
      SELECT @kq =
          (SELECT COUNT(*) FROM HO_SO_SUC_KHOE WHERE MaNguoiDung = 12)
        + (SELECT COUNT(*) FROM LAN_DO WHERE MaNguoiDung = 12)
        + (SELECT COUNT(*) FROM CHI_TIET_LAN_DO AS ct
            WHERE NOT EXISTS (SELECT 1 FROM LAN_DO AS ld WHERE ld.MaLanDo = ct.MaLanDo));',
    0;

EXEC #KT_BangGiaTri 'CS-02', N'Xóa người dùng 12: tổng số lần đo giảm đúng 15',
    N'DELETE FROM NGUOI_DUNG WHERE MaNguoiDung = 12;
      SELECT @kq = COUNT(*) FROM LAN_DO;',
    250;

EXEC #KT_BangGiaTri 'CS-03', N'Xóa lần đo 260: 5 giá trị đo và 3 cảnh báo của nó mất theo',
    N'DELETE FROM LAN_DO WHERE MaLanDo = 260;
      SELECT @kq = (SELECT COUNT(*) FROM CHI_TIET_LAN_DO WHERE MaLanDo = 260)
                 + (SELECT COUNT(*) FROM CANH_BAO WHERE MaLanDo = 260);',
    0;

EXEC #KT_BangGiaTri 'CS-04', N'Xóa một giá trị đo: cảnh báo của nó mất theo, cảnh báo khác còn',
    N'DELETE FROM CHI_TIET_LAN_DO WHERE MaLanDo = 260 AND MaLoaiChiSo = 2;
      SELECT @kq = COUNT(*) FROM CANH_BAO WHERE MaLanDo = 260;',
    2;

EXEC #KT_BangGiaTri 'CS-05', N'Xóa hồ sơ không làm mất người dùng',
    N'DELETE FROM HO_SO_SUC_KHOE WHERE MaNguoiDung = 12;
      SELECT @kq = COUNT(*) FROM NGUOI_DUNG WHERE MaNguoiDung = 12;',
    1;

-- ============================================================================
-- CK — DỮ LIỆU KHÔNG HỢP LỆ (CHECK, NOT NULL)
-- ============================================================================

EXEC #KT_PhaiLoi 'CK-01', N'Giới tính ngoài danh sách cho phép',
    N'INSERT INTO NGUOI_DUNG (HoTen, GioiTinh, NgaySinh) VALUES (N''Lê Văn Sai'', N''Male'', ''1990-01-01'');',
    547, N'CK_NGUOI_DUNG_GioiTinh';

EXEC #KT_PhaiLoi 'CK-02', N'Ngày sinh ở tương lai',
    N'INSERT INTO NGUOI_DUNG (HoTen, GioiTinh, NgaySinh) VALUES (N''Lê Văn Sai'', N''Nam'', ''2999-01-01'');',
    547, N'CK_NGUOI_DUNG_NgaySinh';

EXEC #KT_PhaiLoi 'CK-03', N'Họ tên chỉ có một ký tự',
    N'INSERT INTO NGUOI_DUNG (HoTen, GioiTinh, NgaySinh) VALUES (N''A'', N''Nam'', ''1990-01-01'');',
    547, N'CK_NGUOI_DUNG_HoTen';

EXEC #KT_PhaiLoi 'CK-04', N'Số điện thoại có chữ cái',
    N'INSERT INTO NGUOI_DUNG (HoTen, GioiTinh, NgaySinh, SoDienThoai)
      VALUES (N''Lê Văn Sai'', N''Nam'', ''1990-01-01'', ''09ABC12345'');',
    547, N'CK_NGUOI_DUNG_SoDienThoai';

EXEC #KT_PhaiLoi 'CK-05', N'Email sai định dạng',
    N'INSERT INTO NGUOI_DUNG (HoTen, GioiTinh, NgaySinh, Email)
      VALUES (N''Lê Văn Sai'', N''Nam'', ''1990-01-01'', ''khong-phai-email'');',
    547, N'CK_NGUOI_DUNG_Email';

EXEC #KT_PhaiLoi 'CK-06', N'Họ tên để trống (NULL)',
    N'INSERT INTO NGUOI_DUNG (HoTen, GioiTinh, NgaySinh) VALUES (NULL, N''Nam'', ''1990-01-01'');',
    515;

EXEC #KT_PhaiLoi 'CK-07', N'Chiều cao bằng 0',
    N'UPDATE HO_SO_SUC_KHOE SET ChieuCao = 0 WHERE MaNguoiDung = 1;',
    547, N'CK_HO_SO_SUC_KHOE_ChieuCao';

EXEC #KT_PhaiLoi 'CK-08', N'Cân nặng âm',
    N'UPDATE HO_SO_SUC_KHOE SET CanNang = -5 WHERE MaNguoiDung = 1;',
    547, N'CK_HO_SO_SUC_KHOE_CanNang';

EXEC #KT_PhaiLoi 'CK-09', N'Nhóm máu không tồn tại',
    N'UPDATE HO_SO_SUC_KHOE SET NhomMau = ''C+'' WHERE MaNguoiDung = 1;',
    547, N'CK_HO_SO_SUC_KHOE_NhomMau';

EXEC #KT_PhaiLoi 'CK-10', N'Trạng thái thiết bị ngoài danh sách',
    N'UPDATE THIET_BI SET TrangThai = N''Hỏng'' WHERE MaThietBi = 1;',
    547, N'CK_THIET_BI_TrangThai';

EXEC #KT_PhaiLoi 'CK-11', N'Nguồn "Thiết bị" nhưng không có mã thiết bị',
    N'INSERT INTO LAN_DO (MaNguoiDung, MaThietBi, NguonDuLieu) VALUES (1, NULL, N''Thiết bị'');',
    547, N'CK_LAN_DO_NguonKhopThietBi';

EXEC #KT_PhaiLoi 'CK-12', N'Nguồn "Thủ công" nhưng lại có mã thiết bị',
    N'INSERT INTO LAN_DO (MaNguoiDung, MaThietBi, NguonDuLieu) VALUES (1, 1, N''Thủ công'');',
    547, N'CK_LAN_DO_NguonKhopThietBi';

EXEC #KT_PhaiLoi 'CK-13', N'Thời gian đo ở tương lai',
    N'INSERT INTO LAN_DO (MaNguoiDung, NguonDuLieu, ThoiGianDo)
      VALUES (1, N''Thủ công'', DATEADD(DAY, 1, SYSDATETIME()));',
    547, N'CK_LAN_DO_ThoiGianDo';

EXEC #KT_PhaiLoi 'CK-14', N'Mức độ cảnh báo ngoài danh sách',
    N'UPDATE CANH_BAO SET MucDo = N''Bình thường'' WHERE MaLanDo = 260 AND MaLoaiChiSo = 2;',
    547, N'CK_CANH_BAO_MucDo';

EXEC #KT_PhaiLoi 'CK-15', N'Ngưỡng của chỉ số sai thứ tự (bình thường rộng hơn cảnh báo)',
    N'UPDATE LOAI_CHI_SO SET BinhThuongMax = 130 WHERE KyHieu = ''NHIP_TIM'';',
    547, N'CK_LOAI_CHI_SO_ThuTuNguong';

-- ============================================================================
-- TG — TRIGGER
-- ============================================================================

EXEC #KT_PhaiLoi 'TG-01', N'Giá trị đo ngoài khoảng hợp lệ (nhịp tim 400) bị trigger từ chối',
    N'UPDATE CHI_TIET_LAN_DO SET GiaTri = 400 WHERE MaLanDo = 260 AND MaLoaiChiSo = 2;',
    50001;

EXEC #KT_BangGiaTri 'TG-02', N'Thêm lần đo có 2 chỉ số bất thường: trigger tạo đúng 2 cảnh báo',
    N'INSERT INTO LAN_DO (MaNguoiDung, NguonDuLieu, ThoiGianDo) VALUES (1, N''Thủ công'', ''2026-10-10T22:00:00'');
      DECLARE @Ma INT = SCOPE_IDENTITY();
      INSERT INTO CHI_TIET_LAN_DO (MaLanDo, MaLoaiChiSo, GiaTri)
      VALUES (@Ma, 1, 36.8), (@Ma, 2, 135), (@Ma, 3, 93);
      SELECT @kq = COUNT(*) FROM CANH_BAO WHERE MaLanDo = @Ma;',
    2;

EXEC #KT_BangGiaTri 'TG-03', N'Nhịp tim 135 (ngoài khoảng 50–120) được xếp mức "Nguy hiểm"',
    N'INSERT INTO LAN_DO (MaNguoiDung, NguonDuLieu, ThoiGianDo) VALUES (1, N''Thủ công'', ''2026-10-10T22:00:00'');
      DECLARE @Ma INT = SCOPE_IDENTITY();
      INSERT INTO CHI_TIET_LAN_DO (MaLanDo, MaLoaiChiSo, GiaTri) VALUES (@Ma, 2, 135);
      SELECT @kq = COUNT(*) FROM CANH_BAO WHERE MaLanDo = @Ma AND MucDo = N''Nguy hiểm'';',
    1;

EXEC #KT_BangGiaTri 'TG-04', N'SpO2 93 (trong khoảng 90–95) được xếp mức "Cần chú ý"',
    N'INSERT INTO LAN_DO (MaNguoiDung, NguonDuLieu, ThoiGianDo) VALUES (1, N''Thủ công'', ''2026-10-10T22:00:00'');
      DECLARE @Ma INT = SCOPE_IDENTITY();
      INSERT INTO CHI_TIET_LAN_DO (MaLanDo, MaLoaiChiSo, GiaTri) VALUES (@Ma, 3, 93);
      SELECT @kq = COUNT(*) FROM CANH_BAO WHERE MaLanDo = @Ma AND MucDo = N''Cần chú ý'';',
    1;

EXEC #KT_BangGiaTri 'TG-05', N'Lần đo toàn giá trị bình thường: không sinh cảnh báo',
    N'INSERT INTO LAN_DO (MaNguoiDung, NguonDuLieu, ThoiGianDo) VALUES (1, N''Thủ công'', ''2026-10-10T22:00:00'');
      DECLARE @Ma INT = SCOPE_IDENTITY();
      INSERT INTO CHI_TIET_LAN_DO (MaLanDo, MaLoaiChiSo, GiaTri)
      VALUES (@Ma, 1, 36.8), (@Ma, 2, 75), (@Ma, 3, 98), (@Ma, 4, 118), (@Ma, 5, 76);
      SELECT @kq = COUNT(*) FROM CANH_BAO WHERE MaLanDo = @Ma;',
    0;

EXEC #KT_BangGiaTri 'TG-06', N'Giá trị ở đúng biên khoảng bình thường (nhịp tim 100): không cảnh báo',
    N'INSERT INTO LAN_DO (MaNguoiDung, NguonDuLieu, ThoiGianDo) VALUES (1, N''Thủ công'', ''2026-10-10T22:00:00'');
      DECLARE @Ma INT = SCOPE_IDENTITY();
      INSERT INTO CHI_TIET_LAN_DO (MaLanDo, MaLoaiChiSo, GiaTri) VALUES (@Ma, 2, 100);
      SELECT @kq = COUNT(*) FROM CANH_BAO WHERE MaLanDo = @Ma;',
    0;

EXEC #KT_BangGiaTri 'TG-07', N'Sửa giá trị về bình thường: cảnh báo của nó tự biến mất',
    N'UPDATE CHI_TIET_LAN_DO SET GiaTri = 88 WHERE MaLanDo = 260 AND MaLoaiChiSo = 2;
      SELECT @kq = COUNT(*) FROM CANH_BAO WHERE MaLanDo = 260 AND MaLoaiChiSo = 2;',
    0;

EXEC #KT_BangGiaTri 'TG-08', N'Sửa giá trị từ bình thường sang bất thường: cảnh báo được tạo',
    N'UPDATE CHI_TIET_LAN_DO SET GiaTri = 91 WHERE MaLanDo = 260 AND MaLoaiChiSo = 3;
      SELECT @kq = COUNT(*) FROM CANH_BAO WHERE MaLanDo = 260 AND MaLoaiChiSo = 3 AND MucDo = N''Cần chú ý'';',
    1;

EXEC #KT_BangGiaTri 'TG-09', N'Thời điểm của cảnh báo trùng với thời gian đo',
    N'SELECT @kq = COUNT(*)
      FROM CANH_BAO AS cb
      JOIN LAN_DO   AS ld ON ld.MaLanDo = cb.MaLanDo
      WHERE cb.ThoiGianTao <> ld.ThoiGianDo;',
    0;

EXEC #KT_BangGiaTri 'TG-10', N'Sửa hồ sơ: trigger tự cập nhật NgayCapNhat về hôm nay',
    N'UPDATE HO_SO_SUC_KHOE SET CanNang = 73 WHERE MaNguoiDung = 1;
      SELECT @kq = DATEDIFF(DAY, NgayCapNhat, SYSDATETIME())
      FROM HO_SO_SUC_KHOE WHERE MaNguoiDung = 1;',
    0;

-- ============================================================================
-- CR — THÊM / SỬA / XÓA
-- ============================================================================

EXEC #KT_BangGiaTri 'CR-01', N'Thêm một người dùng: tổng số tăng từ 12 lên 13',
    N'INSERT INTO NGUOI_DUNG (HoTen, GioiTinh, NgaySinh) VALUES (N''Trịnh Gia Bảo'', N''Nam'', ''1999-02-14'');
      SELECT @kq = COUNT(*) FROM NGUOI_DUNG;',
    13;

EXEC #KT_BangGiaTri 'CR-02', N'Sửa số điện thoại của một người dùng',
    N'UPDATE NGUOI_DUNG SET SoDienThoai = ''0901999888'' WHERE MaNguoiDung = 1;
      SELECT @kq = COUNT(*) FROM NGUOI_DUNG WHERE MaNguoiDung = 1 AND SoDienThoai = ''0901999888'';',
    1;

EXEC #KT_BangGiaTri 'CR-03', N'Xóa một người dùng: tổng số giảm từ 12 xuống 11',
    N'DELETE FROM NGUOI_DUNG WHERE MaNguoiDung = 12;
      SELECT @kq = COUNT(*) FROM NGUOI_DUNG;',
    11;

EXEC #KT_BangGiaTri 'CR-04', N'SP_ThemLanDo với 5 chỉ số: lưu đủ 5 giá trị đo',
    N'DECLARE @Ma INT;
      EXEC SP_ThemLanDo @MaNguoiDung = 2, @MaThietBi = 1, @ThoiGianDo = ''2026-10-10T22:00:00'',
           @NhietDo = 36.7, @NhipTim = 81, @SpO2 = 98, @HuyetApTamThu = 121, @HuyetApTamTruong = 79,
           @MaLanDo = @Ma OUTPUT;
      SELECT @kq = COUNT(*) FROM CHI_TIET_LAN_DO WHERE MaLanDo = @Ma;',
    5;

EXEC #KT_BangGiaTri 'CR-05', N'SP_ThemLanDo không có mã thiết bị: nguồn là "Thủ công"',
    N'DECLARE @Ma INT;
      EXEC SP_ThemLanDo @MaNguoiDung = 2, @NhipTim = 81, @MaLanDo = @Ma OUTPUT;
      SELECT @kq = COUNT(*) FROM LAN_DO WHERE MaLanDo = @Ma AND NguonDuLieu = N''Thủ công'' AND MaThietBi IS NULL;',
    1;

EXEC #KT_PhaiLoi 'CR-06', N'SP_ThemLanDo không có chỉ số nào',
    N'EXEC SP_ThemLanDo @MaNguoiDung = 2;',
    50002;

EXEC #KT_PhaiLoi 'CR-07', N'SP_ThemLanDo chỉ có huyết áp tâm thu, thiếu tâm trương',
    N'EXEC SP_ThemLanDo @MaNguoiDung = 2, @HuyetApTamThu = 120;',
    50003;

EXEC #KT_PhaiLoi 'CR-08', N'SP_ThemLanDo có tâm thu nhỏ hơn tâm trương',
    N'EXEC SP_ThemLanDo @MaNguoiDung = 2, @HuyetApTamThu = 70, @HuyetApTamTruong = 90;',
    50004;

EXEC #KT_BangGiaTri 'CR-09', N'SP_ThemLanDo gặp giá trị không hợp lệ: không để lại lần đo dở dang',
    N'BEGIN TRY
          EXEC SP_ThemLanDo @MaNguoiDung = 2, @NhipTim = 80, @SpO2 = 150;
      END TRY
      BEGIN CATCH
      END CATCH;
      SELECT @kq = COUNT(*) FROM LAN_DO;',
    265;

EXEC #KT_BangGiaTri 'CR-10', N'Đánh dấu đã xem toàn bộ cảnh báo của người dùng 7',
    N'UPDATE cb SET cb.DaXem = 1
      FROM CANH_BAO AS cb JOIN LAN_DO AS ld ON ld.MaLanDo = cb.MaLanDo
      WHERE ld.MaNguoiDung = 7;
      SELECT @kq = COUNT(*) FROM V_CANH_BAO_CHI_TIET WHERE MaNguoiDung = 7 AND DaXem = 0;',
    0;

-- ============================================================================
-- TK — TÌM KIẾM VÀ LỌC
-- ============================================================================

EXEC #KT_BangGiaTri 'TK-01', N'Tìm tên không dấu "bich" ra 1 người (Trần Thị Bích)',
    N'SELECT @kq = COUNT(*) FROM NGUOI_DUNG WHERE HoTen COLLATE Latin1_General_CI_AI LIKE N''%bich%'';',
    1;

EXEC #KT_BangGiaTri 'TK-02', N'Tìm "duc" khớp cả chữ Đ (Hoàng Minh Đức)',
    N'SELECT @kq = COUNT(*) FROM NGUOI_DUNG WHERE HoTen COLLATE Latin1_General_CI_AI LIKE N''%duc%'';',
    1;

EXEC #KT_BangGiaTri 'TK-03', N'Tìm "thi" ra 6 người có tên đệm Thị',
    N'SELECT @kq = COUNT(*) FROM NGUOI_DUNG WHERE HoTen COLLATE Latin1_General_CI_AI LIKE N''%thi%'';',
    6;

EXEC #KT_BangGiaTri 'TK-04', N'Tìm từ khóa không có trong dữ liệu trả về 0 dòng',
    N'SELECT @kq = COUNT(*) FROM NGUOI_DUNG WHERE HoTen COLLATE Latin1_General_CI_AI LIKE N''%xyz%'';',
    0;

EXEC #KT_BangGiaTri 'TK-05', N'Lọc giới tính Nữ: 6 người',
    N'SELECT @kq = COUNT(*) FROM NGUOI_DUNG WHERE GioiTinh = N''Nữ'';',
    6;

EXEC #KT_BangGiaTri 'TK-06', N'Lọc từ 60 tuổi (tính đến 10/10/2026): 3 người',
    N'SELECT @kq = COUNT(*) FROM NGUOI_DUNG WHERE dbo.FN_TinhTuoi(NgaySinh, ''2026-10-10'') >= 60;',
    3;

EXEC #KT_BangGiaTri 'TK-07', N'Lọc 18–39 tuổi (tính đến 10/10/2026): 4 người',
    N'SELECT @kq = COUNT(*) FROM NGUOI_DUNG WHERE dbo.FN_TinhTuoi(NgaySinh, ''2026-10-10'') BETWEEN 18 AND 39;',
    4;

EXEC #KT_BangGiaTri 'TK-08', N'Tuổi tính đúng vào ngày sinh nhật (Lý Thị Oanh, sinh 10/10/2005)',
    N'SELECT @kq = dbo.FN_TinhTuoi(''2005-10-10'', ''2026-10-10'') * 100
                 + dbo.FN_TinhTuoi(''2005-10-10'', ''2026-10-09'');',
    2120;

EXEC #KT_BangGiaTri 'TK-09', N'Lọc nhóm máu O (O+ và O-): 4 người',
    N'SELECT @kq = COUNT(*) FROM HO_SO_SUC_KHOE WHERE NhomMau IN (''O+'', ''O-'');',
    4;

EXEC #KT_BangGiaTri 'TK-10', N'Lọc thiết bị đang hoạt động: 4 thiết bị',
    N'SELECT @kq = COUNT(*) FROM THIET_BI WHERE TrangThai = N''Hoạt động'';',
    4;

EXEC #KT_BangGiaTri 'TK-11', N'Lịch sử đo trong ngày 10/10/2026: 15 lần đo',
    N'SELECT @kq = COUNT(*) FROM LAN_DO WHERE ThoiGianDo >= ''2026-10-10'' AND ThoiGianDo < ''2026-10-11'';',
    15;

EXEC #KT_BangGiaTri 'TK-12', N'Lịch sử đo từ 04/10 đến 10/10/2026: 62 lần đo',
    N'SELECT @kq = COUNT(*) FROM LAN_DO WHERE ThoiGianDo >= ''2026-10-04'' AND ThoiGianDo < ''2026-10-11'';',
    62;

EXEC #KT_BangGiaTri 'TK-13', N'Lịch sử đo của người dùng 7: 35 lần đo',
    N'SELECT @kq = COUNT(*) FROM LAN_DO WHERE MaNguoiDung = 7;',
    35;

EXEC #KT_BangGiaTri 'TK-14', N'Lọc lần đo nhập thủ công: 55 lần đo',
    N'SELECT @kq = COUNT(*) FROM LAN_DO WHERE NguonDuLieu = N''Thủ công'';',
    55;

EXEC #KT_BangGiaTri 'TK-15', N'Lọc cảnh báo mức nguy hiểm: 16 cảnh báo',
    N'SELECT @kq = COUNT(*) FROM CANH_BAO WHERE MucDo = N''Nguy hiểm'';',
    16;

EXEC #KT_BangGiaTri 'TK-16', N'Lọc cảnh báo chưa xem: 17 cảnh báo',
    N'SELECT @kq = COUNT(*) FROM CANH_BAO WHERE DaXem = 0;',
    17;

EXEC #KT_BangGiaTri 'TK-17', N'Cảnh báo của người dùng 7: 38 cảnh báo',
    N'SELECT @kq = COUNT(*) FROM V_CANH_BAO_CHI_TIET WHERE MaNguoiDung = 7;',
    38;

-- ============================================================================
-- ST — THỐNG KÊ
-- ============================================================================

EXEC #KT_BangGiaTri 'ST-01', N'Tổng số lần đo của dữ liệu mẫu',
    N'SELECT @kq = COUNT(*) FROM LAN_DO;',
    265;

EXEC #KT_BangGiaTri 'ST-02', N'Tổng số giá trị đo của dữ liệu mẫu',
    N'SELECT @kq = COUNT(*) FROM CHI_TIET_LAN_DO;',
    1110;

EXEC #KT_BangGiaTri 'ST-03', N'Số cảnh báo bằng đúng số giá trị ngoài khoảng bình thường',
    N'SELECT @kq = (SELECT COUNT(*) FROM CANH_BAO)
                 - (SELECT COUNT(*) FROM V_CHI_TIET_DANH_GIA WHERE CapDo > 0);',
    0;

EXEC #KT_BangGiaTri 'ST-04', N'View V_LAN_DO_TONG_HOP có đúng một dòng cho mỗi lần đo',
    N'SELECT @kq = COUNT(*) FROM V_LAN_DO_TONG_HOP;',
    265;

EXEC #KT_BangGiaTri 'ST-05', N'Cộng số lần đo theo từng người (GROUP BY) ra đúng tổng',
    N'SELECT @kq = SUM(SoLanDo)
      FROM (SELECT COUNT(*) AS SoLanDo FROM LAN_DO GROUP BY MaNguoiDung) AS t;',
    265;

EXEC #KT_BangGiaTri 'ST-06', N'Số lần đo có kết quả "Bình thường": 179',
    N'SELECT @kq = COUNT(*) FROM V_LAN_DO_TONG_HOP WHERE MucDo = N''Bình thường'';',
    179;

EXEC #KT_BangGiaTri 'ST-07', N'Ba mức độ của lần đo cộng lại bằng tổng số lần đo',
    N'SELECT @kq = SUM(SoLanDo)
      FROM (SELECT COUNT(*) AS SoLanDo FROM V_LAN_DO_TONG_HOP GROUP BY MucDo) AS t;',
    265;

EXEC #KT_BangGiaTri 'ST-08', N'HAVING: 5 người có từ 25 lần đo trở lên',
    N'SELECT @kq = COUNT(*)
      FROM (SELECT MaNguoiDung FROM LAN_DO GROUP BY MaNguoiDung HAVING COUNT(*) >= 25) AS t;',
    5;

EXEC #KT_BangGiaTri 'ST-09', N'Nhịp tim trung bình toàn bộ dữ liệu: 80,5 bpm (so sánh × 10)',
    N'SELECT @kq = CAST(ROUND(AVG(GiaTri) * 10, 0) AS INT) FROM CHI_TIET_LAN_DO WHERE MaLoaiChiSo = 2;',
    805;

EXEC #KT_BangGiaTri 'ST-10', N'Huyết áp tâm thu cao nhất: 148 mmHg',
    N'SELECT @kq = CAST(MAX(GiaTri) AS INT) FROM CHI_TIET_LAN_DO WHERE MaLoaiChiSo = 4;',
    148;

EXEC #KT_BangGiaTri 'ST-11', N'SpO2 thấp nhất: 92 %',
    N'SELECT @kq = CAST(MIN(GiaTri) AS INT) FROM CHI_TIET_LAN_DO WHERE MaLoaiChiSo = 3;',
    92;

EXEC #KT_BangGiaTri 'ST-12', N'View V_HO_SO_TONG_HOP: tổng cột SoLanDo bằng tổng số lần đo',
    N'SELECT @kq = SUM(SoLanDo) FROM V_HO_SO_TONG_HOP;',
    265;
GO

-- ============================================================================
-- KẾT QUẢ
-- ============================================================================

SELECT Ma, MoTa, MongDoi, ThucTe, KetLuan
FROM #KetQua
ORDER BY STT;

SELECT
    COUNT(*)                                                  AS TongSoCa,
    SUM(CASE WHEN KetLuan = N'ĐẠT' THEN 1 ELSE 0 END)         AS SoCaDat,
    SUM(CASE WHEN KetLuan <> N'ĐẠT' THEN 1 ELSE 0 END)        AS SoCaKhongDat
FROM #KetQua;

-- Sau khi kiểm thử, dữ liệu mẫu phải còn nguyên.
SELECT
    (SELECT COUNT(*) FROM NGUOI_DUNG)      AS NguoiDung,
    (SELECT COUNT(*) FROM LAN_DO)          AS LanDo,
    (SELECT COUNT(*) FROM CHI_TIET_LAN_DO) AS ChiTiet,
    (SELECT COUNT(*) FROM CANH_BAO)        AS CanhBao;
GO
