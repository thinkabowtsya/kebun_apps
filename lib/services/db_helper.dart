import 'dart:convert';

import 'package:flutter_application_3/models/bjr.dart';
import 'package:flutter_application_3/models/blok.dart';
import 'package:flutter_application_3/models/customer.dart';
import 'package:flutter_application_3/models/datalastnospb.dart';
import 'package:flutter_application_3/models/dendapanen.dart';
import 'package:flutter_application_3/models/gpsinterval.dart';
import 'package:flutter_application_3/models/gudangtransaksi.dart';
import 'package:flutter_application_3/models/ijin.dart';
import 'package:flutter_application_3/models/kebun5bkm.dart';
import 'package:flutter_application_3/models/kebunperon.dart';
import 'package:flutter_application_3/models/kebunrkhdt.dart';
import 'package:flutter_application_3/models/kebunrkhdtmaterial.dart';
import 'package:flutter_application_3/models/kebunrkhht.dart';
import 'package:flutter_application_3/models/kegiatannorma.dart';
import 'package:flutter_application_3/models/kemandoran.dart';
import 'package:flutter_application_3/models/kemandoranblok.dart';
import 'package:flutter_application_3/models/keuakun.dart';
import 'package:flutter_application_3/models/klasifiasi.dart';
import 'package:flutter_application_3/models/kodedendapanen.dart';
import 'package:flutter_application_3/models/karyawan.dart';
import 'package:flutter_application_3/models/kegiatan.dart';
import 'package:flutter_application_3/models/kendaraan.dart';
import 'package:flutter_application_3/models/komoditi.dart';
import 'package:flutter_application_3/models/kontrakkegiatan.dart';
import 'package:flutter_application_3/models/masterbarang.dart';
import 'package:flutter_application_3/models/organisasi.dart';
import 'package:flutter_application_3/models/parameteraplikasi.dart';
import 'package:flutter_application_3/models/purch_karyawan.dart';
import 'package:flutter_application_3/models/saldobulanan.dart';
import 'package:flutter_application_3/models/sdmabsensi.dart';
import 'package:flutter_application_3/models/setupapproval.dart';
import 'package:flutter_application_3/models/setuphama.dart';
import 'package:flutter_application_3/models/setupmutu.dart';
import 'package:flutter_application_3/models/setuptph.dart';
import 'package:flutter_application_3/models/templatefingerprint.dart';
import 'package:flutter_application_3/models/tiketdocket.dart';
import 'package:flutter_application_3/models/tphbesar.dart';
import 'package:flutter_application_3/models/user.dart';
import 'package:flutter_application_3/services/constant.dart';
import 'package:flutter_application_3/services/helper.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:sqflite_live/sqflite_live.dart';

class DBHelper {
  Database? _database;
  var ip = ApiConstants.ip;
  Future<Database?> get database async {
    if (_database != null) return _database;

    _database = await initDatabase();
    return _database;
  }

  Future<Database> initDatabase() async {
    String databasesPath = await getDatabasesPath();
    String path = join(databasesPath, 'alammobile.db');

    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    await _createUserTable(db);
    await _createMenuMobileTable(db);
    await _createSetupNotifikasiTable(db);
    await _createLogMobileTable(db);
  }

  Future<void> insertMenuMobileBatch(List<dynamic> items) async {
    if (items.isEmpty) return;
    final db = await database;
    final batch = db!.batch();

    for (final it in items) {
      Map<String, dynamic> map;
      if (it is Map<String, dynamic>) {
        map = it;
      } else if (it is Map) {
        map = Map<String, dynamic>.from(it);
      } else {
        // fallback: simpan sebagai caption
        map = {'id': null, 'caption': it.toString()};
      }

      // Pastikan semua kolom ada; ubah nama kolom sesuai struktur servermu
      final row = <String, dynamic>{
        'id': map['id']?.toString(), // kolom TEXT
        'type': map['type']?.toString() ?? '',
        'caption': map['caption']?.toString() ?? '',
        'caption2': map['caption2']?.toString() ?? '',
        'caption3': map['caption3']?.toString() ?? '',
        'action': map['action']?.toString() ?? '',
        'formjs': map['formjs']?.toString() ?? '',
        'formjsloc': map['formjsloc']?.toString() ?? '',
        'parent': map['parent']?.toString() ?? '',
        'urut': map['urut']?.toString() ?? '',
        'hide': map['hide']?.toString() ?? '',
      };

      // replace existing row with same id (ConflictAlgorithm.replace)
      batch.insert('menumobile', row,
          conflictAlgorithm: ConflictAlgorithm.replace);
    }

    await batch.commit(noResult: true);
  }

  /// Ambil semua menu dari DB, parsing payload JSON kembali
  Future<List<Map<String, dynamic>>> getMenuMobileItems() async {
    final db = await database;
    final rows = await db!.query('menumobile', orderBy: 'urut ASC, id ASC');
    return rows.map((r) {
      return {
        'id': r['id'],
        'type': r['type'],
        'caption': r['caption'],
        'caption2': r['caption2'],
        'caption3': r['caption3'],
        'action': r['action'],
        'formjs': r['formjs'],
        'formjsloc': r['formjsloc'],
        'parent': r['parent'],
        'urut': r['urut'],
        'hide': r['hide'],
      };
    }).toList();
  }

  /// Hapus semua menu (dipakai saat logout jika ingin membersihkan)
  Future<void> clearMenuMobile() async {
    final db = await database;
    await db!.delete('menumobile');
  }

  Future<void> _createUserTable(Database db) async {
    // await db.execute('''DROP TABLE IF EXISTS loginonfo''');

    await db.execute('''
    CREATE TABLE IF NOT EXISTS loginonfo (
      server TEXT, 
      username TEXT, 
      password TEXT, 
      karyawanid TEXT,
      jabatan TEXT, 
      nama TEXT, 
      lokasitugas TEXT, 
      subbagian TEXT, 
      userid TEXT, 
      api_key TEXT, 
      datelogin TEXT, 
      explogin TEXT, 
      lang TEXT, 
      loggeddate TEXT
    )
  ''');
  }

  Future<void> _createMenuMobileTable(Database db) async {
    // await db.execute('''DROP TABLE IF EXISTS menumobile''');

    await db.execute('''
    CREATE TABLE IF NOT EXISTS menumobile (
      id TEXT,
      type TEXT,
      caption TEXT,
      caption2 TEXT,
      caption3 TEXT,
      action TEXT,
      formjs TEXT,
      formjsloc TEXT,
      parent TEXT,
      urut TEXT,
      hide TEXT
    )
    ''');
  }

  Future<void> _createSetupNotifikasiTable(Database db) async {
    // await db.execute('''DROP TABLE IF EXISTS setup_notifikasi''');

    await db.execute('''
    CREATE TABLE IF NOT EXISTS setup_notifikasi (last_penarikan TEXT, aktifasi_notif TEXT, run_time TEXT)
    ''');
  }

  Future<void> _createLogMobileTable(Database db) async {
    // await db.execute('''DROP TABLE IF EXISTS log_mobile''');

    await db.execute('''
    CREATE TABLE IF NOT EXISTS log_mobile (username TEXT, data_log BLOB, syn text, update_time TEXT)
    ''');
  }

  Future<void> _createMenuMobile(Database db) async {
    await db.execute('''
          CREATE TABLE IF NOT EXISTS menu_mobile (
            id INTEGER PRIMARY KEY,
            name TEXT,
            payload TEXT
          )
        ''');
  }

  Future<void> createKaryawanTableIfNotExists() async {
    Database? db = await database;

    await db?.execute('''DROP TABLE IF EXISTS datakaryawan''');

    var result = await db?.rawQuery('''
      SELECT name FROM sqlite_master WHERE type='table' AND name='datakaryawan';
    ''');

    // if (result?.isEmpty ?? true) {
    await db?.execute('''
        CREATE TABLE IF NOT EXISTS datakaryawan (
          karyawanid TEXT,
          nik TEXT,
          lokasitugas TEXT,
          subbagian TEXT,
          namakaryawan TEXT,
          namakaryawan2 TEXT,
          tipekaryawan INTEGER,
          namajabatan TEXT,
          kodejabatan TEXT,
          pemanen TEXT,
          perawatan TEXT,
          kemandoran TEXT,
          gajipokok INT
        );
      ''');

    await db?.execute(''' DELETE FROM datakaryawan; ''');
    // }
  }

  Future<void> createOrganisasiTableIfNotExists() async {
    Database? db = await database;

    await db?.execute('''DROP TABLE IF EXISTS organisasi''');

    var result = await db?.rawQuery('''
      SELECT name FROM sqlite_master WHERE type='table' AND name='organisasi';
    ''');

    if (result?.isEmpty ?? true) {
      await db?.execute('''
        CREATE TABLE IF NOT EXISTS organisasi (kodeorganisasi TEXT, induk TEXT,namaorganisasi TEXT, tipeorganisasi TEXT, sertifikat TEXT, inisialisasiorganisasi TEXT);
      ''');
    }
  }

  Future<void> insertUser(
      UserModel user, String username, String password) async {
    Database? db = await database;
    Map<String, String> configIp = getConfigPath(ip);
    String server = configIp['http']! + ip + configIp['path']!;

    await db?.insert(
      'loginonfo',
      {
        'server': server,
        'username': user.username,
        'password': user.password,
        'karyawanid': user.karyawanid,
        'jabatan': user.kodejabatan,
        'nama': user.namakaryawan,
        'lokasitugas': user.lokasitugas,
        'subbagian': user.subbagian,
        'userid': user.userid,
        'api_key': user.keyApi,
        'datelogin': user.datelogin,
        'explogin': user.explogin,
        'lang': user.lang,
        'loggeddate': getTanggalx()
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> createSetupBlokTableIfNotExists() async {
    Database? db = await database;

    await db?.execute('''DROP TABLE IF EXISTS setup_blok''');

    var result = await db?.rawQuery('''
      SELECT name FROM sqlite_master WHERE type='table' AND name='setup_blok';
    ''');

    if (result?.isEmpty ?? true) {
      await db?.execute('''
        CREATE TABLE IF NOT EXISTS setup_blok (kodeblok TEXT, tahuntanam INTEGER, statusblok TEXT,groupkegiatan TEXT,luasareaproduktif REAL,kelaspohon TEXT,jumlahpokok REAL,topografi TEXT,kemandoran TEXT,latitude TEXT,longitude TEXT);
      ''');
    }
  }

  Future<void> createMasterBarangTableIfNotExists() async {
    Database? db = await database;

    await db?.execute('''DROP TABLE IF EXISTS log_5masterbarang''');

    var result = await db?.rawQuery('''
      SELECT name FROM sqlite_master WHERE type='table' AND name='log_5masterbarang';
    ''');

    if (result?.isEmpty ?? true) {
      await db?.execute('''
        CREATE TABLE IF NOT EXISTS log_5masterbarang (kodebarang TEXT, namabarang TEXT, satuan TEXT);
      ''');
    }
  }

  Future<void> insertKaryawanBatch(List<Karyawan> karyawanList) async {
    await createKaryawanTableIfNotExists();
    Database? db = await database;

    List<Map<String, Object?>> rowBatch = karyawanList.map((karyawan) {
      return {
        'karyawanid': karyawan.karyawanid,
        'nik': karyawan.nik,
        'lokasitugas': karyawan.lokasitugas,
        'subbagian': karyawan.subbagian,
        'namakaryawan': karyawan.namakaryawan,
        'namakaryawan2': karyawan.namakaryawan2,
        'tipekaryawan': karyawan.tipekaryawan,
        'namajabatan': karyawan.namajabatan,
        'kodejabatan': karyawan.kodejabatan,
        'pemanen': karyawan.pemanen,
        'perawatan': karyawan.perawatan,
        'kemandoran': karyawan.kemandoran,
        'gajipokok': karyawan.gajipokok,
      };
    }).toList();

    int insertedRowsCount = 0;

    await db?.transaction((txn) async {
      for (var row in rowBatch) {
        await txn.insert(
          'datakaryawan',
          row,
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
        insertedRowsCount++;
      }
    });
    var result = await db?.rawQuery('SELECT * FROM datakaryawan');
    print("Total rows in datakaryawan: ${result?.length}");
    print('Total rows inserted: $insertedRowsCount');
  }

  Future<void> createPremiBKMTableIfNotExists() async {
    Database? db = await database;

    await db?.execute('''DROP TABLE IF EXISTS kebun_5premibkm''');

    var result = await db?.rawQuery('''
      SELECT name FROM sqlite_master WHERE type='table' AND name='kebun_5premibkm';
    ''');

    if (result?.isEmpty ?? true) {
      await db?.execute('''
       CREATE TABLE IF NOT EXISTS kebun_5premibkm(kodekegiatan TEXT, tahuntanam INT, basis REAL,premibasis REAL,premilebihbasis REAL,extrafooding TEXT);
      ''');
    }
  }

  Future<void> insertPremiBKMBatch(List<Kebun5Premibkm2> premiList) async {
    await createPremiBKMTableIfNotExists();
    Database? db = await database;

    List<Map<String, Object?>> rowBatch = premiList.map((premi) {
      return {
        'kodekegiatan': premi.kodekegiatan,
        'tahuntanam': premi.tahuntanam,
        'basis': premi.basis,
        'premibasis': premi.premibasis,
        'premilebihbasis': premi.premilebihbasis,
        'extrafooding': premi.extrafooding,
      };
    }).toList();

    int insertedRowsCount = 0;

    await db?.transaction((txn) async {
      for (var row in rowBatch) {
        await txn.insert(
          'kebun_5premibkm',
          row,
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
        insertedRowsCount++;
      }
    });
    var result = await db?.rawQuery('SELECT * FROM kebun_5premibkm');
    print("Total rows in kebun_5premibkm: ${result?.length}");
    print('Total rows inserted: $insertedRowsCount');
  }

  Future<void> insertOrganisasiBatch(List<Organisasi> organisasiList) async {
    await createOrganisasiTableIfNotExists();
    Database? db = await database;

    List<Map<String, Object?>> rowBatch = organisasiList.map((organisasi) {
      return {
        'kodeOrganisasi': organisasi.kodeOrganisasi,
        'induk': organisasi.induk,
        'namaOrganisasi': organisasi.namaOrganisasi,
        'tipeOrganisasi': organisasi.tipeOrganisasi,
        'sertifikat': organisasi.sertifikat,
        'inisialisasiOrganisasi': organisasi.inisialisasiOrganisasi,
      };
    }).toList();

    await db?.transaction((txn) async {
      for (var row in rowBatch) {
        await txn.insert(
          'organisasi',
          row,
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });
  }

  Future<void> insertSetupBlokBatch(List<Blok> blokList) async {
    await createSetupBlokTableIfNotExists();
    Database? db = await database;

    List<Map<String, Object?>> rowBatch = blokList.map((blok) {
      return {
        'kodeblok': blok.kodeorg,
        'tahuntanam': blok.tahuntanam,
        'statusblok': blok.statusblok,
        'groupkegiatan': blok.kegiatangroup,
        'luasareaproduktif': blok.luasareaproduktif,
        'kelaspohon': blok.kelaspohon,
        'jumlahpokok': blok.jumlahpokok,
        'topografi': blok.topografi,
        'kemandoran': blok.kemandoran,
        'latitude': blok.latitude,
        'longitude': blok.longitude,
      };
    }).toList();

    await db?.transaction((txn) async {
      for (var row in rowBatch) {
        await txn.insert(
          'setup_blok',
          row,
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });
  }

  Future<void> insertMasterBarangBatch(List<Masterbarang> barangList) async {
    await createMasterBarangTableIfNotExists();
    Database? db = await database;

    List<Map<String, Object?>> rowBatch = barangList.map((barang) {
      return {
        'kodebarang': barang.kodeBarang,
        'namabarang': barang.namaBarang,
        'satuan': barang.satuan,
      };
    }).toList();

    await db?.transaction((txn) async {
      for (var row in rowBatch) {
        await txn.insert(
          'log_5masterbarang',
          row,
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });
  }

  Future<void> createKendaraanTableIfNotExists() async {
    Database? db = await database;

    await db?.execute('''DROP TABLE IF EXISTS vhc_5master''');

    var result = await db?.rawQuery('''
      SELECT name FROM sqlite_master WHERE type='table' AND name='vhc_5master';
    ''');

    if (result?.isEmpty ?? true) {
      await db?.execute('''
        CREATE TABLE IF NOT EXISTS vhc_5master (kodevhc TEXT,nopol TEXT, detailvhc TEXT);
      ''');
    }
  }

  Future<void> insertKendaraanBatch(List<Kendaraan> kendaraanList) async {
    await createKendaraanTableIfNotExists();
    Database? db = await database;

    List<Map<String, Object?>> rowBatch = kendaraanList.map((kendaraan) {
      return {
        'kodevhc': kendaraan.kodeVhc,
        'nopol': kendaraan.nopol,
        'detailvhc': kendaraan.detailvhc,
      };
    }).toList();

    await db?.transaction((txn) async {
      for (var row in rowBatch) {
        await txn.insert(
          'vhc_5master',
          row,
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });
  }

  Future<void> createKegiatanTableIfNotExists() async {
    Database? db = await database;

    await db?.execute('''DROP TABLE IF EXISTS setup_kegiatan''');

    var result = await db?.rawQuery('''
      SELECT name FROM sqlite_master WHERE type='table' AND name='setup_kegiatan';
    ''');

    if (result?.isEmpty ?? true) {
      await db?.execute('''
        CREATE TABLE IF NOT EXISTS setup_kegiatan (kodekegiatan TEXT,namakegiatan TEXT,satuan TEXT,kelompok TEXT,noakun TEXT,premi TEXT,kodeklasifikasi TEXT);
      ''');
    }
  }

  Future<void> insertKegiatanBatch(List<Kegiatan> kegiatanList) async {
    await createKegiatanTableIfNotExists();
    Database? db = await database;

    List<Map<String, Object?>> rowBatch = kegiatanList.map((kegiatan) {
      return {
        'kodekegiatan': kegiatan.kodekegiatan,
        'namakegiatan': kegiatan.namakegiatan,
        'satuan': kegiatan.satuan,
        'kelompok': kegiatan.kelompok,
        'noakun': kegiatan.noakun,
        'premi': kegiatan.premi,
      };
    }).toList();

    await db?.transaction((txn) async {
      for (var row in rowBatch) {
        await txn.insert(
          'setup_kegiatan',
          row,
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });
  }

  Future<void> createCustomerTableIfNotExists() async {
    Database? db = await database;

    await db?.execute('''DROP TABLE IF EXISTS pmn_4customer''');

    var result = await db?.rawQuery('''
      SELECT name FROM sqlite_master WHERE type='table' AND name='pmn_4customer';
    ''');

    if (result?.isEmpty ?? true) {
      await db?.execute('''
        CREATE TABLE IF NOT EXISTS pmn_4customer (kodecustomer TEXT,namacustomer TEXT);
      ''');
    }
  }

  Future<void> insertCustomerBatch(List<Customer> customerList) async {
    await createCustomerTableIfNotExists();
    Database? db = await database;

    List<Map<String, Object?>> rowBatch = customerList.map((customer) {
      return {
        'kodecustomer': customer.kodecustomer,
        'namacustomer': customer.namacustomer,
      };
    }).toList();

    await db?.transaction((txn) async {
      for (var row in rowBatch) {
        await txn.insert(
          'pmn_4customer',
          row,
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });
  }

  Future<void> createKodeDendaPanenTableIfNotExists() async {
    Database? db = await database;

    await db?.execute('''DROP TABLE IF EXISTS kebun_kodedenda''');

    var result = await db?.rawQuery('''
      SELECT name FROM sqlite_master WHERE type='table' AND name='kebun_kodedenda';
    ''');

    if (result?.isEmpty ?? true) {
      await db?.execute('''
       CREATE TABLE IF NOT EXISTS kebun_kodedenda (iddenda TEXT,kodedenda TEXT,deskripsi TEXT,satuan TEXT,lockjjg TEXT,nourut TEXT);
      ''');
    }
  }

  Future<void> insertKodeDendaPanenBatch(
      List<KodeDendaPanen> kodedendapanenList) async {
    await createKodeDendaPanenTableIfNotExists();
    Database? db = await database;

    List<Map<String, Object?>> rowBatch =
        kodedendapanenList.map((kodedendapanen) {
      return {
        'iddenda': kodedendapanen.iddenda,
        'kodedenda': kodedendapanen.kodedenda,
        'deskripsi': kodedendapanen.deskripsi,
        'satuan': kodedendapanen.satuan,
        'lockjjg': kodedendapanen.lockjjg,
        'nourut': kodedendapanen.nourut,
      };
    }).toList();

    await db?.transaction((txn) async {
      for (var row in rowBatch) {
        await txn.insert(
          'kebun_kodedenda',
          row,
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });
  }

  Future<void> createdendaPanenTableIfNotExists() async {
    Database? db = await database;

    await db?.execute('''DROP TABLE IF EXISTS kebun_denda''');

    var result = await db?.rawQuery('''
      SELECT name FROM sqlite_master WHERE type='table' AND name='kebun_denda';
    ''');

    if (result?.isEmpty ?? true) {
      await db?.execute('''
       CREATE TABLE IF NOT EXISTS kebun_denda (kodeorg TEXT,kodedenda TEXT,jenisdenda TEXT,denda TEXT);
      ''');
    }
  }

  Future<void> insertDendaPanenBatch(List<DendaPanen> dendapanenList) async {
    await createdendaPanenTableIfNotExists();
    Database? db = await database;

    List<Map<String, Object?>> rowBatch = dendapanenList.map((dendapanen) {
      return {
        'kodeorg': dendapanen.kodeorg,
        'kodedenda': dendapanen.kodedenda,
        'jenisdenda': dendapanen.jenisdenda,
        'denda': dendapanen.denda,
      };
    }).toList();

    await db?.transaction((txn) async {
      for (var row in rowBatch) {
        await txn.insert(
          'kebun_denda',
          row,
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });
  }

  Future<void> creategpsTableIfNotExists() async {
    Database? db = await database;

    await db?.execute('''DROP TABLE IF EXISTS gps_interval''');

    var result = await db?.rawQuery('''
      SELECT name FROM sqlite_master WHERE type='table' AND name='gps_interval';
    ''');

    if (result?.isEmpty ?? true) {
      await db?.execute('''
       CREATE TABLE IF NOT EXISTS gps_interval (interval TEXT,enableupload TEXT);
      ''');
    }
  }

  Future<void> insertgpsBatch(List<Gpsinterval> gpsList) async {
    await creategpsTableIfNotExists();
    Database? db = await database;

    List<Map<String, Object?>> rowBatch = gpsList.map((gps) {
      return {
        'interval': gps.interval,
        'enableupload': gps.enableupload,
      };
    }).toList();

    await db?.transaction((txn) async {
      for (var row in rowBatch) {
        await txn.insert(
          'gps_interval',
          row,
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });
  }

  Future<void> createbjrTableIfNotExists() async {
    Database? db = await database;

    await db?.execute('''DROP TABLE IF EXISTS kebun_bjr''');

    var result = await db?.rawQuery('''
      SELECT name FROM sqlite_master WHERE type='table' AND name='kebun_bjr';
    ''');

    if (result?.isEmpty ?? true) {
      await db?.execute('''
       CREATE TABLE IF NOT EXISTS kebun_bjr (kodeorg TEXT,kelaspohon TEXT,bjr TEXT,tahunproduksi TEXT);
      ''');
    }
  }

  Future<void> insertbjrBatch(List<Bjr> bjrList) async {
    await createbjrTableIfNotExists();
    Database? db = await database;

    List<Map<String, Object?>> rowBatch = bjrList.map((bjr) {
      return {
        'kodeorg': bjr.kodeorg,
        'kelaspohon': bjr.kelaspohon,
        'bjr': bjr.bjr,
        'tahunproduksi': bjr.tahunproduksi,
      };
    }).toList();

    await db?.transaction((txn) async {
      for (var row in rowBatch) {
        await txn.insert(
          'kebun_bjr',
          row,
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });
  }

  Future<void> createsetupapprovalTableIfNotExists() async {
    Database? db = await database;

    await db?.execute('''DROP TABLE IF EXISTS setup_approval''');

    var result = await db?.rawQuery('''
      SELECT name FROM sqlite_master WHERE type='table' AND name='setup_approval';
    ''');

    if (result?.isEmpty ?? true) {
      await db?.execute('''
       CREATE TABLE IF NOT EXISTS setup_approval (kodeunit TEXT,kode_approval TEXT,level TEXT,applikasi TEXT,karyawanid TEXT,namakaryawan TEXT,nik TEXT);
      ''');
    }
  }

  Future<void> insertsetupapprovalBatch(
      List<SetupApproval> setupapprovalList) async {
    await createsetupapprovalTableIfNotExists();
    Database? db = await database;

    List<Map<String, Object?>> rowBatch = setupapprovalList.map((setupaproval) {
      return {
        'kodeunit': setupaproval.kodeunit,
        'kode_approval': setupaproval.kodeapproval,
        'level': setupaproval.level,
        'applikasi': setupaproval.applikasi,
        'karyawanid': setupaproval.karyawanid,
        'namakaryawan': setupaproval.namakaryawan,
        'nik': setupaproval.nik,
      };
    }).toList();

    await db?.transaction((txn) async {
      for (var row in rowBatch) {
        await txn.insert(
          'setup_approval',
          row,
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });
  }

  Future<void> createpurkaryawanTableIfNotExists() async {
    Database? db = await database;

    await db?.execute('''DROP TABLE IF EXISTS pur_karyawan''');

    var result = await db?.rawQuery('''
      SELECT name FROM sqlite_master WHERE type='table' AND name='pur_karyawan';
    ''');

    if (result?.isEmpty ?? true) {
      await db?.execute('''
       CREATE TABLE IF NOT EXISTS pur_karyawan (karyawanid TEXT,namakaryawan TEXT,bagian TEXT,nik TEXT,tipekaryawan TEXT);
      ''');

      await db?.execute(''' DELETE FROM pur_karyawan; ''');
    }
  }

  Future<void> insertpurkaryawanBatch(List<PurKaryawan> purkaryawanList) async {
    await createpurkaryawanTableIfNotExists();
    Database? db = await database;

    List<Map<String, Object?>> rowBatch = purkaryawanList.map((purkaryawan) {
      return {
        'karyawanid': purkaryawan.karyawanid,
        'namakaryawan': purkaryawan.namakaryawan,
        'bagian': purkaryawan.bagian,
        'nik': purkaryawan.nik,
        'tipekaryawan': purkaryawan.tipekaryawan,
      };
    }).toList();

    await db?.transaction((txn) async {
      for (var row in rowBatch) {
        await txn.insert(
          'pur_karyawan',
          row,
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });
  }

  Future<void> createijinTableIfNotExists() async {
    Database? db = await database;

    await db?.execute('''DROP TABLE IF EXISTS sdm_ijin''');

    var result = await db?.rawQuery('''
      SELECT name FROM sqlite_master WHERE type='table' AND name='sdm_ijin';
    ''');

    if (result?.isEmpty ?? true) {
      await db?.execute('''
      CREATE TABLE IF NOT EXISTS sdm_ijin (karyawanid TEXT,namakaryawan TEXT,tanggal TEXT,keperluan TEXT,keterangan TEXT,persetujuan1 TEXT,namapersetujuan1 TEXT,stpersetujuan1 TEXT,komenst1 TEXT,waktupengajuan TEXT,jenisijin TEXT,hrd TEXT,namahrd TEXT,stpersetujuanhrd TEXT,periodecuti TEXT,darijam TEXT,sampaijam TEXT,jumlahhari TEXT,komenst2 TEXT);
      ''');

      await db?.execute(''' DELETE FROM sdm_ijin; ''');
    }
  }

  Future<void> insertijinBatch(List<Ijin> ijinList) async {
    await createijinTableIfNotExists();
    Database? db = await database;

    List<Map<String, Object?>> rowBatch = ijinList.map((ijin) {
      return {
        'karyawanid': ijin.karyawanid,
        'tanggal': ijin.tanggal,
        'keperluan': ijin.keperluan,
        'keterangan': ijin.keterangan,
        'persetujuan1': ijin.persetujuan1,
        'stpersetujuan1': ijin.stpersetujuan1,
        'komenst1': ijin.komenst1,
        'waktupengajuan': ijin.waktupengajuan,
        'jenisijin': ijin.jenisijin,
        'hrd': ijin.hrd,
        'stpersetujuanhrd': ijin.stpersetujuanhrd,
        'periodecuti': ijin.periodecuti,
        'darijam': ijin.darijam,
        'sampaijam': ijin.sampaijam,
        'jumlahhari': ijin.jumlahhari,
        'komenst2': ijin.komenst2,
      };
    }).toList();

    await db?.transaction((txn) async {
      for (var row in rowBatch) {
        await txn.insert(
          'sdm_ijin',
          row,
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });
  }

  Future<void> creategudangtransaksiTableIfNotExists() async {
    Database? db = await database;

    await db?.execute('''DROP TABLE IF EXISTS gudangtransaksi''');

    var result = await db?.rawQuery('''
      SELECT name FROM sqlite_master WHERE type='table' AND name='gudangtransaksi';
    ''');

    if (result?.isEmpty ?? true) {
      await db?.execute('''
      CREATE TABLE IF NOT EXISTS gudangtransaksi(afdeling TEXT,kodegudang TEXT, status TEXT);
      ''');

      await db?.execute(''' DELETE FROM gudangtransaksi; ''');
    }
  }

  Future<void> insertgudangtransaksiBatch(
      List<GudangTransaksi> gudangtransaksiList) async {
    await creategudangtransaksiTableIfNotExists();
    Database? db = await database;
    // print('sebelum gudang transaksi');
    List<Map<String, Object?>> rowBatch =
        gudangtransaksiList.map((gudangtransaksi) {
      return {
        'afdeling': gudangtransaksi.afdeling,
        'kodegudang': gudangtransaksi.kodegudang,
        'status': gudangtransaksi.status,
      };
    }).toList();

    await db?.transaction((txn) async {
      for (var row in rowBatch) {
        await txn.insert(
          'gudangtransaksi',
          row,
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });
  }

  Future<void> createkegiatannormaTableIfNotExists() async {
    Database? db = await database;

    await db?.execute('''DROP TABLE IF EXISTS setup_kegiatannorma''');

    var result = await db?.rawQuery('''
      SELECT name FROM sqlite_master WHERE type='table' AND name='setup_kegiatannorma';
    ''');

    if (result?.isEmpty ?? true) {
      await db?.execute('''
      CREATE TABLE IF NOT EXISTS setup_kegiatannorma(kodekegiatan TEXT,kelompok TEXT,tipeanggaran TEXT, kodebarang TEXT);
      ''');

      await db?.execute(''' DELETE FROM setup_kegiatannorma; ''');
    }
  }

  Future<void> insertkegiatannormaBatch(
      List<KegiatanNorma> kegiatannormaList) async {
    await createkegiatannormaTableIfNotExists();
    Database? db = await database;

    List<Map<String, Object?>> rowBatch =
        kegiatannormaList.map((kegiatannorma) {
      return {
        'kodekegiatan': kegiatannorma.kodekegiatan,
        'kelompok': kegiatannorma.kelompok,
        'tipeanggaran': kegiatannorma.tipeanggaran,
        'kodebarang': kegiatannorma.kodebarang,
      };
    }).toList();

    await db?.transaction((txn) async {
      for (var row in rowBatch) {
        await txn.insert(
          'setup_kegiatannorma',
          row,
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });
  }

  Future<void> createklasifikasiTableIfNotExists() async {
    Database? db = await database;

    await db?.execute('''DROP TABLE IF EXISTS klasifikasi''');

    var result = await db?.rawQuery('''
      SELECT name FROM sqlite_master WHERE type='table' AND name='klasifikasi';
    ''');

    if (result?.isEmpty ?? true) {
      await db?.execute('''
      CREATE TABLE IF NOT EXISTS klasifikasi(kodeklasifikasi TEXT,namaklasifikasi TEXT,tipeklasifikasi TEXT);
      ''');

      await db?.execute(''' DELETE FROM klasifikasi; ''');
    }
  }

  Future<void> insertklasifikasiBatch(List<Klasifikasi> klasifikasiList) async {
    await createklasifikasiTableIfNotExists();
    Database? db = await database;

    List<Map<String, Object?>> rowBatch = klasifikasiList.map((klasifikasi) {
      return {
        'kodeklasifikasi': klasifikasi.kodeklasifikasi,
        'namaklasifikasi': klasifikasi.namaklasifikasi,
        'tipeklasifikasi': klasifikasi.tipeklasifikasi,
      };
    }).toList();

    await db?.transaction((txn) async {
      for (var row in rowBatch) {
        await txn.insert(
          'klasifikasi',
          row,
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });
  }

  // Future<void> createkemandoranTableIfNotExists() async {
  //   Database? db = await database;

  //   await db?.execute('''DROP TABLE IF EXISTS kemandoran''');

  //   var result = await db?.rawQuery('''
  //     SELECT name FROM sqlite_master WHERE type='table' AND name='kemandoran';
  //   ''');

  //   // print(result);

  //   if (result?.isEmpty ?? true) {
  //     // print('masuk kondisi?');
  //     await db?.execute('''
  //     CREATE TABLE IF NOT EXISTS kemandoran(mandorid TEXT,karyawanid TEXT);
  //     ''');

  //     // await db?.execute(''' DELETE FROM kemandoran; ''');
  //   }
  // }

  Future<void> createkemandoranTableIfNotExists() async {
    final db = await database;

    await db?.execute('''DROP TABLE IF EXISTS kemandoran''');

    var result = await db?.rawQuery('''
      SELECT name FROM sqlite_master WHERE type='table' AND name='kemandoran';
    ''');

    // if (result?.isEmpty ?? true) {
    await db?.execute('''
    CREATE TABLE IF NOT EXISTS kemandoran(
      mandorid   TEXT NOT NULL,
      karyawanid TEXT NOT NULL,
      PRIMARY KEY (mandorid, karyawanid)  -- penting untuk REPLACE
    );
  ''');

    await db?.execute(''' DELETE FROM kemandoran; ''');
    // }
  }

  Future<void> insertkemandoranBatch(List<Kemandoran> kemandoranList) async {
    await createkemandoranTableIfNotExists();
    Database? db = await database;

    List<Map<String, Object?>> rowBatch = kemandoranList.map((kemandoran) {
      // print('kemandiran lost');
      // print(kemandoran.mandorid);
      return {
        'mandorid': kemandoran.mandorid,
        'karyawanid': kemandoran.karyawanid,
      };
    }).toList();
    int insertedRowsCount = 0;
    await db?.transaction((txn) async {
      for (var row in rowBatch) {
        await txn.insert(
          'kemandoran',
          row,
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
        insertedRowsCount++;
      }
    });

    var result = await db?.rawQuery('SELECT * FROM kemandoran');
    print("Total rows in kemandoran: ${result?.length}");
    print(result);
  }

  Future<void> createkemandoranblokTableIfNotExists() async {
    Database? db = await database;

    await db?.execute('''DROP TABLE IF EXISTS kemandoran_blok''');

    var result = await db?.rawQuery('''
      SELECT name FROM sqlite_master WHERE type='table' AND name='kemandoran_blok';
    ''');

    if (result?.isEmpty ?? true) {
      await db?.execute('''
      CREATE TABLE IF NOT EXISTS kemandoran_blok(mandorid TEXT,blok TEXT);
      ''');

      await db?.execute(''' DELETE FROM kemandoran_blok; ''');
    }
  }

  Future<void> insertkemandoranblokBatch(
      List<KemandoranBlok> kemandoranblokList) async {
    await createkemandoranblokTableIfNotExists();
    Database? db = await database;

    List<Map<String, Object?>> rowBatch =
        kemandoranblokList.map((kemandoranblok) {
      return {
        'mandorid': kemandoranblok.mandorid,
        'blok': kemandoranblok.blok,
      };
    }).toList();

    await db?.transaction((txn) async {
      for (var row in rowBatch) {
        await txn.insert(
          'kemandoran_blok',
          row,
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });
  }

  Future<void> createkontrakkegiatanTableIfNotExists() async {
    Database? db = await database;

    await db?.execute('''DROP TABLE IF EXISTS log_spk''');

    var result = await db?.rawQuery('''
      SELECT name FROM sqlite_master WHERE type='table' AND name='log_spk';
    ''');

    if (result?.isEmpty ?? true) {
      await db?.execute('''
      CREATE TABLE IF NOT EXISTS log_spk(kodeorg TEXT
						notransaksi TEXT
						supplierid TEXT
						namasupplier TEXT
						kodekegiatan TEXT
						divisi TEXT
						kodeblok TEXT
						satuan TEXT
						dari TEXT
						sampai TEXT);
      ''');

      await db?.execute(''' DELETE FROM log_spk; ''');
    }
  }

  Future<void> insertkontrakkegiatanBatch(
      List<KontrakKegiatan> kontrakkegiatanList) async {
    await createkontrakkegiatanTableIfNotExists();
    Database? db = await database;

    List<Map<String, Object?>> rowBatch =
        kontrakkegiatanList.map((kontrakkegiatan) {
      return {
        'notransaksi': kontrakkegiatan.notransaksi,
        'supplierid': kontrakkegiatan.supplierid,
        'namasupplier': kontrakkegiatan.namasupplier,
        'kodekegiatan': kontrakkegiatan.kodekegiatan,
        'divisi': kontrakkegiatan.divisi,
        'kodeblok': kontrakkegiatan.kodeblok,
        'satuan': kontrakkegiatan.satuan,
        'dari': kontrakkegiatan.dari,
        'sampai': kontrakkegiatan.sampai,
      };
    }).toList();

    await db?.transaction((txn) async {
      for (var row in rowBatch) {
        await txn.insert(
          'log_spk',
          row,
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });
  }

  Future<void> createsetupmutuancakTableIfNotExists() async {
    Database? db = await database;
    await db?.execute('''DROP TABLE IF EXISTS setup_mutu_ancak''');

    var result = await db?.rawQuery('''
      SELECT name FROM sqlite_master WHERE type='table' AND name='setup_mutu_ancak';
    ''');

    if (result?.isEmpty ?? true) {
      await db?.execute('''
      CREATE TABLE IF NOT EXISTS setup_mutu_ancak(idjenis TEXT,kodemutu TEXT,jenis TEXT,namamutu TEXT,satuan TEXT,satuan2 TEXT);
      ''');

      await db?.execute(''' DELETE FROM setup_mutu_ancak; ''');
    }
  }

  Future<void> insertsetupmutuBatch(List<MutuAncak> mutuancakList) async {
    await createsetupmutuancakTableIfNotExists();
    Database? db = await database;

    List<Map<String, Object?>> rowBatch = mutuancakList.map((mutuancak) {
      return {
        'idjenis': mutuancak.idjenis,
        'kodemutu': mutuancak.kodemutu,
        'jenis': mutuancak.jenis,
        'namamutu': mutuancak.namamutu,
        'satuan': mutuancak.satuan,
        'satuan2': mutuancak.satuan2,
      };
    }).toList();

    await db?.transaction((txn) async {
      for (var row in rowBatch) {
        await txn.insert(
          'setup_mutu_ancak',
          row,
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });
  }

  Future<void> createsetuphamaTableIfNotExists() async {
    Database? db = await database;

    await db?.execute('''DROP TABLE IF EXISTS setup_hama''');

    var result = await db?.rawQuery('''
      SELECT name FROM sqlite_master WHERE type='table' AND name='setup_hama';
    ''');

    if (result?.isEmpty ?? true) {
      await db?.execute('''
      CREATE TABLE IF NOT EXISTS setup_hama(idhama TEXT,kodehama TEXT,namahama TEXT,satuan TEXT);
      ''');

      await db?.execute(''' DELETE FROM setup_hama; ''');
    }
  }

  Future<void> insertsetuphamaBatch(List<Setuphama> setuphamaList) async {
    await createsetuphamaTableIfNotExists();
    Database? db = await database;

    List<Map<String, Object?>> rowBatch = setuphamaList.map((setuphama) {
      return {
        'kodehama': setuphama.kodehama,
        'namahama': setuphama.namahama,
        'satuan': setuphama.satuan,
      };
    }).toList();

    await db?.transaction((txn) async {
      for (var row in rowBatch) {
        await txn.insert(
          'setup_hama',
          row,
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });
  }

  Future<void> createsetuptphTableIfNotExists() async {
    Database? db = await database;

    await db?.execute('''DROP TABLE IF EXISTS setup_tph''');

    var result = await db?.rawQuery('''
      SELECT name FROM sqlite_master WHERE type='table' AND name='setup_tph';
    ''');

    if (result?.isEmpty ?? true) {
      await db?.execute('''
      CREATE TABLE IF NOT EXISTS setup_tph(kode TEXT,keterangan TEXT,kodeorg TEXT,latitude TEXT,longitude TEXT,luas TEXT);
      ''');

      await db?.execute(''' DELETE FROM setup_tph; ''');
    }
  }

  Future<void> insertsetuptphBatch(List<Setuptph> setuptphList) async {
    await createsetuptphTableIfNotExists();
    Database? db = await database;

    List<Map<String, Object?>> rowBatch = setuptphList.map((setuptph) {
      return {
        'kode': setuptph.kode,
        'keterangan': setuptph.keterangan,
        'kodeorg': setuptph.kodeorg,
        'latitude': setuptph.latitude,
        'longitude': setuptph.longitude,
        'luas': setuptph.luas,
      };
    }).toList();

    await db?.transaction((txn) async {
      for (var row in rowBatch) {
        await txn.insert(
          'setup_tph',
          row,
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });
  }

  Future<void> createparameteraplikasiTableIfNotExists() async {
    Database? db = await database;

    await db?.execute('''DROP TABLE IF EXISTS setup_parameterappl''');

    var result = await db?.rawQuery('''
      SELECT name FROM sqlite_master WHERE type='table' AND name='setup_parameterappl';
    ''');

    if (result?.isEmpty ?? true) {
      await db?.execute('''
      CREATE TABLE IF NOT EXISTS setup_parameterappl (kodeaplikasi TEXT, kodeparameter TEXT , kodeorg TEXT, keterangan TEXT, nilai TEXT);
      ''');

      await db?.execute(''' DELETE FROM setup_parameterappl; ''');
    }
  }

  Future<void> insertparameteraplikasiBatch(
      List<ParameterAplikasi> parameteraplikasiList) async {
    await createparameteraplikasiTableIfNotExists();
    Database? db = await database;

    List<Map<String, Object?>> rowBatch =
        parameteraplikasiList.map((parameteraplikasi) {
      return {
        'kodeaplikasi': parameteraplikasi.kodeaplikasi,
        'kodeparameter': parameteraplikasi.kodeparameter,
        'kodeorg': parameteraplikasi.kodeorg,
        'keterangan': parameteraplikasi.keterangan,
        'nilai': parameteraplikasi.nilai,
      };
    }).toList();

    await db?.transaction((txn) async {
      for (var row in rowBatch) {
        await txn.insert(
          'setup_parameterappl',
          row,
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });
  }

  Future<void> createdatalastnospbTableIfNotExists() async {
    Database? db = await database;

    await db?.execute('''DROP TABLE IF EXISTS data_lastnospb''');

    var result = await db?.rawQuery('''
      SELECT name FROM sqlite_master WHERE type='table' AND name='data_lastnospb';
    ''');

    if (result?.isEmpty ?? true) {
      await db?.execute('''
      CREATE TABLE IF NOT EXISTS data_lastnospb(lastnospb TEXT,updateby TEXT);
      ''');

      await db?.execute(''' DELETE FROM data_lastnospb; ''');
    }
  }

  Future<void> insertdatalastnospbBatch(
      List<LastNospb> datalastnospbList) async {
    await createdatalastnospbTableIfNotExists();
    Database? db = await database;

    List<Map<String, Object?>> rowBatch =
        datalastnospbList.map((datalastnospb) {
      return {
        'lastnospb': datalastnospb.lastnospb,
        'updateby': 'suliana',
      };
    }).toList();

    await db?.transaction((txn) async {
      for (var row in rowBatch) {
        await txn.insert(
          'data_lastnospb',
          row,
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });
  }

  Future<void> createkomoditiTableIfNotExists() async {
    Database? db = await database;

    await db?.execute('''DROP TABLE IF EXISTS pmn_4komoditi''');

    var result = await db?.rawQuery('''
      SELECT name FROM sqlite_master WHERE type='table' AND name='pmn_4komoditi';
    ''');

    if (result?.isEmpty ?? true) {
      await db?.execute('''
      CREATE TABLE IF NOT EXISTS pmn_4komoditi(kodecustomer TEXT,kodebarang TEXT,kodekomoditi TEXT);
      ''');

      await db?.execute(''' DELETE FROM pmn_4komoditi; ''');
    }
  }

  Future<void> insertkomoditiBatch(List<Komoditi> komoditiList) async {
    await createkomoditiTableIfNotExists();
    Database? db = await database;

    List<Map<String, Object?>> rowBatch = komoditiList.map((komoditi) {
      return {
        'kodecustomer': komoditi.kodecustomer,
        'kodebarang': komoditi.kodebarang,
        'kodekomoditi': komoditi.kodekomoditi,
      };
    }).toList();

    await db?.transaction((txn) async {
      for (var row in rowBatch) {
        await txn.insert(
          'pmn_4komoditi',
          row,
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });
  }

  Future<void> createsdmabsensiIfNotExists() async {
    Database? db = await database;

    await db?.execute('''DROP TABLE IF EXISTS sdm_5absensi''');

    var result = await db?.rawQuery('''
      SELECT name FROM sqlite_master WHERE type='table' AND name='sdm_5absensi';
    ''');

    if (result?.isEmpty ?? true) {
      await db?.execute('''
      CREATE TABLE IF NOT EXISTS sdm_5absensi(kodeabsen TEXT,keterangan TEXT,kelompok INT,kelompokcatu INT,nilaihk TEXT,pengali TEXT);
      ''');

      await db?.execute(''' DELETE FROM sdm_5absensi; ''');
    }
  }

  Future<void> insertsdmabsensiBatch(List<SdmAbsensi> sdmabsensiList) async {
    await createsdmabsensiIfNotExists();
    Database? db = await database;

    List<Map<String, Object?>> rowBatch = sdmabsensiList.map((sdmabsensi) {
      return {
        'kodeabsen': sdmabsensi.kodeabsen,
        'keterangan': sdmabsensi.keterangan,
        'kelompok': sdmabsensi.kelompok,
        'nilaihk': sdmabsensi.nilaihk,
        'pengali': sdmabsensi.pengali,
      };
    }).toList();

    await db?.transaction((txn) async {
      for (var row in rowBatch) {
        await txn.insert(
          'sdm_5absensi',
          row,
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });
  }

  Future<void> createtemplatefingerprintIfNotExists() async {
    Database? db = await database;

    await db?.execute('''DROP TABLE IF EXISTS fingerprint_tmpt_server''');

    var result = await db?.rawQuery('''
      SELECT name FROM sqlite_master WHERE type='table' AND name='fingerprint_tmpt_server';
    ''');

    if (result?.isEmpty ?? true) {
      await db?.execute('''
      CREATE TABLE IF NOT EXISTS fingerprint_tmpt_server ( sn TEXT, sensor TEXT ,id_jari TEXT, karyawanid TEXT,kebun TEXT, template TEXT, updateby TEXT);
      ''');

      await db?.execute(''' DELETE FROM fingerprint_tmpt_server; ''');
    }
  }

  Future<void> inserttemplatefingerprintBatch(
      List<TemplateFingerprint> templatefingerprintList) async {
    await createtemplatefingerprintIfNotExists();
    Database? db = await database;

    List<Map<String, Object?>> rowBatch =
        templatefingerprintList.map((templatefingerprint) {
      return {
        'sn': templatefingerprint.sn,
        'sensor': templatefingerprint.sensor,
        'idjari': templatefingerprint.idjari,
        'kebun': templatefingerprint.kebun,
        'template': templatefingerprint.template,
        'updateby': templatefingerprint.updateby,
        'karyawanid': templatefingerprint.karyawanid,
      };
    }).toList();

    await db?.transaction((txn) async {
      for (var row in rowBatch) {
        await txn.insert(
          'fingerprint_tmpt_server',
          row,
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });
  }

  Future<void> createtiketdocketIfNotExists() async {
    Database? db = await database;

    await db?.execute('''DROP TABLE IF EXISTS setup_tiket_docket''');

    var result = await db?.rawQuery('''
      SELECT name FROM sqlite_master WHERE type='table' AND name='setup_tiket_docket';
    ''');

    if (result?.isEmpty ?? true) {
      await db?.execute('''
      CREATE TABLE IF NOT EXISTS setup_tiket_docket ( notransaksi TEXT, noreferensi TEXT ,kodeorg TEXT,tph TEXT, kebun TEXT,nik TEXT,sesi TEXT, updateby TEXT);
      ''');

      await db?.execute(''' DELETE FROM setup_tiket_docket; ''');
    }
  }

  Future<void> inserttiketdocketBatch(List<Tiketdocket> tiketdocketList) async {
    await createtiketdocketIfNotExists();
    Database? db = await database;

    List<Map<String, Object?>> rowBatch = tiketdocketList.map((tiketdocket) {
      return {
        'notransaksi': tiketdocket.notransaksi,
        'noreferensi': tiketdocket.noreferensi,
        'kodeorg': tiketdocket.kodeorg,
        'tph': tiketdocket.tph,
        'kebun': tiketdocket.kebun,
        'nik': tiketdocket.nik,
        'sesi': tiketdocket.sesi,
        'updateby': tiketdocket.updateby,
      };
    }).toList();

    await db?.transaction((txn) async {
      for (var row in rowBatch) {
        await txn.insert(
          'setup_tiket_docket',
          row,
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });
  }

  Future<void> createkeuakunIfNotExists() async {
    Database? db = await database;

    await db?.execute('''DROP TABLE IF EXISTS keu_5akun''');

    var result = await db?.rawQuery('''
      SELECT name FROM sqlite_master WHERE type='table' AND name='keu_5akun';
    ''');

    if (result?.isEmpty ?? true) {
      await db?.execute('''
      CREATE TABLE IF NOT EXISTS keu_5akun (noakun TEXT, namaakun TEXT);
      ''');

      await db?.execute(''' DELETE FROM keu_5akun; ''');
    }
  }

  Future<void> insertkeuakunnBatch(List<Keuakun> keuakunList) async {
    await createkeuakunIfNotExists();
    Database? db = await database;

    List<Map<String, Object?>> rowBatch = keuakunList.map((keuakun) {
      return {
        'noakun': keuakun.noakun,
        'namaakun': keuakun.namaakun,
      };
    }).toList();

    await db?.transaction((txn) async {
      for (var row in rowBatch) {
        await txn.insert(
          'keu_5akun',
          row,
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });
  }

  Future<void> createkebunperonIfNotExists() async {
    Database? db = await database;

    await db?.execute('''DROP TABLE IF EXISTS kebun_5peron''');

    var result = await db?.rawQuery('''
      SELECT name FROM sqlite_master WHERE type='table' AND name='kebun_5peron';
    ''');

    if (result?.isEmpty ?? true) {
      await db?.execute('''
      CREATE TABLE IF NOT EXISTS kebun_5peron (id TEXT, nama TEXT);
      ''');

      await db?.execute(''' DELETE FROM kebun_5peron; ''');
    }
  }

  Future<void> insertkebunperonBatch(List<KebunPeron> kebunperonList) async {
    await createkebunperonIfNotExists();
    Database? db = await database;

    List<Map<String, Object?>> rowBatch = kebunperonList.map((kebunperon) {
      return {
        'id': kebunperon.id,
        'nama': kebunperon.nama,
      };
    }).toList();

    await db?.transaction((txn) async {
      for (var row in rowBatch) {
        await txn.insert(
          'kebun_5peron',
          row,
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });
  }

  Future<void> createsaldobulananIfNotExists() async {
    Database? db = await database;

    await db?.execute('''DROP TABLE IF EXISTS log_5saldobulanan''');

    var result = await db?.rawQuery('''
      SELECT name FROM sqlite_master WHERE type='table' AND name='log_5saldobulanan';
    ''');

    if (result?.isEmpty ?? true) {
      await db?.execute('''
      CREATE TABLE IF NOT EXISTS log_5saldobulanan (kodeorg TEXT, kodebarang TEXT, saldoakhirqty TEXT, kodegudang TEXT);
      ''');

      await db?.execute(''' DELETE FROM log_5saldobulanan; ''');
    }
  }

  Future<void> insertsaldobulananBatch(
      List<Saldobulanan> saldobulananList) async {
    await createsaldobulananIfNotExists();
    Database? db = await database;

    List<Map<String, Object?>> rowBatch = saldobulananList.map((saldobulanan) {
      return {
        'kodeorg': saldobulanan.kodeorg,
        'kodebarang': saldobulanan.kodebarang,
        'saldoakhirqty': saldobulanan.saldoakhirqty,
        'kodegudang': saldobulanan.kodegudang,
      };
    }).toList();

    await db?.transaction((txn) async {
      for (var row in rowBatch) {
        await txn.insert(
          'log_5saldobulanan',
          row,
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });
  }

  Future<void> createkebunrkhhtIfNotExists() async {
    Database? db = await database;

    await db?.execute('''DROP TABLE IF EXISTS kebun_rkhht''');

    var result = await db?.rawQuery('''
      SELECT name FROM sqlite_master WHERE type='table' AND name='kebun_rkhht';
    ''');

    if (result?.isEmpty ?? true) {
      await db?.execute('''
      CREATE TABLE IF NOT EXISTS kebun_rkhht(notransaksi TEXT, asisten TEXT, tanggal TEXT, divisi TEXT);
      ''');

      await db?.execute(''' DELETE FROM kebun_rkhht; ''');
    }
  }

  Future<void> insertkebunrkhhtBatch(List<Kebunrkhht> kebunrkhhtList) async {
    await createkebunrkhhtIfNotExists();
    Database? db = await database;

    List<Map<String, Object?>> rowBatch = kebunrkhhtList.map((kebunrkhht) {
      return {
        'notransaksi': kebunrkhht.notransaksi,
        'asisten': kebunrkhht.asisten,
        'tanggal': kebunrkhht.tanggal,
        'divisi': kebunrkhht.divisi,
      };
    }).toList();

    await db?.transaction((txn) async {
      for (var row in rowBatch) {
        await txn.insert(
          'kebun_rkhht',
          row,
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });
  }

  Future<void> createkebunrkhdtIfNotExists() async {
    Database? db = await database;

    await db?.execute('''DROP TABLE IF EXISTS kebun_rkh_dt''');

    var result = await db?.rawQuery('''
      SELECT name FROM sqlite_master WHERE type='table' AND name='kebun_rkh_dt';
    ''');

    if (result?.isEmpty ?? true) {
      await db?.execute('''
     CREATE TABLE IF NOT EXISTS kebun_rkh_dt (notransaksi TEXT, nourut TEXT, mandor TEXT, kodeblok TEXT, statusblok TEXT, kodekegiatan TEXT, rotasi TEXT, target TEXT, hk_pb TEXT, hk_kht TEXT, hk_khl TEXT, hk_bor TEXT, jmlh_tbs TEXT, jmlh_kgtbs TEXT, angkutan TEXT, kontan TEXT, rpsatuan TEXT);
      ''');

      await db?.execute(''' DELETE FROM kebun_rkh_dt; ''');
    }
  }

  Future<void> insertkebunrkhdtBatch(List<Kebunrkhdt> kebunrkhdtList) async {
    await createkebunrkhdtIfNotExists();
    Database? db = await database;

    List<Map<String, Object?>> rowBatch = kebunrkhdtList.map((kebunrkhdt) {
      return {
        'notransaksi': kebunrkhdt.notransaksi,
        'nourut': kebunrkhdt.nourut,
        'mandor': kebunrkhdt.mandor,
        'kodeblok': kebunrkhdt.kodeblok,
        'statusblok': kebunrkhdt.statusblok,
        'kodekegiatan': kebunrkhdt.kodekegiatan,
        'rotasi': kebunrkhdt.rotasi,
        'target': kebunrkhdt.target,
        'hk_pb': kebunrkhdt.hkpb,
        'hk_kht': kebunrkhdt.hkkht,
        'hk_khl': kebunrkhdt.hkkhl,
        'hk_bor': kebunrkhdt.hkbor,
        'jmlh_tbs': kebunrkhdt.jmlhtbs,
        'jmlh_kgtbs': kebunrkhdt.jmlhkgtbs,
        'angkutan': kebunrkhdt.angkutan,
        'kontan': kebunrkhdt.kontan,
        'rpsatuan': kebunrkhdt.rpsatuan,
      };
    }).toList();

    await db?.transaction((txn) async {
      for (var row in rowBatch) {
        await txn.insert(
          'kebun_rkh_dt',
          row,
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });
  }

  Future<void> createkebunrkhdtmaterialIfNotExists() async {
    Database? db = await database;

    await db?.execute('''DROP TABLE IF EXISTS kebun_rkh_dtmaterial''');

    var result = await db?.rawQuery('''
      SELECT name FROM sqlite_master WHERE type='table' AND name='kebun_rkh_dtmaterial';
    ''');

    if (result?.isEmpty ?? true) {
      await db?.execute('''
     CREATE TABLE IF NOT EXISTS kebun_rkh_dtmaterial (notransaksi TEXT, nourut TEXT, kodebarang TEXT, jumlah TEXT, cu TEXT);
      ''');

      await db?.execute(''' DELETE FROM kebun_rkh_dtmaterial; ''');
    }
  }

  Future<void> insertkebunrkhdtmaterialBatch(
      List<Kebunrkhdtmaterial> kebunrkhdtmaterialList) async {
    await createkebunrkhdtmaterialIfNotExists();
    Database? db = await database;

    List<Map<String, Object?>> rowBatch =
        kebunrkhdtmaterialList.map((kebunrkhdtmaterial) {
      return {
        'notransaksi': kebunrkhdtmaterial.notransaksi,
        'nourut': kebunrkhdtmaterial.nourut,
        'kodebarang': kebunrkhdtmaterial.kodebarang,
        'jumlah': kebunrkhdtmaterial.jumlah,
        'cu': kebunrkhdtmaterial.cu,
      };
    }).toList();

    await db?.transaction((txn) async {
      for (var row in rowBatch) {
        await txn.insert(
          'kebun_rkh_dtmaterial',
          row,
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });
  }

  Future<void> createtphbesarIfNotExists() async {
    Database? db = await database;

    await db?.execute('''DROP TABLE IF EXISTS kebun_5tphbesar''');

    var result = await db?.rawQuery('''
      SELECT name FROM sqlite_master WHERE type='table' AND name='kebun_5tphbesar';
    ''');

    if (result?.isEmpty ?? true) {
      await db?.execute('''
    CREATE TABLE IF NOT EXISTS kebun_5tphbesar ( divisi TEXT ,notph TEXT, createdby TEXT);
      ''');

      await db?.execute(''' DELETE FROM kebun_5tphbesar; ''');
    }
  }

  Future<void> inserttphbesarBatch(List<Tphbesar> tphbesarList) async {
    await createtphbesarIfNotExists();
    Database? db = await database;

    List<Map<String, Object?>> rowBatch = tphbesarList.map((tphbesar) {
      return {
        'divisi': tphbesar.divisi,
        'notph': tphbesar.notph,
        'createdby': tphbesar.createdby,
      };
    }).toList();

    await db?.transaction((txn) async {
      for (var row in rowBatch) {
        await txn.insert(
          'kebun_5tphbesar',
          row,
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });
  }

  Future<List<Karyawan>> fetchKaryawans() async {
    Database? db = await database;

    var result = await db?.query(
      'datakaryawan',
      orderBy: 'namakaryawan ASC',
    );

    if (result == null || result.isEmpty) {
      print("No data found in database.");
      throw Exception('No data found in database');
    }

    List<Karyawan> karyawans = [];
    for (var e in result) {
      try {
        karyawans.add(Karyawan.fromJson(Map<String, dynamic>.from(e)));
      } catch (err) {
        print("Error mapping row: $e\nError: $err");
      }
    }

    return karyawans;
  }

  Future<List<Blok>> fetchBlok() async {
    Database? db = await database;

    var result = await db?.query(
      'setup_blok',
      orderBy: 'kodeblok ASC',
    );

    if (result == null || result.isEmpty) {
      print("No data found in database.");
      throw Exception('No data found in database');
    }

    List<Blok> bloks = [];
    for (var e in result) {
      try {
        bloks.add(Blok.fromJson(Map<String, dynamic>.from(e)));
      } catch (err) {
        print("Error mapping row: $e\nError: $err");
      }
    }

    return bloks;
  }

  Future<List<Masterbarang>> fetchBarang() async {
    Database? db = await database;

    var result = await db?.query(
      'log_5masterbarang',
    );

    if (result == null || result.isEmpty) {
      print("No data found in database.");
      throw Exception('No data found in database');
    }

    List<Masterbarang> barangs = [];
    for (var e in result) {
      try {
        barangs.add(Masterbarang.fromJson(Map<String, dynamic>.from(e)));
      } catch (err) {
        print("Error mapping row: $e\nError: $err");
      }
    }

    return barangs;
  }

  Future<List<Organisasi>> fetchOrganisasi() async {
    Database? db = await database;

    var result = await db?.query(
      'organisasi',
    );

    if (result == null || result.isEmpty) {
      print("No data found in database.");
      throw Exception('No data found in database');
    }

    List<Organisasi> organisasis = [];
    for (var e in result) {
      try {
        organisasis.add(Organisasi.fromJson(Map<String, dynamic>.from(e)));
      } catch (err) {
        print("Error mapping row: $e\nError: $err");
      }
    }

    return organisasis;
  }

  Future<List<Kegiatan>> fetchKegiatan() async {
    Database? db = await database;

    var result = await db?.query(
      'setup_kegiatan',
    );

    if (result == null || result.isEmpty) {
      print("No data found in database.");
      throw Exception('No data found in database');
    }

    List<Kegiatan> kegiatans = [];
    for (var e in result) {
      try {
        kegiatans.add(Kegiatan.fromJson(Map<String, dynamic>.from(e)));
      } catch (err) {
        print("Error mapping row: $e\nError: $err");
      }
    }

    return kegiatans;
  }

  Future<List<Kendaraan>> fetchKendaraan() async {
    Database? db = await database;

    var result = await db?.query(
      'vhc_5master',
    );

    if (result == null || result.isEmpty) {
      print("No data found in database.");
      throw Exception('No data found in database');
    }

    List<Kendaraan> kendaraans = [];
    for (var e in result) {
      try {
        kendaraans.add(Kendaraan.fromJson(Map<String, dynamic>.from(e)));
      } catch (err) {
        print("Error mapping row: $e\nError: $err");
      }
    }

    return kendaraans;
  }

  Future<List<Customer>> fetchCustommer() async {
    Database? db = await database;

    var result = await db?.query(
      'pmn_4customer',
    );

    if (result == null || result.isEmpty) {
      print("No data found in database.");
      throw Exception('No data found in database');
    }

    List<Customer> customers = [];
    for (var e in result) {
      try {
        customers.add(Customer.fromJson(Map<String, dynamic>.from(e)));
      } catch (err) {
        print("Error mapping row: $e\nError: $err");
      }
    }

    return customers;
  }

  Future<List<Bjr>> fetchBjr() async {
    Database? db = await database;

    var result = await db?.query(
      'kebun_bjr',
    );

    if (result == null || result.isEmpty) {
      print("No data found in database.");
      throw Exception('No data found in database');
    }

    List<Bjr> bjrs = [];
    for (var e in result) {
      try {
        bjrs.add(Bjr.fromJson(Map<String, dynamic>.from(e)));
      } catch (err) {
        print("Error mapping row: $e\nError: $err");
      }
    }

    return bjrs;
  }

  Future<List<KodeDendaPanen>> fetchKodedenda() async {
    Database? db = await database;

    var result = await db?.query(
      'kebun_kodedenda',
    );

    if (result == null || result.isEmpty) {
      print("No data found in database.");
      throw Exception('No data found in database');
    }

    List<KodeDendaPanen> kodedendas = [];
    for (var e in result) {
      try {
        kodedendas.add(KodeDendaPanen.fromJson(Map<String, dynamic>.from(e)));
      } catch (err) {
        print("Error mapping row: $e\nError: $err");
      }
    }

    return kodedendas;
  }

  Future<List<DendaPanen>> fetchDendapanen() async {
    Database? db = await database;

    var result = await db?.query(
      'kebun_denda',
    );

    if (result == null || result.isEmpty) {
      print("No data found in database.");
      throw Exception('No data found in database');
    }

    List<DendaPanen> dendapanens = [];
    for (var e in result) {
      try {
        dendapanens.add(DendaPanen.fromJson(Map<String, dynamic>.from(e)));
      } catch (err) {
        print("Error mapping row: $e\nError: $err");
      }
    }

    return dendapanens;
  }

  Future<List<MutuAncak>> fetchMutuancak() async {
    Database? db = await database;

    var result = await db?.query(
      'setup_mutu_ancak',
      where: 'idjenis NOT IN (21, 22)',
    );

    if (result == null || result.isEmpty) {
      print("No data found in database.");
      throw Exception('No data found in database');
    }

    List<MutuAncak> mutuancaks = [];
    for (var e in result) {
      try {
        mutuancaks.add(MutuAncak.fromJson(Map<String, dynamic>.from(e)));
      } catch (err) {
        print("Error mapping row: $e\nError: $err");
      }
    }

    return mutuancaks;
  }

  Future<List<Setuphama>> fetchHama() async {
    Database? db = await database;

    var result = await db?.query(
      'setup_hama',
    );

    if (result == null || result.isEmpty) {
      print("No data found in database.");
      throw Exception('No data found in database');
    }

    List<Setuphama> setuphamas = [];
    for (var e in result) {
      try {
        setuphamas.add(Setuphama.fromJson(Map<String, dynamic>.from(e)));
      } catch (err) {
        print("Error mapping row: $e\nError: $err");
      }
    }

    return setuphamas;
  }

  Future<List<Setuptph>> fetchTph() async {
    Database? db = await database;

    var result = await db?.query(
      'setup_tph',
    );

    if (result == null || result.isEmpty) {
      print("No data found in database.");
      throw Exception('No data found in database');
    }

    List<Setuptph> setuptphs = [];
    for (var e in result) {
      try {
        setuptphs.add(Setuptph.fromJson(Map<String, dynamic>.from(e)));
      } catch (err) {
        print("Error mapping row: $e\nError: $err");
      }
    }

    return setuptphs;
  }

  Future<List<Kemandoran>> fetchKemandoran() async {
    Database? db = await database;

    // var result = await db?.query(
    //   'setup_tph',
    // );

    var sql = '''
      SELECT *
      FROM kemandoran a 
      LEFT JOIN datakaryawan b ON a.mandorid = b.karyawanid 
      LEFT JOIN datakaryawan c ON a.karyawanid = c.karyawanid;
    ''';

    var result = await db?.rawQuery(sql);

    var resulttes = await db?.rawQuery('''
      select * from kemandoran
    ''');

    print('ada table');
    print(resulttes);

    if (result == null || result.isEmpty) {
      print("No data found in database.");
      throw Exception('No data found in database');
    }

    List<Kemandoran> kemandorans = [];
    for (var e in result) {
      try {
        kemandorans.add(Kemandoran.fromJson(Map<String, dynamic>.from(e)));
      } catch (err) {
        print("Error mapping row: $e\nError: $err");
      }
    }

    return kemandorans;
  }
}
