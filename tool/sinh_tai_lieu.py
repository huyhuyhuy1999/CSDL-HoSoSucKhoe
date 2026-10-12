#!/usr/bin/env python3
"""Sinh tài liệu Markdown trong docs/ từ các bản mẫu ở tool/tai_lieu/.

Bản mẫu là Markdown thường, có thêm các chỉ thị nằm riêng một dòng:

    {{BANG: NGUOI_DUNG}}        cấu trúc bảng và ràng buộc, đọc từ SQL Server
    {{SQL: 04_nguoi_dung.sql}}  từng mục của file script kèm KẾT QUẢ CHẠY THẬT
    {{TRUYVAN: SELECT ...}}     kết quả của một câu truy vấn
    {{KIEMTHU}}                 bảng kết quả của 11_kiem_thu.sql
    {{DOICHIEU}}                bảng đối chiếu SQL Server với SQLite

Nhờ vậy câu lệnh và kết quả trong tài liệu luôn khớp với script: muốn sửa thì
sửa file .sql rồi chạy lại công cụ này.

Cần SQL Server đang chạy và đã nạp dữ liệu:
    tool/sqlserver.sh start && tool/sqlserver.sh run
Dùng:
    python3 tool/sinh_tai_lieu.py
"""

from __future__ import annotations

import re
import subprocess
import sys
import uuid
from pathlib import Path

GOC = Path(__file__).resolve().parent.parent
THU_MUC_MAU = GOC / "tool" / "tai_lieu"
THU_MUC_RA = GOC / "docs"
THU_MUC_SQL = GOC / "sql" / "sqlserver"

# Số dòng tối đa hiển thị cho một bảng kết quả.
SO_DONG_TOI_DA = 12

# ── Ý nghĩa của từng cột và từng ràng buộc (viết tay) ──────────────────────
# Công cụ sẽ báo lỗi nếu cơ sở dữ liệu có cột / ràng buộc chưa được mô tả,
# để tài liệu không bao giờ thiếu so với script.
MO_TA_COT = {
    "NGUOI_DUNG": {
        "MaNguoiDung": "Khóa chính, tự tăng",
        "HoTen": "Họ và tên",
        "GioiTinh": "Nam, Nữ hoặc Khác",
        "NgaySinh": "Ngày sinh",
        "SoDienThoai": "Số điện thoại, chỉ gồm chữ số",
        "Email": "Thư điện tử",
        "DiaChi": "Địa chỉ liên hệ",
        "NgayTao": "Thời điểm tạo bản ghi",
    },
    "HO_SO_SUC_KHOE": {
        "MaHoSo": "Khóa chính, tự tăng",
        "MaNguoiDung": "Người sở hữu hồ sơ",
        "ChieuCao": "Chiều cao (cm)",
        "CanNang": "Cân nặng (kg)",
        "NhomMau": "Nhóm máu ABO kèm Rh",
        "TienSuBenh": "Tiền sử bệnh",
        "DiUng": "Dị ứng, phân cách bằng dấu phẩy",
        "NgayCapNhat": "Lần cập nhật hồ sơ gần nhất",
    },
    "THIET_BI": {
        "MaThietBi": "Khóa chính, tự tăng",
        "TenThietBi": "Tên thiết bị",
        "LoaiThietBi": "Loại thiết bị",
        "MaDinhDanh": "Địa chỉ MAC hoặc số serial",
        "TrangThai": "Hoạt động, Bảo trì hoặc Ngừng sử dụng",
        "MoTa": "Ghi chú về thiết bị",
    },
    "LOAI_CHI_SO": {
        "MaLoaiChiSo": "Khóa chính, tự tăng",
        "KyHieu": "Mã ngắn dùng trong chương trình",
        "TenChiSo": "Tên chỉ số",
        "DonViDo": "Đơn vị đo",
        "SoThapPhan": "Số chữ số thập phân khi hiển thị (0 hoặc 1)",
        "GiaTriMin": "Cận dưới của khoảng hợp lệ",
        "GiaTriMax": "Cận trên của khoảng hợp lệ",
        "BinhThuongMin": "Cận dưới của khoảng bình thường",
        "BinhThuongMax": "Cận trên của khoảng bình thường",
        "CanhBaoMin": "Dưới mức này là nguy hiểm",
        "CanhBaoMax": "Trên mức này là nguy hiểm",
    },
    "LAN_DO": {
        "MaLanDo": "Khóa chính, tự tăng",
        "MaNguoiDung": "Người được đo",
        "MaThietBi": "Thiết bị đo; NULL nếu nhập thủ công",
        "NguonDuLieu": "Thiết bị hoặc Thủ công",
        "ThoiGianDo": "Thời điểm đo",
        "GhiChu": "Ghi chú của lần đo",
    },
    "CHI_TIET_LAN_DO": {
        "MaLanDo": "Lần đo chứa giá trị này",
        "MaLoaiChiSo": "Chỉ số được đo",
        "GiaTri": "Giá trị đo được",
    },
    "CANH_BAO": {
        "MaCanhBao": "Khóa chính, tự tăng",
        "MaLanDo": "Lần đo phát sinh cảnh báo",
        "MaLoaiChiSo": "Chỉ số vượt ngưỡng",
        "MucDo": "Cần chú ý hoặc Nguy hiểm",
        "NoiDung": "Câu mô tả cảnh báo",
        "ThoiGianTao": "Thời điểm phát sinh, bằng thời gian đo",
        "DaXem": "0 = chưa xem, 1 = đã xem",
    },
}

MO_TA_RANG_BUOC = {
    "PK_NGUOI_DUNG": "Mỗi người dùng một mã duy nhất",
    "CK_NGUOI_DUNG_HoTen": "Họ tên có ít nhất 2 ký tự",
    "CK_NGUOI_DUNG_GioiTinh": "Chỉ nhận Nam, Nữ, Khác",
    "CK_NGUOI_DUNG_NgaySinh": "Từ năm 1900 và không ở tương lai",
    "CK_NGUOI_DUNG_SoDienThoai": "9 đến 12 ký tự, toàn chữ số",
    "CK_NGUOI_DUNG_Email": "Có dạng tên@miền.đuôi",
    "UQ_NGUOI_DUNG_Email": "Email không trùng; cho phép nhiều dòng NULL",
    "PK_HO_SO_SUC_KHOE": "Mỗi hồ sơ một mã duy nhất",
    "UQ_HO_SO_SUC_KHOE_MaNguoiDung": "Mỗi người tối đa một hồ sơ (quan hệ 1–1)",
    "FK_HO_SO_SUC_KHOE_NGUOI_DUNG": "Hồ sơ phải thuộc một người dùng có thật; xóa người thì xóa hồ sơ",
    "CK_HO_SO_SUC_KHOE_ChieuCao": "Từ 30 đến 250 cm",
    "CK_HO_SO_SUC_KHOE_CanNang": "Từ 1 đến 300 kg",
    "CK_HO_SO_SUC_KHOE_NhomMau": "Một trong 8 nhóm máu",
    "PK_THIET_BI": "Mỗi thiết bị một mã duy nhất",
    "UQ_THIET_BI_MaDinhDanh": "Không có hai thiết bị trùng mã định danh",
    "CK_THIET_BI_LoaiThietBi": "Một trong 4 loại thiết bị",
    "CK_THIET_BI_TrangThai": "Một trong 3 trạng thái",
    "PK_LOAI_CHI_SO": "Mỗi loại chỉ số một mã duy nhất",
    "UQ_LOAI_CHI_SO_KyHieu": "Ký hiệu không trùng",
    "UQ_LOAI_CHI_SO_TenChiSo": "Tên chỉ số không trùng",
    "CK_LOAI_CHI_SO_SoThapPhan": "Chỉ nhận 0 hoặc 1",
    "CK_LOAI_CHI_SO_ThuTuNguong": "Ba khoảng ngưỡng phải lồng nhau đúng thứ tự",
    "PK_LAN_DO": "Mỗi lần đo một mã duy nhất",
    "FK_LAN_DO_NGUOI_DUNG": "Lần đo phải của một người dùng có thật; xóa người thì xóa lần đo",
    "FK_LAN_DO_THIET_BI": "Thiết bị phải tồn tại; không xóa được thiết bị đã có lần đo",
    "CK_LAN_DO_NguonDuLieu": "Chỉ nhận Thiết bị, Thủ công",
    "CK_LAN_DO_NguonKhopThietBi": "Nguồn Thiết bị phải có mã thiết bị, nguồn Thủ công thì không",
    "CK_LAN_DO_ThoiGianDo": "Không ở tương lai",
    "IX_LAN_DO_NguoiDung_ThoiGian": "Tăng tốc truy vấn lịch sử của một người",
    "IX_LAN_DO_ThoiGianDo": "Tăng tốc truy vấn theo khoảng thời gian",
    "IX_LAN_DO_MaThietBi": "Tăng tốc thống kê theo thiết bị",
    "PK_CHI_TIET_LAN_DO": "Mỗi chỉ số chỉ xuất hiện một lần trong một lần đo",
    "FK_CHI_TIET_LAN_DO_LAN_DO": "Giá trị phải thuộc một lần đo có thật; xóa lần đo thì xóa giá trị",
    "FK_CHI_TIET_LAN_DO_LOAI_CHI_SO": "Chỉ số phải có trong danh mục; không xóa được loại đang dùng",
    "IX_CHI_TIET_LAN_DO_MaLoaiChiSo": "Tăng tốc thống kê theo chỉ số",
    "PK_CANH_BAO": "Mỗi cảnh báo một mã duy nhất",
    "UQ_CANH_BAO_ChiTiet": "Mỗi giá trị đo tối đa một cảnh báo",
    "FK_CANH_BAO_CHI_TIET_LAN_DO": "Cảnh báo gắn với một giá trị đo có thật; xóa giá trị thì xóa cảnh báo",
    "CK_CANH_BAO_MucDo": "Chỉ nhận Cần chú ý, Nguy hiểm",
    "IX_CANH_BAO_ThoiGianTao": "Tăng tốc liệt kê cảnh báo mới nhất",
    "IX_CANH_BAO_DaXem": "Tăng tốc lọc cảnh báo chưa xem",
}


# ── Chạy T-SQL trên SQL Server trong container ────────────────────────────
def chay_sql(sql: str) -> str:
    """Chạy một đoạn T-SQL (có thể gồm nhiều lô GO) và trả về đầu ra của sqlcmd."""
    tam = THU_MUC_SQL / f".tam_{uuid.uuid4().hex}.sql"
    tam.write_text(
        "USE QuanLyHoSoSucKhoe;\nGO\nSET NOCOUNT ON;\nGO\n" + sql + "\nGO\n",
        encoding="utf-8",
    )
    try:
        kq = subprocess.run(
            [str(GOC / "tool" / "sqlserver.sh"), "file", tam.name, "-W", "-s", "|"],
            capture_output=True,
            text=True,
            stdin=subprocess.DEVNULL,
        )
    finally:
        tam.unlink(missing_ok=True)

    dau_ra = kq.stdout + kq.stderr
    if kq.returncode != 0 or re.search(r"^Msg \d+, Level 1[1-9]", dau_ra, re.M):
        raise RuntimeError(f"SQL Server báo lỗi khi chạy:\n{sql}\n---\n{dau_ra}")
    return dau_ra


def tach_bang(dau_ra: str) -> list[tuple[list[str], list[list[str]]]]:
    """Tách đầu ra của sqlcmd thành các bảng kết quả (tiêu đề, các dòng)."""
    cac_bang = []
    dong = [d.rstrip("\r") for d in dau_ra.split("\n")]

    def la_tieu_de(k: int) -> bool:
        # Một bảng bắt đầu bằng dòng tiêu đề, ngay sau là dòng gạch ngang.
        return (
            k + 1 < len(dong)
            and bool(dong[k].strip())
            and re.fullmatch(r"-+(\|-+)*", dong[k + 1]) is not None
        )

    i = 0
    while i < len(dong) - 1:
        if la_tieu_de(i):
            tieu_de = dong[i].split("|")
            so_cot = len(tieu_de)
            du_lieu = []
            i += 2
            # Với SET NOCOUNT ON, hai bảng liền nhau không có dòng trống ngăn cách.
            while i < len(dong) and dong[i] != "" and not la_tieu_de(i):
                du_lieu.append(dong[i].split("|", so_cot - 1))
                i += 1
            cac_bang.append((tieu_de, du_lieu))
        else:
            i += 1
    return cac_bang


def bang_markdown(tieu_de: list[str], du_lieu: list[list[str]], gioi_han=SO_DONG_TOI_DA) -> str:
    def o(gia_tri: str) -> str:
        gia_tri = gia_tri.strip().replace("|", "\\|")
        return "*NULL*" if gia_tri == "NULL" else gia_tri

    if not du_lieu:
        return "*(Truy vấn không trả về dòng nào.)*\n"

    dong = ["| " + " | ".join(tieu_de) + " |", "|" + "|".join("---" for _ in tieu_de) + "|"]
    for d in du_lieu[:gioi_han]:
        dong.append("| " + " | ".join(o(v) for v in d) + " |")
    kq = "\n".join(dong) + "\n"
    if len(du_lieu) > gioi_han:
        kq += f"\n*… còn {len(du_lieu) - gioi_han} dòng nữa (tổng cộng {len(du_lieu)} dòng).*\n"
    return kq


# ── {{SQL: file}} — trình bày một file script theo từng mục ────────────────
RE_MUC = re.compile(r"^-- ((?:\d+|[A-H])\.\d+) (.*)$")
RE_GACH = re.compile(r"^-- =+$")


def tach_muc(noi_dung: str):
    """Tách file .sql thành: [(tiêu đề lớn, [(số mục, tên, mô tả, sql)])]."""
    dong = noi_dung.split("\n")
    nhom = []  # [(tieu_de_lon, [muc])]
    muc_hien_tai = None
    i = 0
    da_qua_dau_file = False

    def dong_muc():
        nonlocal muc_hien_tai
        if muc_hien_tai and "".join(muc_hien_tai["sql"]).strip():
            nhom[-1][1].append(muc_hien_tai)
        muc_hien_tai = None

    while i < len(dong):
        d = dong[i]
        # Khối tiêu đề lớn: gạch / các dòng chú thích / gạch.
        if RE_GACH.match(d):
            j = i + 1
            than = []
            while j < len(dong) and not RE_GACH.match(dong[j]):
                than.append(dong[j][3:] if dong[j].startswith("-- ") else dong[j].lstrip("-"))
                j += 1
            i = j + 1
            if not da_qua_dau_file:
                da_qua_dau_file = True  # khối đầu tiên là phần giới thiệu file
                continue
            dong_muc()
            nhom.append((than[0].strip() if than else "", []))
            continue

        if not nhom:
            i += 1
            continue

        m = RE_MUC.match(d)
        la_chu_thich_dau_khoi = (
            d.startswith("-- ") and not m and muc_hien_tai is None
        )
        if m or la_chu_thich_dau_khoi:
            dong_muc()
            so, ten = (m.group(1), m.group(2)) if m else ("", d[3:])
            mo_ta = []
            i += 1
            # Các dòng chú thích ngay sau tiêu đề mục là phần giải thích.
            while i < len(dong) and dong[i].startswith("--"):
                mo_ta.append(dong[i].lstrip("-").strip())
                i += 1
            muc_hien_tai = {"so": so, "ten": ten, "mo_ta": " ".join(mo_ta), "sql": []}
            continue

        if muc_hien_tai is not None:
            muc_hien_tai["sql"].append(d + "\n")
        i += 1

    dong_muc()
    return nhom


def trinh_bay_sql(ten_file: str) -> str:
    noi_dung = (THU_MUC_SQL / ten_file).read_text(encoding="utf-8")
    ra = []
    for tieu_de_lon, cac_muc in tach_muc(noi_dung):
        if not cac_muc:
            continue
        ra.append(f"### {tieu_de_lon}\n")
        for muc in cac_muc:
            ten = muc["ten"].rstrip(".")
            # Tiêu đề mục có thể kết thúc bằng dấu ":" hoặc "." rồi giải thích tiếp.
            if muc["so"]:
                ra.append(f"#### {muc['so']} {ten}\n")
                if muc["mo_ta"]:
                    ra.append(muc["mo_ta"] + "\n")
            else:
                # Mục không đánh số: cả khối chú thích là một đoạn giải thích.
                ra.append(f"{muc['ten']} {muc['mo_ta']}".strip() + "\n")

            sql = "".join(muc["sql"]).strip("\n")
            # Mã hiển thị: bỏ các dòng GO đứng riêng và dòng trống thừa ở cuối.
            hien_thi = re.sub(r"\n*^GO\s*$", "", sql, flags=re.M).strip("\n")
            ra.append("```sql\n" + hien_thi + "\n```\n")

            cac_bang = tach_bang(chay_sql(sql))
            if cac_bang:
                ra.append("**Kết quả:**\n")
                for tieu_de, du_lieu in cac_bang:
                    ra.append(bang_markdown(tieu_de, du_lieu))
    return "\n".join(ra)


# ── {{BANG: tên}} — cấu trúc bảng đọc từ danh mục hệ thống ─────────────────
def kieu_du_lieu(d: dict) -> str:
    kieu = d["DATA_TYPE"].upper()
    if kieu in ("NVARCHAR", "VARCHAR", "CHAR", "NCHAR"):
        kieu += f"({d['CHARACTER_MAXIMUM_LENGTH']})"
    elif kieu in ("DECIMAL", "NUMERIC"):
        kieu += f"({d['NUMERIC_PRECISION']},{d['NUMERIC_SCALE']})"
    elif kieu == "DATETIME2":
        kieu += f"({d['DATETIME_PRECISION']})"
    if d["LaTuTang"] == "1":
        kieu += " IDENTITY"
    return kieu


def mac_dinh(gia_tri: str) -> str:
    if gia_tri == "NULL":
        return ""
    while gia_tri.startswith("(") and gia_tri.endswith(")"):
        gia_tri = gia_tri[1:-1]
    return "`" + gia_tri.replace("sysdatetime", "SYSDATETIME") + "`"


def truy_van_dict(sql: str) -> list[dict]:
    cac_bang = tach_bang(chay_sql(sql))
    if not cac_bang:
        return []
    tieu_de, du_lieu = cac_bang[0]
    return [dict(zip(tieu_de, (v.strip() for v in d))) for d in du_lieu]


def trinh_bay_bang(bang: str) -> str:
    cot = truy_van_dict(f"""
        SELECT c.COLUMN_NAME, c.DATA_TYPE, c.CHARACTER_MAXIMUM_LENGTH,
               c.NUMERIC_PRECISION, c.NUMERIC_SCALE, c.DATETIME_PRECISION,
               c.IS_NULLABLE, c.COLUMN_DEFAULT,
               COLUMNPROPERTY(OBJECT_ID(c.TABLE_NAME), c.COLUMN_NAME, 'IsIdentity') AS LaTuTang
        FROM INFORMATION_SCHEMA.COLUMNS AS c
        WHERE c.TABLE_NAME = '{bang}'
        ORDER BY c.ORDINAL_POSITION""")
    if not cot:
        raise RuntimeError(f"Không tìm thấy bảng {bang}")

    ra = ["| Cột | Kiểu dữ liệu | Bắt buộc | Mặc định | Ý nghĩa |", "|---|---|:---:|---|---|"]
    for d in cot:
        ten = d["COLUMN_NAME"]
        if ten not in MO_TA_COT.get(bang, {}):
            raise RuntimeError(f"Chưa mô tả cột {bang}.{ten} trong MO_TA_COT")
        ra.append(
            f"| `{ten}` | {kieu_du_lieu(d)} | {'' if d['IS_NULLABLE'] == 'YES' else '✓'} "
            f"| {mac_dinh(d['COLUMN_DEFAULT'])} | {MO_TA_COT[bang][ten]} |"
        )

    # Ràng buộc: khóa chính, duy nhất, khóa ngoại, CHECK và chỉ mục.
    rang_buoc = truy_van_dict(f"""
        SELECT kc.name AS Ten,
               CASE kc.type WHEN 'PK' THEN N'Khóa chính' ELSE N'Duy nhất' END AS Loai,
               STRING_AGG(c.name, ', ') WITHIN GROUP (ORDER BY ic.key_ordinal) AS Cot,
               1 AS ThuTu
        FROM sys.key_constraints AS kc
        JOIN sys.index_columns AS ic ON ic.object_id = kc.parent_object_id AND ic.index_id = kc.unique_index_id
        JOIN sys.columns AS c ON c.object_id = ic.object_id AND c.column_id = ic.column_id
        WHERE kc.parent_object_id = OBJECT_ID('{bang}')
        GROUP BY kc.name, kc.type
        UNION ALL
        SELECT fk.name,
               CONCAT(N'Khóa ngoại → ', OBJECT_NAME(fk.referenced_object_id),
                      CASE fk.delete_referential_action WHEN 1 THEN N' (xóa dây chuyền)' ELSE N'' END),
               STRING_AGG(c.name, ', ') WITHIN GROUP (ORDER BY fkc.constraint_column_id),
               2
        FROM sys.foreign_keys AS fk
        JOIN sys.foreign_key_columns AS fkc ON fkc.constraint_object_id = fk.object_id
        JOIN sys.columns AS c ON c.object_id = fkc.parent_object_id AND c.column_id = fkc.parent_column_id
        WHERE fk.parent_object_id = OBJECT_ID('{bang}')
        GROUP BY fk.name, fk.referenced_object_id, fk.delete_referential_action
        UNION ALL
        SELECT cc.name, N'CHECK', ISNULL(c.name, N'(nhiều cột)'), 3
        FROM sys.check_constraints AS cc
        LEFT JOIN sys.columns AS c ON c.object_id = cc.parent_object_id AND c.column_id = cc.parent_column_id
        WHERE cc.parent_object_id = OBJECT_ID('{bang}')
        UNION ALL
        SELECT i.name,
               CASE WHEN i.is_unique = 1 THEN N'Chỉ mục duy nhất có điều kiện' ELSE N'Chỉ mục' END,
               STRING_AGG(c.name, ', ') WITHIN GROUP (ORDER BY ic.key_ordinal),
               4
        FROM sys.indexes AS i
        JOIN sys.index_columns AS ic ON ic.object_id = i.object_id AND ic.index_id = i.index_id
        JOIN sys.columns AS c ON c.object_id = ic.object_id AND c.column_id = ic.column_id
        WHERE i.object_id = OBJECT_ID('{bang}')
          AND i.is_primary_key = 0 AND i.is_unique_constraint = 0 AND i.type > 0
        GROUP BY i.name, i.is_unique
        ORDER BY ThuTu, Ten""")

    ra += ["", "| Ràng buộc | Loại | Cột | Ý nghĩa |", "|---|---|---|---|"]
    for d in rang_buoc:
        ten = d["Ten"]
        if ten not in MO_TA_RANG_BUOC:
            raise RuntimeError(f"Chưa mô tả ràng buộc {ten} trong MO_TA_RANG_BUOC")
        ra.append(f"| `{ten}` | {d['Loai']} | {d['Cot']} | {MO_TA_RANG_BUOC[ten]} |")
    return "\n".join(ra) + "\n"


# ── {{KIEMTHU}} và {{DOICHIEU}} ───────────────────────────────────────────
TEN_NHOM_KIEM_THU = {
    "PK": "Khóa chính",
    "UQ": "Ràng buộc duy nhất",
    "FK": "Khóa ngoại",
    "CS": "Xóa dây chuyền",
    "CK": "Dữ liệu không hợp lệ (CHECK, NOT NULL)",
    "TG": "Trigger",
    "CR": "Thêm, sửa, xóa",
    "TK": "Tìm kiếm và lọc",
    "ST": "Thống kê",
}


def trinh_bay_kiem_thu() -> str:
    kq = subprocess.run(
        [str(GOC / "tool" / "sqlserver.sh"), "file", "11_kiem_thu.sql", "-W", "-s", "|"],
        capture_output=True, text=True, stdin=subprocess.DEVNULL,
    )
    cac_bang = tach_bang(kq.stdout)
    if kq.returncode != 0 or len(cac_bang) < 2:
        raise RuntimeError("Không chạy được 11_kiem_thu.sql:\n" + kq.stdout + kq.stderr)

    tieu_de, du_lieu = cac_bang[0]
    ra = []
    nhom_hien_tai = None
    for ma, mo_ta, mong_doi, thuc_te, ket_luan in du_lieu:
        nhom = ma.split("-")[0]
        if nhom != nhom_hien_tai:
            nhom_hien_tai = nhom
            ra += ["", f"### {TEN_NHOM_KIEM_THU[nhom]}", "",
                   "| Mã | Mục tiêu kiểm thử | Kết quả mong đợi | Kết quả thực tế | Kết luận |",
                   "|---|---|---|---|:---:|"]
        # Thông báo lỗi tiếng Anh của SQL Server khá dài: giữ phần đầu.
        thuc_te = thuc_te.strip()
        if len(thuc_te) > 110:
            thuc_te = thuc_te[:107].rstrip() + "…"
        thuc_te = thuc_te.replace("|", "\\|")
        ra.append(f"| {ma} | {mo_ta} | {mong_doi} | {thuc_te} | **{ket_luan.strip()}** |")

    tong = dict(zip(cac_bang[1][0], cac_bang[1][1][0]))
    ra += ["", f"**Tổng kết: {tong['SoCaDat']}/{tong['TongSoCa']} ca đạt, "
               f"{tong['SoCaKhongDat']} ca không đạt.**", ""]
    return "\n".join(ra)


def trinh_bay_doi_chieu() -> str:
    kq = subprocess.run([str(GOC / "tool" / "doi_chieu_hai_he.sh")],
                        capture_output=True, text=True, stdin=subprocess.DEVNULL)
    if kq.returncode != 0:
        raise RuntimeError("Hai hệ quản trị lệch nhau:\n" + kq.stdout + kq.stderr)
    ra = ["| Phép đối chiếu | SQL Server | SQLite | Kết quả |", "|---|---|---|:---:|"]
    for dong in kq.stdout.split("\n")[2:]:
        m = re.match(r"^(.*?)\s{2,}(\S.*?)\s{2,}(\S.*?)\s+(khớp|LỆCH)\s*$", dong)
        if m:
            ra.append("| " + " | ".join(g.strip() for g in m.groups()) + " |")
    return "\n".join(ra) + "\n"


# ── Xử lý bản mẫu ─────────────────────────────────────────────────────────
RE_CHI_THI = re.compile(r"^\{\{(BANG|SQL|TRUYVAN|KIEMTHU|DOICHIEU)(?::\s*(.*?))?\}\}\s*$")


def sinh(ban_mau: Path) -> str:
    ra = []
    for dong in ban_mau.read_text(encoding="utf-8").split("\n"):
        m = RE_CHI_THI.match(dong)
        if not m:
            ra.append(dong)
            continue
        loai, tham_so = m.group(1), (m.group(2) or "").strip()
        if loai == "BANG":
            ra.append(trinh_bay_bang(tham_so))
        elif loai == "SQL":
            ra.append(trinh_bay_sql(tham_so))
        elif loai == "TRUYVAN":
            cac_bang = tach_bang(chay_sql(tham_so))
            ra.append("\n".join(bang_markdown(t, d, gioi_han=40) for t, d in cac_bang))
        elif loai == "KIEMTHU":
            ra.append(trinh_bay_kiem_thu())
        elif loai == "DOICHIEU":
            ra.append(trinh_bay_doi_chieu())
    van_ban = "\n".join(ra)
    # Gọn lại các chỗ thừa dòng trống do ghép nhiều đoạn.
    return re.sub(r"\n{3,}", "\n\n", van_ban).rstrip("\n") + "\n"


def main() -> int:
    chi_dinh = set(sys.argv[1:])
    for ban_mau in sorted(THU_MUC_MAU.glob("*.md")):
        if chi_dinh and ban_mau.stem not in chi_dinh and ban_mau.name not in chi_dinh:
            continue
        print(f"==> {ban_mau.name}", flush=True)
        (THU_MUC_RA / ban_mau.name).write_text(sinh(ban_mau), encoding="utf-8")
    return 0


if __name__ == "__main__":
    sys.exit(main())
