
Map<String, String> getConfigPath(String ip) {
  Map<String, String> config = {
    'http': 'http://',
    'path': '/mobile',
  };

  // Uncomment if you want to handle different IP cases:
  /*
  Map<String, String> configDebug = {
    'http': 'http://',
    'path': '/mobile',
  };
  
  Map<String, String> configDebugLocal = {
    'http': 'http://',
    'path': '/projects/mobile',
  };
  
  if (ip == "182.23.67.40") {
    return configDebug;
  } else if (ip == "localhost") {
    return configDebugLocal;
  }
  */

  return config;
}

  String getTanggalx() {
    DateTime now = DateTime.now();
    int year = now.year;
    int month = now.month;
    int day = now.day;

    // Format tanggal menjadi YYYY-MM-DD
    String formattedDate =
        "$year-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}";
    return formattedDate;
  }



  
