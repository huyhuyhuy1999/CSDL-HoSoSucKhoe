import 'package:flutter/widgets.dart';

// Bộ icon Phosphor (https://phosphoricons.com, giấy phép MIT), đóng gói dưới
// dạng font trong assets/fonts/phosphor/.
//
// Gói `phosphor_flutter` trên pub.dev không còn biên dịch được với Flutter
// 3.47 (nó kế thừa `IconData`, nay là final class), nên app tự khai báo các
// icon đang dùng. Muốn thêm icon: tra mã ký tự (codepoint) theo tên trong
// https://github.com/phosphor-icons/flutter rồi thêm một hằng vào lớp có kiểu
// nét tương ứng bên dưới.

/// Nét thường — dùng cho icon mặc định.
abstract final class PhosphorIconsRegular {
  static const String _family = 'PhosphorRegular';

  static const IconData arrowCounterClockwise = IconData(
    0xe038,
    fontFamily: _family,
  );
  static const IconData arrowsClockwise = IconData(0xe094, fontFamily: _family);
  static const IconData barcode = IconData(0xe0b8, fontFamily: _family);
  static const IconData bell = IconData(0xe0ce, fontFamily: _family);
  static const IconData bellSimple = IconData(0xe0d0, fontFamily: _family);
  static const IconData cake = IconData(0xe780, fontFamily: _family);
  static const IconData calendarBlank = IconData(0xe10a, fontFamily: _family);
  static const IconData caretDown = IconData(0xe136, fontFamily: _family);
  static const IconData caretRight = IconData(0xe13a, fontFamily: _family);
  static const IconData chartBar = IconData(0xe150, fontFamily: _family);
  static const IconData checkCircle = IconData(0xe184, fontFamily: _family);
  static const IconData checks = IconData(0xe53a, fontFamily: _family);
  static const IconData circle = IconData(0xe18a, fontFamily: _family);
  static const IconData clipboardText = IconData(0xe198, fontFamily: _family);
  static const IconData clock = IconData(0xe19a, fontFamily: _family);
  static const IconData clockCounterClockwise = IconData(
    0xe1a0,
    fontFamily: _family,
  );
  static const IconData database = IconData(0xe1de, fontFamily: _family);
  static const IconData cpu = IconData(0xe610, fontFamily: _family);
  static const IconData deviceMobile = IconData(0xe1e0, fontFamily: _family);
  static const IconData dotsThreeVertical = IconData(
    0xe208,
    fontFamily: _family,
  );
  static const IconData envelopeSimple = IconData(0xe218, fontFamily: _family);
  static const IconData folderUser = IconData(0xeb46, fontFamily: _family);
  static const IconData genderFemale = IconData(0xe6e0, fontFamily: _family);
  static const IconData genderMale = IconData(0xe6e2, fontFamily: _family);
  static const IconData hash = IconData(0xe2a2, fontFamily: _family);
  static const IconData house = IconData(0xe2c2, fontFamily: _family);
  static const IconData keyboard = IconData(0xe2d8, fontFamily: _family);
  static const IconData magnifyingGlass = IconData(0xe30c, fontFamily: _family);
  static const IconData mapPin = IconData(0xe316, fontFamily: _family);
  static const IconData moon = IconData(0xe330, fontFamily: _family);
  static const IconData notePencil = IconData(0xe34c, fontFamily: _family);
  static const IconData pencilSimple = IconData(0xe3b4, fontFamily: _family);
  static const IconData phone = IconData(0xe3b8, fontFamily: _family);
  static const IconData prohibit = IconData(0xe3de, fontFamily: _family);
  static const IconData sun = IconData(0xe472, fontFamily: _family);
  static const IconData trash = IconData(0xe4a6, fontFamily: _family);
  static const IconData user = IconData(0xe4c2, fontFamily: _family);
  static const IconData users = IconData(0xe4d6, fontFamily: _family);
  static const IconData warningCircle = IconData(0xe4e2, fontFamily: _family);
  static const IconData x = IconData(0xe4f6, fontFamily: _family);
}

/// Tô đặc — dùng cho trạng thái được chọn và icon có nền màu.
abstract final class PhosphorIconsFill {
  static const String _family = 'PhosphorFill';

  static const IconData bell = IconData(0xe0ce, fontFamily: _family);
  static const IconData chartBar = IconData(0xe150, fontFamily: _family);
  static const IconData checkCircle = IconData(0xe184, fontFamily: _family);
  static const IconData clipboardText = IconData(0xe198, fontFamily: _family);
  static const IconData clockCounterClockwise = IconData(
    0xe1a0,
    fontFamily: _family,
  );
  static const IconData database = IconData(0xe1de, fontFamily: _family);
  static const IconData cpu = IconData(0xe610, fontFamily: _family);
  static const IconData drop = IconData(0xe210, fontFamily: _family);
  static const IconData firstAidKit = IconData(0xe570, fontFamily: _family);
  static const IconData folderUser = IconData(0xeb46, fontFamily: _family);
  static const IconData heartbeat = IconData(0xe2ac, fontFamily: _family);
  static const IconData house = IconData(0xe2c2, fontFamily: _family);
  static const IconData identificationCard = IconData(
    0xe2c8,
    fontFamily: _family,
  );
  static const IconData info = IconData(0xe2ce, fontFamily: _family);
  static const IconData notePencil = IconData(0xe34c, fontFamily: _family);
  static const IconData pulse = IconData(0xe000, fontFamily: _family);
  static const IconData thermometerSimple = IconData(
    0xe5cc,
    fontFamily: _family,
  );
  static const IconData users = IconData(0xe4d6, fontFamily: _family);
  static const IconData warning = IconData(0xe4e0, fontFamily: _family);
  static const IconData warningOctagon = IconData(0xe4e4, fontFamily: _family);
}

/// Nét đậm — dùng cho icon nhỏ cần nổi bật.
abstract final class PhosphorIconsBold {
  static const String _family = 'PhosphorBold';

  static const IconData caretDown = IconData(0xe136, fontFamily: _family);
  static const IconData caretRight = IconData(0xe13a, fontFamily: _family);
  static const IconData check = IconData(0xe182, fontFamily: _family);
  static const IconData plus = IconData(0xe3d4, fontFamily: _family);
  static const IconData userPlus = IconData(0xe4d0, fontFamily: _family);
}
