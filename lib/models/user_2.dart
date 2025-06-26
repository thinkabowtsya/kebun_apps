// lib/models/user.dart

class User {
  String username;
  String karyawanid;
  String namakaryawan;
  String nik;
  String tanggallahir;
  String sistemgaji;
  String tanggalmasuk;
  String tipekaryawan;
  String pt;
  String bagian;
  String lokasitugas;
  String subbagian;
  String kodegolongan;
  String kodejabatan;
  String userid;
  String keyApi;
  String datelogin;
  String explogin;
  String regional;
  String logged;

  User({
    required this.username,
    required this.karyawanid,
    required this.namakaryawan,
    required this.nik,
    required this.tanggallahir,
    required this.sistemgaji,
    required this.tanggalmasuk,
    required this.tipekaryawan,
    required this.pt,
    required this.bagian,
    required this.lokasitugas,
    required this.subbagian,
    required this.kodegolongan,
    required this.kodejabatan,
    required this.userid,
    required this.keyApi,
    required this.datelogin,
    required this.explogin,
    required this.regional,
    required this.logged,
  });

  // Factory method to convert JSON to User object
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      username: json['username'],
      karyawanid: json['karyawanid'],
      namakaryawan: json['namakaryawan'],
      nik: json['nik'],
      tanggallahir: json['tanggallahir'],
      sistemgaji: json['sistemgaji'],
      tanggalmasuk: json['tanggalmasuk'],
      tipekaryawan: json['tipekaryawan'],
      pt: json['pt'],
      bagian: json['bagian'],
      lokasitugas: json['lokasitugas'],
      subbagian: json['subbagian'],
      kodegolongan: json['kodegolongan'],
      kodejabatan: json['kodejabatan'],
      userid: json['userid'],
      keyApi: json['key_api'],
      datelogin: json['datelogin'],
      explogin: json['explogin'],
      regional: json['regional'],
      logged: json['logged'].toString(),
    );
  }

  // Method to convert User object to JSON
  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'karyawanid': karyawanid,
      'namakaryawan': namakaryawan,
      'nik': nik,
      'tanggallahir': tanggallahir,
      'sistemgaji': sistemgaji,
      'tanggalmasuk': tanggalmasuk,
      'tipekaryawan': tipekaryawan,
      'pt': pt,
      'bagian': bagian,
      'lokasitugas': lokasitugas,
      'subbagian': subbagian,
      'kodegolongan': kodegolongan,
      'kodejabatan': kodejabatan,
      'userid': userid,
      'key_api': keyApi,
      'datelogin': datelogin,
      'explogin': explogin,
      'regional': regional,
      'logged': logged,
    };
  }
}
