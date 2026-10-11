import 'dart:math';

import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/utils/dinh_dang.dart';
import '../../../../mock/mock_database.dart';
import '../../../../mock/mock_query.dart';
import '../../../lan_do/domain/entity/loai_chi_so.dart';
import '../../../lan_do/domain/entity/muc_do.dart';
import '../../domain/entity/thong_ke.dart';
import '../../domain/repository/thong_ke_repository.dart';

@LazySingleton(as: ThongKeRepository)
class MockThongKeRepository implements ThongKeRepository {
  MockThongKeRepository(this._db);

  final MockDatabase _db;

  @override
  Future<Either<Failure, ThongKeTongHop>> layThongKe({
    required DateTime tuNgay,
    required DateTime denNgay,
    String? maNguoiDung,
  }) {
    return chayMoPhong(() {
      final tu = tuNgay.dauNgay;
      final den = denNgay.cuoiNgay;
      final lanDo = _db.truyVanLanDo(
        maNguoiDung: maNguoiDung,
        tuNgay: tu,
        denNgay: den,
      );
      final canhBao = _db.truyVanCanhBao(
        maNguoiDung: maNguoiDung,
        tuNgay: tu,
        denNgay: den,
      );

      // Gom theo ngày.
      final soLanTheoNgay = <DateTime, int>{};
      final giaTriTheoNgay = <MaChiSo, Map<DateTime, List<double>>>{};
      final giaTriTheoChiSo = <MaChiSo, List<double>>{};
      final phanBo = {for (final m in MucDo.values) m: 0};
      final nguoiDuocDo = <String>{};
      final soLanDoTheoNguoi = <String, int>{};

      for (final ld in lanDo) {
        final ngay = ld.lanDo.thoiGianDo.dauNgay;
        final ma = ld.nguoiDung.maNguoiDung;
        soLanTheoNgay[ngay] = (soLanTheoNgay[ngay] ?? 0) + 1;
        phanBo[ld.mucDo] = phanBo[ld.mucDo]! + 1;
        nguoiDuocDo.add(ma);
        soLanDoTheoNguoi[ma] = (soLanDoTheoNguoi[ma] ?? 0) + 1;

        for (final kq in ld.ketQua) {
          giaTriTheoChiSo.putIfAbsent(kq.loai.ma, () => []).add(kq.giaTri);
          giaTriTheoNgay
              .putIfAbsent(kq.loai.ma, () => {})
              .putIfAbsent(ngay, () => [])
              .add(kq.giaTri);
        }
      }

      final cacNgay = <DateTime>[];
      for (var d = tu; !d.isAfter(den); d = d.add(const Duration(days: 1))) {
        cacNgay.add(d.dauNgay);
      }

      // Xếp hạng người có nhiều cảnh báo.
      final soCanhBaoTheoNguoi = <String, int>{};
      for (final cb in canhBao) {
        final ma = cb.nguoiDung.maNguoiDung;
        soCanhBaoTheoNguoi[ma] = (soCanhBaoTheoNguoi[ma] ?? 0) + 1;
      }
      final xepHang = [
        for (final e in soCanhBaoTheoNguoi.entries)
          XepHangCanhBao(
            nguoiDung: _db.timNguoiDung(e.key)!,
            soCanhBao: e.value,
            soLanDo: soLanDoTheoNguoi[e.key] ?? 0,
          ),
      ]..sort((a, b) => b.soCanhBao.compareTo(a.soCanhBao));

      return ThongKeTongHop(
        tuNgay: tu,
        denNgay: den,
        tongLanDo: lanDo.length,
        tongCanhBao: canhBao.length,
        soNguoiDuocDo: nguoiDuocDo.length,
        lanDoTheoNgay: [
          for (final ngay in cacNgay)
            SoLanDoTheoNgay(ngay: ngay, soLan: soLanTheoNgay[ngay] ?? 0),
        ],
        theoChiSo: [
          for (final loai in _db.bangLoaiChiSo)
            if (giaTriTheoChiSo[loai.ma] case final giaTri?)
              ThongKeChiSo(
                loai: loai,
                trungBinh: _trungBinh(giaTri),
                nhoNhat: giaTri.reduce(min),
                lonNhat: giaTri.reduce(max),
                soLan: giaTri.length,
              ),
        ],
        dienBien: {
          for (final loai in _db.bangLoaiChiSo)
            loai.ma: [
              for (final ngay in cacNgay)
                if (giaTriTheoNgay[loai.ma]?[ngay] case final giaTri?)
                  DiemDuLieu(ngay: ngay, giaTri: _trungBinh(giaTri)),
            ],
        },
        phanBoMucDo: phanBo,
        xepHangCanhBao: xepHang.take(5).toList(),
      );
    });
  }

  double _trungBinh(List<double> giaTri) =>
      giaTri.reduce((a, b) => a + b) / giaTri.length;
}
