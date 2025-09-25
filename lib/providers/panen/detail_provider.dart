import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_application_3/models/karyawan.dart';
import 'package:flutter_application_3/services/constant.dart';
import 'package:flutter_application_3/services/db_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

class DendaInput {
  final String kode;
  String value;
  final String deskripsi;

  DendaInput({
    required this.kode,
    required this.value,
    required this.deskripsi,
  });

  Map<String, dynamic> toMap() => {
        'kode': kode,
        'value': value,
        'deskripsi': deskripsi,
      };

  @override
  String toString() => '{kode: $kode, value: $value, deskripsi: $deskripsi}';
}

class MutuPanenGroup {
  final String noTransaksi;
  final String noTph;
  final String pemanen;
  final List<DendaInput> dendaList;

  MutuPanenGroup({
    required this.noTransaksi,
    required this.noTph,
    required this.pemanen,
    required this.dendaList,
  });

  @override
  String toString() {
    return 'MutuPanenGroup(noTransaksi: $noTransaksi, noTph: $noTph, pemanen: $pemanen, dendaList: $dendaList)';
  }
}

class DetailProvider extends ChangeNotifier {
  final DBHelper _dbHelper = DBHelper();
  List<Map<String, dynamic>> _sesi = [];
  List<Map<String, dynamic>> _dendaList = [];
  List<Map<String, dynamic>> _blok = [];
  List<Map<String, dynamic>> _tph = [];
  List<Map<String, dynamic>> _detailByTph = [];
  List<Map<String, dynamic>> _lisOptional = [];
  final List<MutuPanenGroup> _mutuPanenData = [];
  List<MutuPanenGroup> get mutuPanenData => _mutuPanenData;

  String? _selectedRotasi;
  String? _capturedImage;

  List<Map<String, dynamic>> get dendalist => _dendaList;
  List<Map<String, dynamic>> get sesi => _sesi;
  List<Map<String, dynamic>> get blok => _blok;
  List<Map<String, dynamic>> get tph => _tph;
  List<Map<String, dynamic>> get detailByTph => _detailByTph;
  List<Map<String, dynamic>> get listoptional => _lisOptional;
  String? get capturedImage => _capturedImage;

  String? get selectedRotasi => _selectedRotasi;

  void setRotasi(String? value) {
    _selectedRotasi = value;
    notifyListeners();
  }

  void setImage(String? value) {
    _capturedImage = value;
    notifyListeners();
  }

  Future<List<String>> addEvaluasi(
      {String usertype = '',
      String? notransaksi,
      String? pemanen,
      DateTime? tanggal,
      String? notph}) async {
    final Database? db = await _dbHelper.database;
    if (db == null) return [];

    final errors = <String>[];

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    var kebun = prefs.getString('lokasitugas');
    var username = prefs.getString('username')?.trim();

    // Pengecekan duplicate (sama seperti Cordova)
    final String tglStr = tanggal?.toIso8601String().substring(0, 10) ??
        ''; // sama logic seperti awal
    final List<Map<String, dynamic>> result = await db.rawQuery(
      '''
    SELECT a.nik as nik 
    FROM kebun_panendt a 
    LEFT JOIN kebun_panen b ON a.notransaksi = b.notransaksi 
    WHERE b.tanggal = ? AND a.notransaksi <> ? AND a.nik = ? AND UPPER(b.updateby) = ? 
    UNION 
    SELECT a.nik as nik 
    FROM kebun_absen_panen a 
    LEFT JOIN kebun_panen b ON a.notransaksi = b.notransaksi 
    WHERE b.tanggal = ? AND a.notransaksi <> ? AND a.nik = ? AND UPPER(b.updateby) = ?
    ''',
      [
        tglStr,
        notransaksi,
        pemanen,
        username?.toUpperCase(),
        tglStr,
        notransaksi,
        pemanen,
        username?.toUpperCase(),
      ],
    );

    if (result.isNotEmpty) {
      errors.add(
          "KARYAWAN sudah terdaftar ditransaksi lain dengan tanggal yang sama (${tglStr})!!");
      return errors;
    }

    // Jika ingin lanjut ke proses berikutnya, tinggal tambahkan logic di bawah sini

    return errors;
  }

  Future<List<String>> execEvaluasi({
    String? usertype,
    String notransaksi = '',
    String? pemanen,
    String blok = '',
    String? rotasi,
    String? action,
    String jjgpanen = '0',
    String? luaspanen,
    String brondolanpanen = '0',
    String? notph,
  }) async {
    String thntanam = '-';
    String bjr = '-';
    String upahkerja = '0';

    final Database? db = await _dbHelper.database;
    if (db == null) return [];

    final errors = <String>[];

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    var kebun = prefs.getString('lokasitugas');
    var username = prefs.getString('username')?.trim();
    final lat_fotoawal = prefs.getDouble('last_latitude');
    final lng_fotoawal = prefs.getDouble('last_longitude');

    String panenverifikasi = '';
    String notransaksiverify = '';
    String cekHeader = '';
    String tahuntanam = '';
    String cek_datadetail = '';
    String? foto = _capturedImage;
    String? base64foto;

    try {
      // Gunakan transaction agar COMMIT/ROLLBACK otomatis
      await db.transaction((txn) async {
        // Validasi awal (tetap mengikuti logika original)
        if ((jjgpanen == '0') && (brondolanpanen == '0')) {
          errors.add('jjg panen dan brondolan tidak boleh 0');
        }

        if (pemanen == '') {
          errors.add('Silahkan pilih karyawan');
        } else if (blok == '') {
          errors.add('Silahkan plih blok');
        } else {
          if (usertype == 'checker') {
            panenverifikasi = " and  verify <> '0'";
            notransaksiverify = 'notransaksi';
          } else {
            panenverifikasi = " and verify = '0'";
            notransaksiverify = notransaksi;
          }

          if (blok.isNotEmpty) {
            String blokKey = blok.length >= 10
                ? blok.substring(0, 10).toUpperCase()
                : blok.toUpperCase();

            final resulttahuntanam = await txn.rawQuery(
              'SELECT * FROM setup_blok WHERE upper(kodeblok) = ? LIMIT 1',
              [blokKey],
            );

            if (resulttahuntanam.isNotEmpty) {
              tahuntanam = resulttahuntanam[0]['tahuntanam']?.toString() ?? '';
            }
          }
        }

        // cek header (mengikuti pola original, pakai parameterized + literal panenverifikasi jika ada)
        final checkResultstr = await txn.rawQuery(
          'select * from kebun_panen where notransaksi = ? ' +
              (panenverifikasi.isNotEmpty ? panenverifikasi : '') +
              ' limit 1',
          [notransaksi],
        );

        if (checkResultstr.isNotEmpty) {
          if (usertype == 'checker') {
            notransaksiverify = 'notransaksi';
          } else {
            notransaksiverify = notransaksi;
          }
          cekHeader = 'ada';
        }

        String lastupdate = DateTimeUtils.lastUpdate();
        String nilaidiv = blok.length >= 10 ? blok.substring(6, 10) : '';

        final strInsert =
            ''' INSERT INTO kebun_panendt(notransaksi, nik, rotasi, blok, divisi, jjgpanen, luaspanen, bjr, brondolanpanen, tahuntanam, upahkerja, status, foto, lat, long, cetakan,lastupdate) values(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)  ''';

        final strDelFirstGerdang =
            "DELETE FROM kebun_gerdang WHERE notransaksi=? AND nik=?;";

        final strCheckDt = '''
        SELECT * FROM kebun_panendt
        WHERE notransaksi=? AND nik=? AND blok=? AND rotasi=?
        ORDER BY blok;
        ''';

        final resultCheckDt = await txn.rawQuery(strCheckDt, [
          notransaksiverify,
          pemanen,
          blok,
          rotasi,
        ]);

        if (resultCheckDt.isNotEmpty) {
          cek_datadetail = "ada";
        }

        // Logic insert/update sesuai original
        if (cekHeader == "") {
          if (usertype == 'checker') {
            if (strInsert.isNotEmpty) {
              await txn.rawInsert(strInsert, [
                notransaksiverify,
                pemanen,
                rotasi,
                notph,
                nilaidiv,
                jjgpanen,
                luaspanen,
                bjr,
                brondolanpanen,
                tahuntanam,
                upahkerja,
                '0', // status
                foto,
                lat_fotoawal,
                lng_fotoawal,
                '0', // cetakan
                lastupdate
              ]);
            }
            // grading insertion jika diperlukan (sesuaikan bila perlu)
          } else {
            errors.add('transaksi belum tersimpan');
            // original menambahkan error lalu tetap lanjut — kita ikuti itu
          }
        } else {
          if (action != "edit") {
            if (cek_datadetail == "ada") {
              errors.add('Data sudah ada');
              // Di original: return errors (di dalam transaction) -> itu menyebabkan transaksi tidak commit/rollback dengan benar.
              // Sekarang: throw agar transaction rollback otomatis, dan kita kembalikan errors di catch luar.
              throw StateError('data_sudah_ada');
            }
          } else {
            // lakukan delete existing rows dalam txn (mengganti nested db.transaction di original)
            await txn.delete(
              'kebun_panendt',
              where: 'notransaksi = ? AND blok = ? AND nik = ? AND rotasi = ?',
              whereArgs: [notransaksiverify, notph, pemanen, rotasi],
            );

            await txn.delete(
              'kebun_kondisi_buah',
              where: 'notransaksi = ? AND blok = ? AND nik = ? AND rotasi = ?',
              whereArgs: [notransaksiverify, notph, pemanen, rotasi],
            );

            await txn.delete(
              'kebun_mutu',
              where: 'notransaksi = ? AND blok = ? AND nik = ? AND rotasi = ?',
              whereArgs: [notransaksiverify, notph, pemanen, rotasi],
            );

            await txn.delete(
              'kebun_grading',
              where: 'notransaksi = ? AND blok = ? AND nik = ? AND rotasi = ?',
              whereArgs: [notransaksiverify, notph, pemanen, rotasi],
            );
          }

          if (strInsert.isNotEmpty) {
            await txn.rawInsert(strInsert, [
              notransaksiverify,
              pemanen,
              rotasi,
              notph,
              nilaidiv,
              jjgpanen,
              luaspanen,
              bjr,
              brondolanpanen,
              tahuntanam,
              upahkerja,
              '0',
              foto,
              lat_fotoawal,
              lng_fotoawal,
              '0',
              lastupdate
            ]);
          }

          if (strInsert.isNotEmpty) {
            // ambil grading (fungsi ini mungkin melakukan logic sendiri — tetap dipanggil seperti original)
            final getGradingValue = getDendaListByTph(
                noTransaksi: notransaksi,
                noTph: notph.toString(),
                pemanen: pemanen.toString());

            if (getGradingValue.isNotEmpty) {
              for (var grading in getGradingValue) {
                final kodeGrading = grading['kode'] ?? '';
                final jumlah = grading['value'] ?? 0;

                await txn.rawInsert(
                  'INSERT INTO kebun_grading(notransaksi, blok, rotasi, nik, kodegrading, jml) VALUES (?, ?, ?, ?, ?, ?)',
                  [notransaksi, notph, rotasi, pemanen, kodeGrading, jumlah],
                );
              }
            }
          }

          // gunakan txn.rawDelete (parameterized)
          await txn.rawDelete(strDelFirstGerdang, [notransaksiverify, pemanen]);
        }

        // Jika sampai sini tanpa throw => transaction callback selesai => COMMIT otomatis
      });
    } catch (e, st) {
      // db.transaction akan otomatis ROLLBACK bila terjadi exception dalam callback
      debugPrint('execEvaluasi transaction error: $e\n$st');
      if (errors.isNotEmpty) return errors;
      return ['Terjadi kesalahan saat menyimpan evaluasi: ${e.toString()}'];
    }

    notifyListeners();
    return errors;
  }

  Future<void> editDataDetail(
      {String? notransaksi,
      String? nik,
      String? blok,
      String? rotasi,
      String usertype = 'user'}) async {
    final Database? db = await _dbHelper.database;
    if (db == null) return;

    if (usertype == 'checker') {
      // todo :
    } else {
      String strSelectDetail =
          ''' select * from kebun_panendt where notransaksi='$notransaksi' and nik='$nik' and blok='$blok' and rotasi='$rotasi' order by blok ''';

      final result = await db.rawQuery(strSelectDetail);

      _detailByTph = result;

      notifyListeners();
    }
  }

  Future<void> deleteDataDetail({
    String? notransaksi,
    String? nik,
    String? blok,
    String? rotasi,
  }) async {
    final Database? db = await _dbHelper.database;
    if (db == null) return;

    await db.transaction((txn) async {
      // DELETE kebun_panendt
      await txn.delete(
        'kebun_panendt',
        where: 'notransaksi = ? AND blok = ? AND nik = ? AND rotasi = ?',
        whereArgs: [notransaksi, blok, nik, rotasi],
      );

      // DELETE kebun_kondisi_buah
      await txn.delete(
        'kebun_kondisi_buah',
        where: 'notransaksi = ? AND blok = ? AND nik = ? AND rotasi = ?',
        whereArgs: [notransaksi, blok, nik, rotasi],
      );

      // DELETE kebun_mutu
      await txn.delete(
        'kebun_mutu',
        where: 'notransaksi = ? AND blok = ? AND nik = ? AND rotasi = ?',
        whereArgs: [notransaksi, blok, nik, rotasi],
      );

      // DELETE kebun_grading
      await txn.delete(
        'kebun_grading',
        where: 'notransaksi = ? AND blok = ? AND nik = ? AND rotasi = ?',
        whereArgs: [notransaksi, blok, nik, rotasi],
      );
    });

    notifyListeners();
  }

  Future<void> listOptional() async {
    final Database? db = await _dbHelper.database;
    if (db == null) return;

    String qryDenda = '''select * from kebun_kodedenda''';

    final result = await db.rawQuery(qryDenda);

    _lisOptional = result;

    notifyListeners();
  }

  void saveMutuPanen({
    required String noTransaksi,
    required String noTph,
    required String pemanen,
    required List<DendaInput> dendaList,
  }) {
    // Cari data, kalau sudah ada update, kalau belum tambah baru
    final idx = _mutuPanenData.indexWhere((e) =>
        e.noTransaksi == noTransaksi &&
        e.noTph == noTph &&
        e.pemanen == pemanen);

    if (idx != -1) {
      _mutuPanenData[idx] = MutuPanenGroup(
        noTransaksi: noTransaksi,
        noTph: noTph,
        pemanen: pemanen,
        dendaList: dendaList,
      );
    } else {
      _mutuPanenData.add(
        MutuPanenGroup(
          noTransaksi: noTransaksi,
          noTph: noTph,
          pemanen: pemanen,
          dendaList: dendaList,
        ),
      );
    }

    // Update _dendaList agar selalu List<Map<String, dynamic>>
    _dendaList = dendaList.map((d) => d.toMap()).toList();

    notifyListeners();
  }

  // Untuk load data (ambil list denda by group)
  List<DendaInput> getDendaInput(
      String noTransaksi, String noTph, String pemanen) {
    final found = _mutuPanenData.where((e) =>
        e.noTransaksi == noTransaksi &&
        e.noTph == noTph &&
        e.pemanen == pemanen);
    if (found.isNotEmpty) {
      return found.first.dendaList;
    }
    return [];
  }

  void resetDendaValueByKode({
    required String noTransaksi,
    required String noTph,
    required String pemanen,
    required String kode,
  }) {
    final idx = _mutuPanenData.indexWhere((e) =>
        e.noTransaksi == noTransaksi &&
        e.noTph == noTph &&
        e.pemanen == pemanen);

    if (idx != -1) {
      for (var denda in _mutuPanenData[idx].dendaList) {
        if (denda.kode == kode) {
          denda.value = '';
        }
      }
      _dendaList = _mutuPanenData[idx]
          .dendaList
          .where((d) => d.value != '0' && d.value.trim().isNotEmpty)
          .map((d) => d.toMap())
          .toList();

      notifyListeners();
    }
  }

  List<Map<String, dynamic>> getDendaListByTph({
    required String noTransaksi,
    required String noTph,
    required String pemanen,
  }) {
    try {
      final group = _mutuPanenData.firstWhere(
        (e) =>
            e.noTransaksi == noTransaksi &&
            e.noTph == noTph &&
            e.pemanen == pemanen,
      );
      return group.dendaList
          .where((d) => d.value.trim().isNotEmpty)
          .map((d) => d.toMap())
          .toList();
    } catch (e) {
      // Jika tidak ketemu, return []
      return [];
    }
  }
}
