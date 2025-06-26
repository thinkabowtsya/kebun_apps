// import 'package:flutter_application_3/models/api_response.dart';
// import 'package:flutter_application_3/models/user.dart';
import 'package:flutter_application_3/models/user.dart';
import 'package:flutter_application_3/services/constant.dart';
import 'package:flutter_application_3/services/db_helper.dart';
import 'package:flutter_application_3/services/helper.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class UserRepository {
  var apiUrl = ApiConstants.apiBaseUrl;
  var ip = ApiConstants.ip;
  final DBHelper dbHelper = DBHelper();
  List<Map<String, dynamic>> _userList = [];

  // Fetch users from SQLite or API
  // Future<List<User>> getUsers() async {
  //   // First check SQLite
  //   List<User> localUsers = await dbHelper.fetchUsers();
  //   if (localUsers.isNotEmpty) {
  //     return localUsers;
  //   }

  //   const url = 'https://jsonplaceholder.typicode.com/users';
  //   final response = await http.get(Uri.parse(url));

  //   if (response.statusCode == 200) {
  //     final List<dynamic> data = json.decode(response.body);
  //     List<User> users = data.map((item) => User.fromJson(item)).toList();

  //     // Store users to SQLite
  //     for (var user in users) {
  //       dbHelper.insertUser(user);
  //     }

  //     return users;
  //   } else {
  //     throw Exception('Failed to load users');
  //   }
  // }

  Future<bool> login(String username, String password) async {
    print(apiUrl);
    final url = Uri.parse(
        '$apiUrl/owlMobile.php?method=getprofile2&username=$username&password=$password');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['user'] != null) {
          _userList = [Map<String, dynamic>.from(data['user'])];

          await _saveUsersToDatabase(username, password);
          await _saveUserToSharedPreferences();
          return true;
        }
      }
      return false; // Login gagal
    } catch (e) {
      
      print("Error during login: $e");
      return false;
    }
  }

  Future<void> _saveUsersToDatabase(String username, String password) async {
    for (var userMap in _userList) {
      UserModel user = UserModel.fromMap(userMap);

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

  // // Add user to SQLite and API
  // Future<void> addUser(User user) async {
  //   const url = 'https://jsonplaceholder.typicode.com/users';
  //   final response = await http.post(
  //     Uri.parse(url),
  //     headers: {'Content-Type': 'application/json'},
  //     body: json.encode(user.toJson()),
  //   );

  //   if (response.statusCode == 201) {
  //     dbHelper.insertUser(user);
  //   } else {
  //     throw Exception('Failed to add user');
  //   }
  // }

  // // Update user in SQLite and API
  // Future<void> updateUser(User user) async {
  //   final url = 'https://jsonplaceholder.typicode.com/users/${user.id}';
  //   final response = await http.put(
  //     Uri.parse(url),
  //     headers: {'Content-Type': 'application/json'},
  //     body: json.encode(user.toJson()),
  //   );

  //   if (response.statusCode == 200) {
  //     dbHelper.updateUser(user);
  //   } else {
  //     throw Exception('Failed to update user');
  //   }
  // }

  // // Delete user from SQLite and API
  // Future<void> deleteUser(int id) async {
  //   final url = 'https://jsonplaceholder.typicode.com/users/$id';
  //   final response = await http.delete(Uri.parse(url));

  //   if (response.statusCode == 200) {
  //     dbHelper.deleteUser(id);
  //   } else {
  //     throw Exception('Failed to delete user');
  //   }
  // }
}
