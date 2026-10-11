/// Mức độ đánh giá một giá trị đo so với ngưỡng.
enum MucDo {
  binhThuong('Bình thường'),
  canChuY('Cần chú ý'),
  nguyHiem('Nguy hiểm');

  const MucDo(this.nhan);

  final String nhan;

  /// Mức nặng hơn trong hai mức.
  MucDo nangHon(MucDo other) => index >= other.index ? this : other;
}
