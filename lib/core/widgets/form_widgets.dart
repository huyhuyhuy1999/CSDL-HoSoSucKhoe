import 'package:flutter/material.dart';

import '../extensions/context_extensions.dart';
import '../theme/app_spacing.dart';
import 'app_card.dart';

/// Một nhóm trường trong form, có tiêu đề và icon.
class FormSection extends StatelessWidget {
  const FormSection({
    super.key,
    required this.title,
    required this.icon,
    required this.children,
  });

  final String title;
  final IconData icon;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: p.primary),
              const SizedBox(width: AppSpacing.sm),
              Text(title, style: context.text.titleMedium),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0) const SizedBox(height: AppSpacing.lg),
            children[i],
          ],
        ],
      ),
    );
  }
}

/// Trường nhập có nhãn đặt phía trên; dấu * đỏ nếu bắt buộc.
class LabeledField extends StatelessWidget {
  const LabeledField({
    super.key,
    required this.label,
    required this.child,
    this.required = false,
    this.trailing,
  });

  final String label;
  final Widget child;
  final bool required;

  /// Widget nhỏ đặt cùng hàng với nhãn, canh phải.
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Flexible(
              child: Text.rich(
                TextSpan(
                  text: label,
                  children: [
                    if (required)
                      TextSpan(
                        text: ' *',
                        style: TextStyle(color: p.danger),
                      ),
                  ],
                ),
                style: context.text.labelMedium!.copyWith(
                  color: p.textSecondary,
                ),
              ),
            ),
            if (trailing != null) ...[const Spacer(), trailing!],
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        child,
      ],
    );
  }
}

/// Ô chỉ đọc mở bộ chọn (ngày, giờ, người dùng…) khi chạm.
class PickerField extends StatelessWidget {
  const PickerField({
    super.key,
    required this.text,
    required this.icon,
    required this.onTap,
    this.hint,
    this.errorText,
    this.leading,
  });

  /// Giá trị đang chọn; `null` thì hiện [hint].
  final String? text;
  final String? hint;
  final IconData icon;
  final VoidCallback onTap;
  final String? errorText;
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: InputDecorator(
        decoration: InputDecoration(
          suffixIcon: Icon(icon, size: 20),
          errorText: errorText,
        ),
        child: Row(
          children: [
            if (leading != null) ...[
              leading!,
              const SizedBox(width: AppSpacing.md),
            ],
            Expanded(
              child: Text(
                text ?? hint ?? '',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.text.bodyLarge!.copyWith(
                  fontSize: 15,
                  color: text == null ? p.textTertiary : p.textPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Đọc số thực từ chuỗi người dùng nhập; chấp nhận cả dấu phẩy và dấu chấm.
double? docSo(String? input) {
  if (input == null) return null;
  return double.tryParse(input.trim().replaceAll(',', '.'));
}
