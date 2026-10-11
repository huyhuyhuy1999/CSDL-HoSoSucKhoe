import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/utils/trang_thai_tai.dart';
import '../../../ho_so/domain/entity/nguoi_dung.dart';
import '../../../ho_so/domain/repository/ho_so_repository.dart';
import '../../../thiet_bi/domain/entity/thiet_bi.dart';
import '../../../thiet_bi/domain/repository/thiet_bi_repository.dart';
import '../../domain/entity/lan_do.dart';
import '../../domain/entity/loai_chi_so.dart';
import '../../domain/repository/lan_do_repository.dart';

part 'lan_do_form_cubit.freezed.dart';

@freezed
abstract class LanDoFormState with _$LanDoFormState {
  const factory LanDoFormState({
    @Default(TrangThaiTai.dangTai) TrangThaiTai trangThai,
    @Default([]) List<NguoiDung> nguoiDung,

    /// Chỉ gồm thiết bị đang hoạt động.
    @Default([]) List<ThietBi> thietBi,
    @Default([]) List<LoaiChiSo> loaiChiSo,
    @Default(false) bool dangLuu,
    String? loi,

    /// Mã lần đo vừa lưu thành công.
    String? maDaLuu,
  }) = _LanDoFormState;
}

@injectable
class LanDoFormCubit extends Cubit<LanDoFormState> {
  LanDoFormCubit(
    this._lanDoRepository,
    this._hoSoRepository,
    this._thietBiRepository,
  ) : super(const LanDoFormState());

  final LanDoRepository _lanDoRepository;
  final HoSoRepository _hoSoRepository;
  final ThietBiRepository _thietBiRepository;

  Future<void> khoiTao() async {
    final hoSo = await _hoSoRepository.layDanhSach();
    final thietBi = await _thietBiRepository.layDanhSach(
      trangThai: TrangThaiThietBi.hoatDong,
    );
    final loaiChiSo = await _lanDoRepository.layLoaiChiSo();
    if (isClosed) return;

    final loi =
        hoSo.fold((f) => f.message, (_) => null) ??
        loaiChiSo.fold((f) => f.message, (_) => null);
    if (loi != null) {
      emit(state.copyWith(trangThai: TrangThaiTai.loi, loi: loi));
      return;
    }
    emit(
      state.copyWith(
        trangThai: TrangThaiTai.thanhCong,
        nguoiDung: [
          for (final hs in hoSo.getOrElse(() => const [])) hs.nguoiDung,
        ],
        thietBi: [
          for (final tb in thietBi.getOrElse(() => const [])) tb.thietBi,
        ],
        loaiChiSo: loaiChiSo.getOrElse(() => const []),
      ),
    );
  }

  Future<void> luu({
    required String maNguoiDung,
    required DateTime thoiGianDo,
    required NguonDuLieu nguon,
    required Map<MaChiSo, double> giaTri,
    String? maThietBi,
    String ghiChu = '',
  }) async {
    if (state.dangLuu) return;
    emit(state.copyWith(dangLuu: true, loi: null));
    final ketQua = await _lanDoRepository.them(
      maNguoiDung: maNguoiDung,
      thoiGianDo: thoiGianDo,
      nguon: nguon,
      maThietBi: maThietBi,
      giaTri: giaTri,
      ghiChu: ghiChu,
    );
    if (isClosed) return;
    ketQua.fold(
      (failure) => emit(state.copyWith(dangLuu: false, loi: failure.message)),
      (lanDo) =>
          emit(state.copyWith(dangLuu: false, maDaLuu: lanDo.lanDo.maLanDo)),
    );
  }
}
