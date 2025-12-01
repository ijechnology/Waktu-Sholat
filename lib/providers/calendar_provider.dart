import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:intl/intl.dart'; 
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class CalendarProvider with ChangeNotifier {
  
  late Timer _timer;
  final DateFormat _timeFormatter = DateFormat('HH:mm:ss');
  
  // Data Jam Dunia (tetap ada)
  String wibTime = '...';
  String witaTime = '...';
  String witTime = '...';
  String londonTime = '...';

  CalendarProvider() {
    tz.initializeTimeZones();
    _updateTimes(); // Panggil sekali saat start
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _updateTimes(); // Panggil setiap detik
    });
  }

  // Fungsi untuk update jam dunia (tidak berubah)
  void _updateTimes() {
    try {
      final wibLocation = tz.getLocation('Asia/Jakarta');
      final wibNow = tz.TZDateTime.now(wibLocation);
      wibTime = _timeFormatter.format(wibNow);

      final witaLocation = tz.getLocation('Asia/Makassar');
      final witaNow = tz.TZDateTime.now(witaLocation);
      witaTime = _timeFormatter.format(witaNow);

      final witLocation = tz.getLocation('Asia/Jayapura');
      final witNow = tz.TZDateTime.now(witLocation);
      witTime = _timeFormatter.format(witNow);

      final londonLocation = tz.getLocation('Europe/London');
      final londonNow = tz.TZDateTime.now(londonLocation);
      londonTime = _timeFormatter.format(londonNow);

      notifyListeners();

    } catch (e) {
      print("Error loading timezones: $e");
      _timer.cancel();
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }


  // --- FUNGSI LOGIKA KALENDER UTAMA (DI-UPGRADE TOTAL) ---
  List<String> getEventsForDay(DateTime day) {
    List<String> events = [];
    var hDay = HijriCalendar.fromDate(day);
    int mDay = day.weekday;
    int hMonth = hDay.hMonth;
    int hDayNum = hDay.hDay;

    // --- 1. HARI BESAR & HARI RAYA (Prioritas) ---
    // (Bulan 1) Muharram
    if (hMonth == 1 && hDayNum == 1) events.add('Tahun Baru Hijriah');
    if (hMonth == 1 && hDayNum == 10) events.add('Hari Asyura');
    // (Bulan 3) Rabi'ul Awwal
    if (hMonth == 3 && hDayNum == 12) events.add('Maulid Nabi SAW');
    // (Bulan 7) Rajab
    if (hMonth == 7 && hDayNum == 27) events.add('Isra\' Mi\'raj');
    // (Bulan 8) Sya'ban
    if (hMonth == 8 && hDayNum == 15) events.add('Nisfu Sya\'ban');
    // (Bulan 9) Ramadhan
    if (hMonth == 9 && hDayNum == 1) events.add('1 Ramadhan (Mulai Puasa)');
    if (hMonth == 9 && hDayNum == 17) events.add('Nuzulul Qur\'an');
    // (Bulan 10) Syawal
    if (hMonth == 10 && hDayNum == 1) events.add('Hari Raya Idul Fitri');
    // (Bulan 12) Dzulhijjah
    if (hMonth == 12 && hDayNum == 9) events.add('Wukuf di Arafah');
    if (hMonth == 12 && hDayNum == 10) events.add('Hari Raya Idul Adha');

    
    // --- 2. HARI HARAM PUASA (Paling Penting) ---
    bool isHaramFasting = false;
    // Idul Fitri
    if (hMonth == 10 && hDayNum == 1) {
      events.add('Haram Puasa (Idul Fitri)');
      isHaramFasting = true;
    }
    // Idul Adha
    if (hMonth == 12 && hDayNum == 10) {
      events.add('Haram Puasa (Idul Adha)');
      isHaramFasting = true;
    }
    // Hari Tasyrik
    if (hMonth == 12 && (hDayNum == 11 || hDayNum == 12 || hDayNum == 13)) {
      events.add('Haram Puasa (Hari Tasyrik)');
      isHaramFasting = true;
    }

    
    // --- 3. PUASA WAJIB ---
    // (Puasa Ramadhan)
    if (hMonth == 9 && !isHaramFasting) { 
      events.add('Puasa Ramadhan');
    }

    
    // --- 4. PUASA SUNNAH (Hanya jika tidak Wajib & tidak Haram) ---
    if (hMonth != 9 && !isHaramFasting) { 
      // Puasa Mingguan
      if (mDay == DateTime.monday) events.add('Puasa Senin');
      if (mDay == DateTime.thursday) events.add('Puasa Kamis');

      // Puasa Bulanan
      if (hDayNum == 13 || hDayNum == 14 || hDayNum == 15) {
        events.add('Puasa Ayyamul Bidh');
      }

      // Puasa Tahunan (di luar Ramadhan)
      if (hMonth == 1 && hDayNum == 9) events.add('Puasa Tasu\'a');
      if (hMonth == 1 && hDayNum == 10) events.add('Puasa Asyura');
      if (hMonth == 12 && hDayNum == 9) events.add('Puasa Arafah');
      
      // Puasa Syawal (bulan 10)
      if (hMonth == 10) {
        events.add('Puasa Syawal (Sunnah)');
        // (Kita tandai seluruh bulan, pengguna bisa memilih 6 hari)
      }
    }

    return events;
  }
}