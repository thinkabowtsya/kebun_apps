import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_application_3/services/constant.dart';
import 'package:flutter_application_3/services/db_helper.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

class SpbProvider with ChangeNotifier {
  final DBHelper _dbHelper = DBHelper();
  List<Map<String, dynamic>> _spblist = [];
  List<Map<String, dynamic>> _afdelinglist = [];
  List<Map<String, dynamic>> _kraniproduksiList = [];
  List<Map<String, dynamic>> _statuspksList = [];
  List<Map<String, dynamic>> _driverList = [];
  List<Map<String, dynamic>> _vehicleList = [];
  List<Map<String, dynamic>> _kernetOnSpb = [];
  List<Map<String, dynamic>> _kernetList = [];
  List<Map<String, dynamic>> _spbDetail = [];
  List<Map<String, dynamic>> _spbHeader = [];
  List<Map<String, dynamic>> _spbDetailList = [];

  bool _shouldRefresh = false;
  String _notransaksi = '';
  String _selectedAfdeling = '';
  String _selectedKrani = '';
  String _selectedStatuspks = '';
  String _selectedDriver = '';
  String _selectedVehicle = '';
  String _selectedKernet = '';
  String _selectedStatus = '';
  String _selectedStatusDetail = '';
  String _selectedImage = '';
  String _labelPks = 'PKS Tujuan';
  String? _capturedImage;
  late DateTime _tanggal;

  List<Map<String, dynamic>> get spblist => _spblist;
  List<Map<String, dynamic>> get afdelinglist => _afdelinglist;
  List<Map<String, dynamic>> get kraniproduksilist => _kraniproduksiList;
  List<Map<String, dynamic>> get statuspkslist => _statuspksList;
  List<Map<String, dynamic>> get driverlist => _driverList;
  List<Map<String, dynamic>> get vehicleList => _vehicleList;
  List<Map<String, dynamic>> get kernetList => _kernetList;
  List<Map<String, dynamic>> get spbDetailList => _spbDetail;
  List<Map<String, dynamic>> get kernetOnSpb => _kernetOnSpb;
  List<Map<String, dynamic>> get spbHeader => _spbHeader;
  List<Map<String, dynamic>> get spbDetail => _spbDetailList;
  String? get notransaksi => _notransaksi;
  String? get selectedAfdeling => _selectedAfdeling;
  String? get selectedKrani => _selectedKrani;
  String? get selectedStatuspks => _selectedStatuspks;
  String? get selectedDriver => _selectedDriver;
  String? get selectedVehicle => _selectedVehicle;
  String? get selectedKernet => _selectedKernet;
  String? get labelpks => _labelPks;
  String? get selectedImage => _selectedImage;
  String? get selectedstatus => _selectedStatus;
  String? get selectedstatusdetail => _selectedStatusDetail;

  String? get capturedImage => _capturedImage;
  List<Map<String, dynamic>> denda = [];

  void setShouldRefresh(bool value) {
    _shouldRefresh = value;
    notifyListeners();
  }

  void setNotransaksi(String value) {
    _notransaksi = value;

    notifyListeners();
  }

  void setTanggal(DateTime value) {
    _tanggal = value;

    notifyListeners();
  }

  void setAfdeling(String value) {
    _selectedAfdeling = value;
    notifyListeners();
  }

  void setKrani(String value) {
    _selectedKrani = value;
    notifyListeners();
  }

  void setStatusPks(String value) {
    _selectedStatuspks = value;

    notifyListeners();
  }

  void setDriver(String value) {
    _selectedDriver = value;
    notifyListeners();
  }

  void setVehicle(String value) {
    _selectedVehicle = value;
    notifyListeners();
  }

  void setKernet(String value) {
    _selectedKernet = value;
    notifyListeners();
  }

  void setStatus(String value) {
    _selectedStatus = value;
    notifyListeners();
  }

  void setImage(String? value) {
    _capturedImage = value;
    notifyListeners();
  }

  void setKendaraan(String value) {
    _selectedVehicle = value;
    notifyListeners();
  }

  void setStatusDetail(String value) {
    _selectedStatusDetail = value;
    notifyListeners();
  }

  void resetDefaults() {
    _notransaksi = '';
    _selectedAfdeling = '';
    _selectedKrani = '';
    _selectedStatuspks = '';
    _selectedDriver = '';
    _selectedVehicle = '';
    _selectedKernet = '';
    _selectedStatus = '';
    _capturedImage = null;
    notifyListeners();
  }

  List<Map<String, String>> _selectedKernetList = [];

  List<Map<String, String>> get selectedKernetList => _selectedKernetList;

  void setKernetList(List<Map<String, String>> list) {
    _selectedKernetList = list;
    notifyListeners();
  }

  Future<void> fetchSpb() async {
    final Database? db = await _dbHelper.database;
    if (db == null) return;

    final prefs = await SharedPreferences.getInstance();
    final kebun = prefs.getString('lokasitugas')?.trim();
    final username = prefs.getString('username')?.trim();

    // Safety: kalau kebun null, hentikan lebih awal biar query LIKE 'null%' gak kejadian
    if (kebun == null || kebun.isEmpty) {
      // optional: log / throw
      debugPrint('prefs.lokasitugas kosong');
      return;
    }

    // 0. Krani Produksi
    final strSel = '''
    SELECT *
    FROM datakaryawan
    WHERE kodejabatan IN (SELECT nilai FROM setup_parameterappl WHERE kodeparameter = 'KRNISPB')
      AND lokasitugas = ?
    ORDER BY namakaryawan
  ''';
    final result = await db.rawQuery(strSel, [kebun]);
    _kraniproduksiList = result;

    // 1. List Afdeling
    final strAfd = '''
    SELECT kodeorganisasi AS key, namaorganisasi AS val
    FROM organisasi
    WHERE tipeorganisasi = 'AFDELING'
      AND kodeorganisasi LIKE ?
    ORDER BY kodeorganisasi
  ''';
    final afdRes = await db.rawQuery(strAfd, ['$kebun%']);
    _afdelinglist = afdRes;

    // 2. Default name (pakai alias 'val', bukan 'namaorganisasi')
    final strDefault = '''
    SELECT kodeorganisasi AS key, namaorganisasi AS val
    FROM organisasi
    WHERE tipeorganisasi = 'AFDELING'
      AND kodeorganisasi LIKE ?
    ORDER BY kodeorganisasi
  ''';
    final defaultRes = await db.rawQuery(strDefault, ['%$kebun%']);

    final String? defaultName =
        defaultRes.isNotEmpty ? defaultRes.first['val']?.toString() : null;

    // 3. Auto select
    if (_afdelinglist.isNotEmpty) {
      final defaultAfd = _afdelinglist.firstWhere(
        (item) {
          final itemVal = item['val']?.toString().toLowerCase() ?? '';
          return defaultName != null && itemVal == defaultName.toLowerCase();
        },
        orElse: () => _afdelinglist.first,
      );
      setAfdeling(defaultAfd['key'].toString());
    }

    notifyListeners();
  }

  Future<void> fetchDriver({String value = '', String where = ''}) async {
    final Database? db = await _dbHelper.database;
    if (db == null) return;

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    var kebun = prefs.getString('lokasitugas') ?? '';

    String pilihan = value.trim();
    String wheretext =
        where.trim().isNotEmpty ? where : " and lokasitugas='$kebun' ";

    if (pilihan.isNotEmpty) {
      String checkstr =
          "SELECT karyawanid FROM datakaryawan WHERE karyawanid = '$pilihan'";
      final checkResult = await db.rawQuery(checkstr);

      if (checkResult.isNotEmpty) {
        // Jika ditemukan → ambil union list
        String strquery = """
        SELECT 'other' as karyawanid, '' as lokasitugas,'' as subbagian,'' as namakaryawan,'' as namakaryawan2,'' as nik
        UNION
        SELECT karyawanid,lokasitugas,subbagian,namakaryawan,namakaryawan2,nik
        FROM datakaryawan WHERE 1=1 $wheretext
        ORDER BY subbagian,namakaryawan
      """;
        _driverList = await db.rawQuery(strquery);
      } else {
        // Jika tidak ditemukan → langsung set "other" saja
        _driverList = [
          {
            'karyawanid': 'other',
            'lokasitugas': '',
            'subbagian': '',
            'namakaryawan': '',
            'namakaryawan2': '',
            'nik': '',
          }
        ];
        // (Tambahkan logika untuk hide elemen kalau perlu di Flutter)
      }
    } else {
      // Jika pilihan kosong → tetap ambil union list
      String strquery = """
      SELECT 'other' as karyawanid, '' as lokasitugas,'' as subbagian,'' as namakaryawan,'' as namakaryawan2,'' as nik
      UNION
      SELECT karyawanid,lokasitugas,subbagian,namakaryawan,namakaryawan2,nik
      FROM datakaryawan WHERE 1=1 $wheretext
      ORDER BY subbagian,namakaryawan
    """;
      _driverList = await db.rawQuery(strquery);
    }

    notifyListeners();
  }

  Future<void> fetchVehicle({String value = ''}) async {
    final Database? db = await _dbHelper.database;
    if (db == null) return;

    String selected = value.trim();
    List<Map<String, dynamic>> vehicleList = [];

    if (selected.isNotEmpty) {
      // cek apakah nopol ada di DB
      String checkStr =
          "SELECT nopol FROM vhc_5master WHERE nopol = '$selected'";
      final checkResult = await db.rawQuery(checkStr);

      if (checkResult.isNotEmpty) {
        // jika ada, ambil union dengan other
        String strQuery = """
        SELECT 'other' AS key, 'Other..' AS val
        UNION ALL
        SELECT nopol AS key, nopol || ' || ' || detailvhc AS val
        FROM vhc_5master
      """;
        vehicleList = await db.rawQuery(strQuery);
      } else {
        vehicleList = [
          {
            "key": "other",
            "val": selected,
          }
        ];
        // di Cordova: otherFieldNopol(ele, selected)
        // di Flutter: bisa tambahkan logika untuk handle input manual
      }
    } else {
      // kalau kosong → ambil semua + other
      String strQuery = """
      SELECT 'other' AS key, 'Other..' AS val
      UNION
      SELECT nopol AS key, nopol || ' || ' || detailvhc AS val
      FROM vhc_5master
      WHERE nopol != ''
      ORDER BY key DESC, val DESC
    """;
      vehicleList = await db.rawQuery(strQuery);
    }

    _vehicleList = vehicleList;
    notifyListeners();
  }

  Future<void> fetchTkbm({String value = '', String where = ''}) async {
    final Database? db = await _dbHelper.database;
    if (db == null) return;

    String pilihan = value.trim();
    String wheretxt = where.trim();

    List<Map<String, dynamic>> tkbmList = [];

    if (pilihan.isNotEmpty) {
      // cek apakah karyawanid ada
      String checkStr =
          "SELECT karyawanid FROM datakaryawan WHERE karyawanid = '$pilihan'";
      final checkResult = await db.rawQuery(checkStr);

      if (checkResult.isNotEmpty) {
        // kalau ada → ambil list tkbm sesuai filter
        String strQuery = """
        SELECT karyawanid,lokasitugas,subbagian,namakaryawan,namakaryawan2,nik
        FROM datakaryawan
        WHERE 1=1 $wheretxt
        ORDER BY subbagian, namakaryawan
      """;
        tkbmList = await db.rawQuery(strQuery);
      } else {
        // kalau tidak ada → sama seperti otherField di Cordova
        tkbmList = [
          {
            "karyawanid": "other",
            "lokasitugas": "",
            "subbagian": "",
            "namakaryawan": pilihan, // tampilkan input manual
            "namakaryawan2": "",
            "nik": "",
          }
        ];
      }
    } else {
      // kalau value kosong → ambil semua
      String strQuery = """
      SELECT karyawanid,lokasitugas,subbagian,namakaryawan,namakaryawan2,nik
      FROM datakaryawan
      WHERE 1=1 $wheretxt
      ORDER BY subbagian, namakaryawan
    """;
      tkbmList = await db.rawQuery(strQuery);
    }

    _kernetList = tkbmList; // simpan ke state/provider
    notifyListeners();
  }

  Future<List<Map<String, dynamic>>> fetchSpbList(String? tanggal) async {
    final Database? db = await _dbHelper.database;
    if (db == null) return [];

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    var kebun = prefs.getString('lokasitugas');
    var username = prefs.getString('username')?.trim();
    String changedata = '';
    final now = DateFormat('yyyy-MM-dd').format(DateTime.now());

    if (tanggal == null) {
      changedata = 'AND (synchronized = "" OR tanggal = "$now")';
    } else {
      if (tanggal.isEmpty) {
        throw Exception('Tanggal kosong');
      } else {
        changedata = " AND tanggal = '$tanggal'";
      }
    }

    String query =
        ''' SELECT nospb,tanggal,penerimatbs,synchronized,ifnull(cetakan,0) as cetakan  FROM kebun_spbht where updateby='$username' $changedata order by nospb desc ''';

    final result = await db.rawQuery(query);

    _spblist = result;

    print('result');
    print(result);
    notifyListeners();
    return _spblist;
  }

  Future<List<Map<String, dynamic>>> fetchStatusPks(String? statusId) async {
    final Database? db = await _dbHelper.database;
    if (db == null) return [];

    List<Map<String, dynamic>> tes = [
      {'label': 'Internal', 'value': '0'},
      {'label': 'Afiliasi', 'value': '1'},
      {'label': 'TPB', 'value': '2'},
      {'label': 'External', 'value': '3'},
      {'label': 'Peron', 'value': '4'},
    ];

    return tes.map((item) {
      return {
        'id': item['value'].toString(),
        'name': item['label'],
        'subtitle': "",
      };
    }).toList();
  }

  Future<List<Map<String, dynamic>>> fetStatusPksDinamis(
      String? statusId, String? val) async {
    final db = await _dbHelper.database;
    if (db == null) return [];

    // list dummy (kalau memang dipakai di UI, tetap ada)
    final tes = [
      {'label': 'Internal', 'value': '0'},
      {'label': 'Afiliasi', 'value': '1'},
      {'label': 'TPB', 'value': '2'},
      {'label': 'External', 'value': '3'},
      {'label': 'Peron', 'value': '4'},
    ];

    final pksValue = (val ?? '').trim();
    if (statusId == null || statusId.isEmpty) return [];

    String? pks;

    // ====== STATUS EXTERNAL ======
    if (statusId == '3') {
      if (pksValue.isNotEmpty) {
        pks = 'where kodecustomer = $pksValue';
      }
      _labelPks = 'TPH Tujuan';

      final sql =
          ''' SELECT kodecustomer, namacustomer FROM pmn_4customer ${pks ?? ''} order by namacustomer ''';

      final result = await db.rawQuery(sql);
      return result
          .map((item) => {
                'id': item['kodecustomer'].toString(),
                'name': item['namacustomer'].toString(),
                'subtitle': '',
              })
          .toList();
    }

    // ====== STATUS TPB ======
    if (statusId == '2') {
      _labelPks = 'TPH Tujuan';
      final defaultValuePks = _selectedAfdeling;
      if (pksValue.isNotEmpty) {
        pks = 'where divisi = $pksValue';
      } else {
        pks = 'where divisi = $defaultValuePks';
      }

      final sql = ''' SELECT notph FROM kebun_5tphbesar $pks order by notph ''';

      final result = await db.rawQuery(sql);
      return result
          .map((item) => {
                'id': item['notph'].toString(),
                'name': item['notph'].toString(),
                'subtitle': '',
              })
          .toList();
    }

    // ====== STATUS PERON ======
    if (statusId == '4') {
      _labelPks = 'TPH Tujuan';
      final sql = ''' SELECT nama FROM kebun_5peron ''';

      final result = await db.rawQuery(sql);
      return result
          .map((item) => {
                'id': item['nama'].toString(),
                'name': item['nama'].toString(),
                'subtitle': '',
              })
          .toList();
    }

    // ====== STATUS INTERNAL / AFILIASI ======
    if (pksValue.isNotEmpty) {
      pks = 'and kodeorganisasi ="$pksValue" ';
    }

    final prefs = await SharedPreferences.getInstance();
    final pt = prefs.getString('pt') ?? '';

    String sql;
    if (statusId == '0') {
      sql =
          ''' SELECT kodeorganisasi FROM organisasi where tipeorganisasi="PABRIK" and induk='$pt' ${pks ?? ''} order by kodeorganisasi ''';
    } else {
      sql =
          ''' SELECT kodeorganisasi FROM organisasi where tipeorganisasi="PABRIK" and induk!='$pt' ${pks ?? ''} order by kodeorganisasi ''';
    }

    final result = await db.rawQuery(sql);
    return result
        .map((item) => {
              'id': item['kodeorganisasi'].toString(),
              'name': item['kodeorganisasi'].toString(),
              'subtitle': '',
            })
        .toList();
  }

  Future<List<String>> simpanSpb({String notransaksi = ''}) async {
    final db = await _dbHelper.database;
    if (db == null) return [];
    final errors = <String>[];
    String notransaksi = _notransaksi;
    DateTime tanggal = _tanggal;
    String afd = _selectedAfdeling;
    String keranitransport = _selectedKrani;
    String statusTujuan = _selectedStatus;
    String statuspks = _selectedStatuspks;
    String supir = _selectedDriver;
    String kendaraan = _selectedVehicle;
    String? foto = _capturedImage;

    final prefs = await SharedPreferences.getInstance();
    final lat = prefs.getDouble('last_latitude') ?? 0.0;
    final lng = prefs.getDouble('last_longitude') ?? 0.0;
    String updateby = prefs.getString('username')!.trim();

    String lastupdate = DateTimeUtils.lastUpdate();
    String formattedDate = DateFormat('yyyy-MM-dd').format(_tanggal);

    if (notransaksi.isEmpty) {
      errors.add('Nomor transaksi wajib diisi');
      return errors;
    }

    if (tanggal == null) {
      errors.add('Tanggal wajib diisi');
      return errors;
    }

    if (afd.isEmpty) {
      errors.add('Afdeling wajib diisi');
      return errors;
    }

    if (keranitransport.isEmpty) {
      errors.add('Kerani Transport wajib diisi');
      return errors;
    }

    if (statusTujuan.isEmpty) {
      errors.add('Status Tujuan wajib diisi');
      return errors;
    }

    if (statuspks.isEmpty) {
      errors.add('Status PKS wajib diisi');
      return errors;
    }

    if (supir.isEmpty) {
      errors.add('Supir wajib diisi');
      return errors;
    }

    if (kendaraan.isEmpty) {
      errors.add('Kendaraan wajib diisi');
      return errors;
    }

    if (foto == null) {
      errors.add('Foto wajib diisi');
      return errors;
    }

    try {
      await db.transaction((txn) async {
        String checkStr =
            '''  SELECT * FROM kebun_spbht where nospb=? '''; // parameterized

        final result = await txn.rawQuery(checkStr, [_notransaksi]);

        // insert atau update
        if (result.isEmpty) {
          await txn.insert('kebun_spbht', {
            'nospb': notransaksi,
            'spbfile': foto,
            'kraniproduksi': keranitransport,
            'tujuan': statusTujuan,
            'penerimatbs': statuspks,
            'tanggal': formattedDate,
            'afdeling': afd,
            'driver': supir,
            'nopol': kendaraan,
            'updateby': updateby,
            'synchronized': '',
            'lat': lat,
            'lon': lng,
            'cetakan': '0',
            'lastupdate': lastupdate,
          });
        } else {
          // === Sudah ada data ===
          final existing = result.first;
          final afDel = existing['afdeling'] as String? ?? '';
          final oldLat = existing['lat'] ?? '';
          final oldLon = existing['lon'] ?? '';
          final oldAlt = existing['alt'] ?? '';
          final oldAcr = existing['acr'] ?? '';

          if (afDel == afd) {
            // Update data tapi tetap pakai lat/lon/alt lama
            await txn.update(
              'kebun_spbht',
              {
                'spbfile': foto,
                'kraniproduksi': keranitransport,
                'tujuan': statusTujuan,
                'penerimatbs': statuspks,
                'tanggal': formattedDate,
                'afdeling': afd,
                'driver': supir,
                'nopol': kendaraan,
                'updateby': updateby,
                'synchronized': '',
                'lat': oldLat,
                'lon': oldLon,
                'alt': oldAlt,
                'acr': oldAcr,
                'cetakan': '0',
                'lastupdate': lastupdate,
              },
              where: 'nospb = ?',
              whereArgs: [notransaksi],
            );
          } else {
            // jika beda afdeling: isi errors lalu rollback dengan throw
            errors.add("SPB dengan nomor yang sama sudah ada di divisi lain!");
            throw StateError('spb_divisi_berbeda');
          }
        }

        // delete dulu dan insert ulang daftar kernet (masih di dalam transaction)
        await txn.delete('kebun_spbtkbm',
            where: 'nospb = ?', whereArgs: [notransaksi]);

        for (var row in _selectedKernetList) {
          await txn.insert('kebun_spbtkbm', {
            'nospb': notransaksi,
            'karyawanid': row['id'],
            'namakaryawan': row['nama'],
            'jumlahjjg': 0,
          });
        }
        // jika sampai sini tanpa throw => commit otomatis
      });
    } catch (e, st) {
      debugPrint('simpanSpb transaction error: $e\n$st');
      if (errors.isNotEmpty) {
        return errors;
      }
      return ['Terjadi kesalahan saat menyimpan SPB: ${e.toString()}'];
    }

    print('after simpan data');

    // optional: untuk debugging kamu ingin melihat isi table, tapi tidak mengubah logika:
    print(await db.rawQuery(''' select * from kebun_spbht'''));
    notifyListeners();
    return errors;
  }

  Future<void> deleteSpb(String notransaksi) async {
    final Database? db = await _dbHelper.database;
    if (db == null) return;

    print(notransaksi);
    await db.transaction((txn) async {
      await txn.delete(
        'kebun_spbht',
        where: 'nospb = ?',
        whereArgs: [notransaksi],
      );
      await txn.delete(
        'kebun_spbdt',
        where: 'nospb = ?  ',
        whereArgs: [notransaksi],
      );

      await txn.delete(
        'kebun_spbtkbm',
        where: 'nospb = ?',
        whereArgs: [notransaksi],
      );

      await txn.delete(
        'kebun_spb_split',
        where: 'nospb = ?',
        whereArgs: [notransaksi],
      );
    });

    notifyListeners();
  }

  Future<void> deleteSpbDetail(
      {String? notransaksi,
      String? blok,
      String? nospbref,
      String? rotasi,
      String? nik}) async {
    final Database? db = await _dbHelper.database;
    if (db == null) return;

    String where = '';

    if (blok == '') {
      where = "and nospbref='$nospbref' ";
    } else {
      where = " and blok='$blok' and nik='$nik' and rotasi='$rotasi' ";
    }

    print(await db
        .rawQuery("select * from kebun_spbdt where nospb='$notransaksi' "));
    await db.rawQuery(
        '''delete from kebun_spbdt where nospb='$notransaksi' $where   ''');
    await db.rawQuery(
        '''delete from kebun_spb_split where nospb='$notransaksi' $where   ''');

    notifyListeners();
  }

  Future<List<String>> spbResultScan(
      Map<String, dynamic> data, String tipespb) async {
    final db = await _dbHelper.database;
    if (db == null) return [];

    final errors = <String>[];

    denda = List<Map<String, dynamic>>.from(data['denda'] ?? []);
    print('from provider $data');

    String besar = _selectedStatusDetail;

    String spbtph = '';
    String latitute = '';
    String longitute = '';
    String where = '';

    String spbno = '';
    String divisiuser = '';
    String gerdang = '';
    String blok = '';
    String noTransaksi = '';
    String nik = '';
    String jjg = '';
    String brondolan = '';
    String tanggal = '';
    String mandor1 = '';
    String mandor2 = '';
    String kerani = '';
    String status = '';
    String cetakan = '';
    String rotasi = '';
    String tahuntanam = '';

    // print('tipespb $tipespb');

    if (tipespb == '1') {
      tipespb = 'normal';
    } else {
      tipespb = 'double';
    }

    if (tipespb == 'normal') {
      spbno = _notransaksi.toString();
      divisiuser = _selectedAfdeling.toString();
      gerdang = '';
      blok = data['noTph'].toString();
      noTransaksi = data['noTransaksi'].toString();
      nik = data['pemanenNik'].toString();
      jjg = data['jjg'].toString();
      brondolan = data['brondolan'].toString();
      tanggal = data['tanggal'].toString();
      mandor1 = data['mandor1'].toString();
      mandor2 = data['mandor2'].toString();
      kerani = data['kerani'].toString();
      status = data['status'].toString();
      cetakan = data['cetakan'].toString();
      rotasi = data['rotasi'].toString();

      print('tipe spb : $tipespb');

      where =
          "and tglpanen = '$tanggal' and blok = '$blok' and nik = '$nik' and rotasi='$rotasi'  ";

      String divisi = blok.substring(0, 6);

      if (divisi == divisiuser) {
        String str = ''' select * from setup_tph where kode='$blok' limit 1 ''';

        final result = await db.rawQuery(str);

        if (result.isNotEmpty) {
          for (var row in result) {
            spbtph = row['kode'].toString();
            latitute = row['latitude'].toString();
            longitute = row['logitude'].toString();
          }
        } else {
          errors.add('Tph $spbtph belum terdaftar');
          return errors;
        }
      } else {
        errors.add('Tph $spbtph belum terdaftar');
        return errors;
      }
    } else if (tipespb == 'double') {
      // nanti dibuat validasi cek scan qr

      blok = data['noTransaksi'].toString();
      noTransaksi = "";
      mandor1 = "";
      mandor2 = "";

      nik = "";
      gerdang = "";
      rotasi = "1";
      jjg = data['jjg'].toString();
      tahuntanam = data['tanggal'].toString();
      brondolan = data['brondolan'].toString();
      tanggal = "";
      where = "and nospbref='$blok'";

      if (blok == spbno) {
        errors.add('spb yang dimasukkan sudah di divisi lain');
        return errors;
      }
    }

    String strCheck = ''' select * from kebun_spbdt where 1=1 $where ''';

    final resultCheck = await db.rawQuery(strCheck);

    if (resultCheck.isNotEmpty) {
      if (tipespb == 'normal') {
        errors.add('TPH $blok sudah pernah di scan sebelumnya');
        return errors;
      } else if (tipespb == 'double') {
        errors.add('nospb $blok sudah pernah di scan sebelumnya');
        return errors;
      }
    } else {
      if (tipespb == 'double' || tipespb == 'normal') {
        String asisten = data['asisten'].toString();
        String krani = data['kerani'].toString();
        String luaspanen = data['luaspanen'].toString() ?? '';

        // print('sebelum simpan : $blok');

        final errors = await simpanSpbDetail(
            spbNo: spbno,
            blok: blok,
            nik: nik,
            rotasi: rotasi,
            tahuntanam: tahuntanam,
            berondolan: brondolan,
            janjang: jjg,
            tglpanen: tanggal,
            nikmandor: mandor2,
            nikmandor1: mandor1,
            gerdang: noTransaksi,
            besar: besar,
            tipespb: tipespb);

        return errors;
      }
    }

    notifyListeners();

    return errors;
  }

  Future<List<String>> simpanSpbDetail({
    required String spbNo,
    required String blok,
    required String nik,
    required String rotasi,
    required String tahuntanam,
    required String berondolan,
    required String janjang,
    required String tglpanen,
    required String nikmandor,
    required String nikmandor1,
    required String gerdang,
    required String besar,
    required String tipespb,
  }) async {
    final db = await _dbHelper.database;
    if (db == null) return [];
    final errors = <String>[];

    String spbBlok = '';
    String spbJJG = '';
    String spbJJGAwal = '';
    String spbBrondolan = '';
    String spbBrondolanAwal = '';
    String spbMentah = '';
    String spbBusuk = '';
    String spbMatang = '';
    String spbLewatMatng = '';
    String spbrotasi = '';
    String spbnik = '';
    String spbTahunTanam = '';
    String spbRef = '';
    String where = '';

    String spbFile = "";
    String spbLatitude = "";
    String spbLongitude = "";
    String spbAltitude = "";
    String spbAccuracy = "";

    if (spbNo.isEmpty) {
      spbNo = _notransaksi.toString();
      spbBlok = blok;
      spbJJG = janjang;
      spbBrondolan = berondolan;
      spbTahunTanam = tahuntanam;
      spbnik = '';
    } else {
      spbBlok = blok;
      spbJJG = janjang;
      spbBrondolan = berondolan;
      spbMentah = nikmandor;
      spbBusuk = nikmandor;
      spbMatang = gerdang;
      spbrotasi = rotasi;
      spbnik = nik;
      spbTahunTanam = tahuntanam;
      tglpanen = tglpanen;
      besar = besar;
    }

    spbJJG = spbJJG == '' ? '0' : spbJJG;
    spbBrondolan = spbBrondolan == '' ? '0' : spbBrondolan;
    spbLewatMatng = spbLewatMatng == '' ? '0' : spbLewatMatng;

    if (tipespb == 'normal') {
      spbRef = '';
      where =
          "and blok='$spbBlok' and nik='$spbnik' and rotasi='$spbrotasi' and tglpanen='$tglpanen' ";
    } else {
      spbRef = spbBlok;
      spbBlok = '';
      where = "and nospbref='$spbRef' ";
    }

    if (tipespb != 'normal' && spbRef == '') {
      errors.add('Silahkan scan $spbNo');
      return errors;
    }

    if (spbJJG == '0') {
      errors.add('Gagal Scan: Jumlah janjang kosong, silahkan check docket!');
      return errors;
    }

    try {
      await db.transaction((txn) async {
        String lastupdate = DateTimeUtils.lastUpdate();
        String formattedDate = DateFormat('yyyy-MM-dd').format(_tanggal);

        String strCheck = ''' select * from kebun_spbht where nospb=? ''';
        final result = await txn.rawQuery(strCheck, [spbNo]);

        if (result.isEmpty) {
          errors.add(
              'Docket/No.SPB tidak bisa discan, Header SPB agar disimpan terlebih dahulu !!');
          throw StateError('header_spb_missing'); // rollback otomatis
        } else {
          // delete dulu record sebelumnya
          await txn.rawDelete(
              'delete from kebun_spbdt where nospb=? $where', [spbNo]);

          // insert baru
          await txn.insert('kebun_spbdt', {
            'nospb': spbNo,
            'blok': spbBlok,
            'nik': nik,
            'rotasi': rotasi,
            'nospbref': spbRef,
            'jjg': spbJJG,
            'brondolan': spbBrondolan,
            'mentah': spbMentah,
            'busuk': spbBusuk,
            'matang': spbMatang,
            'lewatmatang': 0,
            'besar': besar,
            'tahuntanam': spbTahunTanam,
            'sFilename': tipespb,
            'lat': spbLatitude,
            'lon': spbLongitude,
            'alt': spbAltitude,
            'acr': spbAccuracy,
            'tglpanen': tglpanen,
            'lastupdate': lastupdate,
          });
        }
      });
    } catch (e, st) {
      debugPrint('simpanSpbDetail transaction error: $e\n$st');
      if (errors.isNotEmpty) return errors;
      return ['Terjadi kesalahan saat menyimpan SPB detail: ${e.toString()}'];
    }

    return errors;
  }

  Future<void> getListSpbdetail(String? nospb) async {
    final db = await _dbHelper.database;
    if (db == null) return;

    String str =
        ''' SELECT a.sFilename,a.nospbref,a.blok,c.bjr, d.nik,d.karyawanid,d.namakaryawan,d.nik || ' (' || d.namakaryawan || ')' AS nik_nama, a.rotasi,a.rotasi,a.rotasi,b.jjg as jjg_split, IFNULL((a.jjg-b.jjg),a.jjg) as jjg,IFNULL((a.brondolan-b.brondolan),a.brondolan) as brondolan FROM kebun_spbdt a LEFT JOIN kebun_spb_split b on a.nospbref = b.nospbref LEFT JOIN kebun_bjr c on a.blok = c.kodeorg LEFT JOIN datakaryawan d on a.nik=d.karyawanid WHERE a.nospb='$nospb' order by a.blok DESC, a.rotasi   ''';

    final result = await db.rawQuery(str);

    _spbDetail = result;

    notifyListeners();
  }

  Future<void> editSpb(String nospb) async {
    final db = await _dbHelper.database;
    if (db == null) return;

    String str = ''' select * from kebun_spbht where nospb='$nospb'  ''';
    final result = await db.rawQuery(str);

    final firstRow = result.first;

    for (var row in result) {
      _selectedAfdeling = row['afdeling'].toString();
      _selectedKrani = row['kraniproduksi'].toString();
      _selectedStatus = row['tujuan'].toString();
      _selectedStatuspks = row['penerimatbs'].toString();
      _selectedDriver = row['driver'].toString();
      _selectedVehicle = row['nopol'].toString();
      _selectedImage = row['spbfile'].toString();
      // _selectedAfdeling = row['afdeling '].toString();
    }

    String kernetSpb =
        '''  SELECT * FROM kebun_spbtkbm where nospb='$nospb' ''';

    final resultKernet = await db.rawQuery(kernetSpb);

    _kernetOnSpb = resultKernet;

    notifyListeners();
  }

  Future<void> lihatSpb({String? notransaksi}) async {
    final db = await _dbHelper.database;
    if (db == null) return;

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? username = prefs.getString('username')?.trim();

    final String qry = '''
      SELECT 
        a.*,
        b.namaorganisasi,
        ifnull(c.namakaryawan, a.driver) AS driver
      FROM kebun_spbht a
      LEFT JOIN organisasi b 
        ON a.afdeling = b.kodeorganisasi
      LEFT JOIN datakaryawan c 
        ON a.driver = c.karyawanid
      WHERE a.nospb = "$notransaksi"
      ORDER BY a.tanggal DESC
    ''';

    final header = await db.rawQuery(qry);

    _spbHeader = header;
    print('masuk');
    print(_spbHeader);

    String detailstr =
        ''' select * from kebun_spbdt where nospb='$notransaksi' order by blok desc  ''';

    final detail = await db.rawQuery(detailstr);
    _spbDetailList = detail;

    notifyListeners();
  }

  Future<void> resetForm() async {
    _selectedAfdeling = '';
    _selectedKrani = '';
    _selectedStatus = '';
    _selectedStatuspks = '';
    _selectedDriver = '';
    _selectedVehicle = '';
    _selectedImage = '';
  }

  Future<void> createTableSpb() async {
    final Database? db = await _dbHelper.database;
    if (db == null) return;

    await db.execute(''' CREATE TABLE IF NOT EXISTS kebun_spbht(nospb TEXT,
        spbfile BLOB,
        kraniproduksi TEXT,
        tujuan TEXT,
        penerimatbs TEXT,
        tanggal TEXT,
        afdeling TEXT,
        driver TEXT,
        nopol TEXT,
        lat TEXT,
        lon TEXT,
        alt TEXT,
        acr TEXT,
        synchronized TEXT,
        cetakan INTEGER,
        updateby TEXT,
        lastupdate TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL) ''');

    await db.execute(
        ''' CREATE TABLE IF NOT EXISTS kebun_spbdt(nospb TEXT,blok TEXT,nik TEXT,rotasi INT,nospbref TEXT,tglpanen TEXT,jjg TEXT,brondolan TEXT,mentah TEXT,busuk TEXT,matang TEXT,lewatmatang TEXT,besar TEXT,tahuntanam TEXT,sFilename BLOB,lat TEXT,lon TEXT,alt TEXT,acr TEXT,lastupdate TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL) ''');

    await db.execute(
        ''' CREATE TABLE IF NOT EXISTS kebun_spbtkbm(nospb TEXT,karyawanid TEXT,namakaryawan TEXT,jumlahjjg TEXT) ''');

    await db.execute(
        ''' CREATE TABLE IF NOT EXISTS kebun_spb_split(nospb TEXT,blok TEXT,nik TEXT,rotasi INT,nospbref TEXT,tglpanen TEXT,jjg TEXT,brondolan TEXT,mentah TEXT,busuk TEXT,matang TEXT,lewatmatang TEXT,besar TEXT,tahuntanam TEXT,sFilename BLOB,lat TEXT,lon TEXT,alt TEXT,acr TEXT,cetakan INTEGER,lastupdate TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL) ''');
  }
}
