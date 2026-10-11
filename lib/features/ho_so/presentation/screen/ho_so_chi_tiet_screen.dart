import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_icons.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/dinh_dang.dart';
import '../../../../core/utils/trang_thai_tai.dart';
import '../../../../core/widgets/app_badge.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_inputs.dart';
import '../../../../core/widgets/bieu_do_duong.dart';
import '../../../../core/widgets/dialogs.dart';
import '../../../../core/widgets/section_header.dart';
import '../../../../core/widgets/state_views.dart';
import '../../../canh_bao/presentation/widgets/canh_bao_card.dart';
import '../../../lan_do/domain/entity/lan_do.dart';
import '../../../lan_do/presentation/utils/chi_so_ui.dart';
import '../../../lan_do/presentation/widgets/chi_so_tile.dart';
import '../../../lan_do/presentation/widgets/lan_do_card.dart';
import '../../domain/entity/ho_so_suc_khoe.dart';
import '../cubit/ho_so_chi_tiet_cubit.dart';
import '../widgets/avatar_nguoi_dung.dart';

@RoutePage()
class HoSoChiTietScreen extends StatelessWidget {
  const HoSoChiTietScreen({
    super.key,
    @PathParam('maNguoiDung') required this.maNguoiDung,
  });

  final String maNguoiDung;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<HoSoChiTietCubit>()..tai(maNguoiDung),
      child: _HoSoChiTietView(maNguoiDung: maNguoiDung),
    );
  }
}

class _HoSoChiTietView extends StatelessWidget {
  const _HoSoChiTietView({required this.maNguoiDung});

  final String maNguoiDung;

  Future<void> _xoa(BuildContext context, HoSoTongHop hoSo) async {
    final cubit = context.read<HoSoChiTietCubit>();
    final dongY = await xacNhan(
      context,
      tieuDe: 'Xóa hồ sơ?',
      noiDung:
          'Hồ sơ của ${hoSo.nguoiDung.hoTen} cùng ${hoSo.soLanDo} lần đo và '
          'các cảnh báo liên quan sẽ bị xóa. Thao tác này không thể hoàn tác.',
      nhanDongY: 'Xóa',
      nguyHiem: true,
    );
    if (!dongY || !context.mounted) return;

    final loi = await cubit.xoa();
    if (!context.mounted) return;
    if (loi != null) {
      context.showSnack(loi);
      return;
    }
    context.showSnack('Đã xóa hồ sơ ${hoSo.nguoiDung.hoTen}.');
    context.router.maybePop();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HoSoChiTietCubit, HoSoChiTietState>(
      builder: (context, state) {
        final hoSo = state.hoSo;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Hồ sơ sức khỏe'),
            actions: [
              if (hoSo != null) ...[
                IconButton(
                  tooltip: 'Sửa hồ sơ',
                  icon: const Icon(PhosphorIconsRegular.pencilSimple),
                  onPressed: () => context.router.push(
                    HoSoFormRoute(maNguoiDung: maNguoiDung),
                  ),
                ),
                PopupMenuButton<String>(
                  tooltip: 'Thao tác khác',
                  icon: const Icon(PhosphorIconsRegular.dotsThreeVertical),
                  onSelected: (_) => _xoa(context, hoSo),
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'xoa',
                      child: Row(
                        children: [
                          Icon(
                            PhosphorIconsRegular.trash,
                            size: 18,
                            color: context.palette.danger,
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Text(
                            'Xóa hồ sơ',
                            style: TextStyle(color: context.palette.danger),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(width: 4),
            ],
          ),
          bottomNavigationBar: hoSo == null
              ? null
              : SafeArea(
                  minimum: const EdgeInsets.fromLTRB(
                    AppSpacing.page,
                    AppSpacing.sm,
                    AppSpacing.page,
                    AppSpacing.md,
                  ),
                  child: FilledButton.icon(
                    onPressed: () => context.router.push(
                      LanDoFormRoute(maNguoiDung: maNguoiDung),
                    ),
                    icon: const Icon(PhosphorIconsBold.plus, size: 18),
                    label: const Text('Thêm lần đo'),
                  ),
                ),
          body: switch (state.trangThai) {
            TrangThaiTai.dangTai when hoSo == null => const AppLoading(),
            TrangThaiTai.loi when hoSo == null => AppErrorState(
              message: state.loi ?? '',
              onRetry: () => context.read<HoSoChiTietCubit>().tai(maNguoiDung),
            ),
            _ => _NoiDung(state: state, hoSo: hoSo!),
          },
        );
      },
    );
  }
}

class _NoiDung extends StatelessWidget {
  const _NoiDung({required this.state, required this.hoSo});

  final HoSoChiTietState state;
  final HoSoTongHop hoSo;

  @override
  Widget build(BuildContext context) {
    final ma = hoSo.nguoiDung.maNguoiDung;
    final lanDoGanNhat = hoSo.lanDoGanNhat;

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.page,
        AppSpacing.sm,
        AppSpacing.page,
        AppSpacing.xxl,
      ),
      children: [
        _ThongTinCaNhan(hoSo: hoSo),
        const SizedBox(height: AppSpacing.md),
        _TheTrang(hoSo: hoSo.hoSo),
        const SizedBox(height: AppSpacing.md),
        _TienSu(hoSo: hoSo.hoSo),
        const SizedBox(height: AppSpacing.xxl),
        SectionHeader(
          title: 'Chỉ số mới nhất',
          trailing: lanDoGanNhat == null
              ? null
              : Text(
                  DinhDang.tuongDoi(lanDoGanNhat.lanDo.thoiGianDo),
                  style: context.text.bodySmall,
                ),
        ),
        const SizedBox(height: AppSpacing.md),
        _ChiSoMoiNhat(lanDo: state.lanDo),
        const SizedBox(height: AppSpacing.xxl),
        const SectionHeader(title: 'Xu hướng'),
        const SizedBox(height: AppSpacing.md),
        _XuHuong(lanDo: state.lanDo),
        const SizedBox(height: AppSpacing.xxl),
        SectionHeader(
          title: 'Lần đo gần đây',
          actionLabel: state.lanDo.isEmpty ? null : 'Xem lịch sử',
          onAction: () =>
              context.router.push(LichSuNguoiDungRoute(maNguoiDung: ma)),
        ),
        const SizedBox(height: AppSpacing.md),
        if (state.lanDo.isEmpty)
          const AppCard(
            child: AppEmptyState(
              icon: PhosphorIconsRegular.clockCounterClockwise,
              title: 'Chưa có lần đo nào',
              message: 'Nhấn "Thêm lần đo" để ghi nhận chỉ số đầu tiên.',
            ),
          )
        else
          for (final ld in state.lanDo.take(3))
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: LanDoCard(
                lanDo: ld,
                hienNguoiDung: false,
                hienNgay: true,
                onTap: () => context.router.push(
                  LanDoChiTietRoute(maLanDo: ld.lanDo.maLanDo),
                ),
              ),
            ),
        if (state.canhBao.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.md),
          SectionHeader(
            title: 'Cảnh báo',
            trailing: Text(
              '${state.canhBao.length} cảnh báo',
              style: context.text.bodySmall,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          for (final cb in state.canhBao.take(3))
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: CanhBaoCard(
                canhBao: cb,
                hienNguoiDung: false,
                onTap: () => context.router.push(
                  LanDoChiTietRoute(maLanDo: cb.canhBao.maLanDo),
                ),
              ),
            ),
        ],
      ],
    );
  }
}

class _ThongTinCaNhan extends StatelessWidget {
  const _ThongTinCaNhan({required this.hoSo});

  final HoSoTongHop hoSo;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final nd = hoSo.nguoiDung;
    final lienHe = [
      if (nd.soDienThoai.isNotEmpty)
        (PhosphorIconsRegular.phone, nd.soDienThoai),
      if (nd.email.isNotEmpty) (PhosphorIconsRegular.envelopeSimple, nd.email),
      if (nd.diaChi.isNotEmpty) (PhosphorIconsRegular.mapPin, nd.diaChi),
    ];

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AvatarNguoiDung(nguoiDung: nd, size: 64),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(nd.hoTen, style: context.text.titleLarge),
                    const SizedBox(height: 2),
                    Text(
                      'Mã ${nd.maNguoiDung} · Hồ sơ ${hoSo.hoSo.maHoSo}',
                      style: context.text.bodySmall,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        AppBadge(
                          label: nd.gioiTinh.nhan,
                          color: p.primary,
                          background: p.primarySoft,
                          dense: true,
                        ),
                        AppBadge(
                          label: '${nd.tuoi} tuổi',
                          color: p.info,
                          background: p.infoSoft,
                          dense: true,
                        ),
                        AppBadge(
                          label: DinhDang.ngay(nd.ngaySinh),
                          color: p.textSecondary,
                          background: p.surfaceMuted,
                          icon: PhosphorIconsRegular.cake,
                          dense: true,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (lienHe.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.lg),
            Divider(color: p.border),
            const SizedBox(height: AppSpacing.md),
            for (final (icon, text) in lienHe)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 1),
                      child: Icon(icon, size: 17, color: p.textTertiary),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(child: Text(text, style: context.text.bodyMedium)),
                  ],
                ),
              ),
          ],
        ],
      ),
    );
  }
}

/// Chiều cao, cân nặng, BMI và nhóm máu.
class _TheTrang extends StatelessWidget {
  const _TheTrang({required this.hoSo});

  final HoSoSucKhoe hoSo;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final mauBmi = switch (hoSo.phanLoaiBmi) {
      'Bình thường' => p.success,
      'Béo phì' => p.danger,
      _ => p.warning,
    };
    final cacO = [
      ('Chiều cao', DinhDang.so(hoSo.chieuCao), 'cm', null),
      ('Cân nặng', DinhDang.so(hoSo.canNang), 'kg', null),
      ('BMI', DinhDang.so(hoSo.bmi, thapPhan: 1), hoSo.phanLoaiBmi, mauBmi),
      ('Nhóm máu', hoSo.nhomMau, 'ABO/Rh', null),
    ];

    return AppCard(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
      child: Column(
        children: [
          IntrinsicHeight(
            child: Row(
              children: [
                for (var i = 0; i < cacO.length; i++) ...[
                  if (i > 0) VerticalDivider(width: 1, color: p.border),
                  Expanded(
                    child: Column(
                      children: [
                        Text(cacO[i].$1, style: context.text.labelSmall),
                        const SizedBox(height: 6),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            cacO[i].$2,
                            style: AppTypography.number(20, p.textPrimary),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          cacO[i].$3,
                          style: context.text.labelSmall!.copyWith(
                            color: cacO[i].$4,
                            fontWeight: cacO[i].$4 == null
                                ? null
                                : FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Cập nhật ngày ${DinhDang.ngay(hoSo.ngayCapNhat)}',
            style: context.text.labelSmall,
          ),
        ],
      ),
    );
  }
}

class _TienSu extends StatelessWidget {
  const _TienSu({required this.hoSo});

  final HoSoSucKhoe hoSo;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final diUng = [
      for (final muc in hoSo.diUng.split(','))
        if (muc.trim().isNotEmpty) muc.trim(),
    ];

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _TieuDeNho(
            icon: PhosphorIconsRegular.clipboardText,
            nhan: 'Tiền sử bệnh',
          ),
          const SizedBox(height: 6),
          Text(
            hoSo.tienSuBenh.isEmpty ? 'Không có' : hoSo.tienSuBenh,
            style: context.text.bodyMedium!.copyWith(
              color: hoSo.tienSuBenh.isEmpty ? p.textSecondary : null,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          _TieuDeNho(icon: PhosphorIconsRegular.prohibit, nhan: 'Dị ứng'),
          const SizedBox(height: AppSpacing.sm),
          if (diUng.isEmpty)
            Text(
              'Không có',
              style: context.text.bodyMedium!.copyWith(color: p.textSecondary),
            )
          else
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final muc in diUng)
                  AppBadge(
                    label: muc,
                    color: p.danger,
                    background: p.dangerSoft,
                  ),
              ],
            ),
        ],
      ),
    );
  }
}

class _TieuDeNho extends StatelessWidget {
  const _TieuDeNho({required this.icon, required this.nhan});

  final IconData icon;
  final String nhan;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;

    return Row(
      children: [
        Icon(icon, size: 16, color: p.textTertiary),
        const SizedBox(width: 6),
        Text(
          nhan,
          style: context.text.labelMedium!.copyWith(color: p.textSecondary),
        ),
      ],
    );
  }
}

/// Lưới 2×2: với mỗi nhóm chỉ số lấy giá trị từ lần đo gần nhất có nó.
class _ChiSoMoiNhat extends StatelessWidget {
  const _ChiSoMoiNhat({required this.lanDo});

  final List<LanDoDayDu> lanDo;

  LanDoDayDu? _lanDoCo(NhomChiSo nhom) {
    for (final ld in lanDo) {
      if (nhom.giaTri(ld) != null) return ld;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    const nhom = NhomChiSo.values;

    return Column(
      children: [
        for (var hang = 0; hang < nhom.length; hang += 2) ...[
          if (hang > 0) const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: ChiSoTile(nhom: nhom[hang], lanDo: _lanDoCo(nhom[hang])),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: ChiSoTile(
                  nhom: nhom[hang + 1],
                  lanDo: _lanDoCo(nhom[hang + 1]),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

/// Biểu đồ các lần đo gần nhất của một nhóm chỉ số.
class _XuHuong extends StatefulWidget {
  const _XuHuong({required this.lanDo});

  final List<LanDoDayDu> lanDo;

  @override
  State<_XuHuong> createState() => _XuHuongState();
}

class _XuHuongState extends State<_XuHuong> {
  static const _soDiemToiDa = 12;

  NhomChiSo _nhom = NhomChiSo.nhipTim;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;

    // Lấy các lần đo có nhóm chỉ số đang chọn, sắp theo thời gian tăng dần.
    final coDuLieu = [
      for (final ld in widget.lanDo)
        if (_nhom.giaTri(ld) != null) ld,
    ].take(_soDiemToiDa).toList().reversed.toList();

    final loaiChinh = coDuLieu.isEmpty
        ? null
        : coDuLieu.first.ketQuaCua(_nhom.maChiSo.first)!.loai;
    final mauPhu = p.spo2;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppSegmented<NhomChiSo>(
            values: NhomChiSo.values,
            selected: _nhom,
            labelOf: (nhom) => nhom.nhan,
            onChanged: (nhom) => setState(() => _nhom = nhom),
          ),
          const SizedBox(height: AppSpacing.lg),
          BieuDoDuong(
            nhanTrucX: [
              for (final ld in coDuLieu) DinhDang.ngayNgan(ld.lanDo.thoiGianDo),
            ],
            duong: [
              for (var i = 0; i < _nhom.maChiSo.length; i++)
                DuLieuDuong(
                  nhan: _nhom.maChiSo.length == 1
                      ? _nhom.nhan
                      : (i == 0 ? 'Tâm thu' : 'Tâm trương'),
                  mau: i == 0 ? _nhom.mau(p) : mauPhu,
                  giaTri: [
                    for (final ld in coDuLieu)
                      ld.ketQuaCua(_nhom.maChiSo[i])?.giaTri,
                  ],
                ),
            ],
            dinhDang: (v) => loaiChinh?.dinhDang(v) ?? DinhDang.so(v),
            vungBinhThuong: _nhom.maChiSo.length == 1 && loaiChinh != null
                ? (loaiChinh.binhThuongMin, loaiChinh.binhThuongMax)
                : null,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            coDuLieu.isEmpty
                ? 'Chưa có dữ liệu ${_nhom.nhan.toLowerCase()}.'
                : '${coDuLieu.length} lần đo gần nhất · đơn vị ${_nhom.donVi}',
            style: context.text.labelSmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
