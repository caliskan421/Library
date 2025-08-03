class LibraryLocation {
  final int? id;
  final String title;
  final double lat;
  final double long;

  LibraryLocation({
    this.id,
    required this.title,
    required this.lat,
    required this.long,
  });

  factory LibraryLocation.fromJson(Map<String, dynamic> json) {
    return LibraryLocation(
      id: json['id'],
      title: json['title'],
      lat: (json['lat'] as num).toDouble(),
      long: (json['long'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'title': title, 'lat': lat, 'long': long};
  }

  static final createTable = """
    CREATE TABLE library_locations (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      title TEXT,
      lat REAL,
      long REAL)
  """;
}
