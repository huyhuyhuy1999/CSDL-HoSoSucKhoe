import 'package:flutter/material.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/dinh_dang.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../ho_so/presentation/widgets/avatar_nguoi_dung.dart';
import '../../domain/entity/lan_do.dart';
import '../../domain/entity/muc_do.dart';
import '../utils/chi_so_ui.dart';
import 'muc_do_badge.dart';

/// Thẻ tóm tắt một lần đo: ai, lúc nào, nguồn nào và bốn nhóm chỉ số.
class LanDoCard extends StatelessWidget {
  const LanDoCard({
    super.key,
    required this.lanDo,
    this.onTap,
    this.hienNguoiDung = true,
    this.hienNgay = false,
  });

  final LanDoDayDu lanDo;
  final VoidCallback? onTap;

  /// Ẩn avatar và tên khi thẻ nằm trong trang của chính người đó.
  final bool hienNguoiDung;

  /// Hiện cả ngày (khi danh sách không được nhóm theo ngày).
  final bool hienNgay;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final thoiGian = lanDo.lanDo.thoiGianDo;
    final gio = hienNgay
        ? '${DinhDang.gio(thoiGian)} · ${DinhDang.nhomNgay(thoiGian)}'
        : DinhDang.gio(thoiGian);

    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(14),
      child: Column(
        children: [
          Row(
            children: [
              if (hienNguoiDung) ...[
                AvatarNguoiDung(nguoiDung: lanDo.nguoiDung, size: 40),
                const SizedBox(width: AppSpacing.md),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hienNguoiDung ? lanDo.nguoiDung.hoTen : gio,
                      style: context.text.titleSmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        Icon(
                          lanDo.lanDo.nguon.icon,
                          size: 14,
                          color: p.textTertiary,
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            hienNguoiDung
                                ? '$gio · ${lanDo.tenNguon}'
                                : lanDo.tenNguon,
                            style: context.text.bodySmall,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              MucDoBadge(mucDo: lanDo.mucDo, dense: true),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: p.surfaceMuted,
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Row(
              children: [
                for (final nhom in NhomChiSo.values)
                  Expanded(
                    child: _GiaTri(nhom: nhom, lanDo: lanDo),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GiaTri extends StatelessWidget {
  const _GiaTri({required this.nhom, required this.lanDo});

  final NhomChiSo nhom;
  final LanDoDayDu lanDo;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final giaTri = nhom.giaTri(lanDo);
    final mucDo = nhom.mucDo(lanDo);
    final mauGiaTri = switch (mucDo) {
      null => p.textTertiary,
      MucDo.binhThuong => p.textPrimary,
      _ => mucDo.mau(p),
    };

    return Column(
      children: [
        Icon(
          nhom.icon,
          size: 16,
          color: giaTri == null ? p.textTertiary : nhom.mau(p),
        ),
        const SizedBox(height: 4),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            giaTri ?? '—',
            style: AppTypography.number(15, mauGiaTri),
          ),
        ),
        const SizedBox(height: 1),
        Text(
          nhom.donVi,
          style: context.text.labelSmall!.copyWith(fontSize: 10),
        ),
      ],
    );
  }
}
