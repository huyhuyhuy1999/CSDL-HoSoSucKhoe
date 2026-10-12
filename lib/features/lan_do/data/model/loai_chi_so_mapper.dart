import '../../domain/entity/loai_chi_so.dart';

/// Danh sách cột của LOAI_CHI_SO để chèn vào câu SELECT, với bí danh bảng [b].
String cotLoaiChiSo([String b = 'l']) =>
    '$b.MaLoaiChiSo, $b.KyHieu, $b.TenChiSo, $b.DonViDo, $b.SoThapPhan, '
    '$b.GiaTriMin, $b.GiaTriMax, $b.BinhThuongMin, $b.BinhThuongMax, '
    '$b.CanhBaoMin, $b.CanhBaoMax';

/// Một dòng có các cột của LOAI_CHI_SO → [LoaiChiSo]. Trả về `null` nếu ký
/// hiệu của chỉ số chưa được ứng dụng hỗ trợ hiển thị.
LoaiChiSo? loaiChiSoTuDong(Map<String, Object?> dong) {
  final ma = MaChiSo.tuKyHieu(dong['KyHieu']! as String);
  if (ma == null) return null;

  double so(String cot) => (dong[cot]! as num).toDouble();

  return LoaiChiSo(
    maLoaiChiSo: dong['MaLoaiChiSo']! as int,
    ma: ma,
    tenChiSo: dong['TenChiSo']! as String,
    donViDo: dong['DonViDo']! as String,
    soThapPhan: dong['SoThapPhan']! as int,
    nhapMin: so('GiaTriMin'),
    nhapMax: so('GiaTriMax'),
    binhThuongMin: so('BinhThuongMin'),
    binhThuongMax: so('BinhThuongMax'),
    canChuYMin: so('CanhBaoMin'),
    canChuYMax: so('CanhBaoMax'),
  );
}
