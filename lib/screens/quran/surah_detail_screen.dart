import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart'; // Untuk HapticFeedback
import '../../services/api_service.dart';
import '../../models/surah_detail_model.dart';

class SurahDetailScreen extends StatefulWidget {
  final int nomorSurah;
  
  const SurahDetailScreen({Key? key, required this.nomorSurah}) : super(key: key);

  @override
  _SurahDetailScreenState createState() => _SurahDetailScreenState();
}

class _SurahDetailScreenState extends State<SurahDetailScreen> {
  late Future<SurahDetail> _futureSurahDetail;
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _futureSurahDetail = _apiService.getDetailSurah(widget.nomorSurah);
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryAccent = Theme.of(context).primaryColor;
    final Color secondaryAccent = Theme.of(context).colorScheme.secondary;
    final Color cardColor = Theme.of(context).colorScheme.surface;
    final Color textColor = Theme.of(context).colorScheme.onSurface;

    return Scaffold(
      body: FutureBuilder<SurahDetail>(
        future: _futureSurahDetail,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: primaryAccent));
          }
          if (snapshot.hasError) {
            return Center(child: Text('Gagal memuat data: ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return Center(child: Text('Tidak ada data detail surah.'));
          }

          final surah = snapshot.data!;

          return CustomScrollView(
            slivers: [
              // --- 1. SLIVER APP BAR (HEADER IMMERSIVE) ---
              SliverAppBar(
                expandedHeight: 250.0, 
                pinned: true, 
                floating: false,
                backgroundColor: Colors.white,
                iconTheme: IconThemeData(color: primaryAccent),
                titleTextStyle: GoogleFonts.inter(
                  color: textColor,
                  fontWeight: FontWeight.w700,
                  fontSize: 20,
                ),
                
                flexibleSpace: FlexibleSpaceBar(
                  centerTitle: true,
                  title: Text(
                    surah.namaLatin,
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w700,
                      color: textColor,
                    ),
                  ),
                  background: Container(
                    decoration: BoxDecoration(
                      color: cardColor, // Pink Pucat
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 50.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            surah.namaLatin,
                            style: GoogleFonts.inter(
                              color: textColor,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '(${surah.arti})',
                            style: GoogleFonts.inter(
                              color: textColor.withOpacity(0.7),
                              fontSize: 16,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            '${surah.tempatTurun.toUpperCase()} • ${surah.jumlahAyat} AYAT',
                            style: GoogleFonts.inter(
                              color: textColor.withOpacity(0.7),
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 20),
                          
                          // Tampilkan Bismillah HANYA JIKA BUKAN Al-Fatihah (1) atau At-Taubah (9)
                          if (surah.nomor != 1 && surah.nomor != 9)
                            Text(
                              'بِسْمِ اللهِ الرَّحْمٰنِ الرَّحِيْمِ',
                              // --- FONT DIGANTI DI SINI ---
                              style: GoogleFonts.notoNaskhArabic( // Ganti ke Naskh
                                color: secondaryAccent, // Hijau Sedang
                                fontSize: 30, // Sesuaikan ukuran
                                fontWeight: FontWeight.w600,
                              ),
                              // --- AKHIR PERUBAHAN ---
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // --- 2. SLIVER LIST (DAFTAR AYAT) ---
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final ayat = surah.ayat[index];
                    return _buildAyatTile(ayat, cardColor, textColor, secondaryAccent, primaryAccent);
                  },
                  childCount: surah.ayat.length,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // Widget untuk 1 Ayat
  Widget _buildAyatTile(Ayat ayat, Color cardColor, Color textColor, Color secondaryAccent, Color primaryAccent) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: Card(
        elevation: 0,
        color: cardColor.withOpacity(0.6),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CircleAvatar(
                      radius: 14,
                      backgroundColor: primaryAccent,
                      child: Text(
                        ayat.nomorAyat.toString(),
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.copy_all_outlined, color: secondaryAccent, size: 20),
                      onPressed: () {
                        final textToCopy = '${ayat.teksIndonesia} (Q.S ${widget.nomorSurah}:${ayat.nomorAyat})';
                        Clipboard.setData(ClipboardData(text: textToCopy)).then((_) {
                          HapticFeedback.lightImpact();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Terjemahan ayat disalin!'),
                              backgroundColor: secondaryAccent,
                            )
                          );
                        });
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Teks Arab
              Text(
                ayat.teksArab,
                textAlign: TextAlign.right,
                // --- FONT DIGANTI DI SINI ---
                style: GoogleFonts.notoNaskhArabic( // Ganti ke Naskh
                  color: textColor,
                  fontSize: 26, // Ukuran font yang pas untuk dibaca
                  fontWeight: FontWeight.normal, // Normal weight lebih mudah dibaca
                  height: 2.2, // Jarak antar baris (penting!)
                ),
                // --- AKHIR PERUBAHAN ---
              ),
              const SizedBox(height: 16),

              // Teks Latin (Transliterasi)
              Text(
                ayat.teksLatin,
                textAlign: TextAlign.left,
                style: GoogleFonts.inter(
                  color: textColor.withOpacity(0.7),
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 12),

              // Teks Indonesia (Terjemahan)
              Text(
                ayat.teksIndonesia,
                textAlign: TextAlign.left,
                style: GoogleFonts.inter(
                  color: textColor,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}