class Book {
  final String name; // [!] nullable -> db'ye kaydetmeden önce oluşturacağımız nesnede null iken db içinde atanacak
  final int? id;
  final String writer;
  final int? numberOfPages;

  Book({this.id, required this.name, required this.writer, this.numberOfPages});

  factory Book.fromJson(Map<String, dynamic> map) {
    return Book(id: map['id'], name: map['name'], writer: map['writer'], numberOfPages: map['numberOfPages']);
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'writer': writer, 'numberOfPages': numberOfPages};
  }

  static final createTable = """"
    CREATE TABLE books (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT,
      writer TEXT,
      numberOfPages INTEGER)
  """;
}
