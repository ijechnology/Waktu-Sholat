import 'package:flutter/foundation.dart';
import '../services/api_service.dart';
import '../models/surah_model.dart';

class QuranProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<Surah> _daftarSurah = [];
  List<Surah> get daftarSurah => _daftarSurah;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // Constructor
  QuranProvider() {
    // Saat provider dibuat, langsung panggil daftar surah
    fetchDaftarSurah();
  }

  Future<void> fetchDaftarSurah() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _daftarSurah = await _apiService.getDaftarSurah();
    } catch (e) {
      _errorMessage = e.toString().replaceFirst("Exception: ", "");
    }

    _isLoading = false;
    notifyListeners();
  }
}