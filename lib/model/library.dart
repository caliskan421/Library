import 'package:where_is_library/model/number_of_book.dart';
import 'package:where_is_library/model/library_location.dart';

class Library {
  final int? id;
  final String name;
  final int locationId; // LibraryLocation tablosuna referans
  final LibraryLocation? location; // İlişkilendirilmiş location nesnesi
  final List<NumberOfBook?>
  numberOfBook; // [!] Bu liste doğrudan DB'ye kaydedilmez, dikkat!

  Library({
    this.id,
    required this.name,
    required this.locationId,
    this.location,
    this.numberOfBook = const [],
  });

  // [!] numberOfBook listesi bu metod içinde doldurulmaz!
  // [!] Veritabanından [Library] nesnesi çekildikten sonra <ayrı bir sorgu> ile [NumberOfBook] listesi çekilip manuel olarak atanır.
  factory Library.fromJson(Map<String, dynamic> json) {
    return Library(
      id: json['id'],
      name: json['name'],
      locationId: json['locationId'],
      numberOfBook:
          const [], // [!] {fromJson} sırasında liste <boş> olarak başlatılır, sonradan doldurulur.
    );
  }

  // [!] numberOfBook listesi bu Map'e <dahil edilmez>, çünkü doğrudan DB'ye kaydedilmez.
  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'locationId': locationId};
  }

  static final createTable = """
    CREATE TABLE libraries (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT,
      locationId INTEGER,
      FOREIGN KEY (locationId) REFERENCES library_locations (id))
  """;
}
