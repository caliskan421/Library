import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:go_router/go_router.dart';
import 'package:where_is_library/view/router.dart';

import '../../model/book.dart';
import '../../model/library.dart';
import '../../model/writer.dart';
import 'home_view_model.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> with SingleTickerProviderStateMixin {
  late final HomeViewModel _viewModel = HomeViewModel();
  late final TabController _tabController = TabController(length: 4, vsync: this);

  @override
  void initState() {
    super.initState();
    _viewModel.init();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Library Test System'),
        actions: [
          IconButton(
            onPressed: () {
              context.pushNamed(RouteNames.map.name);
            },
            icon: Icon(Icons.location_on),
          ),
        ],
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
          Observer(
            builder: (_) => Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              color: Colors.blue.shade50,
              child: Text(
                _viewModel.statusMessage,
                style: TextStyle(fontWeight: FontWeight.w500, color: Colors.blue.shade800),
              ),
            ),
          ),

          // Tab Views
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [_buildAddDataTab(), _buildViewDataTab(), _buildRelationshipTab(), _buildTestTab()],
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
          // Yazar Ekleme
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('✍️ Yazar Ekle', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _viewModel.writerNameController,
                    decoration: const InputDecoration(labelText: 'Yazar Adı', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(onPressed: _viewModel.addWriter, child: const Text('Yazar Ekle')),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Kitap Ekleme
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('📖 Kitap Ekle', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _viewModel.bookNameController,
                    decoration: const InputDecoration(labelText: 'Kitap Adı', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 8),

                  // Yazar Seçimi
                  const Text('Yazar Seç:', style: TextStyle(fontWeight: FontWeight.w500)),
                  const SizedBox(height: 8),
                  Observer(
                    builder: (_) => DropdownButtonFormField<Writer>(
                      value: _viewModel.selectedWriterForBook,
                      decoration: const InputDecoration(labelText: 'Yazar', border: OutlineInputBorder()),
                      hint: const Text('Yazar seçin...'),
                      items: _viewModel.allWriters.map((writer) {
                        return DropdownMenuItem<Writer>(value: writer, child: Text(writer.name));
                      }).toList(),
                      onChanged: _viewModel.setSelectedWriterForBook,
                    ),
                  ),

                  const SizedBox(height: 8),
                  TextField(
                    controller: _viewModel.bookPagesController,
                    decoration: const InputDecoration(labelText: 'Sayfa Sayısı (opsiyonel)', border: OutlineInputBorder()),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(onPressed: _viewModel.addBook, child: const Text('Kitap Ekle')),
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
                  Text('🏛️ Kütüphane Ekle', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _viewModel.libraryNameController,
                    decoration: const InputDecoration(labelText: 'Kütüphane Adı', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _viewModel.libraryLocationController,
                    decoration: const InputDecoration(labelText: 'Konum', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(onPressed: _viewModel.addLibrary, child: const Text('Kütüphane Ekle')),
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
          // Yazarlar
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Observer(builder: (_) => Text('✍️ Yazarlar (${_viewModel.allWriters.length})', style: Theme.of(context).textTheme.titleLarge)),
                  const SizedBox(height: 12),
                  Observer(
                    builder: (_) => _viewModel.allWriters.isEmpty
                        ? const Text('Henüz yazar eklenmemiş.')
                        : ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _viewModel.allWriters.length,
                            itemBuilder: (context, index) {
                              final writer = _viewModel.allWriters[index];
                              return ListTile(
                                title: Text(writer.name),
                                trailing: IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => _viewModel.deleteWriter(writer),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Kitaplar
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Observer(builder: (_) => Text('📖 Kitaplar (${_viewModel.allBooks.length})', style: Theme.of(context).textTheme.titleLarge)),
                  const SizedBox(height: 12),
                  Observer(
                    builder: (_) => _viewModel.allBooks.isEmpty
                        ? const Text('Henüz kitap eklenmemiş.')
                        : ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _viewModel.allBooks.length,
                            itemBuilder: (context, index) {
                              final book = _viewModel.allBooks[index];
                              final writerName = book.writer?.name ?? 'Bilinmeyen Yazar';
                              return ListTile(
                                title: Text(book.name),
                                subtitle: Text('$writerName - ${book.numberOfPages ?? 'Bilinmiyor'} sayfa'),
                                trailing: IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => _viewModel.deleteBook(book),
                                ),
                              );
                            },
                          ),
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
                  Observer(
                    builder: (_) => Text('🏛️ Kütüphaneler (${_viewModel.libraryWithBooks.length})', style: Theme.of(context).textTheme.titleLarge),
                  ),
                  const SizedBox(height: 12),
                  Observer(
                    builder: (_) => _viewModel.libraryWithBooks.isEmpty
                        ? const Text('Henüz kütüphane eklenmemiş.')
                        : ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _viewModel.libraryWithBooks.length,
                            itemBuilder: (context, index) {
                              final library = _viewModel.libraryWithBooks[index];
                              return Card(
                                margin: const EdgeInsets.only(bottom: 8),
                                child: Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(library.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                                                Text(library.location),
                                              ],
                                            ),
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.delete, color: Colors.red),
                                            onPressed: () => _viewModel.deleteLibrary(library),
                                          ),
                                        ],
                                      ),
                                      if (library.numberOfBook.isNotEmpty) ...[
                                        const SizedBox(height: 8),
                                        const Text('Kitaplar:', style: TextStyle(fontWeight: FontWeight.w500)),
                                        ...library.numberOfBook.map((bookCount) {
                                          if (bookCount == null) return const SizedBox.shrink();
                                          return Padding(
                                            padding: const EdgeInsets.only(left: 16, top: 4),
                                            child: Text('• ${bookCount.book.name}: ${bookCount.number} adet'),
                                          );
                                        }),
                                      ],
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
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
                  Text('🔗 Kitap - Kütüphane İlişkisi Kur', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 12),

                  // Kitap Seçimi
                  const Text('Kitap Seç:', style: TextStyle(fontWeight: FontWeight.w500)),
                  const SizedBox(height: 8),
                  Observer(
                    builder: (_) => DropdownButtonFormField<Book>(
                      value: _viewModel.selectedBookForLibrary,
                      decoration: const InputDecoration(border: OutlineInputBorder()),
                      hint: const Text('Kitap seçin...'),
                      items: _viewModel.allBooks.map((book) {
                        return DropdownMenuItem<Book>(value: book, child: Text('${book.name} - ${book.writer?.name ?? 'Bilinmeyen Yazar'}'));
                      }).toList(),
                      onChanged: _viewModel.setSelectedBookForLibrary,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Kütüphane Seçimi
                  const Text('Kütüphane Seç:', style: TextStyle(fontWeight: FontWeight.w500)),
                  const SizedBox(height: 8),
                  Observer(
                    builder: (_) => DropdownButtonFormField<Library>(
                      value: _viewModel.selectedLibraryForBook,
                      decoration: const InputDecoration(border: OutlineInputBorder()),
                      hint: const Text('Kütüphane seçin...'),
                      items: _viewModel.libraryWithBooks.map((library) {
                        return DropdownMenuItem<Library>(value: library, child: Text('${library.name} - ${library.location}'));
                      }).toList(),
                      onChanged: _viewModel.setSelectedLibraryForBook,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Kitap Sayısı
                  const Text('Kitap Sayısı:', style: TextStyle(fontWeight: FontWeight.w500)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _viewModel.bookCountController,
                    decoration: const InputDecoration(labelText: 'Kaç adet kitap var?', border: OutlineInputBorder()),
                    keyboardType: TextInputType.number,
                  ),

                  const SizedBox(height: 16),

                  ElevatedButton(onPressed: _viewModel.addBookToLibrary, child: const Text('İlişki Kur')),
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
                  Text('🧪 Test Araçları', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 16),

                  ElevatedButton.icon(
                    onPressed: _viewModel.addSampleData,
                    icon: const Icon(Icons.add_circle),
                    label: const Text('Örnek Veri Ekle'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                  ),

                  const SizedBox(height: 8),

                  ElevatedButton.icon(
                    onPressed: _viewModel.deleteAllData,
                    icon: const Icon(Icons.delete_forever),
                    label: const Text('Tüm Verileri Sil'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                  ),

                  const SizedBox(height: 8),

                  ElevatedButton.icon(
                    onPressed: _viewModel.loadAllData,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Verileri Yenile'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white),
                  ),

                  const SizedBox(height: 8),

                  ElevatedButton.icon(
                    onPressed: _viewModel.printAllDataToTerminal,
                    icon: const Icon(Icons.terminal),
                    label: const Text('Terminal\'e Yazdır'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.purple, foregroundColor: Colors.white),
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
                  Text('📊 İstatistikler', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 12),
                  Observer(
                    builder: (_) => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Toplam Yazar: ${_viewModel.allWriters.length}'),
                        Text('Toplam Kitap: ${_viewModel.allBooks.length}'),
                        Text('Toplam Kütüphane: ${_viewModel.libraryWithBooks.length}'),
                        Text('Toplam İlişki: ${_viewModel.allNumberOfBooks.length}'),
                        Text('Son Güncelleme: ${DateTime.now().toString().substring(0, 19)}'),
                      ],
                    ),
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
