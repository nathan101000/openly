import 'dart:convert';

/// ---------------------- Models ----------------------

class Building {
  final Map<int, Floor> floors; // key = floor number (6, 7, 8)
  final List<Door> unassignedDoors; // lobby, cafe, main entrance, etc.

  Building({required this.floors, required this.unassignedDoors});
}

class Floor {
  final int number;
  final String displayName; // "6th Fl"
  final Map<String, int>
      elevatorIdsByName; // {"Elevator A": 2, "Elevator B": 1}
  final List<Door> doors;

  Floor({
    required this.number,
    required this.displayName,
    Map<String, int>? elevatorIdsByName,
    List<Door>? doors,
  })  : elevatorIdsByName = elevatorIdsByName ?? {},
        doors = doors ?? [];

  void addElevator(String name, int id) {
    elevatorIdsByName[name] = id;
  }

  void addDoor(Door door) {
    doors.add(door);
  }
}

enum DoorType {
  suite,
  washroomMen,
  washroomWomen,
  staircase,
  conference,
  genericFloorDoor, // floor-related but not one of the above (fallback)
  other, // building-level / unassigned (lobby/cafe/etc.)
}

class Door {
  final int id;
  final String name;
  final DoorType type;
  final int? inferredFloor; // null for building-level doors
  final String? side; // Left/Right if present

  Door({
    required this.id,
    required this.name,
    required this.type,
    required this.inferredFloor,
    this.side,
  });
}

/// ---------------------- Regex Helpers ----------------------

class _R {
  // Matches "6th Fl" / "7th Fl" / "8th Fl" anywhere
  static final floorTag = RegExp(
    r'\b(\d{1,2})(?:st|nd|rd|th)\s*fl\b',
    caseSensitive: false,
  );

  // Matches "Suite 604", "Suite 1004" etc.
  static final suite = RegExp(
    r'\bsuite\s+(\d{3,4})\b',
    caseSensitive: false,
  );

  // Washrooms: handles "Men", "Men's", "Mens", etc.
  static final menRoom = RegExp(
    r"\bmen('?s)?\b(\s+wash\s*room|\s+room)?\b",
    caseSensitive: false,
  );

  static final womenRoom = RegExp(
    r"\bwomen('?s)?\b(\s+wash\s*room|\s+room)?\b",
    caseSensitive: false,
  );

  // Left/Right
  static final side = RegExp(
    r'\b(left|right)\b',
    caseSensitive: false,
  );

  // Staircase
  static final staircase = RegExp(
    r'\bstaircase\b',
    caseSensitive: false,
  );

  // Conference
  static final conference = RegExp(
    r'\bconference\b',
    caseSensitive: false,
  );

  // Any pure number like 604 inside a name if we want a fallback
  static final numberToken = RegExp(r'\b(\d{3,4})\b');

  // Things that are very likely building-level (no floor)
  static final buildingLevelHints = RegExp(
    r'\b(lobby|cafe|store|entrance|parking|shabbat|face)\b',
    caseSensitive: false,
  );
}

/// Try to infer the floor number from a door's name.
/// Returns null if we cannot reliably infer.
int? inferFloorNumberFromDoorName(String name) {
  // Priority 1: explicit "6th Fl" tag
  final mTag = _R.floorTag.firstMatch(name);
  if (mTag != null) {
    return int.tryParse(mTag.group(1)!);
  }

  // Priority 2: suite numbers (604 -> 6th, 1004 -> 10th)
  final mSuite = _R.suite.firstMatch(name);
  if (mSuite != null) {
    final digits = mSuite.group(1)!;
    return _floorFromRoomNumber(digits);
  }

  // Priority 3: if name contains a 3–4 digit token and also clearly references a floor word
  // (rarely needed for your sample, kept as a smart fallback)
  final mNum = _R.numberToken.firstMatch(name);
  if (mNum != null) {
    final digits = mNum.group(1)!;
    // Use only if the name *also* implies it's a floor thing (e.g., "Room 604")
    if (RegExp(r'(?i)\b(room|suite|office)\b').hasMatch(name)) {
      return _floorFromRoomNumber(digits);
    }
  }

  // No floor hint found
  return null;
}

/// "604" -> 6, "1004" -> 10, "1201" -> 12
int _floorFromRoomNumber(String digits) {
  if (digits.length == 3) {
    return int.parse(digits[0]); // 604 -> 6
  } else if (digits.length == 4) {
    return int.parse(digits.substring(0, 2)); // 1004 -> 10
  } else {
    // Fallback heuristic: first 1–2 digits
    return int.parse(digits.substring(0, digits.length - 2));
  }
}

DoorType classifyDoorType(String name) {
  if (_R.staircase.hasMatch(name)) return DoorType.staircase;
  if (_R.conference.hasMatch(name)) return DoorType.conference;
  if (_R.menRoom.hasMatch(name)) return DoorType.washroomMen;
  if (_R.womenRoom.hasMatch(name)) return DoorType.washroomWomen;
  if (_R.suite.hasMatch(name)) return DoorType.suite;

  // If it looks like a building-level item and we cannot infer a floor, classify as other
  final floor = inferFloorNumberFromDoorName(name);
  if (floor == null && _R.buildingLevelHints.hasMatch(name)) {
    return DoorType.other;
  }

  // Default
  return floor == null ? DoorType.other : DoorType.genericFloorDoor;
}

String? extractSide(String name) {
  final m = _R.side.firstMatch(name);
  return m?.group(1)?.toLowerCase().capitalize();
}

extension _Cap on String {
  String capitalize() =>
      isEmpty ? this : (this[0].toUpperCase() + substring(1).toLowerCase());
}

/// ---------------------- Parser ----------------------

Building parseBuildingFromJson(Map<String, dynamic> json) {
  // 1) Build floors map, deduplicating by floor number
  final floorsList = (json['floors'] as List).cast<Map<String, dynamic>>();
  final Map<int, Floor> floorsByNumber = {};

  for (final f in floorsList) {
    final displayName = f['name'] as String? ?? '';
    final number = _parseFloorNumberFromDisplay(displayName);
    if (number == null) continue;

    floorsByNumber.putIfAbsent(
      number,
      () => Floor(number: number, displayName: displayName),
    );

    final elevatorName = f['elevatorName'] as String? ?? '';
    final elevatorId = f['elevatorId'] as int? ?? -1;
    if (elevatorName.isNotEmpty && elevatorId > 0) {
      floorsByNumber[number]!.addElevator(elevatorName, elevatorId);
    }
  }

  // 2) Parse doors, attach to inferred floor (if any), else unassigned
  final doorsList = (json['doors'] as List).cast<Map<String, dynamic>>();
  final List<Door> unassigned = [];

  for (final d in doorsList) {
    final name = (d['name'] as String? ?? '').trim();
    final id = d['Id'] as int? ?? -1;

    final floorNum = inferFloorNumberFromDoorName(name);
    final type = classifyDoorType(name);
    final side = extractSide(name);

    final door = Door(
      id: id,
      name: name,
      type: type,
      inferredFloor: floorNum,
      side: side,
    );

    if (floorNum != null && floorsByNumber.containsKey(floorNum)) {
      floorsByNumber[floorNum]!.addDoor(door);
    } else {
      // Either building-level or a floor we don't know in floors[]
      if (type == DoorType.other || floorNum == null) {
        unassigned.add(door);
      } else {
        // if it's clearly floor-related but the floor wasn't in floors[], still keep unassigned
        unassigned.add(door);
      }
    }
  }

  return Building(floors: floorsByNumber, unassignedDoors: unassigned);
}

int? _parseFloorNumberFromDisplay(String display) {
  // "6th Fl" / "7th Fl" / "8th Fl"
  final m = _R.floorTag.firstMatch(display);
  if (m != null) return int.tryParse(m.group(1)!);

  // Fallback if someone puts "Floor 6"
  final alt = RegExp(r'(?i)\bfloor\s+(\d{1,2})\b').firstMatch(display);
  if (alt != null) return int.tryParse(alt.group(1)!);

  return null;
}

/// ---------------------- Example Usage ----------------------
/// Call this with your JSON string to see it working.
void demo(String jsonString) {
  final map = json.decode(jsonString) as Map<String, dynamic>;
  final building = parseBuildingFromJson(map);

  // Print a quick summary:
  for (final entry in building.floors.entries.toList()
    ..sort((a, b) => a.key.compareTo(b.key))) {
    final floor = entry.value;
    print('Floor ${floor.number} (${floor.displayName}) '
        'Elevators: ${floor.elevatorIdsByName}');
    for (final door in floor.doors) {
      print('  - [${door.type.name}] ${door.name}'
          '${door.side != null ? " (${door.side})" : ""}');
    }
  }

  print('\nUnassigned / Building-level doors:');
  for (final door in building.unassignedDoors) {
    print('  - [${door.type.name}] ${door.name}');
  }
}
