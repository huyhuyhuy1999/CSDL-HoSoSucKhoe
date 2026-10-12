import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../entity/ho_so_suc_khoe.dart';
import '../entity/nguoi_dung.dart';

/// Dữ liệu nhập từ form thêm / sửa hồ sơ.
class ThongTinHoSo extends Equatable {
  const ThongTinHoSo({
    required this.hoTen,
    required this.gioiTinh,
    required this.ngaySinh,
    required this.chieuCao,
    required this.canNang,
    required this.nhomMau,
    this.soDienThoai = '',
    this.email = '',
    this.diaChi = '',
    this.tienSuBenh = '',
    this.diUng = '',
  });

  final String hoTen;
  final GioiTinh gioiTinh;
  final DateTime ngaySinh;
  final double chieuCao;
  final double canNang;
  final String nhomMau;
  final String soDienThoai;
  final String email;
  final String diaChi;
  final String tienSuBenh;
  final String diUng;

  @override
  List<Object?> get props => [
    hoTen,
    gioiTinh,
    ngaySinh,
    chieuCao,
    canNang,
    nhomMau,
    soDienThoai,
    email,
    diaChi,
    tienSuBenh,
    diUng,
  ];
}

/// Truy cập NGUOI_DUNG và HO_SO_SUC_KHOE.
abstract interface class HoSoRepository {
  /// Danh sách hồ sơ; tìm theo tên, lọc theo giới tính và nhóm tuổi.
  Future<Either<Failure, List<HoSoTongHop>>> layDanhSach({
    String tuKhoa = '',
    GioiTinh? gioiTinh,
    NhomTuoi? nhomTuoi,
  });

  Future<Either<Failure, HoSoTongHop>> layChiTiet(int maNguoiDung);

  /// Thêm mới khi [maNguoiDung] là `null`, ngược lại cập nhật.
  Future<Either<Failure, HoSoTongHop>> luu(
    ThongTinHoSo thongTin, {
    int? maNguoiDung,
  });

  Future<Either<Failure, Unit>> xoa(int maNguoiDung);
}
