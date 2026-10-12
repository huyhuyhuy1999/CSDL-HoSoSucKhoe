#!/usr/bin/env bash
# Chạy SQL Server 2022 trong Docker để kiểm chứng bộ script T-SQL ở sql/sqlserver/.
#
#   tool/sqlserver.sh start            Khởi động máy ảo Docker và container SQL Server
#   tool/sqlserver.sh run              Tạo lại CSDL, chạy lần lượt mọi script 00 → 11
#   tool/sqlserver.sh file <tên.sql>   Chạy một file trong sql/sqlserver/
#   tool/sqlserver.sh query "<T-SQL>"  Chạy một câu lệnh trên CSDL QuanLyHoSoSucKhoe
#   tool/sqlserver.sh stop             Dừng container (dữ liệu trong container vẫn giữ)
#
# Cần: colima, docker (brew install colima docker) và Rosetta trên máy Apple Silicon.
# Mật khẩu tài khoản sa được sinh ngẫu nhiên ở lần chạy đầu và lưu trong
# tool/.sqlserver.env (không đưa vào git).
set -euo pipefail

cd "$(dirname "$0")/.."

CONTAINER="hssk-sqlserver"
IMAGE="mcr.microsoft.com/mssql/server:2022-latest"
CSDL="QuanLyHoSoSucKhoe"
ENV_FILE="tool/.sqlserver.env"
SQLCMD="/opt/mssql-tools18/bin/sqlcmd"

nap_mat_khau() {
  if [[ ! -f "$ENV_FILE" ]]; then
    # SQL Server đòi mật khẩu có chữ hoa, chữ thường, chữ số và ký tự đặc biệt.
    printf 'MSSQL_SA_PASSWORD=%s\n' "$(openssl rand -hex 12)aA1!" > "$ENV_FILE"
    chmod 600 "$ENV_FILE"
  fi
  # shellcheck disable=SC1090
  source "$ENV_FILE"
}

# sqlcmd chạy bên trong container; -I bật QUOTED_IDENTIFIER như mặc định của SSMS
# (bắt buộc với bảng có chỉ mục có điều kiện), -b dừng khi gặp lỗi.
sqlcmd_trong_container() {
  docker exec -i -e SQLCMDPASSWORD="$MSSQL_SA_PASSWORD" "$CONTAINER" \
    "$SQLCMD" -S localhost -U sa -C -I -b "$@"
}

cho_san_sang() {
  printf 'Chờ SQL Server sẵn sàng'
  for _ in $(seq 1 60); do
    if sqlcmd_trong_container -Q "SELECT 1" >/dev/null 2>&1; then
      echo ' — xong.'
      return 0
    fi
    printf '.'
    sleep 2
  done
  echo
  echo 'SQL Server không khởi động được. Xem log: docker logs '"$CONTAINER" >&2
  return 1
}

lenh_start() {
  if ! docker info >/dev/null 2>&1; then
    colima start --vm-type vz --vz-rosetta --cpu 4 --memory 6 --disk 30
  fi
  if docker ps -a --format '{{.Names}}' | grep -qx "$CONTAINER"; then
    docker start "$CONTAINER" >/dev/null
  else
    # ACCEPT_EULA=Y: đồng ý điều khoản giấy phép của Microsoft cho SQL Server.
    docker run -d --name "$CONTAINER" --platform linux/amd64 \
      -e ACCEPT_EULA=Y -e MSSQL_PID=Developer \
      -e MSSQL_SA_PASSWORD="$MSSQL_SA_PASSWORD" \
      -e TZ=Asia/Ho_Chi_Minh \
      -p 1433:1433 \
      -v "$PWD/sql/sqlserver:/sql:ro" \
      "$IMAGE" >/dev/null
  fi
  cho_san_sang
}

lenh_run() {
  local loi=0
  for file in sql/sqlserver/[0-9][0-9]_*.sql; do
    local ten
    ten="$(basename "$file")"
    printf '==> %s\n' "$ten"
    if ! sqlcmd_trong_container -i "/sql/$ten" > "/tmp/hssk_$ten.log" 2>&1; then
      loi=1
      echo "    LỖI — xem bên dưới:"
      grep -nE 'Msg [0-9]+|Sqlcmd: Error' -A2 "/tmp/hssk_$ten.log" | head -30
    else
      # In các dòng PRINT cuối file để biết script đã chạy tới đâu.
      grep -vE '^\s*$|rows affected' "/tmp/hssk_$ten.log" | tail -2 | sed 's/^/    /'
    fi
  done
  return "$loi"
}

nap_mat_khau
case "${1:-}" in
  start) lenh_start ;;
  run) lenh_run ;;
  file) sqlcmd_trong_container -i "/sql/$(basename "$2")" "${@:3}" ;;
  query) sqlcmd_trong_container -d "$CSDL" -W -s '|' -Q "$2" ;;
  stop) docker stop "$CONTAINER" >/dev/null && echo "Đã dừng $CONTAINER." ;;
  *)
    sed -n '2,9p' "$0" | sed 's/^# \{0,1\}//'
    exit 1
    ;;
esac
