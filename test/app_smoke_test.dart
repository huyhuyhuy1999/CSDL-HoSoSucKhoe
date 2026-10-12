import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ho_so_suc_khoe/app/app.dart';
import 'package:ho_so_suc_khoe/core/database/app_database.dart';
import 'package:ho_so_suc_khoe/core/di/injection.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

/// Kiểm tra nhanh: app khởi động được trên cơ sở dữ liệu SQLite và cả năm tab
/// đều hiển thị nội dung.
void main() {
  setUpAll(() async {
    Intl.defaultLocale = 'vi';
    await initializeDateFormatting('vi');
  });

  // Mỗi test dùng một cơ sở dữ liệu SQLite mới trong bộ nhớ.
  setUp(() => configureDependencies(csdlTrongBoNho: true));
  tearDown(getIt.reset);

  Future<void> moApp(WidgetTester tester) async {
    // Kích thước logic của một iPhone thông dụng.
    tester.view.physicalSize = const Size(1179, 2556);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const App());
    await tester.pumpAndSettle();
  }

  Future<void> moTab(WidgetTester tester, String nhan) async {
    await tester.tap(
      find.descendant(
        of: find.byType(NavigationBar),
        matching: find.text(nhan),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('mở app vào tab Tổng quan với dữ liệu mẫu', (tester) async {
    await moApp(tester);

    expect(find.text('Hoạt động hôm nay'), findsOneWidget);
    expect(find.text('Trung bình 7 ngày'), findsOneWidget);
    expect(find.byType(NavigationBar), findsOneWidget);
  });

  testWidgets('tab Hồ sơ liệt kê và tìm kiếm không phân biệt dấu', (
    tester,
  ) async {
    await moApp(tester);
    await moTab(tester, 'Hồ sơ');

    expect(find.text('Hồ sơ sức khỏe'), findsOneWidget);
    expect(find.text('12 hồ sơ'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'bich');
    await tester.pumpAndSettle();

    expect(find.text('Trần Thị Bích'), findsOneWidget);
    expect(find.text('1 hồ sơ phù hợp'), findsOneWidget);
  });

  testWidgets('các tab Lịch sử, Cảnh báo, Thống kê hiển thị nội dung', (
    tester,
  ) async {
    await moApp(tester);

    await moTab(tester, 'Lịch sử');
    expect(find.text('Lịch sử đo'), findsOneWidget);
    expect(find.text('Hôm nay'), findsWidgets);

    await moTab(tester, 'Cảnh báo');
    expect(find.textContaining('Chưa xem'), findsWidgets);
    expect(find.text('Nguy hiểm'), findsWidgets);

    await moTab(tester, 'Thống kê');
    expect(find.text('Diễn biến chỉ số'), findsOneWidget);
  });

  testWidgets('mở chi tiết hồ sơ từ danh sách', (tester) async {
    await moApp(tester);
    await moTab(tester, 'Hồ sơ');

    // Danh sách xếp theo tên nên Nguyễn Văn An đứng đầu.
    await tester.tap(find.text('Nguyễn Văn An'));
    await tester.pumpAndSettle();

    expect(find.text('Chỉ số mới nhất'), findsOneWidget);
    expect(find.text('Thêm lần đo'), findsOneWidget);
    expect(find.text('Tiền sử bệnh'), findsOneWidget);
  });

  testWidgets(
    'thêm lần đo vượt ngưỡng: trigger sinh cảnh báo và giao diện hiện ra',
    (tester) async {
      await moApp(tester);
      final csdl = getIt<AppDatabase>();
      final soCanhBaoTruoc = csdl.demSoDong()['CANH_BAO']!;

      await moTab(tester, 'Hồ sơ');
      await tester.tap(find.text('Nguyễn Văn An'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Thêm lần đo'));
      await tester.pumpAndSettle();

      // Ô thứ hai của form là nhịp tim; 135 bpm nằm ngoài khoảng 50–120.
      await tester.enterText(find.byType(TextFormField).at(1), '135');
      await tester.tap(find.text('Lưu lần đo'));
      await tester.pumpAndSettle();

      // App không tự chèn cảnh báo: dòng mới trong CANH_BAO là do trigger tạo.
      expect(csdl.demSoDong()['LAN_DO'], 266);
      expect(csdl.demSoDong()['CANH_BAO'], soCanhBaoTruoc + 1);
      expect(find.text('Chi tiết lần đo'), findsOneWidget);
      expect(find.text('Nguy hiểm'), findsWidgets);
      expect(find.text('Nhịp tim cao'), findsOneWidget);
    },
  );

  testWidgets('giá trị ngoài khoảng hợp lệ bị form chặn, không ghi vào CSDL', (
    tester,
  ) async {
    await moApp(tester);
    final csdl = getIt<AppDatabase>();

    await moTab(tester, 'Lịch sử');
    await tester.tap(find.text('Thêm lần đo'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).at(1), '400');
    await tester.tap(find.text('Lưu lần đo'));
    await tester.pumpAndSettle();

    expect(
      find.textContaining('Phải trong khoảng 20 – 250 bpm'),
      findsOneWidget,
    );
    expect(csdl.demSoDong()['LAN_DO'], 265);
  });

  testWidgets('xóa hồ sơ: lần đo và cảnh báo của người đó bị xóa theo', (
    tester,
  ) async {
    await moApp(tester);
    final csdl = getIt<AppDatabase>();

    await moTab(tester, 'Hồ sơ');
    await tester.enterText(find.byType(TextField), 'Oanh');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Lý Thị Oanh'));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Thao tác khác'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Xóa hồ sơ'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Xóa'));
    await tester.pumpAndSettle();

    // Lý Thị Oanh (người dùng 12) có 15 lần đo trong dữ liệu mẫu.
    expect(csdl.demSoDong()['NGUOI_DUNG'], 11);
    expect(csdl.demSoDong()['HO_SO_SUC_KHOE'], 11);
    expect(csdl.demSoDong()['LAN_DO'], 250);
  });
}
