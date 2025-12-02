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

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.gallery);

    if (file != null) {
      await context.read<AuthProvider>().updateAvatar(file.path);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

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
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 55,
                  backgroundColor: Colors.grey.shade300,
                  backgroundImage: auth.avatarPath != null
                      ? FileImage(File(auth.avatarPath!))
                      : null,
                  child: auth.avatarPath == null
                      ? const Icon(Icons.person, size: 60, color: Colors.white)
                      : null,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              "Ketuk untuk ganti foto",
              style: GoogleFonts.inter(fontSize: 13),
            ),

            const SizedBox(height: 30),

            // ========================
            // UBAH USERNAME
            // ========================
            TextField(
              controller: usernameC,
              decoration: const InputDecoration(
                labelText: "Username Baru",
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

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(ok
                          ? "Username berhasil diubah"
                          : "Username sudah digunakan"),
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
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: newPassC,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: "Password Baru",
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

                  if (result != null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(result)),
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
                child: Text(
                  "Ubah Password",
                  style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
