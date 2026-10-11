import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/utils/dinh_dang.dart';
import '../../../../mock/mock_database.dart';
import '../../../../mock/mock_query.dart';
import '../../../canh_bao/domain/entity/canh_bao.dart';
import '../../../lan_do/domain/entity/loai_chi_so.dart';
import '../../../thiet_bi/domain/entity/thiet_bi.dart';
import '../../../thong_ke/domain/entity/thong_ke.dart';
import '../../domain/entity/tong_quan.dart';
import '../../domain/repository/tong_quan_repository.dart';

@LazySingleton(as: TongQuanRepository)
class MockTongQuanRepository implements TongQuanRepository {
  MockTongQuanRepository(this._db);

  final MockDatabase _db;

  @override
  Future<Either<Failure, TongQuan>> layTongQuan() {
    return chayMoPhong(() {
      final now = DateTime.now();
      final dauHomNay = now.dauNgay;
      final dau7Ngay = dauHomNay.subtract(const Duration(days: 6));

      final lanDo7Ngay = _db.truyVanLanDo(tuNgay: dau7Ngay);
      final canhBao = _db.truyVanCanhBao();

      // Trung bình theo ngày của từng chỉ số trong 7 ngày gần nhất.
      final theoNgay = <MaChiSo, Map<DateTime, List<double>>>{};
      for (final ld in lanDo7Ngay) {
        final ngay = ld.lanDo.thoiGianDo.dauNgay;
        for (final kq in ld.ketQua) {
          theoNgay
              .putIfAbsent(kq.loai.ma, () => {})
              .putIfAbsent(ngay, () => [])
              .add(kq.giaTri);
        }
      }

      final xuHuong = <MaChiSo, XuHuongChiSo>{};
      for (final loai in _db.bangLoaiChiSo) {
        final diem = <DiemDuLieu>[];
        final tatCa = <double>[];
        for (var i = 0; i < 7; i++) {
          final ngay = dau7Ngay.add(Duration(days: i)).dauNgay;
          final giaTri = theoNgay[loai.ma]?[ngay];
          if (giaTri == null) continue;
          tatCa.addAll(giaTri);
          diem.add(DiemDuLieu(ngay: ngay, giaTri: _trungBinh(giaTri)));
        }
        xuHuong[loai.ma] = XuHuongChiSo(
          loai: loai,
          diem: diem,
          trungBinh: tatCa.isEmpty ? null : _trungBinh(tatCa),
        );
      }

      return TongQuan(
        soHoSo: _db.bangNguoiDung.length,
        tongLanDo: _db.bangLanDo.length,
        lanDoHomNay: lanDo7Ngay
            .where((ld) => !ld.lanDo.thoiGianDo.isBefore(dauHomNay))
            .length,
        canhBaoChuaXem: canhBao.where((cb) => !cb.canhBao.daXem).length,
        canhBaoHomNay: canhBao
            .where((cb) => !cb.canhBao.thoiGianTao.isBefore(dauHomNay))
            .length,
        thietBiHoatDong: _db.bangThietBi
            .where((tb) => tb.trangThai == TrangThaiThietBi.hoatDong)
            .length,
        tongThietBi: _db.bangThietBi.length,
        canhBaoGanDay: _moiLanDoMotCanhBao(canhBao).take(3).toList(),
        lanDoGanDay: lanDo7Ngay.take(4).toList(),
        xuHuong: xuHuong,
      );
    });
  }

  /// Mỗi lần đo chỉ giữ cảnh báo nặng nhất, để danh sách "gần đây" không bị
  /// một lần đo có nhiều chỉ số vượt ngưỡng chiếm hết chỗ.
  List<CanhBaoDayDu> _moiLanDoMotCanhBao(List<CanhBaoDayDu> canhBao) {
    final theoLanDo = <String, CanhBaoDayDu>{};
    for (final cb in canhBao) {
      final hienCo = theoLanDo[cb.canhBao.maLanDo];
      if (hienCo == null ||
          cb.canhBao.mucDo.index > hienCo.canhBao.mucDo.index) {
        theoLanDo[cb.canhBao.maLanDo] = cb;
      }
    }
    return theoLanDo.values.toList();
  }

  double _trungBinh(List<double> giaTri) =>
      giaTri.reduce((a, b) => a + b) / giaTri.length;
}
