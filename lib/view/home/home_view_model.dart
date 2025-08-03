import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:mobx/mobx.dart';

import '../../core/repository/book_repository.dart';
import '../../core/repository/library_repository.dart';
import '../../core/repository/library_location_repository.dart';
import '../../core/repository/number_of_book_repository.dart';
import '../../core/repository/writer_repository.dart';
import '../../model/book.dart';
import '../../model/library.dart';
import '../../model/library_location.dart';
import '../../model/number_of_book.dart';
import '../../model/writer.dart';
import '../../service/service_helper.dart';

part 'home_view_model.g.dart';

class HomeViewModel = _HomeViewModel with _$HomeViewModel;

abstract class _HomeViewModel with Store {
  // Service locator'dan alınacak servisler
  late BookRepository _bookRepository;
  late LibraryRepository _libraryRepository;
  late LibraryLocationRepository _libraryLocationRepository;
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

  @observable
  ObservableList<LibraryLocation> allLibraryLocations = ObservableList<LibraryLocation>();

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
  final locationTitleController = TextEditingController();
  final locationLatController = TextEditingController();
  final locationLongController = TextEditingController();
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
    locationTitleController.dispose();
    locationLatController.dispose();
    locationLongController.dispose();
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
      _libraryLocationRepository = await ServiceHelper.libraryLocationRepository;
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
      final allLibrariesData = await _libraryRepository.getAllWithLocations(); // --> Library: LocationInfo {appointed}
      List<Library> librariesWithDetails = []; // --> Library: NumberOfBook + LocationInfo {appointed}

      for (var lib in allLibrariesData) {
        final detailedLibrary = await _libraryRepository.getLibraryWithBooks(lib.id!);
        if (detailedLibrary != null) {
          librariesWithDetails.add(detailedLibrary);
        }
      }

      final allBooksData = await _bookRepository.getAll();
      final allNumberOfBooksData = await _numberOfBookRepository.getAll();
      final allWritersData = await _writerRepository.getAll();
      final allLibraryLocationsData = await _libraryLocationRepository.getAll();

      libraryWithBooks.clear();
      libraryWithBooks.addAll(librariesWithDetails); // --> veriler [observable_list]'e atanir

      allBooks.clear();
      allBooks.addAll(allBooksData); // --> veriler [observable_list]'e atanir

      allNumberOfBooks.clear();
      allNumberOfBooks.addAll(allNumberOfBooksData); // --> veriler [observable_list]'e atanir

      allWriters.clear();
      allWriters.addAll(allWritersData); // --> veriler [observable_list]'e atanir

      allLibraryLocations.clear();
      allLibraryLocations.addAll(allLibraryLocationsData); // --> veriler [observable_list]'e atanir

      updateStatus(
        'Veriler yüklendi. ${allLibrariesData.length} kütüphane, ${allBooksData.length} kitap, ${allWritersData.length} yazar, ${allLibraryLocationsData.length} konum',
      );
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
      log('ID: ${library.id} | ${library.name} - ${library.location?.title ?? "Konum bilinmiyor"}');
      for (var bookCount in library.numberOfBook) {
        if (bookCount != null) {
          log('  └─ ${bookCount.book.name}: ${bookCount.number} adet');
        }
      }
    }

    log('\n📍 LIBRARY_LOCATIONS (${allLibraryLocations.length} adet):');
    log('-' * 40);
    for (var location in allLibraryLocations) {
      log('ID: ${location.id} | ${location.title} - Enlem: ${location.lat}, Boylam: ${location.long}');
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
    if (libraryNameController.text.isEmpty ||
        locationTitleController.text.isEmpty ||
        locationLatController.text.isEmpty ||
        locationLongController.text.isEmpty) {
      updateStatus('Kütüphane adı ve konum bilgileri gerekli!');
      return;
    }

    try {
      // Lat ve Long değerlerini integer'a dönüştür
      final lat = double.tryParse(locationLatController.text);
      final long = double.tryParse(locationLongController.text);

      if (lat == null || long == null) {
        updateStatus('Enlem ve Boylam değerleri sayı olmalı!');
        return;
      }

      // Önce LibraryLocation oluştur
      final libraryLocation = LibraryLocation(title: locationTitleController.text, lat: lat, long: long);

      final locationId = await _libraryLocationRepository.insert(libraryLocation);
      updateStatus('Konum eklendi! ID: $locationId');

      // Sonra Library oluştur
      final library = Library(name: libraryNameController.text, locationId: locationId);

      final libraryId = await _libraryRepository.insert(library);
      updateStatus('Kütüphane eklendi! ID: $libraryId');

      // Controller'ları temizle
      libraryNameController.clear();
      locationTitleController.clear();
      locationLatController.clear();
      locationLongController.clear();

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
      // Önce mevcut verileri temizle
      await _numberOfBookRepository.deleteAll();
      await _bookRepository.deleteAll();
      await _libraryRepository.deleteAll();
      await _libraryLocationRepository.deleteAll();
      await _writerRepository.deleteAll();

      // Örnek yazarlar ekle
      final writer1 = Writer(name: 'Orhan Pamuk');
      final writer2 = Writer(name: 'Elif Şafak');
      final writer3 = Writer(name: 'Yaşar Kemal');

      final writerId1 = await _writerRepository.insert(writer1);
      final writerId2 = await _writerRepository.insert(writer2);
      final writerId3 = await _writerRepository.insert(writer3);

      // Örnek konum bilgileri ekle
      final location1 = LibraryLocation(title: 'Beşiktaş Merkez Kütüphanesi', lat: 41040000, long: 29000000);
      final location2 = LibraryLocation(title: 'Kadıköy Şubesi', lat: 40980000, long: 29030000);
      final location3 = LibraryLocation(title: 'Sultanahmet Tarihi Kütüphanesi', lat: 41010000, long: 28980000);

      final locationId1 = await _libraryLocationRepository.insert(location1);
      final locationId2 = await _libraryLocationRepository.insert(location2);
      final locationId3 = await _libraryLocationRepository.insert(location3);

      // Örnek kütüphaneler ekle
      final library1 = Library(name: 'Beşiktaş Halk Kütüphanesi', locationId: locationId1);
      final library2 = Library(name: 'Kadıköy Çok Amaçlı Kütüphane', locationId: locationId2);
      final library3 = Library(name: 'Sultanahmet Araştırma Merkezi', locationId: locationId3);

      final libraryId1 = await _libraryRepository.insert(library1);
      final libraryId2 = await _libraryRepository.insert(library2);
      final libraryId3 = await _libraryRepository.insert(library3);

      // Örnek kitaplar ekle
      final book1 = Book(name: 'Kar', writerId: writerId1, numberOfPages: 464);
      final book2 = Book(name: '10 Minutes 38 Seconds in This Strange World', writerId: writerId2, numberOfPages: 320);
      final book3 = Book(name: 'İnce Memed', writerId: writerId3, numberOfPages: 432);
      final book4 = Book(name: 'Masumiyet Müzesi', writerId: writerId1, numberOfPages: 592);

      await _bookRepository.insert(book1);
      await _bookRepository.insert(book2);
      await _bookRepository.insert(book3);
      await _bookRepository.insert(book4);

      // Kitap-Kütüphane ilişkileri ekle
      await _numberOfBookRepository.insert(NumberOfBook(book: book1, number: 5, libraryId: libraryId1));
      await _numberOfBookRepository.insert(NumberOfBook(book: book2, number: 3, libraryId: libraryId1));
      await _numberOfBookRepository.insert(NumberOfBook(book: book3, number: 7, libraryId: libraryId2));
      await _numberOfBookRepository.insert(NumberOfBook(book: book4, number: 2, libraryId: libraryId2));
      await _numberOfBookRepository.insert(NumberOfBook(book: book1, number: 4, libraryId: libraryId3));
      await _numberOfBookRepository.insert(NumberOfBook(book: book3, number: 6, libraryId: libraryId3));

      updateStatus('Örnek veriler başarıyla eklendi!');
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
      await _libraryLocationRepository.deleteAll();
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
