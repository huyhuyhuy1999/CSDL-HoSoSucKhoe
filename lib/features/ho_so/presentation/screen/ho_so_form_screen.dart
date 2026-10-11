import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_icons.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/dinh_dang.dart';
import '../../../../core/utils/trang_thai_tai.dart';
import '../../../../core/widgets/app_inputs.dart';
import '../../../../core/widgets/form_widgets.dart';
import '../../../../core/widgets/state_views.dart';
import '../../domain/entity/ho_so_suc_khoe.dart';
import '../../domain/entity/nguoi_dung.dart';
import '../../domain/repository/ho_so_repository.dart';
import '../cubit/ho_so_form_cubit.dart';

/// Form thêm hồ sơ mới, hoặc sửa hồ sơ khi có [maNguoiDung].
@RoutePage()
class HoSoFormScreen extends StatelessWidget {
  const HoSoFormScreen({super.key, @QueryParam('ma') this.maNguoiDung});

  final String? maNguoiDung;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<HoSoFormCubit>()..khoiTao(maNguoiDung),
      child: _HoSoFormView(dangSua: maNguoiDung != null),
    );
  }
}

class _HoSoFormView extends StatefulWidget {
  const _HoSoFormView({required this.dangSua});

  final bool dangSua;

  @override
  State<_HoSoFormView> createState() => _HoSoFormViewState();
}

class _HoSoFormViewState extends State<_HoSoFormView> {
  final _formKey = GlobalKey<FormState>();
  final _hoTen = TextEditingController();
  final _soDienThoai = TextEditingController();
  final _email = TextEditingController();
  final _diaChi = TextEditingController();
  final _chieuCao = TextEditingController();
  final _canNang = TextEditingController();
  final _tienSuBenh = TextEditingController();
  final _diUng = TextEditingController();

  GioiTinh _gioiTinh = GioiTinh.nam;
  DateTime? _ngaySinh;
  String _nhomMau = 'O+';
  bool _thieuNgaySinh = false;

  @override
  void dispose() {
    for (final controller in [
      _hoTen,
      _soDienThoai,
      _email,
      _diaChi,
      _chieuCao,
      _canNang,
      _tienSuBenh,
      _diUng,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  void _dienSan(HoSoTongHop hoSo) {
    final nd = hoSo.nguoiDung;
    final hs = hoSo.hoSo;
    _hoTen.text = nd.hoTen;
    _soDienThoai.text = nd.soDienThoai;
    _email.text = nd.email;
    _diaChi.text = nd.diaChi;
    _chieuCao.text = DinhDang.so(
      hs.chieuCao,
      thapPhan: hs.chieuCao % 1 == 0 ? 0 : 1,
    );
    _canNang.text = DinhDang.so(
      hs.canNang,
      thapPhan: hs.canNang % 1 == 0 ? 0 : 1,
    );
    _tienSuBenh.text = hs.tienSuBenh;
    _diUng.text = hs.diUng;
    setState(() {
      _gioiTinh = nd.gioiTinh;
      _ngaySinh = nd.ngaySinh;
      _nhomMau = hs.nhomMau;
    });
  }

  Future<void> _chonNgaySinh() async {
    final now = DateTime.now();
    final ngay = await showDatePicker(
      context: context,
      initialDate: _ngaySinh ?? DateTime(now.year - 30),
      firstDate: DateTime(1900),
      lastDate: now,
      helpText: 'Chọn ngày sinh',
    );
    if (ngay == null) return;
    setState(() {
      _ngaySinh = ngay;
      _thieuNgaySinh = false;
    });
  }

  void _luu() {
    final hopLe = _formKey.currentState!.validate();
    setState(() => _thieuNgaySinh = _ngaySinh == null);
    if (!hopLe || _ngaySinh == null) {
      context.showSnack('Vui lòng kiểm tra lại các trường được đánh dấu.');
      return;
    }
    FocusScope.of(context).unfocus();
    context.read<HoSoFormCubit>().luu(
      ThongTinHoSo(
        hoTen: _hoTen.text,
        gioiTinh: _gioiTinh,
        ngaySinh: _ngaySinh!,
        soDienThoai: _soDienThoai.text,
        email: _email.text,
        diaChi: _diaChi.text,
        chieuCao: docSo(_chieuCao.text)!,
        canNang: docSo(_canNang.text)!,
        nhomMau: _nhomMau,
        tienSuBenh: _tienSuBenh.text,
        diUng: _diUng.text,
      ),
    );
  }

  String? _kiemTraSo(String? value, double min, double max, String donVi) {
    if (value == null || value.trim().isEmpty) return 'Bắt buộc';
    final so = docSo(value);
    if (so == null) return 'Không phải số';
    if (so < min || so > max) {
      return '${DinhDang.so(min)}–${DinhDang.so(max)} $donVi';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<HoSoFormCubit, HoSoFormState>(
      listenWhen: (truoc, sau) =>
          truoc.banDau != sau.banDau ||
          truoc.maDaLuu != sau.maDaLuu ||
          (truoc.loi != sau.loi && sau.trangThai == TrangThaiTai.thanhCong),
      listener: (context, state) {
        if (state.maDaLuu != null) {
          context.showSnack(
            widget.dangSua ? 'Đã cập nhật hồ sơ.' : 'Đã thêm hồ sơ mới.',
          );
          context.router.maybePop();
          return;
        }
        if (state.loi != null && state.trangThai == TrangThaiTai.thanhCong) {
          context.showSnack(state.loi!);
          return;
        }
        if (state.banDau case final hoSo?) _dienSan(hoSo);
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: Text(widget.dangSua ? 'Sửa hồ sơ' : 'Thêm hồ sơ'),
          ),
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
                    onPressed: state.dangLuu ? null : _luu,
                    child: state.dangLuu
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2.5),
                          )
                        : Text(widget.dangSua ? 'Lưu thay đổi' : 'Lưu hồ sơ'),
                  ),
                ),
          body: switch (state.trangThai) {
            TrangThaiTai.dangTai => const AppLoading(),
            TrangThaiTai.loi => AppErrorState(message: state.loi ?? ''),
            TrangThaiTai.thanhCong => _buildForm(context),
          },
        );
      },
    );
  }

  Widget _buildForm(BuildContext context) {
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
            title: 'Thông tin cá nhân',
            icon: PhosphorIconsFill.identificationCard,
            children: [
              LabeledField(
                label: 'Họ và tên',
                required: true,
                child: TextFormField(
                  controller: _hoTen,
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    hintText: 'Ví dụ: Nguyễn Văn An',
                  ),
                  validator: (value) {
                    final ten = value?.trim() ?? '';
                    if (ten.isEmpty) return 'Vui lòng nhập họ và tên';
                    if (ten.length < 2) return 'Họ và tên quá ngắn';
                    return null;
                  },
                ),
              ),
              LabeledField(
                label: 'Giới tính',
                required: true,
                child: AppSegmented<GioiTinh>(
                  values: GioiTinh.values,
                  selected: _gioiTinh,
                  labelOf: (gioiTinh) => gioiTinh.nhan,
                  onChanged: (gioiTinh) => setState(() => _gioiTinh = gioiTinh),
                ),
              ),
              LabeledField(
                label: 'Ngày sinh',
                required: true,
                child: PickerField(
                  text: _ngaySinh == null ? null : DinhDang.ngay(_ngaySinh!),
                  hint: 'Chọn ngày sinh',
                  icon: PhosphorIconsRegular.calendarBlank,
                  onTap: _chonNgaySinh,
                  errorText: _thieuNgaySinh ? 'Vui lòng chọn ngày sinh' : null,
                ),
              ),
              LabeledField(
                label: 'Số điện thoại',
                child: TextFormField(
                  controller: _soDienThoai,
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.next,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9+ ]')),
                  ],
                  decoration: const InputDecoration(hintText: '09xx xxx xxx'),
                  validator: (value) {
                    final so = (value ?? '').replaceAll(RegExp(r'\D'), '');
                    if (so.isEmpty) return null;
                    if (so.length < 9 || so.length > 12) {
                      return 'Số điện thoại không hợp lệ';
                    }
                    return null;
                  },
                ),
              ),
              LabeledField(
                label: 'Email',
                child: TextFormField(
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  autocorrect: false,
                  decoration: const InputDecoration(
                    hintText: 'ten@example.com',
                  ),
                  validator: (value) {
                    final email = value?.trim() ?? '';
                    if (email.isEmpty) return null;
                    final hopLe = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$')
                        .hasMatch(email);
                    return hopLe ? null : 'Email không hợp lệ';
                  },
                ),
              ),
              LabeledField(
                label: 'Địa chỉ',
                child: TextFormField(
                  controller: _diaChi,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    hintText: 'Số nhà, đường, quận/huyện, tỉnh/thành',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          FormSection(
            title: 'Hồ sơ sức khỏe',
            icon: PhosphorIconsFill.firstAidKit,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: LabeledField(
                      label: 'Chiều cao (cm)',
                      required: true,
                      child: TextFormField(
                        controller: _chieuCao,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(hintText: '165'),
                        validator: (v) => _kiemTraSo(v, 30, 250, 'cm'),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: LabeledField(
                      label: 'Cân nặng (kg)',
                      required: true,
                      child: TextFormField(
                        controller: _canNang,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(hintText: '60'),
                        validator: (v) => _kiemTraSo(v, 1, 300, 'kg'),
                      ),
                    ),
                  ),
                ],
              ),
              LabeledField(
                label: 'Nhóm máu',
                required: true,
                child: Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: [
                    for (final nhomMau in danhSachNhomMau)
                      AppChoiceChip(
                        label: nhomMau,
                        selected: _nhomMau == nhomMau,
                        onTap: () => setState(() => _nhomMau = nhomMau),
                      ),
                  ],
                ),
              ),
              LabeledField(
                label: 'Tiền sử bệnh',
                child: TextFormField(
                  controller: _tienSuBenh,
                  minLines: 2,
                  maxLines: 4,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    hintText: 'Bệnh mạn tính, phẫu thuật đã trải qua…',
                  ),
                ),
              ),
              LabeledField(
                label: 'Dị ứng',
                child: TextFormField(
                  controller: _diUng,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    hintText:
                        'Phân cách bằng dấu phẩy, ví dụ: Penicillin, hải sản',
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
