class Door {
  final String name;
  final int id;
  List<int> floors;

  Door({required this.name, required this.id, List<int>? floors})
      : floors = floors ?? [];

  factory Door.fromJson(Map<String, dynamic> json) {
    final floors = (json['floors'] as List?)?.map((e) => e as int).toList() ?? [];
    return Door(
      name: json['name'] as String,
      id: json['Id'] as int,
      floors: floors,
    );
  }
}
