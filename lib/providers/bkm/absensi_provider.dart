import 'package:flutter/material.dart';
import 'package:flutter_application_3/services/db_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

class AbsensiProvider with ChangeNotifier {
  final DBHelper _dbHelper = DBHelper();

  List<Map<String, dynamic>> _absensi = [];
  List<Map<String, dynamic>> _absensiList = [];
  List<Map<String, dynamic>> _absensiFull = [];
  String? _noakunDefault;
  Map<String, dynamic>? _noakun;
  String? _selectedAbsensiValue;

  List<Map<String, dynamic>> get absensi => _absensi;
  List<Map<String, dynamic>> get absensiList => _absensiList;
  List<Map<String, dynamic>> get absensiFull => _absensiFull;
  String? get noakunDefault => _noakunDefault;
  Map<String, dynamic>? get noakun => _noakun;
  String? get selectedAbsensiValue => _selectedAbsensiValue;

  bool _shouldRefresh = false;

  bool get shouldRefresh => _shouldRefresh;

  void setShouldRefresh(bool value) {
    _shouldRefresh = value;
    notifyListeners();
  }

  Future<void> selectNoAkunDefault() async {
    final Database? db = await _dbHelper.database;
    if (db == null) return;

    try {
      String qry =
          '''SELECT kodeabsen as key,keterangan as val from sdm_5absensi''';

      final result = await db.rawQuery(qry);
      final defaultItem = result.firstWhere((item) => item['key'] == 'H');

      _absensi = result;
      setSelectedAbsensiValue(defaultItem['key'].toString());

      String qry2 =
          ''' SELECT nilai from setup_parameterappl where kodeparameter="mblnoakun"  ''';

      final result2 = await db.rawQuery(qry2);
      if (result2.isNotEmpty) {
        final hasil = result2[0]; // Map<String, Object?>
        _noakunDefault = hasil['nilai'] as String?; // Casting ke String?
        setNoAkunDefaultValue(_noakunDefault); // jika fungsi menerima String?
      }

      String qty3 =
          ''' SELECT noakun as key, namaakun as val from keu_5akun  ''';

      final result3 = await db.rawQuery(qty3);
      final itemsAkun = result3.firstWhere(
        (item) => item['key'] == _noakunDefault,
        orElse: () => {},
      );

      setNoAkunValue(itemsAkun);
    } catch (e, stackTrace) {
      print("🔴 Error: $e");
      print("🔴 Stack Trace: $stackTrace");
    }
  }

  Future<List<String>> simpanAbsensi({
    String? absensi,
    String? karyawan,
    String? keterangan,
    int hk = 0,
    String? insentif,
    String? asisten,
    String? mandor,
    String? mandor1,
    String? kodekegiatan,
    String? notransaksi,
  }) async {
    final Database? db = await _dbHelper.database;
    if (db == null) return [];
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? username = prefs.getString('username')?.trim();
    final errors = <String>[];

    // SQL templates (tetap sama agar logika tidak berubah)
    String strCheck =
        ''' select nik,jhk from kebun_kehadiran where notransaksi=? and nik=? and updateby=? and kodekegiatan='ABSENSI' ''';

    String strCheck2 =
        ''' select nik from kebun_kehadiran where notransaksi=? and nik=? and updateby=? and kodekegiatan='ABSENSI' ''';

    String strInsert =
        ''' INSERT INTO kebun_kehadiran(notransaksi,satuanprestasi,kodekegiatan,nik,jhk,absensi,insentif,hasilkerja,jam_overtime,updateby) VALUES (?,?,?,?,?,?,?,?,?,?)  ''';

    String strUpdate =
        ''' UPDATE kebun_kehadiran SET satuanprestasi= ?,jhk = ?,absensi = ?,jam_overtime = ?,insentif = ?,updateby = ? where notransaksi= ? and nik= ? and kodekegiatan = 'ABSENSI'  ''';

    try {
      await db.transaction((txn) async {
        // cek apakah sudah ada data absensi untuk user ini (parameterized)
        final strResultCheck =
            await txn.rawQuery(strCheck, [notransaksi, karyawan, username]);

        if (strResultCheck.isNotEmpty) {
          // seperti behavior awal: isi errors dan rollback (lempar agar txn rollback)
          errors.add('Data sudah ada, Terinput Lewat Transaksi!');
          throw StateError('exist_absensi');
        } else {
          // cek kehadiran lain (ada/tidak)
          final strResult2Check =
              await txn.rawQuery(strCheck2, [notransaksi, karyawan, username]);

          String keyNoakun = noakun?['key'];

          if (strResult2Check.isEmpty) {
            // insert baru
            await txn.rawInsert(strInsert, [
              notransaksi,
              keyNoakun,
              kodekegiatan,
              karyawan,
              hk,
              absensi,
              insentif,
              '0',
              keterangan,
              username
            ]);
          } else {
            // update existing
            await txn.rawUpdate(strUpdate, [
              keyNoakun,
              hk,
              absensi,
              keterangan,
              insentif,
              username,
              notransaksi,
              karyawan
            ]);
          }
        }
        // jika callback selesai tanpa throw => COMMIT otomatis
      });

      // Setelah commit: refresh data / panggil fetch seperti kode lama
      fetchAbsensiDetail(notrans: notransaksi, username: username);
      _shouldRefresh = true;
    } catch (e, st) {
      debugPrint('simpanAbsensi transaction error: $e\n$st');
      // jika ada pesan validasi di errors, kembalikan itu
      if (errors.isNotEmpty) {
        return errors;
      }
      // jika bukan validasi, kembalikan pesan umum sesuai pola lama
      return ['Terjadi kesalahan saat menyimpan absensi: ${e.toString()}'];
    }

    return errors;
  }

  Future<void> fetchAbsensiDetail({String? notrans, String? username}) async {
    final Database? db = await _dbHelper.database;
    if (db == null) return;
    String strSelect =
        ''' SELECT b.namakaryawan,a.jhk,a.absensi,a.notransaksi,a.nik,a.kodekegiatan,a.insentif,a.jam_overtime FROM kebun_kehadiran a left join datakaryawan b  on a.nik = b.karyawanid where a.notransaksi = '$notrans' and a.updateby='$username' and a.kodekegiatan = 'ABSENSI'   ''';

    final result = await db.rawQuery(strSelect);

    _absensiList = result;

    notifyListeners();
  }

  Future<void> fetchLoadAbsensi({String? notrans}) async {
    final Database? db = await _dbHelper.database;
    if (db == null) return;

    String strSelect =
        '''  select a.keterangan , count(T1.absensi) as jumlah from (select absensi from kebun_kehadiran where notransaksi = '$notrans' and kodekegiatan = 'ABSENSI' group by nik,absensi) as T1 left join sdm_5absensi a on t1.absensi = a.kodeabsen group by a.kodeabsen    ''';

    final result = await db.rawQuery(strSelect);

    _absensiFull = result;

    notifyListeners();
  }

  Future<void> deleteAbsensi({String? notransaksi, String? nik}) async {
    final db = await _dbHelper.database;
    if (db == null) return;

    print('masuk delete');

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? username = prefs.getString('username')?.trim();

    await db.delete(
      'kebun_kehadiran',
      where:
          'notransaksi = ? AND nik = ? AND updateby = ? AND kodekegiatan = ? ',
      whereArgs: [notransaksi, nik, username, 'ABSENSI'],
    );
    _shouldRefresh = true;
    fetchAbsensiDetail(notrans: notransaksi, username: username);

    notifyListeners();
  }

  void setSelectedAbsensiValue(String? value) {
    _selectedAbsensiValue = value;
    notifyListeners();
  }

  void setNoAkunDefaultValue(String? value) {
    _noakunDefault = value;
    notifyListeners();
  }

  void setNoAkunValue(Map<String, dynamic>? value) {
    _noakun = value;
    notifyListeners();
  }
}
