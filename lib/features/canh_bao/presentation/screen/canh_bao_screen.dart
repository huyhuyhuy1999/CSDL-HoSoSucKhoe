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
import '../../../../core/widgets/dialogs.dart';
import '../../../../core/widgets/page_header.dart';
import '../../../../core/widgets/state_views.dart';
import '../../domain/entity/canh_bao.dart';
import '../cubit/canh_bao_cubit.dart';
import '../widgets/canh_bao_card.dart';

@RoutePage()
class CanhBaoScreen extends StatelessWidget {
  const CanhBaoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<CanhBaoCubit>()..tai(),
      child: const _CanhBaoView(),
    );
  }
}

class _CanhBaoView extends StatelessWidget {
  const _CanhBaoView();

  Future<void> _danhDauTatCa(BuildContext context, int soChuaXem) async {
    final cubit = context.read<CanhBaoCubit>();
    final dongY = await xacNhan(
      context,
      tieuDe: 'Đánh dấu đã xem tất cả?',
      noiDung: '$soChuaXem cảnh báo chưa xem sẽ được chuyển sang đã xem.',
      nhanDongY: 'Đánh dấu',
    );
    if (!dongY) return;
    await cubit.danhDauTatCaDaXem();
    if (context.mounted) context.showSnack('Đã đánh dấu tất cả là đã xem.');
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<CanhBaoCubit>();

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: BlocBuilder<CanhBaoCubit, CanhBaoState>(
          builder: (context, state) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                PageHeader(
                  title: 'Cảnh báo',
                  subtitle: state.soChuaXem > 0
                      ? '${state.soChuaXem} cảnh báo chưa xem'
                      : 'Không có cảnh báo mới',
                  actions: [
                    if (state.soChuaXem > 0)
                      AppIconButton(
                        icon: PhosphorIconsRegular.checks,
                        tooltip: 'Đánh dấu đã xem tất cả',
                        onTap: () => _danhDauTatCa(context, state.soChuaXem),
                      ),
                  ],
                ),
                ChipRow(
                  children: [
                    for (final boLoc in BoLocCanhBao.values)
                      AppChoiceChip(
                        label:
                            boLoc == BoLocCanhBao.chuaXem && state.soChuaXem > 0
                            ? '${boLoc.nhan} (${state.soChuaXem})'
                            : boLoc.nhan,
                        selected: state.boLoc == boLoc,
                        onTap: () => cubit.chonBoLoc(boLoc),
                      ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Expanded(child: _DanhSach(state: state)),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _DanhSach extends StatelessWidget {
  const _DanhSach({required this.state});

  final CanhBaoState state;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<CanhBaoCubit>();

    switch (state.trangThai) {
      case TrangThaiTai.dangTai:
        return const AppLoading();
      case TrangThaiTai.loi:
        return AppErrorState(message: state.loi ?? '', onRetry: cubit.tai);
      case TrangThaiTai.thanhCong:
        if (state.danhSach.isEmpty) {
          return AppEmptyState(
            icon: PhosphorIconsRegular.bellSimple,
            title: state.boLoc == BoLocCanhBao.chuaXem
                ? 'Bạn đã xem hết cảnh báo'
                : 'Không có cảnh báo nào',
            message: 'Cảnh báo xuất hiện khi một chỉ số đo vượt ngưỡng.',
          );
        }

        // Trải phẳng thành: tiêu đề ngày, rồi các cảnh báo của ngày đó.
        final muc = <Object>[];
        DateTime? ngayTruoc;
        for (final cb in state.danhSach) {
          final ngay = cb.canhBao.thoiGianTao.dauNgay;
          if (ngay != ngayTruoc) {
            muc.add(ngay);
            ngayTruoc = ngay;
          }
          muc.add(cb);
        }

        return RefreshIndicator(
          onRefresh: () => cubit.tai(imLang: true),
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.page,
              0,
              AppSpacing.page,
              AppSpacing.xxxl,
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
                  child: Text(
                    DinhDang.nhomNgay(item),
                    style: context.text.titleSmall,
                  ),
                );
              }
              final canhBao = item as CanhBaoDayDu;
              return Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: CanhBaoCard(
                  canhBao: canhBao,
                  onTap: () {
                    if (!canhBao.canhBao.daXem) {
                      cubit.danhDauDaXem(canhBao.canhBao.maCanhBao);
                    }
                    context.router.push(
                      LanDoChiTietRoute(maLanDo: canhBao.canhBao.maLanDo),
                    );
                  },
                ),
              );
            },
          ),
        );
    }
  }
}
