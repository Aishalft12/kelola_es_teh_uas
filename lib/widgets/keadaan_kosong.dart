import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Widget keadaan kosong — dipakai ulang di beberapa halaman
/// Sesuai wireframe: ikon + pesan yang jelas
class KeadaanKosong extends StatelessWidget {
  final IconData ikon;
  final String pesan;

  const KeadaanKosong({
    super.key,
    required this.ikon,
    required this.pesan,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              ikon,
              size: 64,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 16),
            Text(
              pesan,
              style: const TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
