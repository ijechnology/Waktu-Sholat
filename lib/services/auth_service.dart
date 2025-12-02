// lib/services/auth_service.dart

import 'package:hive_flutter/hive_flutter.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';

class AuthService {
  Future<Box> _openUserBox() async {
    return await Hive.openBox('users');
  }

  Future<Box> _openSessionBox() async {
    return await Hive.openBox('session');
  }

  // Fungsi untuk hash password
  String _hashPassword(String password) {
    var bytes = utf8.encode(password);
    var digest = sha256.convert(bytes);
    return digest.toString();
  }

  // Fungsi ini dipanggil oleh AuthProvider saat app start
  Future<String?> checkSession() async {
    final box = await _openSessionBox();
    return box.get('username');
  }

  Future<bool> login(String username, String password) async {
    final box = await _openUserBox();
    final sessionBox = await _openSessionBox();

    String hashedPassword = _hashPassword(password);
    if (box.containsKey(username) && box.get(username) == hashedPassword) {
      await sessionBox.put('username', username);
      return true;
    }
    return false;
  }

  Future<bool> register(String username, String password) async {
    final box = await _openUserBox();

    if (box.containsKey(username)) {
      return false;
    }
    String hashedPassword = _hashPassword(password);
    await box.put(username, hashedPassword);
    return true;
  }

  Future<void> logout() async {
    final box = await _openSessionBox();
    await box.delete('username');
  }

  Future<bool> updateUsername(String oldUsername, String newUsername) async {
    final box = await _openUserBox();
    final sessionBox = await _openSessionBox();

    // Jika username baru sudah ada → gagal
    if (box.containsKey(newUsername)) {
      return false;
    }

    // Ambil password lama
    final oldPasswordHash = box.get(oldUsername);

    // Hapus key lama, buat key baru
    await box.delete(oldUsername);
    await box.put(newUsername, oldPasswordHash);

    // Update session
    await sessionBox.put('username', newUsername);

    return true;
  }

  Future<bool> updateAvatar(String username, String imagePath) async {
    final box = await _openUserBox();

    final userData = box.get(username);
    if (userData == null) return false;

    // userData bisa berupa hash password saja → ubah jadi Map
    if (userData is String) {
      // convert: { "password": hashedPassword }
      await box.put(username, {
        "password": userData,
        "avatar": imagePath,
      });
      return true;
    }

    userData["avatar"] = imagePath;
    await box.put(username, userData);
    return true;
  }

  Future<String?> getAvatar(String username) async {
    final box = await _openUserBox();
    final userData = box.get(username);

    if (userData is Map && userData.containsKey("avatar")) {
      return userData["avatar"];
    }
    return null;
  }

  Future<bool> updatePassword(
      String username, String oldPass, String newPass) async {
    final box = await _openUserBox();

    if (!box.containsKey(username)) return false;

    final userData = box.get(username);

    String hashedOld = _hashPassword(oldPass);

    // Jika format awal masih "password only"
    if (userData is String) {
      if (userData != hashedOld) return false;

      await box.put(username, {
        "password": _hashPassword(newPass),
        "avatar": null,
      });
      return true;
    }

    // Jika data sudah Map
    if (userData["password"] != hashedOld) return false;

    userData["password"] = _hashPassword(newPass);
    await box.put(username, userData);

    return true;
  }
}
