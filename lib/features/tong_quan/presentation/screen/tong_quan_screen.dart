import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/theme_cubit.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_icons.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/dinh_dang.dart';
import '../../../../core/utils/trang_thai_tai.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/page_header.dart';
import '../../../../core/widgets/section_header.dart';
import '../../../../core/widgets/state_views.dart';
import '../../../canh_bao/presentation/widgets/canh_bao_card.dart';
import '../../../lan_do/presentation/utils/chi_so_ui.dart';
import '../../../lan_do/presentation/widgets/lan_do_card.dart';
import '../../domain/entity/tong_quan.dart';
import '../cubit/tong_quan_cubit.dart';
import '../widgets/hero_card.dart';
import '../widgets/stat_card.dart';
import '../widgets/xu_huong_card.dart';

@RoutePage()
class TongQuanScreen extends StatelessWidget {
  const TongQuanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<TongQuanCubit>()..tai(),
      child: const _TongQuanView(),
    );
  }
}

class _TongQuanView extends StatelessWidget {
  const _TongQuanView();

  @override
  Widget build(BuildContext context) {
    final header = PageHeader(
      title: 'Tổng quan',
      subtitle: DinhDang.ngayDayDu(DateTime.now()),
      actions: [
        AppIconButton(
          icon: context.isDark
              ? PhosphorIconsRegular.sun
              : PhosphorIconsRegular.moon,
          tooltip: context.isDark ? 'Giao diện sáng' : 'Giao diện tối',
          onTap: () =>
              context.read<ThemeCubit>().doiCheDo(Theme.of(context).brightness),
        ),
        AppIconButton(
          icon: PhosphorIconsRegular.cpu,
          tooltip: 'Thiết bị',
          onTap: () => context.router.push(const ThietBiRoute()),
        ),
      ],
    );

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: BlocBuilder<TongQuanCubit, TongQuanState>(
          builder: (context, state) {
            final duLieu = state.duLieu;
            if (duLieu == null) {
              return Column(
                children: [
                  header,
                  Expanded(
                    child: state.trangThai == TrangThaiTai.loi
                        ? AppErrorState(
                            message: state.loi ?? '',
                            onRetry: context.read<TongQuanCubit>().tai,
                          )
                        : const AppLoading(),
                  ),
                ],
              );
            }

            return RefreshIndicator(
              onRefresh: () => context.read<TongQuanCubit>().tai(imLang: true),
              child: ListView(
                padding: const EdgeInsets.only(bottom: AppSpacing.xxxl),
                children: [
                  header,
                  _NoiDung(duLieu: duLieu),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _NoiDung extends StatelessWidget {
  const _NoiDung({required this.duLieu});

  final TongQuan duLieu;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final tabsRouter = AutoTabsRouter.of(context);
    const lePhai = EdgeInsets.symmetric(horizontal: AppSpacing.page);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: lePhai,
          child: HeroCard(
            lanDoHomNay: duLieu.lanDoHomNay,
            canhBaoHomNay: duLieu.canhBaoHomNay,
            canhBaoChuaXem: duLieu.canhBaoChuaXem,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Padding(
          padding: lePhai,
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: StatCard(
                      icon: PhosphorIconsFill.folderUser,
                      color: p.primary,
                      background: p.primarySoft,
                      value: '${duLieu.soHoSo}',
                      label: 'Hồ sơ',
                      onTap: () => tabsRouter.setActiveIndex(AppTab.hoSo),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: StatCard(
                      icon: PhosphorIconsFill.clockCounterClockwise,
                      color: p.info,
                      background: p.infoSoft,
                      value: '${duLieu.tongLanDo}',
                      label: 'Lần đo',
                      onTap: () => tabsRouter.setActiveIndex(AppTab.lichSu),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: StatCard(
                      icon: PhosphorIconsFill.bell,
                      color: p.warning,
                      background: p.warningSoft,
                      value: '${duLieu.canhBaoChuaXem}',
                      label: 'Cảnh báo mới',
                      onTap: () => tabsRouter.setActiveIndex(AppTab.canhBao),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: StatCard(
                      icon: PhosphorIconsFill.cpu,
                      color: p.huyetAp,
                      background: p.huyetApSoft,
                      value: '${duLieu.thietBiHoatDong}/${duLieu.tongThietBi}',
                      label: 'Thiết bị',
                      onTap: () => context.router.push(const ThietBiRoute()),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xxl),
        Padding(
          padding: lePhai,
          child: SectionHeader(
            title: 'Trung bình 7 ngày',
            actionLabel: 'Thống kê',
            onAction: () => tabsRouter.setActiveIndex(AppTab.thongKe),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        SizedBox(
          height: 152,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: lePhai,
            itemCount: NhomChiSo.values.length,
            separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.md),
            itemBuilder: (context, i) =>
                XuHuongCard(nhom: NhomChiSo.values[i], xuHuong: duLieu.xuHuong),
          ),
        ),
        const SizedBox(height: AppSpacing.xxl),
        Padding(
          padding: lePhai,
          child: SectionHeader(
            title: 'Cảnh báo gần đây',
            actionLabel: 'Xem tất cả',
            onAction: () => tabsRouter.setActiveIndex(AppTab.canhBao),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Padding(
          padding: lePhai,
          child: duLieu.canhBaoGanDay.isEmpty
              ? const _TrongNho(
                  icon: PhosphorIconsRegular.checkCircle,
                  text: 'Chưa có cảnh báo nào.',
                )
              : Column(
                  children: [
                    for (final cb in duLieu.canhBaoGanDay)
                      Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.md),
                        child: CanhBaoCard(
                          canhBao: cb,
                          onTap: () => context.router.push(
                            LanDoChiTietRoute(maLanDo: cb.canhBao.maLanDo),
                          ),
                        ),
                      ),
                  ],
                ),
        ),
        const SizedBox(height: AppSpacing.md),
        Padding(
          padding: lePhai,
          child: SectionHeader(
            title: 'Lần đo gần đây',
            actionLabel: 'Xem tất cả',
            onAction: () => tabsRouter.setActiveIndex(AppTab.lichSu),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Padding(
          padding: lePhai,
          child: duLieu.lanDoGanDay.isEmpty
              ? const _TrongNho(
                  icon: PhosphorIconsRegular.clockCounterClockwise,
                  text: 'Chưa có lần đo nào trong 7 ngày qua.',
                )
              : Column(
                  children: [
                    for (final ld in duLieu.lanDoGanDay)
                      Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.md),
                        child: LanDoCard(
                          lanDo: ld,
                          hienNgay: true,
                          onTap: () => context.router.push(
                            LanDoChiTietRoute(maLanDo: ld.lanDo.maLanDo),
                          ),
                        ),
                      ),
                  ],
                ),
        ),
      ],
    );
  }
}

/// Dòng thông báo "không có dữ liệu" gọn trong một thẻ.
class _TrongNho extends StatelessWidget {
  const _TrongNho({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;

    return AppCard(
      child: Row(
        children: [
          Icon(icon, color: p.textTertiary),
          const SizedBox(width: AppSpacing.md),
          Expanded(child: Text(text, style: context.text.bodySmall)),
        ],
      ),
    );
  }
}
