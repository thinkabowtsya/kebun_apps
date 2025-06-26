import 'package:flutter_application_3/services/db_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

class NoTransaksiHelper {
  final DBHelper _dbHelper = DBHelper();

  Future<String> generateNoTransaksi() async {
    final Database? db = await _dbHelper.database;

    final prefs = await SharedPreferences.getInstance();
    final karyawanId = prefs.getString('karyawanid') ?? '';
    final lokasiTugas = prefs.getString('lokasitugas') ?? '';

    // Format bagian tetap nomor transaksi
    String noserid = karyawanId.length >= 10
        ? karyawanId.substring(karyawanId.length - 10)
        : karyawanId.padRight(10, '0');
    noserid = noserid.replaceFirst(RegExp(r'^0*'), '');
    if (noserid.isEmpty) noserid = '0';

    // Format tanggal
    final date = DateTime.now();
    final Y = date.year.toString();
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    final H = date.hour.toString().padLeft(2, '0');
    final i = date.minute.toString().padLeft(2, '0');
    final s = date.second.toString().padLeft(2, '0');

    // Format dasar nomor transaksi tanpa running number
    final baseNoTransaksi = '$lokasiTugas$Y$m$d$H$i$s$noserid';

    // Query untuk mendapatkan running number terakhir
    int runningNumber =
        await _getLastRunningNumber(db!, baseNoTransaksi, noserid);

    return '$baseNoTransaksi-${runningNumber.toString().padLeft(3, '0')}';
  }

  Future<int> _getLastRunningNumber(
      Database db, String baseNoTransaksi, String userid) async {
    try {
      // Query untuk mencari nomor transaksi dengan pola yang sama
      final results = await db.rawQuery('''
        SELECT MAX(id) as max_running
        FROM kebun_aktifitas 
      ''');
 
      if (results.isNotEmpty && results.first['max_running'] != null) {
        return (results.first['max_running'] as int) + 1;
      }
      return 1; // Default jika tidak ada data sebelumnya
    } catch (e) {
      print('Error getting running number: $e');
      return 1; // Fallback jika terjadi error
    }
  }
}
