import 'package:flutter/material.dart';

import '../extensions/context_extensions.dart';
import '../theme/app_icons.dart';
import '../theme/app_spacing.dart';

/// Ô tìm kiếm có nút xóa nhanh.
class AppSearchField extends StatefulWidget {
  const AppSearchField({
    super.key,
    required this.hintText,
    required this.onChanged,
    this.initialValue = '',
  });

  final String hintText;
  final ValueChanged<String> onChanged;
  final String initialValue;

  @override
  State<AppSearchField> createState() => _AppSearchFieldState();
}

class _AppSearchFieldState extends State<AppSearchField> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.initialValue,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      onChanged: (value) {
        widget.onChanged(value);
        setState(() {});
      },
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: widget.hintText,
        prefixIcon: const Icon(PhosphorIconsRegular.magnifyingGlass, size: 20),
        suffixIcon: _controller.text.isEmpty
            ? null
            : IconButton(
                tooltip: 'Xóa',
                icon: const Icon(PhosphorIconsRegular.x, size: 18),
                onPressed: () {
                  _controller.clear();
                  widget.onChanged('');
                  setState(() {});
                },
              ),
      ),
    );
  }
}

/// Chip chọn một giá trị lọc.
class AppChoiceChip extends StatelessWidget {
  const AppChoiceChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.icon,
    this.trailingIcon,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final IconData? icon;
  final IconData? trailingIcon;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final foreground = selected ? p.onPrimary : p.textPrimary;

    return Material(
      color: selected ? p.primary : p.surface,
      shape: StadiumBorder(
        side: BorderSide(color: selected ? p.primary : p.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 16, color: foreground),
                const SizedBox(width: 6),
              ],
              Text(
                label,
                style: context.text.labelMedium!.copyWith(
                  color: foreground,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
              if (trailingIcon != null) ...[
                const SizedBox(width: 4),
                Icon(trailingIcon, size: 12, color: foreground),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Hàng chip cuộn ngang, canh lề theo trang.
class ChipRow extends StatelessWidget {
  const ChipRow({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.page),
      child: Row(
        children: [
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0) const SizedBox(width: AppSpacing.sm),
            children[i],
          ],
        ],
      ),
    );
  }
}

/// Bộ chọn phân đoạn (segmented) gọn, chiếm hết chiều ngang.
class AppSegmented<T> extends StatelessWidget {
  const AppSegmented({
    super.key,
    required this.values,
    required this.selected,
    required this.labelOf,
    required this.onChanged,
  });

  final List<T> values;
  final T selected;
  final String Function(T value) labelOf;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: p.surfaceMuted,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        children: [
          for (final value in values)
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => onChanged(value),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(vertical: 9),
                  decoration: BoxDecoration(
                    color: value == selected ? p.surface : Colors.transparent,
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                    boxShadow: value == selected ? p.cardShadow : null,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    labelOf(value),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.text.labelMedium!.copyWith(
                      color: value == selected ? p.primary : p.textSecondary,
                      fontWeight: value == selected
                          ? FontWeight.w600
                          : FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
