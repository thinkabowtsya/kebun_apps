class Setuptph {
  String kode;
  String keterangan;
  String kodeorg;
  String latitude;
  String longitude;
  String luas;

  Setuptph({
    required this.kode,
    required this.keterangan,
    required this.kodeorg,
    required this.latitude,
    required this.longitude,
    required this.luas,
  });

  factory Setuptph.fromJson(Map<String, dynamic> json) {
    return Setuptph(
      kode: json['kode'],
      keterangan: json['keterangan'],
      kodeorg: json['kodeorg'],
      latitude: json['latitude'],
      longitude: json['longitude'],
      luas: json['luas'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'kode': kode,
      'keterangan': keterangan,
      'kodeorg': kodeorg,
      'latitude': latitude,
      'longitude': longitude,
      'luas': luas,
    };
  }
}
