import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_icons.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/dinh_dang.dart';
import '../../../../core/utils/ma_hien_thi.dart';
import '../../../../core/utils/trang_thai_tai.dart';
import '../../../../core/widgets/app_badge.dart';
import '../../../../core/widgets/app_inputs.dart';
import '../../../../core/widgets/form_widgets.dart';
import '../../../../core/widgets/state_views.dart';
import '../../../ho_so/domain/entity/nguoi_dung.dart';
import '../../../ho_so/presentation/widgets/avatar_nguoi_dung.dart';
import '../../../ho_so/presentation/widgets/chon_nguoi_dung_sheet.dart';
import '../../../thiet_bi/domain/entity/thiet_bi.dart';
import '../../domain/entity/lan_do.dart';
import '../../domain/entity/loai_chi_so.dart';
import '../cubit/lan_do_form_cubit.dart';
import '../utils/chi_so_ui.dart';
import '../widgets/muc_do_badge.dart';

/// Form ghi nhận một lần đo mới. [maNguoiDung] chọn sẵn người được đo.
@RoutePage()
class LanDoFormScreen extends StatelessWidget {
  const LanDoFormScreen({super.key, @QueryParam('nguoiDung') this.maNguoiDung});

  final int? maNguoiDung;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<LanDoFormCubit>()..khoiTao(),
      child: _LanDoFormView(maNguoiDung: maNguoiDung),
    );
  }
}

class _LanDoFormView extends StatefulWidget {
  const _LanDoFormView({required this.maNguoiDung});

  final int? maNguoiDung;

  @override
  State<_LanDoFormView> createState() => _LanDoFormViewState();
}

class _LanDoFormViewState extends State<_LanDoFormView> {
  final _formKey = GlobalKey<FormState>();
  final _giaTri = {
    for (final ma in MaChiSo.values) ma: TextEditingController(),
  };
  final _ghiChu = TextEditingController();

  late int? _maNguoiDung = widget.maNguoiDung;
  DateTime _thoiGian = DateTime.now();
  NguonDuLieu _nguon = NguonDuLieu.nhapThuCong;
  int? _maThietBi;
  bool _thieuNguoiDung = false;

  @override
  void dispose() {
    for (final controller in _giaTri.values) {
      controller.dispose();
    }
    _ghiChu.dispose();
    super.dispose();
  }

  NguoiDung? _nguoiDangChon(LanDoFormState state) {
    for (final nd in state.nguoiDung) {
      if (nd.maNguoiDung == _maNguoiDung) return nd;
    }
    return null;
  }

  Future<void> _chonNguoi(LanDoFormState state) async {
    final luaChon = await chonNguoiDung(
      context,
      danhSach: state.nguoiDung,
      maDangChon: _maNguoiDung,
      choPhepTatCa: false,
    );
    if (luaChon == null) return;
    setState(() {
      _maNguoiDung = luaChon.maNguoiDung;
      _thieuNguoiDung = false;
    });
  }

  Future<void> _chonNgay() async {
    final now = DateTime.now();
    final ngay = await showDatePicker(
      context: context,
      initialDate: _thoiGian,
      firstDate: DateTime(now.year - 5),
      lastDate: now,
      helpText: 'Chọn ngày đo',
    );
    if (ngay == null) return;
    setState(() {
      _thoiGian = DateTime(
        ngay.year,
        ngay.month,
        ngay.day,
        _thoiGian.hour,
        _thoiGian.minute,
      );
    });
  }

  Future<void> _chonGio() async {
    final gio = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_thoiGian),
      helpText: 'Chọn giờ đo',
    );
    if (gio == null) return;
    setState(() {
      _thoiGian = DateTime(
        _thoiGian.year,
        _thoiGian.month,
        _thoiGian.day,
        gio.hour,
        gio.minute,
      );
    });
  }

  void _luu(LanDoFormState state) {
    final hopLe = _formKey.currentState!.validate();
    setState(() => _thieuNguoiDung = _maNguoiDung == null);
    if (!hopLe || _maNguoiDung == null) {
      context.showSnack('Vui lòng kiểm tra lại các trường được đánh dấu.');
      return;
    }

    final giaTri = <MaChiSo, double>{
      for (final entry in _giaTri.entries) entry.key: ?docSo(entry.value.text),
    };
    if (giaTri.isEmpty) {
      context.showSnack('Cần nhập ít nhất một chỉ số.');
      return;
    }
    final coTamThu = giaTri.containsKey(MaChiSo.huyetApTamThu);
    final coTamTruong = giaTri.containsKey(MaChiSo.huyetApTamTruong);
    if (coTamThu != coTamTruong) {
      context.showSnack('Huyết áp cần nhập đủ cả tâm thu và tâm trương.');
      return;
    }
    if (_nguon == NguonDuLieu.thietBi && _maThietBi == null) {
      context.showSnack('Vui lòng chọn thiết bị đo.');
      return;
    }

    FocusScope.of(context).unfocus();
    context.read<LanDoFormCubit>().luu(
      maNguoiDung: _maNguoiDung!,
      thoiGianDo: _thoiGian,
      nguon: _nguon,
      maThietBi: _maThietBi,
      giaTri: giaTri,
      ghiChu: _ghiChu.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<LanDoFormCubit, LanDoFormState>(
      listenWhen: (truoc, sau) =>
          truoc.maDaLuu != sau.maDaLuu ||
          (truoc.loi != sau.loi && sau.trangThai == TrangThaiTai.thanhCong),
      listener: (context, state) {
        if (state.maDaLuu case final ma?) {
          context.showSnack('Đã lưu lần đo ${MaHienThi.lanDo(ma)}.');
          context.router.replace(LanDoChiTietRoute(maLanDo: ma));
          return;
        }
        if (state.loi != null) context.showSnack(state.loi!);
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(title: const Text('Thêm lần đo')),
          bottomNavigationBar: state.trangThai != TrangThaiTai.thanhCong
              ? null
              : SafeArea(
                  minimum: const EdgeInsets.fromLTRB(
                    AppSpacing.page,
                    AppSpacing.sm,
                    AppSpacing.page,
                    AppSpacing.md,
                  ),
                  child: FilledButton(
                    onPressed: state.dangLuu ? null : () => _luu(state),
                    child: state.dangLuu
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2.5),
                          )
                        : const Text('Lưu lần đo'),
                  ),
                ),
          body: switch (state.trangThai) {
            TrangThaiTai.dangTai => const AppLoading(),
            TrangThaiTai.loi => AppErrorState(
              message: state.loi ?? '',
              onRetry: context.read<LanDoFormCubit>().khoiTao,
            ),
            TrangThaiTai.thanhCong => _buildForm(context, state),
          },
        );
      },
    );
  }

  Widget _buildForm(BuildContext context, LanDoFormState state) {
    final nguoiDung = _nguoiDangChon(state);

    return Form(
      key: _formKey,
      child: ListView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.page,
          AppSpacing.sm,
          AppSpacing.page,
          AppSpacing.xxl,
        ),
        children: [
          FormSection(
            title: 'Thông tin lần đo',
            icon: PhosphorIconsFill.clipboardText,
            children: [
              LabeledField(
                label: 'Người được đo',
                required: true,
                child: PickerField(
                  text: nguoiDung?.hoTen,
                  hint: 'Chọn người được đo',
                  icon: PhosphorIconsRegular.caretDown,
                  leading: nguoiDung == null
                      ? null
                      : AvatarNguoiDung(nguoiDung: nguoiDung, size: 26),
                  onTap: () => _chonNguoi(state),
                  errorText: _thieuNguoiDung
                      ? 'Vui lòng chọn người được đo'
                      : null,
                ),
              ),
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: LabeledField(
                      label: 'Ngày đo',
                      required: true,
                      child: PickerField(
                        text: DinhDang.ngay(_thoiGian),
                        icon: PhosphorIconsRegular.calendarBlank,
                        onTap: _chonNgay,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    flex: 2,
                    child: LabeledField(
                      label: 'Giờ đo',
                      required: true,
                      child: PickerField(
                        text: DinhDang.gio(_thoiGian),
                        icon: PhosphorIconsRegular.clock,
                        onTap: _chonGio,
                      ),
                    ),
                  ),
                ],
              ),
              LabeledField(
                label: 'Nguồn dữ liệu',
                required: true,
                child: AppSegmented<NguonDuLieu>(
                  values: const [NguonDuLieu.nhapThuCong, NguonDuLieu.thietBi],
                  selected: _nguon,
                  labelOf: (nguon) => nguon.nhan,
                  onChanged: (nguon) => setState(() {
                    _nguon = nguon;
                    if (nguon == NguonDuLieu.nhapThuCong) _maThietBi = null;
                  }),
                ),
              ),
              if (_nguon == NguonDuLieu.thietBi)
                LabeledField(
                  label: 'Thiết bị đo',
                  required: true,
                  child: state.thietBi.isEmpty
                      ? Text(
                          'Không có thiết bị nào đang hoạt động.',
                          style: context.text.bodySmall,
                        )
                      : Column(
                          children: [
                            for (final tb in state.thietBi)
                              Padding(
                                padding: const EdgeInsets.only(
                                  bottom: AppSpacing.sm,
                                ),
                                child: _ThietBiOption(
                                  thietBi: tb,
                                  dangChon: _maThietBi == tb.maThietBi,
                                  onTap: () =>
                                      setState(() => _maThietBi = tb.maThietBi),
                                ),
                              ),
                          ],
                        ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          FormSection(
            title: 'Chỉ số sức khỏe',
            icon: PhosphorIconsFill.heartbeat,
            children: [
              Text(
                'Để trống những chỉ số không đo trong lần này.',
                style: context.text.bodySmall,
              ),
              for (final loai in state.loaiChiSo)
                _TruongChiSo(
                  loai: loai,
                  controller: _giaTri[loai.ma]!,
                  onChanged: () => setState(() {}),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          FormSection(
            title: 'Ghi chú',
            icon: PhosphorIconsFill.notePencil,
            children: [
              TextFormField(
                controller: _ghiChu,
                minLines: 2,
                maxLines: 4,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  hintText: 'Tình trạng lúc đo, triệu chứng kèm theo…',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Ô nhập một chỉ số; hiện đánh giá mức độ ngay khi người dùng gõ.
class _TruongChiSo extends StatelessWidget {
  const _TruongChiSo({
    required this.loai,
    required this.controller,
    required this.onChanged,
  });

  final LoaiChiSo loai;
  final TextEditingController controller;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final nhom = NhomChiSo.cua(loai.ma);
    final so = docSo(controller.text);
    final hopLe = so != null && so >= loai.nhapMin && so <= loai.nhapMax;

    return LabeledField(
      label: '${loai.tenChiSo} (${loai.donViDo})',
      trailing: hopLe
          ? MucDoBadge(mucDo: loai.danhGia(so), dense: true)
          : AppBadge(
              label: 'BT: ${loai.khoangBinhThuong}',
              color: p.textSecondary,
              background: p.surfaceMuted,
              dense: true,
            ),
      child: TextFormField(
        controller: controller,
        keyboardType: TextInputType.numberWithOptions(
          decimal: loai.soThapPhan > 0,
        ),
        textInputAction: TextInputAction.next,
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
        ],
        onChanged: (_) => onChanged(),
        decoration: InputDecoration(
          hintText:
              'Ví dụ: ${loai.dinhDang((loai.binhThuongMin + loai.binhThuongMax) / 2)}',
          prefixIcon: Icon(nhom.icon, size: 20, color: nhom.mau(p)),
        ),
        validator: (value) {
          if (value == null || value.trim().isEmpty) return null;
          final so = docSo(value);
          if (so == null) return 'Giá trị không phải là số';
          if (so < loai.nhapMin || so > loai.nhapMax) {
            return 'Phải trong khoảng ${loai.dinhDang(loai.nhapMin)} – '
                '${loai.dinhDang(loai.nhapMax)} ${loai.donViDo}';
          }
          return null;
        },
      ),
    );
  }
}

class _ThietBiOption extends StatelessWidget {
  const _ThietBiOption({
    required this.thietBi,
    required this.dangChon,
    required this.onTap,
  });

  final ThietBi thietBi;
  final bool dangChon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;

    return Material(
      color: dangChon ? p.primarySoft : p.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        side: BorderSide(
          color: dangChon ? p.primary : p.border,
          width: dangChon ? 1.6 : 1,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              Icon(
                PhosphorIconsRegular.cpu,
                size: 20,
                color: dangChon ? p.primary : p.textSecondary,
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(thietBi.tenThietBi, style: context.text.titleSmall),
                    Text(
                      thietBi.loaiThietBi.nhan,
                      style: context.text.bodySmall,
                    ),
                  ],
                ),
              ),
              Icon(
                dangChon
                    ? PhosphorIconsFill.checkCircle
                    : PhosphorIconsRegular.circle,
                size: 20,
                color: dangChon ? p.primary : p.textTertiary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
