import 'package:flutter/material.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_icons.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';

/// Thẻ nổi bật đầu trang Tổng quan: số lần đo và cảnh báo trong hôm nay.
class HeroCard extends StatelessWidget {
  const HeroCard({
    super.key,
    required this.lanDoHomNay,
    required this.canhBaoHomNay,
    required this.canhBaoChuaXem,
  });

  final int lanDoHomNay;
  final int canhBaoHomNay;
  final int canhBaoChuaXem;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    const trang = Colors.white;

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: p.heroGradient,
        ),
        borderRadius: BorderRadius.circular(AppRadius.xl),
      ),
      child: Stack(
        children: [
          // Đường điện tim trang trí ở nửa phải, ngang hàng với con số lớn.
          Positioned(
            right: 0,
            top: 56,
            width: 210,
            height: 72,
            child: CustomPaint(
              painter: _DuongDienTimPainter(trang.withValues(alpha: 0.3)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: trang.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                      child: const Icon(
                        PhosphorIconsFill.heartbeat,
                        color: trang,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Text(
                      'Hoạt động hôm nay',
                      style: context.text.titleSmall!.copyWith(
                        color: trang.withValues(alpha: 0.92),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '$lanDoHomNay',
                      style: AppTypography.number(46, trang),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 7),
                      child: Text(
                        'lần đo',
                        style: context.text.titleMedium!.copyWith(
                          color: trang.withValues(alpha: 0.92),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: [
                    _Chip(
                      icon: PhosphorIconsFill.warning,
                      label: canhBaoHomNay == 0
                          ? 'Không có cảnh báo hôm nay'
                          : '$canhBaoHomNay cảnh báo hôm nay',
                    ),
                    if (canhBaoChuaXem > 0)
                      _Chip(
                        icon: PhosphorIconsFill.bell,
                        label: '$canhBaoChuaXem chưa xem',
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.white),
          const SizedBox(width: 6),
          Text(
            label,
            style: context.text.labelMedium!.copyWith(color: Colors.white),
          ),
        ],
      ),
    );
  }
}

class _DuongDienTimPainter extends CustomPainter {
  const _DuongDienTimPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    // Mờ dần về bên trái để không tranh chỗ với chữ.
    final paint = Paint()
      ..shader = LinearGradient(
        colors: [color.withValues(alpha: 0), color],
        stops: const [0, 0.55],
      ).createShader(Offset.zero & size)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Một nhịp tim chuẩn hóa: (x, y) với x trong [0, 1], y lệch khỏi đường nền.
    const nhip = <(double, double)>[
      (0.00, 0.00),
      (0.30, 0.00),
      (0.36, -0.14),
      (0.42, 0.00),
      (0.48, 0.00),
      (0.52, 0.18),
      (0.58, -0.78),
      (0.64, 0.34),
      (0.69, 0.00),
      (0.76, 0.00),
      (0.84, -0.22),
      (0.92, 0.00),
      (1.00, 0.00),
    ];

    const rongNhip = 105.0;
    final duongNen = size.height * 0.6;
    final bienDo = size.height * 0.6;
    final path = Path()..moveTo(0, duongNen);

    for (var batDau = 0.0; batDau < size.width; batDau += rongNhip) {
      for (final (x, y) in nhip) {
        path.lineTo(batDau + x * rongNhip, duongNen + y * bienDo);
      }
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_DuongDienTimPainter oldDelegate) =>
      oldDelegate.color != color;
}
