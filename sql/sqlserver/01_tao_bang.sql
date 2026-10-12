-- ============================================================================
-- 01. TẠO BẢNG
--
-- Bảy bảng của hệ thống, tạo theo thứ tự phụ thuộc khóa ngoại:
--   NGUOI_DUNG  ->  HO_SO_SUC_KHOE
--   THIET_BI, LOAI_CHI_SO
--   LAN_DO  ->  CHI_TIET_LAN_DO  ->  CANH_BAO
--
-- Quy ước đặt tên ràng buộc:
--   PK_<bảng>            khóa chính
--   FK_<bảng con>_<bảng cha>   khóa ngoại
--   UQ_<bảng>_<cột>      duy nhất
--   CK_<bảng>_<cột>      kiểm tra miền giá trị
--   DF_<bảng>_<cột>      giá trị mặc định
-- ============================================================================

USE QuanLyHoSoSucKhoe;
GO

-- ----------------------------------------------------------------------------
-- NGUOI_DUNG — người được theo dõi sức khỏe (Người 5)
-- ----------------------------------------------------------------------------
CREATE TABLE NGUOI_DUNG (
    MaNguoiDung  INT IDENTITY(1,1) NOT NULL,
    HoTen        NVARCHAR(100)     NOT NULL,
    GioiTinh     NVARCHAR(5)       NOT NULL,
    NgaySinh     DATE              NOT NULL,
    SoDienThoai  VARCHAR(15)       NULL,
    Email        VARCHAR(100)      NULL,
    DiaChi       NVARCHAR(200)     NULL,
    NgayTao      DATETIME2(0)      NOT NULL
        CONSTRAINT DF_NGUOI_DUNG_NgayTao DEFAULT (SYSDATETIME()),

    CONSTRAINT PK_NGUOI_DUNG PRIMARY KEY (MaNguoiDung),
    CONSTRAINT CK_NGUOI_DUNG_HoTen
        CHECK (LEN(LTRIM(RTRIM(HoTen))) >= 2),
    CONSTRAINT CK_NGUOI_DUNG_GioiTinh
        CHECK (GioiTinh IN (N'Nam', N'Nữ', N'Khác')),
    CONSTRAINT CK_NGUOI_DUNG_NgaySinh
        CHECK (NgaySinh >= '1900-01-01' AND NgaySinh <= CAST(GETDATE() AS DATE)),
    CONSTRAINT CK_NGUOI_DUNG_SoDienThoai
        CHECK (SoDienThoai IS NULL
               OR (LEN(SoDienThoai) BETWEEN 9 AND 12 AND SoDienThoai NOT LIKE '%[^0-9]%')),
    CONSTRAINT CK_NGUOI_DUNG_Email
        CHECK (Email IS NULL OR Email LIKE '_%@_%._%')
);
GO

-- Email không bắt buộc, nhưng nếu có thì không được trùng.
-- (UNIQUE thông thường chỉ cho phép một dòng NULL nên dùng chỉ mục có điều kiện.)
CREATE UNIQUE INDEX UQ_NGUOI_DUNG_Email
    ON NGUOI_DUNG (Email)
    WHERE Email IS NOT NULL;
GO

-- ----------------------------------------------------------------------------
-- HO_SO_SUC_KHOE — hồ sơ sức khỏe, quan hệ 1–1 với NGUOI_DUNG (Người 6)
-- ----------------------------------------------------------------------------
CREATE TABLE HO_SO_SUC_KHOE (
    MaHoSo       INT IDENTITY(1,1) NOT NULL,
    MaNguoiDung  INT               NOT NULL,
    ChieuCao     DECIMAL(5,1)      NOT NULL,  -- cm
    CanNang      DECIMAL(5,1)      NOT NULL,  -- kg
    NhomMau      VARCHAR(3)        NOT NULL,
    TienSuBenh   NVARCHAR(500)     NULL,
    DiUng        NVARCHAR(300)     NULL,
    NgayCapNhat  DATETIME2(0)      NOT NULL
        CONSTRAINT DF_HO_SO_SUC_KHOE_NgayCapNhat DEFAULT (SYSDATETIME()),

    CONSTRAINT PK_HO_SO_SUC_KHOE PRIMARY KEY (MaHoSo),
    -- UNIQUE trên khóa ngoại biến quan hệ 1–N thành 1–1.
    CONSTRAINT UQ_HO_SO_SUC_KHOE_MaNguoiDung UNIQUE (MaNguoiDung),
    CONSTRAINT FK_HO_SO_SUC_KHOE_NGUOI_DUNG
        FOREIGN KEY (MaNguoiDung) REFERENCES NGUOI_DUNG (MaNguoiDung)
        ON DELETE CASCADE,
    CONSTRAINT CK_HO_SO_SUC_KHOE_ChieuCao CHECK (ChieuCao BETWEEN 30 AND 250),
    CONSTRAINT CK_HO_SO_SUC_KHOE_CanNang  CHECK (CanNang BETWEEN 1 AND 300),
    CONSTRAINT CK_HO_SO_SUC_KHOE_NhomMau
        CHECK (NhomMau IN ('A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'))
);
GO

-- ----------------------------------------------------------------------------
-- THIET_BI — thiết bị đo (dữ liệu mô phỏng, không kết nối phần cứng) (Người 9)
-- ----------------------------------------------------------------------------
CREATE TABLE THIET_BI (
    MaThietBi    INT IDENTITY(1,1) NOT NULL,
    TenThietBi   NVARCHAR(100)     NOT NULL,
    LoaiThietBi  NVARCHAR(50)      NOT NULL,
    MaDinhDanh   VARCHAR(50)       NOT NULL,  -- địa chỉ MAC hoặc số serial
    TrangThai    NVARCHAR(20)      NOT NULL
        CONSTRAINT DF_THIET_BI_TrangThai DEFAULT (N'Hoạt động'),
    MoTa         NVARCHAR(300)     NULL,

    CONSTRAINT PK_THIET_BI PRIMARY KEY (MaThietBi),
    CONSTRAINT UQ_THIET_BI_MaDinhDanh UNIQUE (MaDinhDanh),
    CONSTRAINT CK_THIET_BI_LoaiThietBi
        CHECK (LoaiThietBi IN (N'Thiết bị đa chỉ số', N'Máy đo SpO2',
                               N'Nhiệt kế', N'Máy đo huyết áp')),
    CONSTRAINT CK_THIET_BI_TrangThai
        CHECK (TrangThai IN (N'Hoạt động', N'Bảo trì', N'Ngừng sử dụng'))
);
GO

-- ----------------------------------------------------------------------------
-- LOAI_CHI_SO — danh mục chỉ số và ngưỡng đánh giá (Người 7, Người 10)
--
-- Ba khoảng lồng nhau quyết định mức độ của một giá trị đo:
--   [GiaTriMin   , GiaTriMax   ]  khoảng hợp lệ: ngoài khoảng này bị từ chối
--   [CanhBaoMin  , CanhBaoMax  ]  ngoài khoảng này là "Nguy hiểm"
--   [BinhThuongMin, BinhThuongMax] trong khoảng này là "Bình thường";
--                                  giữa hai khoảng trên là "Cần chú ý"
-- ----------------------------------------------------------------------------
CREATE TABLE LOAI_CHI_SO (
    MaLoaiChiSo    INT IDENTITY(1,1) NOT NULL,
    KyHieu         VARCHAR(20)       NOT NULL,  -- mã ngắn dùng trong chương trình
    TenChiSo       NVARCHAR(50)      NOT NULL,
    DonViDo        NVARCHAR(10)      NOT NULL,
    SoThapPhan     TINYINT           NOT NULL
        CONSTRAINT DF_LOAI_CHI_SO_SoThapPhan DEFAULT (0),
    GiaTriMin      DECIMAL(6,1)      NOT NULL,
    GiaTriMax      DECIMAL(6,1)      NOT NULL,
    BinhThuongMin  DECIMAL(6,1)      NOT NULL,
    BinhThuongMax  DECIMAL(6,1)      NOT NULL,
    CanhBaoMin     DECIMAL(6,1)      NOT NULL,
    CanhBaoMax     DECIMAL(6,1)      NOT NULL,

    CONSTRAINT PK_LOAI_CHI_SO PRIMARY KEY (MaLoaiChiSo),
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
GO

-- ----------------------------------------------------------------------------
-- LAN_DO — một lần đo của một người tại một thời điểm (Người 8)
-- ----------------------------------------------------------------------------
CREATE TABLE LAN_DO (
    MaLanDo      INT IDENTITY(1,1) NOT NULL,
    MaNguoiDung  INT               NOT NULL,
    MaThietBi    INT               NULL,      -- NULL khi nhập thủ công
    NguonDuLieu  NVARCHAR(20)      NOT NULL,
    ThoiGianDo   DATETIME2(0)      NOT NULL
        CONSTRAINT DF_LAN_DO_ThoiGianDo DEFAULT (SYSDATETIME()),
    GhiChu       NVARCHAR(300)     NULL,

    CONSTRAINT PK_LAN_DO PRIMARY KEY (MaLanDo),
    -- Xóa người dùng thì xóa luôn lịch sử đo của người đó.
    CONSTRAINT FK_LAN_DO_NGUOI_DUNG
        FOREIGN KEY (MaNguoiDung) REFERENCES NGUOI_DUNG (MaNguoiDung)
        ON DELETE CASCADE,
    -- Không cho xóa thiết bị đã có lần đo (mặc định NO ACTION).
    CONSTRAINT FK_LAN_DO_THIET_BI
        FOREIGN KEY (MaThietBi) REFERENCES THIET_BI (MaThietBi),
    CONSTRAINT CK_LAN_DO_NguonDuLieu
        CHECK (NguonDuLieu IN (N'Thiết bị', N'Thủ công')),
    -- Nguồn "Thiết bị" bắt buộc có mã thiết bị; nguồn "Thủ công" thì không.
    CONSTRAINT CK_LAN_DO_NguonKhopThietBi
        CHECK ((NguonDuLieu = N'Thiết bị' AND MaThietBi IS NOT NULL)
            OR (NguonDuLieu = N'Thủ công' AND MaThietBi IS NULL)),
    CONSTRAINT CK_LAN_DO_ThoiGianDo
        CHECK (ThoiGianDo <= DATEADD(MINUTE, 5, SYSDATETIME()))
);
GO

-- Truy vấn lịch sử luôn lọc theo người và sắp theo thời gian.
CREATE INDEX IX_LAN_DO_NguoiDung_ThoiGian
    ON LAN_DO (MaNguoiDung, ThoiGianDo DESC);
CREATE INDEX IX_LAN_DO_ThoiGianDo
    ON LAN_DO (ThoiGianDo DESC);
CREATE INDEX IX_LAN_DO_MaThietBi
    ON LAN_DO (MaThietBi);
GO

-- ----------------------------------------------------------------------------
-- CHI_TIET_LAN_DO — giá trị của từng chỉ số trong một lần đo (Người 7)
--
-- Tách khỏi LAN_DO để một lần đo có thể gồm số lượng chỉ số bất kỳ
-- (máy đo SpO2 chỉ cho 2 chỉ số, trạm ESP32 cho cả 5).
-- ----------------------------------------------------------------------------
CREATE TABLE CHI_TIET_LAN_DO (
    MaLanDo      INT          NOT NULL,
    MaLoaiChiSo  INT          NOT NULL,
    GiaTri       DECIMAL(6,1) NOT NULL,

    -- Khóa chính kép: mỗi chỉ số chỉ xuất hiện một lần trong một lần đo.
    CONSTRAINT PK_CHI_TIET_LAN_DO PRIMARY KEY (MaLanDo, MaLoaiChiSo),
    CONSTRAINT FK_CHI_TIET_LAN_DO_LAN_DO
        FOREIGN KEY (MaLanDo) REFERENCES LAN_DO (MaLanDo)
        ON DELETE CASCADE,
    CONSTRAINT FK_CHI_TIET_LAN_DO_LOAI_CHI_SO
        FOREIGN KEY (MaLoaiChiSo) REFERENCES LOAI_CHI_SO (MaLoaiChiSo)
);
GO

CREATE INDEX IX_CHI_TIET_LAN_DO_MaLoaiChiSo
    ON CHI_TIET_LAN_DO (MaLoaiChiSo);
GO

-- ----------------------------------------------------------------------------
-- CANH_BAO — cảnh báo khi một giá trị đo vượt ngưỡng (Người 10)
--
-- Cảnh báo gắn với đúng một dòng CHI_TIET_LAN_DO (khóa ngoại kép), nên biết
-- ngay nó thuộc lần đo nào, chỉ số nào và của ai.
-- ----------------------------------------------------------------------------
CREATE TABLE CANH_BAO (
    MaCanhBao    INT IDENTITY(1,1) NOT NULL,
    MaLanDo      INT               NOT NULL,
    MaLoaiChiSo  INT               NOT NULL,
    MucDo        NVARCHAR(20)      NOT NULL,
    NoiDung      NVARCHAR(300)     NOT NULL,
    ThoiGianTao  DATETIME2(0)      NOT NULL
        CONSTRAINT DF_CANH_BAO_ThoiGianTao DEFAULT (SYSDATETIME()),
    DaXem        BIT               NOT NULL
        CONSTRAINT DF_CANH_BAO_DaXem DEFAULT (0),

    CONSTRAINT PK_CANH_BAO PRIMARY KEY (MaCanhBao),
    -- Mỗi giá trị đo có tối đa một cảnh báo.
    CONSTRAINT UQ_CANH_BAO_ChiTiet UNIQUE (MaLanDo, MaLoaiChiSo),
    CONSTRAINT FK_CANH_BAO_CHI_TIET_LAN_DO
        FOREIGN KEY (MaLanDo, MaLoaiChiSo)
        REFERENCES CHI_TIET_LAN_DO (MaLanDo, MaLoaiChiSo)
        ON DELETE CASCADE,
    CONSTRAINT CK_CANH_BAO_MucDo
        CHECK (MucDo IN (N'Cần chú ý', N'Nguy hiểm'))
);
GO

CREATE INDEX IX_CANH_BAO_ThoiGianTao
    ON CANH_BAO (ThoiGianTao DESC);
CREATE INDEX IX_CANH_BAO_DaXem
    ON CANH_BAO (DaXem, ThoiGianTao DESC);
GO

PRINT N'Đã tạo 7 bảng.';
GO
