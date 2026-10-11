import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

/// Chế độ giao diện: theo hệ thống, sáng hoặc tối.
@lazySingleton
class ThemeCubit extends Cubit<ThemeMode> {
  ThemeCubit() : super(ThemeMode.system);

  /// Đổi giữa sáng và tối, dựa trên độ sáng đang hiển thị.
  void doiCheDo(Brightness hienTai) {
    emit(hienTai == Brightness.dark ? ThemeMode.light : ThemeMode.dark);
  }
}
