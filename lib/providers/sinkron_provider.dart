import 'package:flutter/material.dart';
import 'package:flutter_application_3/models/masterdata.dart';
import 'package:flutter_application_3/services/sync_service.dart';

class SinkronProvider with ChangeNotifier {
  final SyncRepository _syncRepository = SyncRepository();
  bool _isSyncing = false; // Status sinkronisasi
  bool get isSyncing => _isSyncing;

  Future<void> sinkronisasi() async {
    print('Provider sync started');
    _isSyncing = true; // Menandakan bahwa sinkronisasi dimulai
    notifyListeners(); // Memberitahu UI untuk memperbarui

    try {
      await _syncRepository.syncData();

      // for (var karyawan in masterData.karyawan) {
      //   print('Nama Karyawan: ${karyawan.namakaryawan}');
      // }

      // Sinkronisasi selesai
      _isSyncing = false;
      notifyListeners();
    } catch (error) {
      print('Error saat sinkronisasi: $error');
      _isSyncing = false;
      notifyListeners(); // Memberitahu UI untuk memperbarui
    }
  }
}
