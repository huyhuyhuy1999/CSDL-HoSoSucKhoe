import 'package:flutter/material.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/dinh_dang.dart';
import '../../../../core/widgets/app_badge.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../lan_do/presentation/utils/chi_so_ui.dart';
import '../../domain/entity/canh_bao.dart';

/// Thẻ cảnh báo: màu theo mức độ, chấm tròn nếu chưa xem.
class CanhBaoCard extends StatelessWidget {
  const CanhBaoCard({
    super.key,
    required this.canhBao,
    this.onTap,
    this.hienNguoiDung = true,
    this.hienNoiDung = false,
  });

  final CanhBaoDayDu canhBao;
  final VoidCallback? onTap;
  final bool hienNguoiDung;

  /// Hiện câu mô tả chi tiết bên dưới tiêu đề.
  final bool hienNoiDung;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final cb = canhBao.canhBao;
    final mau = cb.mucDo.mau(p);
    final thoiGian = DinhDang.tuongDoi(cb.thoiGianTao);

    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconBadge(
            icon: cb.mucDo.icon,
            color: mau,
            background: cb.mucDo.mauNen(p),
            size: 42,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        canhBao.tieuDe,
                        style: context.text.titleSmall!.copyWith(
                          fontWeight: cb.daXem
                              ? FontWeight.w600
                              : FontWeight.w700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      canhBao.giaTriHienThi,
                      style: context.text.titleSmall!.copyWith(color: mau),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  hienNguoiDung
                      ? '${canhBao.nguoiDung.hoTen} · $thoiGian'
                      : '${cb.mucDo.nhan} · $thoiGian',
                  style: context.text.bodySmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (hienNoiDung) ...[
                  const SizedBox(height: 6),
                  Text(
                    cb.noiDung,
                    style: context.text.bodySmall!.copyWith(
                      color: p.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (!cb.daXem)
            Padding(
              padding: const EdgeInsets.only(left: AppSpacing.sm, top: 6),
              child: Container(
                width: 9,
                height: 9,
                decoration: BoxDecoration(
                  color: p.primary,
                  shape: BoxShape.circle,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
