import 'package:flutter/material.dart';

import '../extensions/context_extensions.dart';

/// Hộp thoại xác nhận; trả về `true` nếu người dùng đồng ý.
Future<bool> xacNhan(
  BuildContext context, {
  required String tieuDe,
  required String noiDung,
  String nhanDongY = 'Đồng ý',
  bool nguyHiem = false,
}) async {
  final dongY = await showDialog<bool>(
    context: context,
    builder: (context) {
      final p = context.palette;

      return AlertDialog(
        title: Text(tieuDe),
        content: Text(noiDung),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            style: TextButton.styleFrom(foregroundColor: p.textSecondary),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: nguyHiem ? p.danger : p.primary,
            ),
            child: Text(nhanDongY),
          ),
        ],
      );
    },
  );
  return dongY ?? false;
}
