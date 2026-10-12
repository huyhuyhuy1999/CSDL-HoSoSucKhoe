// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

part of 'app_router.dart';

/// generated route for
/// [CanhBaoScreen]
class CanhBaoRoute extends PageRouteInfo<void> {
  const CanhBaoRoute({List<PageRouteInfo>? children})
    : super(CanhBaoRoute.name, initialChildren: children);

  static const String name = 'CanhBaoRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const CanhBaoScreen();
    },
  );
}

/// generated route for
/// [HoSoChiTietScreen]
class HoSoChiTietRoute extends PageRouteInfo<HoSoChiTietRouteArgs> {
  HoSoChiTietRoute({
    Key? key,
    required int maNguoiDung,
    List<PageRouteInfo>? children,
  }) : super(
         HoSoChiTietRoute.name,
         args: HoSoChiTietRouteArgs(key: key, maNguoiDung: maNguoiDung),
         rawPathParams: {'maNguoiDung': maNguoiDung},
         initialChildren: children,
       );

  static const String name = 'HoSoChiTietRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<HoSoChiTietRouteArgs>(
        orElse: () =>
            HoSoChiTietRouteArgs(maNguoiDung: pathParams.getInt('maNguoiDung')),
      );
      return HoSoChiTietScreen(key: args.key, maNguoiDung: args.maNguoiDung);
    },
  );
}

class HoSoChiTietRouteArgs {
  const HoSoChiTietRouteArgs({this.key, required this.maNguoiDung});

  final Key? key;

  final int maNguoiDung;

  @override
  String toString() {
    return 'HoSoChiTietRouteArgs{key: $key, maNguoiDung: $maNguoiDung}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! HoSoChiTietRouteArgs) return false;
    return key == other.key && maNguoiDung == other.maNguoiDung;
  }

  @override
  int get hashCode => key.hashCode ^ maNguoiDung.hashCode;
}

/// generated route for
/// [HoSoFormScreen]
class HoSoFormRoute extends PageRouteInfo<HoSoFormRouteArgs> {
  HoSoFormRoute({Key? key, int? maNguoiDung, List<PageRouteInfo>? children})
    : super(
        HoSoFormRoute.name,
        args: HoSoFormRouteArgs(key: key, maNguoiDung: maNguoiDung),
        rawQueryParams: {'ma': maNguoiDung},
        initialChildren: children,
      );

  static const String name = 'HoSoFormRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final queryParams = data.queryParams;
      final args = data.argsAs<HoSoFormRouteArgs>(
        orElse: () => HoSoFormRouteArgs(maNguoiDung: queryParams.optInt('ma')),
      );
      return HoSoFormScreen(key: args.key, maNguoiDung: args.maNguoiDung);
    },
  );
}

class HoSoFormRouteArgs {
  const HoSoFormRouteArgs({this.key, this.maNguoiDung});

  final Key? key;

  final int? maNguoiDung;

  @override
  String toString() {
    return 'HoSoFormRouteArgs{key: $key, maNguoiDung: $maNguoiDung}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! HoSoFormRouteArgs) return false;
    return key == other.key && maNguoiDung == other.maNguoiDung;
  }

  @override
  int get hashCode => key.hashCode ^ maNguoiDung.hashCode;
}

/// generated route for
/// [HoSoListScreen]
class HoSoListRoute extends PageRouteInfo<void> {
  const HoSoListRoute({List<PageRouteInfo>? children})
    : super(HoSoListRoute.name, initialChildren: children);

  static const String name = 'HoSoListRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const HoSoListScreen();
    },
  );
}

/// generated route for
/// [LanDoChiTietScreen]
class LanDoChiTietRoute extends PageRouteInfo<LanDoChiTietRouteArgs> {
  LanDoChiTietRoute({
    Key? key,
    required int maLanDo,
    List<PageRouteInfo>? children,
  }) : super(
         LanDoChiTietRoute.name,
         args: LanDoChiTietRouteArgs(key: key, maLanDo: maLanDo),
         rawPathParams: {'maLanDo': maLanDo},
         initialChildren: children,
       );

  static const String name = 'LanDoChiTietRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<LanDoChiTietRouteArgs>(
        orElse: () =>
            LanDoChiTietRouteArgs(maLanDo: pathParams.getInt('maLanDo')),
      );
      return LanDoChiTietScreen(key: args.key, maLanDo: args.maLanDo);
    },
  );
}

class LanDoChiTietRouteArgs {
  const LanDoChiTietRouteArgs({this.key, required this.maLanDo});

  final Key? key;

  final int maLanDo;

  @override
  String toString() {
    return 'LanDoChiTietRouteArgs{key: $key, maLanDo: $maLanDo}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! LanDoChiTietRouteArgs) return false;
    return key == other.key && maLanDo == other.maLanDo;
  }

  @override
  int get hashCode => key.hashCode ^ maLanDo.hashCode;
}

/// generated route for
/// [LanDoFormScreen]
class LanDoFormRoute extends PageRouteInfo<LanDoFormRouteArgs> {
  LanDoFormRoute({Key? key, int? maNguoiDung, List<PageRouteInfo>? children})
    : super(
        LanDoFormRoute.name,
        args: LanDoFormRouteArgs(key: key, maNguoiDung: maNguoiDung),
        rawQueryParams: {'nguoiDung': maNguoiDung},
        initialChildren: children,
      );

  static const String name = 'LanDoFormRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final queryParams = data.queryParams;
      final args = data.argsAs<LanDoFormRouteArgs>(
        orElse: () =>
            LanDoFormRouteArgs(maNguoiDung: queryParams.optInt('nguoiDung')),
      );
      return LanDoFormScreen(key: args.key, maNguoiDung: args.maNguoiDung);
    },
  );
}

class LanDoFormRouteArgs {
  const LanDoFormRouteArgs({this.key, this.maNguoiDung});

  final Key? key;

  final int? maNguoiDung;

  @override
  String toString() {
    return 'LanDoFormRouteArgs{key: $key, maNguoiDung: $maNguoiDung}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! LanDoFormRouteArgs) return false;
    return key == other.key && maNguoiDung == other.maNguoiDung;
  }

  @override
  int get hashCode => key.hashCode ^ maNguoiDung.hashCode;
}

/// generated route for
/// [LichSuDoScreen]
class LichSuDoRoute extends PageRouteInfo<void> {
  const LichSuDoRoute({List<PageRouteInfo>? children})
    : super(LichSuDoRoute.name, initialChildren: children);

  static const String name = 'LichSuDoRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const LichSuDoScreen();
    },
  );
}

/// generated route for
/// [LichSuNguoiDungScreen]
class LichSuNguoiDungRoute extends PageRouteInfo<LichSuNguoiDungRouteArgs> {
  LichSuNguoiDungRoute({
    Key? key,
    required int maNguoiDung,
    List<PageRouteInfo>? children,
  }) : super(
         LichSuNguoiDungRoute.name,
         args: LichSuNguoiDungRouteArgs(key: key, maNguoiDung: maNguoiDung),
         rawPathParams: {'maNguoiDung': maNguoiDung},
         initialChildren: children,
       );

  static const String name = 'LichSuNguoiDungRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<LichSuNguoiDungRouteArgs>(
        orElse: () => LichSuNguoiDungRouteArgs(
          maNguoiDung: pathParams.getInt('maNguoiDung'),
        ),
      );
      return LichSuNguoiDungScreen(
        key: args.key,
        maNguoiDung: args.maNguoiDung,
      );
    },
  );
}

class LichSuNguoiDungRouteArgs {
  const LichSuNguoiDungRouteArgs({this.key, required this.maNguoiDung});

  final Key? key;

  final int maNguoiDung;

  @override
  String toString() {
    return 'LichSuNguoiDungRouteArgs{key: $key, maNguoiDung: $maNguoiDung}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! LichSuNguoiDungRouteArgs) return false;
    return key == other.key && maNguoiDung == other.maNguoiDung;
  }

  @override
  int get hashCode => key.hashCode ^ maNguoiDung.hashCode;
}

/// generated route for
/// [MainShellScreen]
class MainShellRoute extends PageRouteInfo<void> {
  const MainShellRoute({List<PageRouteInfo>? children})
    : super(MainShellRoute.name, initialChildren: children);

  static const String name = 'MainShellRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const MainShellScreen();
    },
  );
}

/// generated route for
/// [ThietBiScreen]
class ThietBiRoute extends PageRouteInfo<void> {
  const ThietBiRoute({List<PageRouteInfo>? children})
    : super(ThietBiRoute.name, initialChildren: children);

  static const String name = 'ThietBiRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const ThietBiScreen();
    },
  );
}

/// generated route for
/// [ThongKeScreen]
class ThongKeRoute extends PageRouteInfo<void> {
  const ThongKeRoute({List<PageRouteInfo>? children})
    : super(ThongKeRoute.name, initialChildren: children);

  static const String name = 'ThongKeRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const ThongKeScreen();
    },
  );
}

/// generated route for
/// [TongQuanScreen]
class TongQuanRoute extends PageRouteInfo<void> {
  const TongQuanRoute({List<PageRouteInfo>? children})
    : super(TongQuanRoute.name, initialChildren: children);

  static const String name = 'TongQuanRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const TongQuanScreen();
    },
  );
}
