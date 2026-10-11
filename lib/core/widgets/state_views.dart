import 'package:flutter/material.dart';

import '../extensions/context_extensions.dart';
import '../theme/app_icons.dart';
import '../theme/app_spacing.dart';

/// Trạng thái đang tải.
class AppLoading extends StatelessWidget {
  const AppLoading({super.key, this.message = 'Đang tải dữ liệu…'});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            width: 28,
            height: 28,
            child: CircularProgressIndicator(strokeWidth: 3),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(message, style: context.text.bodySmall),
        ],
      ),
    );
  }
}

/// Trạng thái rỗng: không có dữ liệu hoặc không có kết quả phù hợp bộ lọc.
class AppEmptyState extends StatelessWidget {
  const AppEmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.message,
    this.action,
  });

  final IconData icon;
  final String title;
  final String? message;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: p.surfaceMuted,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 32, color: p.textTertiary),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              title,
              style: context.text.titleMedium,
              textAlign: TextAlign.center,
            ),
            if (message != null) ...[
              const SizedBox(height: 6),
              Text(
                message!,
                style: context.text.bodySmall,
                textAlign: TextAlign.center,
              ),
            ],
            if (action != null) ...[
              const SizedBox(height: AppSpacing.lg),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}

/// Trạng thái lỗi kèm nút thử lại.
class AppErrorState extends StatelessWidget {
  const AppErrorState({super.key, required this.message, this.onRetry});

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: p.dangerSoft,
                shape: BoxShape.circle,
              ),
              child: Icon(
                PhosphorIconsRegular.warningCircle,
                size: 32,
                color: p.danger,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Không tải được dữ liệu',
              style: context.text.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              message,
              style: context.text.bodySmall,
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: AppSpacing.lg),
              OutlinedButton.icon(
                onPressed: onRetry,
                icon: const Icon(
                  PhosphorIconsRegular.arrowsClockwise,
                  size: 18,
                ),
                label: const Text('Thử lại'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
