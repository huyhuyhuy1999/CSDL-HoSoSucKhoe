import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/database/truy_van.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entity/thiet_bi.dart';
import '../../domain/repository/thiet_bi_repository.dart';
import '../model/thiet_bi_mapper.dart';

/// THIET_BI trên SQLite.
///
/// Câu lệnh tương đương bên SQL Server: `08_thiet_bi.sql`, mục 5 và 6.1.
@LazySingleton(as: ThietBiRepository)
class SqliteThietBiRepository implements ThietBiRepository {
  SqliteThietBiRepository(this._csdl);

  final AppDatabase _csdl;

  @override
  Future<Either<Failure, List<ThietBiTongHop>>> layDanhSach({
    String tuKhoa = '',
    TrangThaiThietBi? trangThai,
  }) {
    return chayTruyVan(() {
      // LEFT JOIN + GROUP BY: thiết bị chưa đo lần nào vẫn hiện với SoLanDo = 0.
      final dong = _csdl.db.select(
        '''
        SELECT ${cotThietBi()},
               COUNT(ld.MaLanDo)  AS SoLanDo,
               MAX(ld.ThoiGianDo) AS LanDoCuoi
        FROM THIET_BI    AS tb
        LEFT JOIN LAN_DO AS ld ON ld.MaThietBi = tb.MaThietBi
        WHERE (?1 = ''
               OR bo_dau(tb.TenThietBi) LIKE '%' || bo_dau(?1) || '%'
               OR tb.MaDinhDanh LIKE '%' || ?1 || '%')
          AND (?2 IS NULL OR tb.TrangThai = ?2)
        GROUP BY tb.MaThietBi
        ORDER BY tb.MaThietBi
        ''',
        [tuKhoa.trim(), trangThai?.nhan],
      );

      return [
        for (final d in dong)
          ThietBiTongHop(
            thietBi: thietBiTuDong(d)!,
            soLanDo: d['SoLanDo'] as int,
            lanDoCuoi: d['LanDoCuoi'] == null
                ? null
                : docNgayGio(d['LanDoCuoi'] as String),
          ),
      ];
    });
  }
}
