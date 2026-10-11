import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/utils/data_refresh_bus.dart';
import '../../../../mock/mock_database.dart';
import '../../../../mock/mock_query.dart';
import '../../../lan_do/domain/entity/muc_do.dart';
import '../../domain/entity/canh_bao.dart';
import '../../domain/repository/canh_bao_repository.dart';

@LazySingleton(as: CanhBaoRepository)
class MockCanhBaoRepository implements CanhBaoRepository {
  MockCanhBaoRepository(this._db, this._bus);

  final MockDatabase _db;
  final DataRefreshBus _bus;

  @override
  Future<Either<Failure, List<CanhBaoDayDu>>> layDanhSach({
    MucDo? mucDo,
    bool chiChuaXem = false,
    String? maNguoiDung,
    String? maLanDo,
  }) {
    return chayMoPhong(
      () => _db.truyVanCanhBao(
        mucDo: mucDo,
        chiChuaXem: chiChuaXem,
        maNguoiDung: maNguoiDung,
        maLanDo: maLanDo,
      ),
    );
  }

  @override
  Future<Either<Failure, Unit>> danhDauDaXem(String maCanhBao) async {
    final ketQua = await chayMoPhong(() {
      _db.danhDauDaXem(maCanhBao);
      return unit;
    });
    if (ketQua.isRight()) _bus.notify();
    return ketQua;
  }

  @override
  Future<Either<Failure, Unit>> danhDauTatCaDaXem() async {
    final ketQua = await chayMoPhong(() {
      _db.danhDauTatCaDaXem();
      return unit;
    });
    if (ketQua.isRight()) _bus.notify();
    return ketQua;
  }
}
