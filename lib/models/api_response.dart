// lib/models/api_response.dart

import 'menu.dart';
import 'user_2.dart';

class ApiResponse {
  List<Menu> menu;
  User user;

  ApiResponse({
    required this.menu,
    required this.user,
  });

  // Factory method to convert JSON to ApiResponse object
  factory ApiResponse.fromJson(Map<String, dynamic> json) {
    var menuList = (json['menu'] as List).map((i) => Menu.fromJson(i)).toList();
    var user = User.fromJson(json['user']);
    return ApiResponse(
      menu: menuList,
      user: user,
    );
  }

  // Method to convert ApiResponse object to JSON
  Map<String, dynamic> toJson() {
    return {
      'menu': menu.map((menuItem) => menuItem.toJson()).toList(),
      'user': user.toJson(),
    };
  }
}
