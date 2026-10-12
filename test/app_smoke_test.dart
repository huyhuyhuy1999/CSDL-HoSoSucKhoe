import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ho_so_suc_khoe/app/app.dart';
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
}
