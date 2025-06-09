import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  bool _isAuthenticated = false;
  bool _isChecking = true;
  String? accessToken;
  int? tenantId;
  String? userName;

  bool get isAuthenticated => _isAuthenticated;
  bool get isChecking => _isChecking;

  Future<void> loadAuthState() async {
    final auth = await AuthService.loadStoredAuth();
    if (auth != null) {
      accessToken = auth.accessToken;
      tenantId = auth.tenantId;
      userName = auth.userName;
      _isAuthenticated = true;
    }
    _isChecking = false;
    notifyListeners();
  }

  Future<void> login(String email, String password) async {
    final auth = await AuthService.login(email, password);
    accessToken = auth.accessToken;
    tenantId = auth.tenantId;
    userName = auth.userName;
    _isAuthenticated = true;
    notifyListeners();
  }

  Future<void> logout() async {
    await AuthService.clearAuth();
    _isAuthenticated = false;
    accessToken = null;
    tenantId = null;
    userName = null;
    notifyListeners();
  }
}
