import 'package:equatable/equatable.dart';

enum TrangThaiThietBi {
  hoatDong('Hoạt động'),
  baoTri('Bảo trì'),
  ngungSuDung('Ngừng sử dụng');

  const TrangThaiThietBi(this.nhan);

  final String nhan;
}

enum LoaiThietBi {
  daChiSo('Thiết bị đa chỉ số'),
  spo2('Máy đo SpO2 / nhịp tim'),
  nhietKe('Nhiệt kế'),
  huyetAp('Máy đo huyết áp');

  const LoaiThietBi(this.nhan);

  final String nhan;
}

/// Bảng THIET_BI (dữ liệu mô phỏng — không kết nối phần cứng thật).
class ThietBi extends Equatable {
  const ThietBi({
    required this.maThietBi,
    required this.tenThietBi,
    required this.loaiThietBi,
    required this.maDinhDanh,
    required this.trangThai,
    this.moTa = '',
  });

  final String maThietBi;
  final String tenThietBi;
  final LoaiThietBi loaiThietBi;

  /// Mã định danh phần cứng (địa chỉ MAC hoặc số serial).
  final String maDinhDanh;
  final TrangThaiThietBi trangThai;
  final String moTa;

  @override
  List<Object?> get props => [
    maThietBi,
    tenThietBi,
    loaiThietBi,
    maDinhDanh,
    trangThai,
    moTa,
  ];
}

/// Thiết bị kèm số liệu sử dụng.
class ThietBiTongHop extends Equatable {
  const ThietBiTongHop({
    required this.thietBi,
    required this.soLanDo,
    this.lanDoCuoi,
  });

  final ThietBi thietBi;
  final int soLanDo;
  final DateTime? lanDoCuoi;

  @override
  List<Object?> get props => [thietBi, soLanDo, lanDoCuoi];
}
