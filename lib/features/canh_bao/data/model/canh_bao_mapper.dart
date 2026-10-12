import '../../../../core/database/truy_van.dart';
import '../../../ho_so/data/model/ho_so_mapper.dart';
import '../../../lan_do/data/model/loai_chi_so_mapper.dart';
import '../../../lan_do/domain/entity/muc_do.dart';
import '../../domain/entity/canh_bao.dart';

/// Câu SELECT cảnh báo đã ghép giá trị đo, người được đo và loại chỉ số
/// (tương đương view V_CANH_BAO_CHI_TIET, nhưng lấy đủ cột của các bảng ghép).
/// Nối thêm mệnh đề WHERE / ORDER BY phía sau khi dùng.
final String selectCanhBao =
    '''
  SELECT cb.MaCanhBao, cb.MaLanDo, cb.MucDo, cb.NoiDung, cb.ThoiGianTao,
         cb.DaXem, ct.GiaTri, ${cotNguoiDung()}, ${cotLoaiChiSo()}
  FROM CANH_BAO        AS cb
  JOIN CHI_TIET_LAN_DO AS ct ON ct.MaLanDo = cb.MaLanDo
                            AND ct.MaLoaiChiSo = cb.MaLoaiChiSo
  JOIN LAN_DO          AS ld ON ld.MaLanDo = cb.MaLanDo
  JOIN NGUOI_DUNG      AS nd ON nd.MaNguoiDung = ld.MaNguoiDung
  JOIN LOAI_CHI_SO     AS l  ON l.MaLoaiChiSo = cb.MaLoaiChiSo
''';

/// Một dòng của [selectCanhBao] → [CanhBaoDayDu]. Trả về `null` nếu loại chỉ
/// số chưa được ứng dụng hỗ trợ hiển thị.
CanhBaoDayDu? canhBaoTuDong(Map<String, Object?> dong) {
  final loai = loaiChiSoTuDong(dong);
  if (loai == null) return null;

  return CanhBaoDayDu(
    canhBao: CanhBao(
      maCanhBao: dong['MaCanhBao']! as int,
      maLanDo: dong['MaLanDo']! as int,
      maLoaiChiSo: loai.maLoaiChiSo,
      mucDo: MucDo.tuCsdl(dong['MucDo']! as String),
      noiDung: dong['NoiDung']! as String,
      thoiGianTao: docNgayGio(dong['ThoiGianTao']! as String),
      daXem: dong['DaXem'] == 1,
    ),
    nguoiDung: nguoiDungTuDong(dong),
    loaiChiSo: loai,
    giaTri: (dong['GiaTri']! as num).toDouble(),
  );
}
