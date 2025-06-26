class Kebunrkhht {
  String notransaksi;
  String asisten;
  String tanggal;
  String divisi;

  Kebunrkhht({
    required this.notransaksi,
    required this.asisten,
    required this.tanggal,
    required this.divisi,
  });

  factory Kebunrkhht.fromJson(Map<String, dynamic> json) {
    return Kebunrkhht(
      notransaksi: json['notransaksi'],
      asisten: json['asisten'],
      tanggal: json['tanggal'],
      divisi: json['divisi'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'notransaksi': notransaksi,
      'asisten': asisten,
      'tanggal': tanggal,
      'divisi': divisi,
    };
  }
}
