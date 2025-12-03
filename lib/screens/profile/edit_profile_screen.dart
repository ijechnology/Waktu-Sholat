import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../providers/auth_provider.dart';
import 'package:google_fonts/google_fonts.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final TextEditingController usernameC = TextEditingController();
  final TextEditingController oldPassC = TextEditingController();
  final TextEditingController newPassC = TextEditingController();

  @override
  void initState() {
    super.initState();
    final auth = context.read<AuthProvider>();
    usernameC.text = auth.username ?? '';
  }

  // --- BAGIAN YANG HILANG (FUNGSI-FUNGSI LOGIKA) ---

  // 1. Fungsi Ambil Gambar
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.gallery);

    if (file != null) {
      if (!mounted) return;
      // Update avatar dengan path file baru
      await context.read<AuthProvider>().updateAvatar(file.path);
      Navigator.pop(context); // Tutup modal
    }
  }

  // 2. Fungsi Hapus Gambar
  Future<void> _deleteImage() async {
    // Pastikan di AuthProvider sudah ada method deleteAvatar()
    // atau pakai updateAvatar(null)
    await context.read<AuthProvider>().deleteAvatar();
    if (!mounted) return;
    Navigator.pop(context); // Tutup modal
  }

  // 3. Fungsi Menampilkan Modal Pilihan (Ini yang error "undefined method")
  // GANTI FUNGSI INI
  void _showPhotoOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        // CEK LANGSUNG KE PROVIDER DI SINI (LEBIH AKURAT)
        // Kita pakai read() karena di dalam callback builder
        final authProvider = context.read<AuthProvider>();
        final bool isPhotoExist = authProvider.avatarPath != null;

        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Ambil dari Galeri'),
                onTap: _pickImage,
              ),
              // LOGIKA: Jika foto ada, TAMPILKAN tombol hapus
              if (isPhotoExist)
                ListTile(
                  leading: const Icon(Icons.delete, color: Colors.red),
                  title: const Text(
                    'Hapus Foto Profil',
                    style: TextStyle(color: Colors.red),
                  ),
                  onTap: _deleteImage,
                ),
            ],
          ),
        );
      },
    );
  }

  // --- AKHIR BAGIAN YANG HILANG ---

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    // --- BAGIAN YANG HILANG (VARIABEL hasImage) ---
    // Ini penting agar kodingan di bawah tau status fotonya
    final bool hasImage = auth.avatarPath != null;
    // ----------------------------------------------

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Edit Profil",
          style: GoogleFonts.inter(fontWeight: FontWeight.w700),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // ========================
            // FOTO PROFIL
            // ========================
            Center(
              child: GestureDetector(
                // Di sini errornya hilang karena fungsi dan variabel sudah ada
                onTap: () => _showPhotoOptions(context),
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 55,
                      backgroundColor: Colors.grey.shade300,
                      // Cek jika ada foto, pakai FileImage. Jika tidak, null.
                      backgroundImage:
                          hasImage ? FileImage(File(auth.avatarPath!)) : null,
                      // Jika tidak ada foto, tampilkan Icon Person
                      child: !hasImage
                          ? const Icon(Icons.person,
                              size: 60, color: Colors.white)
                          : null,
                    ),
                    // Icon Edit Kecil (Penyemanis)
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.edit,
                            size: 16, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              "Ketuk foto untuk mengedit",
              style: GoogleFonts.inter(fontSize: 13, color: Colors.grey),
            ),

            const SizedBox(height: 30),

            // ========================
            // UBAH USERNAME
            // ========================
            TextField(
              controller: usernameC,
              decoration: const InputDecoration(
                labelText: "Username Baru",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  String newName = usernameC.text.trim();
                  if (newName.isEmpty) return;

                  bool ok = await auth.updateUsername(newName);

                  if (!context.mounted) return;

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(ok
                          ? "Username berhasil diubah"
                          : "Username sudah digunakan"),
                      backgroundColor: ok ? Colors.green : Colors.red,
                    ),
                  );
                },
                child: Text(
                  "Simpan Username",
                  style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                ),
              ),
            ),

            const SizedBox(height: 30),

            // ========================
            // UBAH PASSWORD
            // ========================
            TextField(
              controller: oldPassC,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: "Password Lama",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: newPassC,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: "Password Baru",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  String? result = await auth.updatePassword(
                    oldPassC.text.trim(),
                    newPassC.text.trim(),
                  );

                  if (!context.mounted) return;

                  if (result != null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text(result), backgroundColor: Colors.red),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text("Password berhasil diubah"),
                          backgroundColor: Colors.green),
                    );
                    oldPassC.clear();
                    newPassC.clear();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      Colors.green, // Pembeda warna tombol password
                ),
                child: Text(
                  "Ubah Password",
                  style: GoogleFonts.inter(
                      fontWeight: FontWeight.w600, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
