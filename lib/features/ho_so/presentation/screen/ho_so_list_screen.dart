import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_icons.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/trang_thai_tai.dart';
import '../../../../core/widgets/app_inputs.dart';
import '../../../../core/widgets/page_header.dart';
import '../../../../core/widgets/state_views.dart';
import '../../domain/entity/nguoi_dung.dart';
import '../cubit/ho_so_list_cubit.dart';
import '../widgets/ho_so_card.dart';

@RoutePage()
class HoSoListScreen extends StatelessWidget {
  const HoSoListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<HoSoListCubit>()..tai(),
      child: const _HoSoListView(),
    );
  }
}

class _HoSoListView extends StatelessWidget {
  const _HoSoListView();

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<HoSoListCubit>();

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'fab-ho-so',
        onPressed: () => context.router.push(HoSoFormRoute()),
        icon: const Icon(PhosphorIconsBold.userPlus, size: 20),
        label: const Text('Thêm hồ sơ'),
      ),
      body: SafeArea(
        bottom: false,
        child: BlocBuilder<HoSoListCubit, HoSoListState>(
          builder: (context, state) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                PageHeader(
                  title: 'Hồ sơ sức khỏe',
                  subtitle: state.trangThai == TrangThaiTai.thanhCong
                      ? '${state.danhSach.length} hồ sơ'
                            '${state.dangLoc ? ' phù hợp' : ''}'
                      : 'Danh sách người dùng',
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.page,
                  ),
                  child: AppSearchField(
                    hintText: 'Tìm theo họ tên…',
                    onChanged: cubit.timKiem,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                _BoLoc(state: state),
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

class _BoLoc extends StatelessWidget {
  const _BoLoc({required this.state});

  final HoSoListState state;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<HoSoListCubit>();
    final p = context.palette;

    return ChipRow(
      children: [
        AppChoiceChip(
          label: 'Tất cả',
          selected: state.gioiTinh == null && state.nhomTuoi == null,
          onTap: () {
            cubit.chonGioiTinh(null);
            cubit.chonNhomTuoi(null);
          },
        ),
        for (final gioiTinh in [GioiTinh.nam, GioiTinh.nu])
          AppChoiceChip(
            label: gioiTinh.nhan,
            icon: gioiTinh == GioiTinh.nam
                ? PhosphorIconsRegular.genderMale
                : PhosphorIconsRegular.genderFemale,
            selected: state.gioiTinh == gioiTinh,
            onTap: () => cubit.chonGioiTinh(
              state.gioiTinh == gioiTinh ? null : gioiTinh,
            ),
          ),
        Container(width: 1, height: 22, color: p.border),
        for (final nhomTuoi in NhomTuoi.values)
          AppChoiceChip(
            label: nhomTuoi.nhan,
            selected: state.nhomTuoi == nhomTuoi,
            onTap: () => cubit.chonNhomTuoi(
              state.nhomTuoi == nhomTuoi ? null : nhomTuoi,
            ),
          ),
      ],
    );
  }
}

class _DanhSach extends StatelessWidget {
  const _DanhSach({required this.state});

  final HoSoListState state;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<HoSoListCubit>();

    switch (state.trangThai) {
      case TrangThaiTai.dangTai:
        return const AppLoading();
      case TrangThaiTai.loi:
        return AppErrorState(message: state.loi ?? '', onRetry: cubit.tai);
      case TrangThaiTai.thanhCong:
        if (state.danhSach.isEmpty) {
          return AppEmptyState(
            icon: PhosphorIconsRegular.folderUser,
            title: state.dangLoc
                ? 'Không tìm thấy hồ sơ phù hợp'
                : 'Chưa có hồ sơ nào',
            message: state.dangLoc
                ? 'Thử đổi từ khóa hoặc bỏ bớt bộ lọc.'
                : 'Nhấn "Thêm hồ sơ" để tạo hồ sơ đầu tiên.',
          );
        }
        return RefreshIndicator(
          onRefresh: () => cubit.tai(imLang: true),
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.page,
              AppSpacing.sm,
              AppSpacing.page,
              96,
            ),
            itemCount: state.danhSach.length,
            separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
            itemBuilder: (context, i) {
              final hoSo = state.danhSach[i];
              return HoSoCard(
                hoSo: hoSo,
                onTap: () => context.router.push(
                  HoSoChiTietRoute(maNguoiDung: hoSo.nguoiDung.maNguoiDung),
                ),
              );
            },
          ),
        );
    }
  }
}
