class Tphbesar {
  String divisi;
  String notph;
  String createdby;

  Tphbesar({
    required this.divisi,
    required this.notph,
    required this.createdby,
  });

  factory Tphbesar.fromJson(Map<String, dynamic> json) {
    return Tphbesar(
      divisi: json['divisi'],
      notph: json['notph'],
      createdby: json['createdby'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'divisi': divisi,
      'notph': notph,
      'createdby': createdby,
    };
  }
}
