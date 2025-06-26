class Karyawan {
  final String karyawanid;
  final String nik;
  final String lokasitugas;
  final String subbagian;
  final String namakaryawan;
  final String namakaryawan2;
  final String tipekaryawan;
  final String namajabatan;
  final String kodejabatan;
  final String pemanen;
  final String perawatan;
  final String kemandoran;
  final String gajipokok;

  Karyawan({
    required this.karyawanid,
    required this.nik,
    required this.lokasitugas,
    required this.subbagian,
    required this.namakaryawan,
    required this.namakaryawan2,
    required this.tipekaryawan,
    required this.namajabatan,
    required this.kodejabatan,
    required this.pemanen,
    required this.perawatan,
    required this.kemandoran,
    required this.gajipokok,
  });

  // Factory method to convert from JSON (Map<String, dynamic>)
  factory Karyawan.fromJson(Map<String, dynamic> json) {
    return Karyawan(
      karyawanid: json['karyawanid'].toString(),
      nik: json['nik'].toString(),
      lokasitugas: json['lokasitugas'].toString(),
      subbagian: json['subbagian'].toString(),
      namakaryawan: json['namakaryawan'].toString(),
      namakaryawan2: json['namakaryawan2'].toString(),
      tipekaryawan: json['tipekaryawan'].toString(),
      namajabatan: json['namajabatan'].toString(),
      kodejabatan: json['kodejabatan'].toString(),
      pemanen: (json['pemanen'] ?? 0).toString(), // Convert int to String
      perawatan: (json['perawatan'] ?? 0).toString(), // Convert int to String
      kemandoran: json['kemandoran'] ?? '',
      gajipokok: (json['gajipokok'] ?? 0).toString(), // Convert int to String
    );
  }

  // Method to convert to JSON format (Map<String, dynamic>)
  Map<String, dynamic> toJson() {
    return {
      'karyawanid': karyawanid,
      'nik': nik,
      'lokasitugas': lokasitugas,
      'subbagian': subbagian,
      'namakaryawan': namakaryawan,
      'namakaryawan2': namakaryawan2,
      'tipekaryawan': tipekaryawan,
      'namajabatan': namajabatan,
      'kodejabatan': kodejabatan,
      'pemanen': pemanen,
      'perawatan': perawatan,
      'kemandoran': kemandoran,
      'gajipokok': gajipokok,
    };
  }
}
