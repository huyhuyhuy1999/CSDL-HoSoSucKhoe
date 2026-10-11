import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/utils/data_refresh_bus.dart';
import '../../../../core/utils/trang_thai_tai.dart';
import '../../../lan_do/domain/entity/muc_do.dart';
import '../../domain/entity/canh_bao.dart';
import '../../domain/repository/canh_bao_repository.dart';

part 'canh_bao_cubit.freezed.dart';

enum BoLocCanhBao {
  tatCa('Tất cả'),
  chuaXem('Chưa xem'),
  nguyHiem('Nguy hiểm'),
  canChuY('Cần chú ý');

  const BoLocCanhBao(this.nhan);

  final String nhan;
}

@freezed
abstract class CanhBaoState with _$CanhBaoState {
  const factory CanhBaoState({
    @Default(TrangThaiTai.dangTai) TrangThaiTai trangThai,
    @Default([]) List<CanhBaoDayDu> danhSach,
    @Default(BoLocCanhBao.tatCa) BoLocCanhBao boLoc,
    @Default(0) int soChuaXem,
    String? loi,
  }) = _CanhBaoState;
}

@injectable
class CanhBaoCubit extends Cubit<CanhBaoState> {
  CanhBaoCubit(this._repository, DataRefreshBus bus)
    : super(const CanhBaoState()) {
    _sub = bus.stream.listen((_) => tai(imLang: true));
  }

  final CanhBaoRepository _repository;
  late final StreamSubscription<void> _sub;
  int _luot = 0;

  Future<void> tai({bool imLang = false}) async {
    final luot = ++_luot;
    if (!imLang) emit(state.copyWith(trangThai: TrangThaiTai.dangTai));

    final danhSach = await _repository.layDanhSach(
      chiChuaXem: state.boLoc == BoLocCanhBao.chuaXem,
      mucDo: switch (state.boLoc) {
        BoLocCanhBao.nguyHiem => MucDo.nguyHiem,
        BoLocCanhBao.canChuY => MucDo.canChuY,
        _ => null,
      },
    );
    final chuaXem = await _repository.layDanhSach(chiChuaXem: true);
    if (isClosed || luot != _luot) return;

    danhSach.fold(
      (failure) => emit(
        state.copyWith(trangThai: TrangThaiTai.loi, loi: failure.message),
      ),
      (danhSach) => emit(
        state.copyWith(
          trangThai: TrangThaiTai.thanhCong,
          danhSach: danhSach,
          soChuaXem: chuaXem.fold((_) => state.soChuaXem, (ds) => ds.length),
          loi: null,
        ),
      ),
    );
  }

  void chonBoLoc(BoLocCanhBao boLoc) {
    emit(state.copyWith(boLoc: boLoc));
    tai(imLang: true);
  }

  Future<void> danhDauDaXem(String maCanhBao) =>
      _repository.danhDauDaXem(maCanhBao);

  Future<void> danhDauTatCaDaXem() => _repository.danhDauTatCaDaXem();

  @override
  Future<void> close() {
    _sub.cancel();
    return super.close();
  }
}

/// Số cảnh báo chưa xem, dùng cho huy hiệu trên thanh điều hướng.
@injectable
class SoCanhBaoCubit extends Cubit<int> {
  SoCanhBaoCubit(this._repository, DataRefreshBus bus) : super(0) {
    _sub = bus.stream.listen((_) => tai());
  }

  final CanhBaoRepository _repository;
  late final StreamSubscription<void> _sub;

  Future<void> tai() async {
    final ketQua = await _repository.layDanhSach(chiChuaXem: true);
    if (isClosed) return;
    ketQua.fold((_) {}, (danhSach) => emit(danhSach.length));
  }

  @override
  Future<void> close() {
    _sub.cancel();
    return super.close();
  }
}
