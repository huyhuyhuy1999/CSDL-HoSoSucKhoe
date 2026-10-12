import 'package:equatable/equatable.dart';

import '../../../ho_so/domain/entity/nguoi_dung.dart';
import '../../../thiet_bi/domain/entity/thiet_bi.dart';
import 'loai_chi_so.dart';
import 'muc_do.dart';

/// Nguồn sinh ra dữ liệu của một lần đo.
enum NguonDuLieu {
  thietBi('Thiết bị đo', 'Thiết bị'),
  nhapThuCong('Nhập thủ công', 'Thủ công');

  const NguonDuLieu(this.nhan, this.giaTriCsdl);

  /// Nhãn hiển thị trên giao diện.
  final String nhan;

  /// Giá trị cột LAN_DO.NguonDuLieu trong cơ sở dữ liệu.
  final String giaTriCsdl;

  static NguonDuLieu tuCsdl(String giaTri) =>
      values.firstWhere((nguon) => nguon.giaTriCsdl == giaTri);
}

/// Bảng LAN_DO.
class LanDo extends Equatable {
  const LanDo({
    required this.maLanDo,
    required this.maNguoiDung,
    required this.thoiGianDo,
    required this.nguon,
    this.maThietBi,
    this.ghiChu = '',
  });

  final int maLanDo;
  final int maNguoiDung;
  final DateTime thoiGianDo;
  final NguonDuLieu nguon;

  /// `null` khi dữ liệu được nhập thủ công.
  final int? maThietBi;
  final String ghiChu;

  @override
  List<Object?> get props => [
    maLanDo,
    maNguoiDung,
    thoiGianDo,
    nguon,
    maThietBi,
    ghiChu,
  ];
}

/// Bảng CHI_TIET_LAN_DO: một dòng cho mỗi chỉ số của một lần đo.
class ChiTietLanDo extends Equatable {
  const ChiTietLanDo({
    required this.maLanDo,
    required this.maLoaiChiSo,
    required this.giaTri,
  });

  final int maLanDo;
  final int maLoaiChiSo;
  final double giaTri;

  @override
  List<Object?> get props => [maLanDo, maLoaiChiSo, giaTri];
}

/// Một giá trị đo đã ghép với loại chỉ số và được đánh giá mức độ.
class KetQuaChiSo extends Equatable {
  const KetQuaChiSo({required this.loai, required this.giaTri});

  final LoaiChiSo loai;
  final double giaTri;

  MucDo get mucDo => loai.danhGia(giaTri);

  String get giaTriHienThi => loai.dinhDang(giaTri);

  @override
  List<Object?> get props => [loai, giaTri];
}

/// Lần đo đã ghép đủ người đo, thiết bị và các chỉ số (tương đương JOIN
/// LAN_DO – NGUOI_DUNG – THIET_BI – CHI_TIET_LAN_DO – LOAI_CHI_SO).
class LanDoDayDu extends Equatable {
  const LanDoDayDu({
    required this.lanDo,
    required this.nguoiDung,
    required this.ketQua,
    this.thietBi,
  });

  final LanDo lanDo;
  final NguoiDung nguoiDung;
  final ThietBi? thietBi;
  final List<KetQuaChiSo> ketQua;

  KetQuaChiSo? ketQuaCua(MaChiSo ma) {
    for (final kq in ketQua) {
      if (kq.loai.ma == ma) return kq;
    }
    return null;
  }

  /// Mức độ nặng nhất trong các chỉ số của lần đo.
  MucDo get mucDo {
    var mucDo = MucDo.binhThuong;
    for (final kq in ketQua) {
      mucDo = mucDo.nangHon(kq.mucDo);
    }
    return mucDo;
  }

  /// Tên nguồn hiển thị: tên thiết bị hoặc "Nhập thủ công".
  String get tenNguon => thietBi?.tenThietBi ?? lanDo.nguon.nhan;

  @override
  List<Object?> get props => [lanDo, nguoiDung, thietBi, ketQua];
}
