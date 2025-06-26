class KodeDendaPanen {
  String iddenda;
  String kodedenda;
  String deskripsi;
  String satuan;
  String lockjjg;
  String nourut;

  KodeDendaPanen(
      {required this.iddenda,
      required this.kodedenda,
      required this.deskripsi,
      required this.satuan,
      required this.lockjjg,
      required this.nourut});

  factory KodeDendaPanen.fromJson(Map<String, dynamic> json) {
    return KodeDendaPanen(
      iddenda: json['iddenda'],
      kodedenda: json['kodedenda'],
      deskripsi: json['deskripsi'],
      satuan: json['satuan'],
      lockjjg: json['lockjjg'],
      nourut: json['nourut'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'iddenda': iddenda,
      'kodedenda': kodedenda,
      'deskripsi': deskripsi,
      'satuan': satuan,
      'lockjjg': lockjjg,
      'nourut': nourut,
    };
  }
}
