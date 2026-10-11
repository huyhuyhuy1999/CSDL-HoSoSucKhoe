import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../core/di/injection.dart';
import '../core/extensions/context_extensions.dart';
import '../core/router/app_router.dart';
import '../core/theme/app_icons.dart';
import '../features/canh_bao/presentation/cubit/canh_bao_cubit.dart';

/// Khung chính: năm tab với thanh điều hướng dưới.
@RoutePage()
class MainShellScreen extends StatelessWidget {
  const MainShellScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<SoCanhBaoCubit>()..tai(),
      child: AutoTabsRouter(
        routes: const [
          TongQuanRoute(),
          HoSoListRoute(),
          LichSuDoRoute(),
          CanhBaoRoute(),
          ThongKeRoute(),
        ],
        builder: (context, child) {
          final tabsRouter = AutoTabsRouter.of(context);

          return Scaffold(
            body: child,
            bottomNavigationBar: _BottomBar(
              index: tabsRouter.activeIndex,
              onChanged: tabsRouter.setActiveIndex,
            ),
          );
        },
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  const _BottomBar({required this.index, required this.onChanged});

  final int index;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;

    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: p.border)),
      ),
      child: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: onChanged,
        destinations: [
          const NavigationDestination(
            icon: Icon(PhosphorIconsRegular.house),
            selectedIcon: Icon(PhosphorIconsFill.house),
            label: 'Tổng quan',
          ),
          const NavigationDestination(
            icon: Icon(PhosphorIconsRegular.folderUser),
            selectedIcon: Icon(PhosphorIconsFill.folderUser),
            label: 'Hồ sơ',
          ),
          const NavigationDestination(
            icon: Icon(PhosphorIconsRegular.clockCounterClockwise),
            selectedIcon: Icon(PhosphorIconsFill.clockCounterClockwise),
            label: 'Lịch sử',
          ),
          NavigationDestination(
            icon: const _IconCanhBao(icon: PhosphorIconsRegular.bell),
            selectedIcon: const _IconCanhBao(icon: PhosphorIconsFill.bell),
            label: 'Cảnh báo',
          ),
          const NavigationDestination(
            icon: Icon(PhosphorIconsRegular.chartBar),
            selectedIcon: Icon(PhosphorIconsFill.chartBar),
            label: 'Thống kê',
          ),
        ],
      ),
    );
  }
}

/// Icon chuông kèm số cảnh báo chưa xem.
class _IconCanhBao extends StatelessWidget {
  const _IconCanhBao({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;

    return BlocBuilder<SoCanhBaoCubit, int>(
      builder: (context, soChuaXem) {
        return Badge(
          isLabelVisible: soChuaXem > 0,
          label: Text(soChuaXem > 99 ? '99+' : '$soChuaXem'),
          backgroundColor: p.danger,
          textColor: Colors.white,
          child: Icon(icon),
        );
      },
    );
  }
}
