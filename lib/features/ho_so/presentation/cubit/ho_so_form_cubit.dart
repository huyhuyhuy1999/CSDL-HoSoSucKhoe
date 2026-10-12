import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/utils/trang_thai_tai.dart';
import '../../domain/entity/ho_so_suc_khoe.dart';
import '../../domain/repository/ho_so_repository.dart';

part 'ho_so_form_cubit.freezed.dart';

@freezed
abstract class HoSoFormState with _$HoSoFormState {
  const factory HoSoFormState({
    @Default(TrangThaiTai.dangTai) TrangThaiTai trangThai,

    /// Hồ sơ đang sửa; `null` khi thêm mới.
    HoSoTongHop? banDau,
    @Default(false) bool dangLuu,
    String? loi,

    /// Mã người dùng vừa lưu thành công.
    int? maDaLuu,
  }) = _HoSoFormState;
}

@injectable
class HoSoFormCubit extends Cubit<HoSoFormState> {
  HoSoFormCubit(this._repository) : super(const HoSoFormState());

  final HoSoRepository _repository;
  int? _maNguoiDung;

  Future<void> khoiTao(int? maNguoiDung) async {
    _maNguoiDung = maNguoiDung;
    if (maNguoiDung == null) {
      emit(state.copyWith(trangThai: TrangThaiTai.thanhCong));
      return;
    }
    final ketQua = await _repository.layChiTiet(maNguoiDung);
    if (isClosed) return;
    ketQua.fold(
      (failure) => emit(
        state.copyWith(trangThai: TrangThaiTai.loi, loi: failure.message),
      ),
      (hoSo) =>
          emit(state.copyWith(trangThai: TrangThaiTai.thanhCong, banDau: hoSo)),
    );
  }

  Future<void> luu(ThongTinHoSo thongTin) async {
    if (state.dangLuu) return;
    emit(state.copyWith(dangLuu: true, loi: null));
    final ketQua = await _repository.luu(thongTin, maNguoiDung: _maNguoiDung);
    if (isClosed) return;
    ketQua.fold(
      (failure) => emit(state.copyWith(dangLuu: false, loi: failure.message)),
      (hoSo) => emit(
        state.copyWith(dangLuu: false, maDaLuu: hoSo.nguoiDung.maNguoiDung),
      ),
    );
  }
}
