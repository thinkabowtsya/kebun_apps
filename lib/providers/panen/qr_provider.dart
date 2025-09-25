import 'package:flutter/material.dart';
import 'package:flutter_application_3/services/db_helper.dart';
import 'package:flutter_application_3/services/panen_encrypt.dart';
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

    final sql = '''
    SELECT a.blok, a.rotasi, a.jjgpanen, a.brondolanpanen, b.tanggal, a.lastupdate,
           COALESCE(c.namakaryawan, d.namakaryawan) AS namakaryawan, a.nik,
           a.notransaksi, a.status, ifnull(a.cetakan,0) as cetakan,
           b.nikmandor, b.nikmandor1, b.nikasisten, b.kerani, a.luaspanen
      FROM kebun_panendt a
      JOIN kebun_panen b ON a.notransaksi=b.notransaksi
      LEFT JOIN datakaryawan c ON a.nik=c.karyawanid
      LEFT JOIN setup_pemanen_baru d ON a.nik=d.karyawanid
     WHERE a.notransaksi=? AND a.blok=? AND a.rotasi=? AND a.nik=?
  ''';

    final rows = await db
        .rawQuery(sql, [noTrans ?? '', blok ?? '', rotasi ?? '', nik ?? '']);

    if (rows.isEmpty) {
      _qrData = null;
      _lastDetailRow = null;
      notifyListeners();
      return;
    }

    final row = rows.first;
    _lastDetailRow = row;

    final sqlGrading = '''
    SELECT a.kodegrading, a.jml, b.deskripsi
      FROM kebun_grading a
      LEFT JOIN kebun_kodedenda b ON a.kodegrading=b.iddenda
     WHERE a.notransaksi=? AND a.blok=? AND a.nik=? AND a.rotasi=?
  ''';
    final gradingRows = await db.rawQuery(
        sqlGrading, [noTrans ?? '', blok ?? '', nik ?? '', rotasi ?? '']);
    _lastGradingRows = gradingRows;

    String gradingString = 'g#';
    if (gradingRows.isNotEmpty) {
      gradingString +=
          gradingRows.map((g) => '${g['kodegrading']}:${g['jml']}').join(';');
    }

    final notrans = (row['notransaksi'] ?? '').toString();
    final nikkaryawan = (row['nik'] ?? '').toString();
    final jjgpanen = (row['jjgpanen'] ?? '').toString();
    final brondolan = (row['brondolanpanen'] ?? '').toString();
    final tanggal = (row['tanggal'] ?? '').toString();
    final status = (row['status'] ?? '').toString();
    final cetakan = (row['cetakan'] ?? 0).toString();
    final rotVal = (row['rotasi'] ?? '').toString();
    final nikmandor = (row['nikmandor'] ?? '').toString();
    final nikmandor1 = (row['nikmandor1'] ?? '').toString();
    final nikasisten = (row['nikasisten'] ?? '').toString();
    final kerani = (row['kerani'] ?? '').toString();
    final luaspanen = (row['luaspanen'] ?? '').toString();
    final blokVal = (row['blok'] ?? '').toString();

    final notransEncript = PanenEncrypt.notransEncrtypt2(notrans);
    final nikkaryawanEncript = PanenEncrypt.encryptNumberZeroFirst(nikkaryawan);
    final jjgpanenEncript = PanenEncrypt.encryptNumber(jjgpanen);
    final brondolanEncript = PanenEncrypt.encryptNumber(brondolan);
    final nikmandorEncript = PanenEncrypt.encryptNumberZeroFirst(nikmandor);
    final nikasistenEncript = PanenEncrypt.encryptNumberZeroFirst(nikasisten);
    final nikmandor1Encript = PanenEncrypt.encryptNumberZeroFirst(nikmandor1);
    final keraniEncript = PanenEncrypt.encryptNumberZeroFirst(kerani);
    final tanggalEncript = PanenEncrypt.dateEncrtypt(tanggal);
    final luaspanenEncript = PanenEncrypt.encryptNumber(luaspanen);

    final dataParts = <String>[
      blokVal,
      notransEncript,
      nikkaryawanEncript,
      jjgpanenEncript,
      brondolanEncript,
      tanggalEncript,
      status,
      cetakan,
      rotVal,
      nikmandorEncript,
      nikmandor1Encript,
      nikasistenEncript,
      keraniEncript,
      luaspanenEncript,
    ];

    var data = dataParts.join('|');

    if (gradingRows.isNotEmpty) {
      data = '$data|$gradingString';
    } else {
      data = '$data|g#';
    }

    _qrData = data;
    notifyListeners();
  }
}
