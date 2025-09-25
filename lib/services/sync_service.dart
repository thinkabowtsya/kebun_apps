import 'dart:convert';
import 'package:flutter_application_3/models/masterdata.dart';
import 'package:flutter_application_3/services/db_helper.dart';
import 'package:flutter_application_3/services/constant.dart';
import 'package:http/http.dart' as http;

typedef SyncProgress = void Function(int step, int total, String label);

class SyncRepository {
  static const apiUrl = ApiConstants.apiBaseUrl;

  Future<MasterData> syncData({
    required String username,
    required String password,
    SyncProgress? onProgress,
  }) async {
    const String url = '$apiUrl/owlMobile.php';

    int step = 0;
    // hitung total langkah (update sesuai daftar insert kamu)
    const int totalSteps = 1 /* fetch */
            +
            1 /* karyawan */
            +
            1 /* premi bkm */
            +
            1 /* organisasi */
            +
            1 /* blok */
            +
            1 /* master barang */
            +
            1 /* kendaraan */
            +
            1 /* kegiatan */
            +
            1 /* customer */
            +
            1 /* kode denda panen */
            +
            1 /* denda panen */
            +
            1 /* bjr */
            +
            1 /* gps interval */
            +
            1 /* setup approval */
            +
            1 /* purkaryawan */
            +
            1 /* ijin */
            +
            1 /* gudang transaksi */
            +
            1 /* kegiatan norma */
            +
            1 /* klasifikasi */
            +
            1 /* kemandoran */
            +
            1 /* kemandoran blok */
            +
            1 /* kontrak kegiatan */
            +
            1 /* setup mutu */
            +
            1 /* setup hama */
            +
            1 /* setup tph */
            +
            1 /* parameter aplikasi */
            +
            1 /* last nospb */
            +
            1 /* komoditi */
            +
            1 /* sdm absensi */
            +
            1 /* template fingerprint */
            +
            1 /* tiket docket */
            +
            1 /* keu akun */
            +
            1 /* kebun peron */
            +
            1 /* saldo bulanan */
            +
            1 /* rkh ht */
            +
            1 /* rkh dt */
            +
            1 /* rkh dt material */
            +
            1 /* tph besar */
        ;

    void bump(String label) {
      step++;
      onProgress?.call(step, totalSteps, label);
    }

    // print('masih masuk kah');
    try {
      // --- Fetch dari server
      onProgress?.call(0, totalSteps, 'Mengambil data dari server...');
      final response = await http.post(
        Uri.parse(url),
        body: {
          'method': 'synchronize',
          'username': username,
          'password': password,
        },
      );

      if (response.statusCode != 200) {
        throw Exception(
            'Gagal sinkronisasi. Status Code: ${response.statusCode}');
      }

      final Map<String, dynamic> data = jsonDecode(response.body);

      final masterData = MasterData.fromJson(data['masterdata']);
      print(masterData);
      bump('Unduhan selesai, mulai menyimpan ke database...');

      // --- Simpan batch ke DB (beri label yang informatif)
      await DBHelper().insertKaryawanBatch(masterData.karyawan);
      bump('Menyimpan karyawan (${masterData.karyawan.length})');

      await DBHelper().insertPremiBKMBatch(masterData.kebun5Premibkm);
      bump('Menyimpan premi BKM (${masterData.kebun5Premibkm.length})');

      await DBHelper().insertOrganisasiBatch(masterData.organisasi);
      bump('Menyimpan organisasi (${masterData.organisasi.length})');

      await DBHelper().insertSetupBlokBatch(masterData.blok);
      bump('Menyimpan blok (${masterData.blok.length})');

      await DBHelper().insertMasterBarangBatch(masterData.masterbarang);
      bump('Menyimpan master barang (${masterData.masterbarang.length})');

      await DBHelper().insertKendaraanBatch(masterData.kendaraan);
      bump('Menyimpan kendaraan (${masterData.kendaraan.length})');

      await DBHelper().insertKegiatanBatch(masterData.kegiatan);
      bump('Menyimpan kegiatan (${masterData.kegiatan.length})');

      await DBHelper().insertCustomerBatch(masterData.customer);
      bump('Menyimpan customer (${masterData.customer.length})');

      await DBHelper().insertKodeDendaPanenBatch(masterData.kodedendapanen);
      bump('Menyimpan kode denda panen (${masterData.kodedendapanen.length})');

      await DBHelper().insertDendaPanenBatch(masterData.dendapanen);
      bump('Menyimpan denda panen (${masterData.dendapanen.length})');

      await DBHelper().insertbjrBatch(masterData.bjr);
      bump('Menyimpan BJR (${masterData.bjr.length})');

      await DBHelper().insertgpsBatch(masterData.gpsinterval);
      bump('Menyimpan interval GPS (${masterData.gpsinterval.length})');

      await DBHelper().insertsetupapprovalBatch(masterData.setupapproval);
      bump('Menyimpan setup approval (${masterData.setupapproval.length})');

      await DBHelper().insertpurkaryawanBatch(masterData.purkaryawan);
      bump('Menyimpan PUR karyawan (${masterData.purkaryawan.length})');

      await DBHelper().insertijinBatch(masterData.ijin);
      bump('Menyimpan ijin (${masterData.ijin.length})');

      await DBHelper().insertgudangtransaksiBatch(masterData.gudangtransaksi);
      bump('Menyimpan gudang transaksi (${masterData.gudangtransaksi.length})');

      // print(masterData.kegiatannorma);
      await DBHelper().insertkegiatannormaBatch(masterData.kegiatannorma);
      bump('Menyimpan kegiatan norma (${masterData.kegiatannorma.length})');

      await DBHelper().insertklasifikasiBatch(masterData.klasifikasi);
      bump('Menyimpan klasifikasi (${masterData.klasifikasi.length})');

      await DBHelper().insertkemandoranBatch(masterData.kemandoran);
      bump('Menyimpan kemandoran (${masterData.kemandoran.length})');

      await DBHelper().insertkemandoranblokBatch(masterData.kemandoranblok);
      bump('Menyimpan kemandoran blok (${masterData.kemandoranblok.length})');

      await DBHelper().insertkontrakkegiatanBatch(masterData.kontrakkegiatan);
      bump('Menyimpan kontrak kegiatan (${masterData.kontrakkegiatan.length})');

      await DBHelper().insertsetupmutuBatch(masterData.mutuancak);
      bump('Menyimpan setup mutu (${masterData.mutuancak.length})');

      await DBHelper().insertsetuphamaBatch(masterData.setuphama);
      bump('Menyimpan setup hama (${masterData.setuphama.length})');

      await DBHelper().insertsetuptphBatch(masterData.setuptph);
      bump('Menyimpan setup TPH (${masterData.setuptph.length})');

      await DBHelper()
          .insertparameteraplikasiBatch(masterData.parameteraplikasi);
      bump(
          'Menyimpan parameter aplikasi (${masterData.parameteraplikasi.length})');

      await DBHelper().insertdatalastnospbBatch(masterData.lastnospb);
      bump('Menyimpan last No SPB (${masterData.lastnospb.length})');

      await DBHelper().insertkomoditiBatch(masterData.komoditi);
      bump('Menyimpan komoditi (${masterData.komoditi.length})');

      await DBHelper().insertsdmabsensiBatch(masterData.sdmabsensi);
      bump('Menyimpan SDM absensi (${masterData.sdmabsensi.length})');

      await DBHelper()
          .inserttemplatefingerprintBatch(masterData.templatefingerprint);
      bump(
          'Menyimpan template fingerprint (${masterData.templatefingerprint.length})');

      await DBHelper().inserttiketdocketBatch(masterData.tiketdocket);
      bump('Menyimpan tiket docket (${masterData.tiketdocket.length})');

      await DBHelper().insertkeuakunnBatch(masterData.keuakun);
      bump('Menyimpan akun keuangan (${masterData.keuakun.length})');

      await DBHelper().insertkebunperonBatch(masterData.kebunperon);
      bump('Menyimpan kebun peron (${masterData.kebunperon.length})');

      await DBHelper().insertsaldobulananBatch(masterData.saldobulanan);
      bump('Menyimpan saldo bulanan (${masterData.saldobulanan.length})');

      await DBHelper().insertkebunrkhhtBatch(masterData.kebunrkhht);
      bump('Menyimpan RKH HT (${masterData.kebunrkhht.length})');

      await DBHelper().insertkebunrkhdtBatch(masterData.kebunrkhdt);
      bump('Menyimpan RKH DT (${masterData.kebunrkhdt.length})');

      await DBHelper()
          .insertkebunrkhdtmaterialBatch(masterData.kebunrkhdtmaterial);
      bump(
          'Menyimpan RKH DT Material (${masterData.kebunrkhdtmaterial.length})');

      await DBHelper().inserttphbesarBatch(masterData.tphbesar);
      bump('Menyimpan TPH besar (${masterData.tphbesar.length})');

      return masterData;
    } catch (error) {
      onProgress?.call(step, 0, 'Gagal: $error');
      throw Exception('Error: $error');
    }
  }
}
