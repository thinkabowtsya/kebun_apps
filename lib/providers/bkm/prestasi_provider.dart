import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_application_3/services/db_helper.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

class PrestasiProvider with ChangeNotifier {
  final DBHelper _dbHelper = DBHelper();

  List<Map<String, dynamic>> _afdeling = [];
  bool _isLoadingAfdeling = false;
  String? _selectedAfdelingValue;

  List<Map<String, dynamic>> _blok = [];
  bool _isLoadingBlok = false;
  String? _selectedBlokValue;

  List<Map<String, dynamic>> _kegiatan = [];
  bool _isLoadingKegiatan = false;
  String? _selectedKegiatanValue;

  List<Map<String, dynamic>> get afdeling => _afdeling;
  bool get isLoadingAfdeling => _isLoadingAfdeling;
  String? get selectedAfdelingValue => _selectedAfdelingValue;

  List<Map<String, dynamic>> get blok => _blok;
  bool get isLoadingBlok => _isLoadingBlok;
  String? get selectedBlokValue => _selectedBlokValue;

  List<Map<String, dynamic>> get kegiatan => _kegiatan;
  bool get isLoadingKegiatan => _isLoadingKegiatan;
  String? get selectedKegiatanValue => _selectedKegiatanValue;

  List<Map<String, dynamic>> _prestasiList = [];
  List<Map<String, dynamic>> _photoList = [];

  List<Map<String, dynamic>> get prestasiList => _prestasiList;
  List<Map<String, dynamic>> get photoList => _photoList;

  String _hasilKerjaPrestasi = '';
  String _jumlahhkprestasi = '';
  String get hasilkerjaprestasi => _hasilKerjaPrestasi;
  String get jumlahhkprestasi => _jumlahhkprestasi;

  Future<void> fetchAfdeling({String kelompok = '', String divisi = ''}) async {
    String kodetipe = "";
    String tipeorganisasi = "";
    String divisionTxt = "";

    final Database? db = await _dbHelper.database;
    if (db == null) return;

    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      var kebun = prefs.getString('lokasitugas');
      if (kelompok.isNotEmpty) {
        if (kelompok.toUpperCase() == "BBT") {
          kodetipe = "BIBITAN";
        } else {
          kodetipe = "AFDELING";
        }
      }

      if (divisi.isNotEmpty) {
        divisionTxt = divisi;
      }

      if (kodetipe.isNotEmpty) {
        tipeorganisasi = 'and tipeorganisasi = "$kodetipe" ';
      } else {
        tipeorganisasi = 'and tipeorganisasi in ("BIBITAN", "AFDELING") ';
      }
      String query = '''
      SELECT * FROM organisasi 
      WHERE substr(kodeorganisasi, 4, 1) = "E" 
      AND kodeorganisasi LIKE "$kebun%" 
      AND length(kodeorganisasi) = 6 
      $tipeorganisasi 
      ORDER BY kodeorganisasi
    ''';

      final result = await db.rawQuery(query);

      _afdeling = result.isNotEmpty ? result : [];
    } catch (e, stackTrace) {
      print("🔴 Error: $e");
      print("🔴 Stack Trace: $stackTrace");
      _afdeling = [];
    }

    notifyListeners();
  }

  Future<void> fetchBlok({String val = '', String selected = ''}) async {
    final Database? db = await _dbHelper.database;
    if (db == null) return;

    String filter = '';
    if (val.isNotEmpty) {
      filter = 'and kodeblok like "$val%" ';
    }

    String blokTxt = "";

    if (selected.isNotEmpty) {
      blokTxt = selected;
    }

    try {
      String query = '''
        SELECT * FROM setup_blok where 1=1 $filter order by kodeblok
      ''';

      final result = await db.rawQuery(query);

      _blok = result.isNotEmpty ? result : [];
    } catch (e, stackTrace) {
      print("🔴 Error: $e");
      print("🔴 Stack Trace: $stackTrace");
    }

    notifyListeners();
  }

  Future<void> changeKegiatanByBlok(
      {String val = '', String selected = '', String bkmBlok = ''}) async {
    final Database? db = await _dbHelper.database;
    if (db == null) return;

    try {
      _kegiatan = [];
      notifyListeners();

      const blokQuery = '''
      SELECT b.kodeblok, b.statusblok, b.groupkegiatan, b.tahuntanam 
      FROM setup_blok b 
      WHERE kodeblok = ?
    ''';

      final blokResult = await db.rawQuery(blokQuery, [val]);

      if (blokResult.isEmpty) {
        print('Data blok tidak ditemukan');
        return;
      }

      String groupKegiatan = blokResult.first['groupkegiatan'] as String;
      String truekel = groupKegiatan;

      if (!groupKegiatan.contains("'")) {
        truekel = groupKegiatan.split(',').map((e) => '"$e"').join(',');
      }

      final kegiatanQuery = '''
      SELECT * FROM setup_kegiatan 
      WHERE kelompok IN ($truekel) 
      ORDER BY namakegiatan
    ''';

      print('Kegiatan query: $kegiatanQuery');

      final kegiatanResult = await db.rawQuery(kegiatanQuery);

      _kegiatan = kegiatanResult.isNotEmpty ? kegiatanResult : [];
      print(_kegiatan);

      notifyListeners();
    } catch (e, stackTrace) {
      debugPrint('🔴 Error: $e');
      debugPrint('🔴 Stack Trace: $stackTrace');
      print('Terjadi kesalahan saat memuat data kegiatan');
    }
  }

  void setSelectedAfdelingValue(String? value) {
    _selectedAfdelingValue = value;
    notifyListeners();
  }

  void setSelectedBlokValue(String? value) {
    _selectedBlokValue = value;
    notifyListeners();
  }

  void setSelectedKegiatanValue(String? value) {
    _selectedKegiatanValue = value;
    notifyListeners();
  }

  void setHasilkerjaprestasi(String value) {
    _hasilKerjaPrestasi = value;
    notifyListeners();
  }

  void setJumlahhkprestasi(String value) {
    _jumlahhkprestasi = value;
    notifyListeners();
  }

  static Future<void> saveLocationToPrefs(
      double latitude, double longitude) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('last_latitude', latitude);
    await prefs.setDouble('last_longitude', longitude);
    print('Lokasi disimpan: $latitude, $longitude');
  }

  static Future<Map<String, double>?> getLocationFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final lat = prefs.getDouble('last_latitude');
    final lng = prefs.getDouble('last_longitude');

    if (lat != null && lng != null) {
      return {'latitude': lat, 'longitude': lng};
    }
    return null;
  }

  Future<void> savePrestasi({
    required String image1,
    required String image2,
    required String noBKM,
    required String kegiatan,
    required String blok,
    required BuildContext context,
  }) async {
    final Database? db = await _dbHelper.database;
    if (db == null) return;

    final prefs = await SharedPreferences.getInstance();
    final lat_fotoawal = prefs.getDouble('last_latitude');
    final lng_fotoawal = prefs.getDouble('last_longitude');
    final username = prefs.getString('username');

    final String hasilKerjaPrestasi =
        _hasilKerjaPrestasi.isNotEmpty ? _hasilKerjaPrestasi : "0";
    final String jumlahHKPrestasi =
        _jumlahhkprestasi.isNotEmpty ? _jumlahhkprestasi : "0";

    final List<Map<String, dynamic>> results = await db.query(
      'setup_kegiatan',
      where: 'kodekegiatan = ?',
      whereArgs: [kegiatan],
    );

    if (results.isEmpty) {
      throw Exception('Kode kegiatan tidak ditemukan!');
    }

    final String? kelompokResult = results.first['kelompok'] as String?;
    if (kelompokResult == null) throw Exception('Kelompok kegiatan null');

    try {
      // Gunakan transaction agar COMMIT/ROLLBACK otomatis
      await db.transaction((txn) async {
        // Validasi transaksi: pastikan header ada dan di-update oleh user ini
        final checkTrans = await txn.rawQuery('''
        SELECT * FROM kebun_aktifitas 
        WHERE notransaksi = ? AND updateby = ?
      ''', [noBKM, username]);

        if (checkTrans.isEmpty) {
          // lempar objek khusus supaya transaction auto-rollback
          throw {
            'type': 'validation',
            'code': 'no_trans',
            'title': 'Gagal Menyimpan',
            'message': 'Transaksi belum ada atau belum diupdate oleh user ini.'
          };
        }

        // Validasi duplikat
        final checkJmlhHK = await txn.rawQuery('''
        SELECT * FROM kebun_prestasi 
        WHERE notransaksi = ? AND kodekegiatan = ? AND kodeorg = ?
      ''', [noBKM, kegiatan, blok]);

        if (checkJmlhHK.isNotEmpty) {
          throw {
            'type': 'validation',
            'code': 'duplicate',
            'title': 'Gagal Menyimpan',
            'message': 'Data prestasi untuk kegiatan dan blok ini sudah ada.'
          };
        }

        // Insert (parameterized)
        await txn.rawInsert('''
        INSERT INTO kebun_prestasi(
          notransaksi, nobkm, fotoStart2, kelompok, 
          kodekegiatan, kodeorg, jumlahhasilkerja, jumlahhk, 
          updateby, potoawal_lat, potoawal_lat2, 
          potoawal_long, potoawal_long2, potoawal_alt
        ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
      ''', [
          noBKM, // notransaksi
          image1, // nobkm (mengikuti mapping yang ada di kode lama)
          image2, // fotoStart2 (ikuti mapping asli)

          kelompokResult,
          kegiatan,
          blok,
          hasilKerjaPrestasi,
          jumlahHKPrestasi,
          username,
          lat_fotoawal,
          lat_fotoawal,
          lng_fotoawal,
          lng_fotoawal,
          ''
        ]);
        // jika sampai sini tanpa throw -> commit otomatis
      });

      debugPrint('Prestasi berhasil disimpan');

      // setelah commit: kembali ke UI seperti semula
      Navigator.pop(context, {
        'success': true,
        'notransaksi': noBKM,
      });

      notifyListeners();
    } catch (e) {
      // Tangani objek validation yang dilempar untuk menampilkan dialog dan return tanpa rethrow
      if (e is Map && e['type'] == 'validation') {
        final title = e['title'] ?? 'Gagal';
        final message = e['message'] ?? 'Validasi gagal';
        await showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: Text(title.toString()),
            content: Text(message.toString()),
          ),
        );
        return;
      }

      // Untuk error lain: log dan rethrow (sama seperti kode lama yang me-rethrow)
      debugPrint('❌ Error saat simpan prestasi: $e');
      rethrow;
    }
  }

  Future<void> selesaiPhoto({
    required String image1,
    required String image2,
    required String? kodekegiatan,
    required String? kodeorg,
    required String? notrans,
    required BuildContext context,
  }) async {
    final Database? db = await _dbHelper.database;
    if (db == null) return;

    final prefs = await SharedPreferences.getInstance();
    final lat_fotoakhir = prefs.getDouble('last_latitude');
    final lng_fotoakhir = prefs.getDouble('last_longitude');
    final username = prefs.getString('username');

    // print(image2);

    try {
      // gunakan transaction agar COMMIT/ROLLBACK otomatis
      await db.transaction((txn) async {
        // gunakan rawUpdate agar intent UPDATE jelas (sama parameter urutannya seperti kode awal)
        await txn.rawUpdate('''
        UPDATE kebun_prestasi SET 
          jumlahhasilkerja = ?, 
          fotoend2 = ?, 
          potoakhir_long = ?, 
          potoakhir_long2 = ?, 
          potoakhir_alt = ?, 
          potoakhir_lat2 = ?
        WHERE 
          notransaksi = ? AND 
          kodekegiatan = ? AND 
          kodeorg = ?
      ''', [
          image1, // jumlahhasilkerja (sesuai urutan asli)
          image2, // fotoend2
          lng_fotoakhir, // potoakhir_long
          lng_fotoakhir, // potoakhir_long2
          lat_fotoakhir, // potoakhir_alt
          lat_fotoakhir, // potoakhir_lat2
          notrans,
          kodekegiatan,
          kodeorg,
        ]);
        // jika callback selesai tanpa throw => COMMIT otomatis
      });

      debugPrint('Prestasi berhasil disimpan');
      _shouldRefresh = true;
      Navigator.pop(context, {
        'success': true,
        'notransaksi': notrans,
      });

      notifyListeners();
    } catch (e) {
      // db.transaction otomatis melakukan rollback jika exception dilempar
      debugPrint('❌ Error saat simpan prestasi: $e');
      rethrow;
    }
  }

  bool _shouldRefresh = false;

  bool get shouldRefresh => _shouldRefresh;

  void setShouldRefresh(bool value) {
    _shouldRefresh = value;
    notifyListeners();
  }

  Future<List<Map<String, dynamic>>> fetchPrestasiByTransaksi(
      String notrans) async {
    final Database? db = await _dbHelper.database;
    if (db == null) return [];

    try {
      String query = """
    SELECT 
      d.jumlahpokok,
      d.luasareaproduktif,
      MAX(a.jumlahhasilkerja) AS jumlahhasilkerja,

      a.kelompok, 
      b.satuan,
      a.kodekegiatan,
      a.kodeorg,
      a.notransaksi,
      b.namakegiatan,
      SUM(IFNULL(c.jhk, 0)) AS jhk,
      SUM(IFNULL(hasilkerja, 0)) AS hasilkerja,
      c.nik,
      d.kodeblok
    FROM kebun_prestasi a
    LEFT JOIN setup_kegiatan b ON a.kodekegiatan = b.kodekegiatan
    LEFT JOIN setup_blok d ON a.kodeorg = d.kodeblok
    LEFT JOIN kebun_kehadiran c ON c.notransaksi = a.notransaksi 
      AND a.kodekegiatan = c.kodekegiatan 
      AND a.kodeorg = c.kodeorg
    WHERE a.notransaksi = '$notrans'
    GROUP BY a.kodekegiatan, a.kodeorg
    ORDER BY b.namakegiatan
    """;

      final result = await db.rawQuery(query);

      _prestasiList = result;
      notifyListeners();
      return result;
    } catch (e) {
      // await db.execute('ROLLBACK');
      debugPrint('Error: $e');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> fetchPhotoAkhir(
      String kodekegiatan, String kodeorg) async {
    final Database? db = await _dbHelper.database;
    if (db == null) return [];

    try {
      String query = """
    SELECT jumlahhasilkerja AS jumlahhasilkerja, fotoend2 AS fotoend2 FROM kebun_prestasi 
      WHERE kodekegiatan = '$kodekegiatan' and kodeorg='$kodeorg'
    """;

      final result = await db.rawQuery(query);

      _photoList = result;
      notifyListeners();
      return result;
    } catch (e) {
      await db.execute('ROLLBACK');
      debugPrint('Error: $e');
      rethrow;
    }
  }

  Future<void> deletePrestasi({
    required String notransaksi,
    required String kodeorg,
    required String kodekegiatan,
  }) async {
    final db = await _dbHelper.database;
    if (db == null) return;

    await db.delete(
      'kebun_prestasi',
      where: 'notransaksi = ? AND kodeorg = ? AND kodekegiatan = ?',
      whereArgs: [notransaksi, kodeorg, kodekegiatan],
    );

    notifyListeners();
  }
}
