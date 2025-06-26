class AppUpdate {
  String statusAppUpdate; 
  String appVersion;      
  String appVersionNum;   
  String appVersionName;   

  AppUpdate({
    required this.statusAppUpdate,
    required this.appVersion,
    required this.appVersionNum,
    required this.appVersionName,
  });

  // Factory method untuk mengonversi JSON ke objek
  factory AppUpdate.fromJson(Map<String, dynamic> json) {
    return AppUpdate(
      statusAppUpdate: json['statusappupdate'],
      appVersion: json['appversion'],
      appVersionNum: json['appversionnum'],
      appVersionName: json['appversionname'],
    );
  }

  // Method untuk mengonversi objek kembali ke JSON
  Map<String, dynamic> toJson() {
    return {
      'statusappupdate': statusAppUpdate,
      'appversion': appVersion,
      'appversionnum': appVersionNum,
      'appversionname': appVersionName,
    };
  }
}
