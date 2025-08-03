class LibraryLocation {
  final int? id;
  final String title;
  final int lat;
  final int long;

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
      lat: json['lat'],
      long: json['long'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'title': title, 'lat': lat, 'long': long};
  }

  static final createTable = """
    CREATE TABLE library_locations (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      title TEXT,
      lat INTEGER,
      long INTEGER)
  """;
}
