import 'package:dartz/dartz.dart';
import 'package:sqlite3/sqlite3.dart';

import '../error/failures.dart';

/// Chạy một truy vấn trên cơ sở dữ liệu và bọc kết quả trong `Either`:
/// lỗi ràng buộc của SQLite được đổi thành [Failure] có thông báo tiếng Việt.
Future<Either<Failure, T>> chayTruyVan<T>(T Function() truyVan) async {
  try {
    return Right(truyVan());
  } on Failure catch (failure) {
    return Left(failure);
  } on SqliteException catch (e) {
    return Left(loiTuSqlite(e));
  } catch (_) {
    return const Left(UnexpectedFailure());
  }
}

/// Mã lỗi mở rộng của SQLite khi một trigger gọi RAISE(ABORT, ...).
const int _sqliteConstraintTrigger = 1811;

/// Mã lỗi chung của mọi vi phạm ràng buộc.
const int _sqliteConstraint = 19;

/// Thông báo cho từng ràng buộc. Khóa là tên ràng buộc (với CHECK) hoặc
/// `BẢNG.CỘT` (với UNIQUE), đúng như SQLite ghi trong thông báo lỗi.
const Map<String, String> _thongBaoRangBuoc = {
  'CK_NGUOI_DUNG_HoTen': 'Họ và tên phải có ít nhất 2 ký tự.',
  'CK_NGUOI_DUNG_GioiTinh': 'Giới tính không hợp lệ.',
  'CK_NGUOI_DUNG_NgaySinh': 'Ngày sinh không hợp lệ.',
  'CK_NGUOI_DUNG_SoDienThoai': 'Số điện thoại phải gồm 9 đến 12 chữ số.',
  'CK_NGUOI_DUNG_Email': 'Email không đúng định dạng.',
  'NGUOI_DUNG.Email': 'Email này đã được dùng cho một người khác.',
  'CK_HO_SO_SUC_KHOE_ChieuCao': 'Chiều cao phải từ 30 đến 250 cm.',
  'CK_HO_SO_SUC_KHOE_CanNang': 'Cân nặng phải từ 1 đến 300 kg.',
  'CK_HO_SO_SUC_KHOE_NhomMau': 'Nhóm máu không hợp lệ.',
  'HO_SO_SUC_KHOE.MaNguoiDung': 'Người này đã có hồ sơ sức khỏe.',
  'THIET_BI.MaDinhDanh': 'Mã định danh thiết bị đã tồn tại.',
  'CK_THIET_BI_TrangThai': 'Trạng thái thiết bị không hợp lệ.',
  'CK_LAN_DO_NguonKhopThietBi':
      'Lần đo bằng thiết bị phải chọn thiết bị; lần đo thủ công thì không.',
  'CHI_TIET_LAN_DO.MaLanDo': 'Chỉ số này đã có trong lần đo.',
  'FOREIGN KEY constraint failed': 'Bản ghi được tham chiếu không tồn tại, hoặc bản ghi này đang được dùng ở nơi khác.',
};

Failure loiTuSqlite(SqliteException e) {
  // Thông báo trong RAISE(ABORT, ...) của trigger đã là tiếng Việt.
  if (e.extendedResultCode == _sqliteConstraintTrigger) {
    return ValidationFailure(e.message);
  }
  for (final muc in _thongBaoRangBuoc.entries) {
    if (e.message.contains(muc.key)) return ValidationFailure(muc.value);
  }
  if (e.resultCode == _sqliteConstraint) {
    return const ValidationFailure(
      'Dữ liệu vi phạm ràng buộc của cơ sở dữ liệu.',
    );
  }
  return const UnexpectedFailure();
}

/// 'YYYY-MM-DD HH:MM:SS' theo giờ địa phương — dạng lưu ngày giờ trong SQLite.
String sqlNgayGio(DateTime d) {
  return '${sqlNgay(d)} ${_hai(d.hour)}:${_hai(d.minute)}:${_hai(d.second)}';
}

/// 'YYYY-MM-DD'.
String sqlNgay(DateTime d) => '${d.year}-${_hai(d.month)}-${_hai(d.day)}';

/// Đọc ngày giờ lưu trong SQLite thành [DateTime] giờ địa phương.
DateTime docNgayGio(String giaTri) => DateTime.parse(giaTri);

String _hai(int n) => n.toString().padLeft(2, '0');

/// Chuỗi rỗng coi như không có giá trị (NULL).
String? rongThanhNull(String giaTri) {
  final gon = giaTri.trim();
  return gon.isEmpty ? null : gon;
}
