import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/utils/data_refresh_bus.dart';
import '../../../../core/utils/trang_thai_tai.dart';
import '../../domain/entity/tong_quan.dart';
import '../../domain/repository/tong_quan_repository.dart';

part 'tong_quan_cubit.freezed.dart';

@freezed
abstract class TongQuanState with _$TongQuanState {
  const factory TongQuanState({
    @Default(TrangThaiTai.dangTai) TrangThaiTai trangThai,
    TongQuan? duLieu,
    String? loi,
  }) = _TongQuanState;
}

@injectable
class TongQuanCubit extends Cubit<TongQuanState> {
  TongQuanCubit(this._repository, DataRefreshBus bus)
    : super(const TongQuanState()) {
    _sub = bus.stream.listen((_) => tai(imLang: true));
  }

  final TongQuanRepository _repository;
  late final StreamSubscription<void> _sub;

  /// [imLang]: tải lại ngầm, giữ nguyên nội dung đang hiển thị.
  Future<void> tai({bool imLang = false}) async {
    if (!imLang) emit(state.copyWith(trangThai: TrangThaiTai.dangTai));
    final ketQua = await _repository.layTongQuan();
    if (isClosed) return;
    ketQua.fold(
      (failure) => emit(
        state.copyWith(trangThai: TrangThaiTai.loi, loi: failure.message),
      ),
      (duLieu) => emit(
        state.copyWith(
          trangThai: TrangThaiTai.thanhCong,
          duLieu: duLieu,
          loi: null,
        ),
      ),
    );
  }

  @override
  Future<void> close() {
    _sub.cancel();
    return super.close();
  }
}
