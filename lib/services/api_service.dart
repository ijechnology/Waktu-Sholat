import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../models/prayer_times_model.dart';
// --- 1. IMPORT MODEL QURAN BARU ---
import '../models/surah_model.dart';
import '../models/surah_detail_model.dart';

class ApiService {
  // --- (API Sholat dan Kurs tidak berubah) ---
  final String _apiPrayerBaseUrl =
      'https://api.aladhan.com/v1/timingsByCity';
  final String _apiPrayerByCoordsBaseUrl = 'https://api.aladhan.com/v1/timings';
  final String _apiExchangeKey = 'eea3a68781f1554c926bb5e3';
  late final String _apiExchangeBaseUrl;

  // --- 2. BASE URL API QURAN BARU ---
  final String _apiQuranBaseUrl = 'https://equran.id/api/v2';

  ApiService() {
    _apiExchangeBaseUrl =
        'https://v6.exchangerate-api.com/v6/$_apiExchangeKey/latest/IDR';
  }

  // --- (Fungsi Sholat tidak berubah) ---
  Future<PrayerTimes> fetchPrayerTimesByCity(String city) async {
    // ... (kode aman 'fromJson' sudah ada) ...
    final response = await http.get(Uri.parse('$_apiPrayerBaseUrl?city=$city&country=ID'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      try {
        if (data['data'] != null && data['data']['timings'] != null) {
          final timings = PrayerTimes.fromJson(data['data']['timings']);
          return timings;
        } else {
          throw Exception('Kota tidak ditemukan. Periksa kembali ejaan.');
        }
      } catch (e) {
        print('Error parsing fromJson (City): $e');
        throw Exception('Gagal mem-parsing data sholat. Coba lagi.');
      }
    } else {
      throw Exception('Gagal terhubung ke server waktu sholat');
    }
  }

  Future<Map<String, dynamic>> fetchPrayerTimesByCoordinates(
      double latitude, double longitude) async {
    // ... (kode LBS yang sudah diperbaiki ada di sini) ...
    final response = await http.get(Uri.parse('$_apiPrayerByCoordsBaseUrl?latitude=$latitude&longitude=$longitude'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      try {
        if (data['data'] != null && data['data']['timings'] != null) {
          final timings = PrayerTimes.fromJson(data['data']['timings']);
          String locationName;
          try {
            List<Placemark> placemarks = await placemarkFromCoordinates(latitude, longitude);
            locationName = placemarks.first.subAdministrativeArea ?? placemarks.first.administrativeArea ?? 'Lokasi Tidak Dikenal';
            locationName = locationName.replaceFirst('Kabupaten ', '');
          } catch (e) {
            try {
              String city = data['data']['meta']['timezone'];
              locationName = city.split('/').last.replaceAll('_', ' '); 
            } catch (e2) {
              locationName = "Lokasi Saat Ini";
            }
          }
          return {'timings': timings, 'location': locationName};
        } else {
          throw Exception('Gagal mendapatkan data sholat untuk lokasi ini.');
        }
      } catch (e) {
        print('Error parsing fromJson (Coords): $e');
        throw Exception('Gagal mem-parsing data sholat. Coba lagi.');
      }
    } else {
      throw Exception('Gagal memuat waktu sholat dari koordinat');
    }
  }

  // --- (Fungsi Kurs tidak berubah) ---
  Future<Map<String, double>> getExchangeRates() async {
    // ... (kode ini sudah benar) ...
    final response = await http.get(Uri.parse(_apiExchangeBaseUrl));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['result'] == 'success') {
        final rates = data['conversion_rates'] as Map<String, dynamic>;
        final Map<String, double> filteredRates = {};
        final List<String> wantedCurrencies = ['IDR', 'USD', 'MYR', 'KRW', 'JPY'];
        rates.forEach((key, value) {
          if (wantedCurrencies.contains(key)) {
            filteredRates[key] = value.toDouble();
          }
        });
        return filteredRates;
      } else {
        throw Exception('Gagal memuat data kurs: API error');
      }
    } else {
      throw Exception('Gagal terhubung ke server kurs');
    }
  }

  // --- 3. FUNGSI QURAN BARU ---
  
  // Mengambil daftar 114 Surah
  Future<List<Surah>> getDaftarSurah() async {
    final response = await http.get(Uri.parse('$_apiQuranBaseUrl/surat'));
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['data'] != null) {
        List<dynamic> listSurah = data['data'];
        return listSurah.map((json) => Surah.fromJson(json)).toList();
      } else {
        throw Exception('Gagal memuat daftar surah (format data salah)');
      }
    } else {
      throw Exception('Gagal terhubung ke server Al-Qur\'an');
    }
  }

  // Mengambil detail 1 Surah (lengkap dengan ayat & terjemahan)
  Future<SurahDetail> getDetailSurah(int nomor) async {
    final response = await http.get(Uri.parse('$_apiQuranBaseUrl/surat/$nomor'));
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['data'] != null) {
        return SurahDetail.fromJson(data['data']);
      } else {
        throw Exception('Gagal memuat detail surah (format data salah)');
      }
    } else {
      throw Exception('Gagal terhubung ke server Al-Qur\'an');
    }
  }
}