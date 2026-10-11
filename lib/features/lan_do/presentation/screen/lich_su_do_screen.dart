import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_icons.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/dinh_dang.dart';
import '../../../../core/utils/trang_thai_tai.dart';
import '../../../../core/widgets/app_inputs.dart';
import '../../../../core/widgets/page_header.dart';
import '../../../../core/widgets/state_views.dart';
import '../../../ho_so/presentation/widgets/chon_nguoi_dung_sheet.dart';
import '../../domain/entity/lan_do.dart';
import '../cubit/lich_su_do_cubit.dart';
import '../utils/chi_so_ui.dart';
import '../widgets/lan_do_card.dart';

/// Tab "Lịch sử": lịch sử đo của mọi người.
@RoutePage()
class LichSuDoScreen extends StatelessWidget {
  const LichSuDoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<LichSuDoCubit>()..khoiTao(),
      child: const _LichSuDoView(maNguoiDung: null),
    );
  }
}

/// Lịch sử đo của riêng một người, mở từ trang chi tiết hồ sơ.
@RoutePage()
class LichSuNguoiDungScreen extends StatelessWidget {
  const LichSuNguoiDungScreen({
    super.key,
    @PathParam('maNguoiDung') required this.maNguoiDung,
  });

  final String maNguoiDung;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          getIt<LichSuDoCubit>()
            ..khoiTao(maNguoiDung: maNguoiDung, khoang: KhoangThoiGian.tatCa),
      child: _LichSuDoView(maNguoiDung: maNguoiDung),
    );
  }
}

class _LichSuDoView extends StatelessWidget {
  const _LichSuDoView({required this.maNguoiDung});

  /// Khác `null` khi màn hình bị khóa vào một người.
  final String? maNguoiDung;

  bool get _theoNguoi => maNguoiDung != null;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LichSuDoCubit, LichSuDoState>(
      builder: (context, state) {
        final soLanDo = state.trangThai == TrangThaiTai.thanhCong
            ? '${state.danhSach.length} lần đo'
            : 'Các lần đo chỉ số';
        final noiDung = Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (!_theoNguoi) PageHeader(title: 'Lịch sử đo', subtitle: soLanDo),
            if (_theoNguoi) const SizedBox(height: AppSpacing.sm),
            _BoLoc(state: state, theoNguoi: _theoNguoi),
            const SizedBox(height: AppSpacing.sm),
            Expanded(
              child: _DanhSach(state: state, theoNguoi: _theoNguoi),
            ),
          ],
        );

        return Scaffold(
          appBar: _theoNguoi
              ? AppBar(
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Lịch sử đo'),
                      Text(
                        '${state.nguoiDangChon?.hoTen ?? ''} · $soLanDo',
                        style: context.text.bodySmall,
                      ),
                    ],
                  ),
                )
              : null,
          floatingActionButton: FloatingActionButton.extended(
            heroTag: _theoNguoi ? 'fab-lich-su-nguoi' : 'fab-lich-su',
            onPressed: () => context.router.push(
              LanDoFormRoute(maNguoiDung: maNguoiDung ?? state.maNguoiDung),
            ),
            icon: const Icon(PhosphorIconsBold.plus, size: 20),
            label: const Text('Thêm lần đo'),
          ),
          body: _theoNguoi ? noiDung : SafeArea(bottom: false, child: noiDung),
        );
      },
    );
  }
}

class _BoLoc extends StatelessWidget {
  const _BoLoc({required this.state, required this.theoNguoi});

  final LichSuDoState state;
  final bool theoNguoi;

  Future<void> _chonNguoi(BuildContext context) async {
    final cubit = context.read<LichSuDoCubit>();
    final luaChon = await chonNguoiDung(
      context,
      danhSach: state.nguoiDung,
      maDangChon: state.maNguoiDung,
    );
    if (luaChon != null) cubit.chonNguoiDung(luaChon.maNguoiDung);
  }

  Future<void> _chonKhoang(BuildContext context) async {
    final cubit = context.read<LichSuDoCubit>();
    final now = DateTime.now();
    final khoang = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 5),
      lastDate: now,
      initialDateRange: state.tuNgay != null && state.denNgay != null
          ? DateTimeRange(start: state.tuNgay!, end: state.denNgay!)
          : DateTimeRange(
              start: now.subtract(const Duration(days: 6)),
              end: now,
            ),
      helpText: 'Chọn khoảng thời gian',
      saveText: 'Áp dụng',
    );
    if (khoang != null) cubit.chonKhoangTuyChon(khoang.start, khoang.end);
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<LichSuDoCubit>();
    final p = context.palette;
    final tuyChon = state.khoang == KhoangThoiGian.tuyChon;
    final vachNgan = Container(width: 1, height: 22, color: p.border);

    return ChipRow(
      children: [
        if (!theoNguoi) ...[
          AppChoiceChip(
            label: state.nguoiDangChon?.hoTen ?? 'Mọi người',
            icon: PhosphorIconsRegular.user,
            trailingIcon: PhosphorIconsBold.caretDown,
            selected: state.maNguoiDung != null,
            onTap: () => _chonNguoi(context),
          ),
          vachNgan,
        ],
        for (final khoang in KhoangThoiGian.values)
          if (khoang != KhoangThoiGian.tuyChon)
            AppChoiceChip(
              label: khoang.nhan,
              selected: state.khoang == khoang,
              onTap: () => cubit.chonKhoang(khoang),
            ),
        AppChoiceChip(
          label: tuyChon && state.tuNgay != null && state.denNgay != null
              ? '${DinhDang.ngayNgan(state.tuNgay!)} – '
                    '${DinhDang.ngayNgan(state.denNgay!)}'
              : KhoangThoiGian.tuyChon.nhan,
          icon: PhosphorIconsRegular.calendarBlank,
          selected: tuyChon,
          onTap: () => _chonKhoang(context),
        ),
        vachNgan,
        for (final nguon in NguonDuLieu.values)
          AppChoiceChip(
            label: nguon.nhan,
            icon: nguon.icon,
            selected: state.nguon == nguon,
            onTap: () => cubit.chonNguon(state.nguon == nguon ? null : nguon),
          ),
      ],
    );
  }
}

class _DanhSach extends StatelessWidget {
  const _DanhSach({required this.state, required this.theoNguoi});

  final LichSuDoState state;
  final bool theoNguoi;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<LichSuDoCubit>();

    switch (state.trangThai) {
      case TrangThaiTai.dangTai:
        return const AppLoading();
      case TrangThaiTai.loi:
        return AppErrorState(message: state.loi ?? '', onRetry: cubit.tai);
      case TrangThaiTai.thanhCong:
        if (state.danhSach.isEmpty) {
          return const AppEmptyState(
            icon: PhosphorIconsRegular.clockCounterClockwise,
            title: 'Không có lần đo nào',
            message: 'Thử chọn khoảng thời gian rộng hơn hoặc bỏ bớt bộ lọc.',
          );
        }

        // Trải phẳng thành: tiêu đề ngày, rồi các lần đo của ngày đó.
        final muc = <Object>[];
        DateTime? ngayTruoc;
        for (final ld in state.danhSach) {
          final ngay = ld.lanDo.thoiGianDo.dauNgay;
          if (ngay != ngayTruoc) {
            muc.add(ngay);
            ngayTruoc = ngay;
          }
          muc.add(ld);
        }
        final soLanTheoNgay = <DateTime, int>{};
        for (final ld in state.danhSach) {
          final ngay = ld.lanDo.thoiGianDo.dauNgay;
          soLanTheoNgay[ngay] = (soLanTheoNgay[ngay] ?? 0) + 1;
        }

        return RefreshIndicator(
          onRefresh: () => cubit.tai(imLang: true),
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.page,
              0,
              AppSpacing.page,
              96,
            ),
            itemCount: muc.length,
            itemBuilder: (context, i) {
              final item = muc[i];
              if (item is DateTime) {
                return Padding(
                  padding: const EdgeInsets.only(
                    top: AppSpacing.md,
                    bottom: 10,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          DinhDang.nhomNgay(item),
                          style: context.text.titleSmall,
                        ),
                      ),
                      Text(
                        '${soLanTheoNgay[item]} lần đo',
                        style: context.text.bodySmall,
                      ),
                    ],
                  ),
                );
              }
              final lanDo = item as LanDoDayDu;
              return Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: LanDoCard(
                  lanDo: lanDo,
                  hienNguoiDung: !theoNguoi,
                  onTap: () => context.router.push(
                    LanDoChiTietRoute(maLanDo: lanDo.lanDo.maLanDo),
                  ),
                ),
              );
            },
          ),
        );
    }
  }
}
