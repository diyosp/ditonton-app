# Ditonton App

[![Flutter CI](https://github.com/diyosp/ditonton-app/actions/workflows/flutter_ci.yml/badge.svg)](https://github.com/diyosp/ditonton-app/actions/workflows/flutter_ci.yml)

Ditonton adalah aplikasi Flutter untuk menampilkan katalog Movie dan TV Series dari The Movie Database (TMDB).

## Fitur

- Daftar Movie now playing, popular, dan top rated
- Daftar TV Series on the air, popular, dan top rated
- Detail Movie dan TV Series beserta rekomendasi
- Informasi season dan episode TV Series
- Pencarian Movie dan TV Series melalui API
- Watchlist Movie dan TV Series yang tersimpan secara lokal
- Firebase Analytics dan Crashlytics
- SSL pinning untuk koneksi menuju API TMDB

## Arsitektur

Source code menerapkan Clean Architecture dengan tiga layer:

- Domain: entity, repository contract, dan use case
- Data: model, data source, serta implementasi repository
- Presentation: halaman, widget, dan state management BLoC

Dependency injection dikelola menggunakan GetIt.

## Teknologi

- Flutter dan Dart
- flutter_bloc
- GetIt
- Sqflite
- Firebase Analytics
- Firebase Crashlytics
- GitHub Actions

## Menjalankan Aplikasi

Pastikan Flutter stable terbaru sudah terpasang dan perangkat Android telah terhubung.

```bash
flutter pub get
flutter run
```

## Pengujian

Menjalankan seluruh unit dan widget test:

```bash
flutter test
```

Menjalankan test sekaligus menghasilkan laporan coverage:

```bash
flutter test --coverage
```

Menjalankan integration test pada perangkat yang terhubung:

```bash
flutter test integration_test/app_flow_test.dart -d <device-id>
```

Coverage unit dan widget test terakhir mencapai 95,78%.

## Continuous Integration

GitHub Actions dijalankan otomatis pada setiap push dan pull request ke branch `main`. Workflow melakukan pemeriksaan format, static analysis, seluruh unit dan widget test, serta mengunggah laporan coverage sebagai artifact.
