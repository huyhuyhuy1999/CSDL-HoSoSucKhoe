import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/database/truy_van.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/utils/dinh_dang.dart';
import '../../../canh_bao/data/model/canh_bao_mapper.dart';
import '../../../lan_do/data/datasource/lan_do_sql.dart';
import '../../../lan_do/data/model/loai_chi_so_mapper.dart';
import '../../../lan_do/domain/entity/loai_chi_so.dart';
import '../../../thong_ke/domain/entity/thong_ke.dart';
import '../../domain/entity/tong_quan.dart';
import '../../domain/repository/tong_quan_repository.dart';

/// Số liệu của màn hình Tổng quan, lấy bằng các truy vấn tổng hợp trên SQLite.
///
/// Câu lệnh tương đương bên SQL Server: `10_thong_ke.sql`, mục H.1, H.4 và H.5.
@LazySingleton(as: TongQuanRepository)
class SqliteTongQuanRepository implements TongQuanRepository {
  SqliteTongQuanRepository(this._csdl);

  final AppDatabase _csdl;

  @override
  Future<Either<Failure, TongQuan>> layTongQuan() {
    return chayTruyVan(() {
      final db = _csdl.db;
      final dauHomNay = DateTime.now().dauNgay;
      final dau7Ngay = dauHomNay.subtract(const Duration(days: 6));

      // Các con số tổng quan lấy trong một câu lệnh bằng truy vấn con vô hướng.
      final tong = db
          .select(
            '''
        SELECT
          (SELECT COUNT(*) FROM HO_SO_SUC_KHOE)                         AS SoHoSo,
          (SELECT COUNT(*) FROM LAN_DO)                                 AS TongLanDo,
          (SELECT COUNT(*) FROM LAN_DO WHERE ThoiGianDo >= ?1)          AS LanDoHomNay,
          (SELECT COUNT(*) FROM CANH_BAO WHERE DaXem = 0)               AS CanhBaoChuaXem,
          (SELECT COUNT(*) FROM CANH_BAO WHERE ThoiGianTao >= ?1)       AS CanhBaoHomNay,
          (SELECT COUNT(*) FROM THIET_BI WHERE TrangThai = 'Hoạt động') AS ThietBiHoatDong,
          (SELECT COUNT(*) FROM THIET_BI)                               AS TongThietBi
        ''',
            [sqlNgayGio(dauHomNay)],
          )
          .first;

      // Ba cảnh báo gần nhất, mỗi lần đo chỉ lấy cảnh báo nặng nhất:
      // ROW_NUMBER() đánh số cảnh báo trong từng lần đo, nguy hiểm đứng trước.
      final canhBaoGanDay = [
        for (final d in db.select('''
          $selectCanhBao
          WHERE cb.MaCanhBao IN (
              SELECT MaCanhBao
              FROM (
                  SELECT MaCanhBao,
                         ROW_NUMBER() OVER (
                             PARTITION BY MaLanDo
                             ORDER BY (MucDo = 'Nguy hiểm') DESC, MaLoaiChiSo
                         ) AS ThuTu
                  FROM CANH_BAO
              )
              WHERE ThuTu = 1
          )
          ORDER BY cb.ThoiGianTao DESC, cb.MaLanDo DESC
          LIMIT 3
        '''))
          ?canhBaoTuDong(d),
      ];

      final lanDoGanDay = docLanDo(
        db,
        dieuKien: 'ld.ThoiGianDo >= ?',
        thamSo: [sqlNgayGio(dau7Ngay)],
        gioiHan: 4,
      );

      // Xu hướng 7 ngày: trung bình theo ngày của từng chỉ số.
      final diemTheoChiSo = <int, List<DiemDuLieu>>{};
      final tongTheoChiSo = <int, (double, int)>{};
      for (final d in db.select(
        '''
        SELECT MaLoaiChiSo,
               date(ThoiGianDo) AS Ngay,
               AVG(GiaTri)      AS TrungBinh,
               SUM(GiaTri)      AS Tong,
               COUNT(*)         AS SoGiaTri
        FROM V_CHI_TIET_DANH_GIA
        WHERE ThoiGianDo >= ?1
        GROUP BY MaLoaiChiSo, date(ThoiGianDo)
        ORDER BY Ngay
        ''',
        [sqlNgayGio(dau7Ngay)],
      )) {
        final ma = d['MaLoaiChiSo'] as int;
        diemTheoChiSo
            .putIfAbsent(ma, () => [])
            .add(
              DiemDuLieu(
                ngay: DateTime.parse(d['Ngay'] as String),
                giaTri: (d['TrungBinh'] as num).toDouble(),
              ),
            );
        final (tongCu, soCu) = tongTheoChiSo[ma] ?? (0.0, 0);
        tongTheoChiSo[ma] = (
          tongCu + (d['Tong'] as num).toDouble(),
          soCu + (d['SoGiaTri'] as int),
        );
      }

      final xuHuong = <MaChiSo, XuHuongChiSo>{};
      for (final d in db.select(
        'SELECT ${cotLoaiChiSo()} FROM LOAI_CHI_SO AS l ORDER BY l.MaLoaiChiSo',
      )) {
        final loai = loaiChiSoTuDong(d);
        if (loai == null) continue;
        final tongSo = tongTheoChiSo[loai.maLoaiChiSo];
        xuHuong[loai.ma] = XuHuongChiSo(
          loai: loai,
          diem: diemTheoChiSo[loai.maLoaiChiSo] ?? const [],
          trungBinh: tongSo == null ? null : tongSo.$1 / tongSo.$2,
        );
      }

      return TongQuan(
        soHoSo: tong['SoHoSo'] as int,
        tongLanDo: tong['TongLanDo'] as int,
        lanDoHomNay: tong['LanDoHomNay'] as int,
        canhBaoChuaXem: tong['CanhBaoChuaXem'] as int,
        canhBaoHomNay: tong['CanhBaoHomNay'] as int,
        thietBiHoatDong: tong['ThietBiHoatDong'] as int,
        tongThietBi: tong['TongThietBi'] as int,
        canhBaoGanDay: canhBaoGanDay,
        lanDoGanDay: lanDoGanDay,
        xuHuong: xuHuong,
      );
    });
  }
}
