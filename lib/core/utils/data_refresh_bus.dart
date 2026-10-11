import 'dart:async';

import 'package:injectable/injectable.dart';

/// Kênh thông báo "dữ liệu đã thay đổi".
///
/// Repository gọi [notify] sau mỗi thao tác thêm / sửa / xóa; các Cubit lắng
/// nghe [stream] để tải lại, nhờ đó mọi tab luôn hiển thị số liệu mới nhất.
@lazySingleton
class DataRefreshBus {
  final _controller = StreamController<void>.broadcast();

  Stream<void> get stream => _controller.stream;

  void notify() => _controller.add(null);

  @disposeMethod
  void dispose() => _controller.close();
}
