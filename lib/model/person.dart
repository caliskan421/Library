import 'book.dart';

class Person {
  final int? id;
  final String name;
  final String? location;
  final List<Book?> ownedBooks;

  Person(this.location, this.ownedBooks, {required this.id, required this.name});
}
