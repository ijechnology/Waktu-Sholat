import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';

class QiblaScreen extends StatefulWidget {
  const QiblaScreen({Key? key}) : super(key: key);

  @override
  State<QiblaScreen> createState() => _QiblaScreenState();
}

class _QiblaScreenState extends State<QiblaScreen> {
  double? heading; // arah utara (sensor)
  double qiblaDirection = 294.69; // arah kiblat dari API (contoh)

  @override
  void initState() {
    super.initState();
    FlutterCompass.events!.listen((event) {
      setState(() {
        heading = event.heading;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Arah Kiblat"),
      ),
      body: Center(
        child: heading == null
            ? const Text("Mengambil data kompas...")
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Putar perangkat hingga panah mengarah ke Kiblat",
                    style: TextStyle(fontSize: 18),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),

                  // ------------ ROTASI GAMBAR ------------
                  Transform.rotate(
                    angle: ((qiblaDirection - heading!) * (pi / 180)),
                    child: Image.asset(
                      "assets/images/compass.png",
                      width: 250,
                    ),
                  ),

                  const SizedBox(height: 20),

                  Text(
                    "Arah Kiblat: ${qiblaDirection.toStringAsFixed(2)}°",
                    style: const TextStyle(fontSize: 18),
                  ),
                ],
              ),
      ),
    );
  }
}
