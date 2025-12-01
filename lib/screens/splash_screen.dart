import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart'; // <-- 1. Import AuthProvider

// 2. Ubah menjadi StatefulWidget
class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  // 3. Panggil fungsi pengecekan saat halaman ini pertama kali dibuka
  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  // 4. Ini adalah fungsi utama untuk memanggil session
  Future<void> _checkLoginStatus() async {
    // Beri jeda 2 detik agar splash screen terlihat
    await Future.delayed(const Duration(seconds: 2));

    // Panggil fungsi checkSession() dari AuthProvider
    // PENTING: Kita pakai 'listen: false' di dalam initState
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.checkSession();

    // Pastikan widget masih ada (mounted) sebelum navigasi
    if (!mounted) return;

    // 5. Tentukan navigasi berdasarkan hasil checkSession()
    if (authProvider.isLoggedIn) {
      // Jika SUDAH login, langsung ke Halaman Utama
      Navigator.of(context).pushReplacementNamed('/main');
    } else {
      // Jika BELUM login, ke Halaman Login
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Ini adalah UI splash screen (tetap sama)
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA), // Latar belakang cerah
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Ganti dengan logo/ikon aplikasimu
            Icon(
              Icons.mosque, // Contoh ikon
              size: 100,
              color: Theme.of(context).primaryColor, // Hijau Tua
            ),
            const SizedBox(height: 20),
            Text(
              'PrayTime',
              style: GoogleFonts.inter(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
            const SizedBox(height: 20),
            CircularProgressIndicator(
              color: Theme.of(context).primaryColor,
            ),
          ],
        ),
      ),
    );
  }
}