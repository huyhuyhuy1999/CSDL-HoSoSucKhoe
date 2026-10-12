import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/database/truy_van.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/utils/dinh_dang.dart';
import '../../../ho_so/data/model/ho_so_mapper.dart';
import '../../../lan_do/data/model/loai_chi_so_mapper.dart';
import '../../../lan_do/domain/entity/loai_chi_so.dart';
import '../../../lan_do/domain/entity/muc_do.dart';
import '../../domain/entity/thong_ke.dart';
import '../../domain/repository/thong_ke_repository.dart';

/// Các truy vấn tổng hợp trên SQLite: GROUP BY, COUNT, AVG, MIN, MAX trên
/// các view V_LAN_DO_TONG_HOP, V_CHI_TIET_DANH_GIA và V_CANH_BAO_CHI_TIET.
///
/// Câu lệnh tương đương bên SQL Server: `10_thong_ke.sql`, mục E và H.
@LazySingleton(as: ThongKeRepository)
class SqliteThongKeRepository implements ThongKeRepository {
  SqliteThongKeRepository(this._csdl);

  final AppDatabase _csdl;

  @override
  Future<Either<Failure, ThongKeTongHop>> layThongKe({
    required DateTime tuNgay,
    required DateTime denNgay,
    int? maNguoiDung,
  }) {
    return chayTruyVan(() {
      final db = _csdl.db;
      final tu = tuNgay.dauNgay;
      final den = denNgay.cuoiNgay;
      // ?1, ?2: khoảng thời gian; ?3: người dùng (NULL = mọi người).
      final thamSo = [sqlNgayGio(tu), sqlNgayGio(den), maNguoiDung];
      const loc = '''
        ThoiGianDo BETWEEN ?1 AND ?2
        AND (?3 IS NULL OR MaNguoiDung = ?3)
      ''';

      // Tổng số lần đo, số người được đo và phân bố theo mức độ.
      final theoMucDo = db.select('''
        SELECT MucDo, COUNT(*) AS SoLanDo
        FROM V_LAN_DO_TONG_HOP
        WHERE $loc
        GROUP BY MucDo
      ''', thamSo);
      final phanBo = {for (final mucDo in MucDo.values) mucDo: 0};
      for (final d in theoMucDo) {
        phanBo[MucDo.tuCsdl(d['MucDo'] as String)] = d['SoLanDo'] as int;
      }

      final tong = db.select('''
        SELECT COUNT(*) AS TongLanDo, COUNT(DISTINCT MaNguoiDung) AS SoNguoi
        FROM LAN_DO
        WHERE $loc
      ''', thamSo).first;

      // Số lần đo theo ngày.
      final lanDoTheoNgay = {
        for (final d in db.select('''
          SELECT date(ThoiGianDo) AS Ngay, COUNT(*) AS SoLanDo
          FROM LAN_DO
          WHERE $loc
          GROUP BY date(ThoiGianDo)
        ''', thamSo))
          d['Ngay'] as String: d['SoLanDo'] as int,
      };

      // Trung bình / thấp nhất / cao nhất / số lần của từng chỉ số.
      final theoChiSo = <ThongKeChiSo>[];
      for (final d in db.select('''
        SELECT ${cotLoaiChiSo()},
               AVG(v.GiaTri) AS TrungBinh,
               MIN(v.GiaTri) AS NhoNhat,
               MAX(v.GiaTri) AS LonNhat,
               COUNT(*)      AS SoLan
        FROM V_CHI_TIET_DANH_GIA AS v
        JOIN LOAI_CHI_SO         AS l ON l.MaLoaiChiSo = v.MaLoaiChiSo
        WHERE v.ThoiGianDo BETWEEN ?1 AND ?2
          AND (?3 IS NULL OR v.MaNguoiDung = ?3)
        GROUP BY l.MaLoaiChiSo
        ORDER BY l.MaLoaiChiSo
      ''', thamSo)) {
        final loai = loaiChiSoTuDong(d);
        if (loai == null) continue;
        theoChiSo.add(
          ThongKeChiSo(
            loai: loai,
            trungBinh: (d['TrungBinh'] as num).toDouble(),
            nhoNhat: (d['NhoNhat'] as num).toDouble(),
            lonNhat: (d['LonNhat'] as num).toDouble(),
            soLan: d['SoLan'] as int,
          ),
        );
      }

      // Diễn biến: trung bình theo ngày của từng chỉ số (gom theo hai cột).
      final dienBien = {for (final ma in MaChiSo.values) ma: <DiemDuLieu>[]};
      for (final d in db.select('''
        SELECT KyHieu, date(ThoiGianDo) AS Ngay, AVG(GiaTri) AS TrungBinh
        FROM V_CHI_TIET_DANH_GIA
        WHERE $loc
        GROUP BY KyHieu, date(ThoiGianDo)
        ORDER BY Ngay
      ''', thamSo)) {
        final ma = MaChiSo.tuKyHieu(d['KyHieu'] as String);
        if (ma == null) continue;
        dienBien[ma]!.add(
          DiemDuLieu(
            ngay: DateTime.parse(d['Ngay'] as String),
            giaTri: (d['TrungBinh'] as num).toDouble(),
          ),
        );
      }

      // Năm người có nhiều cảnh báo nhất, kèm số lần đo của họ trong khoảng.
      final xepHang = [
        for (final d in db.select('''
          SELECT ${cotNguoiDung()},
                 COUNT(*) AS SoCanhBao,
                 (SELECT COUNT(*) FROM LAN_DO AS ld
                   WHERE ld.MaNguoiDung = nd.MaNguoiDung
                     AND ld.ThoiGianDo BETWEEN ?1 AND ?2) AS SoLanDo
          FROM V_CANH_BAO_CHI_TIET AS v
          JOIN NGUOI_DUNG          AS nd ON nd.MaNguoiDung = v.MaNguoiDung
          WHERE v.ThoiGianTao BETWEEN ?1 AND ?2
            AND (?3 IS NULL OR v.MaNguoiDung = ?3)
          GROUP BY nd.MaNguoiDung
          ORDER BY SoCanhBao DESC, nd.MaNguoiDung
          LIMIT 5
        ''', thamSo))
          XepHangCanhBao(
            nguoiDung: nguoiDungTuDong(d),
            soCanhBao: d['SoCanhBao'] as int,
            soLanDo: d['SoLanDo'] as int,
          ),
      ];

      final tongCanhBao =
          db.select('''
            SELECT COUNT(*) AS n
            FROM V_CANH_BAO_CHI_TIET
            WHERE ThoiGianTao BETWEEN ?1 AND ?2
              AND (?3 IS NULL OR MaNguoiDung = ?3)
          ''', thamSo).first['n']
              as int;

      // Điền đủ mọi ngày trong khoảng, kể cả ngày không có lần đo nào.
      final cacNgay = <DateTime>[];
      for (var d = tu; !d.isAfter(den); d = d.add(const Duration(days: 1))) {
        cacNgay.add(d.dauNgay);
      }

      return ThongKeTongHop(
        tuNgay: tu,
        denNgay: den,
        tongLanDo: tong['TongLanDo'] as int,
        tongCanhBao: tongCanhBao,
        soNguoiDuocDo: tong['SoNguoi'] as int,
        lanDoTheoNgay: [
          for (final ngay in cacNgay)
            SoLanDoTheoNgay(
              ngay: ngay,
              soLan: lanDoTheoNgay[sqlNgay(ngay)] ?? 0,
            ),
        ],
        theoChiSo: theoChiSo,
        dienBien: dienBien,
        phanBoMucDo: phanBo,
        xepHangCanhBao: xepHang,
      );
    });
  }
}
