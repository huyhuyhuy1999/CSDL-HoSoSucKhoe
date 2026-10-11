// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'package:get_it/get_it.dart' as _i174;
import 'package:ho_so_suc_khoe/app/theme_cubit.dart' as _i335;
import 'package:ho_so_suc_khoe/core/utils/data_refresh_bus.dart' as _i499;
import 'package:ho_so_suc_khoe/features/canh_bao/data/repository_impl/mock_canh_bao_repository.dart'
    as _i630;
import 'package:ho_so_suc_khoe/features/canh_bao/domain/repository/canh_bao_repository.dart'
    as _i343;
import 'package:ho_so_suc_khoe/features/canh_bao/presentation/cubit/canh_bao_cubit.dart'
    as _i198;
import 'package:ho_so_suc_khoe/features/ho_so/data/repository_impl/mock_ho_so_repository.dart'
    as _i805;
import 'package:ho_so_suc_khoe/features/ho_so/domain/repository/ho_so_repository.dart'
    as _i312;
import 'package:ho_so_suc_khoe/features/ho_so/presentation/cubit/ho_so_chi_tiet_cubit.dart'
    as _i545;
import 'package:ho_so_suc_khoe/features/ho_so/presentation/cubit/ho_so_form_cubit.dart'
    as _i411;
import 'package:ho_so_suc_khoe/features/ho_so/presentation/cubit/ho_so_list_cubit.dart'
    as _i123;
import 'package:ho_so_suc_khoe/features/lan_do/data/repository_impl/mock_lan_do_repository.dart'
    as _i1061;
import 'package:ho_so_suc_khoe/features/lan_do/domain/repository/lan_do_repository.dart'
    as _i32;
import 'package:ho_so_suc_khoe/features/lan_do/presentation/cubit/lan_do_chi_tiet_cubit.dart'
    as _i396;
import 'package:ho_so_suc_khoe/features/lan_do/presentation/cubit/lan_do_form_cubit.dart'
    as _i937;
import 'package:ho_so_suc_khoe/features/lan_do/presentation/cubit/lich_su_do_cubit.dart'
    as _i223;
import 'package:ho_so_suc_khoe/features/thiet_bi/data/repository_impl/mock_thiet_bi_repository.dart'
    as _i453;
import 'package:ho_so_suc_khoe/features/thiet_bi/domain/repository/thiet_bi_repository.dart'
    as _i990;
import 'package:ho_so_suc_khoe/features/thiet_bi/presentation/cubit/thiet_bi_cubit.dart'
    as _i230;
import 'package:ho_so_suc_khoe/features/thong_ke/data/repository_impl/mock_thong_ke_repository.dart'
    as _i615;
import 'package:ho_so_suc_khoe/features/thong_ke/domain/repository/thong_ke_repository.dart'
    as _i671;
import 'package:ho_so_suc_khoe/features/thong_ke/presentation/cubit/thong_ke_cubit.dart'
    as _i218;
import 'package:ho_so_suc_khoe/features/tong_quan/data/repository_impl/mock_tong_quan_repository.dart'
    as _i395;
import 'package:ho_so_suc_khoe/features/tong_quan/domain/repository/tong_quan_repository.dart'
    as _i52;
import 'package:ho_so_suc_khoe/features/tong_quan/presentation/cubit/tong_quan_cubit.dart'
    as _i709;
import 'package:ho_so_suc_khoe/mock/mock_database.dart' as _i605;
import 'package:injectable/injectable.dart' as _i526;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    gh.lazySingleton<_i335.ThemeCubit>(() => _i335.ThemeCubit());
    gh.lazySingleton<_i499.DataRefreshBus>(
      () => _i499.DataRefreshBus(),
      dispose: (i) => i.dispose(),
    );
    gh.lazySingleton<_i605.MockDatabase>(() => _i605.MockDatabase());
    gh.lazySingleton<_i343.CanhBaoRepository>(
      () => _i630.MockCanhBaoRepository(
        gh<_i605.MockDatabase>(),
        gh<_i499.DataRefreshBus>(),
      ),
    );
    gh.lazySingleton<_i312.HoSoRepository>(
      () => _i805.MockHoSoRepository(
        gh<_i605.MockDatabase>(),
        gh<_i499.DataRefreshBus>(),
      ),
    );
    gh.lazySingleton<_i32.LanDoRepository>(
      () => _i1061.MockLanDoRepository(
        gh<_i605.MockDatabase>(),
        gh<_i499.DataRefreshBus>(),
      ),
    );
    gh.factory<_i545.HoSoChiTietCubit>(
      () => _i545.HoSoChiTietCubit(
        gh<_i312.HoSoRepository>(),
        gh<_i32.LanDoRepository>(),
        gh<_i343.CanhBaoRepository>(),
        gh<_i499.DataRefreshBus>(),
      ),
    );
    gh.factory<_i411.HoSoFormCubit>(
      () => _i411.HoSoFormCubit(gh<_i312.HoSoRepository>()),
    );
    gh.lazySingleton<_i52.TongQuanRepository>(
      () => _i395.MockTongQuanRepository(gh<_i605.MockDatabase>()),
    );
    gh.lazySingleton<_i671.ThongKeRepository>(
      () => _i615.MockThongKeRepository(gh<_i605.MockDatabase>()),
    );
    gh.lazySingleton<_i990.ThietBiRepository>(
      () => _i453.MockThietBiRepository(gh<_i605.MockDatabase>()),
    );
    gh.factory<_i198.CanhBaoCubit>(
      () => _i198.CanhBaoCubit(
        gh<_i343.CanhBaoRepository>(),
        gh<_i499.DataRefreshBus>(),
      ),
    );
    gh.factory<_i198.SoCanhBaoCubit>(
      () => _i198.SoCanhBaoCubit(
        gh<_i343.CanhBaoRepository>(),
        gh<_i499.DataRefreshBus>(),
      ),
    );
    gh.factory<_i937.LanDoFormCubit>(
      () => _i937.LanDoFormCubit(
        gh<_i32.LanDoRepository>(),
        gh<_i312.HoSoRepository>(),
        gh<_i990.ThietBiRepository>(),
      ),
    );
    gh.factory<_i396.LanDoChiTietCubit>(
      () => _i396.LanDoChiTietCubit(
        gh<_i32.LanDoRepository>(),
        gh<_i343.CanhBaoRepository>(),
        gh<_i499.DataRefreshBus>(),
      ),
    );
    gh.factory<_i123.HoSoListCubit>(
      () => _i123.HoSoListCubit(
        gh<_i312.HoSoRepository>(),
        gh<_i499.DataRefreshBus>(),
      ),
    );
    gh.factory<_i223.LichSuDoCubit>(
      () => _i223.LichSuDoCubit(
        gh<_i32.LanDoRepository>(),
        gh<_i312.HoSoRepository>(),
        gh<_i499.DataRefreshBus>(),
      ),
    );
    gh.factory<_i230.ThietBiCubit>(
      () => _i230.ThietBiCubit(gh<_i990.ThietBiRepository>()),
    );
    gh.factory<_i218.ThongKeCubit>(
      () => _i218.ThongKeCubit(
        gh<_i671.ThongKeRepository>(),
        gh<_i312.HoSoRepository>(),
        gh<_i499.DataRefreshBus>(),
      ),
    );
    gh.factory<_i709.TongQuanCubit>(
      () => _i709.TongQuanCubit(
        gh<_i52.TongQuanRepository>(),
        gh<_i499.DataRefreshBus>(),
      ),
    );
    return this;
  }
}
