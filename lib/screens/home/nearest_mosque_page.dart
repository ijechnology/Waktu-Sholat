import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

class NearestMosquePage extends StatefulWidget {
  @override
  _NearestMosquePageState createState() => _NearestMosquePageState();
}

class _NearestMosquePageState extends State<NearestMosquePage> {
  GoogleMapController? mapController;
  Set<Marker> _markers = {};
  Position? _currentPosition;

  // Ganti dengan API KEY kamu
  final String googleApiKey = "AIzaSyCVefT1EyUrvEy1RwOhcPX7ukG-cbSl3Ts";

  @override
  void initState() {
    super.initState();
    _getUserLocation();
  }

  // 1. Dapatkan Lokasi User
  Future<void> _getUserLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }

    Position position = await Geolocator.getCurrentPosition();
    setState(() {
      _currentPosition = position;
    });

    // Setelah dapat lokasi, langsung cari masjid
    _searchNearbyMosques(position.latitude, position.longitude);
  }

  // 2. Cari Masjid pakai Google Places API
  Future<void> _searchNearbyMosques(double lat, double lng) async {
    final String url =
        "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=$lat,$lng&radius=1000&type=mosque&key=$googleApiKey";
    // radius=1000 artinya 1km, type=mosque penting!

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List results = data['results'];

      setState(() {
        _markers.clear();
        // Marker posisi user
        _markers.add(
          Marker(
            markerId: MarkerId("current_loc"),
            position: LatLng(lat, lng),
            icon:
                BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
            infoWindow: InfoWindow(title: "Lokasi Saya"),
          ),
        );

        // Marker Masjid-masjid
        for (var result in results) {
          final loc = result['geometry']['location'];
          _markers.add(
            Marker(
              markerId: MarkerId(result['place_id']),
              position: LatLng(loc['lat'], loc['lng']),
              icon: BitmapDescriptor.defaultMarkerWithHue(
                  BitmapDescriptor.hueGreen), // Warna hijau masjid
              infoWindow: InfoWindow(
                title: result['name'],
                snippet: result['vicinity'], // Alamat singkat
              ),
            ),
          );
        }
      });

      // Pindahkan kamera ke lokasi user
      mapController?.animateCamera(
        CameraUpdate.newLatLng(LatLng(lat, lng)),
      );
    } else {
      print("Gagal mengambil data places");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Masjid Terdekat")),
      body: _currentPosition == null
          ? Center(
              child: CircularProgressIndicator()) // Loading saat cari lokasi
          : GoogleMap(
              onMapCreated: (controller) {
                mapController = controller;
              },
              initialCameraPosition: CameraPosition(
                target: LatLng(
                    _currentPosition!.latitude, _currentPosition!.longitude),
                zoom: 15.0,
              ),
              markers: _markers,
              myLocationEnabled: true, // Menampilkan titik biru lokasi asli
            ),
    );
  }
}
