import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entity/tong_quan.dart';

/// Số liệu tổng hợp cho màn hình Tổng quan.
abstract interface class TongQuanRepository {
  Future<Either<Failure, TongQuan>> layTongQuan();
}
