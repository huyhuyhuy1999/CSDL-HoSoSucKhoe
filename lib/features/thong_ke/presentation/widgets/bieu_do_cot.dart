import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/dinh_dang.dart';
import '../../domain/entity/thong_ke.dart';

/// Biểu đồ cột: số lần đo theo từng ngày.
class BieuDoCot extends StatelessWidget {
  const BieuDoCot({super.key, required this.duLieu, this.height = 180});

  final List<SoLanDoTheoNgay> duLieu;
  final double height;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final lonNhat = duLieu.fold<int>(0, (m, d) => max(m, d.soLan));
    final soCot = duLieu.length;
    final buocNhan = max(1, (soCot / 6).ceil());
    final buocTrucY = max(1, (lonNhat / 4).ceil()).toDouble();
    final rongCot = switch (soCot) {
      <= 7 => 20.0,
      <= 14 => 11.0,
      _ => 5.0,
    };

    return SizedBox(
      height: height,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: (lonNhat / buocTrucY).ceil() * buocTrucY + buocTrucY * 0.4,
          borderData: FlBorderData(show: false),
          gridData: FlGridData(
            drawVerticalLine: false,
            horizontalInterval: buocTrucY,
            getDrawingHorizontalLine: (_) =>
                FlLine(color: p.border, strokeWidth: 1),
          ),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(),
            rightTitles: const AxisTitles(),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 28,
                interval: buocTrucY,
                getTitlesWidget: (value, meta) {
                  if (value == meta.max) return const SizedBox.shrink();
                  return SideTitleWidget(
                    meta: meta,
                    child: Text(
                      value.round().toString(),
                      style: context.text.labelSmall,
                    ),
                  );
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 26,
                getTitlesWidget: (value, meta) {
                  final i = value.round();
                  final hien =
                      i >= 0 && i < soCot && (soCot - 1 - i) % buocNhan == 0;
                  if (!hien) return const SizedBox.shrink();
                  return SideTitleWidget(
                    meta: meta,
                    child: Text(
                      DinhDang.ngayNgan(duLieu[i].ngay),
                      style: context.text.labelSmall,
                    ),
                  );
                },
              ),
            ),
          ),
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              getTooltipColor: (_) => p.textPrimary,
              tooltipBorderRadius: BorderRadius.circular(AppRadius.sm),
              fitInsideHorizontally: true,
              fitInsideVertically: true,
              getTooltipItem: (group, _, rod, _) => BarTooltipItem(
                '${DinhDang.ngayNgan(duLieu[group.x].ngay)}\n'
                '${rod.toY.round()} lần đo',
                context.text.labelMedium!.copyWith(color: p.surface),
              ),
            ),
          ),
          barGroups: [
            for (var i = 0; i < soCot; i++)
              BarChartGroupData(
                x: i,
                barRods: [
                  BarChartRodData(
                    toY: duLieu[i].soLan.toDouble(),
                    width: rongCot,
                    color: p.primary,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(5),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
