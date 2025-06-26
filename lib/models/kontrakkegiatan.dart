class KontrakKegiatan {
  String notransaksi;
  String supplierid;
  String namasupplier;
  String kodekegiatan;
  String divisi;
  String kodeblok;
  String satuan;
  String dari;
  String sampai;

  KontrakKegiatan(
      {required this.notransaksi,
      required this.supplierid,
      required this.namasupplier,
      required this.kodekegiatan,
      required this.divisi,
      required this.kodeblok,
      required this.satuan,
      required this.dari,
      required this.sampai});

  factory KontrakKegiatan.fromJson(Map<String, dynamic> json) {
    return KontrakKegiatan(
      notransaksi: json['notransaksi'],
      supplierid: json['supplierid'],
      namasupplier: json['namasupplier'],
      kodekegiatan: json['kodekegiatan'],
      divisi: json['divisi'],
      kodeblok: json['kodeblok'],
      satuan: json['satuan'],
      dari: json['dari'],
      sampai: json['sampai'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'notransaksi': notransaksi,
      'supplierid': supplierid,
      'namasupplier': namasupplier,
      'kodekegiatan': kodekegiatan,
      'divisi': divisi,
      'kodeblok': kodeblok,
      'satuan': satuan,
      'dari': dari,
      'sampai': sampai,
    };
  }
}
