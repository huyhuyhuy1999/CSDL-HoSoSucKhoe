import 'package:flutter/material.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../ho_so/presentation/widgets/avatar_nguoi_dung.dart';
import '../../../lan_do/presentation/utils/chi_so_ui.dart';
import '../../domain/entity/thong_ke.dart';

/// Bảng trung bình / thấp nhất / cao nhất / số lần đo của từng chỉ số.
class BangChiSo extends StatelessWidget {
  const BangChiSo({super.key, required this.duLieu});

  final List<ThongKeChiSo> duLieu;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;

    if (duLieu.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
        child: Center(
          child: Text('Chưa có dữ liệu', style: context.text.bodySmall),
        ),
      );
    }

    Widget o(String text, {required int flex, TextStyle? style}) {
      return Expanded(
        flex: flex,
        child: Text(
          text,
          style: style ?? context.text.labelLarge,
          textAlign: TextAlign.right,
        ),
      );
    }

    final tieuDe = context.text.labelSmall;

    return Column(
      children: [
        Row(
          children: [
            Expanded(flex: 9, child: Text('Chỉ số', style: tieuDe)),
            o('TB', flex: 4, style: tieuDe),
            o('Thấp', flex: 4, style: tieuDe),
            o('Cao', flex: 4, style: tieuDe),
            o('Lần', flex: 3, style: tieuDe),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        for (final tk in duLieu) ...[
          Divider(color: p.border),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              children: [
                Expanded(
                  flex: 9,
                  child: Row(
                    children: [
                      Icon(
                        NhomChiSo.cua(tk.loai.ma).icon,
                        size: 16,
                        color: NhomChiSo.cua(tk.loai.ma).mau(p),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              tk.loai.tenChiSo.replaceFirst('Huyết áp', 'HA'),
                              style: context.text.labelLarge,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(tk.loai.donViDo, style: tieuDe),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                o(
                  tk.loai.dinhDang(
                    tk.loai.soThapPhan == 0
                        ? tk.trungBinh.roundToDouble()
                        : tk.trungBinh,
                  ),
                  flex: 4,
                  style: context.text.labelLarge!.copyWith(color: p.primary),
                ),
                o(tk.loai.dinhDang(tk.nhoNhat), flex: 4),
                o(tk.loai.dinhDang(tk.lonNhat), flex: 4),
                o(
                  '${tk.soLan}',
                  flex: 3,
                  style: context.text.bodyMedium!.copyWith(
                    color: p.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

/// Xếp hạng những người có nhiều cảnh báo nhất.
class XepHangCanhBaoList extends StatelessWidget {
  const XepHangCanhBaoList({super.key, required this.duLieu});

  final List<XepHangCanhBao> duLieu;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;

    if (duLieu.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
        child: Center(
          child: Text(
            'Không có cảnh báo nào trong khoảng này',
            style: context.text.bodySmall,
          ),
        ),
      );
    }
    final lonNhat = duLieu.first.soCanhBao;

    return Column(
      children: [
        for (final hang in duLieu)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 7),
            child: Row(
              children: [
                AvatarNguoiDung(nguoiDung: hang.nguoiDung, size: 36),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              hang.nguoiDung.hoTen,
                              style: context.text.labelLarge,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            '${hang.soCanhBao}',
                            style: context.text.titleSmall!.copyWith(
                              color: p.warning,
                            ),
                          ),
                          Text(
                            ' / ${hang.soLanDo} lần đo',
                            style: context.text.labelSmall,
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(3),
                        child: LinearProgressIndicator(
                          value: hang.soCanhBao / lonNhat,
                          minHeight: 6,
                          color: p.warning,
                          backgroundColor: p.surfaceMuted,
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
