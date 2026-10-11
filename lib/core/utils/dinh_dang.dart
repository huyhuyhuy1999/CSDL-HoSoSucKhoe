import 'package:intl/intl.dart';

/// Các hàm định dạng ngày giờ và số theo kiểu Việt Nam.
abstract final class DinhDang {
  static final _ngay = DateFormat('dd/MM/yyyy', 'vi');
  static final _ngayNgan = DateFormat('dd/MM', 'vi');
  static final _gio = DateFormat('HH:mm', 'vi');
  static final _thu = DateFormat('EEEE', 'vi');
  static final _thang = DateFormat("'Tháng' M, yyyy", 'vi');

  /// 11/10/2026
  static String ngay(DateTime d) => _ngay.format(d);

  /// 11/10
  static String ngayNgan(DateTime d) => _ngayNgan.format(d);

  /// 08:30
  static String gio(DateTime d) => _gio.format(d);

  /// 08:30 · 11/10/2026
  static String ngayGio(DateTime d) => '${_gio.format(d)} · ${_ngay.format(d)}';

  /// Tháng 10, 2026
  static String thang(DateTime d) => _thang.format(d);

  /// Chủ nhật, 11 tháng 10
  static String ngayDayDu(DateTime d) {
    final thu = _thu.format(d);
    final thuHoa = thu[0].toUpperCase() + thu.substring(1);
    return '$thuHoa, ${d.day} tháng ${d.month}';
  }

  /// Tiêu đề nhóm theo ngày: "Hôm nay", "Hôm qua" hoặc "Thứ sáu, 9 tháng 10".
  static String nhomNgay(DateTime d, {DateTime? hienTai}) {
    final now = hienTai ?? DateTime.now();
    final soNgay = _dauNgay(now).difference(_dauNgay(d)).inDays;
    if (soNgay == 0) return 'Hôm nay';
    if (soNgay == 1) return 'Hôm qua';
    return ngayDayDu(d);
  }

  /// "5 phút trước", "2 giờ trước", "3 ngày trước"…
  static String tuongDoi(DateTime d, {DateTime? hienTai}) {
    final now = hienTai ?? DateTime.now();
    final diff = now.difference(d);
    if (diff.inMinutes < 1) return 'Vừa xong';
    if (diff.inMinutes < 60) return '${diff.inMinutes} phút trước';
    if (diff.inHours < 24) return '${diff.inHours} giờ trước';
    if (diff.inDays < 7) return '${diff.inDays} ngày trước';
    return ngay(d);
  }

  /// Số với dấu phẩy thập phân kiểu Việt Nam: 36,8
  static String so(double value, {int thapPhan = 0}) {
    return value.toStringAsFixed(thapPhan).replaceAll('.', ',');
  }

  static DateTime _dauNgay(DateTime d) => DateTime(d.year, d.month, d.day);
}

extension DateTimeX on DateTime {
  /// 00:00 của ngày này.
  DateTime get dauNgay => DateTime(year, month, day);

  /// 23:59:59.999 của ngày này.
  DateTime get cuoiNgay => DateTime(year, month, day, 23, 59, 59, 999);

  bool cungNgay(DateTime other) =>
      year == other.year && month == other.month && day == other.day;
}
