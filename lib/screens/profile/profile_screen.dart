import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:praytime/screens/splash_screen.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import 'about_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final String username = authProvider.username ?? 'Pengguna';
    
    final Color textColor = Theme.of(context).colorScheme.onSurface;
    final Color secondaryTextColor = const Color(0xFF6B7280);
    final Color cardColor = Theme.of(context).colorScheme.surface; // Pink Pucat
    final Color primaryAccent = Theme.of(context).primaryColor; // Hijau Tua
    final Color errorColor = Theme.of(context).colorScheme.error; // Pink Salmon

    return Scaffold(
      appBar: AppBar(
        title: Text('Profil Saya',
            style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                color: cardColor, // Pink Pucat
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: primaryAccent.withOpacity(0.1), 
                    child: Text(
                      username[0].toUpperCase(),
                      style: GoogleFonts.inter(
                        color: primaryAccent, 
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    username,
                    style: GoogleFonts.inter(
                      color: textColor,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '"Sesungguhnya sholat itu mencegah dari (perbuatan) keji dan munkar."',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      color: secondaryTextColor,
                      fontSize: 14,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  Text(
                    '(Q.S. Al-\'Ankabut: 45)',
                    style: GoogleFonts.inter(
                      color: secondaryTextColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // --- KESAN PESAN ---
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                color: cardColor, // Pink Pucat
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Kesan Pesan',
                    style: GoogleFonts.inter(
                      color: textColor,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Divider(color: Colors.white.withOpacity(0.5)), 
                  const SizedBox(height: 4),
                  Text(
                    'Mata kuliah ini memberikan wawasan yang luar biasa tentang pengembangan aplikasi cross-platform. Semoga ilmu ini bermanfaat!',
                    style: GoogleFonts.inter(
                      color: secondaryTextColor,
                      fontSize: 15,
                      height: 1.5,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // --- "TENTANG APLIKASI" ---
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AboutScreen()),
                );
              },
              borderRadius: BorderRadius.circular(16),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: cardColor, 
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline, color: primaryAccent),
                        const SizedBox(width: 12),
                        Text(
                          'Tentang Aplikasi',
                          style: GoogleFonts.inter(
                            color: textColor,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    Icon(Icons.chevron_right, color: secondaryTextColor),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // --- TOMBOL LOGOUT ---
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        title: Text('Konfirmasi Logout', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
                        content: Text('Apakah Anda yakin ingin keluar?', style: GoogleFonts.inter()),
                        actions: [
                          TextButton(
                            child: Text('Batal', style: GoogleFonts.inter(color: secondaryTextColor)),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                          TextButton(
                            child: Text('Logout', style: GoogleFonts.inter(color: Colors.red.shade800, fontWeight: FontWeight.bold)),
                            onPressed: () {
                              Provider.of<AuthProvider>(context, listen: false).logout();
                              Navigator.of(context).pushAndRemoveUntil(
                                MaterialPageRoute(builder: (context) => SplashScreen()),
                                (Route<dynamic> route) => false,
                              );
                            },
                          ),
                        ],
                      );
                    },
                  );
                },
                // Style khusus untuk tombol Logout
                style: ElevatedButton.styleFrom(
                  backgroundColor: errorColor, 
                  foregroundColor: Colors.red.shade900,
                  elevation: 0,
                ),
                child: Text('Logout', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}