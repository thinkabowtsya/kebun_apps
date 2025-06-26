// lib/models/menu.dart

class Menu {
  String id;
  String icon;
  String type;
  String caption;
  String caption2;
  String caption3;
  String action;
  String formjs;
  String parent;
  String urut;
  String hide;

  Menu({
    required this.id,
    required this.icon,
    required this.type,
    required this.caption,
    required this.caption2,
    required this.caption3,
    required this.action,
    required this.formjs,
    required this.parent,
    required this.urut,
    required this.hide,
  });

  // Factory method to convert JSON to Menu object
  factory Menu.fromJson(Map<String, dynamic> json) {
    return Menu(
      id: json['id'].toString(),
      icon: json['icon'],
      type: json['type'],
      caption: json['caption'],
      caption2: json['caption2'],
      caption3: json['caption3'],
      action: json['action'],
      formjs: json['formjs'],
      parent: json['parent'].toString(),
      urut: json['urut'].toString(),
      hide: json['hide'].toString(),
    );
  }

  // Method to convert Menu object to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'icon': icon,
      'type': type,
      'caption': caption,
      'caption2': caption2,
      'caption3': caption3,
      'action': action,
      'formjs': formjs,
      'parent': parent,
      'urut': urut,
      'hide': hide,
    };
  }
}
