import 'package:flutter_application_3/models/bjr.dart';
import 'package:flutter_application_3/models/blok.dart';
import 'package:flutter_application_3/models/customer.dart';
import 'package:flutter_application_3/models/datalastnospb.dart';
import 'package:flutter_application_3/models/dendapanen.dart';
import 'package:flutter_application_3/models/gpsinterval.dart';
import 'package:flutter_application_3/models/gudangtransaksi.dart';
import 'package:flutter_application_3/models/ijin.dart';
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
import 'package:flutter_application_3/models/kebun5bkm.dart';
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

class MasterData {
  List<Karyawan> karyawan;
  List<Kebun5Premibkm2> kebun5Premibkm;
  List<Organisasi> organisasi;
  List<Blok> blok;
  List<Masterbarang> masterbarang;
  List<Kendaraan> kendaraan;
  List<Kegiatan> kegiatan;
  List<Customer> customer;
  List<Bjr> bjr;
  List<KodeDendaPanen> kodedendapanen;
  List<DendaPanen> dendapanen;
  List<Gpsinterval> gpsinterval;
  List<SetupApproval> setupapproval;
  List<PurKaryawan> purkaryawan;
  List<Ijin> ijin;
  List<GudangTransaksi> gudangtransaksi;
  List<KegiatanNorma> kegiatannorma;
  List<Klasifikasi> klasifikasi;
  List<Kemandoran> kemandoran;
  List<KemandoranBlok> kemandoranblok;
  List<KontrakKegiatan> kontrakkegiatan;
  List<MutuAncak> mutuancak;
  List<Setuphama> setuphama;
  List<Setuptph> setuptph;
  List<ParameterAplikasi> parameteraplikasi;
  List<LastNospb> lastnospb;
  List<Komoditi> komoditi;
  List<SdmAbsensi> sdmabsensi;
  List<TemplateFingerprint> templatefingerprint;
  List<Tiketdocket> tiketdocket;
  List<Keuakun> keuakun;
  List<KebunPeron> kebunperon;
  List<Saldobulanan> saldobulanan;
  List<Kebunrkhht> kebunrkhht;
  List<Kebunrkhdt> kebunrkhdt;
  List<Kebunrkhdtmaterial> kebunrkhdtmaterial;
  List<Tphbesar> tphbesar;

  MasterData({
    required this.karyawan,
    required this.kebun5Premibkm,
    required this.organisasi,
    required this.blok,
    required this.masterbarang,
    required this.kendaraan,
    required this.kegiatan,
    required this.customer,
    required this.bjr,
    required this.kodedendapanen,
    required this.dendapanen,
    required this.gpsinterval,
    required this.setupapproval,
    required this.purkaryawan,
    required this.ijin,
    required this.gudangtransaksi,
    required this.kegiatannorma,
    required this.klasifikasi,
    required this.kemandoran,
    required this.kemandoranblok,
    required this.kontrakkegiatan,
    required this.mutuancak,
    required this.setuphama,
    required this.setuptph,
    required this.parameteraplikasi,
    required this.lastnospb,
    required this.komoditi,
    required this.sdmabsensi,
    required this.templatefingerprint,
    required this.tiketdocket,
    required this.keuakun,
    required this.kebunperon,
    required this.saldobulanan,
    required this.kebunrkhht,
    required this.kebunrkhdt,
    required this.kebunrkhdtmaterial,
    required this.tphbesar,
  });

  /// Mapper list aman: key hilang/null -> [], item bukan Map -> skip, item gagal parse -> skip
  static List<T> _list<T>(
    Map<String, dynamic> src,
    String key,
    T Function(Map<String, dynamic>) fromJsonItem,
  ) {
    final raw = src[key];
    if (raw is! List) return <T>[];
    final out = <T>[];
    for (var i = 0; i < raw.length; i++) {
      final it = raw[i];
      if (it is! Map<String, dynamic>) continue;
      try {
        out.add(fromJsonItem(it));
      } catch (_) {
        // skip item bermasalah, jangan hentikan seluruh proses
      }
    }
    return out;
  }

  // Factory method to convert from JSON (safe defaults)
  factory MasterData.fromJson(Map<String, dynamic> json) {
    final karyawanList = _list(json, 'karyawan', (m) => Karyawan.fromJson(m));
    final kebun5PremibkmList =
        _list(json, 'kebun_5premibkm2', (m) => Kebun5Premibkm2.fromJson(m));
    final organisasiList =
        _list(json, 'organisasi', (m) => Organisasi.fromJson(m));
    final blokList = _list(json, 'blok', (m) => Blok.fromJson(m));
    final barangList = _list(json, 'barang', (m) => Masterbarang.fromJson(m));
    final kendaraanList =
        _list(json, 'kendaraan', (m) => Kendaraan.fromJson(m));
    final kegiatanList = _list(json, 'kegiatan', (m) => Kegiatan.fromJson(m));
    final customerList = _list(json, 'customer', (m) => Customer.fromJson(m));
    final bjrList = _list(json, 'bjr', (m) => Bjr.fromJson(m));
    final kodedendaPanenList =
        _list(json, 'kodedendapanen', (m) => KodeDendaPanen.fromJson(m));
    final dendaPanenList =
        _list(json, 'dendapanen', (m) => DendaPanen.fromJson(m));
    final gpsintervalList = _list(json, 'gps', (m) => Gpsinterval.fromJson(m));
    final setupapprovalList =
        _list(json, 'setupapproval', (m) => SetupApproval.fromJson(m));
    final purkaryawanList =
        _list(json, 'purchaser', (m) => PurKaryawan.fromJson(m));
    final ijinList = _list(json, 'ijin', (m) => Ijin.fromJson(m));
    final gudangtransaksiList =
        _list(json, 'gudangtransaksi', (m) => GudangTransaksi.fromJson(m));
    final kegiatannormaList =
        _list(json, 'kegiatannorma', (m) => KegiatanNorma.fromJson(m));
    final klasifikasiList =
        _list(json, 'klasifikasi', (m) => Klasifikasi.fromJson(m));
    final kemandoranList =
        _list(json, 'kebun_5mandor', (m) => Kemandoran.fromJson(m));
    final kemandoranblokList =
        _list(json, 'kemandoranblok', (m) => KemandoranBlok.fromJson(m));
    final kontrakkegiatanList =
        _list(json, 'kontrakkegiatan', (m) => KontrakKegiatan.fromJson(m));
    final mutuancakList =
        _list(json, 'setup_mutu', (m) => MutuAncak.fromJson(m));
    final setuphamaList =
        _list(json, 'setup_hama', (m) => Setuphama.fromJson(m));
    final setuptphList = _list(json, 'setup_tph', (m) => Setuptph.fromJson(m));
    final parameteraplikasiList = _list(
        json, 'setup_parameterappl', (m) => ParameterAplikasi.fromJson(m));
    final datalastnospbList =
        _list(json, 'data_lastnospb', (m) => LastNospb.fromJson(m));
    final komoditiList =
        _list(json, 'pmn_4komoditi', (m) => Komoditi.fromJson(m));
    final sdmabsensiList =
        _list(json, 'sdm_5absensi', (m) => SdmAbsensi.fromJson(m));
    final templatefingerprintList = _list(json, 'fingerprint_template_server',
        (m) => TemplateFingerprint.fromJson(m));
    final tiketdocketList =
        _list(json, 'tiket_docket', (m) => Tiketdocket.fromJson(m));
    final keuakunList = _list(json, 'keu_5akun', (m) => Keuakun.fromJson(m));
    final kebunperonList =
        _list(json, 'kebun_5peron', (m) => KebunPeron.fromJson(m));
    final saldobulananList =
        _list(json, 'log_5saldobulanan', (m) => Saldobulanan.fromJson(m));
    final kebunrkhhtList =
        _list(json, 'kebun_rkhht', (m) => Kebunrkhht.fromJson(m));
    final kebunrkhdtList =
        _list(json, 'kebun_rkh_dt', (m) => Kebunrkhdt.fromJson(m));
    final kebunrkhdtmaterialList = _list(
        json, 'kebun_rkh_dtmaterial', (m) => Kebunrkhdtmaterial.fromJson(m));
    final tphbesarList = _list(json, 'tphbesar', (m) => Tphbesar.fromJson(m));

    return MasterData(
      karyawan: karyawanList,
      kebun5Premibkm: kebun5PremibkmList,
      organisasi: organisasiList,
      blok: blokList,
      masterbarang: barangList,
      kendaraan: kendaraanList,
      kegiatan: kegiatanList,
      customer: customerList,
      bjr: bjrList,
      kodedendapanen: kodedendaPanenList,
      dendapanen: dendaPanenList,
      gpsinterval: gpsintervalList,
      setupapproval: setupapprovalList,
      purkaryawan: purkaryawanList,
      ijin: ijinList,
      gudangtransaksi: gudangtransaksiList,
      kegiatannorma: kegiatannormaList,
      klasifikasi: klasifikasiList,
      kemandoran: kemandoranList,
      kemandoranblok: kemandoranblokList,
      kontrakkegiatan: kontrakkegiatanList,
      mutuancak: mutuancakList,
      setuphama: setuphamaList,
      setuptph: setuptphList,
      parameteraplikasi: parameteraplikasiList,
      lastnospb: datalastnospbList,
      komoditi: komoditiList,
      sdmabsensi: sdmabsensiList,
      templatefingerprint: templatefingerprintList,
      tiketdocket: tiketdocketList,
      keuakun: keuakunList,
      kebunperon: kebunperonList,
      saldobulanan: saldobulananList,
      kebunrkhht: kebunrkhhtList,
      kebunrkhdt: kebunrkhdtList,
      kebunrkhdtmaterial: kebunrkhdtmaterialList,
      tphbesar: tphbesarList,
    );
  }

  Map<String, dynamic> toJson() {
    List<Map<String, dynamic>> karyawanList =
        karyawan.map((e) => e.toJson()).toList();
    List<Map<String, dynamic>> kebun5PremibkmList =
        kebun5Premibkm.map((e) => e.toJson()).toList();
    List<Map<String, dynamic>> organisasiList =
        organisasi.map((e) => e.toJson()).toList();
    List<Map<String, dynamic>> blokList = blok.map((e) => e.toJson()).toList();
    List<Map<String, dynamic>> barangList =
        masterbarang.map((e) => e.toJson()).toList();
    List<Map<String, dynamic>> kendaraanList =
        kendaraan.map((e) => e.toJson()).toList();
    List<Map<String, dynamic>> kegiatanList =
        kegiatan.map((e) => e.toJson()).toList();
    List<Map<String, dynamic>> customerList =
        customer.map((e) => e.toJson()).toList();
    List<Map<String, dynamic>> bjrList = bjr.map((e) => e.toJson()).toList();
    List<Map<String, dynamic>> kodedendaPanenList =
        kodedendapanen.map((e) => e.toJson()).toList();
    List<Map<String, dynamic>> dendaPanenList =
        dendapanen.map((e) => e.toJson()).toList();
    List<Map<String, dynamic>> gpsList =
        gpsinterval.map((e) => e.toJson()).toList();
    List<Map<String, dynamic>> setupapprovalList =
        setupapproval.map((e) => e.toJson()).toList();
    List<Map<String, dynamic>> purkaryawanList =
        purkaryawan.map((e) => e.toJson()).toList();
    List<Map<String, dynamic>> ijinList = ijin.map((e) => e.toJson()).toList();
    List<Map<String, dynamic>> gudangtransaksiList =
        gudangtransaksi.map((e) => e.toJson()).toList();
    List<Map<String, dynamic>> kegiatannormaList =
        kegiatannorma.map((e) => e.toJson()).toList();
    List<Map<String, dynamic>> klasifikasiList =
        klasifikasi.map((e) => e.toJson()).toList();
    List<Map<String, dynamic>> kemandoranList =
        kemandoran.map((e) => e.toJson()).toList();
    List<Map<String, dynamic>> kemandoranblokList =
        kemandoranblok.map((e) => e.toJson()).toList();
    List<Map<String, dynamic>> kontrakkegiatanList =
        kontrakkegiatan.map((e) => e.toJson()).toList();
    List<Map<String, dynamic>> mutuancakList =
        mutuancak.map((e) => e.toJson()).toList();
    List<Map<String, dynamic>> setuphamaList =
        setuphama.map((e) => e.toJson()).toList();
    List<Map<String, dynamic>> setuptphList =
        setuptph.map((e) => e.toJson()).toList();
    List<Map<String, dynamic>> parameteraplikasiList =
        parameteraplikasi.map((e) => e.toJson()).toList();
    List<Map<String, dynamic>> datalastnospbList =
        lastnospb.map((e) => e.toJson()).toList();
    List<Map<String, dynamic>> datakomoditiList =
        komoditi.map((e) => e.toJson()).toList();
    List<Map<String, dynamic>> sdmabsensiList =
        sdmabsensi.map((e) => e.toJson()).toList();
    List<Map<String, dynamic>> templatefingerprintList =
        templatefingerprint.map((e) => e.toJson()).toList();
    List<Map<String, dynamic>> tiketdocketList =
        tiketdocket.map((e) => e.toJson()).toList();
    List<Map<String, dynamic>> keuakunList =
        keuakun.map((e) => e.toJson()).toList();
    List<Map<String, dynamic>> kebunperonList =
        kebunperon.map((e) => e.toJson()).toList();
    List<Map<String, dynamic>> saldobulananList =
        saldobulanan.map((e) => e.toJson()).toList();
    List<Map<String, dynamic>> kebunrkhhtList =
        kebunrkhht.map((e) => e.toJson()).toList();
    List<Map<String, dynamic>> kebunrkhdtList =
        kebunrkhdt.map((e) => e.toJson()).toList();
    List<Map<String, dynamic>> kebunrkhdtmaterialList =
        kebunrkhdtmaterial.map((e) => e.toJson()).toList();
    List<Map<String, dynamic>> tphbesarList =
        tphbesar.map((e) => e.toJson()).toList();

    return {
      'karyawan': karyawanList,
      'kebun_5premibkm2': kebun5PremibkmList,
      'organisasi': organisasiList,
      'blok': blokList,
      'masterbarang': barangList,
      'kendaraan': kendaraanList,
      'kegiatan': kegiatanList,
      'customer': customerList,
      'bjr': bjrList,
      'kodedendapanen': kodedendaPanenList,
      'dendapanen': dendaPanenList,
      'gps': gpsList,
      'setupapproval': setupapprovalList,
      'purkaryawan': purkaryawanList,
      'ijin': ijinList,
      'gudangtransaksi': gudangtransaksiList,
      'kegiatannorma': kegiatannormaList,
      'klasifikasi': klasifikasiList,
      'kemandoran': kemandoranList,
      'kemandoranblok': kemandoranblokList,
      'kontrakkegiatan': kontrakkegiatanList,
      'mutuancak': mutuancakList,
      'setuphama': setuphamaList,
      'setuptph': setuptphList,
      'parameteraplikasi': parameteraplikasiList,
      'datalastnospb': datalastnospbList,
      'komoditi': datakomoditiList,
      'sdmabsensi': sdmabsensiList,
      'templatefingerprint': templatefingerprintList,
      'tiketdocket': tiketdocketList,
      'keuakun': keuakunList,
      'kebunperon': kebunperonList,
      'saldobulanan': saldobulananList,
      'kebunrkhht': kebunrkhhtList,
      'kebunrkhdt': kebunrkhdtList,
      'kebunrkhdtmaterial': kebunrkhdtmaterialList,
      'tphbesar': tphbesarList,
    };
  }
}
