class SetupApproval {
  String kodeunit;
  String kodeapproval;
  String level;
  String applikasi;
  String karyawanid;
  String namakaryawan;
  String nik;

  SetupApproval({
    required this.kodeunit,
    required this.kodeapproval,
    required this.level,
    required this.applikasi,
    required this.karyawanid,
    required this.namakaryawan,
    required this.nik,
  });

  factory SetupApproval.fromJson(Map<String, dynamic> json) {
    return SetupApproval(
      kodeunit: json['kodeunit'],
      kodeapproval: json['kodeapproval'],
      level: json['level'],
      applikasi: json['applikasi'],
      karyawanid: json['karyawanid'],
      namakaryawan: json['namakaryawan'],
      nik: json['nik'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'kodeunit': kodeunit,
      'kodeapproval': kodeapproval,
      'level': level,
      'applikasi': applikasi,
      'karyawanid': karyawanid,
      'namakaryawan': namakaryawan,
      'nik': nik,
    };
  }
}
