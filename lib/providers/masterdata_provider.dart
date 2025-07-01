import 'package:flutter/material.dart';
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
import 'package:flutter_application_3/services/master_service.dart';

class MasterdataProvider with ChangeNotifier {
  final MasterRepository _masterRepository = MasterRepository();
  List<Karyawan> _karyawans = [];
  List<Blok> _bloks = [];
  List<Masterbarang> _barangs = [];
  List<Organisasi> _organisasis = [];
  List<Kegiatan> _kegiatans = [];
  List<Kendaraan> _kendaraans = [];
  List<Customer> _customers = [];
  List<Bjr> _bjrs = [];
  List<KodeDendaPanen> _kodedendas = [];
  List<DendaPanen> _dendapanens = [];
  List<MutuAncak> _mutuancaks = [];
  List<Setuphama> _setuphamas = [];
  List<Setuptph> _setuptphs = [];
  List<Kemandoran> _kemandorans = [];
  List<Kebun5Premibkm2> _kebunpremibkm = [];

  List<Karyawan> get karyawans => _karyawans;
  List<Blok> get bloks => _bloks;
  List<Kegiatan> get kegiatans => _kegiatans;
  List<Kendaraan> get kendaraans => _kendaraans;
  List<Customer> get customers => _customers;
  List<Bjr> get bjrs => _bjrs;
  List<KodeDendaPanen> get kodedendas => _kodedendas;
  List<DendaPanen> get dendapanens => _dendapanens;
  List<MutuAncak> get mutuancaks => _mutuancaks;
  List<Setuphama> get setuphamas => _setuphamas;
  List<Setuptph> get setuptphs => _setuptphs;
  List<Kemandoran> get kemandorans => _kemandorans;
  List<Kebun5Premibkm2> get kebunpremi => _kebunpremibkm;

  Future<void> fetchKaryawans() async {
    try {
      _karyawans = await _masterRepository.getKaryawans();
      print("Fetched ${_karyawans.length} karyawans");
      notifyListeners();
    } catch (e) {
      throw Exception('Failed to load karyawans');
    }
  }

  //  Future<void> fetchKebunPremi() async {
  //   try {
  //     _bloks = await _masterRepository.getKebunPremiBkm();
  //     print("Fetched ${_kebunpremibkm.length} premi bkm");
  //     notifyListeners();
  //   } catch (e) {
  //     throw Exception('Failed to load premi bkm');
  //   }
  // }

  Future<void> fetchBloks() async {
    try {
      _bloks = await _masterRepository.getBloks();
      print("Fetched ${_bloks.length} blok");
      notifyListeners();
    } catch (e) {
      throw Exception('Failed to load blok');
    }
  }

  Future<void> fetchBarangs() async {
    try {
      _barangs = await _masterRepository.getBarangs();
      print("Fetched ${_barangs.length} barang");
      notifyListeners();
    } catch (e) {
      throw Exception('Failed to load barang');
    }
  }

  Future<void> fetchOrganisasis() async {
    try {
      _organisasis = await _masterRepository.getOrganisasis();
      print("Fetched ${_organisasis.length} barang");
      notifyListeners();
    } catch (e) {
      throw Exception('Failed to load barang');
    }
  }

  Future<void> fetchKegiatans() async {
    try {
      _kegiatans = await _masterRepository.getKegiatan();
      print("Fetched ${_kegiatans.length} kegiatan");
      notifyListeners();
    } catch (e) {
      throw Exception('Failed to load kegiatan');
    }
  }

  Future<void> fetchKendaraans() async {
    try {
      _kendaraans = await _masterRepository.getKendaraans();
      print("Fetched ${_kendaraans.length} kendaraan");
      notifyListeners();
    } catch (e) {
      throw Exception('Failed to load kendaraan');
    }
  }

  Future<void> fetchCustommers() async {
    try {
      _customers = await _masterRepository.getCustommers();
      print("Fetched ${_customers.length} customer");
      notifyListeners();
    } catch (e) {
      throw Exception('Failed to load customer');
    }
  }

  Future<void> fetchBjrs() async {
    try {
      _bjrs = await _masterRepository.getBjrs();
      print("Fetched ${_bjrs.length} bjr");
      notifyListeners();
    } catch (e) {
      throw Exception('Failed to load bjr');
    }
  }

  Future<void> fetchKodedendas() async {
    try {
      _kodedendas = await _masterRepository.getKodedenda();
      print("Fetched ${_kodedendas.length} kodedenda");
      notifyListeners();
    } catch (e) {
      throw Exception('Failed to load kodedenda');
    }
  }

  Future<void> fetchDendapanens() async {
    try {
      _dendapanens = await _masterRepository.getDendapanen();
      print("Fetched ${_dendapanens.length} denda panen");
      notifyListeners();
    } catch (e) {
      throw Exception('Failed to load denda panen');
    }
  }

  Future<void> fetchMutuancaks() async {
    try {
      _mutuancaks = await _masterRepository.getMutuancak();
      print("Fetched ${_mutuancaks.length} mutu ancak");
      notifyListeners();
    } catch (e) {
      throw Exception('Failed to load mutu ancak');
    }
  }

  Future<void> fetchSetuphama() async {
    try {
      _setuphamas = await _masterRepository.getSetuphama();
      print("Fetched ${_setuphamas.length} mutu ancak");
      notifyListeners();
    } catch (e) {
      throw Exception('Failed to load mutu ancak');
    }
  }

  Future<void> fetchSetuptph() async {
    try {
      _setuptphs = await _masterRepository.getSetuptph();
      print("Fetched ${_setuptphs.length} TPH");
      notifyListeners();
    } catch (e) {
      throw Exception('Failed to load TPH');
    }
  }

  Future<void> fetchKemandoran() async {
    try {
      print('fetch kemandoran');
      _kemandorans = await _masterRepository.getKemandoran();
      print("Fetched ${_kemandorans.length} kemandoran");
      notifyListeners();
    } catch (e) {
      throw Exception('Failed to load kemandoran');
    }
  }
}
