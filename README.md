# where_is_library
-B I S M I L L A H-

## Proje Mimarisi

Bu proje **Dependency Injection** pattern'ını kullanarak servisleri merkezi bir yerden yönetir.

### Service Locator Kullanımı
- `lib/service/service_locator.dart` - Tüm servislerin kayıt edildiği merkezi nokta
- `ServiceHelper` sınıfı ile servislere kolay erişim
- Repository pattern ile veritabanı işlemleri
- Secure Storage ve SharedPreferences yönetimi

### Kullanılan Servisler
- **DBService**: SQLite veritabanı yönetimi
- **BookRepository**: Kitap verileri CRUD işlemleri
- **LibraryRepository**: Kütüphane verileri CRUD işlemleri
- **NumberOfBookRepository**: Kitap-Kütüphane ilişki yönetimi
- **SecureStorageManager**: Güvenli veri saklama
- **SharedPreferencesManager**: Kullanıcı tercihleri

## Getting Started


### Build for devices
- ./release.sh build ios
- ./release.sh build android

### Comment Line
//  : Standart yorum satırı
[!] : Dikkat
[?] : Sor
--> : Açıklama

tek seferlik çalıştıracaksan dart run build_runner build

watch etmek için:
dart run build_runner watch --delete-conflicting-outputs
veya
flutter pub run build_runner watch --delete-conflicting-outputs

flutter launcher iconla ios için icon oluşturma;
flutter pub run flutter_launcher_icons

splash screen için;
dart run flutter_native_splash:create --path=flutter_native_splash.yaml

### APK
flutter build apk --release
- build/app/outputs/flutter-apk/app-release.apk

### .aab
flutter build appbundle --release
- build/app/outputs/bundle/release/app-release.aab

## Fastlane ile markete gönderme komutları

Versiyon formatı: MAJOR.MINOR.PATCH+BUILD_NUMBER şeklinde (örn: 1.2.3+45)

# sadece build arttırmak için

./release.sh build ios # iOS için  => çoğunlukla bunu çalıştıracaksın
./release.sh build android # Android için
./release.sh build all # Her iki platform için