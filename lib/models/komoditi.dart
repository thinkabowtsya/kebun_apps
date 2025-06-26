class Komoditi {
  String kodecustomer;
  String kodebarang;
  String kodekomoditi;

  Komoditi(
      {required this.kodecustomer,
      required this.kodebarang,
      required this.kodekomoditi});

  factory Komoditi.fromJson(Map<String, dynamic> json) {
    return Komoditi(
      kodecustomer: json['kodecustomer'],
      kodebarang: json['kodebarang'],
      kodekomoditi: json['kodekomoditi'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'kodecustomer': kodecustomer,
      'kodebarang': kodebarang,
      'kodekomoditi': kodekomoditi,
    };
  }
}
