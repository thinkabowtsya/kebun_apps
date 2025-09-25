import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_application_3/services/constant.dart';
import 'package:flutter_application_3/services/db_helper.dart';
import 'package:flutter_application_3/services/photo_helper.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

class SyncProvider with ChangeNotifier {
  final DBHelper _dbHelper = DBHelper();

  String? _selectedJenistransaksiValue;

  String? get selectedJenistransaksiValue => _selectedJenistransaksiValue;

  String? _selectedNotransaksi;
  String? get selectedNotransaksi => _selectedNotransaksi;

  void setSelectedNotransaksi(String? value) {
    _selectedNotransaksi = value;
    notifyListeners();
  }

  String dataheader = '';

  String _selectedJenis = '';
  String get selectedJenis => _selectedJenis;

  List<Map<String, dynamic>> _currentList = [];
  List<Map<String, dynamic>> get currentList => _currentList;

  Future<void> setSelectedJenisTransaksi({
    required String jenis,
    required String? tglIso8601,
  }) async {
    _selectedJenistransaksiValue = jenis;
    notifyListeners(); // Trigger rebuild UI setelah update value

    if (tglIso8601 != null && tglIso8601.isNotEmpty) {
      await getListing(tgl: tglIso8601, tipeTransaksi: jenis);
    }
  }

  // Method utama ambil data
  Future<void> getListing({
    required String? tgl,
    required String? tipeTransaksi,
    String? noTransaksi,
    String? flag,
  }) async {
    final db = await _dbHelper.database;
    if (db == null) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      String user = prefs.getString('username')!.trim();

      final dateStr = tgl?.split('T').first ?? ''; // 2025‑07‑02

      List<Map<String, dynamic>> result = [];

      switch (tipeTransaksi) {
        case 'bkm':
          final res = await db.rawQuery('''
      SELECT a.notransaksi,a.tanggal,b.kodeorg,
             c.namakaryawan AS leader
        FROM kebun_aktifitas a
        LEFT JOIN kebun_prestasi b ON a.notransaksi = b.notransaksi
        LEFT JOIN datakaryawan   c ON a.nikmandor  = c.karyawanid
       WHERE synchronized="" and a.tanggal      = ?
         AND a.updateby LIKE ?
    ''', [dateStr, '%$user%']);

          result = res
              .map((row) => {
                    'id': row['notransaksi'] ?? '-',
                    'header': row['notransaksi'] ?? '-',
                    'detail': row['kodeorg'] ?? '-',
                    'detail2': row['leader'] ?? '-',
                  })
              .toList();

          break;

        case 'spb':
          final String panenha =
              ''' SELECT * FROM kebun_spbht where synchronized="" and tanggal='$tgl' and updateby like '%$user%'  ''';

          final res = await db.rawQuery(panenha);

          // result = res;
          result = res
              .map((row) => {
                    'id': row['nospb'] ?? '-',
                    'header': row['nospb'] ?? '-',
                    'detail': row['afdeling'] ?? '-',
                    'detail2': row['tanggal'] ?? '-',
                  })
              .toList();

        case 'kranitransport':
          final String kranitransport =
              ''' SELECT * FROM kebun_aktifitas where synchronized="" and tanggal='$tgl' and updateby like '%$user%'  ''';

          result = await db.rawQuery(kranitransport);
          break;

        case 'panen':
          final res = await db.rawQuery('''
            SELECT a.notransaksi,a.verify,a.tanggal,b.namakaryawan as leader,b.namakaryawan2 as leader2,a.nikmandor,a.nikmandor1 FROM kebun_panen a left join datakaryawan b on a.nikmandor = b.karyawanid where
              tanggal      = ? and
              updateby = ?
          ''', [dateStr, '$user']);

          result = res
              .map((row) => {
                    'id': row['notransaksi'] ?? '-',
                    'header': row['notransaksi'] ?? '-',
                    'detail': row['leader'] ?? '-',
                    'detail2': row['leader2'] ?? '-',
                  })
              .toList();

          // result = await db.rawQuery(panen);
          break;
        case 'panenha':
          final res = await db.rawQuery('''
            SELECT a.notransaksi,a.verify,a.tanggal,b.namakaryawan as leader,b.namakaryawan2 as leader2,a.nikmandor,a.nikmandor1 FROM kebun_panen_ha a left join datakaryawan b on a.nikmandor = b.karyawanid where synchronized="" and
              tanggal      = ? and
              updateby = ?
          ''', [dateStr, '$user']);

          result = res
              .map((row) => {
                    'id': row['notransaksi'] ?? '-',
                    'header': row['notransaksi'] ?? '-',
                    'detail': row['leader'] ?? '-',
                    'detail2': row['leader2'] ?? '-',
                  })
              .toList();

          // result = await db.rawQuery(panen);
          break;

        case 'sensuspokok':
          String sensuspokok =
              ''' SELECT a.*, b.namakaryawan as mandor1 FROM kebun_pokokht a LEFT JOIN datakaryawan b on a.kemandoran = b.karyawanid where a.synchronized="" and a.tanggal='$tgl' and a.updateby like '%$user%' ''';

          result = await db.rawQuery(sensuspokok);

          break;

        case 'sensusproduksi':
          String sensusproduksi =
              ''' SELECT * FROM kebun_produksiht where synchronized="" and tanggal='$tgl' and updateby like '%$user%'  ''';
          result = await db.rawQuery(sensusproduksi);

          break;

        case 'taksasi':
          String taksasi =
              ''' SELECT a.*, b.namakaryawan FROM header_taksasi a left join datakaryawan b on a.nikmandor =b.karyawanid where a.synchronized="0" and a.tanggal='$tgl' and a.updateby like '%$user'  ''';
          result = await db.rawQuery(taksasi);

          break;

        default:
          result = [];
      }

      _currentList = result.isNotEmpty
          ? result
          : [
              {
                'notransaksi': '-',
                'tanggal': '-',
                'kodeorg': '-',
                'leader': 'Data kosong',
              }
            ];
    } catch (e) {
      debugPrint('Error getListing: $e');
      _currentList = [
        {
          'notransaksi': '-',
          'tanggal': '-',
          'kodeorg': '-',
          'leader': 'Error',
        }
      ];
    }
    notifyListeners();
  }

  Future<List<String>> syncTrans({
    DateTime? selectedDate,
    String? jenistransaksi,
    String? notransaksi,
    String? flag,
  }) async {
    final errors = <String>[];

    // ignore: unrelated_type_equality_checks
    if (notransaksi == null || jenistransaksi == null) {
      errors.add('tidak memiliki data');
      return errors;
    } else {
      if (jenistransaksi == 'bkm') {
        final errors = await syncBkm(selectedDate, notransaksi);

        return errors;
      } else if (jenistransaksi == 'spb') {
        final errors = await syncSpb(selectedDate, notransaksi);

        return errors;
      } else if (jenistransaksi == 'panen') {
        final errors = await syncPanen(selectedDate, notransaksi, '');

        return errors;
      } else if (jenistransaksi == 'panenha') {
        final errors = await syncPanenha(selectedDate, notransaksi, '');

        return errors;
      }
    }

    notifyListeners();
    return errors;
  }

  Future<List<String>> syncPanenha(
      DateTime? tgl, String? notransaksi, String? flag) async {
    final errors = <String>[];
    final Database? db = await _dbHelper.database;
    if (db == null) return [];

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    // var server = prefs.getString('server');
    var server = ApiConstants.apiBaseUrlTesting;
    var subbagian = prefs.getString('subbagian');
    var kebun = prefs.getString('kebun');
    String? kodeorg = subbagian?.substring(0, 4);
    String? username = prefs.getString('username')?.trim();
    var password = prefs.getString('password');
    String formattedDate = DateFormat('yyyy-MM-dd').format(tgl!);

    try {
      await db.execute('BEGIN TRANSACTION');

      String str =
          ''' SELECT * FROM kebun_panen_ha where notransaksi="$notransaksi" and tanggal="$formattedDate" limit 1 ''';

      final result = await db.rawQuery(str);

      print(str);
      String strData = "";
      for (var i = 0; i < result.length; i++) {
        final row = result[i];

        strData += "&notransaksi=${row['notransaksi']}";
        strData += "&tanggalpanen=${row['tanggal']}";
        strData += "&kodeorg=$kodeorg";
        strData += "&divisi=$subbagian";
        strData += "&mandor=${row['nikmandor']}";
        strData += "&createtime=${row['lastupdate']}";
        strData += "&deviceid=''"; // kalau memang kosong
      }

// gabungkan param utama + strData
      final param = "method=transaction"
          "&tipeData=panenha"
          "&datatransfer=datautama"
          "&username=$username"
          "&password=$password"
          "&uuid=''"
          "$strData"; // langsung tempel di belakang

      String str2 =
          ''' SELECT notransaksi FROM kebun_panendt_ha where notransaksi='$notransaksi' ''';

      final resultCheck = await db.rawQuery(str2);

      if (resultCheck.isNotEmpty) {
        final url = "$server/owlMobile.php";
        final response = await sendPostRequest(url, param);

        if (response != null && response.statusCode == 200) {
          final json = jsonDecode(response.body);

          String notransaksi = json['notransaksi'];
          String tanggal = json['tanggal'];
          String noref = json['noref'];
          bool isError = json['err']['err'] == 'true';

          String strDt =
              ''' SELECT a.*, b.luasareaproduktif FROM kebun_panendt_ha a left join setup_blok b on a.blok=b.kodeblok where notransaksi='$notransaksi' ''';

          final resultDt = await db.rawQuery(strDt);

          List<List<String>> panenDt = [];

          for (var i = 0; i < resultDt.length; i++) {
            final row = resultDt[i];

            panenDt.add([
              row['notransaksi']?.toString() ?? '',
              row['blok']?.toString() ?? '',
              row['luasareaproduktif']?.toString() ?? '',
              row['nik']?.toString() ?? '',
              row['luaspanen']?.toString() ?? '',
            ]);
          }

          final errors = await insertHAPanenDetail(
              notransaksi: notransaksi,
              noref: noref,
              tanggal: tanggal,
              data: panenDt);

          return errors;
        }
      }

      return errors;
    } catch (e) {
      print(e);
      await db.execute('ROLLBACK');
      debugPrint('Error: $e');
      rethrow;
    }
  }

  Future<List<String>> insertHAPanenDetail(
      {String? notransaksi,
      String? noref,
      String? tanggal,
      List<List<String>>? data,
      int number = 0}) async {
    final errors = <String>[];
    final Database? db = await _dbHelper.database;
    if (db == null) return [];

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    // var server = prefs.getString('server');
    var server = ApiConstants.apiBaseUrlTesting;
    var subbagian = prefs.getString('subbagian');
    var username = prefs.getString('username');
    var password = prefs.getString('password');
    String? kodeorg = subbagian?.substring(0, 4);

    try {
      await db.execute('BEGIN TRANSACTION');

      const int limit = 50;
      int forloop = number + limit;
      if (forloop >= data!.length) {
        forloop = data.length;
      }

      List<String> blok = [];
      List<String> luasblok = [];
      List<String> pemanen = [];
      List<String> hapanen = [];

      int urut = 0;

      for (var x = number; x < forloop; x++) {
        final row = data[x];

        luasblok.add(row[2]);
        pemanen.add(row[3]);
        hapanen.add(row[4]);
        blok.add(row[1]);

        urut++;
      }

      Map<String, String> listData = {
        'notransaksi': notransaksi.toString(),
        'noref': noref.toString(),
        'blok': blok.join(','),
        'luasblok': luasblok.join(','),
        'pemanen': pemanen.join(','),
        'hapanen': hapanen.join(','),
      };

      print(listData);

      Map<String, String> paramToDatabase = {
        'method': 'transaction',
        'tipeData': 'panenha',
        'datatransfer': 'datadetail',
        'username': username.toString(),
        'password': password.toString(),
        'uuid': '',
        ...listData
      };

      final url = "$server/owlMobile.php";
      final response = await sendPostRequest(url, paramToDatabase);

      if (response != null && response.statusCode == 200) {
        final json = jsonDecode(response.body);

        String notransaksi = json['notransaksi'].toString();
        String tanggal = json['tanggal'].toString();
        String noref = json['noref'].toString();
        bool isError = json['err']['err'] == 'true';

        final errors = await checkTransactionHAPanenComplete(
            notransaksi: notransaksi, noref: noref, tanggal: tanggal);
        return errors;
      }
      await db.execute('COMMIT');
    } catch (e) {
      print(e);
      await db.execute('ROLLBACK');
      debugPrint('Error: $e');
      rethrow;
    }

    return errors;
  }

  Future<List<String>> checkTransactionHAPanenComplete(
      {String? notransaksi, String? noref, String? tanggal}) async {
    var errors = <String>[];

    final Database? db = await _dbHelper.database;
    if (db == null) return [];

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    // var server = prefs.getString('server');
    var server = ApiConstants.apiBaseUrlTesting;
    var kebun = prefs.getString('lokasitugas');
    var username = prefs.getString('username');
    var password = prefs.getString('password');

    String str =
        ''' SELECT notransaksi FROM kebun_panendt_ha where notransaksi='$notransaksi' ''';

    final result = await db.rawQuery(str);

    int jmldetail = result.length;

    String strData = '&notransaksi=$notransaksi'
        '&noref=$noref'
        '&kodeorg=$kebun'
        '&tanggal=$tanggal'
        '&jmldetail=$jmldetail';

    String param = 'method=transaction'
        '&tipeData=panenha'
        '&datatransfer=checktransaction'
        '&username=$username'
        '&password=$password'
        '&uuid='
        '$strData';

    final url = "$server/owlMobile.php";
    final response = await sendPostRequest(url, param);

    if (response != null) {
      final json = jsonDecode(response.body);

      String notransaksi = json['notransaksi'].toString();
      String tanggal = json['tanggal'].toString();
      String noref = json['noref'].toString();
      bool isError = json['err']['err'] == 'true';

      final errors =
          await updateSyncedHAPanen(notransaksi: notransaksi, noref: noref);

      return errors;
    }
    return errors;
  }

  Future<List<String>> updateSyncedHAPanen({
    String? notransaksi,
    String? noref,
  }) async {
    final errors = <String>[];

    final Database? db = await _dbHelper.database;
    if (db == null) return [];

    String str =
        ''' update kebun_panen_ha set synchronized='$notransaksi' where notransaksi='$notransaksi'  ''';

    final result = await db.rawQuery(str);

    errors.add('berhasil');

    return errors;
  }

  Future<List<String>> syncPanen(
      DateTime? tgl, String? notransaksi, String? flag) async {
    final errors = <String>[];
    final Database? db = await _dbHelper.database;
    if (db == null) return [];

    // print('sudah masuk sini');
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    // var server = prefs.getString('server');
    var server = ApiConstants.apiBaseUrlTesting;
    var subbagian = prefs.getString('subbagian');
    var kebun = prefs.getString('kebun');
    String? kodeorg = subbagian?.substring(0, 4);
    String? username = prefs.getString('username')?.trim();
    var password = prefs.getString('password');
    print('password');
    print(password);
    String whereheader = '';
    String datapanen = '';
    String notranfordetail = '';
    try {
      await db.execute('BEGIN TRANSACTION');

      if (flag != '') {
        whereheader = "and verify <> '0' ";
      } else {
        whereheader = "and verify = '0' ";
      }

      String str =
          ''' select * from kebun_panen where notransaksi='$notransaksi' $whereheader limit 1  ''';

      final res = await db.rawQuery(str);

      // print('kode org $kodeorg');
      for (var i = 0; i < res.length; i++) {
        final row = res[i];

        String strData = "";
        strData += "&notransaksi=${row['notransaksi']}";
        strData += "&tanggal=${row['tanggal']}";
        strData += "&nobkm=${row['nobkm']}";
        strData += "&kodeorg=$kodeorg";
        strData += "&divisi=$subbagian";
        strData += "&nikmandor=${row['nikmandor']}";
        strData += "&nikmandor1=${row['nikmandor1']}";
        strData += "&nikasisten=${row['nikasisten']}";
        strData += "&kerani=${row['kerani']}";
        strData += "&updateby=${row['updateby']}";
        // strData += "&lastupdate=${row['lastupdate']}";
        strData += "&verify=${row['verify']}";
        strData += "&deviceid=''"; // ganti dengan uuid device kamu

        datapanen += strData;

        // logika untuk notranfordetail
        notranfordetail = (row['verify'] != "0")
            ? row['verify'].toString() // list verify
            : row['notransaksi'].toString(); // list detail
      }

      final param =
          "method=transaction&tipeData=panen&datatransfer=datautama&username=$username&password=$password&uuid=''"
          "$datapanen";

      final url = "$server/owlMobile.php";

      // print('$server/owlMobile.php?$param');
      final response = await sendPostRequest(url, param);

      if (response != null) {
        if (response.statusCode == 200) {
          final json = jsonDecode(response.body);

          String notransaksi = json['notransaksi'];
          String tanggal = json['tanggal'];
          String verify = json['verify'];
          String noref = json['noref'];
          bool isError = json['err']['err'] == 'true';

          if (isError == false) {
            if (verify != '0') {
              notranfordetail = verify;
            } else {
              notranfordetail = noref;
            }

            String strDt =
                ''' SELECT * FROM kebun_panendt where notransaksi='$notranfordetail' ''';

            final resDt = await db.rawQuery(strDt);

            List<List<String>> panenDt = [];

            for (var i = 0; i < resDt.length; i++) {
              final row = resDt[i];

              panenDt.add([
                row['nik']?.toString() ?? '',
                row['blok']?.toString() ?? '',
                row['rotasi']?.toString() ?? '',
                row['tahuntanam']?.toString() ?? '',
                row['jjgpanen']?.toString() ?? '',
                row['luaspanen']?.toString() ?? '',
                row['brondolanpanen']?.toString() ?? '',
                row['status']?.toString() ?? '',
                row['lat']?.toString() ?? '',
                row['long']?.toString() ?? '',
                row['cetakan']?.toString() ?? '',
              ]);
            }
            String strKehadiran =
                ''' SELECT a.* FROM kebun_kehadiran_panen a where notransaksi ='$notranfordetail'  ''';

            final kehadiranResult = await db.rawQuery(strKehadiran);

            List<List<String>> kehadiranD = [];

            for (var i = 0; i < kehadiranResult.length; i++) {
              final row = kehadiranResult[i];

              kehadiranD.add([
                row['kodekegiatan']?.toString() ?? '',
                row['kodeorg']?.toString() ?? '',
                row['nik']?.toString() ?? '',
                row['jhk']?.toString() ?? '',
                row['hasilkerja']?.toString() ?? '',
                row['absensi']?.toString() ?? '',
                row['insentif']?.toString() ?? '',
                row['jam_overtime']?.toString() ?? '',
                ((double.tryParse(row['gajipokok']?.toString() ?? '0') ?? 0) /
                        25)
                    .round()
                    .toString()
              ]);
            }

            if (resDt.isNotEmpty || kehadiranResult.isNotEmpty) {
              final errors = await insertPanenDetail(
                  notransaksi: notransaksi,
                  noref: noref,
                  verify: verify,
                  tanggal: tanggal,
                  data: panenDt,
                  kehadiranD: kehadiranD);

              return errors;
            }
          }
        }
      }
    } catch (e) {
      print(e);
      await db.execute('ROLLBACK');
      debugPrint('Error: $e');
      rethrow;
    }
    return errors;
  }

  Future<List<String>> insertPanenDetail(
      {String? notransaksi,
      String? noref,
      String? verify,
      String? tanggal,
      List<List<String>>? data,
      List<List<String>>? kehadiranD,
      int number = 0}) async {
    final errors = <String>[];
    final Database? db = await _dbHelper.database;
    if (db == null) return [];

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    // var server = prefs.getString('server');
    var server = ApiConstants.apiBaseUrlTesting;
    var subbagian = prefs.getString('subbagian');
    var username = prefs.getString('username');
    var password = prefs.getString('password');

    String strdata = '';
    try {
      await db.execute('BEGIN TRANSACTION');

      String? kodeorg = subbagian?.substring(0, 4);

      const int limit = 100;
      int forloop = number + limit;
      if (forloop >= data!.length) {
        forloop = data.length;
      }

      List<String> nik = [];
      List<String> blok = [];
      List<String> rotasi = [];
      List<String> tahuntanam = [];
      List<String> jjgpanen = [];
      List<String> luaspanen = [];
      List<String> brondolanpanen = [];
      List<String> status = [];
      List<String> latitude = [];
      List<String> longitude = [];
      List<String> cetakan = [];

      int urut = 0;
      for (var x = number; x < forloop; x++) {
        final row = data[x];

        nik.add(row[0]);
        blok.add(row[1]);
        rotasi.add(row[2]);
        tahuntanam.add(row[3]);
        jjgpanen.add(row[4]);
        luaspanen.add(row[5]);
        brondolanpanen.add(row[6]);
        status.add(row[7]);
        latitude.add(row[8]);
        longitude.add(row[9]);
        cetakan.add(row[10]);

        urut++;
      }

      Map<String, String> paramMap = {
        'notransaksi': notransaksi.toString(),
        'noref': noref.toString(),
        'verify': verify.toString(),
        'kodeorg': kodeorg.toString(),
        'tanggal': tanggal.toString(),
        'nik': nik.join(","), // array jadi string "a,b,c"
        'blok': blok.join(","),
        'sesi': rotasi.join(","),
        'tahuntanam': tahuntanam.join(","),
        'jjgpanen': jjgpanen.join(","),
        'luaspanen': luaspanen.join(","),
        'brondolanpanen': brondolanpanen.join(","),
        'status': status.join(","),
        'lat': latitude.join(","),
        'long': longitude.join(","),
        'cetakan': cetakan.join(","),
        'upahkerja': '0',
        'upahpremi': '0',
        'upahpremilebihbasis': '0',
        'username': username ?? '',
        'password': password ?? '',
      };

      const int limit2 = 100;
      int forloop2 = number + limit;
      if (forloop2 >= kehadiranD!.length) {
        forloop2 = kehadiranD.length;
      }

      bool kehadiranumum = false;
      List<String> kodekegiatan = [];
      List<String> kodeorgList = [];
      List<String> nik2 = [];
      List<String> jhk = [];
      List<String> hasilkerja = [];
      List<String> absensi = [];
      List<String> insentif = [];
      List<String> jam_overtime = [];

      // String listData = '';
      int nomor = 0;
      for (var x = 0; x < forloop2; x++) {
        final row = kehadiranD[x];

        kodekegiatan.add(row[0]);
        kodeorgList.add(row[1]);
        nik2.add(row[2]);
        jhk.add(row[3]);
        hasilkerja.add(row[4]);
        absensi.add(row[5]);
        insentif.add(row[6]);
        jam_overtime.add(row[7]);

        nomor++;
        kehadiranumum = true;
      }

      Map<String, String> listData = {
        'nik2': nik2.join(','),
        'jhk': jhk.join(','),
        'hasilkerja': hasilkerja.join(','),
        'absensi': absensi.join(','),
        'insentif': insentif.join(','),
        'keterangan': jam_overtime.join(','),
      };

      Map<String, String> paramToDatabase = {
        'method': 'transaction',
        'tipeData': 'panen',
        'datatransfer': 'datadetail',
        'username': username.toString(),
        'password': password.toString(),
        'uuid': '',
        ...paramMap, // gabung isi paramMap
        ...listData, // gabung isi listData
      };

      print('param to database');
      print(paramToDatabase);

      final url = "$server/owlMobile.php";
      final response = await sendPostRequest(url, paramToDatabase);

      if (response != null && response.statusCode == 200) {
        final json = jsonDecode(response.body);

        String notransaksi = json['notransaksi'];
        String tanggal = json['tanggal'];
        String verify = json['verify'];
        String noref = json['noref'];
        String lanjut = json['lanjut'];
        bool isError = json['err']['err'] == 'true';
        String message = json['err']['mssg'];

        if (isError == false) {
          if (forloop < data.length) {
            final errors = await insertPanenDetail(
                notransaksi: notransaksi,
                noref: noref,
                verify: verify,
                tanggal: tanggal,
                data: data,
                kehadiranD: kehadiranD);

            return errors;
          } else {
            if (kehadiranumum) {
              print('ada kehadiran umum');
            } else {
              final errors = await optionalPanen(
                  notransaksi: notransaksi,
                  noref: noref,
                  verify: verify,
                  tanggal: tanggal);

              return errors;
            }
          }
        }
      }

      await db.execute('COMMIT');
    } catch (e) {
      print(e);
      await db.execute('ROLLBACK');
      debugPrint('Error: $e');
      rethrow;
    }

    return errors;
  }

  Future<List<String>> optionalPanen(
      {String? notransaksi,
      String? noref,
      String? verify,
      String? tanggal}) async {
    final errors = <String>[];
    final Database? db = await _dbHelper.database;
    if (db == null) return [];

    try {
      await db.execute('BEGIN TRANSACTION');
      String? notransfordetail = '';

      if (verify != '0') {
        notransfordetail = verify;
      } else {
        notransfordetail = noref;
      }

      List<Map<String, dynamic>> optionaldata = [];
      int nourut = 0;

      String query =
          ''' select * from kebun_grading where notransaksi='$notransfordetail'  ''';

      final resultGrading = await db.rawQuery(query);

      if (resultGrading.isNotEmpty) {
        for (var row in resultGrading) {
          optionaldata.add({
            'blok_grading': row['blok']?.toString() ?? '',
            'nik_grading': row['nik']?.toString() ?? '',
            'sesi_grading': row['rotasi']?.toString() ?? '',
            'kode_grading': row['kodegrading']?.toString() ?? '',
            'jumlah_grading': row['jml']?.toString() ?? '',
          });
          nourut++;
        }
      }

      String queryHama =
          ''' select * from kebun_kondisi_buah where notransaksi='$notransfordetail' ''';

      final resultHama = await db.rawQuery(queryHama);

      if (resultHama.isNotEmpty) {
        for (var row in resultHama) {
          optionaldata.add({
            'blok_hama': row['blok']?.toString() ?? '',
            'nik_hama': row['nik']?.toString() ?? '',
            'sesi_hama': row['rotasi']?.toString() ?? '',
            'kode_hama': row['kodehama']?.toString() ?? '',
            'jumlah_hama': row['jml']?.toString() ?? '',
          });
          nourut++;
        }
      }

      final errors = await insertOptionalPanen(
          notransaksi: notransaksi,
          noref: noref,
          verify: verify,
          tanggal: tanggal,
          data: optionaldata,
          number: 0);

      await db.execute('COMMIT');
      return errors;
    } catch (e) {
      print(e);
      await db.execute('ROLLBACK');
      debugPrint('Error: $e');
      rethrow;
    }

    return errors;
  }

  Future<List<String>> insertOptionalPanen(
      {String? notransaksi,
      String? noref,
      String? verify,
      String? tanggal,
      List<Map<String, dynamic>>? data,
      int number = 0}) async {
    final errors = <String>[];
    final Database? db = await _dbHelper.database;
    if (db == null) return [];

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    var server = ApiConstants.apiBaseUrlTesting;
    var subbagian = prefs.getString('subbagian');
    var username = prefs.getString('username');
    var password = prefs.getString('password');
    String? kodeorg = subbagian?.substring(0, 4);

    try {
      await db.execute('BEGIN TRANSACTION');

      const int limit = 50;
      int forloop = number + limit;
      if (forloop >= data!.length) {
        forloop = data.length;
      }

      List<String> blokGrading = [];
      List<String> nikGrading = [];
      List<String> sesiGrading = [];
      List<String> kodeGrading = [];
      List<String> jumlahGrading = [];

      List<String> blokHama = [];
      List<String> nikHama = [];
      List<String> sesiHama = [];
      List<String> kodeHama = [];
      List<String> jumlahHama = [];

      for (var i = 0; i < forloop; i++) {
        final row = data[i];

        if (row['blok_grading'] != null && row['blok_grading'] != '') {
          blokGrading.add(row['blok_grading']);
          nikGrading.add(row['nik_grading']);
          sesiGrading.add(row['sesi_grading']);
          kodeGrading.add(row['kode_grading']);
          jumlahGrading.add(row['jumlah_grading']);
        }

        if (row['blok_hama'] != null && row['blok_hama'] != '') {
          blokHama.add(row['blok_hama']);
          nikHama.add(row['nik_hama']);
          sesiHama.add(row['sesi_hama']);
          kodeHama.add(row['kode_hama']);
          jumlahHama.add(row['jumlah_hama']);
        }
      }

      final Map<String, String> paramMap = {
        'notransaksi': notransaksi ?? '',
        'noref': noref ?? '',
        'verify': verify ?? '',
        'kodeorg': kodeorg ?? '',
        'tanggal': tanggal ?? '',
        'blok_grading': blokGrading.join(','),
        'nik_grading': nikGrading.join(','),
        'kode_grading': kodeGrading.join(','),
        'sesi_grading': sesiGrading.join(','),
        'jumlah_grading': jumlahGrading.join(','),
        'blok_hama': blokHama.join(','),
        'kode_hama': kodeHama.join(','),
        'nik_hama': nikHama.join(','),
        'sesi_hama': sesiHama.join(','),
        'jumlah_hama': jumlahHama.join(','),
      };

      Map<String, String> paramToDatabase = {
        'method': 'transaction',
        'tipeData': 'panen',
        'datatransfer': 'dataoptional',
        'username': username.toString(),
        'password': password.toString(),
        'uuid': '',
        ...paramMap, // gabung isi paramMap
      };

      printFullUrl(server, paramToDatabase);

      final url = "$server/owlMobile.php";

      final response = await sendPostRequest(url, paramToDatabase);

      if (response != null && response.statusCode == 200) {
        final json = jsonDecode(response.body);

        String notransaksi = json['notransaksi'];
        String noref = json['noref'];
        String lanjut = json['lanjut'];
        bool isError = json['err']['err'] == 'true';
        String message = json['err']['mssg'];

        if (lanjut == 'true') {
          final errors = await insertImagePanen(
              tgl: tanggal,
              notransaksi: notransaksi,
              noref: noref,
              verify: verify);

          return errors;
        }
      }

      await db.execute('COMMIT');
    } catch (e) {
      print(e);
      await db.execute('ROLLBACK');
      debugPrint('Error: $e');
      rethrow;
    }

    return errors;
  }

  Future<List<String>> insertImagePanen(
      {String? tgl, String? notransaksi, String? noref, String? verify}) async {
    final errors = <String>[];
    final Database? db = await _dbHelper.database;
    if (db == null) return [];

    String? notransfordetail;

    if (verify != '0') {
      notransfordetail = verify;
    } else {
      notransfordetail = noref;
    }

    List<String> strData = [];
    String str =
        ''' SELECT foto,nik,blok,rotasi FROM kebun_panendt where notransaksi='$notransfordetail'  ''';

    final List<Map<String, dynamic>> result = await db.rawQuery(str);
    List<String> potoawal = [];
    if (result.isNotEmpty) {
      for (var row in result) {
        String? nik = row['nik'].toString();
        String? blok = row['blok'].toString();
        String? rotasi = row['rotasi'].toString();
        String? potoawal = row['foto'].toString();

        final foto = await PhotoHelper.encodeFileForParam(potoawal);

        // print('fotooo');
        // print(foto);

        // foto = "data:image/jpeg;base64,$fotopanen";

        final krmD = '&nik=$nik'
            '&blok=$blok'
            '&sesi=$rotasi'
            '&foto=$foto';

        strData.add(krmD);
      }

      final errors = await execImagePanen(
          notransaksi: notransaksi,
          noref: noref,
          verify: verify,
          tanggal: tgl,
          data: strData,
          number: 0);

      return errors;

      // print('string data');
      // print(strData);
    }
    return errors;
  }

  // Future<List<String>> execImagePanen({
  //   String? notransaksi,
  //   String? noref,
  //   String? verify,
  //   String? tanggal,
  //   required List<String> data,
  //   int number = 0,
  // }) async {
  //   final errors = <String>[];
  //   final Database? db = await _dbHelper.database;
  //   if (db == null) return [];

  //   final SharedPreferences prefs = await SharedPreferences.getInstance();
  //   var server = ApiConstants.apiBaseUrlTesting;
  //   var kebun = prefs.getString('lokasitugas');
  //   var username = prefs.getString('username')!.trim();
  //   var password = prefs.getString('password');

  //   String strData = '&notransaksi=$notransaksi'
  //       '&noref=$noref'
  //       '&kodeorg=$kebun'
  //       '&verify=$verify'
  //       '&tanggal=$tanggal';

  //   const int limit = 1;
  //   int forloop = number + limit;

  //   if (forloop >= data!.length) {
  //     forloop = data.length;
  //   }

  //   // kirim semua data sekaligus
  //   for (int i = 0; i < data.length; i++) {
  //     strData += data[i];
  //   }

  //   print(strData);

  //   List<String> potoawal = [];

  //   for (int i = 0; i < data.length; i++) {
  //     potoawal.add(data[i].split('&')[4].split('=')[1]);
  //   }
  //   String paramMap = 'method=transaction'
  //       '&tipeData=panen'
  //       '&datatransfer=dataphoto'
  //       '&username=$username'
  //       '&password=$password'
  //       '&verify=$verify'
  //       '&uuid='
  //       '$strData';

  //   print(paramMap);

  //   final url = "$server/owlMobile.php";
  //   final response = await sendPostRequest(url, paramMap);

  //   if (response != null) {
  //     final json = jsonDecode(response.body);
  //     // proses response seperti semula...
  //     final errors = await checkTransactionPanenComplete(
  //         notransaksi: json['notransaksi'],
  //         noref: json['noref'],
  //         verify: json['verify'],
  //         tanggal: tanggal);
  //     return errors;
  //   }

  //   return errors;
  // }
  Future<List<String>> execImagePanen({
    String? notransaksi,
    String? noref,
    String? verify,
    String? tanggal,
    required List<String> data,
    int number = 0,
  }) async {
    final errors = <String>[];
    final Database? db = await _dbHelper.database;
    if (db == null) return [];

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final server = ApiConstants.apiBaseUrlTesting;
    final kebun = prefs.getString('lokasitugas') ?? '';
    final username = prefs.getString('username')?.trim() ?? '';
    final password = prefs.getString('password') ?? '';
    final uuid = prefs.getString('uuid') ?? '';

    // sama seperti cordova: kirim per-batch (limit = 1)
    const int limit = 1;
    int forloop = number + limit;
    if (forloop > data.length) forloop = data.length;

    // build strData hanya untuk batch ini (number .. forloop-1)
    StringBuffer sb = StringBuffer();
    sb.write('&notransaksi=${notransaksi ?? ''}');
    sb.write('&noref=${noref ?? ''}');
    sb.write('&verify=${verify ?? ''}');
    sb.write('&kodeorg=$kebun');
    sb.write('&tanggal=${tanggal ?? ''}');

    // tambahkan hanya item dalam batch (tidak menggabungkan semua)
    for (int i = number; i < forloop; i++) {
      // data[i] diasumsikan sudah berupa '&nik=...&blok=...&sesi=...&foto=...'
      sb.write(data[i]);
    }

    final strData = sb.toString();

    // buat param seperti di Cordova (tidak meng-URL-encode foto agar format persis)
    String param = 'method=transaction'
        '&tipeData=panen'
        '&datatransfer=dataphoto'
        '&username=$username'
        '&password=$password'
        '&verify=$verify'
        '&uuid=$uuid';
    param += strData;

    // debug prints (mirip console.log di Cordova)
    print('execImagePanen -> sending to: $server/owlMobile.php');
    print('execImagePanen -> param length=${param.length}');
    // jangan decode/encode foto di sini supaya format persis seperti Cordova

    final url = "$server/owlMobile.php";
    final response = await sendPostRequest(url, param);

    if (response != null) {
      try {
        final body = response.body;
        print('execImagePanen -> response: ${body.length} chars');
        final json = jsonDecode(body);

        // ambil fields utama sesuai response Cordova
        final respNotrans = json['notransaksi'];
        final respNoref = json['noref'];
        final respVerify = json['verify'];
        final respErr = json['err'];

        // jika response menandakan sukses -> lanjut batch berikutnya atau check complete
        // struktur err di server Cordova: err.err == "false" untuk sukses
        if (respErr != null && (respErr is Map) && respErr['err'] == "false") {
          // masih ada data tersisa? panggil lagi (mirip recursion di Cordova)
          if (forloop < data.length) {
            final nextErrors = await execImagePanen(
              notransaksi: respNotrans,
              noref: respNoref,
              verify: respVerify,
              tanggal: tanggal,
              data: data,
              number: forloop,
            );
            errors.addAll(nextErrors);
            return errors;
          } else {
            // semua batch selesai -> cek complete
            final finalErrors = await checkTransactionPanenComplete(
              notransaksi: respNotrans,
              noref: respNoref,
              verify: respVerify,
              tanggal: tanggal,
            );
            errors.addAll(finalErrors);
            return errors;
          }
        } else {
          // server menolak, kembalikan pesan mssg jika ada
          if (respErr != null && respErr['mssg'] != null) {
            return [respErr['mssg'].toString()];
          }
          return ['Server returned error or unexpected structure'];
        }
      } catch (e, st) {
        print('execImagePanen -> parse/exception: $e\n$st');
        return ['Response parse error: ${e.toString()}'];
      }
    } else {
      return ['No response from server'];
    }
  }

  Future<List<String>> checkTransactionPanenComplete(
      {String? notransaksi,
      String? noref,
      String? verify,
      String? tanggal}) async {
    var errors = <String>[];

    final Database? db = await _dbHelper.database;
    if (db == null) return [];

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    // var server = prefs.getString('server');
    var server = ApiConstants.apiBaseUrlTesting;
    var kebun = prefs.getString('lokasitugas');
    var username = prefs.getString('username');
    var password = prefs.getString('password');

    String? notransfordetail = '';

    if (verify != '0') {
      notransfordetail = verify;
    } else {
      notransfordetail = noref;
    }

    String str = '''
      SELECT notransaksi FROM kebun_gerdang
      WHERE notransaksi="$notransfordetail"
      UNION ALL
      SELECT notransaksi FROM kebun_panendt
      WHERE notransaksi="$notransfordetail"
      UNION ALL
      SELECT notransaksi FROM kebun_grading
      WHERE notransaksi="$notransfordetail"
      UNION ALL
      SELECT notransaksi FROM kebun_kondisi_buah
      WHERE notransaksi="$notransfordetail"
    ''';

    final result = await db.rawQuery(str);
    int jmldetail = result.length;

    String strData = '&notransaksi=$notransaksi'
        '&noref=$noref'
        '&verify=$verify'
        '&kodeorg=$kebun'
        '&tanggal=$tanggal'
        '&jmldetail=$jmldetail';

    String param = 'method=transaction'
        '&tipeData=panen'
        '&datatransfer=checktransaction'
        '&username=$username'
        '&password=$password'
        '&uuid='
        '$strData';

    final url = "$server/owlMobile.php";
    final response = await sendPostRequest(url, param);

    if (response != null) {
      final json = jsonDecode(response.body);

      String notransaksi = json['notransaksi'];
      String noref = json['noref'];
      String verify = json['verify'];
      bool isError = json['err']['err'] == 'true';
      String message = json['err']['mssg'];

      final errors = await updateSyncedPanen(
          notransaksi: notransaksi,
          noref: noref,
          verify: verify,
          tanggal: tanggal);

      return errors;
    }

    return errors;
  }

  Future<List<String>> updateSyncedPanen(
      {String? notransaksi,
      String? noref,
      String? verify,
      String? tanggal}) async {
    final errors = <String>[];

    final Database? db = await _dbHelper.database;
    if (db == null) return [];

    String? where;
    if (verify != '0') {
      where = "and verify = '$verify' ";
    } else {
      where = "and verify = '0'";
    }

    String str =
        ''' update kebun_panen set synchronized='$notransaksi' where notransaksi='$noref' $where ''';

    final result = await db.rawQuery(str);

    errors.add('berhasil');

    return errors;
  }

  Future<List<String>> syncSpb(DateTime? tgl, String? notransaksi) async {
    final errors = <String>[];
    final Database? db = await _dbHelper.database;
    if (db == null) return [];

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    // var server = prefs.getString('server');
    var server = ApiConstants.apiBaseUrlTesting;
    var subbagian = prefs.getString('subbagian');
    var username = prefs.getString('username');
    var password = prefs.getString('password');
    List<String> headerSPB = [];
    try {
      await db.execute('BEGIN TRANSACTION');

      String str =
          '''  SELECT a.*, b.blok FROM kebun_spbht a LEFT JOIN kebun_spbdt b on a.nospb = b.nospb where a.nospb='$notransaksi'  ''';

      final result = await db.rawQuery(str);
      List<String> dataH = [];
      if (result.isNotEmpty) {
        final row = result
            .first; // ambil baris pertama (seperti Cordova yg overwrite di loop)
        const ext = ".jpeg";

        dataH = [
          row['nospb']?.toString() ?? '', // 0
          row['tujuan']?.toString() ?? '', // 1
          row['penerimatbs']?.toString() ?? '', // 2
          row['tanggal']?.toString() ?? '', // 3
          row['afdeling']?.toString() ?? '', // 4
          row['driver']?.toString() ?? '', // 5
          row['nopol']?.toString() ?? '', // 6
          row['ffbdocument']?.toString() ?? '', // 7
          row['kraniproduksi']?.toString() ?? '', // 8
          '${row['nospb'] ?? ''}$ext', // 9
          row['lat']?.toString() ?? '', // 10
          row['lon']?.toString() ?? '', // 11
          row['alt']?.toString() ?? '', // 12
          row['acr']?.toString() ?? '', // 13
          '',
          row['blok']?.toString() ?? '', // 15
        ];
      }

      headerSPB = dataH;

      String strKernet =
          ''' SELECT * FROM kebun_spbtkbm where nospb='$notransaksi'  ''';

      final resultKernet = await db.rawQuery(strKernet);

      List<List<String>> tkbmSPB = [];
      if (resultKernet.isNotEmpty) {
        tkbmSPB = resultKernet
            .map((r) => [
                  r['karyawanid']?.toString() ?? '',
                  r['namakaryawan']?.toString() ?? '',
                  r['jumlahjjg']?.toString() ?? '0',
                ])
            .toList();
      }
      final dtHeader = headerSPB.join(',');
      final dtTkbm = jsonEncode(tkbmSPB);

      final Map<String, String> paramToDatabase = {
        'method': 'transaction',
        'tipeData': 'spb', // <-- perhatikan: untuk SPB, bukan panenha
        'datatransfer': 'datautama', // <-- sesuai Cordova
        'username': username.toString(),
        'password': password.toString(),
        'dtHeader': dtHeader,
        'dtTkbm': dtTkbm,
        'uuid': '',
      };

      final url = "$server/owlMobile.php";
      final response = await sendPostRequest(url, paramToDatabase);

      if (response != null && response.statusCode == 200) {
        final json = jsonDecode(response.body);

        String serverno = json['serverno'].toString();
        String notransaksi = json['notransaksi'].toString();
        String tanggal = json['tanggal'].toString();
        String afdeling = json['afdeling'].toString();
        bool isError = json['err']['err'] == 'true';

        String strDt =
            ''' SELECT * FROM kebun_spbdt where nospb='$notransaksi' order by blok DESC  ''';

        final resultDt = await db.rawQuery(strDt);

        List<List<String>> detailD = [];

        for (var i = 0; i < resultDt.length; i++) {
          final row = resultDt[i];

          detailD.add([
            row['blok']?.toString() ?? '',
            row['jjg']?.toString() ?? '',
            row['brondolan']?.toString() ?? '',
            row['mentah']?.toString() ?? '',
            row['busuk']?.toString() ?? '',
            row['matang']?.toString() ?? '',
            row['lewatmatang']?.toString() ?? '',
            row['nospbref']?.toString() ?? '',
            row['rotasi']?.toString() ?? '',
            row['nik']?.toString() ?? '',
            row['tglpanen']?.toString() ?? '',
          ]);
        }
        // print('detail d');
        // print(detailD);

        if (resultDt.isNotEmpty) {
          final errors = await syndetailspb(
              notransaksi: notransaksi,
              serverno: serverno,
              tanggal: tanggal,
              afd: afdeling,
              data: detailD);

          return errors;
        } else {
          errors.add('Tidak memiliki data, tidak bisa dilanjutkan');

          return errors;
        }
      }
    } catch (e) {
      print(e);
      await db.execute('ROLLBACK');
      debugPrint('Error: $e');
      rethrow;
    }
    return errors;
  }

  Future<List<String>> syndetailspb(
      {String? notransaksi,
      String? serverno,
      String? tanggal,
      String? afd,
      List<List<String>>? data,
      int number = 0}) async {
    final errors = <String>[];
    final Database? db = await _dbHelper.database;
    if (db == null) return [];

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    // var server = prefs.getString('server');
    var server = ApiConstants.apiBaseUrlTesting;
    var subbagian = prefs.getString('subbagian');
    var username = prefs.getString('username');
    var password = prefs.getString('password');
    String? kodeorg = subbagian?.substring(0, 4);

    try {
      await db.execute('BEGIN TRANSACTION');

      const int limit = 50;
      int forloop = number + limit;
      if (forloop >= data!.length) {
        forloop = data.length;
      }

      List<String> blok = [];
      List<String> jjg = [];
      List<String> brondolan = [];
      List<String> mentah = [];
      List<String> busuk = [];
      List<String> matang = [];
      List<String> lewatmatang = [];
      List<String> nospbref = [];
      List<String> rotasi = [];
      List<String> nik = [];
      List<String> tglpanen = [];

      int urut = 0;
      for (var x = number; x < forloop; x++) {
        final row = data[x];

        blok.add(row[0]);
        jjg.add(row[1]);
        brondolan.add(row[2]);
        mentah.add(row[3]);
        busuk.add(row[4]);
        matang.add(row[5]);
        lewatmatang.add(row[6]);
        nospbref.add(row[7]);
        rotasi.add(row[8]);
        nik.add(row[9]);
        tglpanen.add(row[10]);

        urut++;
      }

      Map<String, String> listData = {
        'kodeorg': kodeorg.toString(),
        'afdeling': afd.toString(),
        'tanggal': tanggal.toString(),
        'blok': blok.join(','),
        'jjg': jjg.join(','),
        'brondolan': brondolan.join(','),
        'mentah': mentah.join(','),
        'busuk': busuk.join(','),
        'matang': matang.join(','),
        'lewatmatang': lewatmatang.join(','),
        'nospbref': nospbref.join(','),
        'rotasi': rotasi.join(','),
        'nik': nik.join(','),
        'tglpanen': tglpanen.join(','),
      };

      Map<String, String> paramToDatabase = {
        'method': 'transaction',
        'tipeData': 'spb',
        'datatransfer': 'datadetailspb',
        'username': username.toString(),
        'password': password.toString(),
        'notransaksi': notransaksi.toString(),
        'serverno': serverno.toString(),
        'uuid': '',
        ...listData
      };

      // print(paramToDatabase);

      final url = "$server/owlMobile.php";
      final response = await sendPostRequest(url, paramToDatabase);

      if (response != null && response.statusCode == 200) {
        final json = jsonDecode(response.body);

        String serverno = json['serverno'].toString();
        String notransaksi = json['notransaksi'].toString();
        String tanggal = json['tanggal'].toString();
        String afdeling = json['afdeling'].toString();
        bool isError = json['err']['err'] == 'true';

        final errors = await checkTransactionSpbComplete(
            notransaksi: notransaksi,
            serverno: serverno,
            tanggal: tanggal,
            afdeling: afdeling);

        return errors;
      }

      await db.execute('COMMIT');
    } catch (e) {
      print(e);
      await db.execute('ROLLBACK');
      debugPrint('Error: $e');
      rethrow;
    }

    return errors;
  }

  Future<List<String>> checkTransactionSpbComplete(
      {String? notransaksi,
      String? serverno,
      String? tanggal,
      String? afdeling}) async {
    var errors = <String>[];

    final Database? db = await _dbHelper.database;
    if (db == null) return [];

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    // var server = prefs.getString('server');
    var server = ApiConstants.apiBaseUrlTesting;
    var kebun = prefs.getString('lokasitugas');
    var username = prefs.getString('username');
    var password = prefs.getString('password');

    String str =
        ''' SELECT nospb FROM kebun_spbdt where nospb='$notransaksi' UNION ALL SELECT nospb FROM kebun_spbtkbm where nospb='$notransaksi'  ''';

    final result = await db.rawQuery(str);

    int jmldetail = result.length;

    String strData = '&notransaksi=$notransaksi'
        '&serverno=$serverno'
        '&kodeorg=$kebun'
        '&afdeling=$afdeling'
        '&tanggal=$tanggal'
        '&jmldetail=$jmldetail';

    String param = 'method=transaction'
        '&tipeData=spb'
        '&datatransfer=checktransaction'
        '&username=$username'
        '&password=$password'
        '&uuid='
        '$strData';

    final url = "$server/owlMobile.php";
    final response = await sendPostRequest(url, param);

    if (response != null) {
      final json = jsonDecode(response.body);

      String serverno = json['serverno'].toString();
      String notransaksi = json['notransaksi'].toString();
      String tanggal = json['tanggal'].toString();
      String afdeling = json['afdeling'].toString();
      bool isError = json['err']['err'] == 'true';

      print(json);

      final errors =
          await selesaisynspb(notransaksi: notransaksi, serverno: serverno);

      return errors;
    }

    return errors;
  }

  Future<List<String>> selesaisynspb({
    String? notransaksi,
    String? serverno,
  }) async {
    final errors = <String>[];

    final Database? db = await _dbHelper.database;
    if (db == null) return [];

    String str =
        ''' update kebun_spbht set synchronized='$serverno' where nospb='$notransaksi'  ''';

    await db.rawQuery(str);

    final error = await tryUploadPhoto(notransaksi: notransaksi);

    return error;
  }

  Future<List<String>> tryUploadPhoto({
    String? notransaksi,
  }) async {
    var errors = <String>[];

    final Database? db = await _dbHelper.database;
    if (db == null) return [];

    String str = ''' SELECT * FROM kebun_spbht where nospb=? ''';

    // final rows = await db.rawQuery(str);
    final List<Map<String, dynamic>> results =
        await db.rawQuery(str, [notransaksi]);

    final List<String> fileToUpload = [];
    final List<String> newFilename = [];
    String? foto;
    var potoawal2;
    for (final row in results) {
      String? blobOrString = row['spbfile'];

      print(blobOrString);
      // String base64Image = '';

      // if (blobOrString is Uint8List) {
      //   base64Image = base64Encode(blobOrString);
      // } else if (blobOrString is String) {
      //   // kalau sudah base64 string di DB
      //   base64Image = blobOrString;
      // } else {
      //   // tipe tak dikenal → skip
      //   continue;
      // }

      // final String dataUrl = 'data:image/jpeg;base64,$base64Image';

      potoawal2 = await PhotoHelper.encodeFileForParam(blobOrString);

      final String nospb = row['nospb']?.toString() ?? '';
      if (nospb.isEmpty) continue;

      fileToUpload.add(potoawal2);
      newFilename.add(nospb);
    }

    if (fileToUpload.isNotEmpty) {
      int uploadCounter = 0;

      print('data uri : ');
      print(fileToUpload);

      // await saveBase64ToFile(potoawal2, "foto_test.jpg");

      // errors = await sendImage(dataUri: potoawal2, filename: 'foto_test.jpg');

      // return errors;

      // OPTIONAL: kalau mau kirim semua berurutan:
      for (int i = 0; i < fileToUpload.length; i++) {
        await sendImage(dataUri: fileToUpload[i], filename: newFilename[i]);
      }
    }

    return errors;
  }

  Future<void> saveBase64ToFile(String base64Str, String filename) async {
    try {
      // decode dari base64
      final bytes = base64Decode(base64Str);

      // ambil direktori aplikasi
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/$filename');

      // tulis ke file
      await file.writeAsBytes(bytes);

      print('File tersimpan di: ${file.path}');
    } catch (e) {
      print('Gagal simpan file: $e');
    }
  }

  Future<List<String>> sendImage({String? dataUri, String? filename}) async {
    final errors = <String>[];
    final Database? db = await _dbHelper.database;
    if (db == null) return [];

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    // var server = prefs.getString('server');
    var server = ApiConstants.apiBaseUrlTesting;
    var kebun = prefs.getString('lokasitugas');
    var username = prefs.getString('username');
    var password = prefs.getString('password');

    String tipegambar = "";
    if (dataUri != '') {
      tipegambar = "jpeg";

      print(dataUri);
      String paramMap = 'method=transaction'
          '&tipeData=images'
          '&username=$username'
          '&password=$password'
          '&dtImage=$dataUri'
          '&filename=$filename'
          '&tipeGambar=jpeg'
          '&uuid='
          ' ';

      final url = "$server/owlMobile.php";
      final response = await sendPostRequest(url, paramMap);

      // print(response.body);
      if (response != null) {
        final json = jsonDecode(response.body);

        errors.add('berhasil');
      }
    }

    return errors;
  }

  Future<List<String>> syncBkm(DateTime? tgl, String? notransaksi) async {
    final errors = <String>[];
    final Database? db = await _dbHelper.database;
    if (db == null) return [];
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    // var server = prefs.getString('server');
    var server = ApiConstants.apiBaseUrlTesting;
    var subbagian = prefs.getString('subbagian');
    var username = prefs.getString('username');
    var password = prefs.getString('password');

    // print(username);
    // print(password);
    // print(server);
    try {
      await db.execute('BEGIN TRANSACTION');
      // String str1 =
      //     ''' SELECT t1.*,t2.namakegiatan from (SELECT notransaksi,CASE WHEN nobkm = "" or nobkm is Null THEN "kosong" ELSE nobkm END nobkm , CASE WHEN jumlahhasilkerja = "" or jumlahhasilkerja is Null THEN "kosong" ELSE jumlahhasilkerja END jumlahhasilkerja, kodeorg,kodekegiatan FROM kebun_prestasi where notransaksi='$notransaksi') as t1 left join setup_kegiatan t2 on t1.kodekegiatan=t2.kodekegiatan ''';

      // final res1 = await db.rawQuery(str1);
      final String str1 = '''
      SELECT 
        t1.notransaksi,
        CASE 
          WHEN t1.nobkm IS NULL OR t1.nobkm = '' THEN 'kosong'
          WHEN LENGTH(t1.nobkm) > 512 THEN SUBSTR(t1.nobkm, 1, 512) || '…'
          ELSE t1.nobkm
        END AS nobkm,
        CASE 
          WHEN t1.jumlahhasilkerja IS NULL OR t1.jumlahhasilkerja = '' THEN 'kosong'
          WHEN LENGTH(t1.jumlahhasilkerja) > 64 THEN SUBSTR(t1.jumlahhasilkerja,1,64)
          ELSE t1.jumlahhasilkerja
        END AS jumlahhasilkerja,
        t1.kodeorg,
        t1.kodekegiatan,
        t2.namakegiatan
      FROM (
        SELECT
          notransaksi,
          CASE WHEN nobkm = '' OR nobkm IS NULL THEN NULL ELSE nobkm END AS nobkm,
          CASE WHEN jumlahhasilkerja = '' OR jumlahhasilkerja IS NULL THEN NULL ELSE jumlahhasilkerja END AS jumlahhasilkerja,
          kodeorg,
          kodekegiatan
        FROM kebun_prestasi
        WHERE notransaksi = ?
      ) AS t1
      LEFT JOIN setup_kegiatan t2 ON t1.kodekegiatan = t2.kodekegiatan
      ''';

      final res1 = await db.rawQuery(str1, [notransaksi]);

      // print(res1);

      String potoakhir = '';
      String namakegiatan = '';
      String tiperawat = '';
      if (res1.isNotEmpty) {
        tiperawat = 'biasa';

        for (var row in res1) {
          final jumlahHasilKerja = row['jumlahhasilkerja']?.toString() ?? '';
          final namaKegiatan = row['namakegiatan']?.toString() ?? '-';
          final kodeorg = row['kodeorg']?.toString() ?? '-';

          if (jumlahHasilKerja != '') {
            potoakhir = jumlahHasilKerja.toString();
          } else {
            potoakhir = '';

            errors.add(
                'Silahkan foto akhir kegiatan ($namaKegiatan) di blok ($kodeorg) terlebih dahulu');

            return errors;
          }
        }
      } else {
        tiperawat = 'umum';
      }

      if ((potoakhir != '' && tiperawat == 'biasa') || (tiperawat == 'umum')) {
        String string =
            '''  SELECT * FROM kebun_aktifitas where notransaksi='$notransaksi' ''';

        final resStr = await db.rawQuery(string);

        String dataH = '';

        for (var i = 0; i < resStr.length; i++) {
          final row = resStr[i];
          dataH += "&notransaksi=${row['notransaksi']}";
          dataH += "&tanggal=${row['tanggal']}";
          dataH += "&kelompok=${row['kelompok']}";
          dataH += "&kodeorg=${row['kodeorg']}";
          dataH += "&nikmandor=${row['nikmandor']}";
          dataH += "&nikmandor1=${row['nikmandor1']}";
          dataH += "&nikasisten=${row['nikasisten']}";
          dataH += "&kerani=${row['kerani']}";
          dataH += "&kodekegiatan=${row['kodekegiatan']}";
          dataH += "&nobkm=${row['nobkm']}";
          dataH += "&divisi=$subbagian";
        }

        dataheader += "&nikmandor=${resStr.first['nikmandor']}";
        dataheader += "&nikmandor1=${resStr.first['nikmandor1']}";
        dataheader += "&nikasisten=${resStr.first['nikasisten']}";

        final param = "method=transaction"
            "&tipeData=bkm"
            "&datatransfer=datautama"
            "&username=$username"
            "&password=$password"
            "&uuid=''"
            "$dataH";

        // errors.add('$server/owlMobile.php?$param');
        final url = "$server/owlMobile.php";

        // print('$server/owlMobile.php?$param');
        final response = await sendPostRequest(url, param);

        if (response != null) {
          if (response.statusCode == 200) {
            final json = jsonDecode(response.body);

            String notransaksi = json['notransaksi'];
            String nodevice = json['nodevice'];
            String tanggal = json['tanggal'];
            String lanjut = json['lanjut'];
            bool isError = json['err']['err'] == 'true';
            String message = json['err']['mssg'];

            final errors =
                await syncBkmPrestasi(nodevice, notransaksi, tanggal);

            return errors;
          } else {
            errors.add("Server error: ${response.statusCode}");
          }
        }
      }

      await db.execute('COMMIT');
    } catch (e) {
      print(e);
      print('iya masih masuk sini');
      await db.execute('ROLLBACK');
      debugPrint('Error: $e');
      rethrow;
    }
    return errors;
  }

  Future<void> debugLenPrestasi(Database db, String notrans) async {
    final r = await db.rawQuery('''
    SELECT 
      MAX(LENGTH(kodekegiatan)) AS len_kegiatan,
      MAX(LENGTH(kodeorg))      AS len_org,
      MAX(LENGTH(jumlahhasilkerja)) AS len_jmlhasil,
      MAX(LENGTH(jumlahhk))     AS len_jmlhk,
      MAX(LENGTH(kelompok))     AS len_kelompok,
      MAX(LENGTH(nobkm))        AS len_nobkm
    FROM kebun_prestasi
    WHERE notransaksi = ?
  ''', [notrans]);

    if (r.isNotEmpty) {
      final x = r.first;
      print('LEN kodekegiatan=${x['len_kegiatan']} '
          'kodeorg=${x['len_org']} '
          'jumlahhasilkerja=${x['len_jmlhasil']} '
          'jumlahhk=${x['len_jmlhk']} '
          'kelompok=${x['len_kelompok']} '
          'nobkm=${x['len_nobkm']}');
    }
  }

  Future<List<String>> syncBkmPrestasi(
      String nodevice, String nobkm, String tanggal) async {
    final errors = <String>[];
    final Database? db = await _dbHelper.database;
    if (db == null) return [];

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    var kebun = prefs.getString('kebun');
    // errors.add('masuk iya');

    try {
      await db.execute('BEGIN TRANSACTION');

      await debugLenPrestasi(db, nodevice);

      const String str = '''
        SELECT 
          kodekegiatan,
          kodeorg,
          jumlahhasilkerja,
          jumlahhk,
          kelompok,
          nobkm
        FROM kebun_prestasi
        WHERE notransaksi = ?
      ''';

      final resultStr = await db.rawQuery(str, [nodevice]);

      print(resultStr);

      List<List<String>> prestasiD = [];

      for (var i = 0; i < resultStr.length; i++) {
        final row = resultStr[i];

        prestasiD.add([
          row['kodekegiatan']?.toString() ?? '',
          row['kodeorg']?.toString() ?? '',
          row['jumlahhasilkerja']?.toString() ?? '',
          row['jumlahhk']?.toString() ?? '',
          row['kelompok']?.toString() ?? '',
          row['nobkm']?.toString() ?? '',
        ]);
      }

      String str2 =
          ''' SELECT T1.*,b.kelompok,b.potoawal_lat,b.potoawal_long,b.potoawal_alt,b.potoakhir_lat,b.potoakhir_long,b.potoakhir_alt FROM (SELECT IFNULL(a.kodeorg,'$kebun') as kodeorg,a.*, b.tahuntanam, c.gajipokok FROM kebun_kehadiran a LEFT JOIN setup_blok b on a.kodeorg=b.kodeblok LEFT JOIN datakaryawan c on a.nik=c.karyawanid where notransaksi='$nodevice') as T1 LEFT JOIN kebun_prestasi b on T1.notransaksi = b.notransaksi and T1.kodekegiatan=b.kodekegiatan and T1.kodeorg=b.kodeorg   ''';

      // print(prestasiD[0]);
      final resultStr2 = await db.rawQuery(str2);

      List<List<String>> kehadiranD = [];

      for (var i = 0; i < resultStr2.length; i++) {
        final row = resultStr2[i];

        kehadiranD.add([
          row['kodekegiatan']?.toString() ?? '',
          row['kodeorg']?.toString() ?? '',
          row['nik']?.toString() ?? '',
          row['jhk']?.toString() ?? '',
          row['hasilkerja']?.toString() ?? '',
          row['absensi']?.toString() ?? '',
          row['insentif']?.toString() ?? '',
          row['jam_overtime']?.toString() ?? '',
          row['extrafooding']?.toString() ?? '',
          row['kelompok']?.toString() ?? '',
          (row['gajipokok'] != null ? (row['gajipokok'] as num) / 25 : '')
              .toString(),
          row['kelompok']?.toString() ?? '',
          row['satuanprestasi']?.toString() ?? '',
          row['potoawal_lat']?.toString() ?? '',
          row['potoawal_long']?.toString() ?? '',
          row['potoawal_alt']?.toString() ?? '',
          row['potoakhir_lat']?.toString() ?? '',
          row['potoakhir_long']?.toString() ?? '',
          row['potoakhir_alt']?.toString() ?? '',
          row['premilebihbasis']?.toString() ?? '',
        ]);
      }

      if (resultStr2.isNotEmpty) {
        final errors = await execBkmPrestasi(
            nodevice: nodevice,
            notransaksi: nobkm,
            tanggal: tanggal,
            kehadiranD: kehadiranD,
            number: 0);

        return errors;
      } else {
        errors.add('tidak memiliki data');
      }

      await db.execute('COMMIT');
    } catch (e) {
      await db.execute('ROLLBACK');
      debugPrint('Error: $e');
      rethrow;
    }

    return errors;
  }

  Future<List<String>> execBkmPrestasi(
      {String? nodevice,
      String? notransaksi,
      String? tanggal,
      List<List<String>>? kehadiranD,
      int number = 0}) async {
    final errors = <String>[];
    final Database? db = await _dbHelper.database;
    if (db == null) return [];

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    // var server = prefs.getString('server');
    var server = ApiConstants.apiBaseUrlTesting;
    var subbagian = prefs.getString('subbagian');
    var username = prefs.getString('username');
    var password = prefs.getString('password');

    try {
      await db.execute('BEGIN TRANSACTION');

      const int limit = 50;
      int forloop = number + limit;
      if (forloop >= kehadiranD!.length) {
        forloop = kehadiranD.length;
      }

      // Inisialisasi array
      List<String> kodekegiatan = [];
      List<String> kodeorg = [];
      List<String> nik = [];
      List<String> jhk = [];
      List<String> hasilkerja = [];
      List<String> absensi = [];
      List<String> insentif = [];
      List<String> jamOvertime = [];
      List<String> extrafooding = [];
      List<String> tahuntanam = [];
      List<String> upahkerja = [];
      List<String> statusblok = [];
      List<String> satuan = [];

      List<String> potoawalLat = [];
      List<String> potoawalLong = [];
      List<String> potoawalAlt = [];

      List<String> potoakhirLat = [];
      List<String> potoakhirLong = [];
      List<String> potoakhirAlt = [];

      List<String> premiLebihBasis = [];

      int urut = 0;

      for (int x = number; x < forloop; x++) {
        final row = kehadiranD[x];
        kodekegiatan.add(row[0]);
        kodeorg.add(row[1]);
        nik.add(row[2]);
        jhk.add(row[3]);
        hasilkerja.add(row[4]);
        absensi.add(row[5]);
        insentif.add(row[6]);
        jamOvertime.add(row[7]);
        extrafooding.add(row[8]);
        tahuntanam.add(row[9]);
        upahkerja.add(row[10]);
        statusblok.add(row[11]);
        satuan.add(row[12]);

        potoawalLat.add(row[13]);
        potoawalLong.add(row[14]);
        potoawalAlt.add(row[15]);
        potoakhirLat.add(row[16]);
        potoakhirLong.add(row[17]);
        potoakhirAlt.add(row[18]);
        premiLebihBasis.add(row[19]);

        urut++;
      }

      // final sql = '''
      //     SELECT *
      //     FROM kebun_aktifitas
      //     WHERE notransaksi = ?
      //     LIMIT 1
      //   ''';

      // final rows = await db.rawQuery(sql, [notransaksi]);
      String string =
          '''  SELECT * FROM kebun_aktifitas where notransaksi='$nodevice' ''';

      final resStr = await db.rawQuery(string);

      final row = resStr.isNotEmpty ? resStr.first : null;

      // print(rows);

      final nikmandor = row?['nikmandor']?.toString() ?? '';
      final nikmandor1 = row?['nikmandor1']?.toString() ?? '';
      final nikasisten = row?['nikasisten']?.toString() ?? '';

      Map<String, String> paramMap = {
        'method': 'transaction',
        'tipeData': 'bkm',
        'datatransfer': 'dataprestasi',
        'nikmandor': nikmandor,
        'nikmandor1': nikmandor1,
        'nikasisten': nikasisten,
        'username': username.toString(),
        'password': password.toString(),
        'uuid': '',
        'nobkm': notransaksi.toString(),
        'notransaksi': notransaksi.toString(),
        'nodevice': nodevice.toString(),
        'tanggal': tanggal.toString(),
        'nourut': number.toString(),

        // ======== Array Data, gunakan .join(',') agar sesuai format Cordova ========
        'kodekegiatan': kodekegiatan.join(','),
        'kodeorg': kodeorg.join(','),
        'nik': nik.join(','),
        'jhk': jhk.join(','),
        'hasilkerja': hasilkerja.join(','),
        'absensi': absensi.join(','),
        'insentif': insentif.join(','),
        'jam_overtime': jamOvertime.join(','),
        'extrafooding': extrafooding.join(','),
        'tahuntanam': tahuntanam.join(','),
        'upahkerja': upahkerja.join(','),
        'statusblok': statusblok.join(','),
        'noakun': satuan.join(','),

        'potoawal_lat': potoawalLat.join(','),
        'potoawal_long': potoawalLong.join(','),
        'potoawal_alt': potoawalAlt.join(','),

        'potoakhir_lat': potoakhirLat.join(','),
        'potoakhir_long': potoakhirLong.join(','),
        'potoakhir_alt': potoakhirAlt.join(','),

        'premilebihbasis': premiLebihBasis.join(','),
      };

      // print('$server/owlMobile.php?$paramMap');

      final url = "$server/owlMobile.php";
      // final uri = Uri.parse(url);
      // final response = await http.post(
      //   uri,
      //   headers: {
      //     'Content-Type': 'application/x-www-form-urlencoded',
      //   },
      //   body: paramMap,
      // );
      final response = await sendPostRequest(url, paramMap);

      if (response != null && response.statusCode == 200) {
        final json = jsonDecode(response.body);

        String notransaksi = json['notransaksi'];
        String nodevice = json['nodevice'];
        String tanggal = json['tanggal'];
        String lanjut = json['lanjut'];
        bool isError = json['err']['err'] == 'true';
        String message = json['err']['mssg'];
        // List<Map<String, dynamic>> datafromserver = json['datafromserver'];
        List<Map<String, dynamic>> datafromserver =
            (json['datafromserver'] as List<dynamic>)
                .map((e) => e as Map<String, dynamic>)
                .toList();

        final errors = await synBkmMaterial(
            nodevice: nodevice,
            notransaksi: notransaksi,
            tanggal: tanggal,
            datafromserver: datafromserver);
        // print(errors);

        return errors;
      } else {
        errors.add("Server error: ${response?.statusCode ?? 'no response'}");
      }

      // errors.add('tes iya');

      await db.execute('COMMIT');
    } catch (e) {
      print(e);
      await db.execute('ROLLBACK');
      debugPrint('Error: $e');
      rethrow;
    }

    return errors;
  }

  Future<List<String>> synBkmMaterial({
    required String nodevice,
    required String notransaksi,
    required String tanggal,
    required List<Map<String, dynamic>> datafromserver,
  }) async {
    final errors = <String>[];
    final db = await _dbHelper.database;
    if (db == null) return ['Database tidak tersedia'];

    try {
      // Buat peta dari datafromserver: key = nodevice+kodekegiatan+kodeorg
      final Map<String, String> notrx = {};
      for (final item in datafromserver) {
        final key = item.keys.first;
        final value = item.values.first;
        notrx[key] = value.toString(); // pastikan String
      }

      // Query SQLite untuk ambil material
      final List<Map<String, dynamic>> result = await db.rawQuery(
        'SELECT * FROM kebun_pakaimaterial WHERE notransaksi = ?',
        [nodevice],
      );

      List<List<String>> datamaterial = [];

      for (var row in result) {
        final kodekegiatan = row['kodekegiatan']?.toString() ?? '';
        final kodeorg = row['kodeorg']?.toString() ?? '';
        final key = '$nodevice$kodekegiatan$kodeorg';

        datamaterial.add([
          kodekegiatan,
          kodeorg,
          row['gudang']?.toString() ?? '',
          row['kodebarang']?.toString() ?? '',
          row['kwantitasha']?.toString() ?? '',
          row['kwantitas']?.toString() ?? '',
          notrx[key] ?? '', // bisa null jika tidak ditemukan
        ]);
      }

      final errors = await execBkmMaterial(
        nodevice: nodevice,
        notransaksi: notransaksi,
        tanggal: tanggal,
        datamaterial: datamaterial,
        number: 0,
        datafromserver: datafromserver,
      );

      return errors;
    } catch (e) {
      errors.add('Error di synBkmMaterial: $e');
    }

    return errors;
  }

  Future<List<String>> execBkmMaterial({
    String? nodevice,
    String? notransaksi,
    String? tanggal,
    List<List<String>>? datamaterial,
    int number = 0,
    required List<Map<String, dynamic>> datafromserver,
  }) async {
    final errors = <String>[];
    final Database? db = await _dbHelper.database;
    if (db == null) return [];

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    // var server = prefs.getString('server');
    var server = ApiConstants.apiBaseUrlTesting;
    var subbagian = prefs.getString('subbagian');
    var username = prefs.getString('username');
    var password = prefs.getString('password');

    try {
      await db.execute('BEGIN TRANSACTION');

      const int limit = 50;
      int forloop = number + limit;
      if (forloop >= datamaterial!.length) {
        forloop = datamaterial.length;
      }

      List<String> kodekegiatan = [];
      List<String> kodeorg = [];
      List<String> gudang = [];
      List<String> kodebarang = [];
      List<String> kwantitasha = [];
      List<String> kwantitas = [];
      List<String> notransaksisrv = [];

      int urut = 0;

      for (int x = number; x < forloop; x++) {
        final row = datamaterial[x];
        kodekegiatan.add(row[0]);
        kodeorg.add(row[1]);
        gudang.add(row[2]);
        kodebarang.add(row[3]);
        kwantitasha.add(row[4]);
        kwantitas.add(row[5]);
        notransaksisrv.add(row[6]);
      }

      print(notransaksisrv);

      List<String> notransaksiList = notransaksisrv;

      Map<String, String> paramMap = {
        'method': 'transaction',
        'tipeData': 'bkm',
        'datatransfer': 'datamaterial',
        'username': username.toString(),
        'password': password.toString(),
        'uuid': '',
        'nobkm': notransaksiList.join(','),
        'notransaksi': notransaksi.toString(),
        'nodevice': nodevice.toString(),
        'tanggal': tanggal.toString(),
        'nourut': number.toString(),
        'kodekegiatan': kodekegiatan.join(','),
        'kodeorg': kodeorg.join(','),
        'gudang': gudang.join(','),
        'kodebarang': kodebarang.join(','),
        'kwantitasha': kwantitasha.join(','),
        'kwantitas': kwantitas.join(','),
      };

      final url = "$server/owlMobile.php";
      final response = await sendPostRequest(url, paramMap);

      if (response != null && response.statusCode == 200) {
        final json = jsonDecode(response.body);

        String notransaksi = json['notransaksi'];
        String nodevice = json['nodevice'];
        String tanggal = json['tanggal'];
        String lanjut = json['lanjut'];
        bool isError = json['err']['err'] == 'true';
        String message = json['err']['mssg'];

        final errors = await insertImageBkm(
          nodevice: nodevice,
          notransaksi: notransaksi,
          tanggal: tanggal,
          datafromserver: datafromserver,
        );

        return errors;
      } else {
        errors.add("Server error: ${response?.statusCode ?? 'no response'}");
      }

      await db.execute('COMMIT');
    } catch (e) {
      print(e);
      await db.execute('ROLLBACK');
      debugPrint('Error: $e');
      rethrow;
    }

    return errors;
  }

  void printFullUrl(String server, Map<String, String> paramMap) {
    final query = paramMap.entries
        .map((e) =>
            "${Uri.encodeQueryComponent(e.key)}=${Uri.encodeQueryComponent(e.value)}")
        .join("&");

    final fullUrl = "$server/owlMobile.php?$query";
    print("🔗 Full URL: $fullUrl");
  }

  String normalizeDataUri(String? maybeEncoded) {
    if (maybeEncoded == null) return '';
    String s = maybeEncoded;

    // 1) jika ter-percent-encoded, decode dulu
    if (s.contains('%')) {
      try {
        s = Uri.decodeComponent(s);
      } catch (e) {
        print('normalizeDataUri: decodeComponent failed: $e');
      }
    }

    // 2) replace spaces -> + (safety for base64)
    s = s.replaceAll(' ', '+');

    // 3) jika hanya base64 tanpa prefix, tambahkan prefix
    if (!s.startsWith('data:') && s.length > 100 && s.contains('/9j/')) {
      s = 'data:image/jpeg;base64,$s';
    }

    return s;
  }

  Future<List<String>> insertImageBkm({
    required String nodevice,
    required String notransaksi,
    required String tanggal,
    required List<Map<String, dynamic>> datafromserver,
  }) async {
    final errors = <String>[];

    final db = await _dbHelper.database;
    if (db == null) return ['Database tidak tersedia'];

    try {
      final Map<String, String> notrx = {};
      for (final item in datafromserver) {
        final key = item.keys.first;
        final value = item.values.first;
        notrx[key] = value.toString(); // pastikan String
      }

      List<String> strData = [];

      String query = '''
    SELECT 
      t1.*, 
      t2.namakegiatan 
    FROM (
      SELECT 
        notransaksi,
        CASE 
          WHEN nobkm = "" OR nobkm IS NULL THEN "kosong" 
          ELSE nobkm 
        END AS nobkm,
        fotoStart2,
        CASE 
          WHEN jumlahhasilkerja = "" OR jumlahhasilkerja IS NULL THEN "kosong" 
          ELSE jumlahhasilkerja 
        END AS jumlahhasilkerja,
        fotoEnd2,
        kodeorg, 
        kodekegiatan 
      FROM kebun_prestasi 
      WHERE notransaksi = ?
    ) AS t1
    LEFT JOIN setup_kegiatan t2 ON t1.kodekegiatan = t2.kodekegiatan;
  ''';

      final List<Map<String, dynamic>> results =
          await db.rawQuery(query, [nodevice]);

      print(results);

      // List<List<String>> data = [];

      // String potoawal = "";
      // String potoakhir = "";
      // String namakegiatan = "";
      // String potoawal2 = "";
      // String potoakhir2 = "";

      for (var row in results) {
        String? nobkm = row['nobkm'];
        String? fotoStart2 = row['fotoStart2'];
        String? jumlahhasilkerja = row['jumlahhasilkerja'];
        String? fotoEnd2 = row['fotoEnd2'];
        String kodeorg = row['kodeorg'];
        String kodekegiatan = row['kodekegiatan'];

        String? potoawal;
        String? potoakhir;
        String? potoawal2;
        String? potoakhir2;

        potoawal = await PhotoHelper.encodeFileForParam(nobkm);
        potoakhir = await PhotoHelper.encodeFileForParam(fotoStart2);

        potoawal2 = await PhotoHelper.encodeFileForParam(jumlahhasilkerja);
        potoakhir2 = await PhotoHelper.encodeFileForParam(fotoEnd2);

        print('foto awal');
        print(potoawal);

        // if (nobkm != null && nobkm != "kosong" && nobkm.contains("/")) {
        //   potoawal = "data:image/jpeg;base64,$potoawal";
        // }

        // if (fotoStart2 != null && fotoStart2.contains("/")) {
        //   potoawal2 = "data:image/jpeg;base64,$potoawal2";
        // }

        // if (jumlahhasilkerja != null &&
        //     jumlahhasilkerja != "kosong" &&
        //     jumlahhasilkerja.contains("/")) {
        //   potoakhir = "data:image/jpeg;base64,$potoakhir2";
        // }

        // if (fotoEnd2 != null && fotoEnd2.contains("/")) {
        //   potoakhir2 = "data:image/jpeg;base64,$potoakhir2";
        // }

        // Buat key gabungan
        String key = '$nodevice$kodekegiatan$kodeorg';
        String notransaksisrv = notrx[key] ?? '';

        String krmD = '&notransaksisrv=$notransaksisrv'
            '&kegiatan=$kodekegiatan'
            '&kodeorg=$kodeorg'
            '&potoawal=$potoawal'
            '&potoakhir=$potoakhir'
            '&potoawal2=$potoawal2'
            '&potoakhir2=$potoakhir2';

        strData.add(krmD);
      }

      print('strData');
      print(strData);

      final errors = await execImageBkm(
        nodevice: nodevice,
        notransaksi: notransaksi,
        tanggal: tanggal,
        data: strData,
        number: 0,
      );

      return errors;

      // print(result);
    } catch (e) {
      errors.add('Error di synImage: $e');
    }

    return errors;
  }

  Future<List<String>> execImageBkm({
    String? nodevice,
    String? notransaksi,
    String? tanggal,
    required List<String> data,
    int number = 0,
  }) async {
    final errors = <String>[];

    final Database? db = await _dbHelper.database;
    if (db == null) return [];

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    // var server = prefs.getString('server');
    var server = ApiConstants.apiBaseUrlTesting;
    var kebun = prefs.getString('lokasitugas');
    var username = prefs.getString('username');
    var password = prefs.getString('password');

    try {
      // String strData = '&notransaksi=$notransaksi'
      //     '&noref=$nodevice'
      //     '&kodeorg=$kebun'
      //     '&tanggal=$tanggal';

      String strData = '&notransaksi=$notransaksi'
          '&noref=$nodevice'
          '&kodeorg=$kebun'
          '&tanggal=$tanggal';

      const int limit = 1;
      int forloop = number + limit;

      if (forloop >= data!.length) {
        forloop = data.length;
      }

      for (int i = number; i < forloop; i++) {
        strData += data[i];
      }

      List<String> kodekegiatan = [];
      List<String> kodeorg = [];
      List<String> notrxsrv = [];
      List<String> potoawal = [];
      List<String> potoakhir = [];
      List<String> potoawal2 = [];
      List<String> potoakhir2 = [];

      Map<String, String> notrxserver = {};

      for (int i = 0; i < data.length; i++) {
        // langsung split seperti JS

        kodekegiatan.add(data[i].split('&')[2].split('=')[1]);
        kodeorg.add(data[i].split('&')[3].split('=')[1]);
        notrxsrv.add(data[i].split('&')[1].split('=')[1]);
        potoawal.add(data[i].split('&')[4].split('=')[1]);
        potoakhir.add(data[i].split('&')[5].split('=')[1]);
        potoawal2.add(data[i].split('&')[6].split('=')[1]);
        potoakhir2.add(data[i].split('&')[7].split('=')[1]);

        notrxserver['$nodevice${kodekegiatan[i]}${kodeorg[i]}'] = notrxsrv[i];
      }

      // print(potoawal);

      String paramMap = 'method=transaction'
          '&tipeData=bkm'
          '&datatransfer=dataphoto'
          '&username=$username'
          '&password=$password'
          '&uuid='
          '$strData'
          '&kodeorg=${kodeorg.join(",")}'
          '&kodekegiatan=${kodekegiatan.join(",")}'
          '&notrx=${notrxsrv.join(",")}'
          '&potoawal_all=${potoawal.join(",")}'
          '&potoakhir_all=${potoakhir.join(",")}'
          '&potoawal2_all=${potoawal2.join(",")}'
          '&potoakhir2_all=${potoakhir2.join(",")}';

      print('param map');
      print(paramMap);

      final fullLink = "$server/owlMobile.php?$paramMap";

      // print('full link');
      // print(strData);
      // print(potoakhir);
      // print(potoawal2);
      // print(potoakhir2);

      final url = "$server/owlMobile.php";
      final response = await sendPostRequest(url, paramMap);

      if (response != null) {
        final json = jsonDecode(response.body);

        String notransaksi = json['notransaksi'];
        String noref = json['noref'];

        bool isError = json['err']['err'] == 'true';
        String message = json['err']['mssg'];

        final errors = await checkTransactionBkmComplete(
            notransaksi: noref, serverno: notransaksi, tanggal: tanggal);

        return errors;
      } else {
        errors.add("Server error: ${response?.statusCode ?? 'no response'}");
      }

      // print(result);
    } catch (e) {
      print(e);
      errors.add('Error di exec image: $e');
    }

    return errors;
  }

  Future<List<String>> checkTransactionBkmComplete(
      {String? notransaksi, String? serverno, String? tanggal}) async {
    var errors = <String>[];

    final Database? db = await _dbHelper.database;
    if (db == null) return [];

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    // var server = prefs.getString('server');
    var server = ApiConstants.apiBaseUrlTesting;
    var kebun = prefs.getString('lokasitugas');
    var username = prefs.getString('username');
    var password = prefs.getString('password');

    String str =
        ''' SELECT notransaksi FROM kebun_kehadiran where notransaksi='$notransaksi' UNION ALL SELECT notransaksi FROM kebun_pakaimaterial where notransaksi='$notransaksi' ''';
    final result = await db.rawQuery(str);
    int jmldetail = result.length;

    String strData = '&notransaksi=$notransaksi'
        '&noref=$serverno'
        '&tanggal=$tanggal'
        '&jmldetail=$jmldetail';

    String param = 'method=transaction'
        '&tipeData=bkm'
        '&datatransfer=checktransaction'
        '&username=$username'
        '&password=$password'
        '&uuid='
        '$strData';

    final url = "$server/owlMobile.php";
    final response = await sendPostRequest(url, param);

    if (response != null) {
      final json = jsonDecode(response.body);

      String notransaksi = json['notransaksi'];
      String noref = json['noref'];

      // print(param);

      final errors = await updateSyncedBKM(nodevice: notransaksi, noref: noref);

      return errors;
    }

    return errors;
  }

  Future<List<String>> updateSyncedBKM(
      {String? nodevice, String? notransaksi, String? noref}) async {
    final errors = <String>[];

    final Database? db = await _dbHelper.database;
    if (db == null) return [];

    String str =
        ''' update kebun_aktifitas set synchronized='$noref' where notransaksi='$nodevice' ''';

    final result = await db.rawQuery(str);

    errors.add('berhasil');

    return errors;
  }

  Future<http.Response?> sendPostRequest(String url, dynamic body) async {
    final uri = Uri.parse(url);

    try {
      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: body,
      );

      return response;
    } catch (e) {
      print("Error sending data to $url: $e");
      return null;
    }
  }
}
