#!/usr/bin/env bash
# Build bản phát hành vào thư mục dist/:
#   - HoSoSucKhoe-<phiên bản>-unsigned.ipa  (iOS, chưa ký)
#   - HoSoSucKhoe-<phiên bản>.apk           (Android)
#
# Dùng:  tool/build_release.sh [ios|android]   (bỏ trống = build cả hai)
set -euo pipefail

cd "$(dirname "$0")/.."

nen_tang="${1:-all}"
phien_ban="$(grep '^version:' pubspec.yaml | sed -E 's/^version: *//; s/\+.*$//')"
mkdir -p dist

build_ios() {
  echo "==> iOS: build release (không ký)"
  flutter build ios --release --no-codesign

  # Một file .ipa chỉ là thư mục Payload/ chứa Runner.app được nén zip.
  local tam="build/ios/ipa-unsigned"
  local ipa="dist/HoSoSucKhoe-${phien_ban}-unsigned.ipa"
  rm -rf "$tam" "$ipa"
  mkdir -p "$tam/Payload"
  cp -R build/ios/iphoneos/Runner.app "$tam/Payload/"
  (cd "$tam" && zip -qry "../../../$ipa" Payload)
  echo "    -> $ipa"
}

build_android() {
  echo "==> Android: build APK release"
  flutter build apk --release

  local apk="dist/HoSoSucKhoe-${phien_ban}.apk"
  cp build/app/outputs/flutter-apk/app-release.apk "$apk"
  echo "    -> $apk"
}

case "$nen_tang" in
  ios) build_ios ;;
  android) build_android ;;
  all)
    build_ios
    build_android
    ;;
  *)
    echo "Nền tảng không hợp lệ: $nen_tang (chọn ios, android hoặc bỏ trống)" >&2
    exit 1
    ;;
esac

echo
ls -lh dist
