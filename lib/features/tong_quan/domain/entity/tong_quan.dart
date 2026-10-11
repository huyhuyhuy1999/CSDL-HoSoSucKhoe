import 'package:equatable/equatable.dart';

import '../../../canh_bao/domain/entity/canh_bao.dart';
import '../../../lan_do/domain/entity/lan_do.dart';
import '../../../lan_do/domain/entity/loai_chi_so.dart';
import '../../../thong_ke/domain/entity/thong_ke.dart';

/// Xu hướng 7 ngày gần nhất của một chỉ số.
class XuHuongChiSo extends Equatable {
  const XuHuongChiSo({required this.loai, required this.diem, this.trungBinh});

  final LoaiChiSo loai;
  final List<DiemDuLieu> diem;
  final double? trungBinh;

  @override
  List<Object?> get props => [loai, diem, trungBinh];
}

/// Số liệu của màn hình Tổng quan.
class TongQuan extends Equatable {
  const TongQuan({
    required this.soHoSo,
    required this.tongLanDo,
    required this.lanDoHomNay,
    required this.canhBaoChuaXem,
    required this.canhBaoHomNay,
    required this.thietBiHoatDong,
    required this.tongThietBi,
    required this.canhBaoGanDay,
    required this.lanDoGanDay,
    required this.xuHuong,
  });

  final int soHoSo;
  final int tongLanDo;
  final int lanDoHomNay;
  final int canhBaoChuaXem;
  final int canhBaoHomNay;
  final int thietBiHoatDong;
  final int tongThietBi;
  final List<CanhBaoDayDu> canhBaoGanDay;
  final List<LanDoDayDu> lanDoGanDay;
  final Map<MaChiSo, XuHuongChiSo> xuHuong;

  @override
  List<Object?> get props => [
    soHoSo,
    tongLanDo,
    lanDoHomNay,
    canhBaoChuaXem,
    canhBaoHomNay,
    thietBiHoatDong,
    tongThietBi,
    canhBaoGanDay,
    lanDoGanDay,
    xuHuong,
  ];
}
