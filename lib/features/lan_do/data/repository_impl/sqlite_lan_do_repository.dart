import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/database/truy_van.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/utils/data_refresh_bus.dart';
import '../../domain/entity/lan_do.dart';
import '../../domain/entity/loai_chi_so.dart';
import '../../domain/repository/lan_do_repository.dart';
import '../datasource/lan_do_sql.dart';
import '../model/loai_chi_so_mapper.dart';

/// LAN_DO, CHI_TIET_LAN_DO và LOAI_CHI_SO trên SQLite.
///
/// Câu lệnh tương đương bên SQL Server: `06_chi_so.sql`, `07_lan_do.sql` và
/// thủ tục `SP_ThemLanDo` trong `10_thong_ke.sql`.
@LazySingleton(as: LanDoRepository)
class SqliteLanDoRepository implements LanDoRepository {
  SqliteLanDoRepository(this._csdl, this._bus);

  final AppDatabase _csdl;
  final DataRefreshBus _bus;

  @override
  Future<Either<Failure, List<LoaiChiSo>>> layLoaiChiSo() {
    return chayTruyVan(() {
      final dong = _csdl.db.select(
        'SELECT ${cotLoaiChiSo()} FROM LOAI_CHI_SO AS l ORDER BY l.MaLoaiChiSo',
      );
      return [for (final d in dong) ?loaiChiSoTuDong(d)];
    });
  }

  @override
  Future<Either<Failure, List<LanDoDayDu>>> layLichSu({
    int? maNguoiDung,
    DateTime? tuNgay,
    DateTime? denNgay,
    NguonDuLieu? nguon,
    int? gioiHan,
  }) {
    return chayTruyVan(
      () => docLanDo(
        _csdl.db,
        // Ngày giờ lưu dạng chuỗi ISO nên so sánh chuỗi cũng là so sánh thời gian.
        dieuKien: '''
          (?1 IS NULL OR ld.MaNguoiDung = ?1)
          AND (?2 IS NULL OR ld.ThoiGianDo >= ?2)
          AND (?3 IS NULL OR ld.ThoiGianDo <= ?3)
          AND (?4 IS NULL OR ld.NguonDuLieu = ?4)
        ''',
        thamSo: [
          maNguoiDung,
          tuNgay == null ? null : sqlNgayGio(tuNgay),
          denNgay == null ? null : sqlNgayGio(denNgay),
          nguon?.giaTriCsdl,
        ],
        gioiHan: gioiHan,
      ),
    );
  }

  @override
  Future<Either<Failure, LanDoDayDu>> layChiTiet(int maLanDo) {
    return chayTruyVan(() => _docMot(maLanDo));
  }

  @override
  Future<Either<Failure, LanDoDayDu>> them({
    required int maNguoiDung,
    required DateTime thoiGianDo,
    required NguonDuLieu nguon,
    required Map<MaChiSo, double> giaTri,
    int? maThietBi,
    String ghiChu = '',
  }) async {
    final ketQua = await chayTruyVan(() {
      // Các quy tắc mà ràng buộc trên bảng không diễn đạt được (giống phần
      // kiểm tra đầu thủ tục SP_ThemLanDo).
      if (giaTri.isEmpty) {
        throw const ValidationFailure('Một lần đo phải có ít nhất một chỉ số.');
      }
      final tamThu = giaTri[MaChiSo.huyetApTamThu];
      final tamTruong = giaTri[MaChiSo.huyetApTamTruong];
      if ((tamThu == null) != (tamTruong == null)) {
        throw const ValidationFailure(
          'Huyết áp phải nhập đủ cả tâm thu và tâm trương.',
        );
      }
      if (tamThu != null && tamTruong != null && tamThu <= tamTruong) {
        throw const ValidationFailure(
          'Huyết áp tâm thu phải lớn hơn huyết áp tâm trương.',
        );
      }

      final db = _csdl.db;
      // Lần đo và các chỉ số của nó được ghi trong cùng một giao dịch. Giá trị
      // ngoài khoảng hợp lệ, thời gian ở tương lai hay khóa ngoại sai đều bị
      // ràng buộc / trigger của cơ sở dữ liệu từ chối và cả giao dịch bị hủy.
      final maLanDo = _csdl.giaoDich(() {
        db.execute(
          'INSERT INTO LAN_DO '
          '(MaNguoiDung, MaThietBi, NguonDuLieu, ThoiGianDo, GhiChu) '
          'VALUES (?, ?, ?, ?, ?)',
          [
            maNguoiDung,
            nguon == NguonDuLieu.thietBi ? maThietBi : null,
            nguon.giaTriCsdl,
            sqlNgayGio(thoiGianDo),
            rongThanhNull(ghiChu),
          ],
        );
        final ma = db.lastInsertRowId;

        // Chèn theo thứ tự chỉ số; trigger TRG_CHI_TIET_LAN_DO_CanhBao_Them
        // tự tạo cảnh báo cho giá trị ngoài khoảng bình thường.
        for (final chiSo in MaChiSo.values) {
          final v = giaTri[chiSo];
          if (v == null) continue;
          db.execute(
            'INSERT INTO CHI_TIET_LAN_DO (MaLanDo, MaLoaiChiSo, GiaTri) '
            'SELECT ?, MaLoaiChiSo, ? FROM LOAI_CHI_SO WHERE KyHieu = ?',
            [ma, v, chiSo.kyHieu],
          );
        }
        return ma;
      });

      return _docMot(maLanDo);
    });
    if (ketQua.isRight()) _bus.notify();
    return ketQua;
  }

  @override
  Future<Either<Failure, Unit>> xoa(int maLanDo) async {
    final ketQua = await chayTruyVan(() {
      // Giá trị đo và cảnh báo của lần đo bị xóa theo (ON DELETE CASCADE).
      _csdl.db.execute('DELETE FROM LAN_DO WHERE MaLanDo = ?', [maLanDo]);
      if (_csdl.db.updatedRows == 0) {
        throw NotFoundFailure('Không tìm thấy lần đo số $maLanDo.');
      }
      return unit;
    });
    if (ketQua.isRight()) _bus.notify();
    return ketQua;
  }

  LanDoDayDu _docMot(int maLanDo) {
    final ketQua = docLanDo(
      _csdl.db,
      dieuKien: 'ld.MaLanDo = ?',
      thamSo: [maLanDo],
    );
    if (ketQua.isEmpty) {
      throw NotFoundFailure('Không tìm thấy lần đo số $maLanDo.');
    }
    return ketQua.first;
  }
}
