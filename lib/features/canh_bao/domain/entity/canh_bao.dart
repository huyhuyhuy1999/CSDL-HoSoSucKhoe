import 'package:equatable/equatable.dart';

import '../../../ho_so/domain/entity/nguoi_dung.dart';
import '../../../lan_do/domain/entity/loai_chi_so.dart';
import '../../../lan_do/domain/entity/muc_do.dart';

/// Bảng CANH_BAO: sinh ra khi một chỉ số của lần đo vượt ngưỡng.
class CanhBao extends Equatable {
  const CanhBao({
    required this.maCanhBao,
    required this.maLanDo,
    required this.maLoaiChiSo,
    required this.mucDo,
    required this.noiDung,
    required this.thoiGianTao,
    this.daXem = false,
  });

  final int maCanhBao;
  final int maLanDo;
  final int maLoaiChiSo;
  final MucDo mucDo;
  final String noiDung;
  final DateTime thoiGianTao;
  final bool daXem;

  CanhBao copyWith({bool? daXem}) {
    return CanhBao(
      maCanhBao: maCanhBao,
      maLanDo: maLanDo,
      maLoaiChiSo: maLoaiChiSo,
      mucDo: mucDo,
      noiDung: noiDung,
      thoiGianTao: thoiGianTao,
      daXem: daXem ?? this.daXem,
    );
  }

  @override
  List<Object?> get props => [
    maCanhBao,
    maLanDo,
    maLoaiChiSo,
    mucDo,
    noiDung,
    thoiGianTao,
    daXem,
  ];
}

/// Cảnh báo đã ghép với người được đo, loại chỉ số và giá trị đo.
class CanhBaoDayDu extends Equatable {
  const CanhBaoDayDu({
    required this.canhBao,
    required this.nguoiDung,
    required this.loaiChiSo,
    required this.giaTri,
  });

  final CanhBao canhBao;
  final NguoiDung nguoiDung;
  final LoaiChiSo loaiChiSo;
  final double giaTri;

  /// Ví dụ: "Nhịp tim cao" hoặc "SpO2 thấp".
  String get tieuDe {
    final huong = loaiChiSo.caoHonBinhThuong(giaTri) ? 'cao' : 'thấp';
    return '${loaiChiSo.tenChiSo} $huong';
  }

  /// Ví dụ: "128 bpm".
  String get giaTriHienThi =>
      '${loaiChiSo.dinhDang(giaTri)} ${loaiChiSo.donViDo}';

  @override
  List<Object?> get props => [canhBao, nguoiDung, loaiChiSo, giaTri];
}
