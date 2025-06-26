import 'package:flutter_application_3/models/bjr.dart';
import 'package:flutter_application_3/models/blok.dart';
import 'package:flutter_application_3/models/customer.dart';
import 'package:flutter_application_3/models/dendapanen.dart';
import 'package:flutter_application_3/models/karyawan.dart';
import 'package:flutter_application_3/models/kebun5bkm.dart';
import 'package:flutter_application_3/models/kegiatan.dart';
import 'package:flutter_application_3/models/kemandoran.dart';
import 'package:flutter_application_3/models/kendaraan.dart';
import 'package:flutter_application_3/models/kodedendapanen.dart';
import 'package:flutter_application_3/models/masterbarang.dart';
import 'package:flutter_application_3/models/organisasi.dart';
import 'package:flutter_application_3/models/setuphama.dart';
import 'package:flutter_application_3/models/setupmutu.dart';
import 'package:flutter_application_3/models/setuptph.dart';
import 'package:flutter_application_3/pages/kode_denda_page.dart';
import 'package:flutter_application_3/services/db_helper.dart';

class MasterRepository {
  final DBHelper dbHelper = DBHelper();

  // Fetch all karyawans from the SQLite database
  Future<List<Karyawan>> getKaryawans() async {
    // First, check SQLite
    List<Karyawan> localKaryawans = await dbHelper.fetchKaryawans();

    if (localKaryawans.isNotEmpty) {
      print("Data fetched from local DB: ${localKaryawans.length} records");
      return localKaryawans; // Return data from SQLite if available
    } else {
      print("No data found in local DB");
      throw Exception('No karyawans found in local database');
    }
  }

  Future<List<Blok>> getBloks() async {
    // First, check SQLite
    List<Blok> localBloks = await dbHelper.fetchBlok();

    if (localBloks.isNotEmpty) {
      print("Data fetched from local DB: ${localBloks.length} records");
      return localBloks; // Return data from SQLite if available
    } else {
      print("No data found in local DB");
      throw Exception('No karyawans found in local database');
    }
  }

  // Future<List<Kebun5Premibkm2>> getKebunPremiBkm() async {
  //   // First, check SQLite
  //   List<Kebun5Premibkm2> localPremi = await dbHelper.fetchPremiBKM();

  //   if (localPremi.isNotEmpty) {
  //     print("Data fetched from local DB: ${localPremi.length} records");
  //     return localPremi; // Return data from SQLite if available
  //   } else {
  //     print("No data found in local DB");
  //     throw Exception('No karyawans found in local database');
  //   }
  // }

  Future<List<Kegiatan>> getKegiatan() async {
    // First, check SQLite
    List<Kegiatan> localKegiatans = await dbHelper.fetchKegiatan();

    if (localKegiatans.isNotEmpty) {
      print("Data fetched from local DB: ${localKegiatans.length} records");
      return localKegiatans; // Return data from SQLite if available
    } else {
      print("No data found in local DB");
      throw Exception('No karyawans found in local database');
    }
  }

  Future<List<Kendaraan>> getKendaraans() async {
    // First, check SQLite
    List<Kendaraan> localKendaraans = await dbHelper.fetchKendaraan();

    if (localKendaraans.isNotEmpty) {
      print("Data fetched from local DB: ${localKendaraans.length} records");
      return localKendaraans;
    } else {
      print("No data found in local DB");
      throw Exception('No karyawans found in local database');
    }
  }

  Future<List<Masterbarang>> getBarangs() async {
    // First, check SQLite
    List<Masterbarang> localBarangs = await dbHelper.fetchBarang();

    if (localBarangs.isNotEmpty) {
      print("Data fetched from local DB: ${localBarangs.length} records");
      return localBarangs;
    } else {
      print("No data found in local DB");
      throw Exception('No barangs found in local database');
    }
  }

  Future<List<Organisasi>> getOrganisasis() async {
    // First, check SQLite
    List<Organisasi> localOrganisasis = await dbHelper.fetchOrganisasi();

    if (localOrganisasis.isNotEmpty) {
      print("Data fetched from local DB: ${localOrganisasis.length} records");
      return localOrganisasis;
    } else {
      print("No data found in local DB");
      throw Exception('No organisasis found in local database');
    }
  }

  Future<List<Customer>> getCustommers() async {
    // First, check SQLite
    List<Customer> localCustomers = await dbHelper.fetchCustommer();

    if (localCustomers.isNotEmpty) {
      print("Data fetched from local DB: ${localCustomers.length} records");
      return localCustomers;
    } else {
      print("No data found in local DB");
      throw Exception('No customers found in local database');
    }
  }

  Future<List<Bjr>> getBjrs() async {
    // First, check SQLite
    List<Bjr> localBjrs = await dbHelper.fetchBjr();

    if (localBjrs.isNotEmpty) {
      print("Data fetched from local DB: ${localBjrs.length} records");
      return localBjrs;
    } else {
      print("No data found in local DB");
      throw Exception('No bjrs found in local database');
    }
  }

  Future<List<KodeDendaPanen>> getKodedenda() async {
    // First, check SQLite
    List<KodeDendaPanen> localPanens = await dbHelper.fetchKodedenda();

    if (localPanens.isNotEmpty) {
      print("Data fetched from local DB: ${localPanens.length} records");
      return localPanens;
    } else {
      print("No data found in local DB");
      throw Exception('No bjrs found in local database');
    }
  }

  Future<List<DendaPanen>> getDendapanen() async {
    // First, check SQLite
    List<DendaPanen> localDendas = await dbHelper.fetchDendapanen();

    if (localDendas.isNotEmpty) {
      print("Data fetched from local DB: ${localDendas.length} records");
      return localDendas;
    } else {
      print("No data found in local DB");
      throw Exception('No denda found in local database');
    }
  }

  Future<List<MutuAncak>> getMutuancak() async {
    // First, check SQLite
    List<MutuAncak> localMutuancaks = await dbHelper.fetchMutuancak();

    if (localMutuancaks.isNotEmpty) {
      print("Data fetched from local DB: ${localMutuancaks.length} records");
      return localMutuancaks;
    } else {
      print("No data found in local DB");
      throw Exception('No denda found in local database');
    }
  }

  Future<List<Setuphama>> getSetuphama() async {
    // First, check SQLite
    List<Setuphama> localSetuphamas = await dbHelper.fetchHama();

    if (localSetuphamas.isNotEmpty) {
      print("Data fetched from local DB: ${localSetuphamas.length} records");
      return localSetuphamas;
    } else {
      print("No data found in local DB");
      throw Exception('No denda found in local database');
    }
  }

  Future<List<Setuptph>> getSetuptph() async {
    // First, check SQLite
    List<Setuptph> localSetuptphs = await dbHelper.fetchTph();

    if (localSetuptphs.isNotEmpty) {
      print("Data fetched from local DB: ${localSetuptphs.length} records");
      return localSetuptphs;
    } else {
      print("No data found in local DB");
      throw Exception('No denda found in local database');
    }
  }

  Future<List<Kemandoran>> getKemandoran() async {
    // First, check SQLite
    List<Kemandoran> localKemandorans = await dbHelper.fetchKemandoran();

    if (localKemandorans.isNotEmpty) {
      print("Data fetched from local DB: ${localKemandorans.length} records");
      return localKemandorans;
    } else {
      print("No data found in local DB");
      throw Exception('No denda found in local database');
    }
  }
}
