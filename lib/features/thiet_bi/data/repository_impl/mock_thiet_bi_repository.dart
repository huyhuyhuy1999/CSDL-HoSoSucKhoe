import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/utils/chuoi.dart';
import '../../../../mock/mock_database.dart';
import '../../../../mock/mock_query.dart';
import '../../domain/entity/thiet_bi.dart';
import '../../domain/repository/thiet_bi_repository.dart';

@LazySingleton(as: ThietBiRepository)
class MockThietBiRepository implements ThietBiRepository {
  MockThietBiRepository(this._db);

  final MockDatabase _db;

  @override
  Future<Either<Failure, List<ThietBiTongHop>>> layDanhSach({
    String tuKhoa = '',
    TrangThaiThietBi? trangThai,
  }) {
    return chayMoPhong(() {
      final ketQua = <ThietBiTongHop>[];
      for (final tb in _db.bangThietBi) {
        if (trangThai != null && tb.trangThai != trangThai) continue;
        final khop =
            khopTuKhoa(tb.tenThietBi, tuKhoa) ||
            khopTuKhoa(tb.maDinhDanh, tuKhoa) ||
            khopTuKhoa(tb.maThietBi, tuKhoa);
        if (!khop) continue;

        var soLanDo = 0;
        DateTime? lanDoCuoi;
        for (final ld in _db.bangLanDo) {
          if (ld.maThietBi != tb.maThietBi) continue;
          soLanDo++;
          if (lanDoCuoi == null || ld.thoiGianDo.isAfter(lanDoCuoi)) {
            lanDoCuoi = ld.thoiGianDo;
          }
        }
        ketQua.add(
          ThietBiTongHop(thietBi: tb, soLanDo: soLanDo, lanDoCuoi: lanDoCuoi),
        );
      }
      return ketQua;
    });
  }
}
