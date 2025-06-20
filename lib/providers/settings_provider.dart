import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';

class SettingsProvider extends ChangeNotifier {
  static const _rememberKey = 'remember_me';
  static const _biometricKey = 'use_biometrics';
  static const _emailKey = 'email';
  static const _passwordKey = 'password';

  final LocalAuthentication _localAuth = LocalAuthentication();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  bool rememberMe = false;
  bool useBiometrics = false;
  bool biometricsAvailable = false;

  SettingsProvider() {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    rememberMe = prefs.getBool(_rememberKey) ?? false;
    useBiometrics = prefs.getBool(_biometricKey) ?? false;
    biometricsAvailable =
        await _localAuth.canCheckBiometrics && await _localAuth.isDeviceSupported();
    notifyListeners();
  }

  Future<void> setRememberMe(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    rememberMe = value;
    await prefs.setBool(_rememberKey, value);
    if (!value) {
      await _secureStorage.delete(key: _emailKey);
      await _secureStorage.delete(key: _passwordKey);
    }
    notifyListeners();
  }

  Future<void> setUseBiometrics(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    useBiometrics = value;
    await prefs.setBool(_biometricKey, value);
    notifyListeners();
  }

  Future<void> storeCredentials(String email, String password) async {
    if (!rememberMe) return;
    await _secureStorage.write(key: _emailKey, value: email);
    await _secureStorage.write(key: _passwordKey, value: password);
  }

  Future<Map<String, String>?> loadCredentials() async {
    final email = await _secureStorage.read(key: _emailKey);
    final password = await _secureStorage.read(key: _passwordKey);
    if (email != null && password != null) {
      return {'email': email, 'password': password};
    }
    return null;
  }
}
