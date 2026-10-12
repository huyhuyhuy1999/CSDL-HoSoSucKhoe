import 'package:sqlite3/sqlite3.dart';

import '../../../../core/database/truy_van.dart';
import '../../../ho_so/data/model/ho_so_mapper.dart';
import '../../../thiet_bi/data/model/thiet_bi_mapper.dart';
import '../../domain/entity/lan_do.dart';
import '../model/loai_chi_so_mapper.dart';

/// Đọc các lần đo đã ghép đủ người được đo, thiết bị và từng chỉ số.
///
/// Dùng chung cho mọi repository cần hiển thị lần đo (lịch sử, hồ sơ, tổng quan).
/// [dieuKien] là biểu thức sau WHERE, tham chiếu các bí danh `ld` (LAN_DO),
/// `nd` (NGUOI_DUNG) và `tb` (THIET_BI); kết quả luôn sắp mới nhất trước.
List<LanDoDayDu> docLanDo(
  Database db, {
  String dieuKien = '1 = 1',
  List<Object?> thamSo = const [],
  int? gioiHan,
}) {
  // Truy vấn 1: lần đo JOIN người dùng, LEFT JOIN thiết bị (lần đo thủ công
  // không có thiết bị).
  final cacLanDo = db.select('''
    SELECT ld.MaLanDo, ld.NguonDuLieu, ld.ThoiGianDo, ld.GhiChu,
           ${cotNguoiDung()}, ${cotThietBi()}
    FROM LAN_DO        AS ld
    JOIN NGUOI_DUNG    AS nd ON nd.MaNguoiDung = ld.MaNguoiDung
    LEFT JOIN THIET_BI AS tb ON tb.MaThietBi = ld.MaThietBi
    WHERE $dieuKien
    ORDER BY ld.ThoiGianDo DESC, ld.MaLanDo DESC
    ${gioiHan == null ? '' : 'LIMIT $gioiHan'}
  ''', thamSo);
  if (cacLanDo.isEmpty) return const [];

  // Truy vấn 2: mọi chỉ số của các lần đo vừa lấy, JOIN danh mục chỉ số.
  // Danh sách mã là số nguyên lấy từ kết quả trên nên ghép thẳng vào câu lệnh.
  final danhSachMa = cacLanDo.map((dong) => dong['MaLanDo']).join(', ');
  final chiTiet = db.select('''
    SELECT ct.MaLanDo, ct.GiaTri, ${cotLoaiChiSo()}
    FROM CHI_TIET_LAN_DO AS ct
    JOIN LOAI_CHI_SO     AS l ON l.MaLoaiChiSo = ct.MaLoaiChiSo
    WHERE ct.MaLanDo IN ($danhSachMa)
    ORDER BY ct.MaLanDo, ct.MaLoaiChiSo
  ''');

  final ketQuaTheoLanDo = <int, List<KetQuaChiSo>>{};
  for (final dong in chiTiet) {
    final loai = loaiChiSoTuDong(dong);
    if (loai == null) continue;
    ketQuaTheoLanDo
        .putIfAbsent(dong['MaLanDo'] as int, () => [])
        .add(
          KetQuaChiSo(loai: loai, giaTri: (dong['GiaTri'] as num).toDouble()),
        );
  }

  return [
    for (final dong in cacLanDo)
      LanDoDayDu(
        lanDo: LanDo(
          maLanDo: dong['MaLanDo'] as int,
          maNguoiDung: dong['MaNguoiDung'] as int,
          maThietBi: dong['MaThietBi'] as int?,
          nguon: NguonDuLieu.tuCsdl(dong['NguonDuLieu'] as String),
          thoiGianDo: docNgayGio(dong['ThoiGianDo'] as String),
          ghiChu: dong['GhiChu'] as String? ?? '',
        ),
        nguoiDung: nguoiDungTuDong(dong),
        thietBi: thietBiTuDong(dong),
        ketQua: ketQuaTheoLanDo[dong['MaLanDo'] as int] ?? const [],
      ),
  ];
}
