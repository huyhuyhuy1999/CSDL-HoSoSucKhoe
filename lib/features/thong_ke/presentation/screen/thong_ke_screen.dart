import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_icons.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/dinh_dang.dart';
import '../../../../core/utils/trang_thai_tai.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_inputs.dart';
import '../../../../core/widgets/bieu_do_duong.dart';
import '../../../../core/widgets/page_header.dart';
import '../../../../core/widgets/state_views.dart';
import '../../../ho_so/presentation/widgets/chon_nguoi_dung_sheet.dart';
import '../../../lan_do/domain/entity/loai_chi_so.dart';
import '../../../lan_do/presentation/utils/chi_so_ui.dart';
import '../../domain/entity/thong_ke.dart';
import '../cubit/thong_ke_cubit.dart';
import '../widgets/bang_thong_ke.dart';
import '../widgets/bieu_do_cot.dart';
import '../widgets/bieu_do_tron.dart';

@RoutePage()
class ThongKeScreen extends StatelessWidget {
  const ThongKeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<ThongKeCubit>()..tai(),
      child: const _ThongKeView(),
    );
  }
}

class _ThongKeView extends StatelessWidget {
  const _ThongKeView();

  Future<void> _chonNguoi(BuildContext context, ThongKeState state) async {
    final cubit = context.read<ThongKeCubit>();
    final luaChon = await chonNguoiDung(
      context,
      danhSach: state.nguoiDung,
      maDangChon: state.maNguoiDung,
    );
    if (luaChon != null) cubit.chonNguoiDung(luaChon.maNguoiDung);
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ThongKeCubit>();

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: BlocBuilder<ThongKeCubit, ThongKeState>(
          builder: (context, state) {
            final duLieu = state.duLieu;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                PageHeader(
                  title: 'Thống kê',
                  subtitle: duLieu == null
                      ? 'Số liệu tổng hợp'
                      : '${DinhDang.ngayNgan(duLieu.tuNgay)} – '
                            '${DinhDang.ngay(duLieu.denNgay)}',
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.page,
                  ),
                  child: AppSegmented<int>(
                    values: const [7, 14, 30],
                    selected: state.soNgay,
                    labelOf: (soNgay) => '$soNgay ngày',
                    onChanged: cubit.chonSoNgay,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                ChipRow(
                  children: [
                    AppChoiceChip(
                      label: state.nguoiDangChon?.hoTen ?? 'Mọi người',
                      icon: PhosphorIconsRegular.user,
                      trailingIcon: PhosphorIconsBold.caretDown,
                      selected: state.maNguoiDung != null,
                      onTap: () => _chonNguoi(context, state),
                    ),
                    if (state.maNguoiDung != null)
                      AppChoiceChip(
                        label: 'Bỏ lọc',
                        icon: PhosphorIconsRegular.x,
                        selected: false,
                        onTap: () => cubit.chonNguoiDung(null),
                      ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Expanded(
                  child: switch (state.trangThai) {
                    TrangThaiTai.dangTai when duLieu == null =>
                      const AppLoading(),
                    TrangThaiTai.loi when duLieu == null => AppErrorState(
                      message: state.loi ?? '',
                      onRetry: cubit.tai,
                    ),
                    _ => RefreshIndicator(
                      onRefresh: () => cubit.tai(imLang: true),
                      child: _NoiDung(duLieu: duLieu!),
                    ),
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _NoiDung extends StatelessWidget {
  const _NoiDung({required this.duLieu});

  final ThongKeTongHop duLieu;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.page,
        AppSpacing.sm,
        AppSpacing.page,
        AppSpacing.xxxl,
      ),
      children: [
        Row(
          children: [
            Expanded(
              child: _SoLieu(
                nhan: 'Lần đo',
                giaTri: duLieu.tongLanDo,
                icon: PhosphorIconsFill.clockCounterClockwise,
                mau: p.info,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: _SoLieu(
                nhan: 'Cảnh báo',
                giaTri: duLieu.tongCanhBao,
                icon: PhosphorIconsFill.bell,
                mau: p.warning,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: _SoLieu(
                nhan: 'Người đo',
                giaTri: duLieu.soNguoiDuocDo,
                icon: PhosphorIconsFill.users,
                mau: p.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        _DienBien(duLieu: duLieu),
        const SizedBox(height: AppSpacing.md),
        _Khoi(
          tieuDe: 'Số lần đo theo ngày',
          moTa: 'Tổng ${duLieu.tongLanDo} lần đo trong khoảng đã chọn',
          child: BieuDoCot(duLieu: duLieu.lanDoTheoNgay),
        ),
        const SizedBox(height: AppSpacing.md),
        _Khoi(
          tieuDe: 'Kết quả các lần đo',
          moTa: 'Phân loại theo chỉ số xấu nhất của mỗi lần đo',
          child: BieuDoTron(phanBo: duLieu.phanBoMucDo),
        ),
        const SizedBox(height: AppSpacing.md),
        _Khoi(
          tieuDe: 'Thống kê theo chỉ số',
          moTa: 'Trung bình, thấp nhất, cao nhất và số lần đo',
          child: BangChiSo(duLieu: duLieu.theoChiSo),
        ),
        const SizedBox(height: AppSpacing.md),
        _Khoi(
          tieuDe: 'Nhiều cảnh báo nhất',
          moTa: 'Những người có nhiều cảnh báo nhất trong khoảng đã chọn',
          child: XepHangCanhBaoList(duLieu: duLieu.xepHangCanhBao),
        ),
      ],
    );
  }
}

/// Khối nội dung có tiêu đề và dòng mô tả.
class _Khoi extends StatelessWidget {
  const _Khoi({required this.tieuDe, required this.child, this.moTa});

  final String tieuDe;
  final String? moTa;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(tieuDe, style: context.text.titleMedium),
          if (moTa != null) ...[
            const SizedBox(height: 2),
            Text(moTa!, style: context.text.bodySmall),
          ],
          const SizedBox(height: AppSpacing.lg),
          child,
        ],
      ),
    );
  }
}

class _SoLieu extends StatelessWidget {
  const _SoLieu({
    required this.nhan,
    required this.giaTri,
    required this.icon,
    required this.mau,
  });

  final String nhan;
  final int giaTri;
  final IconData icon;
  final Color mau;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;

    return AppCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: mau),
          const SizedBox(height: AppSpacing.sm),
          Text('$giaTri', style: AppTypography.number(24, p.textPrimary)),
          const SizedBox(height: 2),
          Text(nhan, style: context.text.bodySmall),
        ],
      ),
    );
  }
}

/// Biểu đồ trung bình theo ngày của nhóm chỉ số đang chọn.
class _DienBien extends StatefulWidget {
  const _DienBien({required this.duLieu});

  final ThongKeTongHop duLieu;

  @override
  State<_DienBien> createState() => _DienBienState();
}

class _DienBienState extends State<_DienBien> {
  NhomChiSo _nhom = NhomChiSo.nhipTim;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final duLieu = widget.duLieu;
    final cacNgay = [for (final d in duLieu.lanDoTheoNgay) d.ngay];

    List<double?> giaTriTheoNgay(MaChiSo ma) {
      final theoNgay = {
        for (final diem in duLieu.dienBien[ma] ?? const <DiemDuLieu>[])
          diem.ngay: diem.giaTri,
      };
      return [for (final ngay in cacNgay) theoNgay[ngay]];
    }

    LoaiChiSo? loaiCua(MaChiSo ma) {
      for (final tk in duLieu.theoChiSo) {
        if (tk.loai.ma == ma) return tk.loai;
      }
      return null;
    }

    final loaiChinh = loaiCua(_nhom.maChiSo.first);
    final motDuong = _nhom.maChiSo.length == 1;

    return _Khoi(
      tieuDe: 'Diễn biến chỉ số',
      moTa: 'Trung bình theo ngày · đơn vị ${_nhom.donVi}',
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
            nhanTrucX: [for (final ngay in cacNgay) DinhDang.ngayNgan(ngay)],
            duong: [
              for (var i = 0; i < _nhom.maChiSo.length; i++)
                DuLieuDuong(
                  nhan: motDuong
                      ? _nhom.nhan
                      : (i == 0 ? 'Tâm thu' : 'Tâm trương'),
                  mau: i == 0 ? _nhom.mau(p) : p.spo2,
                  giaTri: giaTriTheoNgay(_nhom.maChiSo[i]),
                ),
            ],
            dinhDang: (v) => loaiChinh?.dinhDang(v) ?? DinhDang.so(v),
            vungBinhThuong: motDuong && loaiChinh != null
                ? (loaiChinh.binhThuongMin, loaiChinh.binhThuongMax)
                : null,
          ),
        ],
      ),
    );
  }
}
