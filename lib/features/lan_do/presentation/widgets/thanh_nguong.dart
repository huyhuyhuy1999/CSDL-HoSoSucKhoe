import 'package:flutter/material.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../domain/entity/loai_chi_so.dart';
import '../../domain/entity/muc_do.dart';
import '../utils/chi_so_ui.dart';

/// Thanh ngưỡng: dải màu nguy hiểm – cần chú ý – bình thường và một con trỏ
/// cho biết giá trị đo nằm ở đâu.
class ThanhNguong extends StatelessWidget {
  const ThanhNguong({super.key, required this.loai, required this.giaTri});

  final LoaiChiSo loai;
  final double giaTri;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;

    // Chỉ số có trần tự nhiên (SpO2 tối đa 100%) thì không có dải phía trên.
    final coDaiTren = loai.canChuYMax > loai.binhThuongMax;
    final le = (loai.canChuYMax - loai.canChuYMin) * 0.3;
    final thap = loai.canChuYMin - le;
    final cao = coDaiTren ? loai.canChuYMax + le : loai.binhThuongMax;

    // Các đoạn (độ rộng, mức độ) từ trái sang phải.
    final doan = <(double, MucDo)>[
      (loai.canChuYMin - thap, MucDo.nguyHiem),
      (loai.binhThuongMin - loai.canChuYMin, MucDo.canChuY),
      (loai.binhThuongMax - loai.binhThuongMin, MucDo.binhThuong),
      if (coDaiTren) ...[
        (loai.canChuYMax - loai.binhThuongMax, MucDo.canChuY),
        (cao - loai.canChuYMax, MucDo.nguyHiem),
      ],
    ];
    final viTri = ((giaTri - thap) / (cao - thap)).clamp(0.0, 1.0);
    final mauConTro = loai.danhGia(giaTri).mau(p);

    return LayoutBuilder(
      builder: (context, constraints) {
        final rong = constraints.maxWidth;
        const duongKinh = 14.0;
        final trai = (viTri * rong - duongKinh / 2).clamp(
          0.0,
          rong - duongKinh,
        );

        return SizedBox(
          height: duongKinh,
          child: Stack(
            alignment: Alignment.centerLeft,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: Row(
                  children: [
                    for (final (doRong, mucDo) in doan)
                      Expanded(
                        flex: (doRong * 1000).round().clamp(1, 1 << 30),
                        child: Container(
                          height: 6,
                          color: mucDo.mau(p).withValues(alpha: 0.38),
                        ),
                      ),
                  ],
                ),
              ),
              Positioned(
                left: trai,
                child: Container(
                  width: duongKinh,
                  height: duongKinh,
                  decoration: BoxDecoration(
                    color: mauConTro,
                    shape: BoxShape.circle,
                    border: Border.all(color: p.surface, width: 2.5),
                    boxShadow: [
                      BoxShadow(
                        color: mauConTro.withValues(alpha: 0.35),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
