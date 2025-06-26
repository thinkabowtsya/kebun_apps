class UserModel {
  final String username;
  final String karyawanid;
  final String namakaryawan;
  final String nik;
  final String tanggallahir;
  final String sistemgaji;
  final String tanggalmasuk;
  final String tipekaryawan;
  final String pt;
  final String bagian;
  final String lokasitugas;
  final String subbagian;
  final String kodegolongan;
  final String kodejabatan;
  final String userid;
  final String keyApi;
  final String datelogin;
  final String explogin;
  final String lang;
  final String logged;

  UserModel({
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
    required this.lang,
    required this.logged,
  });

  get password => null;

  // Mengubah UserModel menjadi Map untuk disimpan di SQLite
  Map<String, dynamic> toMap() {
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
      'lang': lang,
      'logged': logged,
    };
  }

  // Mengubah Map menjadi objek UserModel
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      username: map['username'] ?? '',
      karyawanid: map['karyawanid'] ?? '',
      namakaryawan: map['namakaryawan'] ?? '',
      nik: map['nik'] ?? '',
      tanggallahir: map['tanggallahir'] ?? '',
      sistemgaji: map['sistemgaji'] ?? '',
      tanggalmasuk: map['tanggalmasuk'] ?? '',
      tipekaryawan: map['tipekaryawan'] ?? '',
      pt: map['pt'] ?? '',
      bagian: map['bagian'] ?? '',
      lokasitugas: map['lokasitugas'] ?? '',
      subbagian: map['subbagian'] ?? '',
      kodegolongan: map['kodegolongan'] ?? '',
      kodejabatan: map['kodejabatan'] ?? '',
      userid: map['userid'] ?? '',
      keyApi: map['key_api'] ?? '',
      datelogin: map['datelogin'] ?? '',
      explogin: map['explogin'] ?? '',
      lang: map['lang'] ?? '',
      logged: map['logged'] ?? '',
    );
  }
}
