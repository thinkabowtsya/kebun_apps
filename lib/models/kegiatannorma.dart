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
    // print('kegiatan norma $json');
    return KegiatanNorma(
      kodekegiatan: (json['kodekegiatan'] ?? '').toString(),
      kelompok: (json['kelompok'] ?? '').toString(),
      tipeanggaran: (json['tipeanggaran'] ?? '').toString(),
      kodebarang: (json['kodebarang'] ?? '').toString(),
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
