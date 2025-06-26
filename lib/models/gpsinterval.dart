class Gpsinterval {
  String interval;
  String enableupload;

  Gpsinterval({required this.interval, required this.enableupload});

  factory Gpsinterval.fromJson(Map<String, dynamic> json) {
    return Gpsinterval(
      interval: json['interval'],
      enableupload: json['enableupload'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'interval': interval,
      'enableupload': enableupload,
    };
  }
}
