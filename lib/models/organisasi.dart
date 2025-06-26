class Organisasi {
  String kodeOrganisasi;
  String induk;
  String namaOrganisasi;
  String tipeOrganisasi;
  String sertifikat;
  String inisialisasiOrganisasi;

  Organisasi({
    required this.kodeOrganisasi,
    required this.induk,
    required this.namaOrganisasi,
    required this.tipeOrganisasi,
    required this.sertifikat,
    required this.inisialisasiOrganisasi,
  });

  factory Organisasi.fromJson(Map<String, dynamic> json) {
    return Organisasi(
      kodeOrganisasi: json['kodeorganisasi'],
      induk: json['induk'],
      namaOrganisasi: json['namaorganisasi'],
      tipeOrganisasi: json['tipe'],
      sertifikat: json['sertifikat'],
      inisialisasiOrganisasi: json['inisialisasiorganisasi'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'kodeorganisasi': kodeOrganisasi,
      'induk': induk,
      'namaorganisasi': namaOrganisasi,
      'tipeorganisasi': tipeOrganisasi,
      'sertifikat': sertifikat,
      'inisialisasiorganisasi': inisialisasiOrganisasi,
    };
  }
}
