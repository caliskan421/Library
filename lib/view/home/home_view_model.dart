import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:mobx/mobx.dart';

import '../../core/repository/book_repository.dart';
import '../../core/repository/library_repository.dart';
import '../../core/repository/number_of_book_repository.dart';
import '../../core/repository/writer_repository.dart';
import '../../model/book.dart';
import '../../model/library.dart';
import '../../model/number_of_book.dart';
import '../../model/writer.dart';
import '../../service/service_helper.dart';

part 'home_view_model.g.dart';

class HomeViewModel = _HomeViewModel with _$HomeViewModel;

abstract class _HomeViewModel with Store {
  // Service locator'dan alınacak servisler
  late BookRepository _bookRepository;
  late LibraryRepository _libraryRepository;
  late NumberOfBookRepository _numberOfBookRepository;
  late WriterRepository _writerRepository;

  @observable
  String statusMessage = 'Uygulama Hazırlanıyor...';

  // --> Library sinifi icerisinde, bos liste olarak tanimlanmis [numberOfBook] parametresi dolu gelir
  @observable
  ObservableList<Library> libraryWithBooks = ObservableList<Library>();

  @observable
  ObservableList<Book> allBooks = ObservableList<Book>();

  @observable
  ObservableList<NumberOfBook> allNumberOfBooks = ObservableList<NumberOfBook>();

  @observable
  ObservableList<Writer> allWriters = ObservableList<Writer>();

  // --> İlişkilendirme için
  @observable
  Book? selectedBookForLibrary;

  // --> İlişkilendirme için
  @observable
  Library? selectedLibraryForBook;

  // --> Kitap ekleme için yazar seçimi
  @observable
  Writer? selectedWriterForBook;

  // T E X T - C O N T R O L L E R S ...
  final bookNameController = TextEditingController();
  final bookWriterController = TextEditingController();
  final bookPagesController = TextEditingController();
  final libraryNameController = TextEditingController();
  final libraryLocationController = TextEditingController();
  final bookCountController = TextEditingController();
  final writerNameController = TextEditingController();

  @action
  void init() {
    _initializeDatabaseAndRepositories();
  }

  void dispose() {
    bookNameController.dispose();
    bookWriterController.dispose();
    bookPagesController.dispose();
    libraryNameController.dispose();
    libraryLocationController.dispose();
    bookCountController.dispose();
    writerNameController.dispose();
  }

  @action
  Future<void> _initializeDatabaseAndRepositories() async {
    try {
      updateStatus('Servisler hazırlanıyor...');

      // --> Service locator'dan repository'leri al
      _bookRepository = await ServiceHelper.bookRepository;
      _libraryRepository = await ServiceHelper.libraryRepository;
      _numberOfBookRepository = await ServiceHelper.numberOfBookRepository;
      _writerRepository = await ServiceHelper.writerRepository;

      updateStatus('Servisler hazır.');
      await loadAllData();
    } catch (e) {
      updateStatus('Servis başlatılırken hata oluştu: ${e.toString()}');
    }
  }

  @action
  void updateStatus(String message) {
    statusMessage = message;
    log('🔔 STATUS: $message');
  }

  @action
  Future<void> loadAllData() async {
    updateStatus('Veriler yükleniyor...');
    try {
      final allLibrariesData = await _libraryRepository.getAll(); // --> Library: NumberOfBook {not appointed}
      List<Library> librariesWithDetails = []; // --> Library: NumberOfBook {appointed}

      for (var lib in allLibrariesData) {
        final detailedLibrary = await _libraryRepository.getLibraryWithBooks(lib.id!);
        if (detailedLibrary != null) {
          librariesWithDetails.add(detailedLibrary);
        }
      }

      final allBooksData = await _bookRepository.getAll();
      final allNumberOfBooksData = await _numberOfBookRepository.getAll();
      final allWritersData = await _writerRepository.getAll();

      libraryWithBooks.clear();
      libraryWithBooks.addAll(librariesWithDetails); // --> veriler [observable_list]'e atanir

      allBooks.clear();
      allBooks.addAll(allBooksData); // --> veriler [observable_list]'e atanir

      allNumberOfBooks.clear();
      allNumberOfBooks.addAll(allNumberOfBooksData); // --> veriler [observable_list]'e atanir

      allWriters.clear();
      allWriters.addAll(allWritersData); // --> veriler [observable_list]'e atanir

      updateStatus('Veriler yüklendi. ${allLibrariesData.length} kütüphane, ${allBooksData.length} kitap, ${allWritersData.length} yazar');
      printAllDataToTerminal();
    } catch (e) {
      updateStatus('Veri yüklenirken hata oluştu: ${e.toString()}');
    }
  }

  // Todo: [INCELE...]
  @action
  void printAllDataToTerminal() {
    log('\n${'=' * 60}');
    log('📚 VERİTABANI DURUMU - ${DateTime.now()}');
    log('=' * 60);

    log('\n✍️ WRITERS (${allWriters.length} adet):');
    log('-' * 40);
    for (var writer in allWriters) {
      log('ID: ${writer.id} | ${writer.name}');
    }

    log('\n📖 BOOKS (${allBooks.length} adet):');
    log('-' * 40);
    for (var book in allBooks) {
      final writerName = book.writer?.name ?? 'Bilinmeyen Yazar';
      log('ID: ${book.id} | ${book.name} - $writerName (${book.numberOfPages} sayfa)');
    }

    log('\n🏛️ LIBRARIES (${libraryWithBooks.length} adet):');
    log('-' * 40);
    for (var library in libraryWithBooks) {
      log('ID: ${library.id} | ${library.name} - ${library.location}');
      for (var bookCount in library.numberOfBook) {
        if (bookCount != null) {
          log('  └─ ${bookCount.book.name}: ${bookCount.number} adet');
        }
      }
    }

    log('\n🔗 NUMBER_OF_BOOKS İLİŞKİLERİ (${allNumberOfBooks.length} adet):');
    log('-' * 40);
    for (var numberBook in allNumberOfBooks) {
      log('ID: ${numberBook.id} | Kitap: ${numberBook.book.name} | Kütüphane ID: ${numberBook.libraryId} | Sayı: ${numberBook.number}');
    }

    log('\n${'=' * 60}\n');
  }

  @action
  Future<void> addWriter() async {
    if (writerNameController.text.isEmpty) {
      updateStatus('Yazar adı gerekli!');
      return;
    }

    try {
      // --> Aynı isimde yazar var mı kontrol et
      final existingWriter = await _writerRepository.getByName(writerNameController.text);
      if (existingWriter != null) {
        updateStatus('Bu isimde bir yazar zaten mevcut!');
        return;
      }

      final writer = Writer(name: writerNameController.text);
      final id = await _writerRepository.insert(writer);
      updateStatus('Yazar eklendi! ID: $id');

      writerNameController.clear();
      await loadAllData();
    } catch (e) {
      updateStatus('Yazar eklenirken hata oluştu: ${e.toString()}');
    }
  }

  @action
  Future<void> addBook() async {
    if (bookNameController.text.isEmpty || selectedWriterForBook == null) {
      updateStatus('Kitap adı ve yazar seçimi gerekli!');
      return;
    }

    try {
      final book = Book(
        name: bookNameController.text,
        writer: selectedWriterForBook,
        writerId: selectedWriterForBook!.id,
        numberOfPages: int.tryParse(bookPagesController.text),
      );

      final id = await _bookRepository.insert(book);
      updateStatus('Kitap eklendi! ID: $id');

      bookNameController.clear();
      bookPagesController.clear();
      selectedWriterForBook = null;

      await loadAllData();
    } catch (e) {
      updateStatus('Kitap eklenirken hata oluştu: ${e.toString()}');
    }
  }

  @action
  Future<void> addLibrary() async {
    if (libraryNameController.text.isEmpty || libraryLocationController.text.isEmpty) {
      updateStatus('Kütüphane adı ve konum bilgisi gerekli!');
      return;
    }

    try {
      final library = Library(name: libraryNameController.text, location: libraryLocationController.text);

      final id = await _libraryRepository.insert(library);
      updateStatus('Kütüphane eklendi! ID: $id');

      libraryNameController.clear();
      libraryLocationController.clear();

      await loadAllData();
    } catch (e) {
      updateStatus('Kütüphane eklenirken hata oluştu: ${e.toString()}');
    }
  }

  @action
  Future<void> addBookToLibrary() async {
    if (selectedBookForLibrary == null || selectedLibraryForBook == null) {
      updateStatus('Kitap ve kütüphane seçimi gerekli!');
      return;
    }

    if (bookCountController.text.isEmpty) {
      updateStatus('Kitap sayısı girilmeli!');
      return;
    }

    try {
      final count = int.parse(bookCountController.text);
      final numberOfBook = NumberOfBook(book: selectedBookForLibrary!, number: count, libraryId: selectedLibraryForBook!.id);

      final id = await _numberOfBookRepository.insert(numberOfBook);
      updateStatus('Kitap kütüphaneye eklendi! ID: $id');

      bookCountController.clear();
      selectedBookForLibrary = null;
      selectedLibraryForBook = null;

      await loadAllData();
    } catch (e) {
      updateStatus('Kitap kütüphaneye eklenirken hata oluştu: ${e.toString()}');
    }
  }

  @action
  void setSelectedBookForLibrary(Book? book) {
    selectedBookForLibrary = book;
  }

  @action
  void setSelectedLibraryForBook(Library? library) {
    selectedLibraryForBook = library;
  }

  @action
  void setSelectedWriterForBook(Writer? writer) {
    selectedWriterForBook = writer;
  }

  @action
  Future<void> addSampleData() async {
    updateStatus('Örnek veri ekleniyor...');
    try {
      await _numberOfBookRepository.deleteAll();
      await _bookRepository.deleteAll();
      await _libraryRepository.deleteAll();
      await _writerRepository.deleteAll();
      await loadAllData();
    } catch (e) {
      updateStatus('Örnek veri eklenirken hata oluştu: ${e.toString()}');
      log('Detaylı hata: $e');
    }
  }

  @action
  Future<void> deleteAllData() async {
    updateStatus('Tüm veriler siliniyor...');
    try {
      await _numberOfBookRepository.deleteAll();
      await _bookRepository.deleteAll();
      await _libraryRepository.deleteAll();
      await _writerRepository.deleteAll();
      updateStatus('Tüm veriler silindi.');
      await loadAllData();
    } catch (e) {
      updateStatus('Veri silerken hata oluştu: ${e.toString()}');
    }
  }

  @action
  Future<void> deleteBook(Book book) async {
    try {
      await _bookRepository.delete(book.id!);
      updateStatus('Kitap silindi: ${book.name}');
      await loadAllData();
    } catch (e) {
      updateStatus('Kitap silinirken hata oluştu: ${e.toString()}');
    }
  }

  @action
  Future<void> deleteLibrary(Library library) async {
    try {
      await _libraryRepository.delete(library.id!);
      updateStatus('Kütüphane silindi: ${library.name}');
      await loadAllData();
    } catch (e) {
      updateStatus('Kütüphane silinirken hata oluştu: ${e.toString()}');
    }
  }

  @action
  Future<void> deleteWriter(Writer writer) async {
    try {
      await _writerRepository.delete(writer.id!);
      updateStatus('Yazar silindi: ${writer.name}');
      await loadAllData();
    } catch (e) {
      updateStatus('Yazar silinirken hata oluştu: ${e.toString()}');
    }
  }
}
