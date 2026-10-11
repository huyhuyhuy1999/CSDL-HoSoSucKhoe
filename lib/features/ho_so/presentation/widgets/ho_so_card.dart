import 'package:flutter/material.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_icons.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/dinh_dang.dart';
import '../../../../core/widgets/app_badge.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../lan_do/presentation/widgets/muc_do_badge.dart';
import '../../domain/entity/ho_so_suc_khoe.dart';
import 'avatar_nguoi_dung.dart';

/// Một dòng trong danh sách hồ sơ.
class HoSoCard extends StatelessWidget {
  const HoSoCard({super.key, required this.hoSo, this.onTap});

  final HoSoTongHop hoSo;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final nd = hoSo.nguoiDung;
    final lanDo = hoSo.lanDoGanNhat;

    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(14),
      child: Column(
        children: [
          Row(
            children: [
              AvatarNguoiDung(nguoiDung: nd, size: 48),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      nd.hoTen,
                      style: context.text.titleMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${nd.gioiTinh.nhan} · ${nd.tuoi} tuổi · '
                      'Nhóm ${hoSo.hoSo.nhomMau}',
                      style: context.text.bodySmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              if (hoSo.trangThai case final trangThai?)
                MucDoBadge(mucDo: trangThai, dense: true)
              else
                AppBadge(
                  label: 'Chưa đo',
                  color: p.textSecondary,
                  background: p.surfaceMuted,
                  dense: true,
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Divider(color: p.border),
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(PhosphorIconsRegular.clock, size: 15, color: p.textTertiary),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  lanDo == null
                      ? 'Chưa có lần đo nào'
                      : 'Đo gần nhất ${_chuThuong(DinhDang.tuongDoi(lanDo.lanDo.thoiGianDo))}'
                            ' · ${hoSo.soLanDo} lần đo',
                  style: context.text.bodySmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (hoSo.soCanhBaoChuaXem > 0) ...[
                const SizedBox(width: AppSpacing.sm),
                Icon(PhosphorIconsFill.bell, size: 14, color: p.danger),
                const SizedBox(width: 4),
                Text(
                  '${hoSo.soCanhBaoChuaXem} mới',
                  style: context.text.labelMedium!.copyWith(
                    color: p.danger,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  String _chuThuong(String s) =>
      s.isEmpty ? s : s[0].toLowerCase() + s.substring(1);
}
