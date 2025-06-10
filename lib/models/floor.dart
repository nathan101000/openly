class Floor {
  final int id;
  final String name;

  Floor({required this.id, required this.name});

  factory Floor.fromJson(Map<String, dynamic> json) {
    return Floor(
      id: json['Id'] as int,
      name: json['name'] as String,
    );
  }
}
