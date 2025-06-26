class Kebunrkhdtmaterial {
  String notransaksi;
  String nourut;
  String kodebarang;
  String jumlah;
  String cu;

  Kebunrkhdtmaterial({
    required this.notransaksi,
    required this.nourut,
    required this.kodebarang,
    required this.jumlah,
    required this.cu,
  });

  factory Kebunrkhdtmaterial.fromJson(Map<String, dynamic> json) {
    return Kebunrkhdtmaterial(
      notransaksi: json['notransaksi'],
      nourut: json['nourut'],
      kodebarang: json['kodebarang'],
      jumlah: json['jumlah'],
      cu: json['cu'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'notransaksi': notransaksi,
      'nourut': nourut,
      'kodebarang': kodebarang,
      'jumlah': jumlah,
      'cu': cu,
    };
  }
}
