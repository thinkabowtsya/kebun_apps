import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_application_3/services/db_helper.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

class DataProvider with ChangeNotifier {
  final DBHelper _dbHelper = DBHelper();

  List<Map<String, dynamic>> _mandor = [];
  bool _isLoadingMandor = false;
  String? _selectedMandorValue;

  List<Map<String, dynamic>> _mandor1 = [];
  bool _isLoadingMandor1 = false;
  String? _selectedMandor1Value;

  List<Map<String, dynamic>> _asisten = [];
  bool _isLoadingAsisten = false;
  String? _selectedAsistenValue;

  List<Map<String, dynamic>> _afdeling = [];
  bool _isLoadingAfdeling = false;
  String? _selectedAfdelingValue;

  List<Map<String, dynamic>> _blok = [];
  bool _isLoadingBlok = false;
  String? _selectedBlokValue;

  List<Map<String, dynamic>> _kegiatan = [];
  bool _isLoadingKegiatan = false;
  String? _selectedKegiatanValue;

  String? _noTransaksi;
  String? _kodekegiatanTemp;
  String? _kodeorgTemp;
  double? _luasproduktifTemp;
  double? _luaspokokTemp;

  List<Map<String, dynamic>> get mandor => _mandor;
  bool get isLoadingMandor => _isLoadingMandor;
  String? get selectedMandorValue => _selectedMandorValue;

  List<Map<String, dynamic>> get mandor1 => _mandor1;
  bool get isLoadingMandor1 => _isLoadingMandor1;
  String? get selectedMandor1Value => _selectedMandor1Value;

  List<Map<String, dynamic>> get asisten => _asisten;
  bool get isLoadingAsisten => _isLoadingAsisten;
  String? get selectedAsistenValue => _selectedAsistenValue;

  List<Map<String, dynamic>> get afdeling => _afdeling;
  bool get isLoadingAfdeling => _isLoadingAfdeling;
  String? get selectedAfdelingValue => _selectedAfdelingValue;

  List<Map<String, dynamic>> get blok => _blok;
  bool get isLoadingBlok => _isLoadingBlok;
  String? get selectedBlokValue => _selectedBlokValue;

  List<Map<String, dynamic>> get kegiatan => _kegiatan;
  bool get isLoadingKegiatan => _isLoadingKegiatan;
  String? get selectedKegiatanValue => _selectedKegiatanValue;

  String _bkmklasifikasi = '';
  String _bkmnomor = '';
  String _bkmkrani = '';
  String _hasilKerjaPrestasi = '';
  String _jumlahhkprestasi = '';

  String get klasifikasi => _bkmklasifikasi;
  String get bkmnomor => _bkmnomor;
  String get bkmkrani => _bkmkrani;
  String get hasilkerjaprestasi => _hasilKerjaPrestasi;
  String get jumlahhkprestasi => _jumlahhkprestasi;
  String? get notransaksi => _noTransaksi;
  String? get kodekegiatanTemp => _kodekegiatanTemp;
  String? get kodeorgTemp => _kodeorgTemp;
  double? get luasproduktifTemp => _luasproduktifTemp;
  double? get luaspokokTemp => _luaspokokTemp;

  List<Map<String, dynamic>> _prestasiList = [];
  List<Map<String, dynamic>> _bkmList = [];

  List<Map<String, dynamic>> get prestasiList => _prestasiList;
  List<Map<String, dynamic>> get bkmList => _bkmList;

  List<Map<String, dynamic>> _karyawan = [];
  String? _selectedKaryawanValue;

  List<Map<String, dynamic>> get karyawan => _karyawan;
  String? get selectedKaryawanValue => _selectedKaryawanValue;

  // static int count = 0;
  // final int instanceId;

  // DataProvider() : instanceId = ++count {
  //   print("🟢 DataProvider instance created: $instanceId");
  // }

  void setSelectedKaryawanValue(String value) {
    _selectedKaryawanValue = value;
    notifyListeners();
  }

  void setNotransaksi(String value) {
    _noTransaksi = value;
    // print("✅ setNotransaksi: $_noTransaksi (ID: $instanceId)");
    notifyListeners();
  }

  void setKodekegiatantemp(String value) {
    _kodekegiatanTemp = value;
    notifyListeners();
  }

  void setKodeorgtemp(String value) {
    _kodeorgTemp = value;
    notifyListeners();
  }

  void setLuasproduktiftemp(double? value) {
    _luasproduktifTemp = value;
    notifyListeners();
  }

  void setLuaspokoktemp(double? value) {
    _luaspokokTemp = value;
    notifyListeners();
  }

  void setKlasifikasi(String value) {
    _bkmklasifikasi = value;
    notifyListeners();
  }

  void setBkmnomor(String value) {
    _bkmnomor = value;
    notifyListeners();
  }

  void setBkmkrani(String value) {
    _bkmkrani = value;
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

  Future<void> fetchDataMandorWithDefault() async {
    final Database? db = await _dbHelper.database;
    if (db == null) return;

    _isLoadingMandor = true;
    notifyListeners();

    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      var lokasitugas = prefs.getString('lokasitugas');
      var defaultMandorName = prefs.getString('namakaryawan');

      if (lokasitugas == null) {
        _mandor = [];
        notifyListeners();
        return;
      }

      const String sql = '''
        SELECT * FROM datakaryawan 
        WHERE kodejabatan IN (SELECT nilai FROM setup_parameterappl WHERE kodeparameter = 'MNDRWT') 
        AND lokasitugas = ?
        ORDER BY namakaryawan;
      ''';

      final result = await db.rawQuery(sql, [lokasitugas]);

      _mandor = result.isNotEmpty ? result : [];

      if (defaultMandorName != null && _mandor.isNotEmpty) {
        final defaultMandor = _mandor.firstWhere(
          (item) => item['namakaryawan'] == defaultMandorName,
        );

        setSelectedMandorValue(defaultMandor['karyawanid'].toString());
      }
    } catch (e, stackTrace) {
      print("🔴 Error: $e");
      print("🔴 Stack Trace: $stackTrace");
      _mandor = [];
    }

    _isLoadingMandor = false;
    notifyListeners();
  }

  Future<void> fetchDataMandor1() async {
    final Database? db = await _dbHelper.database;
    if (db == null) return;

    _isLoadingMandor1 = true;
    notifyListeners();

    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      var lokasitugas = prefs.getString('lokasitugas');

      if (lokasitugas == null) {
        _mandor1 = [];
        notifyListeners();
        return;
      }

      const String sql = '''
        SELECT * FROM datakaryawan 
        WHERE kodejabatan IN (SELECT nilai FROM setup_parameterappl WHERE kodeparameter = 'MNDR1') 
        AND lokasitugas = ?
        ORDER BY namakaryawan;
      ''';

      final result = await db.rawQuery(sql, [lokasitugas]);

      _mandor1 = result.isNotEmpty ? result : [];
    } catch (e, stackTrace) {
      print("🔴 Error: $e");
      print("🔴 Stack Trace: $stackTrace");
      _mandor1 = [];
    }

    _isLoadingMandor1 = false;
    notifyListeners();
  }

  Future<void> fetchDataAsisten() async {
    final Database? db = await _dbHelper.database;
    if (db == null) return;

    _isLoadingAsisten = true;
    notifyListeners();

    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      var lokasitugas = prefs.getString('lokasitugas');

      if (lokasitugas == null) {
        _asisten = [];
        notifyListeners();
        return;
      }

      const String sql = '''
        SELECT * FROM datakaryawan 
        WHERE kodejabatan IN (SELECT nilai FROM setup_parameterappl WHERE kodeparameter = 'ASST') 
        AND lokasitugas = ?
        ORDER BY namakaryawan;
      ''';

      final result = await db.rawQuery(sql, [lokasitugas]);

      _asisten = result.isNotEmpty ? result : [];
    } catch (e, stackTrace) {
      print("🔴 Error: $e");
      print("🔴 Stack Trace: $stackTrace");
      _asisten = [];
    }

    _isLoadingAsisten = false;
    notifyListeners();
  }

  Future<void> addHeader(
      {String notransaksi = '', required DateTime tanggal}) async {
    final Database? db = await _dbHelper.database;
    if (db == null) return;

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    var kebun = prefs.getString('lokasitugas');
    var username = prefs.getString('username');

    String notrans = notransaksi;
    String tgl = DateFormat('yyyy-MM-dd').format(tanggal);
    String? asisten = selectedAsistenValue;
    String? mandor = selectedMandorValue;
    String? mandor1 = selectedMandor1Value;

    try {
      await db.execute('BEGIN TRANSACTION');

      String query = '''
        SELECT * FROM kebun_aktifitas
        WHERE nikmandor="$mandor"
        AND tanggal ="$tgl"
      ''';

      final result = await db.rawQuery(query);

      // if (result.isNotEmpty) {
      //   throw Exception('Mandor $mandor sudah ada di tanggal $tgl');
      // } else {
      String query2 = ('''
          SELECT * FROM kebun_aktifitas
          WHERE notransaksi="$notransaksi"
          AND updateby ="$username"
         ''');
      final ceknotransaksi = await db.rawQuery(query2);
      if (ceknotransaksi.isEmpty) {
        await db.rawInsert(
          '''
            INSERT INTO kebun_aktifitas(notransaksi,nobkm,kodeorg,kodeklasifikasi,tanggal,nikmandor,nikmandor1,nikasisten,kerani,updateby,synchronized,status)
            VALUES (?, ?, ?, ?,?,?,?,?,?,?,?,?)
            ''',
          [
            notrans,
            _bkmnomor,
            kebun,
            _bkmklasifikasi,
            tgl,
            mandor,
            mandor1,
            asisten,
            _bkmkrani,
            username,
            '',
            '0'
          ],
        );

        print('berhasil insert');
      } else {
        String queryDelete = ''' SELECT * FROM kebun_aktifitas
          WHERE notransaksi="$notransaksi"
          AND updateby ="$username"''';

        await db.rawQuery(queryDelete);

        await db.rawInsert(
          '''
            INSERT INTO kebun_aktifitas(notransaksi,nobkm,kodeorg,kodeklasifikasi,tanggal,nikmandor,nikmandor1,nikasisten,kerani,updateby,synchronized,status)
            VALUES (?, ?, ?, ?,?,?,?,?,?,?,?,?)
            ''',
          [
            notrans,
            '',
            kebun,
            '',
            tgl,
            mandor,
            mandor1,
            asisten,
            '',
            username,
            '',
            '0'
          ],
        );
        // }
      }

      await db.execute('COMMIT');

      final testData = await db.rawQuery('''SELECT * FROM kebun_aktifitas''');

      print('Header berhasil disimpan');
      print(testData);
    } catch (e) {
      await db.execute('ROLLBACK');
      debugPrint('Error: $e');
      rethrow;
    }
  }

  // List<Map<String, dynamic>> _prestasiList = [];

  // List<Map<String, dynamic>> get prestasiList => _prestasiList;

  // void addPrestasi(Map<String, dynamic> newHeader) {
  //   _prestasiList.add({
  //     'kegiatan': 'masuk',
  //     'blok': 'A001',
  //     'jmlHK': 0.0,
  //     'hasilKerja': 0.0,
  //   });
  //   notifyListeners();
  // }

  void setSelectedMandorValue(String? value) {
    _selectedMandorValue = value;
    notifyListeners();
  }

  void setSelectedMandor1Value(String? value) {
    _selectedMandor1Value = value;
    notifyListeners();
  }

  void setSelectedAsistenValue(String? value) {
    _selectedAsistenValue = value;
    notifyListeners();
  }

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

  Future<void> loadKaryawan(dynamic value) async {
    final Database? db = await _dbHelper.database;
    if (db == null) return;

    try {
      String karyawanPermandor = '';
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      var mandorid = prefs.getString('karyawanid');
      // print('method load');
      // print(value);

      if (value != null) {
        karyawanPermandor = 'and mandorid = $mandorid';
      }

      String query = '''
      SELECT a.* FROM datakaryawan a left join kemandoran b on a.karyawanid = b.karyawanid where a.perawatan = '1'  and a.subbagian != ' ' and a.gajipokok != 0 order by namakaryawan
      ''';

      final result = await db.rawQuery(query);

      _karyawan = result.isNotEmpty ? result : [];
    } catch (e, stackTrace) {
      print("🔴 Error: $e");
      print("🔴 Stack Trace: $stackTrace");
      _karyawan = [];
    }

    notifyListeners();
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

  Future<void> createTableBKM() async {
    final Database? db = await _dbHelper.database;
    if (db == null) return;

    await db.execute('''
    CREATE TABLE IF NOT EXISTS kebun_aktifitas(id INTEGER PRIMARY KEY AUTOINCREMENT,notransaksi TEXT,kodeklasifikasi TEXT,nobkm TEXT,tanggal TEXT,kodeorg TEXT,nikmandor TEXT,nikmandor1 TEXT,nikasisten TEXT,kerani TEXT,kodekegiatan TEXT,status TEXT,synchronized TEXT,updateby TEXT,lastupdate TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL)
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS kebun_prestasi(notransaksi TEXT,
      fotoStart2 BLOB, 
      fotoEnd2 BLOB, 
      nobkm TEXT,
      kelompok TEXT,
      kodekegiatan TEXT,
      kodeorg TEXT,
      jumlahhasilkerja TEXT,
      jumlahhk TEXT,
      potoawal_lat TEXT,
      potoawal_lat2 TEXT,
      potoawal_long TEXT,
      potoawal_long2 TEXT,
      potoawal_alt TEXT,
      potoakhir_lat TEXT,
      potoakhir_lat2 TEXT,
      potoakhir_long TEXT,
      potoakhir_long2 TEXT,
      potoakhir_alt TEXT,
      updateby TEXT,
      lastupdate TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL)
      ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS kebun_kehadiran(notransaksi TEXT,
		    kodekegiatan TEXT,
		    kodeorg TEXT,
		    nik TEXT,
		    jhk REAL,
		    absensi TEXT,
		    hasilkerja TEXT,
		    satuanprestasi TEXT,
		    premiprestasi TEXT,
		    insentif TEXT,
		    extrafooding TEXT,
		    premilebihbasis TEXT,
		    jam_overtime TEXT,
		    updateby TEXT,
		    lastupdate TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL)
      ''');

    await db.execute('''
    CREATE TABLE IF NOT EXISTS kebun_pakaimaterial(notransaksi TEXT,
		kodekegiatan TEXT,
		kodeorg TEXT,
		gudang TEXT,
		kodebarang TEXT,
		kwantitasha TEXT,
		kwantitas TEXT,
		updateby TEXT,
		lastupdate TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL)
    ''');

    await db.execute('''
    CREATE TABLE IF NOT EXISTS kebun_bkmsign(notransaksi TEXT,
		ttd1 BLOB,
		ttd2 BLOB,
		ttd3 BLOB)
    ''');
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
    required File image1,
    required File image2,
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

    final String base64Image1 = base64Encode(await image1.readAsBytes());
    final String base64Image2 = base64Encode(await image2.readAsBytes());

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
      await db.execute('BEGIN TRANSACTION');

      // Validasi transaksi
      final checkTrans = await db.rawQuery('''
      SELECT * FROM kebun_aktifitas 
      WHERE notransaksi = ? AND updateby = ?
    ''', [noBKM, username]);

      if (checkTrans.isEmpty) {
        await db.execute('ROLLBACK');
        showDialog(
          context: context,
          builder: (_) => const AlertDialog(
            title: Text('Gagal Menyimpan'),
            content:
                Text('Transaksi belum ada atau belum diupdate oleh user ini.'),
          ),
        );
        return;
      }

      // Validasi duplikat
      final checkJmlhHK = await db.rawQuery('''
      SELECT * FROM kebun_prestasi 
      WHERE notransaksi = ? AND kodekegiatan = ? AND kodeorg = ?
    ''', [noBKM, kegiatan, blok]);

      if (checkJmlhHK.isNotEmpty) {
        await db.execute('ROLLBACK');
        showDialog(
          context: context,
          builder: (_) => const AlertDialog(
            title: Text('Gagal Menyimpan'),
            content:
                Text('Data prestasi untuk kegiatan dan blok ini sudah ada.'),
          ),
        );
        return;
      }

      // Insert
      await db.rawInsert('''
      INSERT INTO kebun_prestasi(
        notransaksi, nobkm, fotoStart2, kelompok, 
        kodekegiatan, kodeorg, jumlahhasilkerja, jumlahhk, 
        updateby, potoawal_lat, potoawal_lat2, 
        potoawal_long, potoawal_long2, potoawal_alt
      ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
    ''', [
        noBKM,
        base64Image1,
        base64Image2,
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

      await db.execute('COMMIT');
      debugPrint('Prestasi berhasil disimpan');

      Navigator.pop(context, {
        'success': true,
        'notransaksi': noBKM,
      });

      notifyListeners();
    } catch (e) {
      await db.execute('ROLLBACK');
      debugPrint('❌ Error saat simpan prestasi: $e');
      rethrow;
    }
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

  Future<void> tampilkanListBKM(String username, [String? tgl]) async {
    final db = await _dbHelper.database;
    if (db == null) return;

    final now = DateFormat('yyyy-MM-dd').format(DateTime.now());

    String changedata = '';

    if (tgl == null) {
      changedata = 'AND (a.synchronized = "" OR a.tanggal = "$now")';
    } else {
      if (tgl.isEmpty) {
        throw Exception('Tanggal kosong');
      } else {
        changedata = 'AND a.tanggal = "$tgl"';
      }
    }

    // Ingat: kita quote username juga karena itu string
    String query = '''
    SELECT a.*, b.*
    FROM kebun_aktifitas a
    LEFT JOIN datakaryawan b ON a.nikmandor = b.karyawanid
    WHERE a.updateby = '$username'
    $changedata
    ORDER BY a.tanggal DESC, a.lastupdate DESC
  ''';

    final result = await db.rawQuery(query);
    _bkmList = result;
    notifyListeners();
  }
}
