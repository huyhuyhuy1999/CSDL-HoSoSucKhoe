import 'package:equatable/equatable.dart';

import '../../../../core/utils/dinh_dang.dart';
import 'muc_do.dart';

/// Năm chỉ số sức khỏe mà hệ thống theo dõi. [kyHieu] là giá trị cột
/// LOAI_CHI_SO.KyHieu trong cơ sở dữ liệu.
enum MaChiSo {
  nhietDo('NHIET_DO'),
  nhipTim('NHIP_TIM'),
  spo2('SPO2'),
  huyetApTamThu('HA_TAM_THU'),
  huyetApTamTruong('HA_TAM_TRUONG');

  const MaChiSo(this.kyHieu);

  final String kyHieu;

  /// `null` nếu cơ sở dữ liệu có loại chỉ số mà ứng dụng chưa hỗ trợ hiển thị.
  static MaChiSo? tuKyHieu(String kyHieu) {
    for (final ma in values) {
      if (ma.kyHieu == kyHieu) return ma;
    }
    return null;
  }
}

/// Bảng LOAI_CHI_SO: danh mục chỉ số kèm ngưỡng đánh giá (quy tắc cảnh báo).
class LoaiChiSo extends Equatable {
  const LoaiChiSo({
    required this.maLoaiChiSo,
    required this.ma,
    required this.tenChiSo,
    required this.donViDo,
    required this.binhThuongMin,
    required this.binhThuongMax,
    required this.canChuYMin,
    required this.canChuYMax,
    required this.nhapMin,
    required this.nhapMax,
    this.soThapPhan = 0,
  });

  final int maLoaiChiSo;
  final MaChiSo ma;
  final String tenChiSo;
  final String donViDo;

  /// Khoảng giá trị bình thường.
  final double binhThuongMin;
  final double binhThuongMax;

  /// Khoảng "cần chú ý" (bao ngoài khoảng bình thường); ngoài khoảng này là
  /// "nguy hiểm".
  final double canChuYMin;
  final double canChuYMax;

  /// Khoảng giá trị hợp lệ khi nhập liệu.
  final double nhapMin;
  final double nhapMax;

  final int soThapPhan;

  MucDo danhGia(double giaTri) {
    if (giaTri >= binhThuongMin && giaTri <= binhThuongMax) {
      return MucDo.binhThuong;
    }
    if (giaTri >= canChuYMin && giaTri <= canChuYMax) return MucDo.canChuY;
    return MucDo.nguyHiem;
  }

  bool caoHonBinhThuong(double giaTri) => giaTri > binhThuongMax;

  String dinhDang(double giaTri) => DinhDang.so(giaTri, thapPhan: soThapPhan);

  /// Ví dụ: "60 – 100 bpm".
  String get khoangBinhThuong =>
      '${dinhDang(binhThuongMin)} – ${dinhDang(binhThuongMax)} $donViDo';

  @override
  List<Object?> get props => [maLoaiChiSo, ma, tenChiSo, donViDo];
}
