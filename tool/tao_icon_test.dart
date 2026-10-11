// Công cụ vẽ icon app và hình màn hình khởi động từ icon Phosphor "heartbeat".
//
// Chạy:  flutter test tool/tao_icon_test.dart
// Sau đó: dart run flutter_launcher_icons   (sinh icon cho iOS và Android)

import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ho_so_suc_khoe/core/theme/app_icons.dart';

const _mauDam = Color(0xFF0F766E);
const _mauNhat = Color(0xFF14B8A6);

Future<void> _xuat(
  WidgetTester tester, {
  required String duongDan,
  required double canh,
  required Widget child,
}) async {
  final khoa = GlobalKey();
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = Size(canh, canh);
  await tester.pumpWidget(
    Directionality(
      textDirection: TextDirection.ltr,
      child: Center(
        child: RepaintBoundary(
          key: khoa,
          child: SizedBox(width: canh, height: canh, child: child),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();

  final boundary =
      khoa.currentContext!.findRenderObject()! as RenderRepaintBoundary;
  final bytes = await tester.runAsync(() async {
    final image = await boundary.toImage();
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    image.dispose();
    return data!.buffer.asUint8List();
  });
  File(duongDan)
    ..createSync(recursive: true)
    ..writeAsBytesSync(bytes!);
}

/// Hình trái tim có nhịp đập màu trắng, chiếm [tiLe] cạnh của khung.
Widget _bieuTuong(double canh, double tiLe) {
  return Center(
    child: Icon(
      PhosphorIconsFill.heartbeat,
      size: canh * tiLe,
      color: Colors.white,
    ),
  );
}

void main() {
  setUpAll(() async {
    final loader = FontLoader('PhosphorFill')
      ..addFont(
        Future.value(
          ByteData.sublistView(
            File('assets/fonts/phosphor/Phosphor-Fill.ttf').readAsBytesSync(),
          ),
        ),
      );
    await loader.load();
  });

  testWidgets('icon app', (tester) async {
    addTearDown(tester.view.reset);

    // Icon đầy đủ (iOS và Android đời cũ): nền chuyển màu, không trong suốt.
    await _xuat(
      tester,
      duongDan: 'assets/icon/icon.png',
      canh: 1024,
      child: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [_mauNhat, _mauDam],
          ),
        ),
        child: _bieuTuong(1024, 0.6),
      ),
    );

    // Lớp trước của adaptive icon Android: biểu tượng nằm trong vùng an toàn.
    await _xuat(
      tester,
      duongDan: 'assets/icon/icon_foreground.png',
      canh: 1024,
      child: _bieuTuong(1024, 0.42),
    );
  });

  testWidgets('hình màn hình khởi động', (tester) async {
    addTearDown(tester.view.reset);
    const kichThuocDiem = 96.0;

    // iOS: LaunchImage ở ba mật độ điểm ảnh.
    for (final (hauTo, heSo) in [('', 1.0), ('@2x', 2.0), ('@3x', 3.0)]) {
      final canh = kichThuocDiem * heSo;
      await _xuat(
        tester,
        duongDan:
            'ios/Runner/Assets.xcassets/LaunchImage.imageset/LaunchImage$hauTo.png',
        canh: canh,
        child: _bieuTuong(canh, 1),
      );
    }

    // Android: một ảnh cho mỗi nhóm mật độ.
    for (final (nhom, heSo) in [
      ('mdpi', 1.0),
      ('hdpi', 1.5),
      ('xhdpi', 2.0),
      ('xxhdpi', 3.0),
      ('xxxhdpi', 4.0),
    ]) {
      final canh = kichThuocDiem * heSo;
      await _xuat(
        tester,
        duongDan: 'android/app/src/main/res/drawable-$nhom/launch_glyph.png',
        canh: canh,
        child: _bieuTuong(canh, 1),
      );
    }
  });
}
