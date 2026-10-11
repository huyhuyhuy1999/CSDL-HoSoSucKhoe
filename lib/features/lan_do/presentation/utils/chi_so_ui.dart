import 'package:flutter/widgets.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_icons.dart';
import '../../domain/entity/lan_do.dart';
import '../../domain/entity/loai_chi_so.dart';
import '../../domain/entity/muc_do.dart';

/// Nhóm chỉ số khi hiển thị: huyết áp tâm thu và tâm trương được gộp thành
/// một ô "Huyết áp" dạng 120/80.
enum NhomChiSo {
  nhietDo('Nhiệt độ', '°C', [MaChiSo.nhietDo]),
  nhipTim('Nhịp tim', 'bpm', [MaChiSo.nhipTim]),
  spo2('SpO2', '%', [MaChiSo.spo2]),
  huyetAp('Huyết áp', 'mmHg', [
    MaChiSo.huyetApTamThu,
    MaChiSo.huyetApTamTruong,
  ]);

  const NhomChiSo(this.nhan, this.donVi, this.maChiSo);

  final String nhan;
  final String donVi;
  final List<MaChiSo> maChiSo;

  static NhomChiSo cua(MaChiSo ma) =>
      values.firstWhere((nhom) => nhom.maChiSo.contains(ma));

  IconData get icon => switch (this) {
    nhietDo => PhosphorIconsFill.thermometerSimple,
    nhipTim => PhosphorIconsFill.heartbeat,
    spo2 => PhosphorIconsFill.drop,
    huyetAp => PhosphorIconsFill.pulse,
  };

  Color mau(AppPalette p) => switch (this) {
    nhietDo => p.nhietDo,
    nhipTim => p.nhipTim,
    spo2 => p.spo2,
    huyetAp => p.huyetAp,
  };

  Color mauNen(AppPalette p) => switch (this) {
    nhietDo => p.nhietDoSoft,
    nhipTim => p.nhipTimSoft,
    spo2 => p.spo2Soft,
    huyetAp => p.huyetApSoft,
  };

  /// Giá trị hiển thị của nhóm trong một lần đo ("36,8", "120/80");
  /// `null` nếu lần đo không có chỉ số này.
  String? giaTri(LanDoDayDu lanDo) {
    final ketQua = [for (final ma in maChiSo) ?lanDo.ketQuaCua(ma)];
    if (ketQua.length != maChiSo.length) return null;
    return ketQua.map((kq) => kq.giaTriHienThi).join('/');
  }

  /// Mức độ nặng nhất của nhóm trong một lần đo.
  MucDo? mucDo(LanDoDayDu lanDo) {
    MucDo? mucDo;
    for (final ma in maChiSo) {
      final kq = lanDo.ketQuaCua(ma);
      if (kq == null) continue;
      mucDo = mucDo == null ? kq.mucDo : mucDo.nangHon(kq.mucDo);
    }
    return mucDo;
  }
}

extension MucDoUi on MucDo {
  Color mau(AppPalette p) => switch (this) {
    MucDo.binhThuong => p.success,
    MucDo.canChuY => p.warning,
    MucDo.nguyHiem => p.danger,
  };

  Color mauNen(AppPalette p) => switch (this) {
    MucDo.binhThuong => p.successSoft,
    MucDo.canChuY => p.warningSoft,
    MucDo.nguyHiem => p.dangerSoft,
  };

  IconData get icon => switch (this) {
    MucDo.binhThuong => PhosphorIconsFill.checkCircle,
    MucDo.canChuY => PhosphorIconsFill.warning,
    MucDo.nguyHiem => PhosphorIconsFill.warningOctagon,
  };
}

extension NguonDuLieuUi on NguonDuLieu {
  IconData get icon => switch (this) {
    NguonDuLieu.thietBi => PhosphorIconsRegular.cpu,
    NguonDuLieu.nhapThuCong => PhosphorIconsRegular.keyboard,
  };
}
