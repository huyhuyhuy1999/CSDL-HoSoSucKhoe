import 'package:dartz/dartz.dart';

import '../core/error/failures.dart';

/// Độ trễ giả lập để giao diện thể hiện được trạng thái "đang tải".
const Duration doTreMoPhong = Duration(milliseconds: 160);

/// Chạy một truy vấn trên dữ liệu mẫu như thể gọi tới CSDL thật:
/// có độ trễ và trả lỗi dưới dạng [Failure].
Future<Either<Failure, T>> chayMoPhong<T>(T Function() truyVan) async {
  await Future<void>.delayed(doTreMoPhong);
  try {
    return Right(truyVan());
  } on Failure catch (failure) {
    return Left(failure);
  } catch (_) {
    return const Left(UnexpectedFailure());
  }
}
