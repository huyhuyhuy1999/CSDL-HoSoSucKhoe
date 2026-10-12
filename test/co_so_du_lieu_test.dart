import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:ho_so_suc_khoe/core/database/app_database.dart';
import 'package:ho_so_suc_khoe/core/database/truy_van.dart';
import 'package:ho_so_suc_khoe/core/error/failures.dart';
import 'package:ho_so_suc_khoe/core/utils/chuoi.dart';
import 'package:sqlite3/sqlite3.dart';

/// Kiểm thử cơ sở dữ liệu SQLite của ứng dụng: ràng buộc, trigger, view.
///
/// Mỗi test mở một cơ sở dữ liệu mới trong bộ nhớ từ các script ở
/// `sql/sqlite/`, nên các test không ảnh hưởng lẫn nhau. Các ca ở đây tương
/// ứng với `sql/sqlserver/11_kiem_thu.sql` bên SQL Server.
void main() {
  late AppDatabase csdl;
  late Database db;

  setUp(() {
    csdl = AppDatabase.tuScript([
      for (final file in scriptTaoCsdl) File(file).readAsStringSync(),
    ]);
    db = csdl.db;
  });

  tearDown(() => csdl.dong());

  int dem(String sql, [List<Object?> thamSo = const []]) =>
      db.select(sql, thamSo).first.values.first! as int;

  /// Lệnh phải bị cơ sở dữ liệu từ chối; trả về thông báo đã đổi sang tiếng Việt.
  String biTuChoi(String sql, [List<Object?> thamSo = const []]) {
    try {
      db.execute(sql, thamSo);
    } on SqliteException catch (e) {
      return loiTuSqlite(e).message;
    }
    fail('Lệnh đáng lẽ phải bị từ chối nhưng đã chạy thành công:\n$sql');
  }

  group('boDau', () {
    test('bỏ dấu tiếng Việt và chuyển về chữ thường', () {
      expect(boDau('Nguyễn Đức Ánh'), 'nguyen duc anh');
      expect(boDau('Dương Văn Nam'), 'duong van nam');
    });

    test('hàm SQL bo_dau dùng được trong truy vấn', () {
      expect(
        dem("SELECT COUNT(*) FROM NGUOI_DUNG WHERE bo_dau(HoTen) LIKE '%duc%'"),
        1,
      );
      expect(
        dem("SELECT COUNT(*) FROM NGUOI_DUNG WHERE bo_dau(HoTen) LIKE '%thi%'"),
        6,
      );
    });
  });

  group('Dữ liệu mẫu', () {
    test('đủ số dòng ở cả 7 bảng', () {
      expect(csdl.demSoDong(), {
        'NGUOI_DUNG': 12,
        'HO_SO_SUC_KHOE': 12,
        'THIET_BI': 6,
        'LOAI_CHI_SO': 5,
        'LAN_DO': 265,
        'CHI_TIET_LAN_DO': 1110,
        'CANH_BAO': 108,
      });
    });

    test('được dịch về hiện tại: lần đo cuối là hôm nay hoặc hôm qua', () {
      final cuoi = docNgayGio(
        db.select('SELECT MAX(ThoiGianDo) AS t FROM LAN_DO').first['t']!
            as String,
      );
      final now = DateTime.now();
      expect(cuoi.isAfter(now), isFalse);
      expect(now.difference(cuoi).inHours, lessThan(48));
    });

    test('thời điểm cảnh báo vẫn trùng thời gian đo sau khi dịch', () {
      expect(
        dem('''
          SELECT COUNT(*) FROM CANH_BAO AS cb
          JOIN LAN_DO AS ld ON ld.MaLanDo = cb.MaLanDo
          WHERE cb.ThoiGianTao <> ld.ThoiGianDo
        '''),
        0,
      );
    });

    test('đặt lại dữ liệu mẫu khôi phục trạng thái ban đầu', () {
      db.execute('DELETE FROM NGUOI_DUNG WHERE MaNguoiDung = 1');
      expect(csdl.demSoDong()['NGUOI_DUNG'], 11);

      csdl.datLai();

      expect(csdl.demSoDong()['NGUOI_DUNG'], 12);
      expect(csdl.demSoDong()['LAN_DO'], 265);
    });
  });

  group('Khóa chính và ràng buộc duy nhất', () {
    test('trùng khóa chính kép của CHI_TIET_LAN_DO bị từ chối', () {
      expect(
        biTuChoi(
          'INSERT INTO CHI_TIET_LAN_DO (MaLanDo, MaLoaiChiSo, GiaTri) '
          'VALUES (260, 2, 80)',
        ),
        'Chỉ số này đã có trong lần đo.',
      );
    });

    test('một người không thể có hai hồ sơ', () {
      expect(
        biTuChoi(
          'INSERT INTO HO_SO_SUC_KHOE (MaNguoiDung, ChieuCao, CanNang, NhomMau) '
          "VALUES (1, 170, 65, 'O+')",
        ),
        'Người này đã có hồ sơ sức khỏe.',
      );
    });

    test('email không được trùng, nhưng nhiều người có thể không có email', () {
      expect(
        biTuChoi(
          'INSERT INTO NGUOI_DUNG (HoTen, GioiTinh, NgaySinh, Email) '
          "VALUES ('Người Trùng Email', 'Nữ', '1995-05-05', 'an.nguyen@example.com')",
        ),
        'Email này đã được dùng cho một người khác.',
      );

      db.execute(
        'INSERT INTO NGUOI_DUNG (HoTen, GioiTinh, NgaySinh) '
        "VALUES ('Không Email Một', 'Nam', '1990-01-01'), "
        "       ('Không Email Hai', 'Nữ', '1991-02-02')",
      );
      expect(dem('SELECT COUNT(*) FROM NGUOI_DUNG WHERE Email IS NULL'), 3);
    });

    test('mã định danh thiết bị không được trùng', () {
      expect(
        biTuChoi(
          'INSERT INTO THIET_BI (TenThietBi, LoaiThietBi, MaDinhDanh) '
          "VALUES ('ESP32 giả mạo', 'Thiết bị đa chỉ số', 'ESP32-A4:CF:12:9B:7E:01')",
        ),
        'Mã định danh thiết bị đã tồn tại.',
      );
    });
  });

  group('Khóa ngoại', () {
    const loiKhoaNgoai =
        'Bản ghi được tham chiếu không tồn tại, hoặc bản ghi này đang được dùng ở nơi khác.';

    test('không thêm được lần đo cho người dùng không tồn tại', () {
      expect(
        biTuChoi(
          "INSERT INTO LAN_DO (MaNguoiDung, NguonDuLieu) VALUES (9999, 'Thủ công')",
        ),
        loiKhoaNgoai,
      );
    });

    test('không thêm được giá trị đo cho loại chỉ số không tồn tại', () {
      expect(
        biTuChoi(
          'INSERT INTO CHI_TIET_LAN_DO (MaLanDo, MaLoaiChiSo, GiaTri) '
          'VALUES (260, 99, 50)',
        ),
        loiKhoaNgoai,
      );
    });

    test('không xóa được thiết bị đã có lần đo', () {
      expect(
        biTuChoi('DELETE FROM THIET_BI WHERE MaThietBi = 1'),
        loiKhoaNgoai,
      );
    });

    test('xóa được thiết bị chưa có lần đo nào', () {
      db.execute('DELETE FROM THIET_BI WHERE MaThietBi = 6');
      expect(csdl.demSoDong()['THIET_BI'], 5);
    });
  });

  group('Xóa dây chuyền', () {
    test('xóa người dùng kéo theo hồ sơ, lần đo, giá trị đo và cảnh báo', () {
      db.execute('DELETE FROM NGUOI_DUNG WHERE MaNguoiDung = 12');

      expect(
        dem('SELECT COUNT(*) FROM HO_SO_SUC_KHOE WHERE MaNguoiDung = 12'),
        0,
      );
      expect(dem('SELECT COUNT(*) FROM LAN_DO WHERE MaNguoiDung = 12'), 0);
      expect(csdl.demSoDong()['LAN_DO'], 250);
      expect(
        dem('''
          SELECT COUNT(*) FROM CHI_TIET_LAN_DO AS ct
          WHERE NOT EXISTS (SELECT 1 FROM LAN_DO AS ld WHERE ld.MaLanDo = ct.MaLanDo)
        '''),
        0,
      );
    });

    test('xóa lần đo kéo theo giá trị đo và cảnh báo của nó', () {
      expect(dem('SELECT COUNT(*) FROM CANH_BAO WHERE MaLanDo = 260'), 3);

      db.execute('DELETE FROM LAN_DO WHERE MaLanDo = 260');

      expect(
        dem('SELECT COUNT(*) FROM CHI_TIET_LAN_DO WHERE MaLanDo = 260'),
        0,
      );
      expect(dem('SELECT COUNT(*) FROM CANH_BAO WHERE MaLanDo = 260'), 0);
    });
  });

  group('Dữ liệu không hợp lệ', () {
    test('giới tính ngoài danh sách', () {
      expect(
        biTuChoi(
          'INSERT INTO NGUOI_DUNG (HoTen, GioiTinh, NgaySinh) '
          "VALUES ('Lê Văn Sai', 'Male', '1990-01-01')",
        ),
        'Giới tính không hợp lệ.',
      );
    });

    test('ngày sinh ở tương lai', () {
      expect(
        biTuChoi(
          'INSERT INTO NGUOI_DUNG (HoTen, GioiTinh, NgaySinh) '
          "VALUES ('Lê Văn Sai', 'Nam', '2999-01-01')",
        ),
        'Ngày sinh không được ở tương lai.',
      );
    });

    test('số điện thoại có chữ cái', () {
      expect(
        biTuChoi(
          'INSERT INTO NGUOI_DUNG (HoTen, GioiTinh, NgaySinh, SoDienThoai) '
          "VALUES ('Lê Văn Sai', 'Nam', '1990-01-01', '09ABC12345')",
        ),
        'Số điện thoại phải gồm 9 đến 12 chữ số.',
      );
    });

    test('chiều cao, cân nặng, nhóm máu ngoài miền giá trị', () {
      expect(
        biTuChoi(
          'UPDATE HO_SO_SUC_KHOE SET ChieuCao = 0 WHERE MaNguoiDung = 1',
        ),
        'Chiều cao phải từ 30 đến 250 cm.',
      );
      expect(
        biTuChoi(
          'UPDATE HO_SO_SUC_KHOE SET CanNang = -5 WHERE MaNguoiDung = 1',
        ),
        'Cân nặng phải từ 1 đến 300 kg.',
      );
      expect(
        biTuChoi(
          "UPDATE HO_SO_SUC_KHOE SET NhomMau = 'C+' WHERE MaNguoiDung = 1",
        ),
        'Nhóm máu không hợp lệ.',
      );
    });

    test('nguồn dữ liệu và thiết bị phải khớp nhau', () {
      const thongBao =
          'Lần đo bằng thiết bị phải chọn thiết bị; lần đo thủ công thì không.';
      expect(
        biTuChoi(
          'INSERT INTO LAN_DO (MaNguoiDung, MaThietBi, NguonDuLieu) '
          "VALUES (1, NULL, 'Thiết bị')",
        ),
        thongBao,
      );
      expect(
        biTuChoi(
          'INSERT INTO LAN_DO (MaNguoiDung, MaThietBi, NguonDuLieu) '
          "VALUES (1, 1, 'Thủ công')",
        ),
        thongBao,
      );
    });

    test('thời gian đo ở tương lai', () {
      expect(
        biTuChoi(
          'INSERT INTO LAN_DO (MaNguoiDung, NguonDuLieu, ThoiGianDo) '
          "VALUES (1, 'Thủ công', datetime('now', 'localtime', '+1 day'))",
        ),
        'Thời gian đo không được ở tương lai.',
      );
    });
  });

  group('Trigger cảnh báo', () {
    int themLanDo(Map<int, double> giaTri) {
      db.execute(
        "INSERT INTO LAN_DO (MaNguoiDung, NguonDuLieu) VALUES (1, 'Thủ công')",
      );
      final ma = db.lastInsertRowId;
      for (final e in giaTri.entries) {
        db.execute(
          'INSERT INTO CHI_TIET_LAN_DO (MaLanDo, MaLoaiChiSo, GiaTri) '
          'VALUES (?, ?, ?)',
          [ma, e.key, e.value],
        );
      }
      return ma;
    }

    test('giá trị ngoài khoảng hợp lệ bị từ chối', () {
      expect(
        biTuChoi(
          'UPDATE CHI_TIET_LAN_DO SET GiaTri = 400 '
          'WHERE MaLanDo = 260 AND MaLoaiChiSo = 2',
        ),
        'Giá trị đo nằm ngoài khoảng hợp lệ của chỉ số.',
      );
    });

    test('tự tạo cảnh báo đúng mức độ cho giá trị bất thường', () {
      // Nhiệt độ bình thường, nhịp tim 135 nguy hiểm, SpO2 93 cần chú ý.
      final ma = themLanDo({1: 36.8, 2: 135, 3: 93});

      final canhBao = db.select(
        'SELECT MaLoaiChiSo, MucDo, NoiDung FROM CANH_BAO '
        'WHERE MaLanDo = ? ORDER BY MaLoaiChiSo',
        [ma],
      );
      expect(canhBao, hasLength(2));
      expect(canhBao[0]['MucDo'], 'Nguy hiểm');
      expect(
        canhBao[0]['NoiDung'],
        'Nhịp tim 135 bpm cao hơn khoảng bình thường (60 – 100 bpm).',
      );
      expect(canhBao[1]['MucDo'], 'Cần chú ý');
      expect(
        canhBao[1]['NoiDung'],
        'SpO2 93 % thấp hơn khoảng bình thường (95 – 100 %).',
      );
    });

    test('lần đo toàn giá trị bình thường không sinh cảnh báo', () {
      final ma = themLanDo({1: 36.8, 2: 75, 3: 98, 4: 118, 5: 76});
      expect(dem('SELECT COUNT(*) FROM CANH_BAO WHERE MaLanDo = ?', [ma]), 0);
    });

    test('giá trị ở đúng biên khoảng bình thường không sinh cảnh báo', () {
      final ma = themLanDo({2: 100, 3: 95});
      expect(dem('SELECT COUNT(*) FROM CANH_BAO WHERE MaLanDo = ?', [ma]), 0);
    });

    test('sửa giá trị về bình thường thì cảnh báo biến mất', () {
      db.execute(
        'UPDATE CHI_TIET_LAN_DO SET GiaTri = 88 '
        'WHERE MaLanDo = 260 AND MaLoaiChiSo = 2',
      );
      expect(
        dem(
          'SELECT COUNT(*) FROM CANH_BAO WHERE MaLanDo = 260 AND MaLoaiChiSo = 2',
        ),
        0,
      );
      expect(dem('SELECT COUNT(*) FROM CANH_BAO WHERE MaLanDo = 260'), 2);
    });

    test('sửa giá trị sang bất thường thì cảnh báo được tạo', () {
      db.execute(
        'UPDATE CHI_TIET_LAN_DO SET GiaTri = 91 '
        'WHERE MaLanDo = 260 AND MaLoaiChiSo = 3',
      );
      expect(
        dem(
          'SELECT COUNT(*) FROM CANH_BAO '
          "WHERE MaLanDo = 260 AND MaLoaiChiSo = 3 AND MucDo = 'Cần chú ý'",
        ),
        1,
      );
    });

    test('số cảnh báo luôn bằng số giá trị ngoài khoảng bình thường', () {
      expect(
        dem('SELECT COUNT(*) FROM V_CHI_TIET_DANH_GIA WHERE CapDo > 0'),
        csdl.demSoDong()['CANH_BAO'],
      );
    });
  });

  group('Trigger ngày cập nhật hồ sơ', () {
    test('sửa hồ sơ thì NgayCapNhat được ghi lại là hôm nay', () {
      db.execute(
        'UPDATE HO_SO_SUC_KHOE SET CanNang = 73 WHERE MaNguoiDung = 1',
      );

      final ngay =
          db
                  .select(
                    'SELECT date(NgayCapNhat) AS d FROM HO_SO_SUC_KHOE WHERE MaNguoiDung = 1',
                  )
                  .first['d']
              as String;
      expect(ngay, sqlNgay(DateTime.now()));
    });
  });

  group('View và thống kê', () {
    test('V_LAN_DO_TONG_HOP có đúng một dòng cho mỗi lần đo', () {
      expect(dem('SELECT COUNT(*) FROM V_LAN_DO_TONG_HOP'), 265);
    });

    test(
      'ba mức độ của lần đo: 179 bình thường, 72 cần chú ý, 14 nguy hiểm',
      () {
        final phanBo = {
          for (final d in db.select(
            'SELECT MucDo, COUNT(*) AS n FROM V_LAN_DO_TONG_HOP GROUP BY MucDo',
          ))
            d['MucDo']: d['n'],
        };
        expect(phanBo, {'Bình thường': 179, 'Cần chú ý': 72, 'Nguy hiểm': 14});
      },
    );

    test('tổng SoLanDo trong V_HO_SO_TONG_HOP bằng tổng số lần đo', () {
      expect(dem('SELECT SUM(SoLanDo) FROM V_HO_SO_TONG_HOP'), 265);
    });

    test('HAVING: 5 người có từ 25 lần đo trở lên', () {
      expect(
        dem('''
          SELECT COUNT(*) FROM (
            SELECT MaNguoiDung FROM LAN_DO GROUP BY MaNguoiDung HAVING COUNT(*) >= 25
          )
        '''),
        5,
      );
    });

    test(
      'nhịp tim trung bình 80,5; tâm thu cao nhất 148; SpO2 thấp nhất 92',
      () {
        final d = db.select('''
        SELECT
          (SELECT ROUND(AVG(GiaTri), 1) FROM CHI_TIET_LAN_DO WHERE MaLoaiChiSo = 2) AS NhipTim,
          (SELECT MAX(GiaTri) FROM CHI_TIET_LAN_DO WHERE MaLoaiChiSo = 4)           AS TamThu,
          (SELECT MIN(GiaTri) FROM CHI_TIET_LAN_DO WHERE MaLoaiChiSo = 3)           AS SpO2
      ''').first;
        expect(d['NhipTim'], 80.5);
        expect(d['TamThu'], 148.0);
        expect(d['SpO2'], 92.0);
      },
    );
  });

  group('chayTruyVan', () {
    test('đổi lỗi ràng buộc thành ValidationFailure tiếng Việt', () async {
      final ketQua = await chayTruyVan(
        () => db.execute(
          'UPDATE HO_SO_SUC_KHOE SET ChieuCao = 0 WHERE MaNguoiDung = 1',
        ),
      );

      expect(ketQua.isLeft(), isTrue);
      ketQua.fold((failure) {
        expect(failure, isA<ValidationFailure>());
        expect(failure.message, 'Chiều cao phải từ 30 đến 250 cm.');
      }, (_) => fail('phải trả về lỗi'));
    });

    test('giao dịch bị hủy toàn bộ khi một lệnh trong đó lỗi', () {
      expect(
        () => csdl.giaoDich(() {
          db.execute(
            "INSERT INTO LAN_DO (MaNguoiDung, NguonDuLieu) VALUES (1, 'Thủ công')",
          );
          db.execute(
            'INSERT INTO CHI_TIET_LAN_DO (MaLanDo, MaLoaiChiSo, GiaTri) '
            'VALUES (?, 2, 999)',
            [db.lastInsertRowId],
          );
        }),
        throwsA(isA<SqliteException>()),
      );
      expect(csdl.demSoDong()['LAN_DO'], 265);
    });
  });
}
