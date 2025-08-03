import 'package:where_is_library/model/writer.dart';

class Book {
  final int? id; // [!] nullable -> db'ye kaydetmeden önce oluşturacağımız nesnede null iken db içinde atanacak
  final String name;
  final int? numberOfPages;
  final Writer? writer;
  final int? writerId;

  Book({this.id, required this.name, this.numberOfPages, this.writer, this.writerId});

  // [!] Burada [writer] nesnesini doğrudan {fromJson} içinde oluşturmuyoruz!
  // [!] Book çekildiğinde, writer nesnesi {JOIN} ile çekilir.
  factory Book.fromJson(Map<String, dynamic> map) {
    return Book(id: map['id'], name: map['name'], numberOfPages: map['numberOfPages'], writerId: map['writerId']);
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'numberOfPages': numberOfPages, 'writerId': writer?.id ?? writerId};
  }

  static final createTable = """
    CREATE TABLE books (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      writerId INTEGER,
      numberOfPages INTEGER,
      FOREIGN KEY (writerId) REFERENCES writers (id) ON DELETE SET NULL)
  """;
}
