#!/usr/bin/env bash
# Dựng lại sơ đồ và xuất bộ tài liệu trong docs/ sang Word.
#
#   tool/xuat_tai_lieu.sh          Dựng sơ đồ rồi xuất Word
#   tool/xuat_tai_lieu.sh so_do    Chỉ dựng sơ đồ: docs/so_do/*.puml → *.png
#   tool/xuat_tai_lieu.sh word     Chỉ xuất Word: docs/NN_*.md → docs/word/NN_*.docx
#
# Các file docs/NN_*.md được sinh từ bản mẫu bằng tool/sinh_tai_lieu.py; chạy
# công cụ đó trước nếu vừa sửa script SQL hoặc bản mẫu.
#
# Cần: plantuml, pandoc (brew install plantuml pandoc).
set -euo pipefail

cd "$(dirname "$0")/.."

TAM="$(mktemp -d)"
trap 'rm -rf "$TAM"' EXIT

dung_so_do() {
  echo '==> Dựng sơ đồ PlantUML'
  plantuml -charset UTF-8 -tpng -Sdpi=160 docs/so_do/*.puml
}

xuat_word() {
  local mau="$TAM/mau.docx"
  python3 tool/word/tao_mau_word.py "$mau"

  mkdir -p docs/word
  local chung=(--from gfm --to docx --resource-path=docs
               --reference-doc="$mau" --lua-filter=tool/word/loc.lua)

  local tep ten
  for tep in docs/[0-9][0-9]_*.md; do
    ten="$(basename "$tep" .md)"
    echo "==> docs/word/$ten.docx"
    pandoc "$tep" "${chung[@]}" -o "docs/word/$ten.docx"
  done

  # Bản gộp cả 12 phần, có mục lục, để in hoặc ghép vào báo cáo chung.
  echo '==> docs/word/00_toan_bo_tai_lieu.docx'
  pandoc docs/[0-9][0-9]_*.md "${chung[@]}" \
    --toc --toc-depth=2 \
    --metadata title='Cơ sở dữ liệu quản lý hồ sơ sức khỏe và lịch sử theo dõi chỉ số sức khỏe' \
    --metadata toc-title='Mục lục' \
    -o docs/word/00_toan_bo_tai_lieu.docx
}

case "${1:-tat_ca}" in
  so_do)  dung_so_do ;;
  word)   xuat_word ;;
  tat_ca) dung_so_do; xuat_word ;;
  *)      sed -n '2,11p' "$0"; exit 2 ;;
esac
