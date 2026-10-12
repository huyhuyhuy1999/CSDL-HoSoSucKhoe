/// Mã hiển thị trên giao diện, ghép tiền tố với khóa chính dạng số trong
/// cơ sở dữ liệu: người dùng 7 → "ND007", lần đo 246 → "LD0246".
abstract final class MaHienThi {
  static String nguoiDung(int ma) => 'ND${_dem(ma, 3)}';

  static String hoSo(int ma) => 'HS${_dem(ma, 3)}';

  static String thietBi(int ma) => 'TB${_dem(ma, 2)}';

  static String lanDo(int ma) => 'LD${_dem(ma, 4)}';

  static String _dem(int ma, int doDai) => ma.toString().padLeft(doDai, '0');
}
