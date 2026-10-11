import 'package:equatable/equatable.dart';

/// Lỗi nghiệp vụ trả về từ tầng dữ liệu, bọc trong `Either<Failure, T>`.
sealed class Failure extends Equatable implements Exception {
  const Failure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

/// Không tìm thấy bản ghi (ví dụ: sai khóa chính).
class NotFoundFailure extends Failure {
  const NotFoundFailure(super.message);
}

/// Dữ liệu không hợp lệ (vi phạm ràng buộc).
class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

/// Lỗi không lường trước.
class UnexpectedFailure extends Failure {
  const UnexpectedFailure([
    super.message = 'Đã có lỗi xảy ra. Vui lòng thử lại.',
  ]);
}
