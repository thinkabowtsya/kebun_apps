class PurKaryawan {
  String karyawanid;
  String namakaryawan;
  String bagian;
  String nik;
  String tipekaryawan;

  PurKaryawan(
      {required this.karyawanid,
      required this.namakaryawan,
      required this.bagian,
      required this.nik,
      required this.tipekaryawan});

  factory PurKaryawan.fromJson(Map<String, dynamic> json) {
    return PurKaryawan(
      karyawanid: json['karyawanid'],
      namakaryawan: json['namakaryawan'],
      bagian: json['bagian'],
      nik: json['nik'],
      tipekaryawan: json['tipekaryawan'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'karyawanid': karyawanid,
      'namakaryawan': namakaryawan,
      'bagian': bagian,
      'nik': nik,
      'tipekaryawan': tipekaryawan,
    };
  }
}
