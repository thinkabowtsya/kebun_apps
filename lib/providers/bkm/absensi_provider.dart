import 'package:flutter/material.dart';
import 'package:flutter_application_3/services/db_helper.dart';

class AbsensiProvider with ChangeNotifier {
  final DBHelper _dbHelper = DBHelper();

  List<Map<String, dynamic>> _absensiList = [];

  List<Map<String, dynamic>> get absensiList => _absensiList;
}
