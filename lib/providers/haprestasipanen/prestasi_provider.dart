import 'package:flutter/material.dart';
import 'package:flutter_application_3/services/constant.dart';
import 'package:flutter_application_3/services/db_helper.dart';
import 'package:intl/intl.dart';
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

class PrestasiProvider with ChangeNotifier {
  final DBHelper _dbHelper = DBHelper();

  List<Map<String, dynamic>> _karyawan = [];
  List<Map<String, dynamic>> _karyawanPanengerdang = [];
  List<Map<String, dynamic>> _afdeling = [];

  List<Map<String, dynamic>> _pemanen = [];
  List<Map<String, dynamic>> _blok = [];
  List<Map<String, dynamic>> _tph = [];

  String _luasareaproduktif = '';

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
  String get luasareaproduktif => _luasareaproduktif;

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

  void setBlok(String value) {
    _selectedBlok = value;
    notifyListeners();
  }

  void setAfdeling(String value) {
    _selectedAfdeling = value;
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

        final result = await db.rawQuery(strQuery);

        _karyawan = result;
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

  Future<void> selectTphHA(String blok) async {
    final Database? db = await _dbHelper.database;
    if (db == null) return;

    String luasareaproduktif = '';

    String strSelect = '''
    SELECT luasareaproduktif 
    FROM setup_blok 
    WHERE kodeblok = '$blok'
  ''';

    final result = await db.rawQuery(strSelect);

    if (result.isNotEmpty) {
      for (var row in result) {
        luasareaproduktif = (row['luasareaproduktif'] ?? '').toString();
        _luasareaproduktif = luasareaproduktif;
      }
    }

    notifyListeners();
  }

  Future<void> loadPrestasiHaPanen(
      {String? pemanen, String? notransaksi}) async {
    final Database? db = await _dbHelper.database;
    if (db == null) return;

    String strSelect =
        ''' SELECT a.notransaksi, a.nik, a.blok, a.luaspanen, b.namakaryawan FROM kebun_panendt_ha a
						LEFT JOIN datakaryawan b on a.nik = b.karyawanid 
						where notransaksi='$notransaksi' order by a.blok, a.nik  ''';

    final result = await db.rawQuery(strSelect);

    _listPrestasi = result;

    print(result);

    notifyListeners();
  }

  Future<List<String>> addEvaluasi({
    String? notransaksi,
    required DateTime tgltransaksi,
    String? luaspanen,
    String? luasblok,
  }) async {
    final Database? db = await _dbHelper.database;
    if (db == null) return [];

    final errors = <String>[];
    String lastupdate = DateTimeUtils.lastUpdate();
    String formattedDate = DateFormat('yyyy-MM-dd').format(tgltransaksi);

    // ✅ 1. Validasi kosong / nol
    final luasPanenVal = double.tryParse(luaspanen ?? '');
    final luasBlokVal = double.tryParse(luasblok ?? '');

    if (luasPanenVal == null || luasPanenVal == 0) {
      errors.add('Inputan luas panen tidak boleh kosong');
      return errors;
    }

    // ✅ 2. Validasi luas panen > luas blok
    if (luasBlokVal == null) {
      errors.add('Inputan luas blok tidak valid');
      return errors;
    }
    if (luasPanenVal > luasBlokVal) {
      errors.add(
          'Inputan luas panen $luaspanen (Ha) melebihi luas blok $luasblok (Ha)');
      return errors;
    }

    // ✅ 3. Hapus data lama
    await db.delete(
      'kebun_panendt_ha',
      where: 'notransaksi = ? AND nik = ? AND blok = ?',
      whereArgs: [notransaksi, selectedPemanen, selectedBlok],
    );

    // ✅ 4. Ambil total luas panen yang sudah ada di blok + tanggal yang sama
    const cekBlokQuery = '''
    SELECT b.tanggal, a.* 
    FROM kebun_panendt_ha a
    LEFT JOIN kebun_panen_ha b 
      ON a.notransaksi = b.notransaksi
    WHERE blok = ? AND tanggal = ?
    ORDER BY lastupdate DESC
  ''';

    double totalLuasPanen = 0;
    final result =
        await db.rawQuery(cekBlokQuery, [selectedBlok, formattedDate]);
    for (var row in result) {
      totalLuasPanen +=
          double.tryParse(row['luaspanen']?.toString() ?? '0') ?? 0;
    }

    // ✅ 5. Hitung total baru jika tambah data sekarang
    double totalSemua = (luasPanenVal + totalLuasPanen);

    if (totalSemua > luasBlokVal) {
      errors.add(
          'Total inputan luas panen ${totalSemua.toStringAsFixed(2)} (Ha) melebihi luas blok $luasblok (Ha)');
      return errors;
    }

    print('masuk sini');
    // ✅ 6. Insert data baru
    await db.insert('kebun_panendt_ha', {
      'notransaksi': notransaksi,
      'nik': selectedPemanen,
      'rotasi': '',
      'blok': selectedBlok,
      'divisi': '',
      'jjgpanen': '',
      'luaspanen': luasPanenVal.toStringAsFixed(2),
      'bjr': '',
      'brondolanpanen': '',
      'tahuntanam': '',
      'upahkerja': '',
      'status': '',
      'foto': '',
      'lat': '',
      'long': '',
      'cetakan': '0',
      'lastupdate': lastupdate,
    });

    print(await db.rawQuery('select * from kebun_panendt_ha'));

    notifyListeners();
    return errors; // kosong berarti sukses
  }

  Future<void> deleteEvaluasi({
    String? notransaksi,
    String? nik,
    String? blok,
  }) async {
    final Database? db = await _dbHelper.database;
    if (db == null) return;

    await db.transaction((txn) async {
      await txn.delete(
        'kebun_panendt_ha',
        where: 'notransaksi = ? AND nik = ?  AND blok = ?',
        whereArgs: [notransaksi, nik, blok],
      );

      // await txn.delete(
      //   '_ha',
      //   where: 'notransaksi = ? AND nik = ? ',
      //   whereArgs: [notransaksi, nik],
      // );

      await txn.delete(
        'kebun_kondisi_buah_ha',
        where: 'notransaksi = ? AND nik = ?  AND blok = ? ',
        whereArgs: [notransaksi, nik, blok],
      );

      await txn.delete(
        'kebun_mutu_ha',
        where: 'notransaksi = ? AND nik = ?  AND blok = ?',
        whereArgs: [notransaksi, nik, blok],
      );

      await txn.delete(
        'kebun_grading_ha',
        where: 'notransaksi = ? AND nik = ?  AND blok = ?',
        whereArgs: [notransaksi, nik, blok],
      );
    });

    notifyListeners();
  }
}
