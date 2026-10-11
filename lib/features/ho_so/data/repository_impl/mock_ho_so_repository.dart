import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/utils/chuoi.dart';
import '../../../../core/utils/data_refresh_bus.dart';
import '../../../../mock/mock_database.dart';
import '../../../../mock/mock_query.dart';
import '../../domain/entity/ho_so_suc_khoe.dart';
import '../../domain/entity/nguoi_dung.dart';
import '../../domain/repository/ho_so_repository.dart';

@LazySingleton(as: HoSoRepository)
class MockHoSoRepository implements HoSoRepository {
  MockHoSoRepository(this._db, this._bus);

  final MockDatabase _db;
  final DataRefreshBus _bus;

  @override
  Future<Either<Failure, List<HoSoTongHop>>> layDanhSach({
    String tuKhoa = '',
    GioiTinh? gioiTinh,
    NhomTuoi? nhomTuoi,
  }) {
    return chayMoPhong(() {
      final ketQua = <HoSoTongHop>[];
      for (final nd in _db.bangNguoiDung) {
        if (!khopTuKhoa(nd.hoTen, tuKhoa)) continue;
        if (gioiTinh != null && nd.gioiTinh != gioiTinh) continue;
        if (nhomTuoi != null && !nhomTuoi.chua(nd.tuoi)) continue;
        ketQua.add(_db.ghepHoSo(nd));
      }
      ketQua.sort(
        (a, b) => boDau(a.nguoiDung.hoTen).compareTo(boDau(b.nguoiDung.hoTen)),
      );
      return ketQua;
    });
  }

  @override
  Future<Either<Failure, HoSoTongHop>> layChiTiet(String maNguoiDung) {
    return chayMoPhong(() => _db.ghepHoSo(_timNguoiDung(maNguoiDung)));
  }

  @override
  Future<Either<Failure, HoSoTongHop>> luu(
    ThongTinHoSo thongTin, {
    String? maNguoiDung,
  }) async {
    final ketQua = await chayMoPhong(() {
      if (thongTin.hoTen.trim().isEmpty) {
        throw const ValidationFailure('Họ và tên không được để trống.');
      }
      if (thongTin.chieuCao <= 0 || thongTin.canNang <= 0) {
        throw const ValidationFailure('Chiều cao và cân nặng phải lớn hơn 0.');
      }

      if (maNguoiDung == null) {
        final moi = _db.themNguoiDung(
          hoTen: thongTin.hoTen.trim(),
          gioiTinh: thongTin.gioiTinh,
          ngaySinh: thongTin.ngaySinh,
          soDienThoai: thongTin.soDienThoai.trim(),
          email: thongTin.email.trim(),
          diaChi: thongTin.diaChi.trim(),
          chieuCao: thongTin.chieuCao,
          canNang: thongTin.canNang,
          nhomMau: thongTin.nhomMau,
          tienSuBenh: thongTin.tienSuBenh.trim(),
          diUng: thongTin.diUng.trim(),
        );
        return _db.ghepHoSo(moi);
      }

      final cu = _timNguoiDung(maNguoiDung);
      final hoSoCu = _db.timHoSo(maNguoiDung)!;
      final nguoiDung = NguoiDung(
        maNguoiDung: cu.maNguoiDung,
        hoTen: thongTin.hoTen.trim(),
        gioiTinh: thongTin.gioiTinh,
        ngaySinh: thongTin.ngaySinh,
        soDienThoai: thongTin.soDienThoai.trim(),
        email: thongTin.email.trim(),
        diaChi: thongTin.diaChi.trim(),
      );
      _db.capNhatNguoiDung(
        nguoiDung,
        HoSoSucKhoe(
          maHoSo: hoSoCu.maHoSo,
          maNguoiDung: cu.maNguoiDung,
          chieuCao: thongTin.chieuCao,
          canNang: thongTin.canNang,
          nhomMau: thongTin.nhomMau,
          tienSuBenh: thongTin.tienSuBenh.trim(),
          diUng: thongTin.diUng.trim(),
          ngayCapNhat: DateTime.now(),
        ),
      );
      return _db.ghepHoSo(nguoiDung);
    });
    if (ketQua.isRight()) _bus.notify();
    return ketQua;
  }

  @override
  Future<Either<Failure, Unit>> xoa(String maNguoiDung) async {
    final ketQua = await chayMoPhong(() {
      _timNguoiDung(maNguoiDung);
      _db.xoaNguoiDung(maNguoiDung);
      return unit;
    });
    if (ketQua.isRight()) _bus.notify();
    return ketQua;
  }

  NguoiDung _timNguoiDung(String maNguoiDung) {
    final nguoiDung = _db.timNguoiDung(maNguoiDung);
    if (nguoiDung == null) {
      throw NotFoundFailure('Không tìm thấy hồ sơ $maNguoiDung.');
    }
    return nguoiDung;
  }
}
