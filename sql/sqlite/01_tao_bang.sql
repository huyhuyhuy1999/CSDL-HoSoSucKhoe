-- ============================================================================
-- 01. TẠO BẢNG — SQLite (cơ sở dữ liệu nhúng trong ứng dụng)
--
-- Bản tương đương của sql/sqlserver/01_tao_bang.sql. Khác biệt chính:
--   - Kiểu dữ liệu: INTEGER / REAL / TEXT thay cho INT / DECIMAL / NVARCHAR.
--   - Khóa tự tăng: INTEGER PRIMARY KEY AUTOINCREMENT thay cho IDENTITY.
--   - Ngày giờ lưu dạng chuỗi ISO 'YYYY-MM-DD HH:MM:SS' theo giờ địa phương.
--   - SQLite không cho dùng thời điểm hiện tại trong CHECK, nên các ràng buộc
--     "không ở tương lai" được chuyển sang trigger (xem 02_trigger.sql).
--   - Khóa ngoại chỉ có hiệu lực khi kết nối bật PRAGMA foreign_keys = ON.
-- ============================================================================

CREATE TABLE NGUOI_DUNG (
    MaNguoiDung  INTEGER PRIMARY KEY AUTOINCREMENT,
    HoTen        TEXT NOT NULL,
    GioiTinh     TEXT NOT NULL,
    NgaySinh     TEXT NOT NULL,                -- 'YYYY-MM-DD'
    SoDienThoai  TEXT,
    Email        TEXT,
    DiaChi       TEXT,
    NgayTao      TEXT NOT NULL DEFAULT (datetime('now', 'localtime')),

    CONSTRAINT CK_NGUOI_DUNG_HoTen
        CHECK (length(trim(HoTen)) >= 2),
    CONSTRAINT CK_NGUOI_DUNG_GioiTinh
        CHECK (GioiTinh IN ('Nam', 'Nữ', 'Khác')),
    CONSTRAINT CK_NGUOI_DUNG_NgaySinh
        CHECK (NgaySinh >= '1900-01-01' AND NgaySinh = date(NgaySinh)),
    CONSTRAINT CK_NGUOI_DUNG_SoDienThoai
        CHECK (SoDienThoai IS NULL
               OR (length(SoDienThoai) BETWEEN 9 AND 12 AND SoDienThoai NOT GLOB '*[^0-9]*')),
    CONSTRAINT CK_NGUOI_DUNG_Email
        CHECK (Email IS NULL OR Email LIKE '_%@_%._%')
);

CREATE UNIQUE INDEX UQ_NGUOI_DUNG_Email
    ON NGUOI_DUNG (Email)
    WHERE Email IS NOT NULL;

CREATE TABLE HO_SO_SUC_KHOE (
    MaHoSo       INTEGER PRIMARY KEY AUTOINCREMENT,
    MaNguoiDung  INTEGER NOT NULL,
    ChieuCao     REAL NOT NULL,                -- cm
    CanNang      REAL NOT NULL,                -- kg
    NhomMau      TEXT NOT NULL,
    TienSuBenh   TEXT,
    DiUng        TEXT,
    NgayCapNhat  TEXT NOT NULL DEFAULT (datetime('now', 'localtime')),

    CONSTRAINT UQ_HO_SO_SUC_KHOE_MaNguoiDung UNIQUE (MaNguoiDung),
    CONSTRAINT FK_HO_SO_SUC_KHOE_NGUOI_DUNG
        FOREIGN KEY (MaNguoiDung) REFERENCES NGUOI_DUNG (MaNguoiDung)
        ON DELETE CASCADE,
    CONSTRAINT CK_HO_SO_SUC_KHOE_ChieuCao CHECK (ChieuCao BETWEEN 30 AND 250),
    CONSTRAINT CK_HO_SO_SUC_KHOE_CanNang  CHECK (CanNang BETWEEN 1 AND 300),
    CONSTRAINT CK_HO_SO_SUC_KHOE_NhomMau
        CHECK (NhomMau IN ('A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'))
);

CREATE TABLE THIET_BI (
    MaThietBi    INTEGER PRIMARY KEY AUTOINCREMENT,
    TenThietBi   TEXT NOT NULL,
    LoaiThietBi  TEXT NOT NULL,
    MaDinhDanh   TEXT NOT NULL,
    TrangThai    TEXT NOT NULL DEFAULT 'Hoạt động',
    MoTa         TEXT,

    CONSTRAINT UQ_THIET_BI_MaDinhDanh UNIQUE (MaDinhDanh),
    CONSTRAINT CK_THIET_BI_LoaiThietBi
        CHECK (LoaiThietBi IN ('Thiết bị đa chỉ số', 'Máy đo SpO2',
                               'Nhiệt kế', 'Máy đo huyết áp')),
    CONSTRAINT CK_THIET_BI_TrangThai
        CHECK (TrangThai IN ('Hoạt động', 'Bảo trì', 'Ngừng sử dụng'))
);

CREATE TABLE LOAI_CHI_SO (
    MaLoaiChiSo    INTEGER PRIMARY KEY AUTOINCREMENT,
    KyHieu         TEXT NOT NULL,
    TenChiSo       TEXT NOT NULL,
    DonViDo        TEXT NOT NULL,
    SoThapPhan     INTEGER NOT NULL DEFAULT 0,
    GiaTriMin      REAL NOT NULL,
    GiaTriMax      REAL NOT NULL,
    BinhThuongMin  REAL NOT NULL,
    BinhThuongMax  REAL NOT NULL,
    CanhBaoMin     REAL NOT NULL,
    CanhBaoMax     REAL NOT NULL,

    CONSTRAINT UQ_LOAI_CHI_SO_KyHieu   UNIQUE (KyHieu),
    CONSTRAINT UQ_LOAI_CHI_SO_TenChiSo UNIQUE (TenChiSo),
    CONSTRAINT CK_LOAI_CHI_SO_SoThapPhan CHECK (SoThapPhan IN (0, 1)),
    CONSTRAINT CK_LOAI_CHI_SO_ThuTuNguong
        CHECK (GiaTriMin <= CanhBaoMin
               AND CanhBaoMin <= BinhThuongMin
               AND BinhThuongMin < BinhThuongMax
               AND BinhThuongMax <= CanhBaoMax
               AND CanhBaoMax <= GiaTriMax)
);

CREATE TABLE LAN_DO (
    MaLanDo      INTEGER PRIMARY KEY AUTOINCREMENT,
    MaNguoiDung  INTEGER NOT NULL,
    MaThietBi    INTEGER,                      -- NULL khi nhập thủ công
    NguonDuLieu  TEXT NOT NULL,
    ThoiGianDo   TEXT NOT NULL DEFAULT (datetime('now', 'localtime')),
    GhiChu       TEXT,

    CONSTRAINT FK_LAN_DO_NGUOI_DUNG
        FOREIGN KEY (MaNguoiDung) REFERENCES NGUOI_DUNG (MaNguoiDung)
        ON DELETE CASCADE,
    CONSTRAINT FK_LAN_DO_THIET_BI
        FOREIGN KEY (MaThietBi) REFERENCES THIET_BI (MaThietBi),
    CONSTRAINT CK_LAN_DO_NguonDuLieu
        CHECK (NguonDuLieu IN ('Thiết bị', 'Thủ công')),
    CONSTRAINT CK_LAN_DO_NguonKhopThietBi
        CHECK ((NguonDuLieu = 'Thiết bị' AND MaThietBi IS NOT NULL)
            OR (NguonDuLieu = 'Thủ công' AND MaThietBi IS NULL)),
    CONSTRAINT CK_LAN_DO_DinhDangThoiGian
        CHECK (ThoiGianDo = datetime(ThoiGianDo))
);

CREATE INDEX IX_LAN_DO_NguoiDung_ThoiGian ON LAN_DO (MaNguoiDung, ThoiGianDo DESC);
CREATE INDEX IX_LAN_DO_ThoiGianDo         ON LAN_DO (ThoiGianDo DESC);
CREATE INDEX IX_LAN_DO_MaThietBi          ON LAN_DO (MaThietBi);

CREATE TABLE CHI_TIET_LAN_DO (
    MaLanDo      INTEGER NOT NULL,
    MaLoaiChiSo  INTEGER NOT NULL,
    GiaTri       REAL NOT NULL,

    CONSTRAINT PK_CHI_TIET_LAN_DO PRIMARY KEY (MaLanDo, MaLoaiChiSo),
    CONSTRAINT FK_CHI_TIET_LAN_DO_LAN_DO
        FOREIGN KEY (MaLanDo) REFERENCES LAN_DO (MaLanDo)
        ON DELETE CASCADE,
    CONSTRAINT FK_CHI_TIET_LAN_DO_LOAI_CHI_SO
        FOREIGN KEY (MaLoaiChiSo) REFERENCES LOAI_CHI_SO (MaLoaiChiSo)
);

CREATE INDEX IX_CHI_TIET_LAN_DO_MaLoaiChiSo ON CHI_TIET_LAN_DO (MaLoaiChiSo);

CREATE TABLE CANH_BAO (
    MaCanhBao    INTEGER PRIMARY KEY AUTOINCREMENT,
    MaLanDo      INTEGER NOT NULL,
    MaLoaiChiSo  INTEGER NOT NULL,
    MucDo        TEXT NOT NULL,
    NoiDung      TEXT NOT NULL,
    ThoiGianTao  TEXT NOT NULL DEFAULT (datetime('now', 'localtime')),
    DaXem        INTEGER NOT NULL DEFAULT 0,

    CONSTRAINT UQ_CANH_BAO_ChiTiet UNIQUE (MaLanDo, MaLoaiChiSo),
    CONSTRAINT FK_CANH_BAO_CHI_TIET_LAN_DO
        FOREIGN KEY (MaLanDo, MaLoaiChiSo)
        REFERENCES CHI_TIET_LAN_DO (MaLanDo, MaLoaiChiSo)
        ON DELETE CASCADE,
    CONSTRAINT CK_CANH_BAO_MucDo CHECK (MucDo IN ('Cần chú ý', 'Nguy hiểm')),
    CONSTRAINT CK_CANH_BAO_DaXem CHECK (DaXem IN (0, 1))
);

CREATE INDEX IX_CANH_BAO_ThoiGianTao ON CANH_BAO (ThoiGianTao DESC);
CREATE INDEX IX_CANH_BAO_DaXem       ON CANH_BAO (DaXem, ThoiGianTao DESC);
