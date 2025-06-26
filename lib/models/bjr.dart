class Bjr {
  String kodeorg;
  String kelaspohon;
  String bjr;
  String tahunproduksi;

  Bjr({
    required this.kodeorg,
    required this.kelaspohon,
    required this.bjr,
    required this.tahunproduksi,
  });

  factory Bjr.fromJson(Map<String, dynamic> json) {
    return Bjr(
      kodeorg: json['kodeorg'],
      kelaspohon: json['kelaspohon'],
      bjr: json['bjr'],
      tahunproduksi: json['tahunproduksi'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'kodeorg': kodeorg,
      'kelaspohon': kelaspohon,
      'bjr': bjr,
      'tahunproduksi': tahunproduksi,
    };
  }
}
