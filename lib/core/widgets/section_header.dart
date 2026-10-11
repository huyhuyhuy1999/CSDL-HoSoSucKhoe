import 'package:flutter/material.dart';

import '../extensions/context_extensions.dart';
import '../theme/app_icons.dart';

/// Tiêu đề của một nhóm nội dung, kèm nút "Xem tất cả" tùy chọn.
class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    this.actionLabel,
    this.onAction,
    this.trailing,
  });

  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;

    return Row(
      children: [
        Expanded(child: Text(title, style: context.text.titleMedium)),
        ?trailing,
        if (actionLabel != null)
          InkWell(
            onTap: onAction,
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    actionLabel!,
                    style: context.text.labelMedium!.copyWith(
                      color: p.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 2),
                  Icon(
                    PhosphorIconsBold.caretRight,
                    size: 12,
                    color: p.primary,
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
