/// Mức độ đánh giá một giá trị đo so với ngưỡng.
enum MucDo {
  binhThuong('Bình thường'),
  canChuY('Cần chú ý'),
  nguyHiem('Nguy hiểm');

  const MucDo(this.nhan);

  /// Nhãn hiển thị, cũng là giá trị cột CANH_BAO.MucDo và cột MucDo của các view.
  final String nhan;

  static MucDo tuCsdl(String giaTri) =>
      values.firstWhere((mucDo) => mucDo.nhan == giaTri);

  /// Mức nặng hơn trong hai mức.
  MucDo nangHon(MucDo other) => index >= other.index ? this : other;
}
