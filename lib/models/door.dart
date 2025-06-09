class Door {
  final String name;
  final int id;

  Door({required this.name, required this.id});

  factory Door.fromJson(Map<String, dynamic> json) {
    return Door(
      name: json['name'] as String,
      id: json['Id'] as int,
    );
  }
}
