import '../../../../core/database/truy_van.dart';
import '../../domain/entity/ho_so_suc_khoe.dart';
import '../../domain/entity/nguoi_dung.dart';

/// Danh sách cột của NGUOI_DUNG để chèn vào câu SELECT, với bí danh bảng [b].
String cotNguoiDung([String b = 'nd']) =>
    '$b.MaNguoiDung, $b.HoTen, $b.GioiTinh, $b.NgaySinh, '
    '$b.SoDienThoai, $b.Email, $b.DiaChi';

/// Một dòng có các cột của NGUOI_DUNG → [NguoiDung].
NguoiDung nguoiDungTuDong(Map<String, Object?> dong) {
  return NguoiDung(
    maNguoiDung: dong['MaNguoiDung']! as int,
    hoTen: dong['HoTen']! as String,
    gioiTinh: GioiTinh.tuCsdl(dong['GioiTinh']! as String),
    ngaySinh: DateTime.parse(dong['NgaySinh']! as String),
    soDienThoai: dong['SoDienThoai'] as String? ?? '',
    email: dong['Email'] as String? ?? '',
    diaChi: dong['DiaChi'] as String? ?? '',
  );
}

/// Một dòng có các cột của HO_SO_SUC_KHOE → [HoSoSucKhoe].
HoSoSucKhoe hoSoTuDong(Map<String, Object?> dong) {
  return HoSoSucKhoe(
    maHoSo: dong['MaHoSo']! as int,
    maNguoiDung: dong['MaNguoiDung']! as int,
    chieuCao: (dong['ChieuCao']! as num).toDouble(),
    canNang: (dong['CanNang']! as num).toDouble(),
    nhomMau: dong['NhomMau']! as String,
    tienSuBenh: dong['TienSuBenh'] as String? ?? '',
    diUng: dong['DiUng'] as String? ?? '',
    ngayCapNhat: docNgayGio(dong['NgayCapNhat']! as String),
  );
}
