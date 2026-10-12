import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entity/thong_ke.dart';

/// Các truy vấn tổng hợp (JOIN, GROUP BY, AVG/MIN/MAX/COUNT).
abstract interface class ThongKeRepository {
  Future<Either<Failure, ThongKeTongHop>> layThongKe({
    required DateTime tuNgay,
    required DateTime denNgay,
    int? maNguoiDung,
  });
}
