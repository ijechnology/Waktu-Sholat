import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/quran_provider.dart';
import 'surah_detail_screen.dart'; // Halaman detail

class QuranListScreen extends StatelessWidget {
  const QuranListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final quranProvider = context.watch<QuranProvider>();

    final Color primaryAccent = Theme.of(context).primaryColor;
    final Color secondaryAccent = Theme.of(context).colorScheme.secondary;
    final Color cardColor = Theme.of(context).colorScheme.surface;
    final Color textColor = Theme.of(context).colorScheme.onSurface;

    return Scaffold(
      appBar: AppBar(
        title: Text('Al-Qur\'an',
            style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
      ),
      body: Builder(
        builder: (context) {
          if (quranProvider.isLoading) {
            return Center(child: CircularProgressIndicator(color: primaryAccent));
          }

          if (quranProvider.errorMessage != null) {
            return Center(child: Text('Gagal memuat data: ${quranProvider.errorMessage}'));
          }

          if (quranProvider.daftarSurah.isEmpty) {
            return Center(child: Text('Tidak ada data surah.'));
          }

          // Jika data ada
          return ListView.builder(
            itemCount: quranProvider.daftarSurah.length,
            itemBuilder: (context, index) {
              final surah = quranProvider.daftarSurah[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
                child: Card(
                  elevation: 0,
                  color: cardColor, // Pink Pucat
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    leading: CircleAvatar(
                      backgroundColor: primaryAccent.withOpacity(0.1),
                      child: Text(
                        surah.nomor.toString(),
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.bold,
                          color: primaryAccent,
                        ),
                      ),
                    ),
                    title: Text(
                      surah.namaLatin,
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.bold,
                        color: textColor,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Text(
                      '${surah.arti} • ${surah.jumlahAyat} Ayat',
                      style: GoogleFonts.inter(
                        color: textColor.withOpacity(0.7),
                        fontSize: 13,
                      ),
                    ),
                    trailing: Text(
                      surah.nama, // Teks Arab
                      
                      // --- FONT DIGANTI DI SINI ---
                      style: GoogleFonts.notoNaskhArabic( // Ganti dari Nastaliq ke Naskh
                        color: secondaryAccent, // Hijau Sedang
                        fontSize: 24, // Sedikit disesuaikan
                        fontWeight: FontWeight.w600, // Lebih tebal agar jelas
                      ),
                      // --- AKHIR PERUBAHAN ---

                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SurahDetailScreen(nomorSurah: surah.nomor),
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}