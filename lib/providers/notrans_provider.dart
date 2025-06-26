import 'package:flutter/foundation.dart';

class NoTransaksiProvider with ChangeNotifier {
  String? _noTransaksi;

  String? get noTransaksi => _noTransaksi;

  void setNoTransaksi(String no) {
    _noTransaksi = no;
    notifyListeners();
  }

  void clear() {
    _noTransaksi = null;
    notifyListeners();
  }
}
