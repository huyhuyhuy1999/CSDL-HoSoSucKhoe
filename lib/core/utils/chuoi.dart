const _coDau =
    'àáạảãâầấậẩẫăằắặẳẵèéẹẻẽêềếệểễìíịỉĩòóọỏõôồốộổỗơờớợởỡùúụủũưừứựửữỳýỵỷỹđ';
const _khongDau =
    'aaaaaaaaaaaaaaaaaeeeeeeeeeeeiiiiiooooooooooooooooouuuuuuuuuuuyyyyyd';

/// Chuyển về chữ thường không dấu để tìm kiếm tiếng Việt
/// ("Nguyễn" khớp với "nguyen").
String boDau(String input) {
  final buffer = StringBuffer();
  for (final kyTu in input.toLowerCase().split('')) {
    final i = _coDau.indexOf(kyTu);
    buffer.write(i >= 0 ? _khongDau[i] : kyTu);
  }
  return buffer.toString();
}

/// `true` nếu [vanBan] chứa [tuKhoa], không phân biệt hoa thường và dấu.
bool khopTuKhoa(String vanBan, String tuKhoa) {
  final khoa = boDau(tuKhoa.trim());
  if (khoa.isEmpty) return true;
  return boDau(vanBan).contains(khoa);
}
