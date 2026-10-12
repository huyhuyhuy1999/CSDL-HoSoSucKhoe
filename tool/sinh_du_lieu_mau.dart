// Sinh dữ liệu mẫu cho cả hai hệ quản trị từ cùng một bộ số liệu:
//   - sql/sqlserver/03_du_lieu_mau.sql  (T-SQL, nộp bài)
//   - sql/sqlite/03_du_lieu_mau.sql     (SQLite, chạy trong app)
//
// Chạy:  dart run tool/sinh_du_lieu_mau.dart
//
// Dữ liệu gồm 12 người dùng, 5 thiết bị mô phỏng, 5 loại chỉ số và các lần đo
// trong 30 ngày, kết thúc ở [ngayCuoi]. Mốc ngày cố định và bộ sinh số ngẫu
// nhiên có hạt giống cố định, nên chạy lại luôn ra đúng một kết quả — nhờ đó
// số liệu trong tài liệu và trong các ca kiểm thử không thay đổi.
//
// Cảnh báo KHÔNG được INSERT ở đây: trigger trên CHI_TIET_LAN_DO tự tạo
// cảnh báo khi một giá trị đo vượt ngưỡng.

import 'dart:io';
import 'dart:math';

/// Ngày cuối cùng có dữ liệu mẫu.
final ngayCuoi = DateTime(2026, 10, 10);
const soNgay = 30;

// ── Danh mục ─────────────────────────────────────────────────────────────

class LoaiChiSo {
  const LoaiChiSo(
    this.ma,
    this.kyHieu,
    this.ten,
    this.donVi,
    this.soThapPhan,
    this.giaTriMin,
    this.giaTriMax,
    this.binhThuongMin,
    this.binhThuongMax,
    this.canhBaoMin,
    this.canhBaoMax,
  );

  final int ma;
  final String kyHieu;
  final String ten;
  final String donVi;
  final int soThapPhan;

  /// Khoảng giá trị hợp lệ khi nhập liệu.
  final double giaTriMin;
  final double giaTriMax;

  /// Khoảng bình thường.
  final double binhThuongMin;
  final double binhThuongMax;

  /// Khoảng "cần chú ý" (bao ngoài khoảng bình thường); ngoài khoảng này là
  /// "nguy hiểm".
  final double canhBaoMin;
  final double canhBaoMax;
}

const loaiChiSo = [
  LoaiChiSo(1, 'NHIET_DO', 'Nhiệt độ', '°C', 1, 30, 45, 36.1, 37.5, 35, 38.5),
  LoaiChiSo(2, 'NHIP_TIM', 'Nhịp tim', 'bpm', 0, 20, 250, 60, 100, 50, 120),
  LoaiChiSo(3, 'SPO2', 'SpO2', '%', 0, 50, 100, 95, 100, 90, 100),
  LoaiChiSo(
    4,
    'HA_TAM_THU',
    'Huyết áp tâm thu',
    'mmHg',
    0,
    50,
    260,
    90,
    129,
    85,
    139,
  ),
  LoaiChiSo(
    5,
    'HA_TAM_TRUONG',
    'Huyết áp tâm trương',
    'mmHg',
    0,
    30,
    160,
    60,
    84,
    55,
    89,
  ),
];

const nhietDo = 1, nhipTim = 2, spo2 = 3, tamThu = 4, tamTruong = 5;

class ThietBi {
  const ThietBi(
    this.ma,
    this.ten,
    this.loai,
    this.maDinhDanh,
    this.trangThai,
    this.moTa,
  );

  final int ma;
  final String ten;
  final String loai;
  final String maDinhDanh;
  final String trangThai;
  final String moTa;
}

const thietBi = [
  ThietBi(
    1,
    'ESP32 Health Monitor',
    'Thiết bị đa chỉ số',
    'ESP32-A4:CF:12:9B:7E:01',
    'Hoạt động',
    'Trạm đo đa chỉ số: nhiệt độ, nhịp tim, SpO2 và huyết áp.',
  ),
  ThietBi(
    2,
    'Máy đo SpO2 kẹp ngón',
    'Máy đo SpO2',
    'MAX30102-0007',
    'Hoạt động',
    'Cảm biến MAX30102 đo SpO2 và nhịp tim.',
  ),
  ThietBi(
    3,
    'Nhiệt kế hồng ngoại',
    'Nhiệt kế',
    'MLX90614-0012',
    'Hoạt động',
    'Cảm biến MLX90614 đo nhiệt độ không tiếp xúc.',
  ),
  ThietBi(
    4,
    'Máy đo huyết áp điện tử',
    'Máy đo huyết áp',
    'BP-HA01-2231',
    'Bảo trì',
    'Đang hiệu chuẩn lại, tạm ngừng nhận dữ liệu.',
  ),
  ThietBi(
    5,
    'ESP32 Health Monitor (cũ)',
    'Thiết bị đa chỉ số',
    'ESP32-A4:CF:12:3C:20:FE',
    'Ngừng sử dụng',
    'Bản thử nghiệm đầu tiên, đã thay bằng thiết bị số 1.',
  ),
  ThietBi(
    6,
    'Máy đo SpO2 dự phòng',
    'Máy đo SpO2',
    'MAX30102-0019',
    'Hoạt động',
    'Thiết bị dự phòng, chưa đưa vào sử dụng.',
  ),
];

/// Một người dùng mẫu kèm "thể trạng" để sinh số đo cho hợp lý.
class NguoiMau {
  const NguoiMau({
    required this.hoTen,
    required this.gioiTinh,
    required this.ngaySinh,
    required this.soDienThoai,
    required this.email,
    required this.diaChi,
    required this.chieuCao,
    required this.canNang,
    required this.nhomMau,
    required this.tienSuBenh,
    required this.diUng,
    required this.nhipTim,
    required this.spo2,
    required this.tamThu,
    required this.tamTruong,
    required this.tanSuat,
    this.doLechNhipTim = 6,
  });

  final String hoTen;
  final String gioiTinh;
  final String ngaySinh;
  final String soDienThoai;
  final String? email;
  final String diaChi;
  final double chieuCao;
  final double canNang;
  final String nhomMau;
  final String? tienSuBenh;
  final String? diUng;

  // Giá trị trung bình của từng chỉ số.
  final double nhipTim;
  final double spo2;
  final double tamThu;
  final double tamTruong;

  /// Xác suất có một lần đo trong mỗi buổi.
  final double tanSuat;
  final double doLechNhipTim;
}

const nguoiMau = [
  NguoiMau(
    hoTen: 'Nguyễn Văn An',
    gioiTinh: 'Nam',
    ngaySinh: '1968-03-12',
    soDienThoai: '0901234567',
    email: 'an.nguyen@example.com',
    diaChi: '12 Lê Lợi, Quận 1, TP. Hồ Chí Minh',
    chieuCao: 168,
    canNang: 72,
    nhomMau: 'O+',
    tienSuBenh: 'Tăng huyết áp (phát hiện năm 2019), đang điều trị ngoại trú.',
    diUng: 'Penicillin',
    nhipTim: 76,
    spo2: 97.5,
    tamThu: 128,
    tamTruong: 82,
    tanSuat: 0.55,
  ),
  NguoiMau(
    hoTen: 'Trần Thị Bích',
    gioiTinh: 'Nữ',
    ngaySinh: '1975-07-25',
    soDienThoai: '0912345678',
    email: 'bich.tran@example.com',
    diaChi: '45 Nguyễn Trãi, Thanh Xuân, Hà Nội',
    chieuCao: 156,
    canNang: 58,
    nhomMau: 'A+',
    tienSuBenh: 'Đái tháo đường type 2.',
    diUng: null,
    nhipTim: 84,
    spo2: 97.5,
    tamThu: 122,
    tamTruong: 78,
    tanSuat: 0.45,
  ),
  NguoiMau(
    hoTen: 'Lê Hoàng Cường',
    gioiTinh: 'Nam',
    ngaySinh: '1990-11-02',
    soDienThoai: '0933456789',
    email: 'cuong.le@example.com',
    diaChi: '8 Trần Phú, Hải Châu, Đà Nẵng',
    chieuCao: 174,
    canNang: 68,
    nhomMau: 'B+',
    tienSuBenh: null,
    diUng: 'Hải sản',
    nhipTim: 68,
    spo2: 98.5,
    tamThu: 116,
    tamTruong: 74,
    tanSuat: 0.25,
  ),
  NguoiMau(
    hoTen: 'Phạm Thị Dung',
    gioiTinh: 'Nữ',
    ngaySinh: '1958-01-30',
    soDienThoai: '0944567890',
    email: 'dung.pham@example.com',
    diaChi: '27 Hùng Vương, Ninh Kiều, Cần Thơ',
    chieuCao: 152,
    canNang: 50,
    nhomMau: 'AB+',
    tienSuBenh: 'Bệnh phổi tắc nghẽn mạn tính (COPD).',
    diUng: null,
    nhipTim: 82,
    spo2: 94.9,
    tamThu: 124,
    tamTruong: 76,
    tanSuat: 0.6,
  ),
  NguoiMau(
    hoTen: 'Hoàng Minh Đức',
    gioiTinh: 'Nam',
    ngaySinh: '2001-05-18',
    soDienThoai: '0355678901',
    email: 'duc.hoang@example.com',
    diaChi: '102 Võ Văn Ngân, TP. Thủ Đức, TP. Hồ Chí Minh',
    chieuCao: 178,
    canNang: 74,
    nhomMau: 'O-',
    tienSuBenh: null,
    diUng: 'Phấn hoa',
    nhipTim: 64,
    spo2: 98.6,
    tamThu: 114,
    tamTruong: 72,
    tanSuat: 0.2,
  ),
  NguoiMau(
    hoTen: 'Vũ Thị Giang',
    gioiTinh: 'Nữ',
    ngaySinh: '1983-09-09',
    soDienThoai: '0366789012',
    email: 'giang.vu@example.com',
    diaChi: '5 Lạch Tray, Ngô Quyền, Hải Phòng',
    chieuCao: 160,
    canNang: 54,
    nhomMau: 'A-',
    tienSuBenh: 'Hen phế quản.',
    diUng: 'Bụi nhà, lông mèo',
    nhipTim: 86,
    spo2: 96.6,
    tamThu: 112,
    tamTruong: 70,
    tanSuat: 0.4,
  ),
  NguoiMau(
    hoTen: 'Đặng Quốc Huy',
    gioiTinh: 'Nam',
    ngaySinh: '1949-12-21',
    soDienThoai: '0977890123',
    email: 'huy.dang@example.com',
    diaChi: '63 Lê Duẩn, TP. Huế',
    chieuCao: 165,
    canNang: 63,
    nhomMau: 'B+',
    tienSuBenh: 'Rung nhĩ, tăng huyết áp.',
    diUng: 'Aspirin',
    nhipTim: 94,
    spo2: 96.5,
    tamThu: 133,
    tamTruong: 84,
    tanSuat: 0.65,
    doLechNhipTim: 12,
  ),
  NguoiMau(
    hoTen: 'Bùi Thị Lan',
    gioiTinh: 'Nữ',
    ngaySinh: '1996-04-14',
    soDienThoai: '0988901234',
    email: 'lan.bui@example.com',
    diaChi: '19 Quang Trung, TP. Vinh, Nghệ An',
    chieuCao: 158,
    canNang: 49,
    nhomMau: 'O+',
    tienSuBenh: 'Thiếu máu nhẹ.',
    diUng: null,
    nhipTim: 80,
    spo2: 98,
    tamThu: 99,
    tamTruong: 64,
    tanSuat: 0.3,
  ),
  NguoiMau(
    hoTen: 'Đỗ Thanh Long',
    gioiTinh: 'Nam',
    ngaySinh: '2012-08-06',
    soDienThoai: '0399012345',
    email: null,
    diaChi: '34 Phan Chu Trinh, TP. Vũng Tàu',
    chieuCao: 148,
    canNang: 40,
    nhomMau: 'A+',
    tienSuBenh: null,
    diUng: 'Sữa bò',
    nhipTim: 84,
    spo2: 98.5,
    tamThu: 106,
    tamTruong: 66,
    tanSuat: 0.3,
  ),
  NguoiMau(
    hoTen: 'Ngô Thị Mai',
    gioiTinh: 'Nữ',
    ngaySinh: '1964-06-17',
    soDienThoai: '0909123456',
    email: 'mai.ngo@example.com',
    diaChi: '71 Nguyễn Văn Cừ, TP. Biên Hòa, Đồng Nai',
    chieuCao: 154,
    canNang: 66,
    nhomMau: 'B-',
    tienSuBenh: 'Tăng huyết áp, rối loạn mỡ máu.',
    diUng: null,
    nhipTim: 74,
    spo2: 97.2,
    tamThu: 129,
    tamTruong: 82,
    tanSuat: 0.5,
  ),
  NguoiMau(
    hoTen: 'Dương Văn Nam',
    gioiTinh: 'Nam',
    ngaySinh: '1979-02-28',
    soDienThoai: '0918234567',
    email: 'nam.duong@example.com',
    diaChi: '150 Trần Hưng Đạo, TP. Nha Trang, Khánh Hòa',
    chieuCao: 170,
    canNang: 85,
    nhomMau: 'AB-',
    tienSuBenh: 'Béo phì độ I.',
    diUng: null,
    nhipTim: 82,
    spo2: 96.8,
    tamThu: 125,
    tamTruong: 81,
    tanSuat: 0.35,
  ),
  NguoiMau(
    hoTen: 'Lý Thị Oanh',
    gioiTinh: 'Nữ',
    ngaySinh: '2005-10-10',
    soDienThoai: '0327345678',
    email: 'oanh.ly@example.com',
    diaChi: '22 Phan Đình Phùng, TP. Đà Lạt, Lâm Đồng',
    chieuCao: 162,
    canNang: 52,
    nhomMau: 'O+',
    tienSuBenh: null,
    diUng: null,
    nhipTim: 70,
    spo2: 98.7,
    tamThu: 110,
    tamTruong: 70,
    tanSuat: 0.2,
  ),
];

// ── Sinh lần đo ──────────────────────────────────────────────────────────

class LanDo {
  LanDo({
    required this.maNguoiDung,
    required this.thoiGian,
    required this.giaTri,
    this.maThietBi,
    this.ghiChu,
  });

  late final int ma;
  final int maNguoiDung;
  final DateTime thoiGian;

  /// `null` nghĩa là nhập thủ công.
  final int? maThietBi;
  final String? ghiChu;

  /// Mã loại chỉ số → giá trị.
  final Map<int, double> giaTri;

  String get nguon => maThietBi == null ? 'Thủ công' : 'Thiết bị';
}

double _gauss(Random rng, double trungBinh, double doLech) {
  final u1 = 1 - rng.nextDouble();
  final u2 = rng.nextDouble();
  return trungBinh + doLech * sqrt(-2 * log(u1)) * cos(2 * pi * u2);
}

double _lamTron(num v, [int thapPhan = 0]) {
  final heSo = pow(10, thapPhan);
  return (v * heSo).round() / heSo;
}

List<LanDo> sinhLanDo() {
  final rng = Random(20261011);
  const cacBuoi = [
    (gioBatDau: 6.5, soGio: 3.0, heSo: 1.0),
    (gioBatDau: 18.0, soGio: 3.5, heSo: 0.7),
  ];
  final ketQua = <LanDo>[];

  for (var ngayTruoc = soNgay - 1; ngayTruoc >= 0; ngayTruoc--) {
    final ngay = ngayCuoi.subtract(Duration(days: ngayTruoc));

    for (var i = 0; i < nguoiMau.length; i++) {
      final mau = nguoiMau[i];
      // Bé Long (người dùng số 9) bị sốt hai ngày, được đo dày hơn.
      final dangSot = i == 8 && (ngayTruoc == 4 || ngayTruoc == 3);

      for (final buoi in cacBuoi) {
        final xacSuat = dangSot ? 1.0 : mau.tanSuat * buoi.heSo;
        if (rng.nextDouble() > xacSuat) continue;

        final phut = ((buoi.gioBatDau + rng.nextDouble() * buoi.soGio) * 60)
            .round();
        final thoiGian = ngay.add(Duration(minutes: phut));

        final giaTriNhietDo = dangSot
            ? _gauss(rng, ngayTruoc == 4 ? 38.7 : 38.2, 0.3)
            : _gauss(rng, 36.7, 0.22);
        final tatCa = <int, double>{
          nhietDo: _lamTron(giaTriNhietDo.clamp(34.5, 41), 1),
          nhipTim: _lamTron(
            _gauss(
              rng,
              mau.nhipTim + (dangSot ? 24 : 0),
              mau.doLechNhipTim,
            ).clamp(42, 170),
          ),
          spo2: _lamTron(_gauss(rng, mau.spo2, 0.9).clamp(84, 100)),
          tamThu: _lamTron(_gauss(rng, mau.tamThu, 7).clamp(78, 190)),
          tamTruong: _lamTron(_gauss(rng, mau.tamTruong, 4.5).clamp(48, 115)),
        };

        // Chọn nguồn dữ liệu; mỗi loại thiết bị chỉ đo một số chỉ số.
        final x = rng.nextDouble();
        int? maThietBi;
        var chiSo = {nhietDo, nhipTim, spo2, tamThu, tamTruong};
        if (x < 0.22) {
          maThietBi = null; // nhập thủ công, đủ 5 chỉ số
        } else if (x < 0.34) {
          maThietBi = 2;
          chiSo = {spo2, nhipTim};
        } else if (x < 0.42) {
          maThietBi = 3;
          chiSo = {nhietDo};
        } else if (x < 0.52 && ngayTruoc > 7) {
          maThietBi = 4;
          chiSo = {nhipTim, tamThu, tamTruong};
        } else {
          maThietBi = ngayTruoc > 20 && rng.nextDouble() < 0.4 ? 5 : 1;
        }

        ketQua.add(
          LanDo(
            maNguoiDung: i + 1,
            thoiGian: thoiGian,
            maThietBi: maThietBi,
            giaTri: {
              for (final e in tatCa.entries)
                if (chiSo.contains(e.key)) e.key: e.value,
            },
            ghiChu: dangSot ? 'Trẻ sốt, đã dùng thuốc hạ sốt.' : null,
          ),
        );
      }
    }
  }

  // Vài lần đo đáng chú ý vào chiều ngày cuối, để phần demo có sẵn tình huống.
  DateTime luc(int gio, int phut) =>
      DateTime(ngayCuoi.year, ngayCuoi.month, ngayCuoi.day, gio, phut);
  ketQua.addAll([
    LanDo(
      maNguoiDung: 3,
      thoiGian: luc(15, 55),
      maThietBi: 1,
      giaTri: {
        nhietDo: 36.6,
        nhipTim: 66,
        spo2: 99,
        tamThu: 117,
        tamTruong: 75,
      },
    ),
    LanDo(
      maNguoiDung: 4,
      thoiGian: luc(17, 18),
      maThietBi: 2,
      giaTri: {nhipTim: 88, spo2: 92},
      ghiChu: 'Đo sau khi đi bộ, hơi khó thở.',
    ),
    LanDo(
      maNguoiDung: 7,
      thoiGian: luc(18, 12),
      maThietBi: 1,
      giaTri: {
        nhietDo: 36.9,
        nhipTim: 126,
        spo2: 95,
        tamThu: 148,
        tamTruong: 92,
      },
      ghiChu: 'Hồi hộp, đánh trống ngực.',
    ),
  ]);

  ketQua.sort((a, b) => a.thoiGian.compareTo(b.thoiGian));
  for (var i = 0; i < ketQua.length; i++) {
    ketQua[i].ma = i + 1;
  }
  return ketQua;
}

// ── Xuất SQL ─────────────────────────────────────────────────────────────

enum HeQuanTri { sqlServer, sqlite }

class TrinhXuat {
  TrinhXuat(this.he);

  final HeQuanTri he;
  final _buf = StringBuffer();

  bool get _laSqlServer => he == HeQuanTri.sqlServer;

  /// Chuỗi Unicode: N'...' trên SQL Server, '...' trên SQLite.
  String chuoi(String? s) {
    if (s == null) return 'NULL';
    final thoat = s.replaceAll("'", "''");
    return _laSqlServer ? "N'$thoat'" : "'$thoat'";
  }

  /// Chuỗi ASCII (mã, email, số điện thoại).
  String ascii(String? s) =>
      s == null ? 'NULL' : "'${s.replaceAll("'", "''")}'";

  String so(num? v) {
    if (v == null) return 'NULL';
    return v == v.roundToDouble() ? v.toInt().toString() : v.toString();
  }

  String ngayGio(DateTime d) {
    String hai(int n) => n.toString().padLeft(2, '0');
    final ngay = '${d.year}-${hai(d.month)}-${hai(d.day)}';
    final gio = '${hai(d.hour)}:${hai(d.minute)}:${hai(d.second)}';
    // SQL Server: dạng ISO 8601 có chữ T không phụ thuộc cài đặt ngôn ngữ.
    return _laSqlServer ? "'${ngay}T$gio'" : "'$ngay $gio'";
  }

  void dong([String s = '']) => _buf.writeln(s);

  void lo() {
    if (_laSqlServer) dong('GO');
    dong();
  }

  /// Ghi các dòng INSERT, chia lô vì SQL Server giới hạn 1000 dòng mỗi lệnh.
  void chen(
    String bang,
    List<String> cot,
    List<List<String>> cacDong, {
    bool coMaTuTang = true,
    int coLo = 200,
  }) {
    if (_laSqlServer && coMaTuTang) dong('SET IDENTITY_INSERT $bang ON;');
    for (var i = 0; i < cacDong.length; i += coLo) {
      final nhom = cacDong.sublist(i, min(i + coLo, cacDong.length));
      dong('INSERT INTO $bang (${cot.join(', ')}) VALUES');
      for (var j = 0; j < nhom.length; j++) {
        dong('    (${nhom[j].join(', ')})${j == nhom.length - 1 ? ';' : ','}');
      }
    }
    if (_laSqlServer && coMaTuTang) dong('SET IDENTITY_INSERT $bang OFF;');
    lo();
  }

  String xuat(List<LanDo> lanDo) {
    final soChiTiet = lanDo.fold<int>(0, (n, ld) => n + ld.giaTri.length);
    final ngayDau = ngayCuoi.subtract(const Duration(days: soNgay - 1));
    String ngay(DateTime d) =>
        '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

    dong('-- ${'=' * 76}');
    dong('-- DỮ LIỆU MẪU — ${_laSqlServer ? 'SQL Server' : 'SQLite'}');
    dong('--');
    dong('-- File này được sinh tự động bởi tool/sinh_du_lieu_mau.dart.');
    dong(
      '-- Đừng sửa tay: hãy sửa công cụ rồi chạy lại để hai hệ luôn khớp nhau.',
    );
    dong('--');
    dong(
      '-- ${nguoiMau.length} người dùng, ${nguoiMau.length} hồ sơ, '
      '${thietBi.length} thiết bị, ${loaiChiSo.length} loại chỉ số,',
    );
    dong(
      '-- ${lanDo.length} lần đo và $soChiTiet giá trị đo, '
      'từ ${ngay(ngayDau)} đến ${ngay(ngayCuoi)}.',
    );
    dong(
      '-- Cảnh báo do trigger TRG_CHI_TIET_LAN_DO_CanhBao tự sinh khi chèn giá trị đo.',
    );
    dong('-- ${'=' * 76}');
    dong();
    if (_laSqlServer) {
      dong('USE QuanLyHoSoSucKhoe;');
      dong('GO');
      dong('SET NOCOUNT ON;');
      dong('GO');
      dong();
    }

    dong(
      '-- LOAI_CHI_SO: danh mục chỉ số và ngưỡng đánh giá (Người 7, Người 10)',
    );
    chen(
      'LOAI_CHI_SO',
      [
        'MaLoaiChiSo',
        'KyHieu',
        'TenChiSo',
        'DonViDo',
        'SoThapPhan',
        'GiaTriMin',
        'GiaTriMax',
        'BinhThuongMin',
        'BinhThuongMax',
        'CanhBaoMin',
        'CanhBaoMax',
      ],
      [
        for (final l in loaiChiSo)
          [
            so(l.ma),
            ascii(l.kyHieu),
            chuoi(l.ten),
            chuoi(l.donVi),
            so(l.soThapPhan),
            so(l.giaTriMin),
            so(l.giaTriMax),
            so(l.binhThuongMin),
            so(l.binhThuongMax),
            so(l.canhBaoMin),
            so(l.canhBaoMax),
          ],
      ],
    );

    dong('-- THIET_BI: thiết bị mô phỏng (Người 9)');
    chen(
      'THIET_BI',
      [
        'MaThietBi',
        'TenThietBi',
        'LoaiThietBi',
        'MaDinhDanh',
        'TrangThai',
        'MoTa',
      ],
      [
        for (final t in thietBi)
          [
            so(t.ma),
            chuoi(t.ten),
            chuoi(t.loai),
            ascii(t.maDinhDanh),
            chuoi(t.trangThai),
            chuoi(t.moTa),
          ],
      ],
    );

    dong('-- NGUOI_DUNG (Người 5)');
    final ngayTao = DateTime(2026, 9, 1, 8);
    chen(
      'NGUOI_DUNG',
      [
        'MaNguoiDung',
        'HoTen',
        'GioiTinh',
        'NgaySinh',
        'SoDienThoai',
        'Email',
        'DiaChi',
        'NgayTao',
      ],
      [
        for (var i = 0; i < nguoiMau.length; i++)
          [
            so(i + 1),
            chuoi(nguoiMau[i].hoTen),
            chuoi(nguoiMau[i].gioiTinh),
            ascii(nguoiMau[i].ngaySinh),
            ascii(nguoiMau[i].soDienThoai),
            ascii(nguoiMau[i].email),
            chuoi(nguoiMau[i].diaChi),
            ngayGio(ngayTao),
          ],
      ],
    );

    dong('-- HO_SO_SUC_KHOE: mỗi người dùng một hồ sơ (Người 6)');
    final rngHoSo = Random(42);
    chen(
      'HO_SO_SUC_KHOE',
      [
        'MaHoSo',
        'MaNguoiDung',
        'ChieuCao',
        'CanNang',
        'NhomMau',
        'TienSuBenh',
        'DiUng',
        'NgayCapNhat',
      ],
      [
        for (var i = 0; i < nguoiMau.length; i++)
          [
            so(i + 1),
            so(i + 1),
            so(nguoiMau[i].chieuCao),
            so(nguoiMau[i].canNang),
            ascii(nguoiMau[i].nhomMau),
            chuoi(nguoiMau[i].tienSuBenh),
            chuoi(nguoiMau[i].diUng),
            ngayGio(
              ngayCuoi
                  .subtract(Duration(days: 3 + rngHoSo.nextInt(50)))
                  .add(const Duration(hours: 9)),
            ),
          ],
      ],
    );

    dong('-- LAN_DO (Người 8)');
    chen(
      'LAN_DO',
      [
        'MaLanDo',
        'MaNguoiDung',
        'MaThietBi',
        'NguonDuLieu',
        'ThoiGianDo',
        'GhiChu',
      ],
      [
        for (final ld in lanDo)
          [
            so(ld.ma),
            so(ld.maNguoiDung),
            so(ld.maThietBi),
            chuoi(ld.nguon),
            ngayGio(ld.thoiGian),
            chuoi(ld.ghiChu),
          ],
      ],
    );

    dong('-- CHI_TIET_LAN_DO: mỗi dòng là một chỉ số của một lần đo (Người 7)');
    chen(
      'CHI_TIET_LAN_DO',
      ['MaLanDo', 'MaLoaiChiSo', 'GiaTri'],
      [
        for (final ld in lanDo)
          for (final e in ld.giaTri.entries)
            [so(ld.ma), so(e.key), so(e.value)],
      ],
      coMaTuTang: false,
    );

    // Cảnh báo đã do trigger sinh ra; chỉ còn việc đánh dấu "đã xem" cho các
    // cảnh báo cũ, giữ lại một phần cảnh báo 4 ngày gần nhất là chưa xem.
    final mocChuaXem = ngayCuoi.subtract(const Duration(days: 3));
    dong('-- CANH_BAO: đánh dấu đã xem cho cảnh báo cũ (Người 10)');
    dong('UPDATE CANH_BAO SET DaXem = 1');
    dong('WHERE ThoiGianTao < ${ngayGio(mocChuaXem)} OR MaLanDo % 3 = 0;');
    lo();

    return _buf.toString();
  }
}

void main() {
  final lanDo = sinhLanDo();
  for (final (he, duongDan) in [
    (HeQuanTri.sqlServer, 'sql/sqlserver/03_du_lieu_mau.sql'),
    (HeQuanTri.sqlite, 'sql/sqlite/03_du_lieu_mau.sql'),
  ]) {
    File(duongDan)
      ..createSync(recursive: true)
      ..writeAsStringSync(TrinhXuat(he).xuat(lanDo));
    stdout.writeln('Đã ghi $duongDan');
  }
  final soChiTiet = lanDo.fold<int>(0, (n, ld) => n + ld.giaTri.length);
  stdout.writeln('${lanDo.length} lần đo, $soChiTiet giá trị đo.');
}
