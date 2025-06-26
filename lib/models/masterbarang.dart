class Masterbarang {
  String kodeBarang;
  String namaBarang;
  String satuan;

  Masterbarang({
    required this.kodeBarang,
    required this.namaBarang,
    required this.satuan,
  });

  factory Masterbarang.fromJson(Map<String, dynamic> json) {
    return Masterbarang(
      kodeBarang: json['kodebarang'],
      namaBarang: json['namabarang'],
      satuan: json['satuan'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'kodeBarang': kodeBarang,
      'namabarang': namaBarang,
      'satuan': satuan,
    };
  }
}
