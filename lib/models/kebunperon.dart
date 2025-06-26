class KebunPeron {
  String id;
  String nama;

  KebunPeron({required this.id, required this.nama});

  factory KebunPeron.fromJson(Map<String, dynamic> json) {
    return KebunPeron(
      id: json['id'],
      nama: json['nama'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama': nama,
    };
  }
}
