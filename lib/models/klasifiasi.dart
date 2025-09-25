class Klasifikasi {
  final String kodeklasifikasi;
  final String namaklasifikasi;
  final String tipeklasifikasi;

  Klasifikasi({
    required this.kodeklasifikasi,
    required this.namaklasifikasi,
    required this.tipeklasifikasi,
  });

  /// Factory untuk parsing dari JSON
  factory Klasifikasi.fromJson(Map<String, dynamic> json) {
    // Debug optional, bisa dihapus kalau sudah yakin aman
    // print('Parsing Klasifikasi: $json');

    return Klasifikasi(
      kodeklasifikasi: (json['kodeklasifikasi'] ?? '').toString(),
      namaklasifikasi: (json['namaklasifikasi'] ?? '').toString(),
      tipeklasifikasi: (json['tipeklasifikasi'] ?? '').toString(),
    );
  }

  /// Konversi ke JSON
  Map<String, dynamic> toJson() {
    return {
      'kodeklasifikasi': kodeklasifikasi,
      'namaklasifikasi': namaklasifikasi,
      'tipeklasifikasi': tipeklasifikasi,
    };
  }

  /// Tambahan opsional: copyWith untuk update sebagian field
  Klasifikasi copyWith({
    String? kodeklasifikasi,
    String? namaklasifikasi,
    String? tipeklasifikasi,
  }) {
    return Klasifikasi(
      kodeklasifikasi: kodeklasifikasi ?? this.kodeklasifikasi,
      namaklasifikasi: namaklasifikasi ?? this.namaklasifikasi,
      tipeklasifikasi: tipeklasifikasi ?? this.tipeklasifikasi,
    );
  }

  @override
  String toString() =>
      'Klasifikasi(kode: $kodeklasifikasi, nama: $namaklasifikasi, tipe: $tipeklasifikasi)';
}
