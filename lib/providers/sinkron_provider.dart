import 'package:flutter/material.dart';
import 'package:flutter_application_3/models/masterdata.dart';
import 'package:flutter_application_3/services/sync_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SinkronProvider with ChangeNotifier {
  final SyncRepository _syncRepository;
  SinkronProvider(this._syncRepository);
  bool _isSyncing = false;
  double _progress = 0.0; // 0..1
  String _message = 'Menyiapkan sinkronisasi...';

  bool get isSyncing => _isSyncing;
  double get progress => _progress;
  String get message => _message;

  Future<void> sinkronisasi(
      {required String username, required String password}) async {
    _isSyncing = true;
    _progress = 0.0;
    _message = 'Menghubungkan server...';
    final prefs = await SharedPreferences.getInstance();

    print('set pass : $password');
    await prefs.setString('password', password);
    notifyListeners();

    try {
      await _syncRepository.syncData(
        username: username,
        password: password,
        onProgress: (int step, int total, String label) {
          _progress = total == 0 ? 0 : step / total;
          _message = label;
          notifyListeners();
        },
      );
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
  }
}
