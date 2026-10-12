import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entity/lan_do.dart';
import '../entity/loai_chi_so.dart';

/// Truy cập LAN_DO, CHI_TIET_LAN_DO và LOAI_CHI_SO.
abstract interface class LanDoRepository {
  Future<Either<Failure, List<LoaiChiSo>>> layLoaiChiSo();

  /// Lịch sử đo (mới nhất trước), lọc theo người, khoảng thời gian và nguồn.
  Future<Either<Failure, List<LanDoDayDu>>> layLichSu({
    int? maNguoiDung,
    DateTime? tuNgay,
    DateTime? denNgay,
    NguonDuLieu? nguon,
    int? gioiHan,
  });

  Future<Either<Failure, LanDoDayDu>> layChiTiet(int maLanDo);

  Future<Either<Failure, LanDoDayDu>> them({
    required int maNguoiDung,
    required DateTime thoiGianDo,
    required NguonDuLieu nguon,
    required Map<MaChiSo, double> giaTri,
    int? maThietBi,
    String ghiChu = '',
  });

  Future<Either<Failure, Unit>> xoa(int maLanDo);
}
