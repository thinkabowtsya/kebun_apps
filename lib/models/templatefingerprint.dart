class TemplateFingerprint {
  String sn;
  String sensor;
  String idjari;
  String kebun;
  String template;
  String updateby;
  String karyawanid;

  TemplateFingerprint({
    required this.sn,
    required this.sensor,
    required this.idjari,
    required this.kebun,
    required this.template,
    required this.updateby,
    required this.karyawanid,
  });

  factory TemplateFingerprint.fromJson(Map<String, dynamic> json) {
    return TemplateFingerprint(
      sn: json['sn'],
      sensor: json['sensor'],
      idjari: json['idjari'],
      kebun: json['kebun'],
      template: json['template'],
      updateby: json['updateby'],
      karyawanid: json['karyawanid'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sn': sn,
      'sensor': sensor,
      'idjari': idjari,
      'kebun': kebun,
      'template': template,
      'updateby': updateby,
      'karyawanid': karyawanid,
    };
  }
}
