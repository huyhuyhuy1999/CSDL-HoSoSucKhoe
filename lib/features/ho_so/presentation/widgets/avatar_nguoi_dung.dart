import 'package:flutter/material.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../domain/entity/nguoi_dung.dart';

/// Avatar tròn hiển thị chữ cái đầu của họ tên; mỗi người một tông màu
/// cố định suy ra từ mã người dùng.
class AvatarNguoiDung extends StatelessWidget {
  const AvatarNguoiDung({super.key, required this.nguoiDung, this.size = 44});

  final NguoiDung nguoiDung;
  final double size;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final tong = [
      (p.primary, p.primarySoft),
      (p.info, p.infoSoft),
      (p.huyetAp, p.huyetApSoft),
      (p.nhietDo, p.nhietDoSoft),
      (p.nhipTim, p.nhipTimSoft),
      (p.spo2, p.spo2Soft),
      (p.success, p.successSoft),
    ];
    final chiSo = nguoiDung.maNguoiDung.codeUnits.fold(0, (a, b) => a + b);
    final (mau, nen) = tong[chiSo % tong.length];

    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: nen, shape: BoxShape.circle),
      child: Text(
        nguoiDung.chuCaiDau,
        style: TextStyle(
          color: mau,
          fontSize: size * 0.36,
          fontWeight: FontWeight.w700,
          height: 1,
        ),
      ),
    );
  }
}
