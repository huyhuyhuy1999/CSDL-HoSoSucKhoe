import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/database/truy_van.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/utils/data_refresh_bus.dart';
import '../../../lan_do/domain/entity/muc_do.dart';
import '../../domain/entity/canh_bao.dart';
import '../../domain/repository/canh_bao_repository.dart';
import '../model/canh_bao_mapper.dart';

/// CANH_BAO trên SQLite. Ứng dụng không tự chèn cảnh báo: chúng do trigger
/// trên CHI_TIET_LAN_DO sinh ra; ở đây chỉ đọc và đánh dấu đã xem.
///
/// Câu lệnh tương đương bên SQL Server: `09_canh_bao.sql`.
@LazySingleton(as: CanhBaoRepository)
class SqliteCanhBaoRepository implements CanhBaoRepository {
  SqliteCanhBaoRepository(this._csdl, this._bus);

  final AppDatabase _csdl;
  final DataRefreshBus _bus;

  @override
  Future<Either<Failure, List<CanhBaoDayDu>>> layDanhSach({
    MucDo? mucDo,
    bool chiChuaXem = false,
    int? maNguoiDung,
    int? maLanDo,
  }) {
    return chayTruyVan(() {
      final dong = _csdl.db.select(
        '''
        $selectCanhBao
        WHERE (?1 IS NULL OR cb.MucDo = ?1)
          AND (?2 = 0 OR cb.DaXem = 0)
          AND (?3 IS NULL OR ld.MaNguoiDung = ?3)
          AND (?4 IS NULL OR cb.MaLanDo = ?4)
        ORDER BY cb.ThoiGianTao DESC, cb.MaLanDo DESC, cb.MaLoaiChiSo
        ''',
        [mucDo?.nhan, chiChuaXem ? 1 : 0, maNguoiDung, maLanDo],
      );
      return [for (final d in dong) ?canhBaoTuDong(d)];
    });
  }

  @override
  Future<Either<Failure, Unit>> danhDauDaXem(int maCanhBao) async {
    final ketQua = await chayTruyVan(() {
      _csdl.db.execute(
        'UPDATE CANH_BAO SET DaXem = 1 WHERE MaCanhBao = ? AND DaXem = 0',
        [maCanhBao],
      );
      return unit;
    });
    if (ketQua.isRight()) _bus.notify();
    return ketQua;
  }

  @override
  Future<Either<Failure, Unit>> danhDauTatCaDaXem() async {
    final ketQua = await chayTruyVan(() {
      _csdl.db.execute('UPDATE CANH_BAO SET DaXem = 1 WHERE DaXem = 0');
      return unit;
    });
    if (ketQua.isRight()) _bus.notify();
    return ketQua;
  }
}
