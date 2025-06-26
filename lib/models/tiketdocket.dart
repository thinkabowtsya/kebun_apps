class Tiketdocket {
  String notransaksi;
  String noreferensi;
  String kodeorg;
  String tph;
  String kebun;
  String nik;
  String sesi;
  String updateby;

  Tiketdocket({
    required this.notransaksi,
    required this.noreferensi,
    required this.kodeorg,
    required this.tph,
    required this.kebun,
    required this.nik,
    required this.sesi,
    required this.updateby,
  });

  factory Tiketdocket.fromJson(Map<String, dynamic> json) {
    return Tiketdocket(
      notransaksi: json['notransaksi'],
      noreferensi: json['noreferensi'],
      kodeorg: json['kodeorg'],
      tph: json['tph'],
      kebun: json['kebun'],
      nik: json['nik'],
      sesi: json['sesi'],
      updateby: json['updateby'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'notransaksi': notransaksi,
      'noreferensi': noreferensi,
      'kodeorg': kodeorg,
      'tph': tph,
      'kebun': kebun,
      'nik': nik,
      'sesi': sesi,
      'updateby': updateby,
    };
  }
}
