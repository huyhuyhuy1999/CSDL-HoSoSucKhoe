import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../lan_do/domain/entity/muc_do.dart';
import '../entity/canh_bao.dart';

/// Truy cập CANH_BAO.
abstract interface class CanhBaoRepository {
  /// Danh sách cảnh báo (mới nhất trước), lọc theo mức độ, trạng thái đã
  /// xem, người dùng hoặc lần đo.
  Future<Either<Failure, List<CanhBaoDayDu>>> layDanhSach({
    MucDo? mucDo,
    bool chiChuaXem = false,
    String? maNguoiDung,
    String? maLanDo,
  });

  Future<Either<Failure, Unit>> danhDauDaXem(String maCanhBao);

  Future<Either<Failure, Unit>> danhDauTatCaDaXem();
}
