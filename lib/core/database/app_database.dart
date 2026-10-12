import 'dart:io';

import 'package:flutter/services.dart' show rootBundle;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3/sqlite3.dart';

import '../utils/chuoi.dart';

/// Các script tạo cơ sở dữ liệu, chạy theo đúng thứ tự này (trigger phải có
/// trước dữ liệu mẫu để cảnh báo được sinh ra).
const List<String> scriptTaoCsdl = [
  'sql/sqlite/01_tao_bang.sql',
  'sql/sqlite/02_trigger.sql',
  'sql/sqlite/03_du_lieu_mau.sql',
  'sql/sqlite/04_view.sql',
];

/// Tăng số này khi cấu trúc bảng thay đổi; cơ sở dữ liệu cũ sẽ được tạo lại.
const int phienBanLuocDo = 1;

/// Tên bảng theo thứ tự hiển thị trong màn hình thông tin cơ sở dữ liệu.
const List<String> danhSachBang = [
  'NGUOI_DUNG',
  'HO_SO_SUC_KHOE',
  'THIET_BI',
  'LOAI_CHI_SO',
  'LAN_DO',
  'CHI_TIET_LAN_DO',
  'CANH_BAO',
];

/// Cơ sở dữ liệu SQLite nhúng trong ứng dụng.
///
/// Lần mở đầu tiên, các script trong `sql/sqlite/` tạo bảng, trigger, view và
/// nạp dữ liệu mẫu. Các repository chỉ làm việc với cơ sở dữ liệu qua [db].
class AppDatabase {
  AppDatabase._(this._db, this._scripts, this._duongDan);

  /// Mở cơ sở dữ liệu của ứng dụng; script lấy từ asset.
  ///
  /// [trongBoNho] dùng cho kiểm thử: không ghi file, mất khi đóng app.
  static Future<AppDatabase> mo({bool trongBoNho = false}) async {
    final scripts = [
      for (final file in scriptTaoCsdl) await rootBundle.loadString(file),
    ];
    String? duongDan;
    if (!trongBoNho) {
      final thuMuc = await getApplicationSupportDirectory();
      duongDan = p.join(thuMuc.path, 'ho_so_suc_khoe.db');
    }
    return AppDatabase.tuScript(scripts, duongDan: duongDan);
  }

  /// Mở cơ sở dữ liệu từ nội dung script cho sẵn. [duongDan] là `null` thì
  /// cơ sở dữ liệu nằm trong bộ nhớ.
  factory AppDatabase.tuScript(List<String> scripts, {String? duongDan}) {
    final csdl = AppDatabase._(_moKetNoi(duongDan), scripts, duongDan);
    csdl._khoiTaoNeuCan();
    return csdl;
  }

  Database _db;
  final List<String> _scripts;
  final String? _duongDan;

  /// Kết nối hiện tại. Không giữ lại tham chiếu này lâu dài: [datLai] sẽ thay
  /// nó bằng kết nối mới.
  Database get db => _db;

  static Database _moKetNoi(String? duongDan) {
    final db = duongDan == null
        ? sqlite3.openInMemory()
        : sqlite3.open(duongDan);

    // SQLite mặc định KHÔNG kiểm tra khóa ngoại; phải bật cho từng kết nối.
    db.execute('PRAGMA foreign_keys = ON;');

    // Hàm SQL bo_dau(chuỗi): bỏ dấu tiếng Việt để tìm kiếm không phân biệt dấu,
    // tương đương COLLATE Latin1_General_CI_AI bên SQL Server.
    db.createFunction(
      functionName: 'bo_dau',
      argumentCount: const AllowedArgumentCount(1),
      deterministic: true,
      function: (args) {
        final giaTri = args[0];
        return giaTri == null ? null : boDau(giaTri.toString());
      },
    );
    return db;
  }

  void _khoiTaoNeuCan() {
    final phienBan =
        _db.select('PRAGMA user_version').first.values.first as int;
    if (phienBan == phienBanLuocDo) return;

    // Cơ sở dữ liệu từ phiên bản cũ: bỏ đi và tạo lại từ đầu.
    if (phienBan != 0) {
      _dongVaXoaFile();
      _db = _moKetNoi(_duongDan);
    }

    giaoDich(() {
      for (final script in _scripts) {
        _db.execute(script);
      }
      _dichDuLieuMauVeHienTai();
    });
    _db.execute('PRAGMA user_version = $phienBanLuocDo;');
  }

  /// Dữ liệu mẫu có mốc ngày cố định (để kết quả trong tài liệu không đổi).
  /// Trong app, dịch toàn bộ mốc thời gian sao cho ngày cuối của dữ liệu mẫu
  /// trùng với hôm nay — nhờ đó Tổng quan và Lịch sử luôn có số liệu gần đây.
  void _dichDuLieuMauVeHienTai() {
    final ngayCuoi =
        _db
                .select('SELECT MAX(date(ThoiGianDo)) AS Ngay FROM LAN_DO')
                .first['Ngay']
            as String?;
    if (ngayCuoi == null) return;

    final now = DateTime.now();
    final homNay = DateTime(now.year, now.month, now.day);
    final soNgay = homNay.difference(DateTime.parse(ngayCuoi)).inDays;
    if (soNgay == 0) return;

    String dich(int n) => "'${n >= 0 ? '+' : ''}$n days'";

    // Lần đo nào sau khi dịch mà rơi vào tương lai (muộn hơn giờ hiện tại của
    // hôm nay) thì lùi về hôm qua, vì không thể có lần đo ở tương lai.
    _db.execute('''
      UPDATE LAN_DO
      SET ThoiGianDo = CASE
          WHEN datetime(ThoiGianDo, ${dich(soNgay)}) <= datetime('now', 'localtime')
          THEN datetime(ThoiGianDo, ${dich(soNgay)})
          ELSE datetime(ThoiGianDo, ${dich(soNgay - 1)})
      END;

      UPDATE CANH_BAO
      SET ThoiGianTao = (SELECT ld.ThoiGianDo FROM LAN_DO AS ld
                         WHERE ld.MaLanDo = CANH_BAO.MaLanDo);

      UPDATE HO_SO_SUC_KHOE SET NgayCapNhat = datetime(NgayCapNhat, ${dich(soNgay)});
      UPDATE NGUOI_DUNG     SET NgayTao     = datetime(NgayTao, ${dich(soNgay)});
    ''');
  }

  /// Chạy [hanhDong] trong một giao dịch: thành công thì COMMIT, có lỗi thì
  /// ROLLBACK toàn bộ rồi ném lại lỗi.
  T giaoDich<T>(T Function() hanhDong) {
    _db.execute('BEGIN;');
    try {
      final ketQua = hanhDong();
      _db.execute('COMMIT;');
      return ketQua;
    } catch (_) {
      _db.execute('ROLLBACK;');
      rethrow;
    }
  }

  /// Số dòng hiện có của từng bảng.
  Map<String, int> demSoDong() {
    return {
      for (final bang in danhSachBang)
        bang: _db.select('SELECT COUNT(*) AS n FROM $bang').first['n'] as int,
    };
  }

  /// Xóa toàn bộ dữ liệu và nạp lại dữ liệu mẫu ban đầu.
  void datLai() {
    _dongVaXoaFile();
    _db = _moKetNoi(_duongDan);
    _khoiTaoNeuCan();
  }

  void _dongVaXoaFile() {
    _db.close();
    final duongDan = _duongDan;
    if (duongDan == null) return;
    final file = File(duongDan);
    if (file.existsSync()) file.deleteSync();
  }

  void dong() => _db.close();
}
