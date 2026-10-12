import 'package:flutter/material.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_icons.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/data_refresh_bus.dart';
import '../../../../core/widgets/app_badge.dart';
import '../../../../core/widgets/dialogs.dart';

/// Mở bảng thông tin cơ sở dữ liệu: số dòng của từng bảng và nút đặt lại
/// dữ liệu mẫu.
Future<void> moCoSoDuLieuSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => const _CoSoDuLieuSheet(),
  );
}

class _CoSoDuLieuSheet extends StatefulWidget {
  const _CoSoDuLieuSheet();

  @override
  State<_CoSoDuLieuSheet> createState() => _CoSoDuLieuSheetState();
}

class _CoSoDuLieuSheetState extends State<_CoSoDuLieuSheet> {
  final AppDatabase _csdl = getIt<AppDatabase>();
  late Map<String, int> _soDong = _csdl.demSoDong();

  Future<void> _datLai() async {
    final dongY = await xacNhan(
      context,
      tieuDe: 'Đặt lại dữ liệu mẫu?',
      noiDung:
          'Mọi hồ sơ, lần đo và cảnh báo bạn đã thêm hoặc sửa sẽ bị xóa; cơ sở '
          'dữ liệu trở về bộ dữ liệu mẫu ban đầu.',
      nhanDongY: 'Đặt lại',
      nguyHiem: true,
    );
    if (!dongY || !mounted) return;

    _csdl.datLai();
    getIt<DataRefreshBus>().notify();
    setState(() => _soDong = _csdl.demSoDong());
    context.showSnack('Đã nạp lại dữ liệu mẫu.');
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final tong = _soDong.values.fold<int>(0, (a, b) => a + b);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.page,
        0,
        AppSpacing.page,
        AppSpacing.xxl,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              IconBadge(
                icon: PhosphorIconsFill.database,
                color: p.primary,
                background: p.primarySoft,
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Cơ sở dữ liệu', style: context.text.titleLarge),
                    Text(
                      'SQLite nhúng trong ứng dụng · ${_soDong.length} bảng',
                      style: context.text.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Container(
            decoration: BoxDecoration(
              color: p.surfaceMuted,
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.sm,
            ),
            child: Column(
              children: [
                for (final muc in _soDong.entries)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            muc.key,
                            style: context.text.labelLarge!.copyWith(
                              letterSpacing: 0.4,
                            ),
                          ),
                        ),
                        Text(
                          '${muc.value}',
                          style: AppTypography.number(15, p.textPrimary),
                        ),
                        const SizedBox(width: 4),
                        Text('dòng', style: context.text.labelSmall),
                      ],
                    ),
                  ),
                Divider(color: p.border),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text('Tổng cộng', style: context.text.bodySmall),
                      ),
                      Text('$tong', style: AppTypography.number(15, p.primary)),
                      const SizedBox(width: 4),
                      Text('dòng', style: context.text.labelSmall),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          OutlinedButton.icon(
            onPressed: _datLai,
            style: OutlinedButton.styleFrom(foregroundColor: p.danger),
            icon: const Icon(
              PhosphorIconsRegular.arrowCounterClockwise,
              size: 18,
            ),
            label: const Text('Đặt lại dữ liệu mẫu'),
          ),
        ],
      ),
    );
  }
}
