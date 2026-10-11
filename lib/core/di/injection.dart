import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';

import 'injection.config.dart';

final GetIt getIt = GetIt.instance;

/// Đăng ký toàn bộ dependency (sinh tự động bởi injectable).
@InjectableInit()
void configureDependencies() => getIt.init();
