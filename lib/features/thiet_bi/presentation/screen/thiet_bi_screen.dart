import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_icons.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/dinh_dang.dart';
import '../../../../core/utils/ma_hien_thi.dart';
import '../../../../core/utils/trang_thai_tai.dart';
import '../../../../core/widgets/app_badge.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_inputs.dart';
import '../../../../core/widgets/state_views.dart';
import '../../domain/entity/thiet_bi.dart';
import '../cubit/thiet_bi_cubit.dart';

@RoutePage()
class ThietBiScreen extends StatelessWidget {
  const ThietBiScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<ThietBiCubit>()..tai(),
      child: const _ThietBiView(),
    );
  }
}

extension on TrangThaiThietBi {
  (Color, Color) mau(AppPalette p) => switch (this) {
    TrangThaiThietBi.hoatDong => (p.success, p.successSoft),
    TrangThaiThietBi.baoTri => (p.warning, p.warningSoft),
    TrangThaiThietBi.ngungSuDung => (p.textSecondary, p.surfaceMuted),
  };
}

extension on LoaiThietBi {
  IconData get icon => switch (this) {
    LoaiThietBi.daChiSo => PhosphorIconsFill.cpu,
    LoaiThietBi.spo2 => PhosphorIconsFill.drop,
    LoaiThietBi.nhietKe => PhosphorIconsFill.thermometerSimple,
    LoaiThietBi.huyetAp => PhosphorIconsFill.pulse,
  };
}

class _ThietBiView extends StatelessWidget {
  const _ThietBiView();

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ThietBiCubit>();
    final p = context.palette;

    return Scaffold(
      appBar: AppBar(title: const Text('Thiết bị đo')),
      body: BlocBuilder<ThietBiCubit, ThietBiState>(
        builder: (context, state) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.page,
                  AppSpacing.sm,
                  AppSpacing.page,
                  AppSpacing.md,
                ),
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: p.infoSoft,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(PhosphorIconsFill.info, size: 18, color: p.info),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          'Thiết bị và dữ liệu đo là dữ liệu mô phỏng, không '
                          'kết nối phần cứng thật.',
                          style: context.text.bodySmall!.copyWith(
                            color: p.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.page,
                ),
                child: AppSearchField(
                  hintText: 'Tìm theo tên hoặc mã định danh…',
                  onChanged: cubit.timKiem,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              ChipRow(
                children: [
                  AppChoiceChip(
                    label: 'Tất cả',
                    selected: state.trangThaiLoc == null,
                    onTap: () => cubit.chonTrangThai(null),
                  ),
                  for (final trangThai in TrangThaiThietBi.values)
                    AppChoiceChip(
                      label: trangThai.nhan,
                      selected: state.trangThaiLoc == trangThai,
                      onTap: () => cubit.chonTrangThai(trangThai),
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Expanded(
                child: switch (state.trangThai) {
                  TrangThaiTai.dangTai => const AppLoading(),
                  TrangThaiTai.loi => AppErrorState(
                    message: state.loi ?? '',
                    onRetry: cubit.tai,
                  ),
                  TrangThaiTai.thanhCong when state.danhSach.isEmpty =>
                    const AppEmptyState(
                      icon: PhosphorIconsRegular.cpu,
                      title: 'Không tìm thấy thiết bị',
                      message: 'Thử đổi từ khóa hoặc bộ lọc trạng thái.',
                    ),
                  TrangThaiTai.thanhCong => ListView.separated(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.page,
                      AppSpacing.sm,
                      AppSpacing.page,
                      AppSpacing.xxxl,
                    ),
                    itemCount: state.danhSach.length,
                    separatorBuilder: (_, _) =>
                        const SizedBox(height: AppSpacing.md),
                    itemBuilder: (context, i) =>
                        _ThietBiCard(thietBi: state.danhSach[i]),
                  ),
                },
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ThietBiCard extends StatelessWidget {
  const _ThietBiCard({required this.thietBi});

  final ThietBiTongHop thietBi;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final tb = thietBi.thietBi;
    final (mau, nen) = tb.trangThai.mau(p);
    final dangDung = tb.trangThai == TrangThaiThietBi.hoatDong;

    return AppCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconBadge(
                icon: tb.loaiThietBi.icon,
                color: dangDung ? p.primary : p.textSecondary,
                background: dangDung ? p.primarySoft : p.surfaceMuted,
                size: 46,
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tb.tenThietBi,
                      style: context.text.titleSmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${MaHienThi.thietBi(tb.maThietBi)} · ${tb.loaiThietBi.nhan}',
                      style: context.text.bodySmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              AppBadge(
                label: tb.trangThai.nhan,
                color: mau,
                background: nen,
                dense: true,
              ),
            ],
          ),
          if (tb.moTa.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            Text(tb.moTa, style: context.text.bodySmall),
          ],
          const SizedBox(height: AppSpacing.md),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
            decoration: BoxDecoration(
              color: p.surfaceMuted,
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Row(
              children: [
                Icon(
                  PhosphorIconsRegular.barcode,
                  size: 16,
                  color: p.textTertiary,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    tb.maDinhDanh,
                    style: context.text.labelMedium!.copyWith(
                      letterSpacing: 0.3,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Icon(
                PhosphorIconsRegular.clockCounterClockwise,
                size: 15,
                color: p.textTertiary,
              ),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  thietBi.lanDoCuoi == null
                      ? 'Chưa có lần đo nào'
                      : '${thietBi.soLanDo} lần đo · gần nhất '
                            '${DinhDang.ngay(thietBi.lanDoCuoi!)}',
                  style: context.text.bodySmall,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
