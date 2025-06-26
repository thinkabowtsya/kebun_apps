class DendaPanen {
  String kodeorg;
  String kodedenda;
  String jenisdenda;
  String denda;

  DendaPanen({
    required this.kodeorg,
    required this.kodedenda,
    required this.jenisdenda,
    required this.denda,
  });

  factory DendaPanen.fromJson(Map<String, dynamic> json) {
    return DendaPanen(
      kodeorg: json['kodeorg'],
      kodedenda: json['kodedenda'],
      jenisdenda: json['jenisdenda'],
      denda: json['denda'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'kodeorg': kodeorg,
      'kodedenda': kodedenda,
      'jenisdenda': jenisdenda,
      'denda': denda,
    };
  }
}
