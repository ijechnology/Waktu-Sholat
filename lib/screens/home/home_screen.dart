import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import '../../providers/prayer_provider.dart';
import '../../models/prayer_times_model.dart';
import '../home/qibla_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final int _numPages = 6;
  final PageController _pageController = PageController(viewportFraction: 0.9);
  int _currentPage = 0;
  final TextEditingController _cityController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      setState(() {
        _currentPage = _pageController.page!.round();
      });
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  // --- (Fungsi _searchCity, _fetchByLocation, _findNextPrayer, _formatDuration tidak berubah) ---
  void _searchCity() {
    if (_cityController.text.isNotEmpty) {
      Provider.of<PrayerProvider>(context, listen: false)
          .fetchPrayerTimesByCity(_cityController.text);
      FocusScope.of(context).unfocus();
    }
  }

  void _fetchByLocation() {
    Provider.of<PrayerProvider>(context, listen: false)
        .fetchPrayerTimesByCurrentLocation();
    _cityController.clear();
    FocusScope.of(context).unfocus();
  }

  Map<String, dynamic> _findNextPrayer(PrayerTimes? prayerTimes, DateTime now) {
    if (prayerTimes == null) {
      return {'name': '...', 'time': '--:--', 'countdown': 'Memuat...'};
    }
    final formatter = DateFormat('HH:mm');
    final Map<String, DateTime> prayerDateTimes = {
      'Subuh': formatter.parse(prayerTimes.fajr),
      'Terbit': formatter.parse(prayerTimes.sunrise),
      'Dzuhur': formatter.parse(prayerTimes.dhuhr),
      'Ashar': formatter.parse(prayerTimes.asr),
      'Maghrib': formatter.parse(prayerTimes.maghrib),
      'Isya': formatter.parse(prayerTimes.isha),
    };
    String nextPrayerName = 'Subuh';
    DateTime nextPrayerTime = DateTime.now();
    bool foundNextPrayer = false;
    for (var entry in prayerDateTimes.entries) {
      final prayerTime = DateTime(
          now.year, now.month, now.day, entry.value.hour, entry.value.minute);
      if (prayerTime.isAfter(now)) {
        nextPrayerName = entry.key;
        nextPrayerTime = prayerTime;
        foundNextPrayer = true;
        break;
      }
    }
    if (!foundNextPrayer) {
      nextPrayerName = 'Subuh';
      final subuhTime = formatter.parse(prayerTimes.fajr);
      nextPrayerTime = DateTime(
          now.year, now.month, now.day + 1, subuhTime.hour, subuhTime.minute);
    }
    final Duration countdownDuration = nextPrayerTime.difference(now);
    return {
      'name': nextPrayerName,
      'time': DateFormat('HH:mm').format(nextPrayerTime),
      'countdown': _formatDuration(countdownDuration),
    };
  }

  String _formatDuration(Duration d) {
    final hours = d.inHours.toString().padLeft(2, '0');
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }
  // --- AKHIR FUNGSI LAMA ---

  @override
  Widget build(BuildContext context) {
    final prayerProvider = context.watch<PrayerProvider>();
    final prayerTimes = prayerProvider.prayerTimes;

    final nextPrayerInfo =
        _findNextPrayer(prayerTimes, prayerProvider.currentTime);
    final String nextPrayerName = nextPrayerInfo['name'];
    final String nextPrayerTime = nextPrayerInfo['time'];
    final String countdown = nextPrayerInfo['countdown'];

    final Color primaryAccent = Theme.of(context).primaryColor;
    final Color secondaryAccent = Theme.of(context).colorScheme.secondary;
    final Color textColor = Theme.of(context).colorScheme.onSurface;
    final Color secondaryTextColor = const Color(0xFF6B7280);
    final Color cardColor = Theme.of(context).colorScheme.surface;

    return Scaffold(
      appBar: AppBar(
        title: Text('Dasbor PrayTime',
            style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: Column(
          children: [
            // --- 1. KARTU GESER (PAGEVIEW) DIPERBARUI ---
            Container(
              height: 180,
              child: PageView(
                controller: _pageController,
                children: [
                  // Kartu 1: Hitungan Mundur (Tidak berubah)
                  _buildCountdownCard(
                      prayerProvider,
                      nextPrayerName,
                      nextPrayerTime,
                      countdown,
                      primaryAccent,
                      secondaryAccent),
                  // Kartu 2: Info Lokasi & Tanggal (Tidak berubah)
                  _buildLocationCard(
                      prayerProvider, textColor, secondaryTextColor, cardColor),

                  // --- KARTU-KARTU JAM DUNIA SEKARANG MENGGUNAKAN ASET LOKAL ---
                  // Kartu 3: Jam Jakarta (WIB)
                  _buildWorldClockCard('Jakarta (WIB)', prayerProvider.wibTime,
                      'assets/images/jakarta.jpg' // <-- GANTI DARI URL KE ASET
                      ),
                  // Kartu 4: Jam Makassar (WITA)
                  _buildWorldClockCard(
                      'Makassar (WITA)',
                      prayerProvider.witaTime,
                      'assets/images/makassar.jpg' // <-- GANTI DARI URL KE ASET
                      ),
                  // Kartu 5: Jam Jayapura (WIT)
                  _buildWorldClockCard('Jayapura (WIT)', prayerProvider.witTime,
                      'assets/images/jayapura.jpg' // <-- GANTI DARI URL KE ASET
                      ),
                  // Kartu 6: Jam London
                  _buildWorldClockCard('London', prayerProvider.londonTime,
                      'assets/images/london.jpg' // <-- GANTI DARI URL KE ASET
                      ),
                ],
              ),
            ),
            // Indikator Titik (Dots)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_numPages, (index) {
                return Container(
                  width: 8.0,
                  height: 8.0,
                  margin: const EdgeInsets.symmetric(
                      vertical: 10.0, horizontal: 2.0),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentPage == index
                        ? primaryAccent
                        : Colors.grey[300],
                  ),
                );
              }),
            ),
            // --- AKHIR PERUBAHAN ---

            // --- PENCARIAN KOTA & LBS ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _cityController,
                      style: GoogleFonts.inter(color: textColor),
                      decoration: InputDecoration(
                        hintText: 'Cari kota lain...',
                        prefixIcon: Icon(Icons.search, color: Colors.grey[500]),
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 14, horizontal: 16),
                      ),
                      onSubmitted: (value) => _searchCity(),
                    ),
                  ),
                  const SizedBox(width: 10),
                  IconButton(
                    icon: Icon(Icons.my_location, color: primaryAccent),
                    iconSize: 28,
                    onPressed: _fetchByLocation,
                    tooltip: 'Gunakan Lokasi Saat Ini',
                  ),
                  IconButton(
                    icon: Icon(Icons.arrow_forward_ios_rounded,
                        color: primaryAccent, size: 24),
                    onPressed: _searchCity,
                    tooltip: 'Cari',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

// --- TOMBOL KIBLAT ---
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => QiblaScreen()),
                );
              },
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 18, horizontal: 20),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: Offset(0, 3),
                    )
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor.withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child:
                          Icon(Icons.explore, color: primaryAccent, size: 28),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        "Arah Kiblat",
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: textColor,
                        ),
                      ),
                    ),
                    Icon(Icons.arrow_forward_ios_rounded, color: primaryAccent),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),

            // --- DAFTAR JADWAL HARI INI ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Builder(builder: (context) {
                if (prayerProvider.isLoading) {
                  return const Center(
                      child: Padding(
                    padding: EdgeInsets.all(20.0),
                    child: CircularProgressIndicator(),
                  ));
                }
                if (prayerProvider.errorMessage != null) {
                  return Container(
                    padding: const EdgeInsets.all(20.0),
                    decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .error
                            .withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: Theme.of(context).colorScheme.error)),
                    child: Text(
                      prayerProvider.errorMessage!,
                      style: GoogleFonts.inter(
                          color: Colors.red.shade900,
                          fontSize: 16,
                          fontWeight: FontWeight.w500),
                      textAlign: TextAlign.center,
                    ),
                  );
                }
                if (prayerTimes != null) {
                  return _buildTodayScheduleList(prayerTimes, cardColor,
                      textColor, secondaryTextColor, secondaryAccent);
                }
                return const Center(child: Text('Silakan cari kota Anda'));
              }),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // --- (Widget Kartu 1 & 2 tidak berubah) ---
  Widget _buildCountdownCard(
      PrayerProvider prayerProvider,
      String name,
      String time,
      String countdown,
      Color primaryAccent,
      Color secondaryAccent) {
    return Container(
      // ... (kode tidak berubah) ...
      margin: const EdgeInsets.symmetric(horizontal: 6.0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [primaryAccent, secondaryAccent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: primaryAccent.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Sholat Selanjutnya:',
              style: GoogleFonts.inter(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 16,
                  fontWeight: FontWeight.w500)),
          Text('$name ($time)',
              style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Text(countdown,
              style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 40,
                  fontWeight: FontWeight.w800,
                  fontFeatures: [const FontFeature.tabularFigures()])),
        ],
      ),
    );
  }

  Widget _buildLocationCard(PrayerProvider prayerProvider, Color textColor,
      Color secondaryTextColor, Color cardColor) {
    return Container(
      // ... (kode tidak berubah) ...
      margin: const EdgeInsets.symmetric(horizontal: 6.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Lokasi Anda Saat Ini:',
              style: GoogleFonts.inter(
                  color: secondaryTextColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w500)),
          const SizedBox(height: 4),
          Text(prayerProvider.currentCity,
              style: GoogleFonts.inter(
                  color: textColor, fontSize: 22, fontWeight: FontWeight.bold),
              overflow: TextOverflow.ellipsis),
          const SizedBox(height: 12),
          Text(prayerProvider.masehiDateString,
              style: GoogleFonts.inter(
                  color: secondaryTextColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w500)),
          Text(prayerProvider.hijriDateString,
              style: GoogleFonts.inter(
                  color: secondaryTextColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  // --- WIDGET JAM DUNIA DIPERBARUI ---
  // Parameter ketiga diubah dari 'imageUrl' menjadi 'assetPath'
  Widget _buildWorldClockCard(String title, String time, String assetPath) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 6.0),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.black, // Fallback jika path aset salah
        borderRadius: BorderRadius.circular(16),
        // --- 1. UBAH 'NetworkImage' MENJADI 'AssetImage' ---
        image: DecorationImage(
          image: AssetImage(assetPath), // <-- INI PERUBAHANNYA
          fit: BoxFit.cover,
        ),
      ),
      // --- 2. 'Scrim' dan Teks tetap sama ---
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.black.withOpacity(0.6),
              Colors.black.withOpacity(0.2)
            ],
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: GoogleFonts.inter(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                shadows: [
                  Shadow(blurRadius: 2, color: Colors.black.withOpacity(0.5))
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              time,
              style: GoogleFonts.inter(
                color: Colors.white,
                fontSize: 36,
                fontWeight: FontWeight.w600,
                fontFeatures: [const FontFeature.tabularFigures()],
                shadows: [
                  Shadow(blurRadius: 2, color: Colors.black.withOpacity(0.5))
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  // --- AKHIR PERUBAHAN ---

  // --- (Widget Daftar Sholat tidak berubah) ---
  Widget _buildTodayScheduleList(PrayerTimes prayerTimes, Color cardColor,
      Color textColor, Color secondaryTextColor, Color timeColor) {
    return Container(
      // ... (kode tidak berubah) ...
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          _buildPrayerTimeRow('Subuh', prayerTimes.fajr, true, textColor,
              timeColor, secondaryTextColor),
          _buildPrayerTimeRow('Terbit', prayerTimes.sunrise, false, textColor,
              timeColor, secondaryTextColor),
          _buildPrayerTimeRow('Dzuhur', prayerTimes.dhuhr, true, textColor,
              timeColor, secondaryTextColor),
          _buildPrayerTimeRow('Ashar', prayerTimes.asr, true, textColor,
              timeColor, secondaryTextColor),
          _buildPrayerTimeRow('Maghrib', prayerTimes.maghrib, true, textColor,
              timeColor, secondaryTextColor),
          _buildPrayerTimeRow('Isya', prayerTimes.isha, true, textColor,
              timeColor, secondaryTextColor,
              isLast: true),
        ],
      ),
    );
  }

  Widget _buildPrayerTimeRow(String name, String time, bool isSholat,
      Color textColor, Color timeColor, Color secondaryTextColor,
      {bool isLast = false}) {
    return Container(
      // ... (kode tidak berubah) ...
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : Border(
                bottom:
                    BorderSide(color: Colors.white.withOpacity(0.5), width: 1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(name,
              style: GoogleFonts.inter(
                  color: textColor, fontSize: 16, fontWeight: FontWeight.w600)),
          Row(
            children: [
              Text(time,
                  style: GoogleFonts.inter(
                      color: timeColor,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      fontFeatures: [const FontFeature.tabularFigures()])),
              if (isSholat) const SizedBox(width: 8),
              if (isSholat)
                Icon(Icons.notifications_active,
                    color: secondaryTextColor, size: 18),
            ],
          ),
        ],
      ),
    );
  }
}
