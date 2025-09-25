import 'package:flutter/material.dart';
import 'package:flutter_application_3/services/db_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

class GerdangItem {
  GerdangItem({
    required this.id,
    required this.nama,
    required this.tipeKey,
    required this.tipeLabel,
  });

  final String id; // karyawanid
  final String nama; // nama karyawan
  final String tipeKey; // BRD / BHS / STD
  final String tipeLabel; // label yang ditampilkan
}

class PrestasiProvider extends ChangeNotifier {
  final DBHelper _dbHelper = DBHelper();
  List<Map<String, dynamic>> _karyawan = [];
  List<Map<String, dynamic>> _karyawanPanengerdang = [];
  List<Map<String, dynamic>> _afdeling = [];

  List<Map<String, dynamic>> _pemanen = [];
  List<Map<String, dynamic>> _blok = [];
  List<Map<String, dynamic>> _tph = [];

  List<Map<String, dynamic>> get karyawanPanengerdang => _karyawanPanengerdang;

  final List<GerdangItem> _listGerdang = [];
  List<Map<String, dynamic>> _listPrestasi = [];
  List<GerdangItem> get listGerdang => _listGerdang;
  List<Map<String, dynamic>> get listPrestasi => _listPrestasi;

  final List<Map<String, String>> _tipePanen = const [
    {'key': 'STD', 'val': 'Panen Standar'},
    {'key': 'BRD', 'val': 'Borongan Brondolan'},
    {'key': 'BHS', 'val': 'BHS + Kutip'},
  ];

  List<Map<String, dynamic>> get pemanen => _pemanen;
  List<Map<String, dynamic>> get blok => _blok;
  List<Map<String, dynamic>> get tph => _tph;
  List<Map<String, dynamic>> get karyawan => _karyawan;

  List<Map<String, dynamic>> get afdeling => _afdeling;

  String? _selectedAfdeling;
  String? _selectedPemanen;
  String? _selectedFilterkaryawan;
  String? _selectedBlok;
  String? _selectedTph;

  String? get selectedAfdeling => _selectedAfdeling;
  String? get selectedPemanen => _selectedPemanen;
  String? get selectedBlok => _selectedBlok;
  String? get selectedFilterkaryawan => _selectedFilterkaryawan;
  String? get selectedTph => _selectedTph;

  List<Map<String, String>> get tipepanen => _tipePanen;

  bool addGerdang(
      {required String tipeKey, required Map<String, dynamic> karyawan}) {
    final String id = karyawan['karyawanid'].toString();
    if (_listGerdang.any((g) => g.id == id)) return false; // sudah ada

    final String tipeLabel =
        _tipePanen.firstWhere((e) => e['key'] == tipeKey)['val']!;

    _listGerdang.add(GerdangItem(
      id: id,
      nama: karyawan['namakaryawan'] ?? '',
      tipeKey: tipeKey,
      tipeLabel: tipeLabel,
    ));

    notifyListeners();
    return true;
  }

  /// Hapus gerdang berdasar id
  void removeGerdang(String id) {
    _listGerdang.removeWhere((g) => g.id == id);
    notifyListeners();
  }

  Future<void> setPemanen(String value) async {
    _selectedPemanen = value;
    notifyListeners();
  }

  Future<void> setFilterKaryawan(String value) async {
    _selectedFilterkaryawan = value;
    notifyListeners();
  }

  void setAfdeling(String value) {
    _selectedAfdeling = value;
    notifyListeners();
  }

  void setBlok(String value) {
    _selectedBlok = value;
    notifyListeners();
  }

  void setTph(String value) {
    _selectedTph = value;
    notifyListeners();
  }

  Future<List<String>> loadkaryawan(dynamic value, String? panenmandor) async {
    final Database? db = await _dbHelper.database;
    if (db == null) return [];
    final errors = <String>[];

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    var lokasitugas = prefs.getString('lokasitugas');
    var subbagian = prefs.getString('subbagian');

    if (value == 'all') {
      String selectdata =
          'karyawanid,nik,namakaryawan,namakaryawan2,subbagian,lokasitugas';
      String filter = '''and lokasitugas = '$lokasitugas' ''';

      String str =
          ''' SELECT * FROM datakaryawan where pemanen ='1' and subbagian != ' ' and gajipokok != 0 $filter order by namakaryawan    ''';

      final result = await db.rawQuery(str);

      _karyawan = result;
    } else if (value == 'bydivision') {
      String selectdata =
          'karyawanid,nik,namakaryawan,namakaryawan2,subbagian,lokasitugas';
      String strquery =
          ''' SELECT * FROM datakaryawan where  pemanen ='1' and subbagian != ' ' and gajipokok != 0  and subbagian=$subbagian order by namakaryawan  ''';

      final result = await db.rawQuery(strquery);

      _karyawan = result;

      String strQuery2 = '';

      strQuery2 =
          '''  select $selectdata FROM datakaryawan where kodejabatan not in (select nilai from setup_parameterappl where kodeparameter in ('MDRPNN','ASST','KRNPNN','MDRPNN','KASIE'))  ''';
      strQuery2 +=
          ' UNION SELECT $selectdata FROM setup_pemanen_baru where subbagian=$subbagian order by subbagian,namakaryawan';

      final result2 = await db.rawQuery(strQuery2);

      _karyawanPanengerdang = result2;
    } else if (value == 'byborongan') {
      String selectdata =
          'supplierid as karyawanid,namasupplier as namakaryawan,kodeblok as namakaryawan2,supplierid as nik,kodeblok as subbagian';

      String strquery = ''' select $selectdata from log_spk  ''';

      final result = await db.rawQuery(strquery);

      _karyawan = result;
    } else if (value == 'bygroup') {
      String selectdata =
          'karyawanid as karyawanid,nik as nik,namakaryawan as namakaryawan,namakaryawan2 as namakaryawan2,subbagian as subbagian,lokasitugas as lokasitugas';
      String selectdata2 =
          'karyawanid,nik,namakaryawan,namakaryawan2,subbagian,lokasitugas';

      String query =
          ''' SELECT * FROM kemandoran where mandorid = '$panenmandor'  ''';

      final result = await db.rawQuery(query);

      if (result.isNotEmpty) {
        String strQuery =
            ''' SELECT b.*  FROM kemandoran a left join datakaryawan b on b.karyawanid = a.karyawanid where a.mandorid = '$panenmandor' and b.namakaryawan IS NOT NULL order by b.namakaryawan  ''';

        final result2 = await db.rawQuery(strQuery);

        _karyawan = result2;
      } else {
        String strQuery =
            ''' SELECT * FROM datakaryawan where  pemanen ='1' and subbagian='$subbagian' order by namakaryawan  ''';

        final result2 = await db.rawQuery(strQuery);

        _karyawan = result2;

        errors.add('Kemandoran belum memiliki pemanen terdaftar !!');
        return errors;
      }

      String strquery2 = '';

      strquery2 =
          ''' select $selectdata FROM datakaryawan where kodejabatan not in (select nilai from setup_parameterappl where kodeparameter in ('MDRPNN','ASST','KRNPNN','MDRPNN','KASIE'))  ''';
      strquery2 +=
          'UNION SELECT $selectdata FROM setup_pemanen_baru order by subbagian,namakaryawan';

      final resultGerdang = await db.rawQuery(strquery2);

      _karyawanPanengerdang = resultGerdang;
    } else if (value == 'pemanenbaru') {
      String selectdata =
          'karyawanid,nik,namakaryawan,namakaryawan2,subbagian,lokasitugas';

      String strquery =
          ''' select $selectdata  FROM setup_pemanen_baru where subbagian='$subbagian' order by namakaryawan''';

      final result = await db.rawQuery(strquery);

      _karyawan = result;

      String strquery2 = '';

      strquery2 =
          ''' select $selectdata FROM datakaryawan where kodejabatan not in (select nilai from setup_parameterappl where kodeparameter in ('MDRPNN','ASST','KRNPNN','MDRPNN','KASIE'))  ''';
      strquery2 +=
          'UNION SELECT $selectdata from setup_pemanen_baru order by subbagian,namakaryawan';

      final resultgerdang = await db.rawQuery(strquery2);

      _karyawanPanengerdang = resultgerdang;
    }

    notifyListeners();
    return errors;
  }

  Future<void> loadAfdeling({selection = ''}) async {
    final Database? db = await _dbHelper.database;
    if (db == null) return;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    var lokasitugas = prefs.getString('lokasitugas');

    String strquery =
        ''' SELECT kodeorganisasi as key,namaorganisasi as val FROM organisasi where tipeorganisasi = 'AFDELING' and induk = '$lokasitugas' order by kodeorganisasi  ''';

    final result = await db.rawQuery(strquery);

    _afdeling = result;

    notifyListeners();
  }

  Future<void> selectBlok(String? afdeling) async {
    final Database? db = await _dbHelper.database;
    if (db == null) return;

    String strQuery = '''
        SELECT 
          kodeblok as key,
          kodeblok || ' / ' || tahuntanam || ' / ' || statusblok as val
        FROM setup_blok
        WHERE kodeblok LIKE '$afdeling%'
        ORDER BY kodeblok
      ''';

    final result = await db.rawQuery(strQuery);

    _blok = result;

    notifyListeners();
  }

  Future<void> selectTph(String? blok) async {
    final Database? db = await _dbHelper.database;
    if (db == null) return;

    String strQuery = '''
      SELECT 
        kode AS key,
        substr(kode, 1, 10) || ' / ' || substr(kode, 11, 3) AS val
      FROM setup_tph
      WHERE kode LIKE '%$blok%'
      ORDER BY kode
    ''';

    final result = await db.rawQuery(strQuery);

    _tph = result;

    notifyListeners();
  }

  Future<void> loadDataprestasipanen(
      {String? pemanen, String? notransaksi}) async {
    final Database? db = await _dbHelper.database;
    if (db == null) return;

    String strSelectPrestasi =
        ''' SELECT * FROM kebun_panendt where notransaksi='$notransaksi' and nik = '$pemanen' order by blok  ''';

    final result = await db.rawQuery(strSelectPrestasi);

    _listPrestasi = result;
    notifyListeners();
  }

  void reset() {
    _listPrestasi = [];
    _selectedPemanen = '';

    notifyListeners();
  }

  Future<void> editPrestasi(
      {String? notransaksi, String? nik, String? usertype = 'user'}) async {
    final Database? db = await _dbHelper.database;
    if (db == null) return;

    String strselect =
        ''' SELECT b.notransaksi,b.rotasi,b.nik,b.blok,b.jjgpanen,b.luaspanen,b.tahuntanam,b.brondolanpanen,ifnull(a.namakaryawan,'undefined') as tipekaryawan,ifnull(c.namakaryawan,'undefined') as tipekaryawanbaru FROM kebun_panendt b LEFT JOIN datakaryawan a on b.nik=a.karyawanid LEFT JOIN setup_pemanen_baru c on b.nik=c.karyawanid where b.notransaksi='$notransaksi' and b.nik = '$nik'  ''';

    final result = await db.rawQuery(strselect);

    if (result.isNotEmpty) {
      _listPrestasi = result;
      _shouldRefresh = true;

      if (usertype == 'checker') {
      } else {
        _selectedFilterkaryawan = 'all';
        String strQuery =
            ''' select * from datakaryawan where karyawanid='$nik' ''';

        final dataKaryawan = await db.rawQuery(strQuery);

        _karyawan = dataKaryawan;
        // _selectedPemanen = nik;

        // print(_selectedPemanen);
      }
    }

    notifyListeners();
  }

  bool _shouldRefresh = false;

  bool get shouldRefresh => _shouldRefresh;

  void setShouldRefresh(bool value) {
    _shouldRefresh = value;
    notifyListeners();
  }

  Future<void> deleteEvaluasi({
    String? notransaksi,
    String? nik,
    String? blok,
    String? rotasi,
  }) async {
    final Database? db = await _dbHelper.database;
    if (db == null) return;

    await db.transaction((txn) async {
      await txn.delete(
        'kebun_panendt',
        where: 'notransaksi = ? AND nik = ? ',
        whereArgs: [notransaksi, nik],
      );

      await txn.delete(
        'kebun_kondisi_buah',
        where: 'notransaksi = ? AND nik = ? ',
        whereArgs: [notransaksi, nik],
      );

      await txn.delete(
        'kebun_absen_panen',
        where: 'notransaksi = ? AND nik = ? ',
        whereArgs: [notransaksi, nik],
      );

      await txn.delete(
        'kebun_grading',
        where: 'notransaksi = ? AND nik = ? ',
        whereArgs: [notransaksi, nik],
      );
    });

    notifyListeners();
  }
}
