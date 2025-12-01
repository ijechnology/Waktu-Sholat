import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class QiblaScreen extends StatefulWidget {
  const QiblaScreen({super.key});

  @override
  State<QiblaScreen> createState() => _QiblaScreenState();
}

class _QiblaScreenState extends State<QiblaScreen> {
  bool loading = true;
  String? compassUrl;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadQiblaCompass();
  }

  Future<void> _loadQiblaCompass() async {
    try {
      setState(() => loading = true);

      // MINTA IZIN LOKASI
      LocationPermission permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        setState(() {
          errorMessage = "Izin lokasi diperlukan untuk menentukan arah kiblat.";
          loading = false;
        });
        return;
      }

      // AMBIL LOKASI USER
      Position pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // API ALADHAN
      compassUrl =
          "https://api.aladhan.com/v1/qibla/${pos.latitude}/${pos.longitude}/compass";

      setState(() => loading = false);
    } catch (e) {
      setState(() {
        loading = false;
        errorMessage = "Gagal memuat kompas: $e";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Arah Kiblat"),
      ),
      body: Center(
        child: loading
            ? const CircularProgressIndicator()
            : errorMessage != null
                ? Text(
                    errorMessage!,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Mengambil kompas arah Ka'bah...",
                        style: TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 20),

                      // GAMBAR KOMPAS DARI API
                      Image.network(
                        compassUrl!,
                        width: 300,
                        height: 300,
                        fit: BoxFit.contain,
                      ),
                    ],
                  ),
      ),
    );
  }
}
