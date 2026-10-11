import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_icons.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/dinh_dang.dart';
import '../../../../core/utils/trang_thai_tai.dart';
import '../../../../core/widgets/app_badge.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/dialogs.dart';
import '../../../../core/widgets/section_header.dart';
import '../../../../core/widgets/state_views.dart';
import '../../../canh_bao/presentation/widgets/canh_bao_card.dart';
import '../../../ho_so/presentation/widgets/avatar_nguoi_dung.dart';
import '../../domain/entity/lan_do.dart';
import '../../domain/entity/muc_do.dart';
import '../cubit/lan_do_chi_tiet_cubit.dart';
import '../utils/chi_so_ui.dart';
import '../widgets/muc_do_badge.dart';
import '../widgets/thanh_nguong.dart';

@RoutePage()
class LanDoChiTietScreen extends StatelessWidget {
  const LanDoChiTietScreen({
    super.key,
    @PathParam('maLanDo') required this.maLanDo,
  });

  final String maLanDo;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<LanDoChiTietCubit>()..tai(maLanDo),
      child: _LanDoChiTietView(maLanDo: maLanDo),
    );
  }
}

class _LanDoChiTietView extends StatelessWidget {
  const _LanDoChiTietView({required this.maLanDo});

  final String maLanDo;

  Future<void> _xoa(BuildContext context) async {
    final cubit = context.read<LanDoChiTietCubit>();
    final dongY = await xacNhan(
      context,
      tieuDe: 'Xóa lần đo?',
      noiDung:
          'Lần đo $maLanDo cùng các cảnh báo của nó sẽ bị xóa. '
          'Thao tác này không thể hoàn tác.',
      nhanDongY: 'Xóa',
      nguyHiem: true,
    );
    if (!dongY || !context.mounted) return;

    final loi = await cubit.xoa();
    if (!context.mounted) return;
    if (loi != null) {
      context.showSnack(loi);
      return;
    }
    context.showSnack('Đã xóa lần đo $maLanDo.');
    context.router.maybePop();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LanDoChiTietCubit, LanDoChiTietState>(
      builder: (context, state) {
        final lanDo = state.lanDo;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Chi tiết lần đo'),
            actions: [
              if (lanDo != null)
                IconButton(
                  tooltip: 'Xóa lần đo',
                  icon: const Icon(PhosphorIconsRegular.trash),
                  onPressed: () => _xoa(context),
                ),
              const SizedBox(width: 4),
            ],
          ),
          body: switch (state.trangThai) {
            TrangThaiTai.dangTai when lanDo == null => const AppLoading(),
            TrangThaiTai.loi when lanDo == null => AppErrorState(
              message: state.loi ?? '',
              onRetry: () => context.read<LanDoChiTietCubit>().tai(maLanDo),
            ),
            _ => _NoiDung(state: state, lanDo: lanDo!),
          },
        );
      },
    );
  }
}

class _NoiDung extends StatelessWidget {
  const _NoiDung({required this.state, required this.lanDo});

  final LanDoChiTietState state;
  final LanDoDayDu lanDo;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.page,
        AppSpacing.sm,
        AppSpacing.page,
        AppSpacing.xxxl,
      ),
      children: [
        _KetLuan(lanDo: lanDo),
        const SizedBox(height: AppSpacing.md),
        _ThongTin(lanDo: lanDo),
        const SizedBox(height: AppSpacing.xxl),
        SectionHeader(
          title: 'Chỉ số đo được',
          trailing: Text(
            '${lanDo.ketQua.length} chỉ số',
            style: context.text.bodySmall,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        for (final kq in lanDo.ketQua)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: _ChiSoChiTiet(ketQua: kq),
          ),
        if (state.canhBao.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.md),
          SectionHeader(
            title: 'Cảnh báo',
            trailing: Text(
              '${state.canhBao.length} cảnh báo',
              style: context.text.bodySmall,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          for (final cb in state.canhBao)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: CanhBaoCard(
                canhBao: cb,
                hienNguoiDung: false,
                hienNoiDung: true,
              ),
            ),
        ],
        if (lanDo.lanDo.ghiChu.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.md),
          const SectionHeader(title: 'Ghi chú'),
          const SizedBox(height: AppSpacing.md),
          AppCard(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  PhosphorIconsRegular.notePencil,
                  size: 18,
                  color: p.textTertiary,
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    lanDo.lanDo.ghiChu,
                    style: context.text.bodyMedium,
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

/// Dải kết luận tô màu theo mức độ nặng nhất của lần đo.
class _KetLuan extends StatelessWidget {
  const _KetLuan({required this.lanDo});

  final LanDoDayDu lanDo;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final mucDo = lanDo.mucDo;
    final mau = mucDo.mau(p);
    final soBatThuong = lanDo.ketQua
        .where((kq) => kq.mucDo != MucDo.binhThuong)
        .length;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: mucDo.mauNen(p),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: mau.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          Icon(mucDo.icon, color: mau, size: 34),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  mucDo.nhan,
                  style: context.text.titleMedium!.copyWith(color: mau),
                ),
                const SizedBox(height: 2),
                Text(
                  soBatThuong == 0
                      ? 'Mọi chỉ số đều trong khoảng bình thường.'
                      : '$soBatThuong/${lanDo.ketQua.length} chỉ số nằm '
                            'ngoài khoảng bình thường.',
                  style: context.text.bodySmall!.copyWith(color: p.textPrimary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ThongTin extends StatelessWidget {
  const _ThongTin({required this.lanDo});

  final LanDoDayDu lanDo;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final nd = lanDo.nguoiDung;
    final thietBi = lanDo.thietBi;
    final dong = [
      (
        PhosphorIconsRegular.clock,
        'Thời gian đo',
        DinhDang.ngayGio(lanDo.lanDo.thoiGianDo),
      ),
      (lanDo.lanDo.nguon.icon, 'Nguồn dữ liệu', lanDo.lanDo.nguon.nhan),
      if (thietBi != null) ...[
        (PhosphorIconsRegular.deviceMobile, 'Thiết bị', thietBi.tenThietBi),
        (PhosphorIconsRegular.barcode, 'Mã định danh', thietBi.maDinhDanh),
      ],
      (PhosphorIconsRegular.hash, 'Mã lần đo', lanDo.lanDo.maLanDo),
    ];

    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          InkWell(
            onTap: () => context.router.push(
              HoSoChiTietRoute(maNguoiDung: nd.maNguoiDung),
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Row(
                children: [
                  AvatarNguoiDung(nguoiDung: nd, size: 46),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(nd.hoTen, style: context.text.titleMedium),
                        const SizedBox(height: 2),
                        Text(
                          '${nd.gioiTinh.nhan} · ${nd.tuoi} tuổi · '
                          '${nd.maNguoiDung}',
                          style: context.text.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    PhosphorIconsRegular.caretRight,
                    size: 18,
                    color: p.textTertiary,
                  ),
                ],
              ),
            ),
          ),
          Divider(color: p.border),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.sm,
            ),
            child: Column(
              children: [
                for (final (icon, nhan, giaTri) in dong)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 7),
                    child: Row(
                      children: [
                        Icon(icon, size: 17, color: p.textTertiary),
                        const SizedBox(width: AppSpacing.md),
                        Text(nhan, style: context.text.bodySmall),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Text(
                            giaTri,
                            style: context.text.labelLarge,
                            textAlign: TextAlign.right,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Thẻ của một chỉ số: giá trị, đánh giá và vị trí trên thanh ngưỡng.
class _ChiSoChiTiet extends StatelessWidget {
  const _ChiSoChiTiet({required this.ketQua});

  final KetQuaChiSo ketQua;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final loai = ketQua.loai;
    final nhom = NhomChiSo.cua(loai.ma);
    final mucDo = ketQua.mucDo;

    return AppCard(
      child: Column(
        children: [
          Row(
            children: [
              IconBadge(
                icon: nhom.icon,
                color: nhom.mau(p),
                background: nhom.mauNen(p),
                size: 42,
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(loai.tenChiSo, style: context.text.titleSmall),
                    const SizedBox(height: 5),
                    MucDoBadge(mucDo: mucDo, dense: true),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                ketQua.giaTriHienThi,
                style: AppTypography.number(
                  28,
                  mucDo == MucDo.binhThuong ? p.textPrimary : mucDo.mau(p),
                ),
              ),
              const SizedBox(width: 4),
              Padding(
                padding: const EdgeInsets.only(top: 9),
                child: Text(loai.donViDo, style: context.text.labelSmall),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          ThanhNguong(loai: loai, giaTri: ketQua.giaTri),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Text('Khoảng bình thường', style: context.text.labelSmall),
              const Spacer(),
              Text(
                loai.khoangBinhThuong,
                style: context.text.labelSmall!.copyWith(
                  color: p.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
