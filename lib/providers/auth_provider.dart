import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/notification_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  final NotificationService _notificationService = NotificationService();

  bool _isLoggedIn = false;
  String? _username;
  String? _errorMessage;

  bool _isLoading = false;

  bool get isLoggedIn => _isLoggedIn;
  String? get username => _username;
  String? get errorMessage => _errorMessage;

  bool get isLoading => _isLoading;

  String? _avatarPath;
  String? get avatarPath => _avatarPath;

  Future<void> checkSession() async {
    _username = await _authService.checkSession();
    if (_username != null) {
      _avatarPath = await _authService.getAvatar(_username!);
      _isLoggedIn = true;
    }
    notifyListeners();
  }

  Future<bool> login(String username, String password) async {
    _errorMessage = null;
    _isLoading = true;
    notifyListeners();

    bool success = await _authService.login(username, password);
    if (success) {
      _isLoggedIn = true;
      _username = username;
      _isLoading = false;
      notifyListeners();
      return true;
    } else {
      _errorMessage = 'Username atau password salah';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register(String username, String password) async {
    _errorMessage = null;
    _isLoading = true;
    notifyListeners();

    bool success = await _authService.register(username, password);

    if (success) {
      await _notificationService.showRegistrationSuccessNotification();
      _isLoading = false;
      notifyListeners();
      return true;
    } else {
      _errorMessage = 'Username sudah digunakan';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateUsername(String newUsername) async {
    if (_username == null) return false;

    bool success = await _authService.updateUsername(_username!, newUsername);

    if (success) {
      _username = newUsername;
      notifyListeners();
      return true;
    } else {
      _errorMessage = "Username sudah digunakan";
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    _isLoggedIn = false;
    _username = null;
    notifyListeners();
  }

  Future<void> updateAvatar(String path) async {
    if (_username == null) return;

    bool ok = await _authService.updateAvatar(_username!, path);
    if (ok) {
      _avatarPath = path;
      notifyListeners();
    }
  }

  Future<String?> updatePassword(String oldPass, String newPass) async {
    if (_username == null) return "Anda tidak login";

    bool ok = await _authService.updatePassword(_username!, oldPass, newPass);
    if (!ok) return "Password lama salah";

    return null; // null artinya sukses
  }
}
