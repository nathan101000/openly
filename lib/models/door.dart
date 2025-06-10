class Door {
  final String name;
  final int id;
  final List<int> floors;

  Door({required this.name, required this.id, required this.floors});

  factory Door.fromJson(Map<String, dynamic> json) {
    final floors = (json['floors'] as List?)?.map((e) => e as int).toList() ?? [];
    return Door(
      name: json['name'] as String,
      id: json['Id'] as int,
      floors: floors,
    );
  }
}
