class Klasifikasi {
  String kodeklasifikasi;
  String namaklasifikasi;
  String tipeklasifikasi;

  Klasifikasi(
      {required this.kodeklasifikasi,
      required this.namaklasifikasi,
      required this.tipeklasifikasi});

  factory Klasifikasi.fromJson(Map<String, dynamic> json) {
    return Klasifikasi(
      kodeklasifikasi: json['kodeklasifikasi'],
      namaklasifikasi: json['namaklasifikasi'],
      tipeklasifikasi: json['tipeklasifikasi'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'kodeklasifikasi': kodeklasifikasi,
      'namaklasifikasi': namaklasifikasi,
      'tipeklasifikasi': tipeklasifikasi,
    };
  }
}
