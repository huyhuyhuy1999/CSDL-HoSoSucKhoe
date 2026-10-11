import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_badge.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../lan_do/domain/entity/loai_chi_so.dart';
import '../../../lan_do/presentation/utils/chi_so_ui.dart';
import '../../domain/entity/tong_quan.dart';

/// Thẻ xu hướng 7 ngày của một nhóm chỉ số: giá trị trung bình và
/// đường biểu diễn thu nhỏ.
class XuHuongCard extends StatelessWidget {
  const XuHuongCard({super.key, required this.nhom, required this.xuHuong});

  final NhomChiSo nhom;
  final Map<MaChiSo, XuHuongChiSo> xuHuong;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final mau = nhom.mau(p);
    final chinh = xuHuong[nhom.maChiSo.first];

    // "36,7" hoặc "124/79" với huyết áp.
    final trungBinh = [
      for (final ma in nhom.maChiSo)
        if (xuHuong[ma] case XuHuongChiSo(:final loai, :final trungBinh?))
          loai.dinhDang(trungBinh),
    ];
    final coDuLieu = trungBinh.length == nhom.maChiSo.length;
    final diem = chinh?.diem ?? const [];

    return SizedBox(
      width: 158,
      child: AppCard(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                IconBadge(
                  icon: nhom.icon,
                  color: mau,
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
                      coDuLieu ? trungBinh.join('/') : '—',
                      style: AppTypography.number(24, p.textPrimary),
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
            SizedBox(
              height: 36,
              child: diem.length < 2
                  ? Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Chưa đủ dữ liệu',
                        style: context.text.labelSmall,
                      ),
                    )
                  : LineChart(
                      LineChartData(
                        minX: 0,
                        maxX: (diem.length - 1).toDouble(),
                        gridData: const FlGridData(show: false),
                        titlesData: const FlTitlesData(show: false),
                        borderData: FlBorderData(show: false),
                        lineTouchData: const LineTouchData(enabled: false),
                        lineBarsData: [
                          LineChartBarData(
                            spots: [
                              for (var i = 0; i < diem.length; i++)
                                FlSpot(i.toDouble(), diem[i].giaTri),
                            ],
                            isCurved: true,
                            curveSmoothness: 0.3,
                            preventCurveOverShooting: true,
                            color: mau,
                            barWidth: 2.5,
                            isStrokeCapRound: true,
                            dotData: const FlDotData(show: false),
                            belowBarData: BarAreaData(
                              show: true,
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  mau.withValues(alpha: 0.22),
                                  mau.withValues(alpha: 0),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
