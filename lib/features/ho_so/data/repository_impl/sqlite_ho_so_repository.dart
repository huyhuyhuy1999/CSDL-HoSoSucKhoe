import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/database/truy_van.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/utils/chuoi.dart';
import '../../../../core/utils/data_refresh_bus.dart';
import '../../../lan_do/data/datasource/lan_do_sql.dart';
import '../../domain/entity/ho_so_suc_khoe.dart';
import '../../domain/entity/nguoi_dung.dart';
import '../../domain/repository/ho_so_repository.dart';
import '../model/ho_so_mapper.dart';

/// NGUOI_DUNG và HO_SO_SUC_KHOE trên SQLite.
///
/// Câu lệnh tương đương bên SQL Server: `04_nguoi_dung.sql`,
/// `05_ho_so_suc_khoe.sql` và view `V_HO_SO_TONG_HOP` trong `10_thong_ke.sql`.
@LazySingleton(as: HoSoRepository)
class SqliteHoSoRepository implements HoSoRepository {
  SqliteHoSoRepository(this._csdl, this._bus);

  final AppDatabase _csdl;
  final DataRefreshBus _bus;

  @override
  Future<Either<Failure, List<HoSoTongHop>>> layDanhSach({
    String tuKhoa = '',
    GioiTinh? gioiTinh,
    NhomTuoi? nhomTuoi,
  }) {
    return chayTruyVan(() {
      // bo_dau() là hàm do ứng dụng đăng ký: tìm tên không phân biệt dấu.
      // Mỗi điều kiện lọc tự vô hiệu khi tham số của nó rỗng / NULL.
      final dong = _csdl.db.select(
        '''
        SELECT *
        FROM V_HO_SO_TONG_HOP
        WHERE MaHoSo IS NOT NULL
          AND (?1 = '' OR bo_dau(HoTen) LIKE '%' || bo_dau(?1) || '%')
          AND (?2 IS NULL OR GioiTinh = ?2)
          AND (?3 IS NULL OR Tuoi BETWEEN ?3 AND ?4)
        ''',
        [tuKhoa.trim(), gioiTinh?.nhan, nhomTuoi?.tuoiMin, nhomTuoi?.tuoiMax],
      );

      final ketQua = dong.map(_ghepHoSo).toList()
        ..sort(
          (a, b) =>
              _khoaSapXep(a.nguoiDung).compareTo(_khoaSapXep(b.nguoiDung)),
        );
      return ketQua;
    });
  }

  @override
  Future<Either<Failure, HoSoTongHop>> layChiTiet(int maNguoiDung) {
    return chayTruyVan(() => _docHoSo(maNguoiDung));
  }

  @override
  Future<Either<Failure, HoSoTongHop>> luu(
    ThongTinHoSo thongTin, {
    int? maNguoiDung,
  }) async {
    final ketQua = await chayTruyVan(() {
      final db = _csdl.db;
      final nguoiDung = [
        thongTin.hoTen.trim(),
        thongTin.gioiTinh.nhan,
        sqlNgay(thongTin.ngaySinh),
        // Cơ sở dữ liệu chỉ nhận số điện thoại toàn chữ số.
        rongThanhNull(thongTin.soDienThoai.replaceAll(RegExp(r'\D'), '')),
        rongThanhNull(thongTin.email),
        rongThanhNull(thongTin.diaChi),
      ];
      final hoSo = [
        thongTin.chieuCao,
        thongTin.canNang,
        thongTin.nhomMau,
        rongThanhNull(thongTin.tienSuBenh),
        rongThanhNull(thongTin.diUng),
      ];

      // Người dùng và hồ sơ được ghi trong cùng một giao dịch: nếu hồ sơ
      // vi phạm ràng buộc thì người dùng cũng không được lưu.
      final ma = _csdl.giaoDich(() {
        if (maNguoiDung == null) {
          db.execute(
            'INSERT INTO NGUOI_DUNG '
            '(HoTen, GioiTinh, NgaySinh, SoDienThoai, Email, DiaChi) '
            'VALUES (?, ?, ?, ?, ?, ?)',
            nguoiDung,
          );
          final maMoi = db.lastInsertRowId;
          db.execute(
            'INSERT INTO HO_SO_SUC_KHOE '
            '(MaNguoiDung, ChieuCao, CanNang, NhomMau, TienSuBenh, DiUng) '
            'VALUES (?, ?, ?, ?, ?, ?)',
            [maMoi, ...hoSo],
          );
          return maMoi;
        }

        db.execute(
          'UPDATE NGUOI_DUNG '
          'SET HoTen = ?, GioiTinh = ?, NgaySinh = ?, '
          '    SoDienThoai = ?, Email = ?, DiaChi = ? '
          'WHERE MaNguoiDung = ?',
          [...nguoiDung, maNguoiDung],
        );
        if (db.updatedRows == 0) {
          throw NotFoundFailure('Không tìm thấy người dùng số $maNguoiDung.');
        }
        // Không gán NgayCapNhat: trigger TRG_HO_SO_SUC_KHOE_NgayCapNhat tự ghi.
        db.execute(
          'UPDATE HO_SO_SUC_KHOE '
          'SET ChieuCao = ?, CanNang = ?, NhomMau = ?, TienSuBenh = ?, DiUng = ? '
          'WHERE MaNguoiDung = ?',
          [...hoSo, maNguoiDung],
        );
        return maNguoiDung;
      });

      return _docHoSo(ma);
    });
    if (ketQua.isRight()) _bus.notify();
    return ketQua;
  }

  @override
  Future<Either<Failure, Unit>> xoa(int maNguoiDung) async {
    final ketQua = await chayTruyVan(() {
      // Hồ sơ, lần đo, giá trị đo và cảnh báo của người này bị xóa theo
      // nhờ các khóa ngoại ON DELETE CASCADE.
      _csdl.db.execute('DELETE FROM NGUOI_DUNG WHERE MaNguoiDung = ?', [
        maNguoiDung,
      ]);
      if (_csdl.db.updatedRows == 0) {
        throw NotFoundFailure('Không tìm thấy người dùng số $maNguoiDung.');
      }
      return unit;
    });
    if (ketQua.isRight()) _bus.notify();
    return ketQua;
  }

  HoSoTongHop _docHoSo(int maNguoiDung) {
    final dong = _csdl.db.select(
      'SELECT * FROM V_HO_SO_TONG_HOP '
      'WHERE MaNguoiDung = ? AND MaHoSo IS NOT NULL',
      [maNguoiDung],
    );
    if (dong.isEmpty) {
      throw NotFoundFailure(
        'Không tìm thấy hồ sơ của người dùng số $maNguoiDung.',
      );
    }
    return _ghepHoSo(dong.first);
  }

  /// Một dòng của view V_HO_SO_TONG_HOP → [HoSoTongHop], kèm lần đo gần nhất.
  HoSoTongHop _ghepHoSo(Map<String, Object?> dong) {
    final lanDoGanNhat = docLanDo(
      _csdl.db,
      dieuKien: 'ld.MaNguoiDung = ?',
      thamSo: [dong['MaNguoiDung']],
      gioiHan: 1,
    );
    return HoSoTongHop(
      nguoiDung: nguoiDungTuDong(dong),
      hoSo: hoSoTuDong(dong),
      soLanDo: dong['SoLanDo']! as int,
      soCanhBaoChuaXem: dong['SoCanhBaoChuaXem']! as int,
      lanDoGanNhat: lanDoGanNhat.isEmpty ? null : lanDoGanNhat.first,
    );
  }

  /// Danh sách tiếng Việt xếp theo tên (từ cuối cùng) trước, rồi tới họ đệm.
  String _khoaSapXep(NguoiDung nguoiDung) {
    final hoTen = boDau(nguoiDung.hoTen.trim());
    final ten = hoTen.split(RegExp(r'\s+')).last;
    return '$ten $hoTen';
  }
}
