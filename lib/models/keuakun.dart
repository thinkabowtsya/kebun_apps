class Keuakun {
  String noakun;
  String namaakun;

  Keuakun({required this.noakun, required this.namaakun});

  factory Keuakun.fromJson(Map<String, dynamic> json) {
    return Keuakun(
      noakun: json['noakun'],
      namaakun: json['namaakun'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'noakun': noakun,
      'namaakun': namaakun,
    };
  }
}
