import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';

import '../database/app_database.dart';
import 'injection.config.dart';

final GetIt getIt = GetIt.instance;

/// Mở cơ sở dữ liệu rồi đăng ký toàn bộ dependency (phần còn lại do
/// injectable sinh tự động).
///
/// [AppDatabase] được đăng ký thủ công vì phải mở bất đồng bộ trước khi các
/// repository dùng tới. [csdlTrongBoNho] dành cho kiểm thử.
@InjectableInit(ignoreUnregisteredTypes: [AppDatabase])
Future<void> configureDependencies({bool csdlTrongBoNho = false}) async {
  getIt.registerSingleton<AppDatabase>(
    await AppDatabase.mo(trongBoNho: csdlTrongBoNho),
    dispose: (csdl) => csdl.dong(),
  );
  getIt.init();
}
