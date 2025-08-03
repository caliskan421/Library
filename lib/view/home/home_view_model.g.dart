// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'home_view_model.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$HomeViewModel on _HomeViewModel, Store {
  late final _$statusMessageAtom = Atom(
    name: '_HomeViewModel.statusMessage',
    context: context,
  );

  @override
  String get statusMessage {
    _$statusMessageAtom.reportRead();
    return super.statusMessage;
  }

  @override
  set statusMessage(String value) {
    _$statusMessageAtom.reportWrite(value, super.statusMessage, () {
      super.statusMessage = value;
    });
  }

  late final _$libraryWithBooksAtom = Atom(
    name: '_HomeViewModel.libraryWithBooks',
    context: context,
  );

  @override
  ObservableList<Library> get libraryWithBooks {
    _$libraryWithBooksAtom.reportRead();
    return super.libraryWithBooks;
  }

  @override
  set libraryWithBooks(ObservableList<Library> value) {
    _$libraryWithBooksAtom.reportWrite(value, super.libraryWithBooks, () {
      super.libraryWithBooks = value;
    });
  }

  late final _$allBooksAtom = Atom(
    name: '_HomeViewModel.allBooks',
    context: context,
  );

  @override
  ObservableList<Book> get allBooks {
    _$allBooksAtom.reportRead();
    return super.allBooks;
  }

  @override
  set allBooks(ObservableList<Book> value) {
    _$allBooksAtom.reportWrite(value, super.allBooks, () {
      super.allBooks = value;
    });
  }

  late final _$allNumberOfBooksAtom = Atom(
    name: '_HomeViewModel.allNumberOfBooks',
    context: context,
  );

  @override
  ObservableList<NumberOfBook> get allNumberOfBooks {
    _$allNumberOfBooksAtom.reportRead();
    return super.allNumberOfBooks;
  }

  @override
  set allNumberOfBooks(ObservableList<NumberOfBook> value) {
    _$allNumberOfBooksAtom.reportWrite(value, super.allNumberOfBooks, () {
      super.allNumberOfBooks = value;
    });
  }

  late final _$allWritersAtom = Atom(
    name: '_HomeViewModel.allWriters',
    context: context,
  );

  @override
  ObservableList<Writer> get allWriters {
    _$allWritersAtom.reportRead();
    return super.allWriters;
  }

  @override
  set allWriters(ObservableList<Writer> value) {
    _$allWritersAtom.reportWrite(value, super.allWriters, () {
      super.allWriters = value;
    });
  }

  late final _$selectedBookForLibraryAtom = Atom(
    name: '_HomeViewModel.selectedBookForLibrary',
    context: context,
  );

  @override
  Book? get selectedBookForLibrary {
    _$selectedBookForLibraryAtom.reportRead();
    return super.selectedBookForLibrary;
  }

  @override
  set selectedBookForLibrary(Book? value) {
    _$selectedBookForLibraryAtom.reportWrite(
      value,
      super.selectedBookForLibrary,
      () {
        super.selectedBookForLibrary = value;
      },
    );
  }

  late final _$selectedLibraryForBookAtom = Atom(
    name: '_HomeViewModel.selectedLibraryForBook',
    context: context,
  );

  @override
  Library? get selectedLibraryForBook {
    _$selectedLibraryForBookAtom.reportRead();
    return super.selectedLibraryForBook;
  }

  @override
  set selectedLibraryForBook(Library? value) {
    _$selectedLibraryForBookAtom.reportWrite(
      value,
      super.selectedLibraryForBook,
      () {
        super.selectedLibraryForBook = value;
      },
    );
  }

  late final _$selectedWriterForBookAtom = Atom(
    name: '_HomeViewModel.selectedWriterForBook',
    context: context,
  );

  @override
  Writer? get selectedWriterForBook {
    _$selectedWriterForBookAtom.reportRead();
    return super.selectedWriterForBook;
  }

  @override
  set selectedWriterForBook(Writer? value) {
    _$selectedWriterForBookAtom.reportWrite(
      value,
      super.selectedWriterForBook,
      () {
        super.selectedWriterForBook = value;
      },
    );
  }

  late final _$_initializeDatabaseAndRepositoriesAsyncAction = AsyncAction(
    '_HomeViewModel._initializeDatabaseAndRepositories',
    context: context,
  );

  @override
  Future<void> _initializeDatabaseAndRepositories() {
    return _$_initializeDatabaseAndRepositoriesAsyncAction.run(
      () => super._initializeDatabaseAndRepositories(),
    );
  }

  late final _$loadAllDataAsyncAction = AsyncAction(
    '_HomeViewModel.loadAllData',
    context: context,
  );

  @override
  Future<void> loadAllData() {
    return _$loadAllDataAsyncAction.run(() => super.loadAllData());
  }

  late final _$addWriterAsyncAction = AsyncAction(
    '_HomeViewModel.addWriter',
    context: context,
  );

  @override
  Future<void> addWriter() {
    return _$addWriterAsyncAction.run(() => super.addWriter());
  }

  late final _$addBookAsyncAction = AsyncAction(
    '_HomeViewModel.addBook',
    context: context,
  );

  @override
  Future<void> addBook() {
    return _$addBookAsyncAction.run(() => super.addBook());
  }

  late final _$addLibraryAsyncAction = AsyncAction(
    '_HomeViewModel.addLibrary',
    context: context,
  );

  @override
  Future<void> addLibrary() {
    return _$addLibraryAsyncAction.run(() => super.addLibrary());
  }

  late final _$addBookToLibraryAsyncAction = AsyncAction(
    '_HomeViewModel.addBookToLibrary',
    context: context,
  );

  @override
  Future<void> addBookToLibrary() {
    return _$addBookToLibraryAsyncAction.run(() => super.addBookToLibrary());
  }

  late final _$addSampleDataAsyncAction = AsyncAction(
    '_HomeViewModel.addSampleData',
    context: context,
  );

  @override
  Future<void> addSampleData() {
    return _$addSampleDataAsyncAction.run(() => super.addSampleData());
  }

  late final _$deleteAllDataAsyncAction = AsyncAction(
    '_HomeViewModel.deleteAllData',
    context: context,
  );

  @override
  Future<void> deleteAllData() {
    return _$deleteAllDataAsyncAction.run(() => super.deleteAllData());
  }

  late final _$deleteBookAsyncAction = AsyncAction(
    '_HomeViewModel.deleteBook',
    context: context,
  );

  @override
  Future<void> deleteBook(Book book) {
    return _$deleteBookAsyncAction.run(() => super.deleteBook(book));
  }

  late final _$deleteLibraryAsyncAction = AsyncAction(
    '_HomeViewModel.deleteLibrary',
    context: context,
  );

  @override
  Future<void> deleteLibrary(Library library) {
    return _$deleteLibraryAsyncAction.run(() => super.deleteLibrary(library));
  }

  late final _$deleteWriterAsyncAction = AsyncAction(
    '_HomeViewModel.deleteWriter',
    context: context,
  );

  @override
  Future<void> deleteWriter(Writer writer) {
    return _$deleteWriterAsyncAction.run(() => super.deleteWriter(writer));
  }

  late final _$_HomeViewModelActionController = ActionController(
    name: '_HomeViewModel',
    context: context,
  );

  @override
  void init() {
    final _$actionInfo = _$_HomeViewModelActionController.startAction(
      name: '_HomeViewModel.init',
    );
    try {
      return super.init();
    } finally {
      _$_HomeViewModelActionController.endAction(_$actionInfo);
    }
  }

  @override
  void updateStatus(String message) {
    final _$actionInfo = _$_HomeViewModelActionController.startAction(
      name: '_HomeViewModel.updateStatus',
    );
    try {
      return super.updateStatus(message);
    } finally {
      _$_HomeViewModelActionController.endAction(_$actionInfo);
    }
  }

  @override
  void printAllDataToTerminal() {
    final _$actionInfo = _$_HomeViewModelActionController.startAction(
      name: '_HomeViewModel.printAllDataToTerminal',
    );
    try {
      return super.printAllDataToTerminal();
    } finally {
      _$_HomeViewModelActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setSelectedBookForLibrary(Book? book) {
    final _$actionInfo = _$_HomeViewModelActionController.startAction(
      name: '_HomeViewModel.setSelectedBookForLibrary',
    );
    try {
      return super.setSelectedBookForLibrary(book);
    } finally {
      _$_HomeViewModelActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setSelectedLibraryForBook(Library? library) {
    final _$actionInfo = _$_HomeViewModelActionController.startAction(
      name: '_HomeViewModel.setSelectedLibraryForBook',
    );
    try {
      return super.setSelectedLibraryForBook(library);
    } finally {
      _$_HomeViewModelActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setSelectedWriterForBook(Writer? writer) {
    final _$actionInfo = _$_HomeViewModelActionController.startAction(
      name: '_HomeViewModel.setSelectedWriterForBook',
    );
    try {
      return super.setSelectedWriterForBook(writer);
    } finally {
      _$_HomeViewModelActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
statusMessage: ${statusMessage},
libraryWithBooks: ${libraryWithBooks},
allBooks: ${allBooks},
allNumberOfBooks: ${allNumberOfBooks},
allWriters: ${allWriters},
selectedBookForLibrary: ${selectedBookForLibrary},
selectedLibraryForBook: ${selectedLibraryForBook},
selectedWriterForBook: ${selectedWriterForBook}
    ''';
  }
}
