class SdmAbsensi {
  String kodeabsen;
  String keterangan;
  String kelompok;
  String nilaihk;
  String pengali;

  SdmAbsensi({
    required this.kodeabsen,
    required this.keterangan,
    required this.kelompok,
    required this.nilaihk,
    required this.pengali,
  });

  factory SdmAbsensi.fromJson(Map<String, dynamic> json) {
    return SdmAbsensi(
      kodeabsen: json['kodeabsen'],
      keterangan: json['keterangan'],
      kelompok: json['kelompok'],
      nilaihk: json['nilaihk'],
      pengali: json['pengali'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'kodeabsen': kodeabsen,
      'keterangan': keterangan,
      'kelompok': kelompok,
      'nilaihk': nilaihk,
      'pengali': pengali,
    };
  }
}
