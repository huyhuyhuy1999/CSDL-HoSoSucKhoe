import 'package:flutter/material.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/widgets/app_badge.dart';
import '../../domain/entity/muc_do.dart';
import '../utils/chi_so_ui.dart';

/// Nhãn mức độ: Bình thường / Cần chú ý / Nguy hiểm.
class MucDoBadge extends StatelessWidget {
  const MucDoBadge({
    super.key,
    required this.mucDo,
    this.dense = false,
    this.showIcon = true,
  });

  final MucDo mucDo;
  final bool dense;
  final bool showIcon;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;

    return AppBadge(
      label: mucDo.nhan,
      color: mucDo.mau(p),
      background: mucDo.mauNen(p),
      icon: showIcon ? mucDo.icon : null,
      dense: dense,
    );
  }
}
