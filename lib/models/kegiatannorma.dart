class KegiatanNorma {
  String kodekegiatan;
  String kelompok;
  String tipeanggaran;
  String kodebarang;

  KegiatanNorma(
      {required this.kodekegiatan,
      required this.kelompok,
      required this.tipeanggaran,
      required this.kodebarang});

  factory KegiatanNorma.fromJson(Map<String, dynamic> json) {
    return KegiatanNorma(
      kodekegiatan: json['kodekegiatan'],
      kelompok: json['kelompok'],
      tipeanggaran: json['tipeanggaran'],
      kodebarang: json['kodebarang'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'kodekegiatan': kodekegiatan,
      'kelompok': kelompok,
      'tipeanggaran': tipeanggaran,
      'kodebarang': kodebarang,
    };
  }
}
