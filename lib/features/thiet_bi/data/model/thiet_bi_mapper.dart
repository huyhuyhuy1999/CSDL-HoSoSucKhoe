import '../../domain/entity/thiet_bi.dart';

/// Danh sách cột của THIET_BI để chèn vào câu SELECT, với bí danh bảng [b].
String cotThietBi([String b = 'tb']) =>
    '$b.MaThietBi, $b.TenThietBi, $b.LoaiThietBi, $b.MaDinhDanh, '
    '$b.TrangThai, $b.MoTa';

/// Một dòng có các cột của THIET_BI → [ThietBi]. Trả về `null` khi dòng đến
/// từ LEFT JOIN mà không khớp thiết bị nào (lần đo nhập thủ công).
ThietBi? thietBiTuDong(Map<String, Object?> dong) {
  final ma = dong['MaThietBi'] as int?;
  final ten = dong['TenThietBi'] as String?;
  if (ma == null || ten == null) return null;

  return ThietBi(
    maThietBi: ma,
    tenThietBi: ten,
    loaiThietBi: LoaiThietBi.tuCsdl(dong['LoaiThietBi']! as String),
    maDinhDanh: dong['MaDinhDanh']! as String,
    trangThai: TrangThaiThietBi.tuCsdl(dong['TrangThai']! as String),
    moTa: dong['MoTa'] as String? ?? '',
  );
}
