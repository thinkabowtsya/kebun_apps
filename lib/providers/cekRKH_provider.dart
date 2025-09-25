import 'package:flutter/material.dart';
import 'package:flutter_application_3/services/constant.dart';
import 'package:flutter_application_3/services/db_helper.dart';
import 'package:sqflite/sqflite.dart';

class CekRkhProvider with ChangeNotifier {
  final DBHelper _dbHelper = DBHelper();

  int? _cekrkh;
  int? get cekrkh => _cekrkh;

  Future<List<String>> cekRKHA() async {
    final db = await _dbHelper.database;
    if (db == null) return [];

    final errors = <String>[];
    final String tgl = DateTimeUtils.tanggalSekarang();

    try {
      const qParam = '''
      SELECT nilai 
      FROM setup_parameterappl 
      WHERE kodeparameter = "VALRKH" 
      LIMIT 1
    ''';
      final paramRows = await db.rawQuery(qParam);

      if (paramRows.isEmpty) return errors;

      final int valRkh =
          int.tryParse(paramRows.first['nilai']?.toString() ?? '') ?? 0;

      if (valRkh != 1) return errors;

      const qRkh = '''
      SELECT COUNT(*) AS cnt 
      FROM kebun_rkhht 
      WHERE tanggal = ?
      LIMIT 1
    ''';
      final rkhRows = await db.rawQuery(qRkh, [tgl]);
      final int cnt =
          int.tryParse(rkhRows.first['cnt']?.toString() ?? '0') ?? 0;

      if (cnt == 0) {
        errors.add('Tidak bisa melakukan Transaksi. '
            'Silakan input data RKH untuk tanggal: $tgl, lalu login ulang kembali.');
      }

      return errors;
    } catch (e) {
      errors.add('Gagal cek RKH: ${e.toString()}');
      return errors;
    } finally {
      notifyListeners();
    }
  }
}
