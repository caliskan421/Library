class Writer {
  final int? id;
  final String name;

  Writer({this.id, required this.name});

  factory Writer.fromJson(Map<String, dynamic> json) {
    return Writer(id: json['id'], name: json['name']);
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name};
  }

  static final createTable = """
    CREATE TABLE writers (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL UNIQUE)
  """;
}
