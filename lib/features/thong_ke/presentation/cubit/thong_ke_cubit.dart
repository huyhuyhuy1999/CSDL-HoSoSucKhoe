import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/utils/data_refresh_bus.dart';
import '../../../../core/utils/dinh_dang.dart';
import '../../../../core/utils/trang_thai_tai.dart';
import '../../../ho_so/domain/entity/nguoi_dung.dart';
import '../../../ho_so/domain/repository/ho_so_repository.dart';
import '../../domain/entity/thong_ke.dart';
import '../../domain/repository/thong_ke_repository.dart';

part 'thong_ke_cubit.freezed.dart';

@freezed
abstract class ThongKeState with _$ThongKeState {
  const factory ThongKeState({
    @Default(TrangThaiTai.dangTai) TrangThaiTai trangThai,
    ThongKeTongHop? duLieu,

    /// Độ dài khoảng thống kê tính đến hôm nay: 7, 14 hoặc 30 ngày.
    @Default(7) int soNgay,
    String? maNguoiDung,
    @Default([]) List<NguoiDung> nguoiDung,
    String? loi,
  }) = _ThongKeState;

  const ThongKeState._();

  NguoiDung? get nguoiDangChon {
    for (final nd in nguoiDung) {
      if (nd.maNguoiDung == maNguoiDung) return nd;
    }
    return null;
  }
}

@injectable
class ThongKeCubit extends Cubit<ThongKeState> {
  ThongKeCubit(
    this._thongKeRepository,
    this._hoSoRepository,
    DataRefreshBus bus,
  ) : super(const ThongKeState()) {
    _sub = bus.stream.listen((_) => tai(imLang: true));
  }

  final ThongKeRepository _thongKeRepository;
  final HoSoRepository _hoSoRepository;
  late final StreamSubscription<void> _sub;
  int _luot = 0;

  Future<void> tai({bool imLang = false}) async {
    final luot = ++_luot;
    if (!imLang) emit(state.copyWith(trangThai: TrangThaiTai.dangTai));

    final homNay = DateTime.now().dauNgay;
    final thongKe = await _thongKeRepository.layThongKe(
      tuNgay: homNay.subtract(Duration(days: state.soNgay - 1)),
      denNgay: homNay,
      maNguoiDung: state.maNguoiDung,
    );
    final hoSo = await _hoSoRepository.layDanhSach();
    if (isClosed || luot != _luot) return;

    thongKe.fold(
      (failure) => emit(
        state.copyWith(trangThai: TrangThaiTai.loi, loi: failure.message),
      ),
      (duLieu) => emit(
        state.copyWith(
          trangThai: TrangThaiTai.thanhCong,
          duLieu: duLieu,
          nguoiDung: hoSo.fold(
            (_) => state.nguoiDung,
            (ds) => [for (final hs in ds) hs.nguoiDung],
          ),
          loi: null,
        ),
      ),
    );
  }

  void chonSoNgay(int soNgay) {
    emit(state.copyWith(soNgay: soNgay));
    tai(imLang: true);
  }

  void chonNguoiDung(String? maNguoiDung) {
    emit(state.copyWith(maNguoiDung: maNguoiDung));
    tai(imLang: true);
  }

  @override
  Future<void> close() {
    _sub.cancel();
    return super.close();
  }
}
