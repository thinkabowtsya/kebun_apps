class KemandoranBlok {
  String mandorid;
  String blok;

  KemandoranBlok({required this.mandorid, required this.blok});

  factory KemandoranBlok.fromJson(Map<String, dynamic> json) {
    return KemandoranBlok(
      mandorid: json['mandorid'],
      blok: json['blok'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'mandorid': mandorid,
      'blok': blok,
    };
  }
}
