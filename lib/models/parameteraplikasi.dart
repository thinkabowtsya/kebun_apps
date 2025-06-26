class ParameterAplikasi {
  String kodeaplikasi;
  String kodeparameter;
  String kodeorg;
  String keterangan;
  String nilai;

  ParameterAplikasi({
    required this.kodeaplikasi,
    required this.kodeparameter,
    required this.kodeorg,
    required this.keterangan,
    required this.nilai,
  });

  factory ParameterAplikasi.fromJson(Map<String, dynamic> json) {
    return ParameterAplikasi(
      kodeaplikasi: json['kodeaplikasi'],
      kodeparameter: json['kodeparameter'],
      kodeorg: json['kodeorg'],
      keterangan: json['keterangan'],
      nilai: json['nilai'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'kodeaplikasi': kodeaplikasi,
      'kodeparameter': kodeparameter,
      'kodeorg': kodeorg,
      'keterangan': keterangan,
      'nilai': nilai,
    };
  }
}
