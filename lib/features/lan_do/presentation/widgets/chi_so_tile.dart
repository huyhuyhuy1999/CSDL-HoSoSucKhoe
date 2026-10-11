import 'package:flutter/material.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_badge.dart';
import '../../../../core/widgets/app_card.dart';
import '../../domain/entity/lan_do.dart';
import '../utils/chi_so_ui.dart';
import 'muc_do_badge.dart';

/// Ô hiển thị giá trị mới nhất của một nhóm chỉ số.
class ChiSoTile extends StatelessWidget {
  const ChiSoTile({super.key, required this.nhom, required this.lanDo});

  final NhomChiSo nhom;

  /// Lần đo lấy giá trị; `null` nếu chưa có lần đo nào chứa chỉ số này.
  final LanDoDayDu? lanDo;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final giaTri = lanDo == null ? null : nhom.giaTri(lanDo!);
    final mucDo = lanDo == null ? null : nhom.mucDo(lanDo!);

    return AppCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconBadge(
                icon: nhom.icon,
                color: nhom.mau(p),
                background: nhom.mauNen(p),
                size: 34,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  nhom.nhan,
                  style: context.text.labelMedium!.copyWith(
                    color: p.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.bottomLeft,
                  child: Text(
                    giaTri ?? '—',
                    style: AppTypography.number(
                      26,
                      giaTri == null ? p.textTertiary : p.textPrimary,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Padding(
                padding: const EdgeInsets.only(bottom: 3),
                child: Text(nhom.donVi, style: context.text.labelSmall),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          if (mucDo != null)
            MucDoBadge(mucDo: mucDo, dense: true)
          else
            AppBadge(
              label: 'Chưa đo',
              color: p.textSecondary,
              background: p.surfaceMuted,
              dense: true,
            ),
        ],
      ),
    );
  }
}
