import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/api_exception.dart';
import '../models/building.dart'; // contains Building, Floor, Door, parseBuildingFromJson

class DoorService {
  static Future<Building> fetchDoors(int tenantId, String token) async {
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
      try {
        final decoded = jsonDecode(response.body);
        final errorMessage =
            decoded['message'] ?? decoded['error'] ?? 'Failed to load doors';
        throw ApiException('fetch_doors_failed', errorMessage);
      } catch (_) {
        throw ApiException(
            'invalid_response', 'Failed to load doors.\n${response.body}');
      }
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;

    // 👉 Use the parser we built earlier
    final building = parseBuildingFromJson(data);
    return building;
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
      body: jsonEncode({
        'doorId': doorId,
        'floorId': null, // optional if API supports
        'minutes': minutes,
      }),
    );

    if (response.statusCode != 200) {
      try {
        final decoded = jsonDecode(response.body);
        final errorMessage =
            decoded['message'] ?? decoded['error'] ?? 'Failed to unlock door';
        throw ApiException('unlock_failed', errorMessage);
      } catch (_) {
        throw ApiException(
            'invalid_response', 'Failed to unlock door.\n${response.body}');
      }
    }
  }
}
