class GudangTransaksi {
  String afdeling;
  String kodegudang;
  String status;

  GudangTransaksi(
      {required this.afdeling, required this.kodegudang, required this.status});

  factory GudangTransaksi.fromJson(Map<String, dynamic> json) {
    print('model');
    print(json);
    return GudangTransaksi(
      afdeling: json['afdeling'],
      kodegudang: json['kodegudang'],
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'afdeling': afdeling,
      'kodegudang': kodegudang,
      'status': status,
    };
  }
}
