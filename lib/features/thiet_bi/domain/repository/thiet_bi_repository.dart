import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entity/thiet_bi.dart';

/// Truy cập THIET_BI.
abstract interface class ThietBiRepository {
  /// Danh sách thiết bị; tìm theo tên / mã định danh, lọc theo trạng thái.
  Future<Either<Failure, List<ThietBiTongHop>>> layDanhSach({
    String tuKhoa = '',
    TrangThaiThietBi? trangThai,
  });
}
