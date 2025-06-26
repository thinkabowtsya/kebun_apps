import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_application_3/models/user.dart';
import 'package:flutter_application_3/services/user_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_application_3/services/constant.dart';

class UserProvider with ChangeNotifier {
  var apiUrl = ApiConstants.apiBaseUrl;
  final List<UserModel> _users = [];

  final UserRepository userRepository = UserRepository();

  List<UserModel> get users => _users;
  List<dynamic> _menuItems = [];

  bool _isLoggedIn = false;
  String _username = '';
  final String _password = '';

  bool get isLoggedIn => _isLoggedIn;
  String get username => _username;
  String get password => _password;

  List<dynamic> get menuItems => _menuItems;

  UserProvider() {
    _loadUserData();
  }

  _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    _username = prefs.getString('username') ?? '';

    notifyListeners();
  }

  Future<void> login(String username, String password) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    bool isLoginSuccessful = await userRepository.login(username, password);
   
    if (isLoginSuccessful) {
      _username = username;
      _isLoggedIn = true;

      await prefs.setString('username', username);
      await prefs.setBool('isLoggedIn', true);

      await getMenu(username, password);

      notifyListeners();
    } else {
      _username = '';
      _isLoggedIn = false;

      await prefs.setBool('isLoggedIn', false);

      notifyListeners();
    }
  }

  Future<List> getMenu(String username, String password) async {
    final url = Uri.parse(
        '$apiUrl/owlMobile.php?method=getprofile2&username=$username&password=$password');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Mendapatkan data menu dan menyimpannya ke _menuItems
        _menuItems = List<Map<String, dynamic>>.from(data['menu']);

        return _menuItems;
      } else {
        throw Exception('Failed to load menu');
      }
    } catch (e) {
      print("Error during menu fetch: $e");
      rethrow;
    }
  }

  // // Fungsi untuk logout
  void logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    _username = '';
    _isLoggedIn = false;

    // Hapus data yang ada di SharedPreferences
    await prefs.remove('username');
    await prefs.remove('isLoggedIn');

    notifyListeners();
  }

  // Future<void> fetchUsers() async {
  //   _users = await userRepository.getUsers();
  //   notifyListeners();
  // }

  // Future<void> addUser(User user) async {
  //   await userRepository.addUser(user);
  //   _users.add(user);
  //   notifyListeners();
  // }

  // Future<void> updateUser(User user) async {
  //   await userRepository.updateUser(user);
  //   int index = _users.indexWhere((u) => u.id == user.id);
  //   if (index != -1) {
  //     _users[index] = user;
  //   }
  //   notifyListeners();
  // }

  // Future<void> deleteUser(int id) async {
  //   await userRepository.deleteUser(id);
  //   _users.removeWhere((user) => user.id == id);
  //   notifyListeners();
  // }
}
