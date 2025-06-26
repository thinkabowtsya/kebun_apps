class Kebunrkhdt {
  String notransaksi;
  String nourut;
  String mandor;
  String kodeblok;
  String statusblok;
  String kodekegiatan;
  String rotasi;
  String target;
  String hkpb;
  String hkkht;
  String hkkhl;
  String hkbor;
  String jmlhtbs;
  String jmlhkgtbs;
  String angkutan;
  String kontan;
  String rpsatuan;

  Kebunrkhdt({
    required this.notransaksi,
    required this.nourut,
    required this.mandor,
    required this.kodeblok,
    required this.statusblok,
    required this.kodekegiatan,
    required this.rotasi,
    required this.target,
    required this.hkpb,
    required this.hkkht,
    required this.hkkhl,
    required this.hkbor,
    required this.jmlhtbs,
    required this.jmlhkgtbs,
    required this.angkutan,
    required this.kontan,
    required this.rpsatuan,
  });

  factory Kebunrkhdt.fromJson(Map<String, dynamic> json) {
    return Kebunrkhdt(
      notransaksi: json['notransaksi'],
      nourut: json['nourut'],
      mandor: json['mandor'],
      kodeblok: json['kodeblok'],
      statusblok: json['statusblok'],
      kodekegiatan: json['kodekegiatan'],
      rotasi: json['rotasi'],
      target: json['target'],
      hkpb: json['hk_pb'],
      hkkht: json['hk_kht'],
      hkkhl: json['hk_khl'],
      hkbor: json['hk_bor'],
      jmlhtbs: json['jmlh_tbs'],
      jmlhkgtbs: json['jmlh_kgtbs'],
      angkutan: json['angkutan'],
      kontan: json['kontan'],
      rpsatuan: json['rpsatuan'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'notransaksi': notransaksi,
      'nourut': nourut,
      'mandor': mandor,
      'kodeblok': kodeblok,
      'statusblok': statusblok,
      'kodekegiatan': kodekegiatan,
      'rotasi': rotasi,
      'target': target,
      'hkpb': hkpb,
      'hkkht': hkkht,
      'hkkhl': hkkhl,
      'hkbor': hkbor,
      'jmlhtbs': jmlhtbs,
      'jmlhkgtbs': jmlhkgtbs,
      'angkutan': angkutan,
      'kontan': kontan,
      'rpsatuan': rpsatuan,
    };
  }
}
