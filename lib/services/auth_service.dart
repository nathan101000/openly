import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthData {
  final String accessToken;
  final int tenantId;
  final String userId;
  final String userName;

  AuthData(this.accessToken, this.tenantId, this.userId, this.userName);
}

class AuthService {
  static const _tokenKey = 'auth_token';
  static const _tenantKey = 'tenant_id';
  static const _userIdKey = 'user_id';
  static const _userNameKey = 'user_name';

  static Future<AuthData> login(String email, String password) async {
    final body = {
      'username': email,
      'password': password,
      'grant_type': 'password',
    };
    final response = await http.post(
      Uri.parse('https://doors.thespencertower.com/api/token'),
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: body,
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to login');
    }
    final data = jsonDecode(response.body);
    final tenantRoles = jsonDecode(data['tenantRoles'])[0];
    final tenantId = tenantRoles['tenantId'] as int;
    final auth = AuthData(
      data['access_token'],
      tenantId,
      data['userId'],
      data['userName'],
    );
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, auth.accessToken);
    await prefs.setInt(_tenantKey, auth.tenantId);
    await prefs.setString(_userIdKey, auth.userId);
    await prefs.setString(_userNameKey, auth.userName);
    return auth;
  }

  static Future<AuthData?> loadStoredAuth() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_tokenKey);
    final tenant = prefs.getInt(_tenantKey);
    final userId = prefs.getString(_userIdKey);
    final userName = prefs.getString(_userNameKey);
    if (token != null && tenant != null) {
      return AuthData(token, tenant, userId ?? '', userName ?? '');
    }
    return null;
  }

  static Future<void> clearAuth() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_tenantKey);
    await prefs.remove(_userIdKey);
    await prefs.remove(_userNameKey);
  }
}
