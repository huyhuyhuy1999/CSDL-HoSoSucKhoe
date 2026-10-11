import 'package:flutter/material.dart';

/// Kiểu chữ của ứng dụng — font Be Vietnam Pro (hỗ trợ đầy đủ dấu tiếng Việt).
abstract final class AppTypography {
  static const String fontFamily = 'BeVietnamPro';

  static TextTheme textTheme(Color primary, Color secondary) {
    TextStyle style(
      double size,
      FontWeight weight, {
      double height = 1.35,
      double spacing = 0,
      Color? color,
    }) {
      return TextStyle(
        fontFamily: fontFamily,
        fontSize: size,
        fontWeight: weight,
        height: height,
        letterSpacing: spacing,
        color: color ?? primary,
      );
    }

    return TextTheme(
      displaySmall: style(30, FontWeight.w700, height: 1.2, spacing: -0.4),
      headlineMedium: style(26, FontWeight.w700, height: 1.2, spacing: -0.3),
      headlineSmall: style(22, FontWeight.w700, height: 1.25, spacing: -0.2),
      titleLarge: style(18, FontWeight.w600, height: 1.3),
      titleMedium: style(16, FontWeight.w600, height: 1.3),
      titleSmall: style(14, FontWeight.w600, height: 1.3),
      bodyLarge: style(16, FontWeight.w400, height: 1.5),
      bodyMedium: style(14, FontWeight.w400, height: 1.45),
      bodySmall: style(12.5, FontWeight.w400, height: 1.4, color: secondary),
      labelLarge: style(14, FontWeight.w600, height: 1.2),
      labelMedium: style(12.5, FontWeight.w500, height: 1.2),
      labelSmall: style(11, FontWeight.w500, height: 1.2, color: secondary),
    );
  }

  /// Kiểu chữ cho con số lớn (giá trị chỉ số): chữ số có độ rộng bằng nhau.
  static TextStyle number(double size, Color color) {
    return TextStyle(
      fontFamily: fontFamily,
      fontSize: size,
      fontWeight: FontWeight.w700,
      height: 1.1,
      letterSpacing: -0.5,
      color: color,
      fontFeatures: const [FontFeature.tabularFigures()],
    );
  }
}
