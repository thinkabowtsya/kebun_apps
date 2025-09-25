import 'package:flutter/material.dart';
import 'package:flutter_application_3/services/constant.dart';
import 'package:flutter_application_3/services/db_helper.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

class HaPrestasiPanenProvider with ChangeNotifier {
  final DBHelper _dbHelper = DBHelper();

  String? _notransaksi;
  late DateTime _tanggal;
  String? _selectedPanenmandor;
  String? _selectedPanenmandor1;
  String? _selectedPanenkerani;
  String? _blok;
  String? _rotasi;
  String? _karyawan;

  List<Map<String, dynamic>> _mandorList = [];
  List<Map<String, dynamic>> _panenList = [];
  List<Map<String, dynamic>> _mandor1List = [];
  List<Map<String, dynamic>> _keraniList = [];
  List<Map<String, dynamic>> _hapanenList = [];
  List<Map<String, dynamic>> _evaluasihapanenList = [];
  List<Map<String, dynamic>> _hapanenHeaderList = [];
  List<Map<String, dynamic>> _hapanenPerBlokList = [];
  List<Map<String, dynamic>> _hapanenPerKaryawanList = [];
  List<Map<String, dynamic>> _hapanenPerKaryawanDetail = [];

  List<Map<String, dynamic>> get hapanenHeader => _hapanenHeaderList;
  List<Map<String, dynamic>> get hapanenperblok => _hapanenPerBlokList;
  List<Map<String, dynamic>> get hapanenperkaryawan => _hapanenPerKaryawanList;
  List<Map<String, dynamic>> get hapanenperkaryawanDetail =>
      _hapanenPerKaryawanDetail;

  String? get selectedMandorValue => _selectedPanenmandor;
  String? get selectedMandor1Value => _selectedPanenmandor1;
  String? get selectedKeraniValue => _selectedPanenkerani;
  String? get blok => _blok;
  String? get rotasi => _rotasi;
  String? get karyawan => _karyawan;

  String? get notransaksi => _notransaksi;

  List<Map<String, dynamic>> get mandor => _mandorList;
  DateTime get tanggal => _tanggal;
  List<Map<String, dynamic>> get hapanen => _hapanenList;

  List<Map<String, dynamic>> get evaluasihapanenList => _evaluasihapanenList;

  String? _nobkm;

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

  void setMandor(String value) {
    _selectedPanenmandor = value;
    notifyListeners();
  }

  void setKrani(String value) {
    _selectedPanenkerani = value;
    notifyListeners();
  }

  void setMandor1(String value) {
    _selectedPanenmandor1 = value;
    notifyListeners();
  }

  Future<void> fetchMandor() async {
    final Database? db = await _dbHelper.database;
    if (db == null) return;

    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      var lokasitugas = prefs.getString('lokasitugas');
      var defaultMandorName = prefs.getString('namakaryawan');
      var karyawanIdbySession = prefs.getString('karyawanid');

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
      //   setMandor1(karyawanIdbySession.toString());
      //   setKrani(karyawanIdbySession.toString());
      // }
    } catch (e, stackTrace) {
      print("🔴 Error: $e");
      print("🔴 Stack Trace: $stackTrace");
      _mandorList = [];
    }

    notifyListeners();
  }

  Future<List<Map<String, dynamic>>> fetchListHaPanen(String? tanggal) async {
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
        ''' SELECT a.*, b.namakaryawan as namakaryawan FROM kebun_panen_ha a LEFT OUTER JOIN datakaryawan b on a.nikmandor=b.karyawanid where a.verify = '0' and a.updateby='$username'$changedata order by notransaksi desc ''';

    final result = await db.rawQuery(query);

    _hapanenList = result;

    notifyListeners();
    return _hapanenList;
  }

  // Future<List<String>> addHeader(
  //     {String notransaksi = '',
  //     required DateTime tanggal,
  //     String usertype = '',
  //     String notransverify = '',
  //     required BuildContext context}) async {
  //   final Database? db = await _dbHelper.database;
  //   if (db == null) return [];

  //   final errors = <String>[];

  //   String notrans = notransaksi;
  //   String tgl = DateFormat('yyyy-MM-dd').format(tanggal);

  //   String? mandor = selectedMandorValue;

  //   final SharedPreferences prefs = await SharedPreferences.getInstance();
  //   var kebun = prefs.getString('lokasitugas');
  //   var username = prefs.getString('username')?.trim();

  //   try {
  //     await db.execute('BEGIN TRANSACTION');

  //     if (usertype != 'checker') {
  //       String qry =
  //           ''' select * FROM kebun_panen_ha where nikmandor='$mandor' and tanggal ='$tgl' and notransaksi <> '$notransverify' and(updateby) ='$username' ''';

  //       final result = await db.rawQuery(qry);

  //       if (result.isNotEmpty) {
  //         errors.add(
  //             'Kode Kemandoran sudah terdaftar ditransaksi lain dengan tanggal yang sama ($tgl) !!');

  //         return errors;
  //       } else {
  //         final errors = await execAddHeader(
  //             usertype: usertype, notransverify: notransverify);

  //         return errors;
  //       }
  //     }
  //   } catch (e) {
  //     await db.execute('ROLLBACK');
  //     debugPrint('Error: $e');
  //     rethrow;
  //   }

  //   notifyListeners();
  //   return errors;
  // }

  // Future<List<String>> execAddHeader(
  //     {String usertype = '', String notransverify = ''}) async {
  //   final Database? db = await _dbHelper.database;
  //   if (db == null) return [];

  //   final errors = <String>[];

  //   final SharedPreferences prefs = await SharedPreferences.getInstance();
  //   var kebun = prefs.getString('lokasitugas');
  //   var username = prefs.getString('username')?.trim();

  //   String? notrans = notransaksi;
  //   String tgl = DateFormat('yyyy-MM-dd').format(_tanggal);
  //   String? mandor = selectedMandorValue;
  //   String? mandor1 = selectedMandor1Value;
  //   String? kerani = selectedKeraniValue;
  //   String? nobkm = _nobkm;
  //   String panenverify = '0';
  //   String panenwhere = "and verify = '0'";

  //   if (usertype != '' && usertype == 'checker') {
  //     panenverify = notransverify;
  //     panenwhere = "and verify = '$panenverify'";
  //   } else {
  //     panenwhere = "and verify <> '0'";

  //     tgl = DateTimeUtils.tanggalSekarang();
  //   }

  //   if (notrans == '') {
  //     errors.add('Transaksi belum disimpan');

  //     return errors;
  //   } else {
  //     String lastupdate = DateTimeUtils.lastUpdate();

  //     String qryInsert =
  //         ''' insert into kebun_panen_ha(notransaksi,tanggal,nobkm,nikmandor,nikmandor1,nikasisten,kerani,updateby,verify,lastupdate,synchronized,cetakan) values(?,?,?,?,?,?,?,?,?,?,?,?)  ''';

  //     String? panenblok = '';
  //     String? panenkaryawan = '';
  //     String? rotasi = '';
  //     if (usertype == 'checker') {
  //       panenblok = blok;
  //       panenkaryawan = karyawan;
  //       rotasi = rotasi;
  //     }

  //     // cek kegiatan
  //     String qryCekKegiatan =
  //         ''' select * from kebun_panen_ha where notransaksi = '$notransaksi' $panenwhere ''';

  //     final cekkegiatan = await db.rawQuery(qryCekKegiatan);

  //     if (cekkegiatan.isNotEmpty) {
  //       errors.add(
  //           'Data dengan tanggal yang sama sudah ada, silahkan isi data detail');

  //       return errors;
  //     } else {
  //       if (usertype == 'checker') {
  //         await db.rawInsert(qryInsert, [
  //           notrans,
  //           tgl,
  //           nobkm,
  //           mandor,
  //           mandor1,
  //           "",
  //           kerani,
  //           username,
  //           panenverify,
  //           lastupdate,
  //           "",
  //           "0"
  //         ]);
  //       } else {
  //         await db.rawInsert(qryInsert, [
  //           notrans,
  //           tgl,
  //           nobkm,
  //           mandor,
  //           mandor1,
  //           "",
  //           kerani,
  //           username,
  //           panenverify,
  //           lastupdate,
  //           "",
  //           "0"
  //         ]);
  //       }
  //     }
  //   }

  //   notifyListeners();
  //   return errors;
  // }

  // Perubahan: addHeader tetap nama & parameter sama, tapi transaksi aman (db.transaction)
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

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    var kebun = prefs.getString('lokasitugas');
    var username = prefs.getString('username')?.trim();

    try {
      // gunakan transaction agar commit/rollback otomatis
      await db.transaction((txn) async {
        if (usertype != 'checker') {
          String qry =
              ''' select * FROM kebun_panen_ha where nikmandor=? and tanggal =? and notransaksi <> ? and updateby =? ''';

          final result = await txn.rawQuery(
              qry, [mandor ?? '', tgl, notransverify, username ?? '']);

          if (result.isNotEmpty) {
            errors.add(
                'Kode Kemandoran sudah terdaftar ditransaksi lain dengan tanggal yang sama ($tgl) !!');

            // throw agar transaction rollback otomatis
            throw StateError('duplicate_kemandoran');
          } else {
            // delegasi ke execAddHeader, berikan txn agar insert bagian dalam menjadi bagian dari transaction ini
            final innerErrors = await execAddHeader(
              usertype: usertype,
              notransverify: notransverify,
              txn: txn, // optional param yang kita tambahkan
            );

            if (innerErrors.isNotEmpty) {
              // jika ada error di execAddHeader, masukkan ke errors dan throw agar rollback
              errors.addAll(innerErrors);
              throw StateError('execAddHeader_failed');
            }

            // jika sampai sini, semua berhasil — transaction callback akan selesai dan COMMIT otomatis
            return; // keluar dari transaction callback (COMMIT)
          }
        } else {
          // Jika usertype == 'checker' dan ada jalur lain (sesuaikan jika ada logika lain)
          // kita tetap perlu memanggil execAddHeader agar header dibuat untuk checker juga
          final innerErrors = await execAddHeader(
            usertype: usertype,
            notransverify: notransverify,
            txn: txn,
          );
          if (innerErrors.isNotEmpty) {
            errors.addAll(innerErrors);
            throw StateError('execAddHeader_failed_checker');
          }
          return;
        }
      });

      // transaction berhasil & committed di sini
      // lakukan checkpoint WAL agar perubahan terlihat saat inspect via adb (opsional)
      try {
        await db.execute('PRAGMA wal_checkpoint(FULL);');
      } catch (e) {
        debugPrint('wal_checkpoint failed: $e');
      }
    } catch (e) {
      // jika errors sudah diisi sebelumnya, kembalikan; jika belum, catat error umum
      debugPrint('addHeader transaction error: $e');
      if (errors.isNotEmpty) return errors;
      return ['Terjadi kesalahan saat menyimpan header: ${e.toString()}'];
    }

    notifyListeners();
    return errors;
  }

// execAddHeader dimodifikasi sedikit: tambahkan optional named param Transaction? txn
// supaya bisa dipanggil dari dalam transaction tanpa mengubah nama method.
// Jika txn == null, perilaku lama (gunakan db) tetap berlaku.
  Future<List<String>> execAddHeader({
    String usertype = '',
    String notransverify = '',
    Transaction?
        txn, // optional: jika diberikan, gunakan ini untuk rawInsert/rawQuery
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
    String panenwhere = "and verify = '0'";

    if (usertype != '' && usertype == 'checker') {
      panenverify = notransverify;
      panenwhere = "and verify = '$panenverify'";
    } else {
      panenwhere = "and verify <> '0'";

      tgl = DateTimeUtils.tanggalSekarang();
    }

    if (notrans == '') {
      errors.add('Transaksi belum disimpan');
      return errors;
    } else {
      String lastupdate = DateTimeUtils.lastUpdate();

      String qryInsert =
          ''' insert into kebun_panen_ha(notransaksi,tanggal,nobkm,nikmandor,nikmandor1,nikasisten,kerani,updateby,verify,lastupdate,synchronized,cetakan) values(?,?,?,?,?,?,?,?,?,?,?,?)  ''';

      String? panenblok = '';
      String? panenkaryawan = '';
      String? rotasi = '';
      if (usertype == 'checker') {
        panenblok = blok;
        panenkaryawan = karyawan;
        rotasi = rotasi;
      }

      // cek kegiatan
      String qryCekKegiatan =
          ''' select * from kebun_panen_ha where notransaksi = ? $panenwhere '''; // maintain original panenwhere logic

      List<Map<String, Object?>> cekkegiatan;
      if (txn != null) {
        // gunakan txn untuk query jika tersedia (bagian dari transaction di parent)
        // perhatikan: panenwhere mungkin mengandung literal; untuk safety kita build parameter list accordingly
        if (usertype == 'checker') {
          cekkegiatan = await txn.rawQuery(
              'select * from kebun_panen_ha where notransaksi = ? and verify = ?',
              [notransaksi, notransverify]);
        } else {
          cekkegiatan = await txn.rawQuery(
              'select * from kebun_panen_ha where notransaksi = ? and verify <> ?',
              [notransaksi, '0']);
        }
      } else {
        // fallback ke db jika txn tidak disuplai
        if (usertype == 'checker') {
          cekkegiatan = await db.rawQuery(
              'select * from kebun_panen_ha where notransaksi = ? and verify = ?',
              [notransaksi, notransverify]);
        } else {
          cekkegiatan = await db.rawQuery(
              'select * from kebun_panen_ha where notransaksi = ? and verify <> ?',
              [notransaksi, '0']);
        }
      }

      if (cekkegiatan.isNotEmpty) {
        errors.add(
            'Data dengan tanggal yang sama sudah ada, silahkan isi data detail');

        return errors;
      } else {
        // lakukan insert menggunakan txn jika ada, atau db jika tidak
        if (txn != null) {
          await txn.rawInsert(qryInsert, [
            notrans,
            tgl,
            nobkm,
            mandor,
            mandor1,
            "",
            kerani,
            username,
            panenverify,
            lastupdate,
            "",
            "0"
          ]);
        } else {
          await db.rawInsert(qryInsert, [
            notrans,
            tgl,
            nobkm,
            mandor,
            mandor1,
            "",
            kerani,
            username,
            panenverify,
            lastupdate,
            "",
            "0"
          ]);
        }
      }
    }

    notifyListeners();
    return errors;
  }

  Future<List<Map<String, dynamic>>> fetchPanenEvaluasiHa(
      String? notransaksi) async {
    final Database? db = await _dbHelper.database;
    if (db == null) return [];

    String strSelecty =
        ''' SELECT b.notransaksi,b.nik, SUM(b.luaspanen) as luaspanen, SUM(b.jjgpanen) as jjgpanen,SUM(b.brondolanpanen) as brondolanpanen,ifnull(a.namakaryawan,ifnull(c.namakaryawan,b.nik)) as namakaryawan,ifnull(b.cetakan,0) as cetakan FROM kebun_panendt_ha b LEFT JOIN datakaryawan a on b.nik=a.karyawanid LEFT JOIN setup_pemanen_baru_ha c on b.nik=c.karyawanid where b.notransaksi='$notransaksi' group by b.nik order by a.namakaryawan,c.namakaryawan ''';

    String strSelectyLain =
        '''  SELECT b.notransaksi,b.nik,SUM(b.jjgpanen) as jjgpanen,SUM(b.brondolanpanen) as brondolanpanen,ifnull(a.namakaryawan,ifnull(c.namakaryawan,b.nik)) as namakaryawan,ifnull(b.cetakan,0) as cetakan FROM kebun_panendt b LEFT JOIN datakaryawan a on b.nik=a.karyawanid LEFT JOIN setup_pemanen_baru c on b.nik=c.karyawanid where b.notransaksi='$notransaksi' group by b.nik order by a.namakaryawan,c.namakaryawan ''';

    final result = await db.rawQuery(strSelecty);
    final resultLain = await db.rawQuery(strSelectyLain);
    if (result.isNotEmpty) {
      _evaluasihapanenList = result;

      // Buat daftar NIK yang sudah ada di result
      final nikList = result.map((row) => "'${row['nik']}'").join(',');

      final strSelectyLainList = '''
        SELECT b.notransaksi,
              b.nik,
              "0" as jjgpanen,
              "0" as brondolanpanen,
              IFNULL(a.namakaryawan, IFNULL(c.namakaryawan, b.nik)) as namakaryawan
        FROM kebun_absen_panen_ha b
        LEFT JOIN datakaryawan a on b.nik = a.karyawanid
        LEFT JOIN setup_pemanen_baru_ha c on b.nik = c.karyawanid
        WHERE b.notransaksi = '$notransaksi'
          AND b.nik NOT IN ($nikList)
        GROUP BY b.nik
        ORDER BY a.namakaryawan, c.namakaryawan
      ''';

      final resultLainList = await db.rawQuery(strSelectyLainList);
      _evaluasihapanenList.addAll(resultLainList);
    } else {
      _evaluasihapanenList = await db.rawQuery(strSelectyLain);
    }

    notifyListeners();
    return _evaluasihapanenList;
  }

  Future<void> deleteEvaluasi({
    String? notransaksi,
    String? nik,
  }) async {
    final Database? db = await _dbHelper.database;
    if (db == null) return;

    await db.transaction((txn) async {
      await txn.delete(
        'kebun_panendt_ha',
        where: 'notransaksi = ? AND nik = ? ',
        whereArgs: [notransaksi, nik],
      );

      // await txn.delete(
      //   '_ha',
      //   where: 'notransaksi = ? AND nik = ? ',
      //   whereArgs: [notransaksi, nik],
      // );

      await txn.delete(
        'kebun_kondisi_buah_ha',
        where: 'notransaksi = ? AND nik = ? ',
        whereArgs: [notransaksi, nik],
      );

      await txn.delete(
        'kebun_mutu_ha',
        where: 'notransaksi = ? AND nik = ? ',
        whereArgs: [notransaksi, nik],
      );

      await txn.delete(
        'kebun_absen_panen_ha',
        where: 'notransaksi = ? AND nik = ? ',
        whereArgs: [notransaksi, nik],
      );

      await txn.delete(
        'kebun_grading_ha',
        where: 'notransaksi = ? AND nik = ? ',
        whereArgs: [notransaksi, nik],
      );
    });

    notifyListeners();
  }

  Future<void> deletePanen(String? notransaksi) async {
    final Database? db = await _dbHelper.database;
    if (db == null) return;

    await db.transaction((txn) async {
      await txn.delete(
        'kebun_panen_ha',
        where: 'notransaksi = ? ',
        whereArgs: [notransaksi],
      );

      await txn.delete(
        'kebun_panendt_ha',
        where: 'notransaksi = ? ',
        whereArgs: [notransaksi],
      );

      // await txn.delete(
      //   '_ha',
      //   where: 'notransaksi = ? AND nik = ? ',
      //   whereArgs: [notransaksi, nik],
      // );

      await txn.delete(
        'kebun_kondisi_buah_ha',
        where: 'notransaksi = ? ',
        whereArgs: [notransaksi],
      );

      await txn.delete(
        'kebun_mutu_ha',
        where: 'notransaksi = ? ',
        whereArgs: [notransaksi],
      );

      await txn.delete(
        'kebun_grading_ha',
        where: 'notransaksi = ? ',
        whereArgs: [notransaksi],
      );
    });

    notifyListeners();
  }

  Future<void> lihatHAPanen({String? notransaksi, String usertype = ''}) async {
    final db = await _dbHelper.database;
    if (db == null) return;

    String where = '';
    if (usertype == 'checker') {
      where = " a.verify='$notransaksi' ";
    } else {
      where = " a.notransaksi='$notransaksi' ";
    }

    String qry =
        '''  SELECT a.*, ifnull(b.namakaryawan,a.nikmandor) as mandor FROM kebun_panen_ha a LEFT JOIN datakaryawan b on a.nikmandor=b.karyawanid where $where order by tanggal desc limit 1 ''';

    final result = await db.rawQuery(qry);
    _hapanenHeaderList = result;

    String qry2 =
        ''' SELECT a.blok, SUM(a.luaspanen) AS luaspanen, b.luasareaproduktif 
										FROM kebun_panendt_ha a
										LEFT JOIN setup_blok b on a.blok = b.kodeblok
										where notransaksi="$notransaksi" group by a.blok order by a.blok   ''';

    final result2 = await db.rawQuery(qry2);
    _hapanenPerBlokList = result2;

    String strSelectylist = '''
      SELECT b.notransaksi,
            b.nik,
            SUM(b.luaspanen) AS luaspanen,
            IFNULL(a.namakaryawan, IFNULL(c.namakaryawan, b.nik)) AS namakaryawan
      FROM kebun_panendt_ha b
      LEFT JOIN datakaryawan a ON b.nik = a.karyawanid
      LEFT JOIN setup_pemanen_baru_ha c ON b.nik = c.karyawanid
      WHERE b.notransaksi = '$notransaksi'
      GROUP BY b.nik
      ORDER BY a.namakaryawan, c.namakaryawan
      ''';

    final resultselect = await db.rawQuery(strSelectylist);

    _hapanenPerKaryawanList = resultselect;

    List<String> allnik = [];

    allnik = resultselect
        .map((row) => row['nik']?.toString() ?? '')
        .where((nik) => nik.isNotEmpty)
        .toList();

    final String txtAllnik = allnik.map((e) => "'$e'").join(',');

    notifyListeners();
  }

  Future<void> lihatHADetailPanen({String? notransaksi, String? nik}) async {
    final db = await _dbHelper.database;
    if (db == null) return;

    String strSelect1 = '''
        SELECT b.*,
              IFNULL(a.namakaryawan, IFNULL(c.namakaryawan, b.nik)) AS namakaryawan
        FROM kebun_panendt_ha b
        LEFT JOIN datakaryawan a ON b.nik = a.karyawanid
        LEFT JOIN setup_pemanen_baru_ha c ON b.nik = c.karyawanid
        WHERE b.notransaksi = '$notransaksi'
          AND b.nik = '$nik'
        ORDER BY b.nik, a.namakaryawan, c.namakaryawan
      ''';

    final result = await db.rawQuery(strSelect1);
    _hapanenPerKaryawanDetail = result;

    print(_hapanenPerKaryawanDetail);

    notifyListeners();
  }

  Future<void> createTablePrestasiPanen() async {
    final Database? db = await _dbHelper.database;
    if (db == null) return;

    await db.execute(
        '''CREATE TABLE IF NOT EXISTS kebun_panen_ha(notransaksi TEXT,tanggal TEXT,nobkm TEXT,nikmandor TEXT,nikmandor1 TEXT,nikasisten TEXT,kerani TEXT,synchronized TEXT,updateby TEXT,cetakan INTEGER,status TEXT,verify TEXT,lastupdate TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL)''');

    await db.execute(
        ''' CREATE TABLE IF NOT EXISTS kebun_panendt_ha(notransaksi TEXT,
                 nik TEXT,
                 blok TEXT,
                 divisi TEXT,
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

    await db.execute(
        '''CREATE TABLE IF NOT EXISTS kebun_bkmsign_ha(notransaksi TEXT,ttd1 BLOB,ttd2 BLOB,ttd3 BLOB)''');

    await db.execute(
        ''' CREATE TABLE IF NOT EXISTS kebun_grading_ha(notransaksi TEXT,blok TEXT,rotasi INT,nik TEXT,kodegrading TEXT,jml TEXT)''');

    await db.execute(
        ''' CREATE TABLE IF NOT EXISTS kebun_mutu_ha(notransaksi TEXT,blok TEXT,rotasi INT,nik TEXT,nourut INT,kodemutu TEXT,jml TEXT) ''');

    await db.execute(
        ''' CREATE TABLE IF NOT EXISTS kebun_kondisi_buah_ha(notransaksi TEXT, blok TEXT,rotasi INT,nik TEXT,kodehama TEXT,jml TEXT) ''');

    await db.execute(
        '''  CREATE TABLE IF NOT EXISTS kebun_gerdang_ha(notransaksi TEXT, nik TEXT,gerdang TEXT) ''');

    await db.execute(
        '''CREATE TABLE IF NOT EXISTS kebun_absen_panen_ha(notransaksi TEXT,nik TEXT)  ''');

    await db.execute(
        ''' CREATE TABLE IF NOT EXISTS setup_pemanen_baru_ha(karyawanid TEXT,nik TEXT,lokasitugas TEXT,subbagian TEXT,namakaryawan TEXT,namakaryawan2 TEXT,status INT)''');

    await db.execute(
        ''' CREATE TABLE IF NOT EXISTS kebun_absen_fingerprint_ha(notransaksi TEXT,nik TEXT) ''');

    await db.execute(
        ''' CREATE TABLE IF NOT EXISTS dataOTG_ha(nik TEXT, tanggal TEXT ,idk1 TEXT ,idk2 TEXT ,idk3 TEXT ,idk4 TEXT)  ''');

    await db.execute(
        '''  CREATE TABLE IF NOT EXISTS upah_karyawan_ha(karyawanid TEXT,tanggal TEXT,periode TEXT,upah TEXT,hk TEXT,basis TEXT,lebih1 TEXT,lebih2 TEXT,lebih3 TEXT,updatetime TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL) ''');

    await db.execute(
        ''' CREATE TABLE IF NOT EXISTS kebun_kehadiran_panen_ha(notransaksi TEXT,kodekegiatan TEXT, kodeorg TEXT,nik TEXT,jhk REAL, absensi TEXT,hasilkerja TEXT, satuanprestasi TEXT, premiprestasi TEXT, insentif TEXT, extrafooding TEXT, jam_overtime TEXT, updateby TEXT,lastupdate TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL) ''');
  }
}
