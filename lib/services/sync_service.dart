import 'dart:convert';
import 'package:flutter_application_3/models/masterdata.dart';
import 'package:flutter_application_3/services/db_helper.dart';
import 'package:flutter_application_3/services/constant.dart';
import 'package:http/http.dart' as http;
// Import model yang sudah dibuat

class SyncRepository {
  static const apiUrl = ApiConstants.apiBaseUrl;
  // Method untuk sinkronisasi
  Future<MasterData> syncData() async {
    const String url = '$apiUrl/owlMobile.php';

    try {
      final response = await http.post(
        Uri.parse(url),
        body: {
          'method': 'synchronize',
          'username': 'suliana',
          'password': '123456',
        },
      );

      // Cek jika status code adalah 200
      // if (response.statusCode == 200) {
      //   // Parsing data JSON
      //   Map<String, dynamic> data = jsonDecode(response.body);

      //   MasterData masterData = MasterData.fromJson(data['masterdata']);

      //   // 1 karyawan
      //   for (var karyawan in masterData.karyawan) {
      //     // print('Nama Karyawan: ${karyawan.namakaryawan}');
      //     await DBHelper().insertKaryawan(karyawan);
      //   }
      //   // 2 organisasi
      //   for (var organisasi in masterData.organisasi) {
      //     // print('organisasi: ${organisasi.namaOrganisasi}');
      //     await DBHelper().insertOrganisasi(organisasi);
      //   }

      //   // 3 setup blok
      //   for (var blok in masterData.blok) {
      //     // print('blok: ${blok.kodeorg}');
      //     await DBHelper().insertSetupBlok(blok);
      //   }

      //   // 4 master barang
      //   for (var masterbarang in masterData.masterbarang) {
      //     // print('blok: ${masterbarang.namaBarang}');
      //     await DBHelper().insertMasterBarang(masterbarang);
      //   }

      //   return masterData;
      // } else {
      //   throw Exception(
      //       'Gagal melakukan sinkronisasi. Status Code: ${response.statusCode}');
      // }
      if (response.statusCode == 200) {
        // Parsing data JSON
        Map<String, dynamic> data = jsonDecode(response.body);

        MasterData masterData = MasterData.fromJson(data['masterdata']);

        // 1. Insert Karyawan in batch
        await DBHelper().insertKaryawanBatch(masterData.karyawan);
        await DBHelper().insertPremiBKMBatch(masterData.kebun5Premibkm);
        // await Future.delayed(const Duration(milliseconds: 200));

        // 2. Insert Organisasi in batch
        await DBHelper().insertOrganisasiBatch(masterData.organisasi);

        // 3. Insert Blok in batch
        await DBHelper().insertSetupBlokBatch(masterData.blok);

        // 4. Insert MasterBarang in batch
        await DBHelper().insertMasterBarangBatch(masterData.masterbarang);

        // 5. Insert Kendaraan in batch
        await DBHelper().insertKendaraanBatch(masterData.kendaraan);

        // 6. Insert Kegiatan in batch
        await DBHelper().insertKegiatanBatch(masterData.kegiatan);
        // 7. Insert Customer in batch
        await DBHelper().insertCustomerBatch(masterData.customer);
        // 8. Insert Kode Denda Panen in batch
        await DBHelper().insertKodeDendaPanenBatch(masterData.kodedendapanen);

        // 9. Insert Denda Panen in batch
        await DBHelper().insertDendaPanenBatch(masterData.dendapanen);

        // 10. Insert Bjr in batch
        await DBHelper().insertbjrBatch(masterData.bjr);

        // 11. Insert Gps in batch
        await DBHelper().insertgpsBatch(masterData.gpsinterval);
        // 12. Insert Setup approval in batch
        await DBHelper().insertsetupapprovalBatch(masterData.setupapproval);
        // await Future.delayed(const Duration(milliseconds: 200));
        print(masterData.gudangtransaksi);
        await DBHelper().insertpurkaryawanBatch(masterData.purkaryawan);
        await DBHelper().insertijinBatch(masterData.ijin);
        await DBHelper().insertgudangtransaksiBatch(masterData.gudangtransaksi);
        await DBHelper().insertkegiatannormaBatch(masterData.kegiatannorma);
        await DBHelper().insertklasifikasiBatch(masterData.klasifikasi);
        await DBHelper().insertkemandoranBatch(masterData.kemandoran);
        await DBHelper().insertkemandoranblokBatch(masterData.kemandoranblok);
        await DBHelper().insertkontrakkegiatanBatch(masterData.kontrakkegiatan);
        await DBHelper().insertsetupmutuBatch(masterData.mutuancak);
        await DBHelper().insertsetuphamaBatch(masterData.setuphama);
        await DBHelper().insertsetuptphBatch(masterData.setuptph);
        await DBHelper()
            .insertparameteraplikasiBatch(masterData.parameteraplikasi);
        await DBHelper().insertdatalastnospbBatch(masterData.lastnospb);
        await DBHelper().insertkomoditiBatch(masterData.komoditi);
        await DBHelper().insertsdmabsensiBatch(masterData.sdmabsensi);
        await DBHelper()
            .inserttemplatefingerprintBatch(masterData.templatefingerprint);
        await DBHelper().inserttiketdocketBatch(masterData.tiketdocket);
        await DBHelper().insertkeuakunnBatch(masterData.keuakun);
        await DBHelper().insertkebunperonBatch(masterData.kebunperon);
        await DBHelper().insertsaldobulananBatch(masterData.saldobulanan);
        await DBHelper().insertkebunrkhhtBatch(masterData.kebunrkhht);
        await DBHelper().insertkebunrkhdtBatch(masterData.kebunrkhdt);
        await DBHelper()
            .insertkebunrkhdtmaterialBatch(masterData.kebunrkhdtmaterial);

        return masterData;
      } else {
        throw Exception(
            'Gagal melakukan sinkronisasi. Status Code: ${response.statusCode}');
      }
    } catch (error) {
      throw Exception('Error: $error');
    }
  }
}
