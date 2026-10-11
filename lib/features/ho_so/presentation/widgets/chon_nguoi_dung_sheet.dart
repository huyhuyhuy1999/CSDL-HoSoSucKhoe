import 'package:flutter/material.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_icons.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/chuoi.dart';
import '../../../../core/widgets/app_inputs.dart';
import '../../domain/entity/nguoi_dung.dart';
import 'avatar_nguoi_dung.dart';

/// Kết quả chọn người dùng: [maNguoiDung] là `null` khi chọn "Tất cả".
typedef LuaChonNguoiDung = ({String? maNguoiDung});

/// Mở bảng chọn người dùng. Trả về `null` nếu người dùng đóng bảng mà
/// không chọn gì.
Future<LuaChonNguoiDung?> chonNguoiDung(
  BuildContext context, {
  required List<NguoiDung> danhSach,
  String? maDangChon,
  bool choPhepTatCa = true,
}) {
  return showModalBottomSheet<LuaChonNguoiDung>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (context) => _ChonNguoiDungSheet(
      danhSach: danhSach,
      maDangChon: maDangChon,
      choPhepTatCa: choPhepTatCa,
    ),
  );
}

class _ChonNguoiDungSheet extends StatefulWidget {
  const _ChonNguoiDungSheet({
    required this.danhSach,
    required this.maDangChon,
    required this.choPhepTatCa,
  });

  final List<NguoiDung> danhSach;
  final String? maDangChon;
  final bool choPhepTatCa;

  @override
  State<_ChonNguoiDungSheet> createState() => _ChonNguoiDungSheetState();
}

class _ChonNguoiDungSheetState extends State<_ChonNguoiDungSheet> {
  String _tuKhoa = '';

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final ketQua = [
      for (final nd in widget.danhSach)
        if (khopTuKhoa(nd.hoTen, _tuKhoa)) nd,
    ];
    final hienTatCa = widget.choPhepTatCa && _tuKhoa.isEmpty;

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SizedBox(
        height: MediaQuery.sizeOf(context).height * 0.7,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.page),
              child: Text('Chọn người được đo', style: context.text.titleLarge),
            ),
            const SizedBox(height: AppSpacing.md),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.page),
              child: AppSearchField(
                hintText: 'Tìm theo họ tên…',
                onChanged: (value) => setState(() => _tuKhoa = value),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.only(bottom: AppSpacing.lg),
                itemCount: ketQua.length + (hienTatCa ? 1 : 0),
                itemBuilder: (context, i) {
                  if (hienTatCa && i == 0) {
                    return _Dong(
                      leading: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: p.surfaceMuted,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          PhosphorIconsRegular.users,
                          size: 20,
                          color: p.textSecondary,
                        ),
                      ),
                      tieuDe: 'Tất cả mọi người',
                      dangChon: widget.maDangChon == null,
                      onTap: () =>
                          Navigator.of(context).pop((maNguoiDung: null)),
                    );
                  }
                  final nd = ketQua[i - (hienTatCa ? 1 : 0)];
                  return _Dong(
                    leading: AvatarNguoiDung(nguoiDung: nd, size: 40),
                    tieuDe: nd.hoTen,
                    phu: '${nd.gioiTinh.nhan} · ${nd.tuoi} tuổi',
                    dangChon: widget.maDangChon == nd.maNguoiDung,
                    onTap: () =>
                        Navigator.of(context)
                            .pop((maNguoiDung: nd.maNguoiDung)),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Dong extends StatelessWidget {
  const _Dong({
    required this.leading,
    required this.tieuDe,
    required this.dangChon,
    required this.onTap,
    this.phu,
  });

  final Widget leading;
  final String tieuDe;
  final String? phu;
  final bool dangChon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.page,
          vertical: 10,
        ),
        child: Row(
          children: [
            leading,
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(tieuDe, style: context.text.titleSmall),
                  if (phu != null) Text(phu!, style: context.text.bodySmall),
                ],
              ),
            ),
            if (dangChon)
              Icon(PhosphorIconsBold.check, size: 18, color: p.primary),
          ],
        ),
      ),
    );
  }
}
