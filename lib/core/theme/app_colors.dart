import 'package:flutter/material.dart';

/// Bảng màu ngữ nghĩa của ứng dụng, có hai biến thể sáng / tối.
///
/// Widget không dùng mã màu trực tiếp mà lấy qua `context.palette`.
@immutable
class AppPalette extends ThemeExtension<AppPalette> {
  const AppPalette({
    required this.background,
    required this.surface,
    required this.surfaceMuted,
    required this.border,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.primary,
    required this.primarySoft,
    required this.onPrimary,
    required this.success,
    required this.successSoft,
    required this.warning,
    required this.warningSoft,
    required this.danger,
    required this.dangerSoft,
    required this.info,
    required this.infoSoft,
    required this.nhietDo,
    required this.nhietDoSoft,
    required this.nhipTim,
    required this.nhipTimSoft,
    required this.spo2,
    required this.spo2Soft,
    required this.huyetAp,
    required this.huyetApSoft,
    required this.heroGradient,
    required this.cardShadow,
  });

  // Nền và bề mặt
  final Color background;
  final Color surface;
  final Color surfaceMuted;
  final Color border;

  // Chữ
  final Color textPrimary;
  final Color textSecondary;
  final Color textTertiary;

  // Màu thương hiệu
  final Color primary;
  final Color primarySoft;
  final Color onPrimary;

  // Trạng thái: bình thường / cần chú ý / nguy hiểm / thông tin
  final Color success;
  final Color successSoft;
  final Color warning;
  final Color warningSoft;
  final Color danger;
  final Color dangerSoft;
  final Color info;
  final Color infoSoft;

  // Màu riêng của từng chỉ số sức khỏe
  final Color nhietDo;
  final Color nhietDoSoft;
  final Color nhipTim;
  final Color nhipTimSoft;
  final Color spo2;
  final Color spo2Soft;
  final Color huyetAp;
  final Color huyetApSoft;

  final List<Color> heroGradient;
  final List<BoxShadow> cardShadow;

  static const light = AppPalette(
    background: Color(0xFFF4F7F9),
    surface: Color(0xFFFFFFFF),
    surfaceMuted: Color(0xFFEEF3F6),
    border: Color(0xFFE5EBF0),
    textPrimary: Color(0xFF0F172A),
    textSecondary: Color(0xFF5B6B7F),
    textTertiary: Color(0xFF94A3B8),
    primary: Color(0xFF0D9488),
    primarySoft: Color(0xFFD9F5F0),
    onPrimary: Color(0xFFFFFFFF),
    success: Color(0xFF16A34A),
    successSoft: Color(0xFFDFF7E7),
    warning: Color(0xFFD97706),
    warningSoft: Color(0xFFFDF0CF),
    danger: Color(0xFFDC2626),
    dangerSoft: Color(0xFFFDE3E3),
    info: Color(0xFF2563EB),
    infoSoft: Color(0xFFDFEAFE),
    nhietDo: Color(0xFFF97316),
    nhietDoSoft: Color(0xFFFFEBD9),
    nhipTim: Color(0xFFE11D48),
    nhipTimSoft: Color(0xFFFFE2E8),
    spo2: Color(0xFF0EA5E9),
    spo2Soft: Color(0xFFDDF2FD),
    huyetAp: Color(0xFF7C3AED),
    huyetApSoft: Color(0xFFECE5FD),
    heroGradient: [Color(0xFF0F766E), Color(0xFF14B8A6)],
    cardShadow: [
      BoxShadow(color: Color(0x0A0F172A), blurRadius: 18, offset: Offset(0, 6)),
    ],
  );

  static const dark = AppPalette(
    background: Color(0xFF0B1220),
    surface: Color(0xFF131C2B),
    surfaceMuted: Color(0xFF1B2637),
    border: Color(0xFF243044),
    textPrimary: Color(0xFFF1F5F9),
    textSecondary: Color(0xFF9FB0C4),
    textTertiary: Color(0xFF64748B),
    primary: Color(0xFF2DD4BF),
    primarySoft: Color(0xFF123B3A),
    onPrimary: Color(0xFF042F2E),
    success: Color(0xFF4ADE80),
    successSoft: Color(0xFF133422),
    warning: Color(0xFFFBBF24),
    warningSoft: Color(0xFF3A2C10),
    danger: Color(0xFFF87171),
    dangerSoft: Color(0xFF3F1A1D),
    info: Color(0xFF60A5FA),
    infoSoft: Color(0xFF16284A),
    nhietDo: Color(0xFFFB923C),
    nhietDoSoft: Color(0xFF3B2414),
    nhipTim: Color(0xFFFB7185),
    nhipTimSoft: Color(0xFF3F1722),
    spo2: Color(0xFF38BDF8),
    spo2Soft: Color(0xFF0F2D40),
    huyetAp: Color(0xFFA78BFA),
    huyetApSoft: Color(0xFF261E45),
    heroGradient: [Color(0xFF0F5F59), Color(0xFF0D9488)],
    cardShadow: [],
  );

  @override
  AppPalette copyWith() => this;

  @override
  AppPalette lerp(ThemeExtension<AppPalette>? other, double t) {
    if (other is! AppPalette) return this;
    return t < 0.5 ? this : other;
  }
}
