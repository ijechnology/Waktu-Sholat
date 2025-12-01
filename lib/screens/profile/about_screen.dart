// lib/screens/profile/about_screen.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Color textColor = Theme.of(context).colorScheme.onSurface;
    final Color secondaryTextColor = const Color(0xFF6B7280);

    return Scaffold(
      appBar: AppBar(
        title: Text('Tentang Aplikasi',
            style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Bagian Latar Belakang ---
            Text(
              'Latar Belakang',
              style: GoogleFonts.inter(
                color: textColor,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              // --- GANTI TEKS INI ---
              'PrayTime adalah aplikasi yang dibuat sebagai Proyek Akhir untuk mata kuliah Pemrograman Aplikasi Mobile. Aplikasi ini bertujuan untuk menyediakan alat bantu ibadah yang mudah diakses dan modern bagi umat Muslim, menggabungkan pengingat waktu sholat yang akurat, kalkulator zakat, dan informasi zona waktu global.',
              style: GoogleFonts.inter(
                color: secondaryTextColor,
                fontSize: 15,
                height: 1.6, // Jarak antar baris
              ),
            ),
            const SizedBox(height: 30),

            // --- Bagian Developer ---
            Text(
              'Developer',
              style: GoogleFonts.inter(
                color: textColor,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor:
                      Theme.of(context).primaryColor.withOpacity(0.1),
                  child: Image.asset('assets/images/foto_developer.png'),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Nissa Aulia R. H.',
                      style: GoogleFonts.inter(
                        color: textColor,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'Sistem Informasi || 124230050',
                      style: GoogleFonts.inter(
                        color: secondaryTextColor,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              'Semoga aplikasi ini dapat bermanfaat, love.',
              style: GoogleFonts.inter(
                color: secondaryTextColor,
                fontSize: 15,
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
