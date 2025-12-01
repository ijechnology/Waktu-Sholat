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
}