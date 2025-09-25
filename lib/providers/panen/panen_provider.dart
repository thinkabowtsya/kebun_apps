import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_application_3/services/constant.dart';
import 'package:flutter_application_3/services/db_helper.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

class PanenProvider extends ChangeNotifier {
  final DBHelper _dbHelper = DBHelper();

  String? _notransaksi;
  String? _blok;
  String? _karyawan;
  String? _rotasi;
  late DateTime _tanggal;
  String? _nobkm;
  String? _selectedPanenmandor;
  String? _selectedPanenmandor1;
  String? _selectedPanenkerani;

  List<Map<String, dynamic>> _keraniList = [];
  List<Map<String, dynamic>> _listPrinter = [];
  List<Map<String, dynamic>> _mandorList = [];
  List<Map<String, dynamic>> _mandor1List = [];
  List<Map<String, dynamic>> _panenList = [];
  List<Map<String, dynamic>> _evaluasiPanenList = [];
  List<Map<String, dynamic>> _panenListbytrans = [];

  List<Map<String, dynamic>> _panenHeaderList = [];
  List<Map<String, dynamic>> _panenPerBlokList = [];
  List<Map<String, dynamic>> _panenPerKaryawanList = [];
  List<Map<String, dynamic>> _panenPerKaryawanDetail = [];
  List<Map<String, dynamic>> _panenPresensi = [];

  String? get selectedMandorValue => _selectedPanenmandor;
  String? get selectedMandor1Value => _selectedPanenmandor1;
  String? get selectedKeraniValue => _selectedPanenkerani;
  String? get notransaksi => _notransaksi;
  String? get blok => _blok;
  String? get karyawan => _karyawan;
  String? get rotasi => _rotasi;

  List<Map<String, dynamic>> get kerani => _keraniList;
  List<Map<String, dynamic>> get mandor => _mandorList;
  List<Map<String, dynamic>> get mandor1 => _mandor1List;
  List<Map<String, dynamic>> get listpanen => _panenList;
  List<Map<String, dynamic>> get listPanenbyTrans => _panenListbytrans;
  DateTime get tanggal => _tanggal;
  List<Map<String, dynamic>> get evaluasipanen => _evaluasiPanenList;

  List<Map<String, dynamic>> get panenHeader => _panenHeaderList;
  List<Map<String, dynamic>> get panenperblok => _panenPerBlokList;
  List<Map<String, dynamic>> get panenperkaryawan => _panenPerKaryawanList;
  List<Map<String, dynamic>> get panenperkaryawanDetail =>
      _panenPerKaryawanDetail;
  List<Map<String, dynamic>> get panenPresensi => _panenPresensi;
  List<Map<String, dynamic>> get listPrinter => _listPrinter;

  bool _shouldRefresh = false;

  bool get shouldRefresh => _shouldRefresh;

  void setShouldRefresh(bool value) {
    _shouldRefresh = value;
    notifyListeners();
  }

  void setNotransaksi(String value) {
    _notransaksi = value;

    notifyListeners();
  }

  void setTanggal(DateTime value) {
    _tanggal = value;

    notifyListeners();
  }

  void setKrani(String value) {
    _selectedPanenkerani = value;
    notifyListeners();
  }

  void setMandor(String value) {
    _selectedPanenmandor = value;
    notifyListeners();
  }

  void setMandor1(String value) {
    _selectedPanenmandor1 = value;
    notifyListeners();
  }

  Future<void> fetchListPrinter(String? notransaksi) async {
    final Database? db = await _dbHelper.database;
    if (db == null) return;

    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      var lokasitugas = prefs.getString('lokasitugas');

      String str = '''
        SELECT b.* ,ifnull(a.namakaryawan,ifnull(c.namakaryawan,b.nik)) as namakaryawan FROM kebun_panendt b LEFT OUTER JOIN datakaryawan a on b.nik=a.karyawanid LEFT OUTER JOIN setup_pemanen_baru c on b.nik=c.karyawanid where b.notransaksi='$notransaksi' order by a.namakaryawan,c.namakaryawan
      
        ''';

      final result = await db.rawQuery(str);

      _listPrinter = result;
    } catch (e, stackTrace) {
      print("🔴 Error: $e");
      print("🔴 Stack Trace: $stackTrace");
      _mandorList = [];
    }

    notifyListeners();
  }

  Future<void> fetchMandor() async {
    final Database? db = await _dbHelper.database;
    if (db == null) return;

    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      var lokasitugas = prefs.getString('lokasitugas');
      var defaultMandorName = prefs.getString('namakaryawan');

      if (lokasitugas == null) {
        _mandorList = [];
        notifyListeners();
        return;
      }

      const String sql = '''
        SELECT * FROM datakaryawan 
        WHERE kodejabatan IN (SELECT nilai FROM setup_parameterappl WHERE kodeparameter = 'MNDR') 
        AND lokasitugas = ?
        ORDER BY namakaryawan;
      ''';

      final result = await db.rawQuery(sql, [lokasitugas]);

      _mandorList = result.isNotEmpty ? result : [];

      // if (defaultMandorName != null && _mandorList.isNotEmpty) {
      //   final defaultMandor = _mandorList.firstWhere(
      //     (item) => item['namakaryawan'] == defaultMandorName,
      //   );

      //   setMandor(defaultMandor['karyawanid'].toString());
      // }
    } catch (e, stackTrace) {
      print("🔴 Error: $e");
      print("🔴 Stack Trace: $stackTrace");
      _mandorList = [];
    }

    notifyListeners();
  }

  Future fetchDataMandor1() async {
    final Database? db = await _dbHelper.database;
    if (db == null) return;

    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      var lokasitugas = prefs.getString('lokasitugas');

      if (lokasitugas == null) {
        _mandor1List = [];
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

      _mandor1List = result.isNotEmpty ? result : [];
    } catch (e, stackTrace) {
      print("🔴 Error: $e");
      print("🔴 Stack Trace: $stackTrace");
      _mandor1List = [];
    }

    notifyListeners();
  }

  Future fetchDataKraniPanen() async {
    final Database? db = await _dbHelper.database;
    if (db == null) return;

    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      var lokasitugas = prefs.getString('lokasitugas');

      if (lokasitugas == null) {
        _keraniList = [];
        notifyListeners();
        return;
      }

      const String sql = '''
        SELECT * FROM datakaryawan 
        WHERE kodejabatan IN (SELECT nilai FROM setup_parameterappl WHERE kodeparameter = 'KRNI') 
        AND lokasitugas = ?
        ORDER BY namakaryawan;
      ''';

      final result = await db.rawQuery(sql, [lokasitugas]);

      _keraniList = result.isNotEmpty ? result : [];
    } catch (e, stackTrace) {
      print("🔴 Error: $e");
      print("🔴 Stack Trace: $stackTrace");
      _keraniList = [];
    }

    notifyListeners();
  }

  Future<List<Map<String, dynamic>>> fetchListPanen(String? tanggal) async {
    final Database? db = await _dbHelper.database;
    if (db == null) return [];

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    var kebun = prefs.getString('lokasitugas');
    var username = prefs.getString('username')?.trim();
    String changedata = '';
    final now = DateFormat('yyyy-MM-dd').format(DateTime.now());

    if (tanggal == null) {
      changedata = 'AND (a.synchronized = "" OR a.tanggal = "$now")';
    } else {
      if (tanggal.isEmpty) {
        throw Exception('Tanggal kosong');
      } else {
        changedata = " AND a.tanggal = '$tanggal'";
      }
    }

    String query =
        ''' SELECT a.*, b.namakaryawan as namakaryawan FROM kebun_panen a LEFT OUTER JOIN datakaryawan b on a.nikmandor=b.karyawanid where a.verify = '0' and a.updateby='$username'$changedata order by notransaksi desc ''';

    final result = await db.rawQuery(query);

    _panenList = result;

    print(_panenList);

    notifyListeners();
    return _panenList;
  }

  Future<List<Map<String, dynamic>>> fetchByTrans(String? transaksi) async {
    final Database? db = await _dbHelper.database;
    if (db == null) return [];

    final result = await db.rawQuery(
      'SELECT * FROM kebun_panen WHERE notransaksi = ?',
      [transaksi],
    );

    _panenListbytrans = result.isNotEmpty ? result : [];
    // _shouldRefresh = true;
    notifyListeners();
    return _panenListbytrans;
  }

  Future<void> setInitialHeaderData(Map<String, dynamic> header) async {
    _notransaksi = header['notransaksi'];
    _selectedPanenkerani = header['kerani'];
    // _selectedAsisten = header['nikasisten'];
    _selectedPanenmandor = header['nikmandor'];
    _selectedPanenmandor1 = header['nikmandor1'];
    _tanggal = DateTime.parse(header['tanggal']);

    notifyListeners();
  }

  void resetForm() {
    _selectedPanenkerani = null;
    // _selectedAsisten = header['nikasisten'];
    _selectedPanenmandor = null;
    _selectedPanenmandor1 = null;
    notifyListeners();
  }

  // ==========
  Future<List<Map<String, dynamic>>> fetchPanenEvaluasi(
      String? notransaksi) async {
    final Database? db = await _dbHelper.database;
    if (db == null) return [];

    String strSelecty =
        '''  SELECT b.notransaksi,b.nik,SUM(b.jjgpanen) as jjgpanen,SUM(b.brondolanpanen) as brondolanpanen,ifnull(a.namakaryawan,ifnull(c.namakaryawan,b.nik)) as namakaryawan,ifnull(b.cetakan,0) as cetakan FROM kebun_panendt b LEFT JOIN datakaryawan a on b.nik=a.karyawanid LEFT JOIN setup_pemanen_baru c on b.nik=c.karyawanid where b.notransaksi='$notransaksi' group by b.nik order by a.namakaryawan,c.namakaryawan ''';

    String strSelectyLain =
        '''  SELECT b.notransaksi,b.nik,SUM(b.jjgpanen) as jjgpanen,SUM(b.brondolanpanen) as brondolanpanen,ifnull(a.namakaryawan,ifnull(c.namakaryawan,b.nik)) as namakaryawan,ifnull(b.cetakan,0) as cetakan FROM kebun_panendt b LEFT JOIN datakaryawan a on b.nik=a.karyawanid LEFT JOIN setup_pemanen_baru c on b.nik=c.karyawanid where b.notransaksi='$notransaksi' group by b.nik order by a.namakaryawan,c.namakaryawan ''';

    final result = await db.rawQuery(strSelecty);
    final resultLain = await db.rawQuery(strSelectyLain);

    if (result.isNotEmpty) {
      _evaluasiPanenList = result;
    } else {
      _evaluasiPanenList = resultLain;
    }

    notifyListeners();
    return _evaluasiPanenList;
  }

  Future<List<String>> addHeader({
    String notransaksi = '',
    required DateTime tanggal,
    String usertype = '',
    String notransverify = '',
    required BuildContext context,
  }) async {
    final Database? db = await _dbHelper.database;
    if (db == null) return [];

    final errors = <String>[];

    String notrans = notransaksi;
    String tgl = DateFormat('yyyy-MM-dd').format(tanggal);

    String? mandor = selectedMandorValue;
    String? mandor1 = selectedMandor1Value;
    String? kerani = selectedKeraniValue;

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    var kebun = prefs.getString('lokasitugas');
    var username = prefs.getString('username')?.trim();

    try {
      // gunakan transaction supaya COMMIT/ROLLBACK otomatis
      await db.transaction((txn) async {
        if (usertype != 'checker') {
          // gunakan parameterized query agar aman terhadap karakter khusus
          String qry =
              ''' SELECT 1 FROM kebun_panen WHERE nikmandor = ? AND tanggal = ? AND notransaksi <> ? AND updateby = ? LIMIT 1 ''';

          final result = await txn.rawQuery(
              qry, [mandor ?? '', tgl, notransverify, username ?? '']);

          if (result.isNotEmpty) {
            errors.add(
                'Kode Kemandoran sudah terdaftar ditransaksi lain dengan tanggal yang sama ($tgl) !!');

            // rollback otomatis oleh transaction -> gunakan throw untuk menghentikan callback
            throw StateError('duplicate_kemandoran');
          } else {
            // delegasi ke execAddHeader yang menerima optional txn agar bagian insert menjadi bagian dari transaction ini
            final innerErrors = await execAddHeader(
              usertype: usertype,
              notransverify: notransverify,
              txn: txn, // pastikan execAddHeader mendukung optional Transaction
            );

            if (innerErrors.isNotEmpty) {
              errors.addAll(innerErrors);
              throw StateError('execAddHeader_failed');
            }

            // jika sampai sini, transaction callback selesai => COMMIT otomatis
            return;
          }
        } else {
          // jika usertype == 'checker', perilaku semula tidak melakukan cek/insert di sini
          // (jika seharusnya checker juga memanggil execAddHeader, sesuaikan)
          return;
        }
      });

      // transaction sukses, lakukan checkpoint WAL agar perubahan mudah terlihat saat inspect via adb (opsional)
      try {
        await db.execute('PRAGMA wal_checkpoint(FULL);');
      } catch (e) {
        debugPrint('wal_checkpoint failed: $e');
      }
    } catch (e, st) {
      // Jika terjadi exception di dalam transaction (termasuk throw sengaja), transaction sudah di-rollback otomatis
      debugPrint('addHeader transaction error: $e\n$st');
      if (errors.isNotEmpty) return errors;
      return ['Terjadi kesalahan saat menyimpan header: ${e.toString()}'];
    }

    notifyListeners();
    return errors;
  }

  Future<List<String>> execAddHeader({
    String usertype = '',
    String notransverify = '',
    Transaction?
        txn, // optional: jika disuplai, gunakan txn agar operasi jadi bagian dari transaction luar
  }) async {
    final Database? db = await _dbHelper.database;
    if (db == null) return [];

    final errors = <String>[];

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    var kebun = prefs.getString('lokasitugas');
    var username = prefs.getString('username')?.trim();

    String? notrans = notransaksi;
    String tgl = DateFormat('yyyy-MM-dd').format(_tanggal);
    String? mandor = selectedMandorValue;
    String? mandor1 = selectedMandor1Value;
    String? kerani = selectedKeraniValue;
    String? nobkm = _nobkm;
    String panenverify = '0';

    // tentukan mode panenwhere secara aman (kita akan gunakan parameter list)
    bool isChecker = (usertype != '' && usertype == 'checker');

    if (isChecker) {
      panenverify = notransverify;
      // tgl tetap sesuai awal (tidak diubah)
    } else {
      // non-checker: hanya ambil yang verify <> '0'
      // dan gunakan tanggal sekarang sebagai tgl
      tgl = DateTimeUtils.tanggalSekarang();
    }

    // helper: pilih executor (txn kalau ada, else db)
    Future<List<Map<String, Object?>>> rawQuery(String sql,
        [List<Object?>? params]) {
      if (txn != null) return txn!.rawQuery(sql, params);
      return db.rawQuery(sql, params);
    }

    Future<int> rawInsert(String sql, [List<Object?>? params]) {
      if (txn != null) return txn!.rawInsert(sql, params);
      return db.rawInsert(sql, params);
    }

    Future<int> rawDelete(String sql, [List<Object?>? params]) {
      if (txn != null) return txn!.rawDelete(sql, params);
      return db.rawDelete(sql, params);
    }

    try {
      // cek notrans kosong
      if ((notrans ?? '').isEmpty) {
        errors.add('Transaksi belum disimpan');
        if (txn != null) {
          // inside transaction -> rollback by throwing
          throw StateError('notransaksi_empty');
        }
        return errors;
      }

      // cek kegiatan : gunakan parameterized query tergantung mode checker atau bukan
      List<Map<String, Object?>> cekkegiatan;
      if (isChecker) {
        final String qryCekKegiatan =
            'SELECT 1 FROM kebun_panen WHERE notransaksi = ? AND verify = ? LIMIT 1';
        cekkegiatan = await rawQuery(qryCekKegiatan, [notrans, panenverify]);
      } else {
        final String qryCekKegiatan =
            'SELECT 1 FROM kebun_panen WHERE notransaksi = ? AND verify <> ? LIMIT 1';
        cekkegiatan = await rawQuery(qryCekKegiatan, [notrans, '0']);
      }

      if (cekkegiatan.isNotEmpty) {
        errors.add(
            'Data dengan tanggal yang sama sudah ada, silahkan isi data detail');
        if (txn != null) {
          throw StateError('duplicate_kegiatan');
        }
        return errors;
      }

      // siapkan insert
      String lastupdate = DateTimeUtils.lastUpdate();

      final String qryInsert =
          'INSERT INTO kebun_panen(notransaksi,tanggal,nobkm,nikmandor,nikmandor1,nikasisten,kerani,updateby,verify,lastupdate,synchronized,cetakan) VALUES(?,?,?,?,?,?,?,?,?,?,?,?)';

      // jika checker, ada kemungkinan variabel panenblok/panenkaryawan/rotasi di-set; tetap mengikuti logic asli
      String? panenblok = '';
      String? panenkaryawan = '';
      String? rotasiLocal = '';
      if (isChecker) {
        panenblok = blok;
        panenkaryawan = karyawan;
        rotasiLocal = rotasi; // gunakan nama lokal agar tidak kebingungan
      }

      // lakukan insert
      await rawInsert(qryInsert, [
        notrans,
        tgl,
        nobkm ?? '',
        mandor ?? '',
        mandor1 ?? '',
        "",
        kerani ?? '',
        username ?? '',
        (isChecker) ? panenverify : '0',
        lastupdate,
        "",
        "0"
      ]);
    } catch (e, st) {
      debugPrint('execAddHeader error: $e\n$st');
      if (errors.isNotEmpty) {
        // jika errors terisi (kondisi logis), kembalikan itu
        return errors;
      }
      // kalau bukan kondisi logis, kembalikan pesan generik
      return ['Terjadi kesalahan saat menambahkan header: ${e.toString()}'];
    }

    // notify seperti semula
    notifyListeners();
    return errors;
  }

  Future<void> deletePanen(notransaksi) async {
    final Database? db = await _dbHelper.database;
    if (db == null) return;

    await db.transaction((txn) async {
      await txn.delete(
        'kebun_panen',
        where: 'notransaksi = ? AND verify = ? ',
        whereArgs: [notransaksi, '0'],
      );

      await txn.delete(
        'kebun_panendt',
        where: 'notransaksi = ? ',
        whereArgs: [notransaksi],
      );

      await txn.delete(
        'kebun_kondisi_buah',
        where: 'notransaksi = ? ',
        whereArgs: [notransaksi],
      );

      await txn.delete(
        'kebun_absen_panen',
        where: 'notransaksi = ? ',
        whereArgs: [notransaksi],
      );

      await txn.delete(
        'kebun_grading',
        where: 'notransaksi = ? ',
        whereArgs: [notransaksi],
      );
    });

    notifyListeners();
  }

  Future<void> lihatPanen({String? notransaksi, String usertype = ''}) async {
    final db = await _dbHelper.database;
    if (db == null) return;

    String where = '';
    if (usertype == 'checker') {
      where = " a.verify='$notransaksi' ";
    } else {
      where = " a.notransaksi='$notransaksi' ";
    }

    String qry = '''
      SELECT
        a.*,
        IFNULL((SELECT namakaryawan FROM datakaryawan WHERE karyawanid = a.kerani), a.kerani)   AS kerani,
        IFNULL(b.namakaryawan, a.nikmandor)                                                    AS mandor,
        IFNULL((SELECT namakaryawan FROM datakaryawan WHERE karyawanid = a.nikmandor1), a.nikmandor1) AS mandor1
      FROM kebun_panen a
      LEFT JOIN datakaryawan b ON a.nikmandor = b.karyawanid
      WHERE $where
      ORDER BY a.tanggal DESC
      LIMIT 1
      ''';

    final result = await db.rawQuery(qry);
    _panenHeaderList = result;

    String strPerBlock = '''
        SELECT 
          SUM(b.jjgpanen) AS jjgpanen,
          SUM(b.brondolanpanen) AS brondolanpanen,
          IFNULL(a.kodeorg, b.blok) AS blok
        FROM kebun_panendt b
        LEFT JOIN setup_tph a ON b.blok = a.kode
        WHERE b.notransaksi = '$notransaksi'
        GROUP BY a.kodeorg
        ORDER BY a.kodeorg
      ''';

    final resultblok = await db.rawQuery(strPerBlock);

    _panenPerBlokList = resultblok;

    String strSelectylist = '''
  SELECT 
    b.notransaksi,
    b.nik,
    SUM(b.jjgpanen) AS jjgpanen,
    SUM(b.brondolanpanen) AS brondolanpanen,
    IFNULL(a.namakaryawan, IFNULL(c.namakaryawan, b.nik)) AS namakaryawan,
    b.cetakan
  FROM kebun_panendt b
  LEFT JOIN datakaryawan a ON b.nik = a.karyawanid
  LEFT JOIN setup_pemanen_baru c ON b.nik = c.karyawanid
  WHERE b.notransaksi = '$notransaksi'
  GROUP BY b.nik
  ORDER BY a.namakaryawan, c.namakaryawan
''';

    final resultSelect = await db.rawQuery(strSelectylist);

    _panenPerKaryawanList = resultSelect;

    String qKebunKehadiran = '''
      SELECT 
        IFNULL(d.namakaryawan, '') AS namakaryawan,
        a.*
      FROM kebun_kehadiran_panen a
      LEFT JOIN datakaryawan d ON a.nik = d.karyawanid
      WHERE a.notransaksi = '$notransaksi'
        AND a.kodekegiatan = 'ABSENSI'
      ORDER BY a.lastupdate DESC
    ''';

    final resultKehadiran = await db.rawQuery(qKebunKehadiran);

    _panenPresensi = resultKehadiran;

    notifyListeners();
  }

  Future<void> lihatDetailPanen({String? notransaksi, String? nik}) async {
    final db = await _dbHelper.database;
    if (db == null) return;

    print('process here');

    String strSelect1 = '''
  SELECT 
    b.*,
    IFNULL(a.namakaryawan, IFNULL(c.namakaryawan, b.nik)) AS namakaryawan
  FROM kebun_panendt b
  LEFT JOIN datakaryawan a ON b.nik = a.karyawanid
  LEFT JOIN setup_pemanen_baru c ON b.nik = c.karyawanid
  WHERE b.notransaksi = '$notransaksi'
    AND b.nik = '$nik'
  ORDER BY b.nik, a.namakaryawan, c.namakaryawan
''';

    final resultSelect1 = await db.rawQuery(strSelect1);

    print(resultSelect1);

    _panenPerKaryawanDetail = resultSelect1;

    notifyListeners();
  }

  Future<void> createTablePanen() async {
    final Database? db = await _dbHelper.database;
    if (db == null) return;

    await db.execute(
        ''' CREATE TABLE IF NOT EXISTS pinnumber(karyawanid TEXT,pin TEXT) ''');

    await db.execute(
        ''' CREATE TABLE IF NOT EXISTS kebun_panen(notransaksi TEXT, tanggal TEXT,nobkm TEXT,nikmandor TEXT,nikmandor1 TEXT,nikasisten TEXT,kerani TEXT,synchronized TEXT,updateby TEXT,cetakan INTEGER,status TEXT,verify TEXT,lastupdate TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL)''');

    await db.execute(
        ''' CREATE TABLE IF NOT EXISTS kebun_panendt(notransaksi TEXT,nik TEXT,blok TEXT, divisi TEXT,
				uploaded TEXT,
				rotasi INT,
				jjgpanen TEXT,
				bjr REAL, 
				brondolanpanen TEXT,
				luaspanen TEXT,
				tahuntanam TEXT, 
				upahkerja TEXT, 
				upahpremi TEXT, 
				upahpremilebihbasis TEXT, 
				status INTEGER, 
				foto BLOB,
				lat TEXT,
				long TEXT,
				cetakan INTEGER,
				penalti1 TEXT,
				penalti2 TEXT,
				penalti3 TEXT,
				penalti4 TEXT,
				penalti5 TEXT,
				penalti6 TEXT,
				penalti7 TEXT,
				penalti8 TEXT,
				penalti9 TEXT,
				penalti10 TEXT,
				penalti11 TEXT, 
				penalti12 TEXT, 
				penalti13 TEXT, 
				lastupdate TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL) ''');

    await db
        .execute('''CREATE TABLE IF NOT EXISTS kebun_bkmsign(notransaksi TEXT, 
				ttd1 BLOB,
				ttd2 BLOB,
				ttd3 BLOB) ''');

    await db
        .execute(''' CREATE TABLE IF NOT EXISTS kebun_grading(notransaksi TEXT, 
				blok TEXT,
				rotasi INT,
				nik TEXT,
				kodegrading TEXT,
				jml TEXT) ''');

    await db
        .execute(''' CREATE TABLE IF NOT EXISTS kebun_mutu(notransaksi TEXT, 
				blok TEXT, 
				rotasi INT, 
				nik TEXT,
				nourut INT,
				kodemutu TEXT, 
				jml TEXT)''');

    await db.execute(
        ''' CREATE TABLE IF NOT EXISTS kebun_kondisi_buah(notransaksi TEXT, 
				blok TEXT, 
				rotasi INT, 
				nik TEXT,
				kodehama TEXT, 
				jml TEXT) ''');

    await db
        .execute(''' CREATE TABLE IF NOT EXISTS kebun_gerdang(notransaksi TEXT, 
				nik TEXT,
				gerdang TEXT) ''');

    await db.execute(
        ''' CREATE TABLE IF NOT EXISTS kebun_absen_panen(notransaksi TEXT, 
				nik TEXT) ''');

    await db.execute(
        ''' CREATE TABLE IF NOT EXISTS setup_pemanen_baru(karyawanid TEXT,nik TEXT, 
				lokasitugas TEXT,subbagian TEXT,namakaryawan TEXT,namakaryawan2 TEXT,status INT) ''');

    await db.execute(
        ''' CREATE TABLE IF NOT EXISTS kebun_absen_fingerprint(notransaksi TEXT, 
			nik TEXT) ''');

    await db.execute(''' CREATE TABLE IF NOT EXISTS dataOTG(nik TEXT, 
					 tanggal TEXT,
					 idk1 TEXT,
					 idk2 TEXT,
					 idk3 TEXT,
					 idk4 TEXT)  ''');

    await db
        .execute(''' CREATE TABLE IF NOT EXISTS upah_karyawan(karyawanid TEXT, 
        tanggal TEXT, 
        periode TEXT, 
        upah TEXT, 
        hk TEXT, 
        basis TEXT, 
        lebih1 TEXT, 
        lebih2 TEXT, 
        lebih3 TEXT, 
        updatetime TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL) ''');

    await db.execute(
        ''' CREATE TABLE IF NOT EXISTS kebun_kehadiran_panen(notransaksi TEXT, 
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
		    jam_overtime TEXT, 
		    updateby TEXT,
		    lastupdate TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL) ''');
  }
}
