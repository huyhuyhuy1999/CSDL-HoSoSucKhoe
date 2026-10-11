import 'dart:math';

import 'package:injectable/injectable.dart';

import '../features/canh_bao/domain/entity/canh_bao.dart';
import '../features/ho_so/domain/entity/ho_so_suc_khoe.dart';
import '../features/ho_so/domain/entity/nguoi_dung.dart';
import '../features/lan_do/domain/entity/lan_do.dart';
import '../features/lan_do/domain/entity/loai_chi_so.dart';
import '../features/lan_do/domain/entity/muc_do.dart';
import '../features/thiet_bi/domain/entity/thiet_bi.dart';

part 'mock_seed.dart';

/// Cơ sở dữ liệu mẫu trong bộ nhớ, mô phỏng 7 bảng của đồ án.
///
/// Đây là chỗ duy nhất cần thay khi nhóm hoàn thành CSDL thật: các
/// `*RepositoryImpl` sẽ gọi SQL/API thay vì đọc các danh sách dưới đây.
/// Dữ liệu được sinh lại mỗi lần mở app, trải trong 30 ngày gần nhất.
@lazySingleton
class MockDatabase {
  MockDatabase() : _now = DateTime.now() {
    _taoDuLieuMau(this);
  }

  final DateTime _now;

  // ── Các bảng ──────────────────────────────────────────────────────────
  final List<NguoiDung> bangNguoiDung = [];
  final List<HoSoSucKhoe> bangHoSo = [];
  final List<ThietBi> bangThietBi = [];
  final List<LoaiChiSo> bangLoaiChiSo = [];
  final List<LanDo> bangLanDo = [];
  final List<CanhBao> bangCanhBao = [];

  /// CHI_TIET_LAN_DO, lập chỉ mục theo mã lần đo.
  final Map<String, List<ChiTietLanDo>> _chiTietTheoLanDo = {};

  int _demNguoiDung = 0;
  int _demLanDo = 0;
  int _demCanhBao = 0;

  // ── Tra cứu theo khóa ─────────────────────────────────────────────────
  NguoiDung? timNguoiDung(String maNguoiDung) {
    for (final nd in bangNguoiDung) {
      if (nd.maNguoiDung == maNguoiDung) return nd;
    }
    return null;
  }

  HoSoSucKhoe? timHoSo(String maNguoiDung) {
    for (final hs in bangHoSo) {
      if (hs.maNguoiDung == maNguoiDung) return hs;
    }
    return null;
  }

  ThietBi? timThietBi(String? maThietBi) {
    if (maThietBi == null) return null;
    for (final tb in bangThietBi) {
      if (tb.maThietBi == maThietBi) return tb;
    }
    return null;
  }

  LanDo? timLanDo(String maLanDo) {
    for (final ld in bangLanDo) {
      if (ld.maLanDo == maLanDo) return ld;
    }
    return null;
  }

  LoaiChiSo loaiChiSoTheoMa(String maLoaiChiSo) =>
      bangLoaiChiSo.firstWhere((l) => l.maLoaiChiSo == maLoaiChiSo);

  LoaiChiSo loaiChiSo(MaChiSo ma) =>
      bangLoaiChiSo.firstWhere((l) => l.ma == ma);

  List<ChiTietLanDo> chiTietCua(String maLanDo) =>
      _chiTietTheoLanDo[maLanDo] ?? const [];

  // ── Truy vấn ghép bảng ────────────────────────────────────────────────
  LanDoDayDu ghepLanDo(LanDo lanDo) {
    final ketQua = [
      for (final ct in chiTietCua(lanDo.maLanDo))
        KetQuaChiSo(loai: loaiChiSoTheoMa(ct.maLoaiChiSo), giaTri: ct.giaTri),
    ]..sort((a, b) => a.loai.ma.index.compareTo(b.loai.ma.index));

    return LanDoDayDu(
      lanDo: lanDo,
      nguoiDung: timNguoiDung(lanDo.maNguoiDung)!,
      thietBi: timThietBi(lanDo.maThietBi),
      ketQua: ketQua,
    );
  }

  /// Lịch sử đo, mới nhất trước. Mọi tham số lọc đều tùy chọn.
  List<LanDoDayDu> truyVanLanDo({
    String? maNguoiDung,
    DateTime? tuNgay,
    DateTime? denNgay,
    NguonDuLieu? nguon,
    int? gioiHan,
  }) {
    final ketQua = <LanDo>[];
    for (final ld in bangLanDo) {
      if (maNguoiDung != null && ld.maNguoiDung != maNguoiDung) continue;
      if (tuNgay != null && ld.thoiGianDo.isBefore(tuNgay)) continue;
      if (denNgay != null && ld.thoiGianDo.isAfter(denNgay)) continue;
      if (nguon != null && ld.nguon != nguon) continue;
      ketQua.add(ld);
    }
    ketQua.sort((a, b) => b.thoiGianDo.compareTo(a.thoiGianDo));
    final gioiHanKetQua = gioiHan == null ? ketQua : ketQua.take(gioiHan);
    return [for (final ld in gioiHanKetQua) ghepLanDo(ld)];
  }

  CanhBaoDayDu ghepCanhBao(CanhBao canhBao) {
    final lanDo = timLanDo(canhBao.maLanDo)!;
    final chiTiet = chiTietCua(canhBao.maLanDo)
        .firstWhere((ct) => ct.maLoaiChiSo == canhBao.maLoaiChiSo);

    return CanhBaoDayDu(
      canhBao: canhBao,
      nguoiDung: timNguoiDung(lanDo.maNguoiDung)!,
      loaiChiSo: loaiChiSoTheoMa(canhBao.maLoaiChiSo),
      giaTri: chiTiet.giaTri,
    );
  }

  /// Cảnh báo, mới nhất trước.
  List<CanhBaoDayDu> truyVanCanhBao({
    MucDo? mucDo,
    bool chiChuaXem = false,
    String? maNguoiDung,
    String? maLanDo,
    DateTime? tuNgay,
    DateTime? denNgay,
  }) {
    final ketQua = <CanhBao>[];
    for (final cb in bangCanhBao) {
      if (mucDo != null && cb.mucDo != mucDo) continue;
      if (chiChuaXem && cb.daXem) continue;
      if (maLanDo != null && cb.maLanDo != maLanDo) continue;
      if (tuNgay != null && cb.thoiGianTao.isBefore(tuNgay)) continue;
      if (denNgay != null && cb.thoiGianTao.isAfter(denNgay)) continue;
      if (maNguoiDung != null &&
          timLanDo(cb.maLanDo)?.maNguoiDung != maNguoiDung) {
        continue;
      }
      ketQua.add(cb);
    }
    ketQua.sort((a, b) => b.thoiGianTao.compareTo(a.thoiGianTao));
    return [for (final cb in ketQua) ghepCanhBao(cb)];
  }

  HoSoTongHop ghepHoSo(NguoiDung nguoiDung) {
    final lanDo = truyVanLanDo(maNguoiDung: nguoiDung.maNguoiDung);
    final chuaXem = truyVanCanhBao(
      maNguoiDung: nguoiDung.maNguoiDung,
      chiChuaXem: true,
    );

    return HoSoTongHop(
      nguoiDung: nguoiDung,
      hoSo: timHoSo(nguoiDung.maNguoiDung)!,
      lanDoGanNhat: lanDo.isEmpty ? null : lanDo.first,
      soLanDo: lanDo.length,
      soCanhBaoChuaXem: chuaXem.length,
    );
  }

  // ── Thêm / sửa / xóa ──────────────────────────────────────────────────
  String _maNguoiDungMoi() =>
      'ND${(++_demNguoiDung).toString().padLeft(3, '0')}';

  /// Thêm người dùng cùng hồ sơ sức khỏe (quan hệ 1–1).
  NguoiDung themNguoiDung({
    required String hoTen,
    required GioiTinh gioiTinh,
    required DateTime ngaySinh,
    required double chieuCao,
    required double canNang,
    required String nhomMau,
    String soDienThoai = '',
    String email = '',
    String diaChi = '',
    String tienSuBenh = '',
    String diUng = '',
    DateTime? ngayCapNhat,
  }) {
    final ma = _maNguoiDungMoi();
    final nguoiDung = NguoiDung(
      maNguoiDung: ma,
      hoTen: hoTen,
      gioiTinh: gioiTinh,
      ngaySinh: ngaySinh,
      soDienThoai: soDienThoai,
      email: email,
      diaChi: diaChi,
    );
    bangNguoiDung.add(nguoiDung);
    bangHoSo.add(
      HoSoSucKhoe(
        maHoSo: ma.replaceFirst('ND', 'HS'),
        maNguoiDung: ma,
        chieuCao: chieuCao,
        canNang: canNang,
        nhomMau: nhomMau,
        tienSuBenh: tienSuBenh,
        diUng: diUng,
        ngayCapNhat: ngayCapNhat ?? DateTime.now(),
      ),
    );
    return nguoiDung;
  }

  void capNhatNguoiDung(NguoiDung nguoiDung, HoSoSucKhoe hoSo) {
    final iNguoiDung = bangNguoiDung.indexWhere(
      (nd) => nd.maNguoiDung == nguoiDung.maNguoiDung,
    );
    final iHoSo = bangHoSo.indexWhere(
      (hs) => hs.maNguoiDung == nguoiDung.maNguoiDung,
    );
    if (iNguoiDung >= 0) bangNguoiDung[iNguoiDung] = nguoiDung;
    if (iHoSo >= 0) bangHoSo[iHoSo] = hoSo;
  }

  /// Xóa người dùng và toàn bộ dữ liệu phụ thuộc (ON DELETE CASCADE).
  void xoaNguoiDung(String maNguoiDung) {
    final maLanDo = [
      for (final ld in bangLanDo)
        if (ld.maNguoiDung == maNguoiDung) ld.maLanDo,
    ];
    maLanDo.forEach(xoaLanDo);
    bangHoSo.removeWhere((hs) => hs.maNguoiDung == maNguoiDung);
    bangNguoiDung.removeWhere((nd) => nd.maNguoiDung == maNguoiDung);
  }

  /// Thêm một lần đo cùng các chi tiết; tự sinh cảnh báo nếu vượt ngưỡng
  /// (mô phỏng Trigger của module cảnh báo).
  LanDo themLanDo({
    required String maNguoiDung,
    required DateTime thoiGianDo,
    required NguonDuLieu nguon,
    required Map<MaChiSo, double> giaTri,
    String? maThietBi,
    String ghiChu = '',
    bool canhBaoDaXem = false,
  }) {
    final ma = 'LD${(++_demLanDo).toString().padLeft(4, '0')}';
    final lanDo = LanDo(
      maLanDo: ma,
      maNguoiDung: maNguoiDung,
      thoiGianDo: thoiGianDo,
      nguon: nguon,
      maThietBi: nguon == NguonDuLieu.thietBi ? maThietBi : null,
      ghiChu: ghiChu,
    );
    bangLanDo.add(lanDo);

    final chiTiet = <ChiTietLanDo>[];
    for (final entry in giaTri.entries) {
      final loai = loaiChiSo(entry.key);
      chiTiet.add(
        ChiTietLanDo(
          maLanDo: ma,
          maLoaiChiSo: loai.maLoaiChiSo,
          giaTri: entry.value,
        ),
      );

      final mucDo = loai.danhGia(entry.value);
      if (mucDo == MucDo.binhThuong) continue;
      final huong = loai.caoHonBinhThuong(entry.value) ? 'cao' : 'thấp';
      bangCanhBao.add(
        CanhBao(
          maCanhBao: 'CB${(++_demCanhBao).toString().padLeft(4, '0')}',
          maLanDo: ma,
          maLoaiChiSo: loai.maLoaiChiSo,
          mucDo: mucDo,
          noiDung:
              '${loai.tenChiSo} ${loai.dinhDang(entry.value)} ${loai.donViDo} '
              '$huong hơn khoảng bình thường (${loai.khoangBinhThuong}).',
          thoiGianTao: thoiGianDo,
          daXem: canhBaoDaXem,
        ),
      );
    }
    _chiTietTheoLanDo[ma] = chiTiet;
    return lanDo;
  }

  /// Xóa lần đo cùng chi tiết và cảnh báo của nó.
  void xoaLanDo(String maLanDo) {
    bangCanhBao.removeWhere((cb) => cb.maLanDo == maLanDo);
    _chiTietTheoLanDo.remove(maLanDo);
    bangLanDo.removeWhere((ld) => ld.maLanDo == maLanDo);
  }

  void danhDauDaXem(String maCanhBao) {
    final i = bangCanhBao.indexWhere((cb) => cb.maCanhBao == maCanhBao);
    if (i >= 0) bangCanhBao[i] = bangCanhBao[i].copyWith(daXem: true);
  }

  void danhDauTatCaDaXem() {
    for (var i = 0; i < bangCanhBao.length; i++) {
      if (!bangCanhBao[i].daXem) {
        bangCanhBao[i] = bangCanhBao[i].copyWith(daXem: true);
      }
    }
  }
}
