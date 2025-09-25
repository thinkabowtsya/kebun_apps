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
  String _password = '';

  bool get isLoggedIn => _isLoggedIn;
  String get username => _username;
  String get password => _password;

  List<dynamic> get menuItems => _menuItems;

  // Hapus pemanggilan _loadUserData di konstruktor — andalkan restoreSession() di AppGate
  UserProvider();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<bool> login(String username, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();

      final isLoginSuccessful = await userRepository.login(username, password);

      if (isLoginSuccessful) {
        _username = username;
        _password = password;
        _isLoggedIn = true;

        await prefs.setString('username', username);
        await prefs.setString('password', password);
        await prefs.setBool('isLoggedIn', true);

        // ambil menu dari repository setelah login sukses
        final data = await userRepository.getLastLoginData();
        if (data != null && data['menu'] != null) {
          _menuItems = List<Map<String, dynamic>>.from(data['menu']);
        }

        notifyListeners();
        return true;
      } else {
        _username = '';
        _isLoggedIn = false;
        await prefs.setBool('isLoggedIn', false);
        await prefs.remove('username');
        _menuItems = [];
        notifyListeners();
        return false;
      }
    } catch (e) {
      _username = '';
      _isLoggedIn = false;
      _menuItems = [];
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> restoreSession() async {
    _isLoading = true;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      final u = prefs.getString('username') ?? '';
      final ok = prefs.getBool('isLoggedIn') ?? false;

      if (ok && u.isNotEmpty) {
        _username = u;
        _isLoggedIn = true;

        // Coba muat menu dari DB lokal (userRepository harus menyediakan getMenuFromDb)
        try {
          final menuFromDb = await userRepository.getMenuFromDb(u);
          if (menuFromDb != null) {
            _menuItems = List<Map<String, dynamic>>.from(menuFromDb);
          } else {
            _menuItems = [];
          }
        } catch (e) {
          _menuItems = [];
        }
      } else {
        _username = '';
        _isLoggedIn = false;
        _menuItems = [];
      }
    } catch (e) {
      _username = '';
      _isLoggedIn = false;
      _menuItems = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<List> getMenuFromDb(String username) async {
    try {
      final items = await userRepository.getMenuFromDb(
          username); // jika repo memanggil dbHelper.getMenuMobileItems()
      _menuItems = List<Map<String, dynamic>>.from(items);
      notifyListeners();
      return _menuItems;
    } catch (e) {
      _menuItems = [];
      notifyListeners();
      rethrow;
    }
  }

  // Future<List> getMenu(String username, String password) async {
  //   final url = Uri.parse(
  //       '$apiUrl/owlMobile.php?method=getprofile2&username=$username&password=$password');

  //   try {
  //     final response = await http.get(url);

  //     if (response.statusCode == 200) {
  //       final data = jsonDecode(response.body);

  //       // Mendapatkan data menu dan menyimpannya ke _menuItems
  //       _menuItems = List<Map<String, dynamic>>.from(data['menu']);

  //       return _menuItems;
  //     } else {
  //       throw Exception('Failed to load menu');
  //     }
  //   } catch (e) {
  //     print("Error during menu fetch: $e");
  //     rethrow;
  //   }
  // }

  // logout sekarang juga membersihkan menu, dan (opsional) menu di DB via repository
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();

    _username = '';
    _isLoggedIn = false;
    _menuItems = [];

    // Hapus data di SharedPreferences
    await prefs.remove('username');
    await prefs.remove('isLoggedIn');

    // Bersihkan menu di DB (opsional, tapi direkomendasikan)
    try {
      await userRepository.dbHelper.clearMenuMobile();
    } catch (e) {
      debugPrint("Gagal clear menu di DB saat logout: $e");
    }

    notifyListeners();
  }
}
