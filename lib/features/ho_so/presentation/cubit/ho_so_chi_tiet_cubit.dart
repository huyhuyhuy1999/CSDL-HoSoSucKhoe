import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/utils/data_refresh_bus.dart';
import '../../../../core/utils/trang_thai_tai.dart';
import '../../../canh_bao/domain/entity/canh_bao.dart';
import '../../../canh_bao/domain/repository/canh_bao_repository.dart';
import '../../../lan_do/domain/entity/lan_do.dart';
import '../../../lan_do/domain/repository/lan_do_repository.dart';
import '../../domain/entity/ho_so_suc_khoe.dart';
import '../../domain/repository/ho_so_repository.dart';

part 'ho_so_chi_tiet_cubit.freezed.dart';

@freezed
abstract class HoSoChiTietState with _$HoSoChiTietState {
  const factory HoSoChiTietState({
    @Default(TrangThaiTai.dangTai) TrangThaiTai trangThai,
    HoSoTongHop? hoSo,

    /// Các lần đo của người này, mới nhất trước.
    @Default([]) List<LanDoDayDu> lanDo,
    @Default([]) List<CanhBaoDayDu> canhBao,
    String? loi,
    @Default(false) bool daXoa,
  }) = _HoSoChiTietState;
}

@injectable
class HoSoChiTietCubit extends Cubit<HoSoChiTietState> {
  HoSoChiTietCubit(
    this._hoSoRepository,
    this._lanDoRepository,
    this._canhBaoRepository,
    DataRefreshBus bus,
  ) : super(const HoSoChiTietState()) {
    _sub = bus.stream.listen((_) {
      final ma = _maNguoiDung;
      if (ma != null && !state.daXoa) tai(ma, imLang: true);
    });
  }

  final HoSoRepository _hoSoRepository;
  final LanDoRepository _lanDoRepository;
  final CanhBaoRepository _canhBaoRepository;
  late final StreamSubscription<void> _sub;
  int? _maNguoiDung;

  Future<void> tai(int maNguoiDung, {bool imLang = false}) async {
    _maNguoiDung = maNguoiDung;
    if (!imLang) emit(state.copyWith(trangThai: TrangThaiTai.dangTai));

    final hoSo = await _hoSoRepository.layChiTiet(maNguoiDung);
    final lanDo = await _lanDoRepository.layLichSu(maNguoiDung: maNguoiDung);
    final canhBao = await _canhBaoRepository.layDanhSach(
      maNguoiDung: maNguoiDung,
    );
    if (isClosed || state.daXoa) return;

    hoSo.fold(
      (failure) => emit(
        state.copyWith(trangThai: TrangThaiTai.loi, loi: failure.message),
      ),
      (hoSo) => emit(
        state.copyWith(
          trangThai: TrangThaiTai.thanhCong,
          hoSo: hoSo,
          lanDo: lanDo.getOrElse(() => const []),
          canhBao: canhBao.getOrElse(() => const []),
          loi: null,
        ),
      ),
    );
  }

  /// Xóa hồ sơ; trả về thông báo lỗi nếu thất bại.
  Future<String?> xoa() async {
    final ma = _maNguoiDung;
    if (ma == null) return null;
    emit(state.copyWith(daXoa: true));
    final ketQua = await _hoSoRepository.xoa(ma);
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
