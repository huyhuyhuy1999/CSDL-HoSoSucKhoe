import 'package:equatable/equatable.dart';

import '../../../ho_so/domain/entity/nguoi_dung.dart';
import '../../../lan_do/domain/entity/loai_chi_so.dart';
import '../../../lan_do/domain/entity/muc_do.dart';

/// Một điểm trên biểu đồ: giá trị (trung bình) của một ngày.
class DiemDuLieu extends Equatable {
  const DiemDuLieu({required this.ngay, required this.giaTri});

  final DateTime ngay;
  final double giaTri;

  @override
  List<Object?> get props => [ngay, giaTri];
}

/// Số lần đo trong một ngày (COUNT … GROUP BY ngày).
class SoLanDoTheoNgay extends Equatable {
  const SoLanDoTheoNgay({required this.ngay, required this.soLan});

  final DateTime ngay;
  final int soLan;

  @override
  List<Object?> get props => [ngay, soLan];
}

/// AVG / MIN / MAX / COUNT của một chỉ số.
class ThongKeChiSo extends Equatable {
  const ThongKeChiSo({
    required this.loai,
    required this.trungBinh,
    required this.nhoNhat,
    required this.lonNhat,
    required this.soLan,
  });

  final LoaiChiSo loai;
  final double trungBinh;
  final double nhoNhat;
  final double lonNhat;
  final int soLan;

  @override
  List<Object?> get props => [loai, trungBinh, nhoNhat, lonNhat, soLan];
}

/// Số cảnh báo của một người (GROUP BY người dùng).
class XepHangCanhBao extends Equatable {
  const XepHangCanhBao({
    required this.nguoiDung,
    required this.soCanhBao,
    required this.soLanDo,
  });

  final NguoiDung nguoiDung;
  final int soCanhBao;
  final int soLanDo;

  @override
  List<Object?> get props => [nguoiDung, soCanhBao, soLanDo];
}

/// Toàn bộ số liệu của màn hình Thống kê trong một khoảng thời gian.
class ThongKeTongHop extends Equatable {
  const ThongKeTongHop({
    required this.tuNgay,
    required this.denNgay,
    required this.tongLanDo,
    required this.tongCanhBao,
    required this.soNguoiDuocDo,
    required this.lanDoTheoNgay,
    required this.theoChiSo,
    required this.dienBien,
    required this.phanBoMucDo,
    required this.xepHangCanhBao,
  });

  final DateTime tuNgay;
  final DateTime denNgay;
  final int tongLanDo;
  final int tongCanhBao;
  final int soNguoiDuocDo;
  final List<SoLanDoTheoNgay> lanDoTheoNgay;
  final List<ThongKeChiSo> theoChiSo;

  /// Trung bình theo ngày của từng chỉ số.
  final Map<MaChiSo, List<DiemDuLieu>> dienBien;

  /// Số lần đo theo mức độ đánh giá.
  final Map<MucDo, int> phanBoMucDo;
  final List<XepHangCanhBao> xepHangCanhBao;

  @override
  List<Object?> get props => [
    tuNgay,
    denNgay,
    tongLanDo,
    tongCanhBao,
    soNguoiDuocDo,
    lanDoTheoNgay,
    theoChiSo,
    dienBien,
    phanBoMucDo,
    xepHangCanhBao,
  ];
}
