# Tugas Resep Winda

Aplikasi Flutter bertema resep masakan untuk tugas Praktikum Mobile IF-D.

## Fitur

- Register dan login dengan penyimpanan akun lokal memakai SharedPreferences.
- Logout dari tombol AppBar dan penghapusan sesi lokal.
- Home Page berisi GridView resep dari API TheMealDB.
- Detail Page mengambil ulang data resep memakai endpoint `lookup.php?i={id}`.
- Favorit Page menyimpan, menampilkan, dan menghapus resep favorit memakai Hive.
- Data favorit tetap tersimpan walaupun aplikasi ditutup.

## API

Base URL: `https://www.themealdb.com/api/json/v1/1/`

Endpoint yang digunakan:

- `filter.php?c={category}`
- `lookup.php?i={id}`

## Menjalankan Project

```bash
flutter pub get
flutter run
```
