// NumberOfBook.dart
import 'book.dart';

class NumberOfBook {
  final int? id;
  int number;
  final Book book; // Bu Book nesnesi, veri tabanından çekilirken dışarıdan atanacak

  NumberOfBook({this.id, this.number = 0, required this.book});

  // Bu fromJson metodu, 'numberOfBooks' ve 'books' tablolarının JOIN edilmesiyle
  // oluşan TEK BİR HARİTADAN veri almak için tasarlanmıştır.
  // Bu harita hem numberOfBook hem de book bilgilerini içerecektir.
  factory NumberOfBook.fromJsonWithBook(Map<String, dynamic> json) {
    // Kitap bilgileri doğrudan haritada bulunuyor
    final Book actualBook = Book(
      id: json['book_id'] as int?, // JOIN ile gelen book ID'si
      name: json['book_name'] as String, // JOIN ile gelen book adı
      writer: json['book_writer'] as String, // JOIN ile gelen book yazarı
      numberOfPages: json['book_numberOfPages'] as int?, // JOIN ile gelen sayfa sayısı
    );

    return NumberOfBook(
      id: json['numberOfBook_id'] as int?, // JOIN ile gelen numberOfBook ID'si
      number: json['numberOfBook_number'] as int? ?? 0, // JOIN ile gelen sayı adedi
      book: actualBook,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'number': number,
      'bookId': book.id, // Sadece Book'un ID'sini kaydet
      // libraryId, bu nesnenin bir parçası olarak kaydedilmez,
      // NumberOfBook'un Library ile ilişkisini kurarken dışarıdan verilir.
    };
  }

  static final createTable = """
    CREATE TABLE numberOfBooks (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      number INTEGER,
      bookId INTEGER,
      libraryId INTEGER,
      FOREIGN KEY (bookId) REFERENCES books (id),
      FOREIGN KEY (libraryId) REFERENCES libraries (id))
  """;
}
