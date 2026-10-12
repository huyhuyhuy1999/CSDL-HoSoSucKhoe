import 'package:equatable/equatable.dart';

enum GioiTinh {
  nam('Nam'),
  nu('Nữ'),
  khac('Khác');

  const GioiTinh(this.nhan);

  /// Nhãn hiển thị, cũng là giá trị cột NGUOI_DUNG.GioiTinh.
  final String nhan;

  static GioiTinh tuCsdl(String giaTri) =>
      values.firstWhere((gt) => gt.nhan == giaTri, orElse: () => khac);
}

/// Nhóm tuổi dùng cho bộ lọc "độ tuổi".
enum NhomTuoi {
  duoi18('Dưới 18', 0, 17),
  tu18Den39('18 – 39', 18, 39),
  tu40Den59('40 – 59', 40, 59),
  tu60('Từ 60', 60, 200);

  const NhomTuoi(this.nhan, this.tuoiMin, this.tuoiMax);

  final String nhan;
  final int tuoiMin;
  final int tuoiMax;

  bool chua(int tuoi) => tuoi >= tuoiMin && tuoi <= tuoiMax;
}

/// Bảng NGUOI_DUNG.
class NguoiDung extends Equatable {
  const NguoiDung({
    required this.maNguoiDung,
    required this.hoTen,
    required this.gioiTinh,
    required this.ngaySinh,
    this.soDienThoai = '',
    this.email = '',
    this.diaChi = '',
  });

  final int maNguoiDung;
  final String hoTen;
  final GioiTinh gioiTinh;
  final DateTime ngaySinh;
  final String soDienThoai;
  final String email;
  final String diaChi;

  int tuoiTai(DateTime thoiDiem) {
    var tuoi = thoiDiem.year - ngaySinh.year;
    final chuaToiSinhNhat =
        thoiDiem.month < ngaySinh.month ||
        (thoiDiem.month == ngaySinh.month && thoiDiem.day < ngaySinh.day);
    if (chuaToiSinhNhat) tuoi--;
    return tuoi;
  }

  int get tuoi => tuoiTai(DateTime.now());

  /// Hai chữ cái đầu của họ và tên, dùng làm avatar.
  String get chuCaiDau {
    final tu = hoTen.trim().split(RegExp(r'\s+'));
    if (tu.isEmpty || tu.first.isEmpty) return '?';
    if (tu.length == 1) return tu.first[0].toUpperCase();
    return (tu.first[0] + tu.last[0]).toUpperCase();
  }

  @override
  List<Object?> get props => [
    maNguoiDung,
    hoTen,
    gioiTinh,
    ngaySinh,
    soDienThoai,
    email,
    diaChi,
  ];
}
