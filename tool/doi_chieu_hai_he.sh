#!/usr/bin/env bash
# Đối chiếu dữ liệu giữa SQL Server (script nộp bài) và SQLite (CSDL trong app).
#
# Nạp sql/sqlite/ vào một CSDL SQLite tạm, rồi chạy cùng một loạt truy vấn tổng
# hợp trên cả hai hệ. Hai bên phải cho ra kết quả giống hệt nhau.
#
# Cần SQL Server đang chạy và đã nạp dữ liệu:  tool/sqlserver.sh start && tool/sqlserver.sh run
# Dùng:  tool/doi_chieu_hai_he.sh
set -euo pipefail

cd "$(dirname "$0")/.."

TAM="$(mktemp -d)"
trap 'rm -rf "$TAM"' EXIT

DB="$TAM/hssk.db"
for file in 01_tao_bang 02_trigger 03_du_lieu_mau 04_view; do
  sqlite3 -bail "$DB" "PRAGMA foreign_keys = ON;" ".read sql/sqlite/$file.sql"
done

# Mỗi dòng: <nhãn> <TAB> <truy vấn trả về đúng một giá trị, viết được trên cả hai hệ>
TRUY_VAN=$(cat <<'EOF'
Số người dùng	SELECT COUNT(*) FROM NGUOI_DUNG
Số hồ sơ	SELECT COUNT(*) FROM HO_SO_SUC_KHOE
Số thiết bị	SELECT COUNT(*) FROM THIET_BI
Số loại chỉ số	SELECT COUNT(*) FROM LOAI_CHI_SO
Số lần đo	SELECT COUNT(*) FROM LAN_DO
Số giá trị đo	SELECT COUNT(*) FROM CHI_TIET_LAN_DO
Số cảnh báo	SELECT COUNT(*) FROM CANH_BAO
Cảnh báo chưa xem	SELECT COUNT(*) FROM CANH_BAO WHERE DaXem = 0
Cảnh báo nguy hiểm	SELECT COUNT(*) FROM CANH_BAO WHERE MucDo = 'Nguy hiểm'
Lần đo nhập thủ công	SELECT COUNT(*) FROM LAN_DO WHERE MaThietBi IS NULL
Lần đo đầu tiên	SELECT MIN(ThoiGianDo) FROM LAN_DO
Lần đo cuối cùng	SELECT MAX(ThoiGianDo) FROM LAN_DO
Tổng nhiệt độ × 10	SELECT CAST(ROUND(SUM(GiaTri) * 10, 0) AS INT) FROM CHI_TIET_LAN_DO WHERE MaLoaiChiSo = 1
Tổng nhịp tim	SELECT CAST(ROUND(SUM(GiaTri), 0) AS INT) FROM CHI_TIET_LAN_DO WHERE MaLoaiChiSo = 2
Tổng SpO2	SELECT CAST(ROUND(SUM(GiaTri), 0) AS INT) FROM CHI_TIET_LAN_DO WHERE MaLoaiChiSo = 3
Tổng huyết áp tâm thu	SELECT CAST(ROUND(SUM(GiaTri), 0) AS INT) FROM CHI_TIET_LAN_DO WHERE MaLoaiChiSo = 4
Tổng huyết áp tâm trương	SELECT CAST(ROUND(SUM(GiaTri), 0) AS INT) FROM CHI_TIET_LAN_DO WHERE MaLoaiChiSo = 5
Lần đo của người dùng 7	SELECT COUNT(*) FROM LAN_DO WHERE MaNguoiDung = 7
Lần đo bằng thiết bị 1	SELECT COUNT(*) FROM LAN_DO WHERE MaThietBi = 1
Mã cảnh báo khớp lần đo	SELECT SUM(MaCanhBao * MaLanDo + MaLoaiChiSo) FROM CANH_BAO
Cảnh báo đã xem khớp mã	SELECT SUM(MaCanhBao) FROM CANH_BAO WHERE DaXem = 1
Lần đo bình thường (view)	SELECT COUNT(*) FROM V_LAN_DO_TONG_HOP WHERE MucDo = 'Bình thường'
Lần đo cần chú ý (view)	SELECT COUNT(*) FROM V_LAN_DO_TONG_HOP WHERE MucDo = 'Cần chú ý'
Lần đo nguy hiểm (view)	SELECT COUNT(*) FROM V_LAN_DO_TONG_HOP WHERE MucDo = 'Nguy hiểm'
Cảnh báo của người dùng 7 (view)	SELECT COUNT(*) FROM V_CANH_BAO_CHI_TIET WHERE MaNguoiDung = 7
Tổng BMI × 10 (view)	SELECT CAST(ROUND(SUM(BMI) * 10, 0) AS INT) FROM V_HO_SO_TONG_HOP
Tổng tuổi (view)	SELECT SUM(Tuoi) FROM V_HO_SO_TONG_HOP
EOF
)

lech=0
printf '%-36s  %-22s  %-22s  %s\n' 'Phép đối chiếu' 'SQL Server' 'SQLite' ''
printf '%s\n' "$(printf '%.0s-' {1..93})"

while IFS=$'\t' read -r nhan truy_van; do
  # SQL Server cần tiền tố N cho chuỗi Unicode; SQLite thì không.
  truy_van_mssql="$(sed -E "s/'(Nguy hiểm|Bình thường|Cần chú ý)'/N'\\1'/g" <<< "$truy_van")"

  # </dev/null: docker exec -i sẽ đọc hết phần còn lại của vòng lặp nếu không chặn.
  mssql="$(tool/sqlserver.sh query "SET NOCOUNT ON; $truy_van_mssql" 2>&1 </dev/null | sed -n '3p' | tr -d '\r' | sed 's/[[:space:]]*$//')"
  sqlite="$(sqlite3 "$DB" "$truy_van")"

  if [[ "$mssql" == "$sqlite" ]]; then
    ket_qua='khớp'
  else
    ket_qua='LỆCH'
    lech=1
  fi
  printf '%-36s  %-22s  %-22s  %s\n' "$nhan" "$mssql" "$sqlite" "$ket_qua"
done <<< "$TRUY_VAN"

echo
if [[ "$lech" -eq 0 ]]; then
  echo 'Hai hệ quản trị cho kết quả giống nhau ở mọi phép đối chiếu.'
else
  echo 'CÓ CHỖ LỆCH giữa hai hệ — xem các dòng đánh dấu LỆCH.' >&2
  exit 1
fi
