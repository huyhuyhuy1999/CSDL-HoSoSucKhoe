import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/utils/data_refresh_bus.dart';
import '../../../../core/utils/trang_thai_tai.dart';
import '../../domain/entity/ho_so_suc_khoe.dart';
import '../../domain/entity/nguoi_dung.dart';
import '../../domain/repository/ho_so_repository.dart';

part 'ho_so_list_cubit.freezed.dart';

@freezed
abstract class HoSoListState with _$HoSoListState {
  const factory HoSoListState({
    @Default(TrangThaiTai.dangTai) TrangThaiTai trangThai,
    @Default([]) List<HoSoTongHop> danhSach,
    @Default('') String tuKhoa,
    GioiTinh? gioiTinh,
    NhomTuoi? nhomTuoi,
    String? loi,
  }) = _HoSoListState;

  const HoSoListState._();

  bool get dangLoc => tuKhoa.isNotEmpty || gioiTinh != null || nhomTuoi != null;
}

@injectable
class HoSoListCubit extends Cubit<HoSoListState> {
  HoSoListCubit(this._repository, DataRefreshBus bus)
    : super(const HoSoListState()) {
    _sub = bus.stream.listen((_) => tai(imLang: true));
  }

  final HoSoRepository _repository;
  late final StreamSubscription<void> _sub;

  /// Số thứ tự của lượt truy vấn, để bỏ qua kết quả về trễ của lượt cũ.
  int _luot = 0;

  Future<void> tai({bool imLang = false}) async {
    final luot = ++_luot;
    if (!imLang) emit(state.copyWith(trangThai: TrangThaiTai.dangTai));
    final ketQua = await _repository.layDanhSach(
      tuKhoa: state.tuKhoa,
      gioiTinh: state.gioiTinh,
      nhomTuoi: state.nhomTuoi,
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

  void chonGioiTinh(GioiTinh? gioiTinh) {
    emit(state.copyWith(gioiTinh: gioiTinh));
    tai(imLang: true);
  }

  void chonNhomTuoi(NhomTuoi? nhomTuoi) {
    emit(state.copyWith(nhomTuoi: nhomTuoi));
    tai(imLang: true);
  }

  @override
  Future<void> close() {
    _sub.cancel();
    return super.close();
  }
}
