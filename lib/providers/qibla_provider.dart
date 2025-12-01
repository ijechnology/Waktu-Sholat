import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

class QiblaProvider extends ChangeNotifier {
  bool isLoading = false;
  String? errorMessage;

  double? qiblaDirection; // dari API qibla direction (derajat)
  String? compassImageUrl; // dari API compass image

  Future<void> fetchQiblaData() async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      // --- MINTA LOKASI
      LocationPermission perm = await Geolocator.requestPermission();
      if (perm == LocationPermission.denied ||
          perm == LocationPermission.deniedForever) {
        errorMessage = "Izin lokasi diperlukan.";
        isLoading = false;
        notifyListeners();
        return;
      }

      Position pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final lat = pos.latitude;
      final lon = pos.longitude;

      // --- API 1: QIBLA DIRECTION (DERAJAT)
      final dirResponse = await http.get(
        Uri.parse("https://api.aladhan.com/v1/qibla/$lat/$lon"),
      );

      if (dirResponse.statusCode == 200) {
        final data = jsonDecode(dirResponse.body);
        qiblaDirection = data["data"]["direction"] * 1.0;
      }

      // --- API 2: QIBLA COMPASS IMAGE
      compassImageUrl = "https://api.aladhan.com/v1/qibla/$lat/$lon/compass";

      isLoading = false;
      notifyListeners();
    } catch (e) {
      errorMessage = "Gagal memuat qibla: $e";
      isLoading = false;
      notifyListeners();
    }
  }
}
