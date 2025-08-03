import 'package:where_is_library/model/writer.dart';

import 'book.dart';

class NumberOfBook {
  final int? id;
  final int number;
  final Book book;
  final int? libraryId;

  NumberOfBook({this.id, this.number = 0, required this.book, this.libraryId});

  factory NumberOfBook.fromJsonWithBook(Map<String, dynamic> json) {
    /// Todo --> [Writer] nesnesini ayri bir sorgu ile kaydet
    // [?] Neden [snake_case] stilde {json-model} donusumleri yapiliyor ???
    // [!]  SQL sorgularında, özellikle [JOIN] işlemleriyle birden fazla tablodan veri çekerken
    // [!] aynı sütun adına sahip olabilecek sütunlar için {alias} (takma ad) kullanırız. [ör: {id} çakışmaları...]
    // FROM numberOfBooks AS nb // nb.id AS numberOfBook_id,

    final Writer? actualWriter = json['writer_id'] != null
        ? Writer(id: json['writer_id'] as int?, name: json['writer_name'] as String? ?? 'Bilinmeyen Yazar')
        : null;

    final Book actualBook = Book(
      id: json['book_id'] as int?,
      name: json['book_name'] as String? ?? 'Bilinmeyen Kitap',
      writer: actualWriter,
      numberOfPages: json['book_numberOfPages'] as int?,
    );

    // [?] Neden {type_casting} yapiliyor ???
    return NumberOfBook(
      id: json['numberOfBook_id'] as int?,
      number: json['numberOfBook_number'] as int? ?? 0,
      book: actualBook,
      libraryId: json['libraryId'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'number': number, 'bookId': book.id, 'libraryId': libraryId};
  }

  static final createTable = """
    CREATE TABLE numberOfBooks (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      number INTEGER,
      bookId INTEGER,
      libraryId INTEGER,
      FOREIGN KEY (bookId) REFERENCES books (id) ON DELETE CASCADE,
      FOREIGN KEY (libraryId) REFERENCES libraries (id) ON DELETE CASCADE)
  """;
}
