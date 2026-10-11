import 'package:flutter_test/flutter_test.dart';
import 'package:ho_so_suc_khoe/core/utils/chuoi.dart';
import 'package:ho_so_suc_khoe/features/lan_do/domain/entity/lan_do.dart';
import 'package:ho_so_suc_khoe/features/lan_do/domain/entity/loai_chi_so.dart';
import 'package:ho_so_suc_khoe/features/lan_do/domain/entity/muc_do.dart';
import 'package:ho_so_suc_khoe/mock/mock_database.dart';

void main() {
  group('boDau', () {
    test('bỏ dấu tiếng Việt và chuyển về chữ thường', () {
      expect(boDau('Nguyễn Đức Ánh'), 'nguyen duc anh');
      expect(boDau('Lý Thị Oanh'), 'ly thi oanh');
      expect(boDau('Hoàng Minh Đức'), 'hoang minh duc');
    });

    test('khopTuKhoa không phân biệt dấu', () {
      expect(khopTuKhoa('Trần Thị Bích', 'bich'), isTrue);
      expect(khopTuKhoa('Trần Thị Bích', 'BÍCH'), isTrue);
      expect(khopTuKhoa('Trần Thị Bích', 'an'), isTrue);
      expect(khopTuKhoa('Trần Thị Bích', 'long'), isFalse);
    });
  });

  group('MockDatabase', () {
    late MockDatabase db;

    setUp(() => db = MockDatabase());

    test('sinh đủ 7 bảng dữ liệu mẫu', () {
      expect(db.bangNguoiDung, hasLength(12));
      expect(db.bangHoSo, hasLength(12));
      expect(db.bangLoaiChiSo, hasLength(5));
      expect(db.bangThietBi, hasLength(5));
      expect(db.bangLanDo.length, greaterThan(100));
      expect(db.bangCanhBao, isNotEmpty);
    });

    test('khóa chính không trùng', () {
      final maLanDo = db.bangLanDo.map((ld) => ld.maLanDo).toSet();
      final maCanhBao = db.bangCanhBao.map((cb) => cb.maCanhBao).toSet();
      expect(maLanDo, hasLength(db.bangLanDo.length));
      expect(maCanhBao, hasLength(db.bangCanhBao.length));
    });

    test('khóa ngoại luôn trỏ tới bản ghi tồn tại', () {
      for (final ld in db.bangLanDo) {
        expect(db.timNguoiDung(ld.maNguoiDung), isNotNull);
        expect(db.chiTietCua(ld.maLanDo), isNotEmpty);
        if (ld.nguon == NguonDuLieu.thietBi) {
          expect(db.timThietBi(ld.maThietBi), isNotNull);
        } else {
          expect(ld.maThietBi, isNull);
        }
      }
      for (final cb in db.bangCanhBao) {
        expect(db.timLanDo(cb.maLanDo), isNotNull);
      }
    });

    test('không có lần đo nào ở tương lai', () {
      final now = DateTime.now().add(const Duration(seconds: 1));
      expect(db.bangLanDo.every((ld) => ld.thoiGianDo.isBefore(now)), isTrue);
    });

    test('cảnh báo chỉ sinh khi chỉ số vượt ngưỡng', () {
      for (final cb in db.truyVanCanhBao()) {
        expect(cb.loaiChiSo.danhGia(cb.giaTri), cb.canhBao.mucDo);
        expect(cb.canhBao.mucDo, isNot(MucDo.binhThuong));
      }
    });

    test('thêm lần đo vượt ngưỡng sẽ tự tạo cảnh báo', () {
      final truoc = db.bangCanhBao.length;
      final lanDo = db.themLanDo(
        maNguoiDung: 'ND001',
        thoiGianDo: DateTime.now(),
        nguon: NguonDuLieu.nhapThuCong,
        giaTri: {MaChiSo.nhipTim: 135, MaChiSo.spo2: 98},
      );

      expect(db.bangCanhBao.length, truoc + 1);
      expect(db.ghepLanDo(lanDo).mucDo, MucDo.nguyHiem);
    });

    test('xóa người dùng sẽ xóa dây chuyền lần đo và cảnh báo', () {
      db.xoaNguoiDung('ND007');

      expect(db.timNguoiDung('ND007'), isNull);
      expect(db.timHoSo('ND007'), isNull);
      expect(db.bangLanDo.any((ld) => ld.maNguoiDung == 'ND007'), isFalse);
      for (final cb in db.bangCanhBao) {
        expect(db.timLanDo(cb.maLanDo), isNotNull);
      }
    });
  });
}
