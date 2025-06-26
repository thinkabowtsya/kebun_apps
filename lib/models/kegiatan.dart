class Kegiatan {
  String kodekegiatan;
  String namakegiatan;
  String satuan;
  String kelompok;
  String noakun;
  String premi;

  Kegiatan({
    required this.kodekegiatan,
    required this.namakegiatan,
    required this.satuan,
    required this.kelompok,
    required this.noakun,
    required this.premi,
  });

  factory Kegiatan.fromJson(Map<String, dynamic> json) {
    return Kegiatan(
      kodekegiatan: json['kodekegiatan'],
      namakegiatan: json['namakegiatan'],
      satuan: json['satuan'],
      kelompok: json['kelompok'],
      noakun: json['noakun'],
      premi: json['premi'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'kodekegiatan': kodekegiatan,
      'namakegiatan': namakegiatan,
      'satuan': satuan,
      'kelompok': kelompok,
      'noakun': noakun,
      'premi': premi,
    };
  }
}
