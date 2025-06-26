class Kendaraan {
  String kodeVhc;
  String nopol;
  String detailvhc;

  Kendaraan({
    required this.kodeVhc,
    required this.nopol,
    required this.detailvhc,
  });

  factory Kendaraan.fromJson(Map<String, dynamic> json) {
    return Kendaraan(
      kodeVhc: json['kodevhc'],
      nopol: json['nopol'],
      detailvhc: json['detailvhc'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'kodevhc': kodeVhc,
      'nopopl': nopol,
    };
  }
}
