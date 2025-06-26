class Ijin {
  String karyawanid;
  // String namakaryawan;
  String tanggal;
  String keperluan;
  String keterangan;
  String persetujuan1;
  // String namapersetujuan1;
  String stpersetujuan1;
  String komenst1;
  String waktupengajuan;
  String jenisijin;
  String hrd;
  // String namahrd;
  String stpersetujuanhrd;
  String periodecuti;
  String darijam;
  String sampaijam;
  String jumlahhari;
  String komenst2;

  Ijin(
      {required this.karyawanid,
      // required this.namakaryawan,
      required this.tanggal,
      required this.keperluan,
      required this.keterangan,
      required this.persetujuan1,
      // required this.namapersetujuan1,
      required this.stpersetujuan1,
      required this.komenst1,
      required this.waktupengajuan,
      required this.jenisijin,
      required this.hrd,
      // required this.namahrd,
      required this.stpersetujuanhrd,
      required this.periodecuti,
      required this.darijam,
      required this.sampaijam,
      required this.jumlahhari,
      required this.komenst2});

  factory Ijin.fromJson(Map<String, dynamic> json) {
    return Ijin(
      karyawanid: json['karyawanid'] ?? '',
      tanggal: json['tanggal'] ?? '',
      keperluan: json['keperluan'] ?? '',
      keterangan: json['keterangan'] ?? '',
      persetujuan1: json['persetujuan1'] ?? '',
      stpersetujuan1: json['stpersetujuan1'] ?? '',
      komenst1: json['komenst1'] ?? '',
      waktupengajuan: json['waktupengajuan'] ?? '',
      jenisijin: json['jenisijin'] ?? '',
      hrd: json['hrd'] ?? '',
      stpersetujuanhrd: json['stpersetujuanhrd'] ?? '',
      periodecuti: json['periodecuti'] ?? '',
      darijam: json['darijam'] ?? '',
      sampaijam: json['sampaijam'] ?? '',
      jumlahhari: json['jumlahhari'] ?? '',
      komenst2: json['komenst2'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'karyawanid': karyawanid,
      // 'namakaryawan': namakaryawan,
      'tanggal': tanggal,
      'keperluan': keperluan,
      'keterangan': keterangan,
      'persetujuan1': persetujuan1,
      // 'namapersetujuan1': namapersetujuan1,
      'stpersetujuan1': stpersetujuan1,
      'komenst1': komenst1,
      'waktupengajuan': waktupengajuan,
      'jenisijin': jenisijin,
      'hrd': hrd,
      // 'namahrd': namahrd,
      'stpersetujuanhrd': stpersetujuanhrd,
      'periodecuti': periodecuti,
      'darijam': darijam,
      'sampaijam': sampaijam,
      'jumlahhari': jumlahhari,
      'komenst2': komenst2,
    };
  }
}
