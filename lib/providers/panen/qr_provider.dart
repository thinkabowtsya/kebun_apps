import 'package:flutter/material.dart';
import 'package:flutter_application_3/services/db_helper.dart';
import 'package:sqflite/sqflite.dart';

class PanenQrProvider extends ChangeNotifier {
  final DBHelper _dbHelper = DBHelper();

  String? _qrData;
  String? get qrData => _qrData;

  Map<String, dynamic>? _lastDetailRow;
  Map<String, dynamic>? get lastDetailRow => _lastDetailRow;

  List<Map<String, dynamic>>? _lastGradingRows;
  List<Map<String, dynamic>> get lastGradingRows => _lastGradingRows ?? [];

  Future<void> loadPanenQr(
      String? noTrans, String? blok, String? rotasi, String? nik) async {
    final Database? db = await _dbHelper.database;
    if (db == null) return;

    // 1. Query header/detail panen
    String sql = '''
    SELECT a.blok, a.rotasi, a.jjgpanen, a.brondolanpanen, b.tanggal, a.lastupdate,
           COALESCE(c.namakaryawan, d.namakaryawan) AS namakaryawan, a.nik,
           a.notransaksi, a.status, ifnull(a.cetakan,0) as cetakan,
           b.nikmandor, b.nikmandor1, b.nikasisten, b.kerani, a.luaspanen
      FROM kebun_panendt a
      JOIN kebun_panen b ON a.notransaksi=b.notransaksi
      LEFT JOIN datakaryawan c ON a.nik=c.karyawanid
      LEFT JOIN setup_pemanen_baru d ON a.nik=d.karyawanid
     WHERE a.notransaksi='$noTrans' AND a.blok='$blok' AND a.rotasi='$rotasi' AND a.nik='$nik'
  ''';
    final rows = await db.rawQuery(sql);

    print(rows);
    if (rows.isEmpty) {
      _qrData = null;
      _lastDetailRow = null;
      notifyListeners();
      return;
    }
    final row = rows.first;

    _lastDetailRow = row;
    // 2. Query grading (denda panen/mutu buah)
    String sqlGrading = '''
    SELECT a.kodegrading, a.jml,b.deskripsi
      FROM kebun_grading a left join kebun_kodedenda as b on a.kodegrading=b.iddenda 
     WHERE a.notransaksi='$noTrans' AND a.blok='$blok' AND a.nik='$nik' AND a.rotasi='$rotasi'
  ''';
    final gradingRows = await db.rawQuery(sqlGrading);

    _lastGradingRows = gradingRows;
    // 3. Packing grading ke format g#kode:jml;kode:jml
    String gradingString = 'g#';
    if (gradingRows.isNotEmpty) {
      gradingString +=
          gradingRows.map((g) => '${g['kodegrading']}:${g['jml']}').join(';');
    }

    _qrData = [
      row['blok'] ?? '',
      row['notransaksi'] ?? '',
      row['nik'] ?? '',
      row['jjgpanen'] ?? '',
      row['brondolanpanen'] ?? '',
      row['tanggal'] ?? '',
      row['status'] ?? '',
      row['cetakan'] ?? '',
      row['rotasi'] ?? '',
      row['nikmandor'] ?? '',
      row['nikmandor1'] ?? '',
      row['nikasisten'] ?? '',
      row['kerani'] ?? '',
      row['luaspanen'] ?? '',
      gradingString,
    ].join('|');

    notifyListeners();
  }
}
