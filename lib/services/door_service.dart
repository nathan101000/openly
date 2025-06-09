import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/door.dart';

class DoorService {
  static Future<List<Door>> fetchDoors(int tenantId, String token) async {
    final url =
        'https://doors.thespencertower.com/api/api/tenants/$tenantId/unlocklist';
    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to load doors');
    }
    final data = jsonDecode(response.body);
    final doors = (data['doors'] as List)
        .map((d) => Door.fromJson(d as Map<String, dynamic>))
        .toList();
    return doors;
  }

  static Future<void> unlockDoor(
    int doorId,
    int tenantId,
    String token,
    int minutes,
  ) async {
    final url =
        'https://doors.thespencertower.com/api/api/tenants/$tenantId/unlock';
    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'doorId': doorId, 'floorId': null, 'minutes': minutes}),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to unlock door');
    }
  }
}
