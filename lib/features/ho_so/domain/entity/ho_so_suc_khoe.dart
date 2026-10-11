import 'package:equatable/equatable.dart';

import '../../../lan_do/domain/entity/lan_do.dart';
import '../../../lan_do/domain/entity/muc_do.dart';
import 'nguoi_dung.dart';

/// Danh sách nhóm máu hợp lệ.
const List<String> danhSachNhomMau = [
  'A+',
  'A-',
  'B+',
  'B-',
  'AB+',
  'AB-',
  'O+',
  'O-',
];

/// Bảng HO_SO_SUC_KHOE.
class HoSoSucKhoe extends Equatable {
  const HoSoSucKhoe({
    required this.maHoSo,
    required this.maNguoiDung,
    required this.chieuCao,
    required this.canNang,
    required this.nhomMau,
    required this.ngayCapNhat,
    this.tienSuBenh = '',
    this.diUng = '',
  });

  final String maHoSo;
  final String maNguoiDung;

  /// Chiều cao (cm).
  final double chieuCao;

  /// Cân nặng (kg).
  final double canNang;
  final String nhomMau;
  final String tienSuBenh;
  final String diUng;
  final DateTime ngayCapNhat;

  double get bmi {
    final met = chieuCao / 100;
    if (met <= 0) return 0;
    return canNang / (met * met);
  }

  /// Phân loại BMI theo thang dành cho người châu Á.
  String get phanLoaiBmi {
    final v = bmi;
    if (v < 18.5) return 'Thiếu cân';
    if (v < 23) return 'Bình thường';
    if (v < 25) return 'Thừa cân';
    return 'Béo phì';
  }

  @override
  List<Object?> get props => [
    maHoSo,
    maNguoiDung,
    chieuCao,
    canNang,
    nhomMau,
    tienSuBenh,
    diUng,
    ngayCapNhat,
  ];
}

/// Hồ sơ đã ghép với người dùng và số liệu tổng hợp (tương đương một VIEW).
class HoSoTongHop extends Equatable {
  const HoSoTongHop({
    required this.nguoiDung,
    required this.hoSo,
    required this.soLanDo,
    required this.soCanhBaoChuaXem,
    this.lanDoGanNhat,
  });

  final NguoiDung nguoiDung;
  final HoSoSucKhoe hoSo;
  final LanDoDayDu? lanDoGanNhat;
  final int soLanDo;
  final int soCanhBaoChuaXem;

  /// Mức độ của lần đo gần nhất; `null` nếu chưa đo lần nào.
  MucDo? get trangThai => lanDoGanNhat?.mucDo;

  @override
  List<Object?> get props => [
    nguoiDung,
    hoSo,
    lanDoGanNhat,
    soLanDo,
    soCanhBaoChuaXem,
  ];
}
