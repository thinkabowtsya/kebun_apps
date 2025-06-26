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

  MasterData(
      {required this.karyawan,
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
      required this.tphbesar});

  // Factory method to convert from JSON
  factory MasterData.fromJson(Map<String, dynamic> json) {
    var list = json['karyawan'] as List? ?? [];
    List<Karyawan> karyawanList =
        list.map((i) => Karyawan.fromJson(i)).toList();

    var listKebunBkm = json['kebun_5premibkm2'] as List? ?? [];
    List<Kebun5Premibkm2> kebun5PremibkmList =
        listKebunBkm.map((i) => Kebun5Premibkm2.fromJson(i)).toList();

    var listOrganisasi = json['organisasi'] as List? ?? [];
    List<Organisasi> organisasiList =
        listOrganisasi.map((i) => Organisasi.fromJson(i)).toList();

    var listBlok = json['blok'] as List? ?? [];
    // print(listBlok);
    List<Blok> blokList = listBlok.map((i) => Blok.fromJson(i)).toList();

    var listMasterBarang = json['barang'] as List? ?? [];
    List<Masterbarang> barangList =
        listMasterBarang.map((i) => Masterbarang.fromJson(i)).toList();

    var listKendaraan = json['kendaraan'] as List? ?? [];
    List<Kendaraan> kendaraanList =
        listKendaraan.map((i) => Kendaraan.fromJson(i)).toList();

    var listKegiatan = json['kegiatan'] as List? ?? [];
    List<Kegiatan> kegiatanList =
        listKegiatan.map((i) => Kegiatan.fromJson(i)).toList();

    var listCustomer = json['customer'] as List? ?? [];
    List<Customer> customerList =
        listCustomer.map((i) => Customer.fromJson(i)).toList();

    var listBjr = json['bjr'] as List? ?? [];
    List<Bjr> bjrList = listBjr.map((i) => Bjr.fromJson(i)).toList();

    var listKodeDendapanen = json['kodedendapanen'] as List? ?? [];
    List<KodeDendaPanen> kodedendaPanenList =
        listKodeDendapanen.map((i) => KodeDendaPanen.fromJson(i)).toList();

    var listDendapanen = json['dendapanen'] as List? ?? [];
    List<DendaPanen> dendaPanenList =
        listDendapanen.map((i) => DendaPanen.fromJson(i)).toList();

    var listGpsinterval = json['gps'] as List? ?? [];
    List<Gpsinterval> gpsintervalList =
        listGpsinterval.map((i) => Gpsinterval.fromJson(i)).toList();

    var listSetupApproval = json['setupapproval'] as List? ?? [];
    List<SetupApproval> setupapprovalList =
        listSetupApproval.map((i) => SetupApproval.fromJson(i)).toList();

    var listPurkaryawan = json['purchaser'] as List? ?? [];
    List<PurKaryawan> purkaryawanList =
        listPurkaryawan.map((i) => PurKaryawan.fromJson(i)).toList();

    var listIjin = json['ijin'] as List? ?? [];
    List<Ijin> ijinList = listIjin.map((i) => Ijin.fromJson(i)).toList();

    var listGudangtransaksi = json['gudangtransaksi'] as List? ?? [];
    List<GudangTransaksi> gudangtransaksiList =
        listGudangtransaksi.map((i) => GudangTransaksi.fromJson(i)).toList();

    var listKegiatannorma = json['kegiatannorma'] as List? ?? [];
    List<KegiatanNorma> kegiatannormaList =
        listKegiatannorma.map((i) => KegiatanNorma.fromJson(i)).toList();

    var listKlasifikasi = json['klasifikasi'] as List? ?? [];
    List<Klasifikasi> klasifikasiList =
        listKlasifikasi.map((i) => Klasifikasi.fromJson(i)).toList();

    var listKemandoran = json['kemandoran'] as List? ?? [];
    List<Kemandoran> kemandoranList =
        listKemandoran.map((i) => Kemandoran.fromJson(i)).toList();

    var listKemandoranblok = json['kemandoranblok'] as List? ?? [];
    List<KemandoranBlok> kemandoranblokList =
        listKemandoranblok.map((i) => KemandoranBlok.fromJson(i)).toList();

    var listKontrakkegiatan = json['kontrakkegiatan'] as List? ?? [];
    List<KontrakKegiatan> kontrakkegiatanList =
        listKontrakkegiatan.map((i) => KontrakKegiatan.fromJson(i)).toList();

    var listMutuancak = json['setup_mutu'] as List? ?? [];
    List<MutuAncak> mutuancakList =
        listMutuancak.map((i) => MutuAncak.fromJson(i)).toList();

    var listSetuphama = json['setup_hama'] as List? ?? [];
    List<Setuphama> setuphamaList =
        listSetuphama.map((i) => Setuphama.fromJson(i)).toList();

    var listSetuptph = json['setup_tph'] as List? ?? [];
    List<Setuptph> setuptphList =
        listSetuptph.map((i) => Setuptph.fromJson(i)).toList();

    var listParameteraplikasi = json['setup_parameterappl'] as List? ?? [];
    List<ParameterAplikasi> parameteraplikasiList = listParameteraplikasi
        .map((i) => ParameterAplikasi.fromJson(i))
        .toList();

    var listLastnospb = json['data_lastnospb'] as List? ?? [];
    List<LastNospb> datalastnospbList =
        listLastnospb.map((i) => LastNospb.fromJson(i)).toList();

    var listKomoditi = json['pmn_4komoditi'] as List? ?? [];
    List<Komoditi> komoditiList =
        listKomoditi.map((i) => Komoditi.fromJson(i)).toList();

    var listSdmabsensi = json['sdm_5absensi'] as List? ?? [];
    List<SdmAbsensi> sdmabsensiList =
        listSdmabsensi.map((i) => SdmAbsensi.fromJson(i)).toList();

    var listTemplatefingerprint =
        json['fingerprint_template_server'] as List? ?? [];
    List<TemplateFingerprint> templatefingerprintList = listTemplatefingerprint
        .map((i) => TemplateFingerprint.fromJson(i))
        .toList();

    var listTiketdocket = json['tiket_docket'] as List? ?? [];
    List<Tiketdocket> tiketdocketList =
        listTiketdocket.map((i) => Tiketdocket.fromJson(i)).toList();

    var listKeuakun = json['keu_5akun'] as List? ?? [];
    List<Keuakun> keuakunList =
        listKeuakun.map((i) => Keuakun.fromJson(i)).toList();

    var listKebunperon = json['kebun_5peron'] as List? ?? [];
    List<KebunPeron> kebunperonList =
        listKebunperon.map((i) => KebunPeron.fromJson(i)).toList();

    var listSaldobulanan = json['log_5saldobulanan'] as List? ?? [];
    List<Saldobulanan> saldobulananList =
        listSaldobulanan.map((i) => Saldobulanan.fromJson(i)).toList();

    var listKebunrkhht = json['kebun_rkhht'] as List? ?? [];
    List<Kebunrkhht> kebunrkhhtList =
        listKebunrkhht.map((i) => Kebunrkhht.fromJson(i)).toList();

    var listKebunrkhdt = json['kebun_rkh_dt'] as List? ?? [];
    List<Kebunrkhdt> kebunrkhdtList =
        listKebunrkhdt.map((i) => Kebunrkhdt.fromJson(i)).toList();

    var listKebunrkhdtmaterial = json['kebun_rkh_dtmaterial'] as List? ?? [];
    List<Kebunrkhdtmaterial> kebunrkhdtmaterialList = listKebunrkhdtmaterial
        .map((i) => Kebunrkhdtmaterial.fromJson(i))
        .toList();

    var listTphbesar = json['tphbesar'] as List? ?? [];
    List<Tphbesar> tphbesarList =
        listTphbesar.map((i) => Tphbesar.fromJson(i)).toList();

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
        tphbesar: tphbesarList);
  }

  Map<String, dynamic> toJson() {
    List<Map<String, dynamic>> karyawanList =
        karyawan.map((karyawan) => karyawan.toJson()).toList();

    List<Map<String, dynamic>> kebun5PremibkmList = kebun5Premibkm
        .map((kebun5Premibkm) => kebun5Premibkm.toJson())
        .toList();

    List<Map<String, dynamic>> organisasiList =
        organisasi.map((organisasi) => organisasi.toJson()).toList();

    List<Map<String, dynamic>> blokList =
        blok.map((blok) => blok.toJson()).toList();

    List<Map<String, dynamic>> barangList =
        masterbarang.map((masterbarang) => masterbarang.toJson()).toList();

    List<Map<String, dynamic>> kendaraanList =
        kendaraan.map((kendaraan) => kendaraan.toJson()).toList();

    List<Map<String, dynamic>> kegiatanList =
        kegiatan.map((kegiatan) => kegiatan.toJson()).toList();

    List<Map<String, dynamic>> customerList =
        customer.map((customer) => customer.toJson()).toList();

    List<Map<String, dynamic>> bjrList =
        bjr.map((bjr) => bjr.toJson()).toList();

    List<Map<String, dynamic>> kodedendaPanenList = kodedendapanen
        .map((kodedendapanen) => kodedendapanen.toJson())
        .toList();

    List<Map<String, dynamic>> dendaPanenList =
        dendapanen.map((dendapanen) => dendapanen.toJson()).toList();

    List<Map<String, dynamic>> gpsList =
        gpsinterval.map((gpsinterval) => gpsinterval.toJson()).toList();

    List<Map<String, dynamic>> setupapprovalList =
        setupapproval.map((setupapproval) => setupapproval.toJson()).toList();

    List<Map<String, dynamic>> purkaryawanList =
        purkaryawan.map((purkaryawan) => purkaryawan.toJson()).toList();

    List<Map<String, dynamic>> ijinList =
        ijin.map((ijin) => ijin.toJson()).toList();

    List<Map<String, dynamic>> gudangtransaksiList = gudangtransaksi
        .map((gudangtransaksi) => gudangtransaksi.toJson())
        .toList();

    List<Map<String, dynamic>> kegiatannormaList =
        kegiatannorma.map((kegiatannorma) => kegiatannorma.toJson()).toList();

    List<Map<String, dynamic>> klasifikasiList =
        klasifikasi.map((klasifikasi) => klasifikasi.toJson()).toList();

    List<Map<String, dynamic>> kemandoranList =
        kemandoran.map((kemandoran) => kemandoran.toJson()).toList();

    List<Map<String, dynamic>> kemandoranblokList = kemandoranblok
        .map((kemandoranblok) => kemandoranblok.toJson())
        .toList();

    List<Map<String, dynamic>> kontrakkegiatanList = kontrakkegiatan
        .map((kontrakkegiatan) => kontrakkegiatan.toJson())
        .toList();

    List<Map<String, dynamic>> mutuancakList =
        mutuancak.map((mutuancak) => mutuancak.toJson()).toList();

    List<Map<String, dynamic>> setuphamaList =
        setuphama.map((setuphama) => setuphama.toJson()).toList();

    List<Map<String, dynamic>> setuptphList =
        setuptph.map((setuptph) => setuptph.toJson()).toList();

    List<Map<String, dynamic>> parameteraplikasiList = parameteraplikasi
        .map((parameteraplikasi) => parameteraplikasi.toJson())
        .toList();

    List<Map<String, dynamic>> datalastnospbList =
        lastnospb.map((datalastnospb) => datalastnospb.toJson()).toList();

    List<Map<String, dynamic>> datakomoditiList =
        komoditi.map((datakomoditi) => datakomoditi.toJson()).toList();

    List<Map<String, dynamic>> sdmabsensiList =
        sdmabsensi.map((sdmabsensi) => sdmabsensi.toJson()).toList();

    List<Map<String, dynamic>> templatefingerprintList = templatefingerprint
        .map((templatefingerprint) => templatefingerprint.toJson())
        .toList();

    List<Map<String, dynamic>> tiketdocketList =
        tiketdocket.map((tiketdocket) => tiketdocket.toJson()).toList();

    List<Map<String, dynamic>> keuakunList =
        keuakun.map((keuakun) => keuakun.toJson()).toList();

    List<Map<String, dynamic>> kebunperonList =
        kebunperon.map((kebunperon) => kebunperon.toJson()).toList();

    List<Map<String, dynamic>> saldobulananList =
        saldobulanan.map((saldobulanan) => saldobulanan.toJson()).toList();

    List<Map<String, dynamic>> kebunrkhhtList =
        kebunrkhht.map((kebunrkhht) => kebunrkhht.toJson()).toList();

    List<Map<String, dynamic>> kebunrkhdtList =
        kebunrkhdt.map((kebunrkhdt) => kebunrkhdt.toJson()).toList();

    List<Map<String, dynamic>> kebunrkhdtmaterialList = kebunrkhdtmaterial
        .map((kebunrkhdtmaterial) => kebunrkhdtmaterial.toJson())
        .toList();

    List<Map<String, dynamic>> tphbesarList =
        tphbesar.map((tphbesar) => tphbesar.toJson()).toList();

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
      'tphbesar': tphbesarList
    };
  }
}
