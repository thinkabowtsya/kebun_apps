import 'package:flutter/material.dart';
import 'package:flutter_application_3/services/db_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

class MaterialProvider with ChangeNotifier {
  final DBHelper _dbHelper = DBHelper();

  List<Map<String, dynamic>> _gudang = [];
  List<Map<String, dynamic>> _material = [];
  List<Map<String, dynamic>> _materialList = [];

  String? _selectedGudangValue;
  String? _selectedMaterialValue;
  num? _kuantitashaMaterial = 0;

  List<Map<String, dynamic>> get gudang => _gudang;
  List<Map<String, dynamic>> get material => _material;
  List<Map<String, dynamic>> get materialList => _materialList;

  String? get selectedGudangValue => _selectedGudangValue;
  String? get selectedMaterialValue => _selectedMaterialValue;
  num? get kuantitashaMaterial => _kuantitashaMaterial;

  bool _shouldRefresh = false;

  bool get shouldRefresh => _shouldRefresh;

  void setShouldRefresh(bool value) {
    _shouldRefresh = value;
    notifyListeners();
  }

  void setGudangValue(String value) {
    _selectedGudangValue = value;
  }

  void setMaterialValue(String value) {
    _selectedMaterialValue = value;
  }

  void setKuantitasHAMaterialValue(num value) {
    _kuantitashaMaterial = value;
  }

  void initialize({
    required String? notransaksi,
    required String? kodekegiatan,
    required String? kodeorg,
  }) {}

  Future<void> fetchDataGudang({
    required String? notransaksi,
    required String? kodekegiatan,
    required String? kodeorg,
  }) async {
    final Database? db = await _dbHelper.database;
    if (db == null) return;

    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      var lokasitugas = prefs.getString('lokasitugas');

      final String? kodeOrg = kodeorg != null && kodeorg.length >= 6
          ? kodeorg.substring(0, 6)
          : null;

      const String sql = '''
          SELECT * FROM gudangtransaksi
          WHERE afdeling = ? AND status = '1';
        ''';

      final result = await db.rawQuery(sql, [kodeOrg]);
      print(result);
      // final result = await db.rawQuery(sql, [lokasitugas]);

      _gudang = result.isNotEmpty ? result : [];
    } catch (e, stackTrace) {
      print("🔴 Error: $e");
      print("🔴 Stack Trace: $stackTrace");
      _gudang = [];
    }

    notifyListeners();
  }

  Future<void> fetchMaterial(
      {String val = '', String selected = '', String? kodekegiatan}) async {
    print(val);
    final Database? db = await _dbHelper.database;
    if (db == null) return;

    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      var lokasitugas = prefs.getString('lokasitugas');

      const String sql = '''
          SELECT * from setup_kegiatannorma a left join log_5masterbarang b on a.kodebarang = b.kodebarang where a.kodekegiatan = ?;
        ''';

      final result = await db.rawQuery(sql, [kodekegiatan]);
      // print(result);

      // final result = await db.rawQuery(sql, [lokasitugas]);

      _material = result.isNotEmpty ? result : [];
    } catch (e, stackTrace) {
      print("🔴 Error: $e");
      print("🔴 Stack Trace: $stackTrace");
      _gudang = [];
    }
  }

  Future<void> simpanMaterial(
      {required String? gudang,
      required String? material,
      required String? qty,
      required String? notrans,
      required String? kodekegiatan,
      required String? kodeorg,
      required BuildContext context}) async {
    final errors = <String>[];
    final Database? db = await _dbHelper.database;

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    var username = prefs.getString('username')?.trim();

    try {
      await db?.execute('BEGIN TRANSACTION');

      String strCheck =
          '''   SELECT * FROM kebun_aktifitas where notransaksi= ? and updateby= ?''';

      final resultCheck = await db!.rawQuery(strCheck, [notrans, username]);

      if (resultCheck.isEmpty) {
        errors.add('gagal transaksi');
      }
      await db.delete(
        'kebun_pakaimaterial',
        where:
            'notransaksi = ? AND kodekegiatan = ? AND kodeorg = ? AND kodebarang = ?',
        whereArgs: [notrans, kodeorg, material],
      );
      final _kuantitashaMaterial = kuantitashaMaterial ?? '0';

      String strInsert =
          '''  INSERT INTO  kebun_pakaimaterial(notransaksi,kodekegiatan,kodeorg,gudang,kodebarang,kwantitasha,kwantitas,updateby) values('$notrans','$kodekegiatan','$kodeorg','$gudang','$material','$_kuantitashaMaterial','$qty','$username') ''';

      await db.rawQuery(strInsert);
      await db.execute('COMMIT');

      _shouldRefresh = true;
      Navigator.pop(context, {
        'success': true,
        'notransaksi': notrans,
      });

      notifyListeners();
    } catch (e) {
      await db?.execute('ROLLBACK');
      debugPrint('❌ Error saat simpan prestasi: $e');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> fetchMaterialByBkm({
    String? notrans,
    String? kodekegiatan,
    String? kodeorg,
  }) async {
    print('fetch material');
    final Database? db = await _dbHelper.database;
    if (db == null) return [];

    try {
      await db.execute('BEGIN TRANSACTION');

      String strQry =
          '''  SELECT a.notransaksi,a.kodekegiatan,a.kodeorg,b.kodebarang as kodebarang ,b.namabarang as namabarang ,b.satuan  as satuan,a.kwantitas as kwantitas,a.kwantitasha as kwantitasha FROM kebun_pakaimaterial a LEFT OUTER JOIN log_5masterbarang b on a.kodebarang=b.kodebarang where a.notransaksi= '$notrans' and a.kodekegiatan = '$kodekegiatan' and a.kodeorg = '$kodeorg' order by b.namabarang  ''';

      final result = await db.rawQuery(strQry);

      String strCheck = '''  select * from kebun_pakaimaterial ''';

      _materialList = result;

      await db.execute('COMMIT');

      notifyListeners();
      return result;
    } catch (e) {
      await db.execute('ROLLBACK');
      debugPrint('❌ Error : $e');
      rethrow;
    }

    // return result;
  }

  Future<void> deleteMaterial({
    required String notransaksi,
    required String kodeorg,
    required String kodekegiatan,
    required String kodebarang,
  }) async {
    final db = await _dbHelper.database;
    if (db == null) return;

    await db.delete(
      'kebun_pakaimaterial',
      where:
          'notransaksi = ? AND kodeorg = ? AND kodekegiatan = ? AND kodebarang = ?',
      whereArgs: [notransaksi, kodeorg, kodekegiatan, kodebarang],
    );

    _shouldRefresh = true;

    notifyListeners();
  }
}
