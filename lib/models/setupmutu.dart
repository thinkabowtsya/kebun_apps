class MutuAncak {
  String idjenis;
  String kodemutu;
  String jenis;
  String namamutu;
  String satuan;
  String satuan2;

  MutuAncak({
    required this.idjenis,
    required this.kodemutu,
    required this.jenis,
    required this.namamutu,
    required this.satuan,
    required this.satuan2,
  });

  factory MutuAncak.fromJson(Map<String, dynamic> json) {
    return MutuAncak(
      idjenis: json['idjenis'] ?? '',
      kodemutu: json['kodemutu'] ?? '',
      jenis: json['jenis'] ?? '',
      namamutu: json['namamutu'] ?? '',
      satuan: json['satuan'] ?? '',
      satuan2: json['satuan2'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idjenis': idjenis,
      'kodemutu': kodemutu,
      'jenis': jenis,
      'namamutu': namamutu,
      'satuan': satuan,
      'satuan2': satuan2,
    };
  }
}
