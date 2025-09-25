// import 'package:flutter_application_3/services/db_helper.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:sqflite/sqflite.dart';

// class NoTransaksiHelper {
//   final DBHelper _dbHelper = DBHelper();

//   Future<String> generateNoTransaksi({required String nametable}) async {
//     final Database? db = await _dbHelper.database;

//     final prefs = await SharedPreferences.getInstance();
//     final karyawanId = prefs.getString('karyawanid') ?? '';
//     final lokasiTugas = prefs.getString('lokasitugas') ?? '';

//     // Format bagian tetap nomor transaksi
//     String noserid = karyawanId.length >= 10
//         ? karyawanId.substring(karyawanId.length - 10)
//         : karyawanId.padRight(10, '0');
//     noserid = noserid.replaceFirst(RegExp(r'^0*'), '');
//     if (noserid.isEmpty) noserid = '0';

//     // Format tanggal
//     final date = DateTime.now();
//     final Y = date.year.toString();
//     final m = date.month.toString().padLeft(2, '0');
//     final d = date.day.toString().padLeft(2, '0');
//     final H = date.hour.toString().padLeft(2, '0');
//     final i = date.minute.toString().padLeft(2, '0');
//     final s = date.second.toString().padLeft(2, '0');

//     // Format dasar nomor transaksi tanpa running number
//     final baseNoTransaksi = '$lokasiTugas$Y$m$d$H$i$s$noserid';

//     // Query untuk mendapatkan running number terakhir
//     int runningNumber =
//         await _getLastRunningNumber(db!, baseNoTransaksi, noserid);

//     return '$baseNoTransaksi-${runningNumber.toString().padLeft(3, '0')}';
//   }

//   Future<int> _getLastRunningNumber(
//       Database db, String baseNoTransaksi, String userid) async {
//     try {
//       // Query untuk mencari nomor transaksi dengan pola yang sama
//       final results = await db.rawQuery('''
//         SELECT MAX(id) as max_running
//         FROM kebun_aktifitas
//       ''');

//       if (results.isNotEmpty && results.first['max_running'] != null) {
//         return (results.first['max_running'] as int) + 1;
//       }
//       return 1; // Default jika tidak ada data sebelumnya
//     } catch (e) {
//       print('Error getting running number: $e');
//       return 1; // Fallback jika terjadi error
//     }
//   }
// }

import 'package:shared_preferences/shared_preferences.dart';

/// Generator No Transaksi: YYYYMMDDHHmmss + optional suffix
/// Meniru Cordova `noTransaksi(type)` + kontrol sumber suffix (userid/karyawanid)
class NoTransaksiHelper {
  /// type:
  /// - 'number'   -> YYYYMMDDHHmmss
  /// - 'number2'  -> YYYYMMDDHHmmss-<suffix>
  /// - 'nouserid' -> ''   (meniru Cordova yang return kosong)
  /// - 'no_do'    -> DOYYYYMMDDHHmmss
  /// - default    -> YYYYMMDDHHmmss-<suffix>
  ///
  /// suffixSource:
  /// - 'userid' (default, mirip Cordova)
  /// - 'karyawanid'
  /// - null  (tidak ada suffix)
  ///
  /// suffixOverride: paksa suffix manual (mengabaikan suffixSource)
  Future<String> generate({
    String? type,
    String? suffixSource = 'userid',
    String? suffixOverride,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    // print(prefs);
    // Ambil nilai suffix
    String suffix = '';
    if (suffixOverride != null) {
      suffix = suffixOverride;
    } else if (suffixSource == 'karyawanid') {
      suffix = prefs.getString('karyawanid') ?? '';
    } else if (suffixSource == 'userid') {
      suffix = prefs.getString('userid') ?? '';
    } else {
      suffix = '';
    }

    final now = DateTime.now();
    final Y = now.year.toString();
    final m = now.month.toString().padLeft(2, '0');
    final d = now.day.toString().padLeft(2, '0');
    final H = now.hour.toString().padLeft(2, '0');
    final i = now.minute.toString().padLeft(2, '0');
    final s = now.second.toString().padLeft(2, '0');

    final ts = '$Y$m$d$H$i$s';
    final nouserid = suffix.isEmpty ? '' : '-$suffix';

    switch (type) {
      case 'number':
        return ts;
      case 'number2':
        return '$ts$nouserid';
      case 'nouserid':
        return ''; // meniru Cordova kamu
      case 'no_do':
        return 'DO$ts';
      default:
        return '$ts$nouserid';
    }
  }

  /// Kompatibel dengan panggilan lama
  @Deprecated('Gunakan generate({type, suffixSource})')
  Future<String> generateNoTransaksi({required String nametable}) async {
    return generate();
  }
}
