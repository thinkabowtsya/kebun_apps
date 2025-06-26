class Kebun5Premibkm2 {
  String unit;
  String kodekegiatan;
  String tahuntanam;
  String basis;
  String premibasis;
  String premilebihbasis;
  String extrafooding;
  String updateby;
  String updatetime;

  Kebun5Premibkm2({
    required this.unit,
    required this.kodekegiatan,
    required this.tahuntanam,
    required this.basis,
    required this.premibasis,
    required this.premilebihbasis,
    required this.extrafooding,
    required this.updateby,
    required this.updatetime,
  });

  factory Kebun5Premibkm2.fromJson(Map<String, dynamic> json) {
    return Kebun5Premibkm2(
      unit: json['unit'],
      kodekegiatan: json['kodekegiatan'],
      tahuntanam: json['tahuntanam'],
      basis: json['basis'],
      premibasis: json['premibasis'],
      premilebihbasis: json['premilebihbasis'],
      extrafooding: json['extrafooding'],
      updateby: json['updateby'],
      updatetime: json['updatetime'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'unit': unit,
      'kodekegiatan': kodekegiatan,
      'tahuntanam': tahuntanam,
      'basis': basis,
      'premibasis': premibasis,
      'premilebihbasis': premilebihbasis,
      'extrafooding': extrafooding,
      'updateby': updateby,
      'updatetime': updatetime,
    };
  }
}
