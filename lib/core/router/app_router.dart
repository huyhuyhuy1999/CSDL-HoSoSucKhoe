import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

import '../../app/main_shell_screen.dart';
import '../../features/canh_bao/presentation/screen/canh_bao_screen.dart';
import '../../features/ho_so/presentation/screen/ho_so_chi_tiet_screen.dart';
import '../../features/ho_so/presentation/screen/ho_so_form_screen.dart';
import '../../features/ho_so/presentation/screen/ho_so_list_screen.dart';
import '../../features/lan_do/presentation/screen/lan_do_chi_tiet_screen.dart';
import '../../features/lan_do/presentation/screen/lan_do_form_screen.dart';
import '../../features/lan_do/presentation/screen/lich_su_do_screen.dart';
import '../../features/thiet_bi/presentation/screen/thiet_bi_screen.dart';
import '../../features/thong_ke/presentation/screen/thong_ke_screen.dart';
import '../../features/tong_quan/presentation/screen/tong_quan_screen.dart';

part 'app_router.gr.dart';

/// Thứ tự các tab trong thanh điều hướng dưới.
abstract final class AppTab {
  static const int tongQuan = 0;
  static const int hoSo = 1;
  static const int lichSu = 2;
  static const int canhBao = 3;
  static const int thongKe = 4;
}

@AutoRouterConfig(replaceInRouteName: 'Screen,Route')
class AppRouter extends RootStackRouter {
  @override
  RouteType get defaultRouteType => const RouteType.adaptive();

  @override
  List<AutoRoute> get routes => [
    AutoRoute(
      page: MainShellRoute.page,
      path: '/',
      children: [
        AutoRoute(page: TongQuanRoute.page, path: 'tong-quan', initial: true),
        AutoRoute(page: HoSoListRoute.page, path: 'ho-so'),
        AutoRoute(page: LichSuDoRoute.page, path: 'lich-su'),
        AutoRoute(page: CanhBaoRoute.page, path: 'canh-bao'),
        AutoRoute(page: ThongKeRoute.page, path: 'thong-ke'),
      ],
    ),
    AutoRoute(page: HoSoChiTietRoute.page, path: '/ho-so/:maNguoiDung'),
    AutoRoute(page: HoSoFormRoute.page, path: '/ho-so-form'),
    AutoRoute(page: LichSuNguoiDungRoute.page, path: '/lich-su/:maNguoiDung'),
    AutoRoute(page: LanDoChiTietRoute.page, path: '/lan-do/:maLanDo'),
    AutoRoute(page: LanDoFormRoute.page, path: '/lan-do-form'),
    AutoRoute(page: ThietBiRoute.page, path: '/thiet-bi'),
  ];
}
