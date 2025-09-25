// lib/services/user_service.dart
import 'dart:convert';
import 'package:flutter_application_3/models/user.dart';
import 'package:flutter_application_3/services/constant.dart';
import 'package:flutter_application_3/services/db_helper.dart';
import 'package:flutter_application_3/services/helper.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class UserRepository {
  var apiUrl = ApiConstants.apiBaseUrl;
  var ip = ApiConstants.ip;
  final DBHelper dbHelper = DBHelper();
  List<Map<String, dynamic>> _userList = [];

  Map<String, dynamic>? _lastLoginData;

  /// Login: ambil data user (dan menu) dari server, simpan user ke SQLite & prefs,
  /// serta simpan menu ke DB lokal (jika tersedia).
  Future<bool> login(String username, String password) async {
    final url = Uri.parse(
      '$apiUrl/owlMobile.php?method=getprofile2&username=$username&password=$password',
    );

    try {
      final response = await http.get(url).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _lastLoginData = data; // simpan response supaya bisa diakses Provider

        final user = data['user'];
        if (user != null) {
          _userList = [Map<String, dynamic>.from(user)];

          // simpan user ke DB lokal
          await _saveUsersToDatabase(username, password);

          // simpan menu ke DB lokal jika ada
          if (data['menu'] != null) {
            try {
              await dbHelper
                  .insertMenuMobileBatch(List<dynamic>.from(data['menu']));
            } catch (e) {
              print('Gagal simpan menu ke DB: $e');
            }
          }

          // simpan beberapa info user ke SharedPreferences
          await _saveUserToSharedPreferences();
          return true;
        }
      }
      return false;
    } catch (e) {
      print("Error during login: $e");
      return false;
    }
  }

  Map<String, dynamic>? getLastLoginData() => _lastLoginData;

  Future<void> _saveUsersToDatabase(String username, String password) async {
    for (var userMap in _userList) {
      UserModel user = UserModel.fromMap(userMap);
      // Sesuaikan insertUser signature di DBHelper (kamu sebelumnya memakai insertUser(user, username, password))
      await dbHelper.insertUser(user, username, password);
    }
  }

  Future<void> _saveUserToSharedPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    String tanggalLogin = getTanggalx();
    Map<String, String> configIp = getConfigPath(ip);
    String server = configIp['http']! + ip + configIp['path']!;

    for (var userMap in _userList) {
      UserModel user = UserModel.fromMap(userMap);

      // Menyimpan hasil ke SharedPreferences
      await prefs.setString('server', server);
      await prefs.setString('username', user.username);
      await prefs.setString('karyawanid', user.karyawanid);
      await prefs.setString('namakaryawan', user.namakaryawan);
      await prefs.setString('nik', user.nik);
      await prefs.setString('tanggallahir', user.tanggallahir);
      await prefs.setString('sistemgaji', user.sistemgaji);
      await prefs.setString('tanggalmasuk', user.tanggalmasuk);
      await prefs.setString('tipekaryawan', user.tipekaryawan);
      await prefs.setString('pt', user.pt);
      await prefs.setString('bagian', user.bagian);
      await prefs.setString('lokasitugas', user.lokasitugas);
      await prefs.setString('subbagian', user.subbagian);
      await prefs.setString('kodegolongan', user.kodegolongan);
      await prefs.setString('kodejabatan', user.kodejabatan);
      await prefs.setString('userid', user.userid);
      await prefs.setString('keyApi', user.keyApi);
      await prefs.setString('datelogin', user.datelogin);
      await prefs.setString('explogin', user.explogin);
      await prefs.setString('lang', user.lang);
      await prefs.setString('logged', tanggalLogin);
    }
  }

  Future<List<Map<String, dynamic>>> getMenuFromDb(String username) async {
    return await dbHelper.getMenuMobileItems();
  }
}
