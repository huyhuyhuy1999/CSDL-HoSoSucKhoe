#!/usr/bin/env python3
"""Tạo file mẫu định dạng (reference.docx) cho pandoc khi xuất tài liệu sang Word.

Lấy file mẫu mặc định của pandoc rồi chỉnh theo thể thức báo cáo thông dụng:
khổ A4, lề trái 3 cm, các lề còn lại 2 cm, chữ Times New Roman 13, tiêu đề đậm
màu đen, bảng có kẻ viền với chữ cỡ 11 và khối mã nguồn có nền xám nhạt.

Dùng:  python3 tool/word/tao_mau_word.py <đường-dẫn-ra.docx>
"""

from __future__ import annotations

import re
import subprocess
import sys
import zipfile
from pathlib import Path

PHONG_CHU = "Times New Roman"
RFONTS = (
    f'<w:rFonts w:ascii="{PHONG_CHU}" w:hAnsi="{PHONG_CHU}" '
    f'w:cs="{PHONG_CHU}" w:eastAsia="{PHONG_CHU}" />'
)

# Cỡ chữ tiêu đề tính bằng nửa điểm: 32 = 16pt.
TIEU_DE = {
    "Title": (36, ""),
    "Heading1": (32, ""),
    "Heading2": (28, ""),
    "Heading3": (26, ""),
    "Heading4": (26, "<w:i />"),
    "Heading5": (26, "<w:i />"),
}

VIEN_BANG = "".join(
    f'<w:{canh} w:val="single" w:sz="4" w:space="0" w:color="7F7F7F" />'
    for canh in ("top", "left", "bottom", "right", "insideH", "insideV")
)

# Kiểu đoạn văn cho chữ trong ô bảng, được bộ lọc loc.lua gán qua custom-style.
KIEU_NOI_DUNG_BANG = """
  <w:style w:type="paragraph" w:customStyle="1" w:styleId="NoiDungBang">
    <w:name w:val="Noi Dung Bang" />
    <w:basedOn w:val="Compact" />
    <w:qFormat />
    <w:rPr>
      <w:sz w:val="22" />
      <w:szCs w:val="22" />
    </w:rPr>
  </w:style>
"""

KIEU_MA_NGUON = """
  <w:style w:type="paragraph" w:customStyle="1" w:styleId="SourceCode">
    <w:name w:val="Source Code" />
    <w:basedOn w:val="Normal" />
    <w:link w:val="VerbatimChar" />
    <w:pPr>
      <w:shd w:val="clear" w:color="auto" w:fill="F3F5F5" />
      <w:wordWrap w:val="off" />
      <w:spacing w:before="80" w:after="160" w:line="240" w:lineRule="auto" />
      <w:jc w:val="left" />
    </w:pPr>
  </w:style>
"""


def sua_kieu(styles: str, ma_kieu: str, ham) -> str:
    """Áp `ham` lên khối <w:style> có styleId cho trước."""
    mau = re.compile(
        r'<w:style\b[^>]*w:styleId="%s"[^>]*>.*?</w:style>' % re.escape(ma_kieu), re.S
    )
    khop = mau.search(styles)
    if not khop:
        raise RuntimeError(f"File mẫu của pandoc không có kiểu {ma_kieu}")
    return styles[: khop.start()] + ham(khop.group(0)) + styles[khop.end() :]


def dat_ppr(khoi: str, ppr: str) -> str:
    """Thay (hoặc thêm) phần định dạng đoạn văn của một kiểu."""
    if "<w:pPr>" in khoi:
        return re.sub(r"<w:pPr>.*?</w:pPr>", ppr, khoi, flags=re.S)
    return khoi.replace("</w:style>", ppr + "</w:style>")


def chinh_styles(styles: str) -> str:
    # Mọi chỗ dùng phông theo chủ đề đều chuyển sang Times New Roman.
    styles = re.sub(r"<w:rFonts\b[^>]*Theme[^>]*/>", RFONTS, styles, flags=re.S)
    # Cỡ chữ mặc định 13pt.
    styles = re.sub(
        r"(<w:rPrDefault>.*?)<w:sz w:val=\"\d+\" />\s*<w:szCs w:val=\"\d+\" />",
        r'\1<w:sz w:val="26" /><w:szCs w:val="26" />',
        styles,
        count=1,
        flags=re.S,
    )

    for ma_kieu, (co, them) in TIEU_DE.items():
        rpr = (
            f"<w:rPr>{RFONTS}<w:b />{them}<w:color w:val=\"000000\" />"
            f'<w:sz w:val="{co}" /><w:szCs w:val="{co}" /></w:rPr>'
        )
        styles = sua_kieu(
            styles, ma_kieu, lambda k, rpr=rpr: re.sub(r"<w:rPr>.*?</w:rPr>", rpr, k, flags=re.S)
        )

    # Mỗi phần (tiêu đề cấp 1) bắt đầu ở trang mới.
    styles = sua_kieu(
        styles,
        "Heading1",
        lambda k: k.replace("<w:keepLines />", "<w:keepLines /><w:pageBreakBefore />", 1),
    )

    # Đoạn văn: căn đều hai bên, giãn dòng 1,3.
    styles = sua_kieu(
        styles,
        "BodyText",
        lambda k: dat_ppr(
            k,
            '<w:pPr><w:spacing w:before="120" w:after="120" w:line="312" w:lineRule="auto" />'
            '<w:jc w:val="both" /></w:pPr>',
        ),
    )
    # Kiểu Compact dùng trong ô bảng và danh sách: căn trái, dòng sít hơn.
    styles = sua_kieu(
        styles,
        "Compact",
        lambda k: dat_ppr(
            k,
            '<w:pPr><w:spacing w:before="40" w:after="40" w:line="264" w:lineRule="auto" />'
            '<w:jc w:val="left" /></w:pPr>',
        ),
    )

    # Bảng: kẻ viền, dòng tiêu đề đậm trên nền nhạt.
    def chinh_bang(khoi: str) -> str:
        khoi = khoi.replace("<w:tblCellMar>", f"<w:tblBorders>{VIEN_BANG}</w:tblBorders><w:tblCellMar>", 1)
        return re.sub(
            r'<w:tblStylePr w:type="firstRow">.*?</w:tblStylePr>',
            '<w:tblStylePr w:type="firstRow"><w:rPr><w:b /></w:rPr><w:tcPr>'
            '<w:shd w:val="clear" w:color="auto" w:fill="E3F1EE" />'
            '<w:vAlign w:val="center" /></w:tcPr></w:tblStylePr>',
            khoi,
            flags=re.S,
        )

    styles = sua_kieu(styles, "Table", chinh_bang)

    # Mã nguồn: Courier New cỡ 9 (có sẵn trên cả Windows lẫn macOS), khối mã nền xám nhạt.
    styles = sua_kieu(
        styles,
        "VerbatimChar",
        lambda k: re.sub(
            r"<w:rPr>.*?</w:rPr>",
            '<w:rPr><w:rFonts w:ascii="Courier New" w:hAnsi="Courier New" w:cs="Courier New" />'
            '<w:sz w:val="18" /><w:szCs w:val="18" /></w:rPr>',
            k,
            flags=re.S,
        ),
    )
    return styles.replace("</w:styles>", KIEU_MA_NGUON + KIEU_NOI_DUNG_BANG + "</w:styles>")


def chinh_document(document: str) -> str:
    # Khổ A4 (11906 × 16838 twip), lề trái 3 cm, các lề còn lại 2 cm.
    trang = (
        '<w:pgSz w:w="11906" w:h="16838" />'
        '<w:pgMar w:top="1134" w:right="1134" w:bottom="1134" w:left="1701" '
        'w:header="709" w:footer="709" w:gutter="0" />'
    )
    moi, so_lan = re.subn(r"</w:sectPr>", trang + "</w:sectPr>", document, count=1)
    if so_lan != 1:
        raise RuntimeError("Không tìm thấy <w:sectPr> trong file mẫu của pandoc")
    return moi


def main() -> int:
    if len(sys.argv) != 2:
        print(__doc__)
        return 2
    dich = Path(sys.argv[1])
    goc = dich.with_suffix(".goc.docx")
    goc.write_bytes(
        subprocess.run(
            ["pandoc", "--print-default-data-file", "reference.docx"],
            check=True,
            capture_output=True,
        ).stdout
    )

    with zipfile.ZipFile(goc) as vao, zipfile.ZipFile(dich, "w", zipfile.ZIP_DEFLATED) as ra:
        for muc in vao.infolist():
            du_lieu = vao.read(muc.filename)
            if muc.filename == "word/styles.xml":
                du_lieu = chinh_styles(du_lieu.decode("utf-8")).encode("utf-8")
            elif muc.filename == "word/document.xml":
                du_lieu = chinh_document(du_lieu.decode("utf-8")).encode("utf-8")
            ra.writestr(muc, du_lieu)
    goc.unlink()
    return 0


if __name__ == "__main__":
    sys.exit(main())
