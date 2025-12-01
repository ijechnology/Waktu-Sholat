

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

  Future<void> checkSession() async {
    _username = await _authService.checkSession();
    if (_username != null) {
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

  Future<void> logout() async {
    await _authService.logout();
    _isLoggedIn = false;
    _username = null;
    notifyListeners();
  }
}