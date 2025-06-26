class LastNospb {
  String lastnospb;
  String updateby;

  LastNospb({required this.lastnospb, required this.updateby});

  factory LastNospb.fromJson(Map<String, dynamic> json) {
    return LastNospb(
      lastnospb: json['lastnospb'],
      updateby: json['updateby'] ?? 'syarifah',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'lastnospb': lastnospb,
      'updateby': updateby,
    };
  }
}
