import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Badge status stok — Aman (hijau), Menipis (oranye), Habis (merah)
/// Selalu sertakan teks, jangan hanya warna (aturan style guide)
class StatusBadge extends StatelessWidget {
  final String status;

  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    Color warna;
    switch (status) {
      case 'Aman':
        warna = AppColors.success;
        break;
      case 'Menipis':
        warna = AppColors.warning;
        break;
      case 'Habis':
        warna = AppColors.error;
        break;
      default:
        warna = AppColors.textSecondary;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: warna.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: warna, width: 1),
      ),
      child: Text(
        status,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: warna,
        ),
      ),
    );
  }
}
