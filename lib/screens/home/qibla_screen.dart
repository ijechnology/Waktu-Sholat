import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:math';

class QiblaScreen extends StatefulWidget {
  const QiblaScreen({super.key});

  @override
  State<QiblaScreen> createState() => _QiblaScreenState();
}

class _QiblaScreenState extends State<QiblaScreen>
    with SingleTickerProviderStateMixin {
  String? compassImageUrl;
  double? qiblaAngle;
  bool isLoading = true;
  String? errorMessage;

  String? cityName; // ⬅️ TEMPAT SIMPAN NAMA KOTA

  late AnimationController _controller;
  late Animation<double> _animation;
  double lastRotation = 0.0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    loadData();
  }

  Future<void> loadData() async {
    try {
      // 1. Lokasi
      Position pos = await _getLocation();

      // 2. Ambil nama kota
      await _getCityName(pos.latitude, pos.longitude);

      // 3. Arah kiblat
      await fetchQiblaDirection(pos.latitude, pos.longitude);

      // 4. Kompas image
      await fetchCompassImage(pos.latitude, pos.longitude);

      setState(() => isLoading = false);
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  Future<Position> _getLocation() async {
    LocationPermission perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) {
      perm = await Geolocator.requestPermission();
    }
    if (perm == LocationPermission.deniedForever ||
        perm == LocationPermission.denied) {
      throw Exception("Izin lokasi ditolak.");
    }

    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  /// Ambil nama kota dari latitude & longitude
  Future<void> _getCityName(double lat, double lon) async {
    List<Placemark> pm = await placemarkFromCoordinates(lat, lon);

    if (pm.isNotEmpty) {
      Placemark place = pm.first;
      cityName = place.locality ??
          place.subAdministrativeArea ??
          place.administrativeArea ??
          "Lokasi tidak diketahui";
    }
  }

  Future<void> fetchQiblaDirection(double lat, double lon) async {
    final url = "https://api.aladhan.com/v1/qibla/$lat/$lon";
    final response = await http.get(Uri.parse(url));
    final data = jsonDecode(response.body);

    qiblaAngle = data["data"]["direction"]?.toDouble();
  }

  Future<void> fetchCompassImage(double lat, double lon) async {
    try {
      final url = "https://api.aladhan.com/v1/qibla/$lat/$lon/compass";

      final response = await http.get(Uri.parse(url));

      final data = jsonDecode(response.body);
      compassImageUrl = data["data"];
    } catch (e) {
      debugPrint("Error loading compass image: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (errorMessage != null) {
      return Scaffold(
        body: Center(
          child: Text(
            errorMessage!,
            style: const TextStyle(color: Colors.red),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Arah Kiblat"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => _buildRefreshDialog(),
              );
            },
          ),
        ],
      ),
      body: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Color(0xFFE9F5F0)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            const SizedBox(height: 45),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              /// ⬅️ TAMPILKAN NAMA KOTA
              Icon(Icons.location_on, color: Colors.red, size: 20),
              Text(
                cityName ?? "Mengambil lokasi...",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ]),
            const SizedBox(height: 30),
            const Text(
              "Putar perangkat hingga panah mengarah ke Kiblat",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.black54,
                fontSize: 15,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 50),
            StreamBuilder<CompassEvent>(
              stream: FlutterCompass.events,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Text("Mengkalibrasi kompas...");
                }

                double? direction = snapshot.data!.heading;
                if (direction == null) {
                  return const Text("Sensor tidak tersedia");
                }

                double rotation = -(direction * pi / 180);

                _animation = Tween(begin: lastRotation, end: rotation)
                    .animate(CurvedAnimation(
                  parent: _controller,
                  curve: Curves.easeOut,
                ));

                _controller.forward(from: 0);
                lastRotation = rotation;

                return AnimatedBuilder(
                  animation: _animation,
                  builder: (context, child) {
                    return Transform.rotate(
                      angle: _animation.value,
                      child: child,
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 14,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: compassImageUrl == null
                        ? Image.asset(
                            "assets/images/compass.png",
                            width: 280,
                            height: 280,
                          )
                        : Image.network(
                            compassImageUrl!,
                            width: 280,
                            height: 280,
                            errorBuilder: (context, error, stack) {
                              return Image.asset(
                                "assets/images/compass.png",
                                width: 280,
                                height: 280,
                              );
                            },
                          ),
                  ),
                );
              },
            ),
            const SizedBox(height: 50),
            const Text(
              "Arah Kiblat:",
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 4),
            Text(
              "${qiblaAngle?.toStringAsFixed(2) ?? '-'}°",
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Color(0xFF195A49),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRefreshDialog() {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        padding: const EdgeInsets.all(22),
        width: 320,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.my_location, size: 40, color: Color(0xFF195A49)),
            const SizedBox(height: 15),
            const Text(
              "Perbarui Lokasi",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              "Aplikasi akan mengambil ulang lokasi Anda untuk memperbarui arah Kiblat.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.black54),
            ),
            const SizedBox(height: 25),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  child: const Text(
                    "Batal",
                    style: TextStyle(color: Colors.grey),
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF195A49),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text("Perbarui"),
                  onPressed: () async {
                    Navigator.pop(context);
                    setState(() => isLoading = true);
                    await loadData();
                  },
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
