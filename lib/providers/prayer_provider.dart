import 'dart:async'; // <-- 1. Import Timer
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart'; // <-- 2. Import Intl
import 'package:timezone/timezone.dart' as tz; // <-- 3. Import Timezone
import 'package:timezone/data/latest.dart' as tz;
import 'package:hijri/hijri_calendar.dart'; // <-- 4. Import Hijri

import '../models/prayer_times_model.dart';
import '../services/api_service.dart';
import '../services/notification_service.dart';
import 'package:geolocator/geolocator.dart';

class PrayerProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  final NotificationService _notificationService = NotificationService();

  // --- Data Sholat ---
  PrayerTimes? _prayerTimes;
  PrayerTimes? get prayerTimes => _prayerTimes;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  String _currentCity = "Jakarta";
  String get currentCity => _currentCity;

  // --- 5. DATA WAKTU BARU (Dipindah ke sini) ---
  late Timer _timer;
  final DateFormat _timeFormatter = DateFormat('HH:mm:ss');
  final DateFormat _dateFormatter = DateFormat('EEE, dd MMM', 'id_ID');

  DateTime _currentTime = DateTime.now();
  DateTime get currentTime => _currentTime;

  String _hijriDateString = '...';
  String get hijriDateString => _hijriDateString;
  String _masehiDateString = '...';
  String get masehiDateString => _masehiDateString;

  String wibTime = '...';
  String witaTime = '...';
  String witTime = '...';
  String londonTime = '...';
  // --- AKHIR DATA BARU ---

  // Constructor
  PrayerProvider() {
    // Inisialisasi Timezone
    tz.initializeTimeZones();
    
    // Panggil fungsi sholat (default)
    fetchPrayerTimesByCity(_currentCity);

    // --- 6. JALANKAN TIMER ---
    _updateTime(); // Panggil sekali saat start
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _updateTime(); // Panggil setiap detik
    });
    // --- AKHIR TIMER ---
  }

  // --- 7. FUNGSI UPDATE WAKTU (BARU) ---
  void _updateTime() {
    try {
      final wibLocation = tz.getLocation('Asia/Jakarta');
      final wibNow = tz.TZDateTime.now(wibLocation);
      _currentTime = wibNow; // Simpan waktu saat ini
      
      // Update data tanggal
      _masehiDateString = DateFormat('EEEE, dd MMMM yyyy', 'id_ID').format(wibNow);
      _hijriDateString = HijriCalendar.fromDate(wibNow).toFormat("dd MMMM yyyy H");
      
      // Update 4 Jam Dunia
      wibTime = _timeFormatter.format(wibNow);

      final witaLocation = tz.getLocation('Asia/Makassar');
      witaTime = _timeFormatter.format(tz.TZDateTime.now(witaLocation));

      final witLocation = tz.getLocation('Asia/Jayapura');
      witTime = _timeFormatter.format(tz.TZDateTime.now(witLocation));

      final londonLocation = tz.getLocation('Europe/London');
      londonTime = _timeFormatter.format(tz.TZDateTime.now(londonLocation));

      notifyListeners(); // Beritahu UI (terutama countdown)
    
    } catch (e) {
      print("Error updating time: $e");
    }
  }
  // --- AKHIR FUNGSI BARU ---
  
  // --- (Fungsi fetchPrayerTimes & LBS tidak berubah) ---
  Future<void> fetchPrayerTimesByCity(String city) async {
    _isLoading = true;
    _errorMessage = null;
    _currentCity = city; 
    notifyListeners();
    try {
      final data = await _apiService.fetchPrayerTimesByCity(city);
      _prayerTimes = data;
      await _notificationService.schedulePrayerNotifications(data);
    } catch (e) {
      _errorMessage = e.toString().replaceFirst("Exception: ", "");
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchPrayerTimesByCurrentLocation() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Izin lokasi ditolak');
        }
      }
      if (permission == LocationPermission.deniedForever) {
        throw Exception('Izin lokasi ditolak permanen. Buka pengaturan aplikasi.');
      }
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      final result = await _apiService.fetchPrayerTimesByCoordinates(
          position.latitude, position.longitude);
      _prayerTimes = result['timings'] as PrayerTimes;
      _currentCity = result['location'] as String;
      if (_prayerTimes != null) {
        await _notificationService.schedulePrayerNotifications(_prayerTimes!);
      }
    } catch (e) {
      _errorMessage = e.toString().replaceFirst("Exception: ", "");
    }
    _isLoading = false;
    notifyListeners();
  }

  // --- 8. HENTIKAN TIMER ---
  @override
  void dispose() {
    _timer.cancel(); // Wajib
    super.dispose();
  }
}