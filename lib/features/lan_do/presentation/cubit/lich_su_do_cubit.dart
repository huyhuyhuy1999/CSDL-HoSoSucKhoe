import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/utils/data_refresh_bus.dart';
import '../../../../core/utils/dinh_dang.dart';
import '../../../../core/utils/trang_thai_tai.dart';
import '../../../ho_so/domain/entity/nguoi_dung.dart';
import '../../../ho_so/domain/repository/ho_so_repository.dart';
import '../../domain/entity/lan_do.dart';
import '../../domain/repository/lan_do_repository.dart';

part 'lich_su_do_cubit.freezed.dart';

/// Các khoảng thời gian lọc nhanh của lịch sử đo.
enum KhoangThoiGian {
  homNay('Hôm nay'),
  bayNgay('7 ngày'),
  thangNay('Tháng này'),
  tatCa('Tất cả'),
  tuyChon('Tùy chọn');

  const KhoangThoiGian(this.nhan);

  final String nhan;
}

@freezed
abstract class LichSuDoState with _$LichSuDoState {
  const factory LichSuDoState({
    @Default(TrangThaiTai.dangTai) TrangThaiTai trangThai,
    @Default([]) List<LanDoDayDu> danhSach,

    /// Danh sách người dùng cho bộ chọn "người được đo".
    @Default([]) List<NguoiDung> nguoiDung,
    int? maNguoiDung,
    @Default(KhoangThoiGian.bayNgay) KhoangThoiGian khoang,

    /// Chỉ dùng khi [khoang] là [KhoangThoiGian.tuyChon].
    DateTime? tuNgay,
    DateTime? denNgay,
    NguonDuLieu? nguon,
    String? loi,
  }) = _LichSuDoState;

  const LichSuDoState._();

  NguoiDung? get nguoiDangChon {
    for (final nd in nguoiDung) {
      if (nd.maNguoiDung == maNguoiDung) return nd;
    }
    return null;
  }
}

@injectable
class LichSuDoCubit extends Cubit<LichSuDoState> {
  LichSuDoCubit(this._lanDoRepository, this._hoSoRepository, DataRefreshBus bus)
    : super(const LichSuDoState()) {
    _sub = bus.stream.listen((_) => tai(imLang: true));
  }

  final LanDoRepository _lanDoRepository;
  final HoSoRepository _hoSoRepository;
  late final StreamSubscription<void> _sub;
  int _luot = 0;

  Future<void> khoiTao({
    int? maNguoiDung,
    KhoangThoiGian khoang = KhoangThoiGian.bayNgay,
  }) {
    emit(state.copyWith(maNguoiDung: maNguoiDung, khoang: khoang));
    return tai();
  }

  Future<void> tai({bool imLang = false}) async {
    final luot = ++_luot;
    if (!imLang) emit(state.copyWith(trangThai: TrangThaiTai.dangTai));

    final (tuNgay, denNgay) = _khoangNgay();
    final lichSu = await _lanDoRepository.layLichSu(
      maNguoiDung: state.maNguoiDung,
      tuNgay: tuNgay,
      denNgay: denNgay,
      nguon: state.nguon,
    );
    final hoSo = await _hoSoRepository.layDanhSach();
    if (isClosed || luot != _luot) return;

    lichSu.fold(
      (failure) => emit(
        state.copyWith(trangThai: TrangThaiTai.loi, loi: failure.message),
      ),
      (danhSach) => emit(
        state.copyWith(
          trangThai: TrangThaiTai.thanhCong,
          danhSach: danhSach,
          nguoiDung: hoSo.fold(
            (_) => state.nguoiDung,
            (ds) => [for (final hs in ds) hs.nguoiDung],
          ),
          loi: null,
        ),
      ),
    );
  }

  void chonNguoiDung(int? maNguoiDung) {
    emit(state.copyWith(maNguoiDung: maNguoiDung));
    tai(imLang: true);
  }

  void chonKhoang(KhoangThoiGian khoang) {
    emit(state.copyWith(khoang: khoang));
    tai(imLang: true);
  }

  void chonKhoangTuyChon(DateTime tuNgay, DateTime denNgay) {
    emit(
      state.copyWith(
        khoang: KhoangThoiGian.tuyChon,
        tuNgay: tuNgay,
        denNgay: denNgay,
      ),
    );
    tai(imLang: true);
  }

  void chonNguon(NguonDuLieu? nguon) {
    emit(state.copyWith(nguon: nguon));
    tai(imLang: true);
  }

  (DateTime?, DateTime?) _khoangNgay() {
    final homNay = DateTime.now().dauNgay;
    return switch (state.khoang) {
      KhoangThoiGian.tatCa => (null, null),
      KhoangThoiGian.homNay => (homNay, null),
      KhoangThoiGian.bayNgay => (
        homNay.subtract(const Duration(days: 6)),
        null,
      ),
      KhoangThoiGian.thangNay => (DateTime(homNay.year, homNay.month), null),
      KhoangThoiGian.tuyChon => (
        state.tuNgay?.dauNgay,
        state.denNgay?.cuoiNgay,
      ),
    };
  }

  @override
  Future<void> close() {
    _sub.cancel();
    return super.close();
  }
}
