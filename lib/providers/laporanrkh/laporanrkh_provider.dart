import 'package:flutter/material.dart';
import 'package:flutter_application_3/services/db_helper.dart';
import 'package:sqflite/sqflite.dart';

class LaporanrkhProvider with ChangeNotifier {
  final DBHelper _dbHelper = DBHelper();

  List<Map<String, dynamic>> _laporanRkhList = [];
  List<Map<String, dynamic>> _kehadiranList = [];
  List<Map<String, dynamic>> _headerList = [];
  List<Map<String, dynamic>> _prestasiList = [];
  List<Map<String, dynamic>> _tenagakerjaList = [];
  List<Map<String, dynamic>> _materialList = [];

  List<Map<String, dynamic>> get laporanRkhList => _laporanRkhList;
  List<Map<String, dynamic>> get kehadiranList => _kehadiranList;
  List<Map<String, dynamic>> get headerList => _headerList;
  List<Map<String, dynamic>> get prestasiList => _prestasiList;
  List<Map<String, dynamic>> get tenagakerjaList => _tenagakerjaList;
  List<Map<String, dynamic>> get materialList => _materialList;

  Future<void> loadRkh() async {
    final Database? db = await _dbHelper.database;
    if (db == null) return;

    String query = ''' SELECT a.*, c.namakaryawan FROM kebun_rkhht a 
                  LEFT JOIN datakaryawan  c ON a.asisten = c.karyawanid 
                  group by notransaksi 
                  order by tanggal desc   ''';

    final result = await db.rawQuery(query);

    _laporanRkhList = result;

    notifyListeners();
  }

  Future<void> listRkh(String id) async {
    final Database? db = await _dbHelper.database;
    if (db == null) return;

    String query = ''' SELECT * FROM kebun_rkh_dt a 
                  LEFT JOIN setup_kegiatan b ON b.kodekegiatan = a.kodekegiatan 
                  LEFT JOIN datakaryawan  c ON a.mandor = c.karyawanid 
                  where notransaksi='$id' ''';

    final result = await db.rawQuery(query);
    _kehadiranList = result;
    notifyListeners();
  }

  Future<void> detailRKH(
      {String? id, String? kodeblok, String? kodekegiatan}) async {
    final Database? db = await _dbHelper.database;
    if (db == null) return;

    String query =
        ''' SELECT  a.*, b.namakegiatan, c.namakaryawan, d.luasareaproduktif, d.jumlahpokok, b.satuan 
                  FROM kebun_rkh_dt a
                  LEFT JOIN setup_kegiatan b ON b.kodekegiatan = a.kodekegiatan 
                  LEFT JOIN datakaryawan  c ON a.mandor = c.karyawanid 
                  LEFT JOIN setup_blok d ON a.kodeblok = d.kodeblok
                  where notransaksi='$id' and a.kodeblok ='$kodeblok' and a.kodekegiatan='$kodekegiatan' ''';

    String query2 = '''  SELECT b.*, c.*  
                  FROM kebun_rkh_dt a
                  LEFT JOIN kebun_rkh_dtmaterial b ON a.notransaksi = b.notransaksi 
                  LEFT JOIN datakaryawan  c ON a.mandor = c.karyawanid 
                  LEFT JOIN log_5masterbarang c ON b.kodebarang = c.kodebarang 
                  where a.notransaksi='$id' and b.notransaksi != '' ''';

    final result = await db.rawQuery(query);
    final result2 = await db.rawQuery(query2);

    _materialList = result2;
    _headerList = result;

    notifyListeners();
  }
}
