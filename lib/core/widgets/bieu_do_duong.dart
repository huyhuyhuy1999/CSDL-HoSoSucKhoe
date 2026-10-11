import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../extensions/context_extensions.dart';
import '../theme/app_spacing.dart';

/// Một đường trên [BieuDoDuong].
class DuLieuDuong {
  const DuLieuDuong({
    required this.nhan,
    required this.mau,
    required this.giaTri,
  });

  final String nhan;
  final Color mau;

  /// Giá trị theo từng mốc trục X; `null` nghĩa là mốc đó không có dữ liệu.
  final List<double?> giaTri;
}

/// Biểu đồ đường dùng chung: một hoặc nhiều đường, có vùng tô "bình thường"
/// tùy chọn và chú giải khi có nhiều hơn một đường.
class BieuDoDuong extends StatelessWidget {
  const BieuDoDuong({
    super.key,
    required this.nhanTrucX,
    required this.duong,
    required this.dinhDang,
    this.vungBinhThuong,
    this.height = 200,
  });

  /// Nhãn của từng mốc trên trục X.
  final List<String> nhanTrucX;
  final List<DuLieuDuong> duong;
  final String Function(double value) dinhDang;

  /// Khoảng (min, max) được tô nền nhạt để thấy giá trị có nằm trong ngưỡng.
  final (double, double)? vungBinhThuong;
  final double height;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final tatCa = [
      for (final d in duong)
        for (final v in d.giaTri) ?v,
    ];

    if (tatCa.length < 2) {
      return SizedBox(
        height: height,
        child: Center(
          child: Text(
            'Chưa đủ dữ liệu để vẽ biểu đồ',
            style: context.text.bodySmall,
          ),
        ),
      );
    }

    var minY = tatCa.reduce(min);
    var maxY = tatCa.reduce(max);
    if (vungBinhThuong case (final thap, final cao)) {
      // Khi có giá trị vượt ngưỡng, nới trục Y để mép vùng bình thường vẫn
      // nằm trong khung nhìn, giúp thấy rõ giá trị lệch bao xa.
      final khoang = max(maxY - minY, 1.0);
      final vuotTren = maxY > cao;
      final vuotDuoi = minY < thap;
      if (vuotTren) minY = min(minY, cao - khoang * 0.2);
      if (vuotDuoi) maxY = max(maxY, thap + khoang * 0.2);
    }
    final bien = max((maxY - minY) * 0.15, 0.5);
    minY -= bien;
    maxY += bien;

    final soMoc = nhanTrucX.length;
    final buocNhan = max(1, (soMoc / 5).ceil());
    final nhieuDuong = duong.length > 1;

    return Column(
      children: [
        SizedBox(
          height: height,
          child: LineChart(
            LineChartData(
              minX: 0,
              maxX: max(1, soMoc - 1).toDouble(),
              minY: minY,
              maxY: maxY,
              clipData: const FlClipData.all(),
              borderData: FlBorderData(show: false),
              gridData: FlGridData(
                drawVerticalLine: false,
                horizontalInterval: (maxY - minY) / 4,
                getDrawingHorizontalLine: (_) =>
                    FlLine(color: p.border, strokeWidth: 1),
              ),
              rangeAnnotations: RangeAnnotations(
                horizontalRangeAnnotations: [
                  if (vungBinhThuong case (final thap, final cao))
                    HorizontalRangeAnnotation(
                      y1: max(thap, minY),
                      y2: min(cao, maxY),
                      color: p.success.withValues(alpha: 0.08),
                    ),
                ],
              ),
              titlesData: FlTitlesData(
                topTitles: const AxisTitles(),
                rightTitles: const AxisTitles(),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40,
                    interval: (maxY - minY) / 4,
                    getTitlesWidget: (value, meta) {
                      if (value == meta.min || value == meta.max) {
                        return const SizedBox.shrink();
                      }
                      return SideTitleWidget(
                        meta: meta,
                        child: Text(
                          dinhDang(value),
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
                    interval: 1,
                    getTitlesWidget: (value, meta) {
                      final i = value.round();
                      final hien =
                          value == i.toDouble() &&
                          i >= 0 &&
                          i < soMoc &&
                          (soMoc - 1 - i) % buocNhan == 0;
                      if (!hien) return const SizedBox.shrink();
                      return SideTitleWidget(
                        meta: meta,
                        child: Text(
                          nhanTrucX[i],
                          style: context.text.labelSmall,
                        ),
                      );
                    },
                  ),
                ),
              ),
              lineTouchData: LineTouchData(
                touchTooltipData: LineTouchTooltipData(
                  getTooltipColor: (_) => p.textPrimary,
                  tooltipBorderRadius: BorderRadius.circular(AppRadius.sm),
                  fitInsideHorizontally: true,
                  fitInsideVertically: true,
                  getTooltipItems: (spots) => [
                    for (final spot in spots)
                      LineTooltipItem(
                        '${spot == spots.first ? '${nhanTrucX[spot.x.round()]}\n' : ''}'
                        '${nhieuDuong ? '${duong[spot.barIndex].nhan}: ' : ''}'
                        '${dinhDang(spot.y)}',
                        context.text.labelMedium!.copyWith(color: p.surface),
                      ),
                  ],
                ),
              ),
              lineBarsData: [
                for (final d in duong)
                  LineChartBarData(
                    spots: [
                      for (var i = 0; i < d.giaTri.length; i++)
                        if (d.giaTri[i] case final v?) FlSpot(i.toDouble(), v),
                    ],
                    isCurved: true,
                    curveSmoothness: 0.25,
                    preventCurveOverShooting: true,
                    color: d.mau,
                    barWidth: 2.5,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: soMoc <= 16,
                      getDotPainter: (_, _, _, _) => FlDotCirclePainter(
                        radius: 3,
                        color: p.surface,
                        strokeWidth: 2,
                        strokeColor: d.mau,
                      ),
                    ),
                    belowBarData: BarAreaData(
                      show: !nhieuDuong,
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          d.mau.withValues(alpha: 0.18),
                          d.mau.withValues(alpha: 0),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        if (nhieuDuong || vungBinhThuong != null) ...[
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.lg,
            runSpacing: 6,
            alignment: WrapAlignment.center,
            children: [
              if (nhieuDuong)
                for (final d in duong) ChuGiai(mau: d.mau, nhan: d.nhan),
              if (vungBinhThuong != null)
                ChuGiai(
                  mau: p.success.withValues(alpha: 0.35),
                  nhan: 'Khoảng bình thường',
                  vuong: true,
                ),
            ],
          ),
        ],
      ],
    );
  }
}

/// Một mục chú giải: chấm màu và nhãn.
class ChuGiai extends StatelessWidget {
  const ChuGiai({
    super.key,
    required this.mau,
    required this.nhan,
    this.vuong = false,
  });

  final Color mau;
  final String nhan;
  final bool vuong;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: mau,
            borderRadius: BorderRadius.circular(vuong ? 3 : 5),
          ),
        ),
        const SizedBox(width: 6),
        Text(nhan, style: context.text.labelSmall),
      ],
    );
  }
}
