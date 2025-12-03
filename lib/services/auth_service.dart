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

  String _hashPassword(String password) {
    var bytes = utf8.encode(password);
    var digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<String?> checkSession() async {
    final box = await _openSessionBox();
    return box.get('username');
  }

  Future<bool> login(String username, String password) async {
    final box = await _openUserBox();
    final sessionBox = await _openSessionBox();

    if (!box.containsKey(username)) return false;

    final userData = box.get(username);
    String inputHash = _hashPassword(password);

    // Cek jika data masih format lama (String) atau format baru (Map)
    String storedHash;
    if (userData is String) {
      storedHash = userData;
    } else {
      storedHash = userData['password'];
    }

    if (storedHash == inputHash) {
      await sessionBox.put('username', username);
      return true;
    }
    return false;
  }

  // UPDATE 1: Register langsung simpan sebagai Map agar konsisten
  Future<bool> register(String username, String password) async {
    final box = await _openUserBox();

    if (box.containsKey(username)) {
      return false;
    }
    String hashedPassword = _hashPassword(password);

    // Simpan sebagai Map, avatar default null (kosong)
    await box.put(username, {
      "password": hashedPassword,
      "avatar": null,
    });
    return true;
  }

  Future<void> logout() async {
    final box = await _openSessionBox();
    await box.delete('username');
  }

  // ... (updateUsername tetap sama) ...
  Future<bool> updateUsername(String oldUsername, String newUsername) async {
    final box = await _openUserBox();
    final sessionBox = await _openSessionBox();

    if (box.containsKey(newUsername)) return false;

    final oldData = box.get(oldUsername);

    await box.delete(oldUsername);
    await box.put(newUsername, oldData); // Pindahkan data lama ke key baru
    await sessionBox.put('username', newUsername);

    return true;
  }

  // UPDATE 2: Parameter imagePath jadi nullable (String?) untuk fitur hapus
  Future<bool> updateAvatar(String username, String? imagePath) async {
    final box = await _openUserBox();
    final userData = box.get(username);

    if (userData == null) return false;

    // Migrasi data lama (String) ke Map jika perlu
    if (userData is String) {
      await box.put(username, {
        "password": userData,
        "avatar": imagePath,
      });
      return true;
    }

    // Update avatar di Map yang sudah ada
    // Kita harus clone map agar hive mendeteksi perubahan jika objectnya sama
    final newUserData = Map<String, dynamic>.from(userData as Map);
    newUserData["avatar"] = imagePath;

    await box.put(username, newUserData);
    return true;
  }

  Future<String?> getAvatar(String username) async {
    final box = await _openUserBox();
    final userData = box.get(username);

    if (userData is Map && userData.containsKey("avatar")) {
      return userData["avatar"]; // Bisa return null jika emang null
    }
    return null;
  }

  // ... (updatePassword tetap sama, pastikan ambil userData['password'] dgn benar) ...
  Future<bool> updatePassword(
      String username, String oldPass, String newPass) async {
    final box = await _openUserBox();
    if (!box.containsKey(username)) return false;

    final userData = box.get(username);
    String hashedOld = _hashPassword(oldPass);

    if (userData is String) {
      if (userData != hashedOld) return false;
      await box.put(username, {
        "password": _hashPassword(newPass),
        "avatar": null,
      });
      return true;
    }

    if (userData["password"] != hashedOld) return false;

    final newUserData = Map<String, dynamic>.from(userData as Map);
    newUserData["password"] = _hashPassword(newPass);

    await box.put(username, newUserData);

    return true;
  }
}
