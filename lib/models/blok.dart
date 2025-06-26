class Blok {
  String kodeorg;
  String kodeblok;
  String tahuntanam;
  String statusblok;
  String kegiatangroup;
  double luasareaproduktif;
  String kelaspohon;
  double jumlahpokok;
  String topografi;
  String kemandoran;
  String latitude;
  String longitude;

  Blok({
    required this.kodeorg,
    required this.kodeblok,
    required this.tahuntanam,
    required this.statusblok,
    required this.kegiatangroup,
    required this.luasareaproduktif,
    required this.kelaspohon,
    required this.jumlahpokok,
    required this.topografi,
    required this.kemandoran,
    required this.latitude,
    required this.longitude,
  });

  factory Blok.fromJson(Map<String, dynamic> json) {
    return Blok(
      kodeorg: json['kodeorg'].toString(),
      kodeblok: json['kodeblok'].toString(),
      tahuntanam: json['tahuntanam'].toString(),
      statusblok: json['statusblok'].toString(),
      kegiatangroup: json['kegiatangroup'].toString(),
      luasareaproduktif: json['luasareaproduktif'] != null
          ? double.parse(json['luasareaproduktif'].toString())
          : 0.0,
      kelaspohon: json['kelaspohon'].toString(),
      jumlahpokok: json['jumlahpokok'] != null
          ? double.parse(json['jumlahpokok'].toString())
          : 0,
      topografi: json['topografi'].toString(),
      kemandoran: json['kemandoran'].toString(),
      latitude: json['latitude'].toString(),
      longitude: json['longitude'].toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'kodeorg': kodeorg,
      'kodeblok': kodeblok,
      'tahuntanam': tahuntanam,
      'statusblok': statusblok,
      'kegiatangroup': kegiatangroup,
      'luasareaproduktif': luasareaproduktif,
      'kelaspohon': kelaspohon,
      'jumlahpokok': jumlahpokok,
      'topografi': topografi,
      'kemandoran': kemandoran,
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}
