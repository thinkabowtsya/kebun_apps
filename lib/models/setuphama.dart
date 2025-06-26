class Setuphama {
  String kodehama;
  String namahama;
  String satuan;

  Setuphama({
    required this.kodehama,
    required this.namahama,
    required this.satuan,
  });

  factory Setuphama.fromJson(Map<String, dynamic> json) {
    return Setuphama(
      kodehama: json['kodehama'],
      namahama: json['namahama'],
      satuan: json['satuan'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'kodehama': kodehama,
      'namahama': namahama,
      'satuan': satuan,
    };
  }
}
