class Saldobulanan {
  String kodeorg;
  String kodebarang;
  String saldoakhirqty;
  String kodegudang;

  Saldobulanan({
    required this.kodeorg,
    required this.kodebarang,
    required this.saldoakhirqty,
    required this.kodegudang,
  });

  factory Saldobulanan.fromJson(Map<String, dynamic> json) {
    return Saldobulanan(
      kodeorg: json['kodeorg'],
      kodebarang: json['kodebarang'],
      saldoakhirqty: json['saldoakhirqty'],
      kodegudang: json['kodegudang'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'kodeorg': kodeorg,
      'kodebarang': kodebarang,
      'saldoakhirqty': saldoakhirqty,
      'kodegudang': kodegudang,
    };
  }
}
