// lib/views/home/home_screen.dart
import 'dart:async';
import 'dart:ui'; // for FontFeature
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/prayer_provider.dart';
import '../../models/prayer_times_model.dart';
import '../home/qibla_screen.dart';
import 'nearest_mosque_page.dart';

class TopToast extends StatefulWidget {
  final String message;
  final VoidCallback onDismiss;

  const TopToast({
    Key? key,
    required this.message,
    required this.onDismiss,
  }) : super(key: key);

  @override
  State<TopToast> createState() => _TopToastState();
}

class _TopToastState extends State<TopToast>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slide;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );

    _slide = Tween(begin: const Offset(0, -1), end: Offset.zero)
        .animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    _fade = Tween(begin: 0.0, end: 1.0).animate(_controller);

    _controller.forward();

    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        _controller.reverse().then((_) => widget.onDismiss());
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SlideTransition(
        position: _slide,
        child: FadeTransition(
          opacity: _fade,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 25),
            decoration: BoxDecoration(
              color: const Color(0xFF3A6F43),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.18),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            child: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white, size: 20),
                const SizedBox(width: 20),
                Expanded(
                  child: Text(
                    widget.message,
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final int _numPages = 2;
  final PageController _pageController = PageController(viewportFraction: 0.9);
  int _currentPage = 0;
  final TextEditingController _cityController = TextEditingController();

  // state to trigger visual feedback when location updated
  bool _locationUpdated = false;
  Timer? _locationHighlightTimer;

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
    _locationHighlightTimer?.cancel();
    super.dispose();
  }

  void _showSnackBar(String message) {
    final overlay = Overlay.of(context);
    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (context) => Positioned(
        top: 0,
        left: 0,
        right: 0,
        child: TopToast(
          message: message,
          onDismiss: () => entry.remove(),
        ),
      ),
    );

    overlay.insert(entry);
  }

  void _triggerLocationHighlight() {
    // set highlight true for a short time so card shows a distinct background
    setState(() {
      _locationUpdated = true;
    });
    _locationHighlightTimer?.cancel();
    _locationHighlightTimer = Timer(const Duration(milliseconds: 800), () {
      if (mounted) {
        setState(() {
          _locationUpdated = false;
        });
      }
    });
  }

  void _searchCity() async {
    final query = _cityController.text.trim();
    if (query.isNotEmpty) {
      try {
        await Provider.of<PrayerProvider>(context, listen: false)
            .fetchPrayerTimesByCity(query);
        _cityController.clear();
        FocusScope.of(context).unfocus();
        _triggerLocationHighlight();
        _showSnackBar('Lokasi diperbarui: $query');
      } catch (e) {
        _showSnackBar('Gagal mencari lokasi: $query');
      }
    } else {
      _showSnackBar('Masukkan nama kota untuk mencari');
    }
  }

  void _fetchByLocation() async {
    try {
      await Provider.of<PrayerProvider>(context, listen: false)
          .fetchPrayerTimesByCurrentLocation();
      _cityController.clear();
      FocusScope.of(context).unfocus();
      _triggerLocationHighlight();
      final currentCity =
          Provider.of<PrayerProvider>(context, listen: false).currentCity;
      _showSnackBar('Lokasi diperbarui: $currentCity');
    } catch (e) {
      _showSnackBar('Gagal mengambil lokasi saat ini');
    }
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
            SizedBox(
              height: 180,
              child: PageView(
                controller: _pageController,
                children: [
                  // Kartu 1: Hitungan Mundur
                  _buildCountdownCard(
                      prayerProvider,
                      nextPrayerName,
                      nextPrayerTime,
                      countdown,
                      primaryAccent,
                      secondaryAccent),
                  // Kartu 2: Info Lokasi & Tanggal (animated on location change)
                  _buildLocationCard(
                      prayerProvider, textColor, secondaryTextColor, cardColor),
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
                      vertical: 10.0, horizontal: 6.0),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentPage == index
                        ? primaryAccent
                        : Colors.grey[300],
                  ),
                );
              }),
            ),

            const SizedBox(height: 8),

            // --- 2. PENCARIAN KOTA (BARIS SENDIRI) ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: TextField(
                controller: _cityController,
                style: GoogleFonts.inter(color: textColor),
                decoration: InputDecoration(
                  hintText: 'Cari kota lain...',
                  prefixIcon: Icon(Icons.search, color: Colors.grey[500]),
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.background,
                ),
                onSubmitted: (value) => _searchCity(),
              ),
            ),

            const SizedBox(height: 10), // Jarak antara Search Bar dan Menu

            // --- 3. MENU CEPAT (LOKASI, KIBLAT, MASJID) ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceEvenly, // Agar jarak antar ikon rapi
                children: [
                  // Menu 1: Lokasi
                  _buildIconWithLabel(
                    icon: Icons.my_location,
                    label: 'Lokasi Saya',
                    onTap: _fetchByLocation,
                    tooltip: 'Gunakan Lokasi Saat Ini',
                    semanticLabel: 'Perbarui lokasi saat ini',
                    color: primaryAccent,
                  ),

                  // Menu 2: Kiblat
                  _buildIconWithLabel(
                    icon: Icons.explore,
                    label: 'Kiblat',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => QiblaScreen()),
                      );
                    },
                    tooltip: 'Arah Kiblat',
                    semanticLabel: 'Buka arah kiblat',
                    color: primaryAccent,
                  ),

                  // Menu 3: Masjid (FITUR BARU)
                  _buildIconWithLabel(
                    icon: Icons.mosque, // Icon Masjid
                    label: 'Masjid Terdekat',
                    onTap: () {
                      // Pastikan kamu sudah membuat class NearestMosquePage dr jawaban sebelumnya
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => NearestMosquePage()),
                      );
                    },
                    tooltip: 'Masjid Terdekat',
                    semanticLabel: 'Cari masjid terdekat',
                    color: primaryAccent,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

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

  Widget _buildIconWithLabel({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required String tooltip,
    required String semanticLabel,
    required Color color,
  }) {
    // compact icon with vertical label
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Semantics(
              label: semanticLabel,
              button: true,
              child: Tooltip(
                message: tooltip,
                child: Container(
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.08),
                    shape: BoxShape.circle,
                  ),
                  padding: const EdgeInsets.all(8),
                  child: Icon(icon, color: color, size: 22),
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(label,
                style: GoogleFonts.inter(
                    fontSize: 11, fontWeight: FontWeight.w600, color: color)),
          ],
        ),
      ),
    );
  }

  Widget _buildCountdownCard(
      PrayerProvider prayerProvider,
      String name,
      String time,
      String countdown,
      Color primaryAccent,
      Color secondaryAccent) {
    return Container(
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
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 14,
                  fontWeight: FontWeight.w500)),
          const SizedBox(height: 6),
          Text('$name ($time)',
              style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(countdown,
              style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 36,
                  fontWeight: FontWeight.w800,
                  fontFeatures: [const FontFeature.tabularFigures()])),
        ],
      ),
    );
  }

  Widget _buildLocationCard(PrayerProvider prayerProvider, Color textColor,
      Color secondaryTextColor, Color cardColor) {
    final title = 'Lokasi Anda Saat Ini:';
    final city = prayerProvider.currentCity;
    final masehi = prayerProvider.masehiDateString;
    final hijri = prayerProvider.hijriDateString;

    // Animated visual feedback when location is updated
    return AnimatedContainer(
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeOut,
      margin: const EdgeInsets.symmetric(horizontal: 6.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: _locationUpdated
            ? cardColor.withOpacity(0.95)
            : cardColor, // slightly brighter when updated
        borderRadius: BorderRadius.circular(16),
        boxShadow: _locationUpdated
            ? [
                BoxShadow(
                    color: Theme.of(context).primaryColor.withOpacity(0.15),
                    blurRadius: 12,
                    offset: const Offset(0, 6))
              ]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(title,
              style: GoogleFonts.inter(
                  color: secondaryTextColor,
                  fontSize: 13,
                  fontWeight: FontWeight.w500)),
          const SizedBox(height: 6),
          // animated city transition so user feels the change
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            transitionBuilder: (child, animation) {
              final offsetAnimation =
                  Tween<Offset>(begin: const Offset(0, 0.12), end: Offset.zero)
                      .animate(animation);
              return SlideTransition(position: offsetAnimation, child: child);
            },
            child: Text(
              city,
              key: ValueKey<String>(city),
              style: GoogleFonts.inter(
                  color: textColor, fontSize: 20, fontWeight: FontWeight.bold),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 12),
          Text(masehi,
              style: GoogleFonts.inter(
                  color: secondaryTextColor,
                  fontSize: 13,
                  fontWeight: FontWeight.w500)),
          Text(hijri,
              style: GoogleFonts.inter(
                  color: secondaryTextColor,
                  fontSize: 13,
                  fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildTodayScheduleList(PrayerTimes prayerTimes, Color cardColor,
      Color textColor, Color secondaryTextColor, Color timeColor) {
    return Container(
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
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 18.0),
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
