// number_of_book.dart
import 'book.dart';

class NumberOfBook {
  final int? id;
  int number;
  final Book book;
  final int? libraryId; // Yeni eklendi!

  NumberOfBook({
    this.id,
    this.number = 0,
    required this.book,
    this.libraryId,
  }); // Constructor güncellendi

  NumberOfBook copyWith({int? id, int? number, Book? book, int? libraryId}) {
    return NumberOfBook(
      id: id ?? this.id,
      number: number ?? this.number,
      book: book ?? this.book,
      libraryId: libraryId ?? this.libraryId,
    );
  }

  factory NumberOfBook.fromJsonWithBook(Map<String, dynamic> json) {
    final Book actualBook = Book(
      id: json['book_id'] as int?,
      name: json['book_name'] as String,
      writer: json['book_writer'] as String,
      numberOfPages: json['book_numberOfPages'] as int?,
    );

    return NumberOfBook(
      id: json['numberOfBook_id'] as int?,
      number: json['numberOfBook_number'] as int? ?? 0,
      book: actualBook,
      libraryId: json['libraryId'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'number': number,
      'bookId': book.id,
      'libraryId': libraryId, // toJson'a libraryId eklendi!
    };
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
