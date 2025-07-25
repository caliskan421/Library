import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';

import '../../core/database/db_helper.dart';
import '../../core/repository/book_repository.dart';
import '../../core/repository/library_repository.dart';
import '../../core/repository/number_of_book_repository.dart';
import '../../model/book.dart';
import '../../model/library.dart';
import '../../model/number_of_book.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView>
    with SingleTickerProviderStateMixin {
  late Database _database;
  late BookRepository _bookRepository;
  late LibraryRepository _libraryRepository;
  late NumberOfBookRepository _numberOfBookRepository;

  String _statusMessage = 'Uygulama Hazırlanıyor...';
  List<Library> _librariesWithBooks = [];
  List<Book> _allBooks = [];
  List<NumberOfBook> _allNumberOfBooks = [];

  late TabController _tabController;

  // Form controllers
  final _bookNameController = TextEditingController();
  final _bookWriterController = TextEditingController();
  final _bookPagesController = TextEditingController();

  final _libraryNameController = TextEditingController();
  final _libraryLocationController = TextEditingController();

  final _bookCountController = TextEditingController();

  Book? _selectedBookForLibrary;
  Library? _selectedLibraryForBook;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _initializeDatabaseAndRepositories();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _bookNameController.dispose();
    _bookWriterController.dispose();
    _bookPagesController.dispose();
    _libraryNameController.dispose();
    _libraryLocationController.dispose();
    _bookCountController.dispose();
    super.dispose();
  }

  Future<void> _initializeDatabaseAndRepositories() async {
    try {
      _updateStatus('Veritabanı bağlantısı kuruluyor...');
      _database = await DBHelper().database;
      _bookRepository = BookRepository(_database);
      _libraryRepository = LibraryRepository(_database);
      _numberOfBookRepository = NumberOfBookRepository(_database);
      _updateStatus('Veritabanı hazır.');
      await _loadAllData();
    } catch (e) {
      _updateStatus('Hata oluştu: ${e.toString()}');
    }
  }

  void _updateStatus(String message) {
    setState(() {
      _statusMessage = message;
    });

    // Terminal'e de yazdır
    print('🔔 STATUS: $message');
  }

  Future<void> _loadAllData() async {
    if (!_isDatabaseReady()) {
      _updateStatus('Veritabanı henüz hazır değil...');
      return;
    }

    _updateStatus('Veriler yükleniyor...');
    try {
      final allLibraries = await _libraryRepository.getAll();
      List<Library> librariesWithDetails = [];

      for (var lib in allLibraries) {
        final detailedLibrary = await _libraryRepository.getLibraryWithBooks(
          lib.id!,
        );
        if (detailedLibrary != null) {
          librariesWithDetails.add(detailedLibrary);
        }
      }

      final allBooks = await _bookRepository.getAll();
      final allNumberOfBooks = await _numberOfBookRepository.getAll();

      setState(() {
        _librariesWithBooks = librariesWithDetails;
        _allBooks = allBooks;
        _allNumberOfBooks = allNumberOfBooks;
      });

      _updateStatus(
        'Veriler yüklendi. ${allLibraries.length} kütüphane, ${allBooks.length} kitap',
      );
      _printAllDataToTerminal();
    } catch (e) {
      _updateStatus('Veri yüklenirken hata oluştu: ${e.toString()}');
    }
  }

  // Terminal Debug Fonksiyonları
  void _printAllDataToTerminal() {
    print('\n${'=' * 60}');
    print('📚 VERİTABANI DURUMU - ${DateTime.now()}');
    print('=' * 60);

    print('\n📖 BOOKS (${_allBooks.length} adet):');
    print('-' * 40);
    for (var book in _allBooks) {
      print(
        'ID: ${book.id} | ${book.name} - ${book.writer} (${book.numberOfPages} sayfa)',
      );
    }

    print('\n🏛️ LIBRARIES (${_librariesWithBooks.length} adet):');
    print('-' * 40);
    for (var library in _librariesWithBooks) {
      print('ID: ${library.id} | ${library.name} - ${library.location}');
      for (var bookCount in library.numberOfBook) {
        if (bookCount != null) {
          print('  └─ ${bookCount.book.name}: ${bookCount.number} adet');
        }
      }
    }

    print(
      '\n🔗 NUMBER_OF_BOOKS İLİŞKİLERİ (${_allNumberOfBooks.length} adet):',
    );
    print('-' * 40);
    for (var numberBook in _allNumberOfBooks) {
      print(
        'ID: ${numberBook.id} | Kitap: ${numberBook.book.name} | Kütüphane ID: ${numberBook.libraryId} | Sayı: ${numberBook.number}',
      );
    }

    print('\n${'=' * 60}\n');
  }

  bool _isDatabaseReady() {
    try {
      // Late değişkenlerin başlatılıp başlatılmadığını kontrol et
      var db = _database;
      var bookRepo = _bookRepository;
      var libraryRepo = _libraryRepository;
      var numberRepo = _numberOfBookRepository;
      return bookRepo != null;
    } catch (e) {
      // LateInitializationError veya başka bir hata varsa false döndür
      return false;
    }
  }

  Future<void> _addBook() async {
    if (_bookNameController.text.isEmpty ||
        _bookWriterController.text.isEmpty) {
      _updateStatus('Kitap adı ve yazar bilgisi gerekli!');
      return;
    }

    if (!_isDatabaseReady()) {
      _updateStatus('Veritabanı henüz hazır değil, lütfen bekleyin...');
      return;
    }

    try {
      final book = Book(
        name: _bookNameController.text,
        writer: _bookWriterController.text,
        numberOfPages: int.tryParse(_bookPagesController.text),
      );

      final id = await _bookRepository.insert(book);
      _updateStatus('Kitap eklendi! ID: $id');

      _bookNameController.clear();
      _bookWriterController.clear();
      _bookPagesController.clear();

      await _loadAllData();
    } catch (e) {
      _updateStatus('Kitap eklenirken hata oluştu: ${e.toString()}');
    }
  }

  Future<void> _addLibrary() async {
    if (_libraryNameController.text.isEmpty ||
        _libraryLocationController.text.isEmpty) {
      _updateStatus('Kütüphane adı ve konum bilgisi gerekli!');
      return;
    }

    if (!_isDatabaseReady()) {
      _updateStatus('Veritabanı henüz hazır değil, lütfen bekleyin...');
      return;
    }

    try {
      final library = Library(
        name: _libraryNameController.text,
        location: _libraryLocationController.text,
      );

      final id = await _libraryRepository.insert(library);
      _updateStatus('Kütüphane eklendi! ID: $id');

      _libraryNameController.clear();
      _libraryLocationController.clear();

      await _loadAllData();
    } catch (e) {
      _updateStatus('Kütüphane eklenirken hata oluştu: ${e.toString()}');
    }
  }

  Future<void> _addBookToLibrary() async {
    if (_selectedBookForLibrary == null || _selectedLibraryForBook == null) {
      _updateStatus('Kitap ve kütüphane seçimi gerekli!');
      return;
    }

    if (_bookCountController.text.isEmpty) {
      _updateStatus('Kitap sayısı girilmeli!');
      return;
    }

    if (!_isDatabaseReady()) {
      _updateStatus('Veritabanı henüz hazır değil, lütfen bekleyin...');
      return;
    }

    try {
      final count = int.parse(_bookCountController.text);
      final numberOfBook = NumberOfBook(
        book: _selectedBookForLibrary!,
        number: count,
        libraryId: _selectedLibraryForBook!.id,
      );

      final id = await _numberOfBookRepository.insert(numberOfBook);
      _updateStatus('Kitap kütüphaneye eklendi! ID: $id');

      _bookCountController.clear();
      _selectedBookForLibrary = null;
      _selectedLibraryForBook = null;

      await _loadAllData();
    } catch (e) {
      _updateStatus(
        'Kitap kütüphaneye eklenirken hata oluştu: ${e.toString()}',
      );
    }
  }

  Future<void> _addSampleData() async {
    if (!_isDatabaseReady()) {
      _updateStatus('Veritabanı henüz hazır değil, lütfen bekleyin...');
      return;
    }

    _updateStatus('Örnek veri ekleniyor...');
    try {
      // Önceki verileri temizle
      await _numberOfBookRepository.deleteAll();
      await _bookRepository.deleteAll();
      await _libraryRepository.deleteAll();

      // Kitap Ekle
      final book1 = Book(
        name: 'Sefiller',
        writer: 'Victor Hugo',
        numberOfPages: 1400,
      );
      final book2 = Book(
        name: 'Suç ve Ceza',
        writer: 'Dostoyevski',
        numberOfPages: 700,
      );
      final book3 = Book(
        name: 'Kürk Mantolu Madonna',
        writer: 'Sabahattin Ali',
        numberOfPages: 250,
      );

      final int book1Id = await _bookRepository.insert(book1);
      final int book2Id = await _bookRepository.insert(book2);
      final int book3Id = await _bookRepository.insert(book3);

      final insertedBook1 = book1.copyWith(id: book1Id);
      final insertedBook2 = book2.copyWith(id: book2Id);
      final insertedBook3 = book3.copyWith(id: book3Id);

      // Kütüphane Ekle
      final library1 = Library(
        name: 'Merkez Kütüphanesi',
        location: 'Şehir Merkezi',
      );
      final library2 = Library(
        name: 'Üniversite Kütüphanesi',
        location: 'Kampüs',
      );

      final int library1Id = await _libraryRepository.insert(library1);
      final int library2Id = await _libraryRepository.insert(library2);

      final insertedLibrary1 = library1.copyWith(id: library1Id);
      final insertedLibrary2 = library2.copyWith(id: library2Id);

      // Kütüphaneye Kitap Sayısı Ekle
      await _numberOfBookRepository.insert(
        NumberOfBook(
          book: insertedBook1,
          number: 5,
          libraryId: insertedLibrary1.id,
        ),
      );
      await _numberOfBookRepository.insert(
        NumberOfBook(
          book: insertedBook2,
          number: 3,
          libraryId: insertedLibrary1.id,
        ),
      );
      await _numberOfBookRepository.insert(
        NumberOfBook(
          book: insertedBook2,
          number: 2,
          libraryId: insertedLibrary2.id,
        ),
      );
      await _numberOfBookRepository.insert(
        NumberOfBook(
          book: insertedBook3,
          number: 8,
          libraryId: insertedLibrary2.id,
        ),
      );

      _updateStatus('Örnek veri başarıyla eklendi.');
      await _loadAllData();
    } catch (e) {
      _updateStatus('Örnek veri eklenirken hata oluştu: ${e.toString()}');
      print('Detaylı hata: $e');
    }
  }

  Future<void> _deleteAllData() async {
    if (!_isDatabaseReady()) {
      _updateStatus('Veritabanı henüz hazır değil, lütfen bekleyin...');
      return;
    }

    _updateStatus('Tüm veriler siliniyor...');
    try {
      await _numberOfBookRepository.deleteAll();
      await _bookRepository.deleteAll();
      await _libraryRepository.deleteAll();
      _updateStatus('Tüm veriler silindi.');
      await _loadAllData();
    } catch (e) {
      _updateStatus('Veri silerken hata oluştu: ${e.toString()}');
    }
  }

  Future<void> _deleteBook(Book book) async {
    if (!_isDatabaseReady()) {
      _updateStatus('Veritabanı henüz hazır değil, lütfen bekleyin...');
      return;
    }

    try {
      await _bookRepository.delete(book.id!);
      _updateStatus('Kitap silindi: ${book.name}');
      await _loadAllData();
    } catch (e) {
      _updateStatus('Kitap silinirken hata oluştu: ${e.toString()}');
    }
  }

  Future<void> _deleteLibrary(Library library) async {
    if (!_isDatabaseReady()) {
      _updateStatus('Veritabanı henüz hazır değil, lütfen bekleyin...');
      return;
    }

    try {
      await _libraryRepository.delete(library.id!);
      _updateStatus('Kütüphane silindi: ${library.name}');
      await _loadAllData();
    } catch (e) {
      _updateStatus('Kütüphane silinirken hata oluştu: ${e.toString()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Library Test System'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.add), text: 'Veri Ekle'),
            Tab(icon: Icon(Icons.list), text: 'Görüntüle'),
            Tab(icon: Icon(Icons.link), text: 'İlişki Kur'),
            Tab(icon: Icon(Icons.settings), text: 'Test'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Status Bar
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            color: Colors.blue.shade50,
            child: Text(
              _statusMessage,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.blue.shade800,
              ),
            ),
          ),

          // Tab Views
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildAddDataTab(),
                _buildViewDataTab(),
                _buildRelationshipTab(),
                _buildTestTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddDataTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Kitap Ekleme
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '📖 Kitap Ekle',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _bookNameController,
                    decoration: const InputDecoration(
                      labelText: 'Kitap Adı',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _bookWriterController,
                    decoration: const InputDecoration(
                      labelText: 'Yazar',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _bookPagesController,
                    decoration: const InputDecoration(
                      labelText: 'Sayfa Sayısı (opsiyonel)',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: _addBook,
                    child: const Text('Kitap Ekle'),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Kütüphane Ekleme
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '🏛️ Kütüphane Ekle',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _libraryNameController,
                    decoration: const InputDecoration(
                      labelText: 'Kütüphane Adı',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _libraryLocationController,
                    decoration: const InputDecoration(
                      labelText: 'Konum',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: _addLibrary,
                    child: const Text('Kütüphane Ekle'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildViewDataTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Kitaplar
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '📖 Kitaplar (${_allBooks.length})',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),
                  if (_allBooks.isEmpty)
                    const Text('Henüz kitap eklenmemiş.')
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _allBooks.length,
                      itemBuilder: (context, index) {
                        final book = _allBooks[index];
                        return ListTile(
                          title: Text(book.name),
                          subtitle: Text(
                            '${book.writer} - ${book.numberOfPages ?? 'Bilinmiyor'} sayfa',
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteBook(book),
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Kütüphaneler
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '🏛️ Kütüphaneler (${_librariesWithBooks.length})',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),
                  if (_librariesWithBooks.isEmpty)
                    const Text('Henüz kütüphane eklenmemiş.')
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _librariesWithBooks.length,
                      itemBuilder: (context, index) {
                        final library = _librariesWithBooks[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            library.name,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(library.location),
                                        ],
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.delete,
                                        color: Colors.red,
                                      ),
                                      onPressed: () => _deleteLibrary(library),
                                    ),
                                  ],
                                ),
                                if (library.numberOfBook.isNotEmpty) ...[
                                  const SizedBox(height: 8),
                                  const Text(
                                    'Kitaplar:',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  ...library.numberOfBook.map((bookCount) {
                                    if (bookCount == null)
                                      return const SizedBox.shrink();
                                    return Padding(
                                      padding: const EdgeInsets.only(
                                        left: 16,
                                        top: 4,
                                      ),
                                      child: Text(
                                        '• ${bookCount.book.name}: ${bookCount.number} adet',
                                      ),
                                    );
                                  }),
                                ],
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRelationshipTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '🔗 Kitap - Kütüphane İlişkisi Kur',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),

                  // Kitap Seçimi
                  const Text(
                    'Kitap Seç:',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<Book>(
                    value: _selectedBookForLibrary,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                    hint: const Text('Kitap seçin...'),
                    items: _allBooks.map((book) {
                      return DropdownMenuItem<Book>(
                        value: book,
                        child: Text('${book.name} - ${book.writer}'),
                      );
                    }).toList(),
                    onChanged: (Book? value) {
                      setState(() {
                        _selectedBookForLibrary = value;
                      });
                    },
                  ),

                  const SizedBox(height: 16),

                  // Kütüphane Seçimi
                  const Text(
                    'Kütüphane Seç:',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<Library>(
                    value: _selectedLibraryForBook,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                    hint: const Text('Kütüphane seçin...'),
                    items: _librariesWithBooks.map((library) {
                      return DropdownMenuItem<Library>(
                        value: library,
                        child: Text('${library.name} - ${library.location}'),
                      );
                    }).toList(),
                    onChanged: (Library? value) {
                      setState(() {
                        _selectedLibraryForBook = value;
                      });
                    },
                  ),

                  const SizedBox(height: 16),

                  // Kitap Sayısı
                  const Text(
                    'Kitap Sayısı:',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _bookCountController,
                    decoration: const InputDecoration(
                      labelText: 'Kaç adet kitap var?',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),

                  const SizedBox(height: 16),

                  ElevatedButton(
                    onPressed: _addBookToLibrary,
                    child: const Text('İlişki Kur'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTestTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    '🧪 Test Araçları',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),

                  ElevatedButton.icon(
                    onPressed: _addSampleData,
                    icon: const Icon(Icons.add_circle),
                    label: const Text('Örnek Veri Ekle'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 8),

                  ElevatedButton.icon(
                    onPressed: _deleteAllData,
                    icon: const Icon(Icons.delete_forever),
                    label: const Text('Tüm Verileri Sil'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 8),

                  ElevatedButton.icon(
                    onPressed: _loadAllData,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Verileri Yenile'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 8),

                  ElevatedButton.icon(
                    onPressed: _printAllDataToTerminal,
                    icon: const Icon(Icons.terminal),
                    label: const Text('Terminal\'e Yazdır'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '📊 İstatistikler',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),
                  Text('Toplam Kitap: ${_allBooks.length}'),
                  Text('Toplam Kütüphane: ${_librariesWithBooks.length}'),
                  Text('Toplam İlişki: ${_allNumberOfBooks.length}'),
                  Text(
                    'Son Güncelleme: ${DateTime.now().toString().substring(0, 19)}',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
