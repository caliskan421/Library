import 'package:where_is_library/model/number_of_book.dart';

class Library {
  final int? id;
  final String name;
  final String location;
  final List<NumberOfBook?> numberOfBook; // [!] Bu liste doğrudan DB'ye kaydedilmez, dikkat!

  Library({this.id, required this.name, required this.location, this.numberOfBook = const []});

  // [!] numberOfBook listesi bu metod içinde doldurulmaz!
  // [!] Veritabanından [Library] nesnesi çekildikten sonra <ayrı bir sorgu> ile [NumberOfBook] listesi çekilip manuel olarak atanır.
  factory Library.fromJson(Map<String, dynamic> json) {
    return Library(
      id: json['id'],
      name: json['name'],
      location: json['location'],
      numberOfBook: const [], // [!] {fromJson} sırasında liste <boş> olarak başlatılır, sonradan doldurulur.
    );
  }

  // [!] numberOfBook listesi bu Map'e <dahil edilmez>, çünkü doğrudan DB'ye kaydedilmez.
  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'location': location};
  }

  static final createTable = """
    CREATE TABLE libraries (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT,
      location TEXT)
  """;
}
