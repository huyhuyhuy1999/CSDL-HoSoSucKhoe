import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/utils/trang_thai_tai.dart';
import '../../domain/entity/thiet_bi.dart';
import '../../domain/repository/thiet_bi_repository.dart';

part 'thiet_bi_cubit.freezed.dart';

@freezed
abstract class ThietBiState with _$ThietBiState {
  const factory ThietBiState({
    @Default(TrangThaiTai.dangTai) TrangThaiTai trangThai,
    @Default([]) List<ThietBiTongHop> danhSach,
    @Default('') String tuKhoa,
    TrangThaiThietBi? trangThaiLoc,
    String? loi,
  }) = _ThietBiState;
}

@injectable
class ThietBiCubit extends Cubit<ThietBiState> {
  ThietBiCubit(this._repository) : super(const ThietBiState());

  final ThietBiRepository _repository;
  int _luot = 0;

  Future<void> tai({bool imLang = false}) async {
    final luot = ++_luot;
    if (!imLang) emit(state.copyWith(trangThai: TrangThaiTai.dangTai));
    final ketQua = await _repository.layDanhSach(
      tuKhoa: state.tuKhoa,
      trangThai: state.trangThaiLoc,
    );
    if (isClosed || luot != _luot) return;
    ketQua.fold(
      (failure) => emit(
        state.copyWith(trangThai: TrangThaiTai.loi, loi: failure.message),
      ),
      (danhSach) => emit(
        state.copyWith(
          trangThai: TrangThaiTai.thanhCong,
          danhSach: danhSach,
          loi: null,
        ),
      ),
    );
  }

  void timKiem(String tuKhoa) {
    emit(state.copyWith(tuKhoa: tuKhoa.trim()));
    tai(imLang: true);
  }

  void chonTrangThai(TrangThaiThietBi? trangThai) {
    emit(state.copyWith(trangThaiLoc: trangThai));
    tai(imLang: true);
  }
}
