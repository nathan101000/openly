import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  bool _isAuthenticated = false;
  bool _isChecking = true;
  String? accessToken;
  int? tenantId;
  String? userName;
  String? displayName;

  bool get isAuthenticated => _isAuthenticated;
  bool get isChecking => _isChecking;

  bool _isAuthorized = false;
  bool get isAuthorized => _isAuthorized;

  // ───────────────────────── helpers
  void _finishChecking() {
    _isChecking = false;
    notifyListeners();
  }

  Future<void> biometricLogin() async {
    final stored = await AuthService.loadStoredAuth();
    if (stored == null) throw Exception('No stored credentials');

    accessToken = stored.accessToken;
    tenantId = stored.tenantId;
    userName = stored.userName;
    displayName = stored.displayName;
    _isAuthenticated = true;
    _isAuthorized = true;
    notifyListeners();
  }

  void markAuthorized() {
    _isAuthorized = true;
    notifyListeners();
  }

  Future<void> loadAuthState() async {
    final auth = await AuthService.loadStoredAuth();
    if (auth != null) {
      // we *only* preload creds – not authorised yet
      accessToken = auth.accessToken;
      tenantId = auth.tenantId;
      userName = auth.userName;
      displayName = auth.displayName;
      _isAuthenticated = true;
      // _isAuthorized stays false until biometric
    }
    // leave _isChecking = true – AppEntryPoint clears it
    notifyListeners();
  }

  void finishChecking() => _finishChecking();

  Future<void> login(String email, String password) async {
    final auth = await AuthService.login(email, password);
    print('Login successful: ${auth.accessToken}');
    accessToken = auth.accessToken;
    tenantId = auth.tenantId;
    userName = auth.userName;
    displayName = auth.displayName;
    _isAuthenticated = true;
    notifyListeners();
  }

  Future<void> logout() async {
    await AuthService.clearAuth();
    _isAuthenticated = false;
    _isAuthorized = false;
    accessToken = null;
    tenantId = null;
    userName = null;
    notifyListeners();
  }
}
