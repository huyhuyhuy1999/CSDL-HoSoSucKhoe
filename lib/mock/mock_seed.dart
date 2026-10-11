part of 'mock_database.dart';

/// Mô tả một người dùng mẫu kèm "thể trạng" để sinh số đo cho hợp lý.
class _HoSoMau {
  const _HoSoMau({
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
  final GioiTinh gioiTinh;
  final (int, int, int) ngaySinh;
  final String soDienThoai;
  final String email;
  final String diaChi;
  final double chieuCao;
  final double canNang;
  final String nhomMau;
  final String tienSuBenh;
  final String diUng;

  // Giá trị trung bình của từng chỉ số.
  final double nhipTim;
  final double spo2;
  final double tamThu;
  final double tamTruong;

  /// Xác suất có một lần đo trong mỗi buổi.
  final double tanSuat;
  final double doLechNhipTim;
}

const _danhSachMau = <_HoSoMau>[
  _HoSoMau(
    hoTen: 'Nguyễn Văn An',
    gioiTinh: GioiTinh.nam,
    ngaySinh: (1968, 3, 12),
    soDienThoai: '0901 234 567',
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
  _HoSoMau(
    hoTen: 'Trần Thị Bích',
    gioiTinh: GioiTinh.nu,
    ngaySinh: (1975, 7, 25),
    soDienThoai: '0912 345 678',
    email: 'bich.tran@example.com',
    diaChi: '45 Nguyễn Trãi, Thanh Xuân, Hà Nội',
    chieuCao: 156,
    canNang: 58,
    nhomMau: 'A+',
    tienSuBenh: 'Đái tháo đường type 2.',
    diUng: '',
    nhipTim: 84,
    spo2: 97.5,
    tamThu: 122,
    tamTruong: 78,
    tanSuat: 0.45,
  ),
  _HoSoMau(
    hoTen: 'Lê Hoàng Cường',
    gioiTinh: GioiTinh.nam,
    ngaySinh: (1990, 11, 2),
    soDienThoai: '0933 456 789',
    email: 'cuong.le@example.com',
    diaChi: '8 Trần Phú, Hải Châu, Đà Nẵng',
    chieuCao: 174,
    canNang: 68,
    nhomMau: 'B+',
    tienSuBenh: '',
    diUng: 'Hải sản',
    nhipTim: 68,
    spo2: 98.5,
    tamThu: 116,
    tamTruong: 74,
    tanSuat: 0.25,
  ),
  _HoSoMau(
    hoTen: 'Phạm Thị Dung',
    gioiTinh: GioiTinh.nu,
    ngaySinh: (1958, 1, 30),
    soDienThoai: '0944 567 890',
    email: 'dung.pham@example.com',
    diaChi: '27 Hùng Vương, Ninh Kiều, Cần Thơ',
    chieuCao: 152,
    canNang: 50,
    nhomMau: 'AB+',
    tienSuBenh: 'Bệnh phổi tắc nghẽn mạn tính (COPD).',
    diUng: '',
    nhipTim: 82,
    spo2: 94.9,
    tamThu: 124,
    tamTruong: 76,
    tanSuat: 0.6,
  ),
  _HoSoMau(
    hoTen: 'Hoàng Minh Đức',
    gioiTinh: GioiTinh.nam,
    ngaySinh: (2001, 5, 18),
    soDienThoai: '0355 678 901',
    email: 'duc.hoang@example.com',
    diaChi: '102 Võ Văn Ngân, TP. Thủ Đức, TP. Hồ Chí Minh',
    chieuCao: 178,
    canNang: 74,
    nhomMau: 'O-',
    tienSuBenh: '',
    diUng: 'Phấn hoa',
    nhipTim: 64,
    spo2: 98.6,
    tamThu: 114,
    tamTruong: 72,
    tanSuat: 0.2,
  ),
  _HoSoMau(
    hoTen: 'Vũ Thị Giang',
    gioiTinh: GioiTinh.nu,
    ngaySinh: (1983, 9, 9),
    soDienThoai: '0366 789 012',
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
  _HoSoMau(
    hoTen: 'Đặng Quốc Huy',
    gioiTinh: GioiTinh.nam,
    ngaySinh: (1949, 12, 21),
    soDienThoai: '0977 890 123',
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
  _HoSoMau(
    hoTen: 'Bùi Thị Lan',
    gioiTinh: GioiTinh.nu,
    ngaySinh: (1996, 4, 14),
    soDienThoai: '0988 901 234',
    email: 'lan.bui@example.com',
    diaChi: '19 Quang Trung, TP. Vinh, Nghệ An',
    chieuCao: 158,
    canNang: 49,
    nhomMau: 'O+',
    tienSuBenh: 'Thiếu máu nhẹ.',
    diUng: '',
    nhipTim: 80,
    spo2: 98,
    tamThu: 99,
    tamTruong: 64,
    tanSuat: 0.3,
  ),
  _HoSoMau(
    hoTen: 'Đỗ Thanh Long',
    gioiTinh: GioiTinh.nam,
    ngaySinh: (2012, 8, 6),
    soDienThoai: '0399 012 345',
    email: '',
    diaChi: '34 Phan Chu Trinh, TP. Vũng Tàu',
    chieuCao: 148,
    canNang: 40,
    nhomMau: 'A+',
    tienSuBenh: '',
    diUng: 'Sữa bò',
    nhipTim: 84,
    spo2: 98.5,
    tamThu: 106,
    tamTruong: 66,
    tanSuat: 0.3,
  ),
  _HoSoMau(
    hoTen: 'Ngô Thị Mai',
    gioiTinh: GioiTinh.nu,
    ngaySinh: (1964, 6, 17),
    soDienThoai: '0909 123 456',
    email: 'mai.ngo@example.com',
    diaChi: '71 Nguyễn Văn Cừ, TP. Biên Hòa, Đồng Nai',
    chieuCao: 154,
    canNang: 66,
    nhomMau: 'B-',
    tienSuBenh: 'Tăng huyết áp, rối loạn mỡ máu.',
    diUng: '',
    nhipTim: 74,
    spo2: 97.2,
    tamThu: 129,
    tamTruong: 82,
    tanSuat: 0.5,
  ),
  _HoSoMau(
    hoTen: 'Dương Văn Nam',
    gioiTinh: GioiTinh.nam,
    ngaySinh: (1979, 2, 28),
    soDienThoai: '0918 234 567',
    email: 'nam.duong@example.com',
    diaChi: '150 Trần Hưng Đạo, TP. Nha Trang, Khánh Hòa',
    chieuCao: 170,
    canNang: 85,
    nhomMau: 'AB-',
    tienSuBenh: 'Béo phì độ I.',
    diUng: '',
    nhipTim: 82,
    spo2: 96.8,
    tamThu: 125,
    tamTruong: 81,
    tanSuat: 0.35,
  ),
  _HoSoMau(
    hoTen: 'Lý Thị Oanh',
    gioiTinh: GioiTinh.nu,
    ngaySinh: (2005, 10, 10),
    soDienThoai: '0327 345 678',
    email: 'oanh.ly@example.com',
    diaChi: '22 Phan Đình Phùng, TP. Đà Lạt, Lâm Đồng',
    chieuCao: 162,
    canNang: 52,
    nhomMau: 'O+',
    tienSuBenh: '',
    diUng: '',
    nhipTim: 70,
    spo2: 98.7,
    tamThu: 110,
    tamTruong: 70,
    tanSuat: 0.2,
  ),
];

/// Lần đo chưa ghi vào bảng (để sắp theo thời gian trước khi cấp mã).
class _LanDoNhap {
  _LanDoNhap({
    required this.maNguoiDung,
    required this.thoiGian,
    required this.nguon,
    required this.giaTri,
    this.maThietBi,
    this.ghiChu = '',
    this.canhBaoDaXem = true,
  });

  final String maNguoiDung;
  final DateTime thoiGian;
  final NguonDuLieu nguon;
  final Map<MaChiSo, double> giaTri;
  final String? maThietBi;
  final String ghiChu;
  final bool canhBaoDaXem;
}

double _gauss(Random rng, double trungBinh, double doLech) {
  final u1 = 1 - rng.nextDouble();
  final u2 = rng.nextDouble();
  return trungBinh + doLech * sqrt(-2 * log(u1)) * cos(2 * pi * u2);
}

double _lamTron(double v, [int thapPhan = 0]) {
  final heSo = pow(10, thapPhan);
  return (v * heSo).round() / heSo;
}

void _taoDuLieuMau(MockDatabase db) {
  final rng = Random(20261011);
  final now = db._now;
  final homNay = DateTime(now.year, now.month, now.day);

  // LOAI_CHI_SO
  db.bangLoaiChiSo.addAll(const [
    LoaiChiSo(
      maLoaiChiSo: 'CS01',
      ma: MaChiSo.nhietDo,
      tenChiSo: 'Nhiệt độ',
      donViDo: '°C',
      binhThuongMin: 36.1,
      binhThuongMax: 37.5,
      canChuYMin: 35,
      canChuYMax: 38.5,
      nhapMin: 30,
      nhapMax: 45,
      soThapPhan: 1,
    ),
    LoaiChiSo(
      maLoaiChiSo: 'CS02',
      ma: MaChiSo.nhipTim,
      tenChiSo: 'Nhịp tim',
      donViDo: 'bpm',
      binhThuongMin: 60,
      binhThuongMax: 100,
      canChuYMin: 50,
      canChuYMax: 120,
      nhapMin: 20,
      nhapMax: 250,
    ),
    LoaiChiSo(
      maLoaiChiSo: 'CS03',
      ma: MaChiSo.spo2,
      tenChiSo: 'SpO2',
      donViDo: '%',
      binhThuongMin: 95,
      binhThuongMax: 100,
      canChuYMin: 90,
      canChuYMax: 100,
      nhapMin: 50,
      nhapMax: 100,
    ),
    LoaiChiSo(
      maLoaiChiSo: 'CS04',
      ma: MaChiSo.huyetApTamThu,
      tenChiSo: 'Huyết áp tâm thu',
      donViDo: 'mmHg',
      binhThuongMin: 90,
      binhThuongMax: 129,
      canChuYMin: 85,
      canChuYMax: 139,
      nhapMin: 50,
      nhapMax: 260,
    ),
    LoaiChiSo(
      maLoaiChiSo: 'CS05',
      ma: MaChiSo.huyetApTamTruong,
      tenChiSo: 'Huyết áp tâm trương',
      donViDo: 'mmHg',
      binhThuongMin: 60,
      binhThuongMax: 84,
      canChuYMin: 55,
      canChuYMax: 89,
      nhapMin: 30,
      nhapMax: 160,
    ),
  ]);

  // THIET_BI
  db.bangThietBi.addAll(const [
    ThietBi(
      maThietBi: 'TB01',
      tenThietBi: 'ESP32 Health Monitor',
      loaiThietBi: LoaiThietBi.daChiSo,
      maDinhDanh: 'ESP32-A4:CF:12:9B:7E:01',
      trangThai: TrangThaiThietBi.hoatDong,
      moTa: 'Trạm đo đa chỉ số: nhiệt độ, nhịp tim, SpO2 và huyết áp.',
    ),
    ThietBi(
      maThietBi: 'TB02',
      tenThietBi: 'Máy đo SpO2 kẹp ngón',
      loaiThietBi: LoaiThietBi.spo2,
      maDinhDanh: 'MAX30102-0007',
      trangThai: TrangThaiThietBi.hoatDong,
      moTa: 'Cảm biến MAX30102 đo SpO2 và nhịp tim.',
    ),
    ThietBi(
      maThietBi: 'TB03',
      tenThietBi: 'Nhiệt kế hồng ngoại',
      loaiThietBi: LoaiThietBi.nhietKe,
      maDinhDanh: 'MLX90614-0012',
      trangThai: TrangThaiThietBi.hoatDong,
      moTa: 'Cảm biến MLX90614 đo nhiệt độ không tiếp xúc.',
    ),
    ThietBi(
      maThietBi: 'TB04',
      tenThietBi: 'Máy đo huyết áp điện tử',
      loaiThietBi: LoaiThietBi.huyetAp,
      maDinhDanh: 'BP-HA01-2231',
      trangThai: TrangThaiThietBi.baoTri,
      moTa: 'Đang hiệu chuẩn lại, tạm ngừng nhận dữ liệu.',
    ),
    ThietBi(
      maThietBi: 'TB05',
      tenThietBi: 'ESP32 Health Monitor (cũ)',
      loaiThietBi: LoaiThietBi.daChiSo,
      maDinhDanh: 'ESP32-A4:CF:12:3C:20:FE',
      trangThai: TrangThaiThietBi.ngungSuDung,
      moTa: 'Bản thử nghiệm đầu tiên, đã thay bằng TB01.',
    ),
  ]);

  // NGUOI_DUNG + HO_SO_SUC_KHOE
  for (final mau in _danhSachMau) {
    final (nam, thang, ngay) = mau.ngaySinh;
    db.themNguoiDung(
      hoTen: mau.hoTen,
      gioiTinh: mau.gioiTinh,
      ngaySinh: DateTime(nam, thang, ngay),
      soDienThoai: mau.soDienThoai,
      email: mau.email,
      diaChi: mau.diaChi,
      chieuCao: mau.chieuCao,
      canNang: mau.canNang,
      nhomMau: mau.nhomMau,
      tienSuBenh: mau.tienSuBenh,
      diUng: mau.diUng,
      ngayCapNhat: homNay.subtract(Duration(days: 3 + rng.nextInt(50))),
    );
  }

  // LAN_DO + CHI_TIET_LAN_DO trong 30 ngày gần nhất
  const cacBuoi = [
    (gioBatDau: 6.5, soGio: 3.0, heSo: 1.0),
    (gioBatDau: 18.0, soGio: 3.5, heSo: 0.7),
  ];
  final nhap = <_LanDoNhap>[];

  for (var ngayTruoc = 29; ngayTruoc >= 0; ngayTruoc--) {
    final ngay = homNay.subtract(Duration(days: ngayTruoc));

    for (var i = 0; i < _danhSachMau.length; i++) {
      final mau = _danhSachMau[i];
      // Bé Long (ND009) bị sốt hai ngày, được đo dày hơn.
      final dangSot = i == 8 && (ngayTruoc == 4 || ngayTruoc == 3);

      for (final buoi in cacBuoi) {
        final xacSuat = dangSot ? 1.0 : mau.tanSuat * buoi.heSo;
        if (rng.nextDouble() > xacSuat) continue;

        final phut = ((buoi.gioBatDau + rng.nextDouble() * buoi.soGio) * 60)
            .round();
        final thoiGian = ngay.add(Duration(minutes: phut));
        if (thoiGian.isAfter(now)) continue;

        final nhietDo = dangSot
            ? _gauss(rng, ngayTruoc == 4 ? 38.7 : 38.2, 0.3)
            : _gauss(rng, 36.7, 0.22);
        final tatCa = <MaChiSo, double>{
          MaChiSo.nhietDo: _lamTron(nhietDo.clamp(34.5, 41), 1),
          MaChiSo.nhipTim: _lamTron(
            _gauss(
              rng,
              mau.nhipTim + (dangSot ? 24 : 0),
              mau.doLechNhipTim,
            ).clamp(42, 170),
          ),
          MaChiSo.spo2: _lamTron(_gauss(rng, mau.spo2, 0.9).clamp(84, 100)),
          MaChiSo.huyetApTamThu: _lamTron(
            _gauss(rng, mau.tamThu, 7).clamp(78, 190),
          ),
          MaChiSo.huyetApTamTruong: _lamTron(
            _gauss(rng, mau.tamTruong, 4.5).clamp(48, 115),
          ),
        };

        // Chọn nguồn dữ liệu; mỗi loại thiết bị chỉ đo một số chỉ số.
        final x = rng.nextDouble();
        NguonDuLieu nguon = NguonDuLieu.thietBi;
        String? maThietBi;
        var chiSo = MaChiSo.values.toSet();
        if (x < 0.22) {
          nguon = NguonDuLieu.nhapThuCong;
        } else if (x < 0.34) {
          maThietBi = 'TB02';
          chiSo = {MaChiSo.spo2, MaChiSo.nhipTim};
        } else if (x < 0.42) {
          maThietBi = 'TB03';
          chiSo = {MaChiSo.nhietDo};
        } else if (x < 0.52 && ngayTruoc > 7) {
          maThietBi = 'TB04';
          chiSo = {
            MaChiSo.nhipTim,
            MaChiSo.huyetApTamThu,
            MaChiSo.huyetApTamTruong,
          };
        } else {
          maThietBi = ngayTruoc > 20 && rng.nextDouble() < 0.4
              ? 'TB05'
              : 'TB01';
        }

        nhap.add(
          _LanDoNhap(
            maNguoiDung: db.bangNguoiDung[i].maNguoiDung,
            thoiGian: thoiGian,
            nguon: nguon,
            maThietBi: maThietBi,
            giaTri: {
              for (final e in tatCa.entries)
                if (chiSo.contains(e.key)) e.key: e.value,
            },
            ghiChu: dangSot ? 'Trẻ sốt, đã dùng thuốc hạ sốt.' : '',
            canhBaoDaXem: ngayTruoc >= 4 || rng.nextDouble() < 0.35,
          ),
        );
      }
    }
  }

  // Vài lần đo rất gần đây để trang Tổng quan luôn có dữ liệu mới.
  nhap.addAll([
    _LanDoNhap(
      maNguoiDung: 'ND003',
      thoiGian: now.subtract(const Duration(hours: 2, minutes: 35)),
      nguon: NguonDuLieu.thietBi,
      maThietBi: 'TB01',
      giaTri: {
        MaChiSo.nhietDo: 36.6,
        MaChiSo.nhipTim: 66,
        MaChiSo.spo2: 99,
        MaChiSo.huyetApTamThu: 117,
        MaChiSo.huyetApTamTruong: 75,
      },
    ),
    _LanDoNhap(
      maNguoiDung: 'ND004',
      thoiGian: now.subtract(const Duration(hours: 1, minutes: 12)),
      nguon: NguonDuLieu.thietBi,
      maThietBi: 'TB02',
      giaTri: {MaChiSo.nhipTim: 88, MaChiSo.spo2: 92},
      ghiChu: 'Đo sau khi đi bộ, hơi khó thở.',
      canhBaoDaXem: false,
    ),
    _LanDoNhap(
      maNguoiDung: 'ND007',
      thoiGian: now.subtract(const Duration(minutes: 18)),
      nguon: NguonDuLieu.thietBi,
      maThietBi: 'TB01',
      giaTri: {
        MaChiSo.nhietDo: 36.9,
        MaChiSo.nhipTim: 126,
        MaChiSo.spo2: 95,
        MaChiSo.huyetApTamThu: 148,
        MaChiSo.huyetApTamTruong: 92,
      },
      ghiChu: 'Hồi hộp, đánh trống ngực.',
      canhBaoDaXem: false,
    ),
  ]);

  nhap.sort((a, b) => a.thoiGian.compareTo(b.thoiGian));
  for (final ld in nhap) {
    db.themLanDo(
      maNguoiDung: ld.maNguoiDung,
      thoiGianDo: ld.thoiGian,
      nguon: ld.nguon,
      maThietBi: ld.maThietBi,
      giaTri: ld.giaTri,
      ghiChu: ld.ghiChu,
      canhBaoDaXem: ld.canhBaoDaXem,
    );
  }
}
