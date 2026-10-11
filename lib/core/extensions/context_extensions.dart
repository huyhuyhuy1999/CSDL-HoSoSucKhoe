import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

extension ContextX on BuildContext {
  ThemeData get theme => Theme.of(this);

  TextTheme get text => Theme.of(this).textTheme;

  /// Bảng màu ngữ nghĩa theo theme hiện tại.
  AppPalette get palette => Theme.of(this).extension<AppPalette>()!;

  bool get isDark => Theme.of(this).brightness == Brightness.dark;

  void showSnack(String message) {
    ScaffoldMessenger.of(this)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}
