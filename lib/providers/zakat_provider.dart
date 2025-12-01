import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'package:intl/intl.dart';
// --- 1. HAPUS IMPORT NOTIFIKASI DARI SINI ---
// import '../services/notification_service.dart';

class ZakatProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  // --- 2. HAPUS INSTANCE NOTIFIKASI DARI SINI ---
  // final NotificationService _notificationService = NotificationService();

  // --- (Data, Getters, Constructor, _fetchRates tidak berubah) ---
  double _totalHarta = 0;
  bool _wajibZakat = false;
  double _zakatAmount = 0;
  final double nishab = 85000000;
  String _selectedCurrency = 'IDR';
  Map<String, double> _rates = {};
  bool _isLoading = false;
  double get totalHarta => _totalHarta;
  bool get wajibZakat => _wajibZakat;
  double get zakatAmount => _zakatAmount;
  String get selectedCurrency => _selectedCurrency;
  bool get isLoading => _isLoading;
  Map<String, double> get rates => _rates;
  final NumberFormat _formatter =
      NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
  ZakatProvider() {
    _fetchRates();
  }
  Future<void> _fetchRates() async {
    _isLoading = true;
    notifyListeners();
    try {
      _rates = await _apiService.getExchangeRates();
    } catch (e) {
      print("Error fetching rates: $e");
      _rates = {};
    }
    _isLoading = false;
    notifyListeners();
  }
  // --- AKHIR KODE LAMA ---

  // Dipanggil di Langkah 1
  void setHartaAndCalculate(String hartaValue) {
    _totalHarta = double.tryParse(hartaValue.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;

    if (_totalHarta >= nishab) {
      _wajibZakat = true;
      _zakatAmount = _totalHarta * 0.025;
    } else {
      _wajibZakat = false;
      _zakatAmount = 0;
    }

    // --- 3. HAPUS PANGGILAN NOTIFIKASI DARI SINI ---
    
    notifyListeners();
  }
  
  // (Fungsi lainnya tidak berubah)
  void setCurrency(String currency) {
    _selectedCurrency = currency;
    notifyListeners();
  }
  String formatRupiah(double value) {
    return _formatter.format(value);
  }
  String getFormattedZakatInCurrency() {
    if (_zakatAmount == 0) return "Belum mencapai nishab";
    if (_rates.isEmpty && _isLoading) return "Loading rates...";
    if (_rates.isEmpty && !_isLoading) return "Gagal memuat kurs";

    double rate = _rates[_selectedCurrency] ?? 1.0;
    double convertedAmount = _zakatAmount * rate;

    switch (_selectedCurrency) {
      case 'IDR':
        return _formatter.format(_zakatAmount);
      case 'USD':
        return NumberFormat.currency(locale: 'en_US', symbol: '\$ ', decimalDigits: 2)
            .format(convertedAmount);
      case 'KRW':
        return NumberFormat.currency(locale: 'ko_KR', symbol: '₩ ', decimalDigits: 0)
            .format(convertedAmount);
      case 'MYR':
        return NumberFormat.currency(locale: 'ms_MY', symbol: 'RM ', decimalDigits: 2)
            .format(convertedAmount);
      case 'JPY':
        return NumberFormat.currency(locale: 'ja_JP', symbol: '¥ ', decimalDigits: 0)
            .format(convertedAmount);
      default:
        return _formatter.format(_zakatAmount);
    }
  }
  void resetWizard() {
    _totalHarta = 0;
    _wajibZakat = false;
    _zakatAmount = 0;
    _selectedCurrency = 'IDR';
  }
}