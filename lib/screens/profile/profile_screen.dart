import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:praytime/screens/splash_screen.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import 'about_screen.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final String username = authProvider.username ?? 'Pengguna';
    final auth = context.watch<AuthProvider>();

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
                    radius: 55,
                    backgroundColor: Colors.grey.shade300,
                    backgroundImage: auth.avatarPath != null
                        ? FileImage(File(auth.avatarPath!))
                        : null,
                    child: auth.avatarPath == null
                        ? const Icon(Icons.person,
                            size: 60, color: Colors.white)
                        : null,
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
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const EditProfileScreen()),
                      );
                    },
                    child: Text(
                      "Edit Profil",
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w600,
                        color: primaryAccent,
                      ),
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

// --- VERSION APP ---
            buildMenuTile(
              context,
              icon: Icons.apps_outlined,
              title: "Versi Aplikasi",
              onTap: () async {
                final info = await PackageInfo.fromPlatform();
                showDialog(
                  context: context,
                  builder: (c) => AlertDialog(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    title: const Text("Informasi Aplikasi"),
                    content: Text(
                      "Versi: ${info.version}\nBuild: ${info.buildNumber}",
                    ),
                    actions: [
                      TextButton(
                        child: const Text("Tutup"),
                        onPressed: () => Navigator.pop(c),
                      )
                    ],
                  ),
                );
              },
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
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                        title: Text('Konfirmasi Logout',
                            style:
                                GoogleFonts.inter(fontWeight: FontWeight.bold)),
                        content: Text('Apakah Anda yakin ingin keluar?',
                            style: GoogleFonts.inter()),
                        actions: [
                          TextButton(
                            child: Text('Batal',
                                style: GoogleFonts.inter(
                                    color: secondaryTextColor)),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                          TextButton(
                            child: Text('Logout',
                                style: GoogleFonts.inter(
                                    color: Colors.red.shade800,
                                    fontWeight: FontWeight.bold)),
                            onPressed: () {
                              Provider.of<AuthProvider>(context, listen: false)
                                  .logout();
                              Navigator.of(context).pushAndRemoveUntil(
                                MaterialPageRoute(
                                    builder: (context) => SplashScreen()),
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
                child: Text('Logout',
                    style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget buildMenuTile(
  BuildContext context, {
  required IconData icon,
  required String title,
  required VoidCallback onTap,
}) {
  final Color textColor = Theme.of(context).colorScheme.onSurface;
  final Color secondaryTextColor = const Color(0xFF6B7280);
  final Color cardColor = Theme.of(context).colorScheme.surface;
  final Color primaryAccent = Theme.of(context).primaryColor;

  return InkWell(
    onTap: onTap,
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
              Icon(icon, color: primaryAccent),
              const SizedBox(width: 12),
              Text(
                title,
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
  );
}
