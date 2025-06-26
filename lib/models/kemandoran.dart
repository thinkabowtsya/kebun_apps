class Kemandoran {
  String mandorid;
  String karyawanid;
  String namakaryawan;
  String mandor;

  Kemandoran(
      {required this.mandorid,
      required this.karyawanid,
      required this.namakaryawan,
      required this.mandor});

  factory Kemandoran.fromJson(Map<String, dynamic> json) {
    return Kemandoran(
      mandorid: json['mandorid'] ?? '',
      karyawanid: json['karyawanid'] ?? '',
      namakaryawan: json['namakaryawan'] ?? '',
      mandor: json['mandor'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'mandorid': mandorid,
      'karyawanid': karyawanid,
      'namakaryawan': namakaryawan,
      'mandor': mandor,
    };
  }
}
