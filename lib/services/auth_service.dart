import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/api_exception.dart' show ApiException;
import 'package:flutter/foundation.dart';

class AuthData {
  final String accessToken;
  final int tenantId;
  final String userId;
  final String userName;
  final String displayName;

  AuthData(
    this.accessToken,
    this.tenantId,
    this.userId,
    this.userName,
    this.displayName,
  );
}

class AuthService {
  static const _tokenKey = 'auth_token';
  static const _tenantKey = 'tenant_id';
  static const _userIdKey = 'user_id';
  static const _userNameKey = 'user_name';
  static const _displayNameKey = 'display_name';

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
      debugPrint('Login failed response: ${response.body}');
      debugPrint('Content-Type: ${response.headers['content-type']}');

      Map<String, dynamic> decoded;
      try {
        decoded = jsonDecode(response.body);
      } catch (e) {
        debugPrint('❌ Failed to decode JSON error response: $e');
        throw ApiException('unknown', 'Login failed.\n${response.body}');
      }

      final error = decoded['error'] ?? '';
      final description = decoded['error_description'] ?? 'Login failed';

      if (error == 'invalid_grant' &&
          description.toLowerCase().contains('locked')) {
        throw ApiException('account_locked',
            'Your account is locked. Please contact support.');
      } else if (error == 'invalid_grant' &&
          description.toLowerCase().contains('incorrect')) {
        throw ApiException('wrong_password',
            'The email or password you entered is incorrect.');
      }

      throw ApiException('login_failed', description);
    }

    final data = jsonDecode(response.body);

    final tenantRolesJson = data['tenantRoles'];
    if (tenantRolesJson == null || tenantRolesJson.isEmpty) {
      throw ApiException('no_tenant', 'Tenant roles not found');
    }

    final tenantRoles = jsonDecode(tenantRolesJson)[0];
    final tenantId = tenantRoles['tenantId'];

    if (tenantId == null ||
        data['access_token'] == null ||
        data['userId'] == null ||
        data['userName'] == null) {
      throw ApiException('invalid_response', 'Incomplete login response');
    }

    final displayName = _capitalizeUsername(data['userName']);

    final auth = AuthData(
      data['access_token'],
      tenantId,
      data['userId'],
      data['userName'],
      displayName,
    );

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, auth.accessToken);
    await prefs.setInt(_tenantKey, auth.tenantId);
    await prefs.setString(_userIdKey, auth.userId);
    await prefs.setString(_userNameKey, auth.userName);
    await prefs.setString(_displayNameKey, auth.displayName);

    return auth;
  }

  static Future<AuthData?> loadStoredAuth() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_tokenKey);
    final tenant = prefs.getInt(_tenantKey);
    final userId = prefs.getString(_userIdKey);
    final userName = prefs.getString(_userNameKey);
    final displayName = prefs.getString(_displayNameKey);

    if (token != null &&
        tenant != null &&
        userId != null &&
        userName != null &&
        displayName != null) {
      return AuthData(token, tenant, userId, userName, displayName);
    }

    return null;
  }

  static Future<void> clearAuth() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_tenantKey);
    await prefs.remove(_userIdKey);
    await prefs.remove(_userNameKey);
    await prefs.remove(_displayNameKey);
  }

  static String _capitalizeUsername(String email) {
    final name = email.split('@').first;
    return name.isNotEmpty ? name[0].toUpperCase() + name.substring(1) : '';
  }
}
