import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/utils/data_refresh_bus.dart';
import '../../../../core/utils/trang_thai_tai.dart';
import '../../../canh_bao/domain/entity/canh_bao.dart';
import '../../../canh_bao/domain/repository/canh_bao_repository.dart';
import '../../domain/entity/lan_do.dart';
import '../../domain/repository/lan_do_repository.dart';

part 'lan_do_chi_tiet_cubit.freezed.dart';

@freezed
abstract class LanDoChiTietState with _$LanDoChiTietState {
  const factory LanDoChiTietState({
    @Default(TrangThaiTai.dangTai) TrangThaiTai trangThai,
    LanDoDayDu? lanDo,
    @Default([]) List<CanhBaoDayDu> canhBao,
    String? loi,
    @Default(false) bool daXoa,
  }) = _LanDoChiTietState;
}

@injectable
class LanDoChiTietCubit extends Cubit<LanDoChiTietState> {
  LanDoChiTietCubit(
    this._lanDoRepository,
    this._canhBaoRepository,
    DataRefreshBus bus,
  ) : super(const LanDoChiTietState()) {
    _sub = bus.stream.listen((_) {
      if (_maLanDo != null && !state.daXoa) tai(_maLanDo!, imLang: true);
    });
  }

  final LanDoRepository _lanDoRepository;
  final CanhBaoRepository _canhBaoRepository;
  late final StreamSubscription<void> _sub;
  String? _maLanDo;

  Future<void> tai(String maLanDo, {bool imLang = false}) async {
    _maLanDo = maLanDo;
    if (!imLang) emit(state.copyWith(trangThai: TrangThaiTai.dangTai));

    final lanDo = await _lanDoRepository.layChiTiet(maLanDo);
    final canhBao = await _canhBaoRepository.layDanhSach(maLanDo: maLanDo);
    if (isClosed || state.daXoa) return;

    lanDo.fold(
      (failure) => emit(
        state.copyWith(trangThai: TrangThaiTai.loi, loi: failure.message),
      ),
      (lanDo) => emit(
        state.copyWith(
          trangThai: TrangThaiTai.thanhCong,
          lanDo: lanDo,
          canhBao: canhBao.getOrElse(() => const []),
          loi: null,
        ),
      ),
    );

    // Mở chi tiết lần đo coi như đã xem các cảnh báo của nó.
    final chuaXem = state.canhBao.where((cb) => !cb.canhBao.daXem).toList();
    for (final cb in chuaXem) {
      await _canhBaoRepository.danhDauDaXem(cb.canhBao.maCanhBao);
    }
  }

  /// Xóa lần đo; trả về thông báo lỗi nếu thất bại.
  Future<String?> xoa() async {
    final ma = _maLanDo;
    if (ma == null) return null;
    emit(state.copyWith(daXoa: true));
    final ketQua = await _lanDoRepository.xoa(ma);
    if (isClosed) return null;
    return ketQua.fold((failure) {
      emit(state.copyWith(daXoa: false));
      return failure.message;
    }, (_) => null);
  }

  @override
  Future<void> close() {
    _sub.cancel();
    return super.close();
  }
}
