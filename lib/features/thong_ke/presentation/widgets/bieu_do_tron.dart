import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../lan_do/domain/entity/muc_do.dart';
import '../../../lan_do/presentation/utils/chi_so_ui.dart';

/// Biểu đồ vành khuyên: tỷ lệ lần đo theo mức độ đánh giá.
class BieuDoTron extends StatelessWidget {
  const BieuDoTron({super.key, required this.phanBo});

  final Map<MucDo, int> phanBo;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final tong = phanBo.values.fold<int>(0, (a, b) => a + b);

    if (tong == 0) {
      return SizedBox(
        height: 120,
        child: Center(
          child: Text('Chưa có lần đo nào', style: context.text.bodySmall),
        ),
      );
    }

    return Row(
      children: [
        SizedBox(
          width: 132,
          height: 132,
          child: Stack(
            alignment: Alignment.center,
            children: [
              PieChart(
                PieChartData(
                  startDegreeOffset: -90,
                  sectionsSpace: 3,
                  centerSpaceRadius: 44,
                  sections: [
                    for (final mucDo in MucDo.values)
                      if (phanBo[mucDo] case final so? when so > 0)
                        PieChartSectionData(
                          value: so.toDouble(),
                          color: mucDo.mau(p),
                          radius: 18,
                          showTitle: false,
                        ),
                  ],
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('$tong', style: AppTypography.number(24, p.textPrimary)),
                  Text('lần đo', style: context.text.labelSmall),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.xl),
        Expanded(
          child: Column(
            children: [
              for (final mucDo in MucDo.values)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: mucDo.mau(p),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(mucDo.nhan, style: context.text.bodyMedium),
                      ),
                      Text(
                        '${phanBo[mucDo] ?? 0}',
                        style: context.text.titleSmall,
                      ),
                      SizedBox(
                        width: 44,
                        child: Text(
                          '${((phanBo[mucDo] ?? 0) * 100 / tong).round()}%',
                          style: context.text.bodySmall,
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
