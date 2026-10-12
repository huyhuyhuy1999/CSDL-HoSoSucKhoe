// Công cụ chụp ảnh các màn hình của app vào docs/screenshots/.
//
// Đây không phải test kiểm tra đúng/sai: nó dựng app với font thật, đi qua
// từng màn hình rồi lưu ảnh PNG để đưa vào README và báo cáo.
//
// Chạy:  flutter test tool/chup_man_hinh_test.dart

import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ho_so_suc_khoe/app/app.dart';
import 'package:ho_so_suc_khoe/app/theme_cubit.dart';
import 'package:ho_so_suc_khoe/core/di/injection.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

const _thuMucAnh = 'docs/screenshots';

/// Kích thước logic của iPhone 6,3 inch và vùng an toàn trên / dưới.
const _kichThuoc = Size(402, 874);
const _tiLeDiemAnh = 3.0;
const _leTren = 59.0;
const _leDuoi = 34.0;

final _khoaChup = GlobalKey();

Future<void> _napFont() async {
  Future<void> nap(String family, List<String> duongDan) async {
    final loader = FontLoader(family);
    for (final file in duongDan) {
      final bytes = File(file).readAsBytesSync();
      loader.addFont(Future.value(ByteData.sublistView(bytes)));
    }
    await loader.load();
  }

  await nap('BeVietnamPro', [
    for (final kieu in ['Regular', 'Medium', 'SemiBold', 'Bold'])
      'assets/fonts/BeVietnamPro-$kieu.ttf',
  ]);
  for (final kieu in ['Regular', 'Fill', 'Bold']) {
    await nap('Phosphor$kieu', ['assets/fonts/phosphor/Phosphor-$kieu.ttf']);
  }
  final flutterRoot = Platform.environment['FLUTTER_ROOT'];
  if (flutterRoot != null) {
    await nap('MaterialIcons', [
      '$flutterRoot/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf',
    ]);
  }
}

Future<void> _chup(WidgetTester tester, String ten) async {
  await tester.pumpAndSettle();
  final boundary =
      _khoaChup.currentContext!.findRenderObject()! as RenderRepaintBoundary;
  final bytes = await tester.runAsync(() async {
    final image = await boundary.toImage(pixelRatio: _tiLeDiemAnh);
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    image.dispose();
    return data!.buffer.asUint8List();
  });
  File('$_thuMucAnh/$ten.png').writeAsBytesSync(bytes!);
}

Future<void> _moApp(WidgetTester tester, {required bool toi}) async {
  tester.view.devicePixelRatio = _tiLeDiemAnh;
  tester.view.physicalSize = _kichThuoc * _tiLeDiemAnh;
  const le = FakeViewPadding(
    top: _leTren * _tiLeDiemAnh,
    bottom: _leDuoi * _tiLeDiemAnh,
  );
  tester.view.padding = le;
  tester.view.viewPadding = le;
  addTearDown(tester.view.reset);

  if (toi) getIt<ThemeCubit>().doiCheDo(Brightness.light);
  await tester.pumpWidget(RepaintBoundary(key: _khoaChup, child: const App()));
  await tester.pumpAndSettle();
}

Future<void> _moTab(WidgetTester tester, String nhan) async {
  await tester.tap(
    find.descendant(of: find.byType(NavigationBar), matching: find.text(nhan)),
  );
  await tester.pumpAndSettle();
}

Future<void> _cuon(WidgetTester tester, double khoangCach) async {
  await tester.drag(
    find.byType(ListView).last,
    Offset(0, -khoangCach),
    warnIfMissed: false,
  );
  await tester.pumpAndSettle();
}

Future<void> _quayLai(WidgetTester tester) async {
  await tester.tap(find.byType(BackButton).last);
  await tester.pumpAndSettle();
}

/// Mở chi tiết hồ sơ của Đặng Quốc Huy từ tab Hồ sơ.
Future<void> _moHoSoMau(WidgetTester tester) async {
  await _moTab(tester, 'Hồ sơ');
  await tester.enterText(find.byType(TextField), 'Quốc Huy');
  await tester.pumpAndSettle();
  await tester.tap(find.text('Đặng Quốc Huy'));
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(() async {
    Directory(_thuMucAnh).createSync(recursive: true);
    Intl.defaultLocale = 'vi';
    await initializeDateFormatting('vi');
    await _napFont();
  });

  setUp(() async {
    await configureDependencies(csdlTrongBoNho: true);
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    debugDisableShadows = false;
  });

  tearDown(getIt.reset);

  /// Các biến debug phải được trả về mặc định trước khi test kết thúc.
  void khoiPhucDebug() {
    debugDefaultTargetPlatformOverride = null;
    debugDisableShadows = true;
  }

  testWidgets('giao diện sáng', (tester) async {
    await _moApp(tester, toi: false);

    await _chup(tester, '01_tong_quan');
    await _cuon(tester, 560);
    await _chup(tester, '02_tong_quan_gan_day');

    await _moTab(tester, 'Hồ sơ');
    await _chup(tester, '03_ho_so_danh_sach');

    await tester.enterText(find.byType(TextField), 'Quốc Huy');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Đặng Quốc Huy'));
    await _chup(tester, '04_ho_so_chi_tiet');
    await _cuon(tester, 600);
    await _chup(tester, '05_ho_so_chi_so_xu_huong');
    await _cuon(tester, 620);
    await _chup(tester, '06_ho_so_lan_do_gan_day');

    // Form sửa hồ sơ.
    await tester.tap(find.byTooltip('Sửa hồ sơ'));
    await _chup(tester, '07_form_ho_so');
    await _quayLai(tester);

    // Form thêm lần đo, nhập thử một giá trị vượt ngưỡng.
    await tester.tap(find.text('Thêm lần đo'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).at(0), '38,9');
    await tester.enterText(find.byType(TextFormField).at(1), '104');
    await _chup(tester, '08_form_lan_do');
    await _quayLai(tester);
    await _quayLai(tester);

    await _moTab(tester, 'Lịch sử');
    await _chup(tester, '09_lich_su_do');

    // Mở lần đo đầu tiên trong lịch sử (của Đặng Quốc Huy, có cảnh báo).
    await tester.tap(find.text('Đặng Quốc Huy').first);
    await _chup(tester, '10_lan_do_chi_tiet');
    await _cuon(tester, 700);
    await _chup(tester, '11_lan_do_canh_bao');
    await _quayLai(tester);

    await _moTab(tester, 'Cảnh báo');
    await _chup(tester, '12_canh_bao');

    await _moTab(tester, 'Thống kê');
    await _chup(tester, '13_thong_ke');
    await _cuon(tester, 520);
    await _chup(tester, '14_thong_ke_bieu_do');
    await _cuon(tester, 640);
    await _chup(tester, '15_thong_ke_bang');

    await _moTab(tester, 'Tổng quan');
    await _cuon(tester, -2000);
    await tester.tap(find.byTooltip('Thiết bị'));
    await _chup(tester, '16_thiet_bi');
    await _quayLai(tester);

    await tester.tap(find.byTooltip('Cơ sở dữ liệu'));
    await _chup(tester, '17_co_so_du_lieu');

    khoiPhucDebug();
  });

  testWidgets('giao diện tối', (tester) async {
    await _moApp(tester, toi: true);
    await _chup(tester, '21_toi_tong_quan');

    await _moHoSoMau(tester);
    await _cuon(tester, 600);
    await _chup(tester, '22_toi_ho_so_chi_tiet');
    await _quayLai(tester);

    await _moTab(tester, 'Lịch sử');
    await tester.tap(find.text('Đặng Quốc Huy').first);
    await _chup(tester, '23_toi_lan_do_chi_tiet');
    await _quayLai(tester);

    await _moTab(tester, 'Thống kê');
    await _chup(tester, '24_toi_thong_ke');

    khoiPhucDebug();
  });
}
