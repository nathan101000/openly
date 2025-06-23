import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/api_exception.dart';
import '../models/door.dart';
import '../models/floor.dart';
import '../models/unlock_list.dart';

class DoorService {
  static Future<UnlockList> fetchDoors(int tenantId, String token) async {
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

    final data = jsonDecode(response.body);
    final doors = (data['doors'] as List)
        .map((d) => Door.fromJson(d as Map<String, dynamic>))
        .toList();
    final floors = (data['floors'] as List?)
            ?.map((f) => Floor.fromJson(f as Map<String, dynamic>))
            .toList() ??
        [];

    for (final door in doors) {
      if (door.floors.isEmpty) {
        door.floors = _inferFloorIds(door.name, floors);
      }
    }

    return UnlockList(doors: doors, floors: floors);
  }

  static List<int> _inferFloorIds(String name, List<Floor> floors) {
    final ids = <int>[];
    final lower = name.toLowerCase();
    for (final floor in floors) {
      if (lower.contains(floor.name.toLowerCase())) {
        ids.add(floor.id);
      }
    }
    if (ids.isNotEmpty) return ids;

    final numberMatch = RegExp(r'\b(\d{3,})\b').firstMatch(name);
    if (numberMatch != null) {
      final num = int.parse(numberMatch.group(1)!);
      final floorNum = num ~/ 100;
      ids.addAll(_idsForNumber(floorNum, floors));
    }

    final flMatch = RegExp(r'(\d+)(?:st|nd|rd|th)?\s*fl', caseSensitive: false)
        .firstMatch(name);
    if (flMatch != null) {
      final num = int.parse(flMatch.group(1)!);
      ids.addAll(_idsForNumber(num, floors));
    }

    return ids;
  }

  static List<int> _idsForNumber(int num, List<Floor> floors) {
    return floors
        .where((f) => f.name.startsWith('$num'))
        .map((f) => f.id)
        .toList();
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
