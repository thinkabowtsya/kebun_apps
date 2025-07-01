import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_application_3/services/db_helper.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

class BkmProvider with ChangeNotifier {
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

  late DateTime _selectedDate;
  DateTime get selectedDate => _selectedDate;

  List<Map<String, dynamic>> _bkmListing = [];
  List<Map<String, dynamic>> _kehadiranUmumListing = [];

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

  List<Map<String, dynamic>> get bkmListing => _bkmListing;
  List<Map<String, dynamic>> get kehadiranUmumListing => _kehadiranUmumListing;

  String _bkmklasifikasi = '';
  String _bkmnomor = '';
  String _bkmkrani = '';

  String get klasifikasi => _bkmklasifikasi;
  String get bkmnomor => _bkmnomor;
  String get bkmkrani => _bkmkrani;

  String? get notransaksi => _noTransaksi;
  String? get kodekegiatanTemp => _kodekegiatanTemp;
  String? get kodeorgTemp => _kodeorgTemp;
  double? get luasproduktifTemp => _luasproduktifTemp;
  double? get luaspokokTemp => _luaspokokTemp;

  List<Map<String, dynamic>> _bkmList = [];
  List<Map<String, dynamic>> get bkmList => _bkmList;

  List<Map<String, dynamic>> _bkmListByTrans = [];
  List<Map<String, dynamic>> get bkmListByTrans => _bkmListByTrans;

  void setNotransaksi(String value) {
    _noTransaksi = value;
    // print("✅ setNotransaksi: $_noTransaksi (ID: $instanceId)");
    notifyListeners();
  }

  void setInitialHeaderData(Map<String, dynamic> header) {
    _noTransaksi = header['notransaksi'];
    _selectedMandorValue = header['nikmandor'];
    _selectedMandor1Value = header['nikmandor1'];
    _selectedAsistenValue = header['nikasisten'];
    _selectedDate = DateTime.parse(header['tanggal']);

    notifyListeners();
  }

  void resetForm() {
    _selectedMandor1Value = null;
    _selectedAsistenValue = null;
    _kodekegiatanTemp = null;
    _kodeorgTemp = null;
    _luasproduktifTemp = null;
    _luaspokokTemp = null;
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

  Future<List<Map<String, dynamic>>> fetchByTrans(String? transaksi) async {
    final Database? db = await _dbHelper.database;
    if (db == null) return [];

    final result = await db.rawQuery(
      'SELECT * FROM kebun_aktifitas WHERE notransaksi = ?',
      [transaksi],
    );

    _bkmListByTrans = result.isNotEmpty ? result : [];

    notifyListeners();
    return _bkmListByTrans;
  }

  Future fetchDataMandor1() async {
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

  Future<void> addHeader({
    String notransaksi = '',
    required DateTime tanggal,
    required BuildContext context,
  }) async {
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

      if (result.isNotEmpty) {
        throw Exception('Mandor $mandor sudah ada di tanggal $tgl');
      } else {
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
        }
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

    notifyListeners();
  }

  bool _shouldRefresh = false;
  bool _shouldRefreshDelete = false;

  bool get shouldRefresh => _shouldRefresh;
  bool get shouldRefreshDelete => _shouldRefreshDelete;

  void setShouldRefresh(bool value) {
    _shouldRefresh = value;
    notifyListeners();
  }

  void setShouldRefreshDelete(bool value) {
    _shouldRefreshDelete = value;
    notifyListeners();
  }

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

  // ==========

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

  Future<void> tampilkanListBKM(String username, [String? tgl]) async {
    final db = await _dbHelper.database;
    if (db == null) return;
    _bkmList = [];

    final now = DateFormat('yyyy-MM-dd').format(DateTime.now());

    String changedata = '';

    if (tgl == null) {
      changedata = 'AND (a.synchronized = "" OR a.tanggal = "$now")';
    } else {
      if (tgl.isEmpty) {
        throw Exception('Tanggal kosong');
      } else {
        changedata = " AND a.tanggal = '$tgl'";
      }
    }

    // Ingat: kita quote username juga karena itu string
    String query = '''
    SELECT a.*, b.*
    FROM kebun_aktifitas a
    LEFT JOIN datakaryawan b ON a.nikmandor = b.karyawanid
    WHERE a.updateby like '%$username%'
    $changedata
    ORDER BY a.tanggal DESC, a.lastupdate DESC
  ''';

    final result = await db.rawQuery(query);

    _bkmList = result;
    notifyListeners();
  }

  Future<void> lihatBkm({String? notransaksi}) async {
    final db = await _dbHelper.database;
    if (db == null) return;

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? username = prefs.getString('username')?.trim();

    String strSelect =
        '''  SELECT a.*, ifnull((SELECT namakaryawan FROM datakaryawan WHERE karyawanid = a.nikasisten), a.nikasisten) AS asisten, ifnull(b.namakaryawan,a.nikmandor) as mandor, ifnull((SELECT namakaryawan FROM datakaryawan WHERE karyawanid = a.nikmandor1), a.nikmandor1) AS mandor1 FROM kebun_aktifitas a LEFT JOIN datakaryawan b on a.nikmandor=b.karyawanid where a.notransaksi = '$notransaksi' and a.updateby like '%$username%' order by tanggal desc limit 1  ''';

    final result = await db.rawQuery(strSelect);
    _bkmListing = result;

    String strKehadiranUmum = '''
        SELECT 
          d.namakaryawan, 
          a.* 
        FROM kebun_kehadiran a 
        LEFT JOIN datakaryawan d ON a.nik = d.nik 
        WHERE a.notransaksi = '$notransaksi' 
          AND a.kodekegiatan = 'ABSENSI' 
        ORDER BY a.lastupdate DESC
      ''';

    final resultKehadiran = await db.rawQuery(strKehadiranUmum);
    _kehadiranUmumListing = resultKehadiran;

    notifyListeners();
  }

  Future<void> deleteBkm(
      {String? notransaksi, required BuildContext context}) async {
    final Database? db = await _dbHelper.database;
    if (db == null) return;

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? username = prefs.getString('username')?.trim();

    try {
      await db.transaction((txn) async {
        await txn.delete(
          'kebun_aktifitas',
          where: 'notransaksi = ? AND updateby LIKE ?',
          whereArgs: [notransaksi, '%$username%'],
        );

        await txn.delete(
          'kebun_prestasi',
          where: 'notransaksi = ?',
          whereArgs: [notransaksi],
        );

        await txn.delete(
          'kebun_kehadiran',
          where: 'notransaksi = ?',
          whereArgs: [notransaksi],
        );

        await txn.delete(
          'kebun_pakaimaterial',
          where: 'notransaksi = ?',
          whereArgs: [notransaksi],
        );
      });

      _shouldRefresh = true;

      if (context.mounted) {
        Navigator.pop(context, {'success': true});
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Gagal hapus data')));
      }
      rethrow;
    }

    notifyListeners();
  }
}
