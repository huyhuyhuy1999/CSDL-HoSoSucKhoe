import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/utils/data_refresh_bus.dart';
import '../../../../mock/mock_database.dart';
import '../../../../mock/mock_query.dart';
import '../../domain/entity/lan_do.dart';
import '../../domain/entity/loai_chi_so.dart';
import '../../domain/repository/lan_do_repository.dart';

@LazySingleton(as: LanDoRepository)
class MockLanDoRepository implements LanDoRepository {
  MockLanDoRepository(this._db, this._bus);

  final MockDatabase _db;
  final DataRefreshBus _bus;

  @override
  Future<Either<Failure, List<LoaiChiSo>>> layLoaiChiSo() {
    return chayMoPhong(() => List.of(_db.bangLoaiChiSo));
  }

  @override
  Future<Either<Failure, List<LanDoDayDu>>> layLichSu({
    String? maNguoiDung,
    DateTime? tuNgay,
    DateTime? denNgay,
    NguonDuLieu? nguon,
    int? gioiHan,
  }) {
    return chayMoPhong(
      () => _db.truyVanLanDo(
        maNguoiDung: maNguoiDung,
        tuNgay: tuNgay,
        denNgay: denNgay,
        nguon: nguon,
        gioiHan: gioiHan,
      ),
    );
  }

  @override
  Future<Either<Failure, LanDoDayDu>> layChiTiet(String maLanDo) {
    return chayMoPhong(() {
      final lanDo = _db.timLanDo(maLanDo);
      if (lanDo == null) {
        throw NotFoundFailure('Không tìm thấy lần đo $maLanDo.');
      }
      return _db.ghepLanDo(lanDo);
    });
  }

  @override
  Future<Either<Failure, LanDoDayDu>> them({
    required String maNguoiDung,
    required DateTime thoiGianDo,
    required NguonDuLieu nguon,
    required Map<MaChiSo, double> giaTri,
    String? maThietBi,
    String ghiChu = '',
  }) async {
    final ketQua = await chayMoPhong(() {
      // Kiểm tra khóa ngoại và ràng buộc dữ liệu như CSDL thật sẽ làm.
      if (_db.timNguoiDung(maNguoiDung) == null) {
        throw const ValidationFailure('Người được đo không tồn tại.');
      }
      if (nguon == NguonDuLieu.thietBi && _db.timThietBi(maThietBi) == null) {
        throw const ValidationFailure('Thiết bị đo không tồn tại.');
      }
      if (giaTri.isEmpty) {
        throw const ValidationFailure('Cần nhập ít nhất một chỉ số.');
      }
      if (thoiGianDo.isAfter(DateTime.now().add(const Duration(minutes: 1)))) {
        throw const ValidationFailure('Thời gian đo không được ở tương lai.');
      }
      for (final entry in giaTri.entries) {
        final loai = _db.loaiChiSo(entry.key);
        if (entry.value < loai.nhapMin || entry.value > loai.nhapMax) {
          throw ValidationFailure(
            '${loai.tenChiSo} phải nằm trong khoảng '
            '${loai.dinhDang(loai.nhapMin)} – ${loai.dinhDang(loai.nhapMax)} '
            '${loai.donViDo}.',
          );
        }
      }
      final tamThu = giaTri[MaChiSo.huyetApTamThu];
      final tamTruong = giaTri[MaChiSo.huyetApTamTruong];
      if (tamThu != null && tamTruong != null && tamThu <= tamTruong) {
        throw const ValidationFailure(
          'Huyết áp tâm thu phải lớn hơn huyết áp tâm trương.',
        );
      }

      final lanDo = _db.themLanDo(
        maNguoiDung: maNguoiDung,
        thoiGianDo: thoiGianDo,
        nguon: nguon,
        maThietBi: maThietBi,
        giaTri: giaTri,
        ghiChu: ghiChu.trim(),
      );
      return _db.ghepLanDo(lanDo);
    });
    if (ketQua.isRight()) _bus.notify();
    return ketQua;
  }

  @override
  Future<Either<Failure, Unit>> xoa(String maLanDo) async {
    final ketQua = await chayMoPhong(() {
      if (_db.timLanDo(maLanDo) == null) {
        throw NotFoundFailure('Không tìm thấy lần đo $maLanDo.');
      }
      _db.xoaLanDo(maLanDo);
      return unit;
    });
    if (ketQua.isRight()) _bus.notify();
    return ketQua;
  }
}
