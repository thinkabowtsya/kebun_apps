import 'package:flutter/material.dart';
import 'package:flutter_application_3/services/db_helper.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

class KehadiranProvider with ChangeNotifier {
  final DBHelper _dbHelper = DBHelper();
  List<Map<String, dynamic>> _karyawan = [];
  String? _selectedKaryawanValue;

  List<Map<String, dynamic>> get karyawan => _karyawan;
  String? get selectedKaryawanValue => _selectedKaryawanValue;

  String filter = 'perdivisi';

  String? _selectedKaryawan;
  int _hasilKerja = 0;
  int _hk = 0;
  int _premi = 0;
  int _extraFooding = 0;
  int _premiLebihBasis = 0;
  double _nilaiBasis = 0;
  final int _overtime = 0;
  int _tahuntanam = 0;
  bool _showDetail = false;

  String? _bkmOvertime;
  String _bkmPLB = '0';

  String _satuanKerja = '';
  String _satuanPremi = '';
  String _statusBlok = '';
  String _bkmPremiPrestasi = '';
  int _bkmextrafoodinghide = 0;
  String? _bkmextrafooding;
  String _bkmHKValue = '';
  DateTime? _tanggalBkm;

  List<Map<String, dynamic>> _kehadiranList = [];

  List<Map<String, dynamic>> get kehadiranList => _kehadiranList;

  bool _isPremiEnabled = false;
  bool _isHkEnabled = true;
  final bool _isCheckboxVisible = false;
  final bool _isPLBVisible = false;

  bool get showDetail => _showDetail;
  String? get selectedKaryawan => _selectedKaryawan;
  int get hasilKerja => _hasilKerja;
  int get hk => _hk;
  int get premi => _premi;
  int get extrafooding => _extraFooding;
  int get premilebihbasis => _premiLebihBasis;
  double get nilaiBasis => _nilaiBasis;
  int get overtime => _overtime;
  int get tahuntanam => _tahuntanam;
  String get statusblok => _statusBlok;
  String get satuankerja => _satuanKerja;
  String get satuanpremi => _satuanPremi;
  bool get bkmpremi => _isPremiEnabled;
  bool get bkmhk => _isHkEnabled;
  String get premiPrestasi => _bkmPremiPrestasi;
  int get bkmextrafoodinghide => _bkmextrafoodinghide;
  String? get bkmextrafooding => _bkmextrafooding;
  String? get bkmHKValue => _bkmHKValue;
  String? get bkmOvertime => _bkmOvertime;
  String? get bkmPLB => _bkmPLB;
  DateTime? get tglBKm => _tanggalBkm;

  bool _shouldRefresh = false;

  bool get shouldRefresh => _shouldRefresh;

  void setShouldRefresh(bool value) {
    _shouldRefresh = value;
    notifyListeners();
  }

  void initialize({
    required String? notransaksi,
    required String? kodeKegiatan,
    required String? kodeOrg,
    required DateTime? tanggal,
    required double? luasareaproduktif,
    required double? luaspokok,
    required int? extrafooding,
    required int tahun,
    required String statusblok,
  }) async {
    final Database? db = await _dbHelper.database;
    if (db == null) return;

    setTglBkm(tanggal);

    final qrySetupBlok = '''
    SELECT luasareaproduktif, tahuntanam, statusblok
    FROM setup_blok
    WHERE kodeblok = '$kodeOrg'
  ''';
    final rsBlok = await db.rawQuery(qrySetupBlok);
    if (rsBlok.isEmpty) return;

    final tahuntanamDb = int.tryParse(rsBlok[0]['tahuntanam'].toString()) ?? 0;
    final statusBlok = rsBlok[0]['statusblok'].toString();
    _statusBlok = statusBlok;

    final usiaTanam = (tahun + 1) - tahuntanamDb;

    String qrypremi =
        '''  SELECT premi from setup_kegiatan where kodekegiatan='$kodeKegiatan'  ''';

    final premi = await db.rawQuery(qrypremi);
    final premiResult = premi[0];
    final premiValue = premiResult['premi'];

    if (premiValue == 0) {
      _isPremiEnabled = false;
      _isHkEnabled = false;
    } else {
      _isPremiEnabled = true;
      _isHkEnabled = true;
    }

    String qrythntanam =
        '''   SELECT tahuntanam FROM kebun_5premibkm where kodekegiatan = '$kodeKegiatan'     ''';

    final thntanam = await db.rawQuery(qrythntanam);

    String thntanam0 = '';
    String thntanamLast = '';
    for (final row in thntanam) {
      final t = row['tahuntanam'].toString();
      if (t == '0') thntanam0 = t;
      thntanamLast = t;
    }

    String queryPremi = "SELECT * FROM kebun_5premibkm WHERE kodekegiatan = ?";
    List<String?> params = [kodeKegiatan];

    if (statusblok == 'TM') {
      if (thntanam0 == '0') {
        queryPremi += " LIMIT 1";
      } else if (thntanamLast == '28') {
        queryPremi += " AND tahuntanam <= ? ORDER BY tahuntanam DESC LIMIT 1";
        params.add(usiaTanam.toString());
      } else {
        queryPremi += " AND tahuntanam = ? LIMIT 1";
        params.add(usiaTanam.toString());
      }
    } else {
      queryPremi += " LIMIT 1";
    }

    final resultPremi = await db.rawQuery(queryPremi, params);
    _showDetail = false;
    if (resultPremi.isNotEmpty) {
      final row = resultPremi.first;

      setPremiValues(
        nilaiBasis: double.parse(row['basis'].toString()),
        extraFooding: int.tryParse(row['extrafooding'].toString()) ?? 0,
        premiLebihBasis: int.tryParse(row['premilebihbasis'].toString()) ?? 0,
      );

      _showDetail = true;
      notifyListeners();
    }

    print('result premi');
    print(resultPremi);

    String query = '''
      SELECT b.satuan, b.satuan as satuanpremi
      FROM kebun_prestasi a
      LEFT JOIN setup_kegiatan b ON b.kodekegiatan = a.kodekegiatan
      LEFT JOIN kebun_5premibkm c ON a.kodekegiatan = c.kodekegiatan
      WHERE a.notransaksi = ? AND a.kodekegiatan = ? AND a.kodeorg = ?
    ''';

    final resultSatuan =
        await db.rawQuery(query, [notransaksi, kodeKegiatan, kodeOrg]);

    if (resultSatuan.isNotEmpty) {
      final row = resultSatuan.first;

      final String satuan = row['satuan']?.toString() ?? '';
      final String satuanPremi = row['satuanpremi']?.toString() ?? '';

      setSatuanValues(
        satuan: satuan,
        satuanpremi: satuanPremi,
      );
    } else {
      setSatuanValues(satuan: '', satuanpremi: '');
    }

    setExtraFoodingHide(extrafooding);

    notifyListeners();
  }

  void setSatuanValues({required String satuan, required String satuanpremi}) {
    _satuanKerja = satuan;
    _satuanPremi = satuanpremi;

    notifyListeners();
  }

  void setExtraFoodingHide(int? value) {
    _bkmextrafoodinghide = value!;

    notifyListeners();
  }

  void setTglBkm(DateTime? value) {
    _tanggalBkm = value;

    notifyListeners();
  }

  void setExtraFooding(String? value) {
    _bkmextrafooding = value;

    notifyListeners();
  }

  void setPremiValues({
    required double nilaiBasis,
    required int extraFooding,
    required int premiLebihBasis,
  }) {
    _nilaiBasis = nilaiBasis;
    _extraFooding = extraFooding;
    _premiLebihBasis = premiLebihBasis;

    notifyListeners();
  }

  void setBkmPremiPrestasi(String value) {
    _bkmPremiPrestasi = value;
    notifyListeners();
  }

  void setFilter(String value) {
    filter = value;
    notifyListeners();
  }

  void setKaryawan(String? value) {
    _selectedKaryawan = value;
    notifyListeners();
  }

  void setKehadiranList(List<Map<String, dynamic>> value) {
    _kehadiranList = value;
    notifyListeners();
  }

  void setHasilKerja(int value) {
    _hasilKerja = value;
    notifyListeners();
  }

  void setHk(int value) {
    _hk = value;
    notifyListeners();
  }

  void setPremi(int value) {
    _premi = value;
    notifyListeners();
  }

  void setTahuntanam(int value) {
    _tahuntanam = value;
    notifyListeners();
  }

  void setSelectedKaryawanValue(String value) {
    _selectedKaryawanValue = value;
    notifyListeners();
  }

  Future<void> loadKaryawan(dynamic value) async {
    final Database? db = await _dbHelper.database;
    if (db == null) return;

    try {
      String karyawanPermandor = '';
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      var mandorid = prefs.getString('karyawanid');

      if (value == 2) {
        karyawanPermandor = 'and mandorid = "$mandorid"';
      }

      String query = '''
      SELECT a.* FROM datakaryawan a left join kemandoran b on a.karyawanid = b.karyawanid where a.perawatan = '1' $karyawanPermandor  and a.subbagian != ' ' and a.gajipokok != 0 order by namakaryawan
      ''';

      final result = await db.rawQuery(query);

      _karyawan = result.isNotEmpty ? result : [];
    } catch (e, stackTrace) {
      print("🔴 Error: $e");
      print("🔴 Stack Trace: $stackTrace");
      _karyawan = [];
    }

    notifyListeners();
  }

  Future<List<Object>> simpanKehadiran(
      {required String? notrans,
      required String? nikkaryawan,
      required String? kodekegiatanTemp,
      required String? kodeorgTemp,
      double? luasareaproduktifTemp,
      double? luaspokokTemp,
      required String? bkmexstrafooding,
      required double bkmhk,
      required String bkmhasilkerja,
      required String bkmpremi,
      required BuildContext context}) async {
    final Database? db = await _dbHelper.database;
    final errors = <String>[];

    String idKehadiran = 'H';

    String strCheckKebun = '''
    SELECT kodekegiatan, kodeorg, nik, jhk, hasilkerja, insentif, extrafooding 
    FROM kebun_kehadiran 
    WHERE notransaksi = '$notrans' AND nik = '$nikkaryawan';
  ''';

    final resultCheckKebun = await db!.rawQuery(strCheckKebun);

    bool update = false;
    int jhk = 0;
    double hasilKerja = 0;
    double jumlahExtraFooding = 0;

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    var username = prefs.getString('username');
    final cleanUsername = username?.trim();

    for (var row in resultCheckKebun) {
      final kodekegiatan = row['kodekegiatan']?.toString();
      final kodeorg = row['kodeorg']?.toString();
      final nik = row['nik']?.toString();

      if (nik == nikkaryawan) {
        if (kodekegiatan == 'ABSENSI') {
          errors.add("Karyawan Sudah ada di Absensi");
          return errors;
        } else if (kodekegiatan != kodekegiatanTemp || kodeorg != kodeorgTemp) {
          jhk += int.tryParse(row['jhk'].toString()) ?? 0;
          hasilKerja += double.tryParse(row['hasilkerja'].toString()) ?? 0;
          jumlahExtraFooding +=
              double.tryParse(row['extrafooding'].toString()) ?? 0;
        } else {
          update = true;
        }
      }
    }

    double totalExtraFooding =
        jumlahExtraFooding + (double.tryParse(bkmexstrafooding ?? '0') ?? 0.0);

    if (bkmextrafoodinghide > 0) {
      if (totalExtraFooding > bkmextrafoodinghide) {
        double hasil = bkmextrafoodinghide - jumlahExtraFooding;
        bkmexstrafooding = hasil.toStringAsFixed(0);

        setExtraFooding(bkmexstrafooding);
      }
    }

    double bkmhkDouble = bkmhk;

    double jmlhHK = jhk.toDouble() + bkmhkDouble;

    hasilKerja += double.tryParse(bkmhasilkerja) ?? 0.0;

    double jmlhk = jhk + bkmhkDouble;
    double max = double.parse((1.0 - jhk).toStringAsFixed(2));

    if (jmlhk > 1.0) {
      errors.add(
          "Karyawan ini sudah ada di transaksi lain ($jhk HK), Max Input $max");
      _bkmHKValue = max.toString();

      return errors;
    }

    String strCheckLuasBlok = '''
        select a.*, b.kodeblok, b.luasareaproduktif, b.jumlahpokok from kebun_prestasi a left join setup_blok b on a.kodeorg=b.kodeblok where a.kodeorg='$kodeorgTemp' and a.notransaksi='$notrans'
    ''';

    final resultCheckLuasBlok = await db.rawQuery(strCheckLuasBlok);

    double luasareaproduktif = 0.0;
    double luasblok = 0.0;

    if (resultCheckLuasBlok.isNotEmpty) {
      final row = resultCheckLuasBlok.first;

      luasareaproduktif =
          double.tryParse(row['luasareaproduktif'].toString()) ?? 0.0;
      luasblok = double.tryParse(row['luasblok'].toString()) ?? 0.0;
    }

    if (satuanpremi == 'HA' &&
        double.tryParse(bkmhasilkerja)! > luasareaproduktif) {
      errors.add('luas hasil kerja lebih besar dari luas blok');
    } else if (satuanpremi == 'PKK' &&
        double.tryParse(bkmhasilkerja)! > luasblok) {
      errors.add('luas hasil kerja lebih besar dari luas blok');
    }

    String strCheck = '''
      SELECT * FROM kebun_aktifitas
      WHERE notransaksi = '$notrans' AND updateby like '%$cleanUsername%'
    ''';

    String strUPTFirst =
        '''   update kebun_kehadiran set jhk='$bkmhk', absensi='$idKehadiran', hasilkerja='$hasilKerja',insentif='$bkmpremi',jam_overtime='$bkmOvertime' ,
        updateby='$cleanUsername',
        extrafooding='$extrafooding',
        premilebihbasis='$bkmPLB'
        
        where notransaksi ='$notrans' and kodekegiatan='$kodekegiatanTemp' and kodeorg='$kodeorgTemp' and nik='$nikkaryawan'     ''';

    String strInsert =
        '''  INSERT INTO kebun_kehadiran(notransaksi, kodekegiatan, kodeorg, nik, jhk, absensi, hasilkerja, insentif, extrafooding, premilebihbasis, jam_overtime, updateby, premiprestasi, satuanprestasi) values ('$notrans','$kodekegiatanTemp','$kodeorgTemp','$nikkaryawan','$bkmhk','$idKehadiran','$bkmhasilkerja','$bkmpremi','$bkmextrafooding','$bkmPLB', '','$cleanUsername','$premiPrestasi','$satuanpremi') ''';

    final checkResult = await db.rawQuery(strCheck);

    DateTime date = DateTime.parse(_tanggalBkm.toString());
    String formattedDate = DateFormat('yyyy-MM-dd').format(date);

    if (checkResult.isEmpty) {
      errors.add('Transaksi tidak bisa dilanjutkan');
    } else {
      String strG =
          '''  select a.jhk FROM kebun_kehadiran a LEFT OUTER JOIN kebun_aktifitas b on a.notransaksi=b.notransaksi where b.tanggal='$formattedDate' and a.nik='$nikkaryawan' and a.notransaksi='$notrans' ''';

      final strGResult = await db.rawQuery(strG);

      double jhk = 0.0;
      double itsHk = 0.0;

      if (strGResult.isNotEmpty) {
        for (var row in strGResult) {
          double currentJhk = double.tryParse(row['jhk'].toString()) ?? 0.0;
          jhk = currentJhk;
          itsHk += currentJhk;
        }
      }

      itsHk += bkmhk;

      if (itsHk <= 1.0) {
        if (update == true) {
          await db.rawQuery(strUPTFirst);
          _shouldRefresh = true;
          Navigator.pop(context, {
            'success': true,
          });
        } else if (update == false) {
          await db.rawQuery(strInsert);
          _shouldRefresh = true;
          Navigator.pop(context, {
            'success': true,
          });
        }
      }
    }

    notifyListeners();
    return errors;
  }

  Future<List<Map<String, dynamic>>> fetchKehadiranByTransaksi(
      {String? notransaksi,
      String? kodekegiatan,
      String? kodeorg,
      String? kelompok,
      String? luasareaproduktif}) async {
    final value = [];

    final Database? db = await _dbHelper.database;
    if (db == null) return [];

    final strSelect = '''
    SELECT b.notransaksi, b.kodekegiatan, b.kodeorg, b.nik, e.satuan,
           a.namakaryawan as namakaryawan, b.jhk as jhk, b.hasilkerja as hasilkerja,
           b.jam_overtime as jam_overtime, b.insentif as insentif,
           b.premiprestasi as premiprestasi, b.extrafooding,
           IFNULL(e.satuan,'N/A') as satuanpremi, 
           g.luasareaproduktif, g.kodeblok, b.premilebihbasis 
    FROM kebun_kehadiran b
    LEFT JOIN kebun_aktifitas c ON b.notransaksi = c.notransaksi
    LEFT JOIN kebun_prestasi d ON b.notransaksi = d.notransaksi 
        AND b.kodekegiatan = d.kodekegiatan 
        AND b.kodeorg = d.kodeorg
    LEFT JOIN setup_kegiatan e ON d.kodekegiatan = e.kodekegiatan
    LEFT JOIN kebun_5premibkm f ON d.kodekegiatan = f.kodekegiatan
    LEFT JOIN setup_blok g ON d.kodeorg = g.kodeblok
    LEFT OUTER JOIN datakaryawan a ON b.nik = a.nik
    WHERE b.notransaksi = '$notransaksi' 
      AND b.kodekegiatan = '$kodekegiatan' 
      AND b.kodeorg = '$kodeorg'
    GROUP BY b.nik
    ORDER BY a.namakaryawan
  ''';

    final result = await db.rawQuery(strSelect);

    const strKebun =
        ''' select * from kebun_kehadiran order by notransaksi desc''';

    final resultCheck = await db.rawQuery(strKebun);

    _kehadiranList = result;

    notifyListeners();
    return value[0];
  }

  void resetForm() {
    _selectedKaryawanValue = null;

    notifyListeners();
  }

  Future<void> deleteKehadiran({
    required String notransaksi,
    required String kodeorg,
    required String kodekegiatan,
    required String nik,
  }) async {
    final db = await _dbHelper.database;
    if (db == null) return;

    await db.delete(
      'kebun_kehadiran',
      where: 'notransaksi = ? AND kodeorg = ? AND kodekegiatan = ? AND nik = ?',
      whereArgs: [notransaksi, kodeorg, kodekegiatan, nik],
    );

    print('sudah selesai delete');
    _shouldRefresh = true;

    notifyListeners();
  }

  Future<List<String>> validatePremiBkmLogic({
    required String? kodekegiatan,
    required double? hasilkerja,
    required String? modeValidate,
    required String? kodeblok,
    required String? karyawan,
    required double? bkmHK,
    required int? tahunbkm,
    TextEditingController? hkController,
    TextEditingController? hasilKerjaController,
    TextEditingController? extrafoodingController,
  }) async {
    final db = await _dbHelper.database;
    if (db == null) return [];

    final errors = <String>[];

    final hasilKerjaVal = hasilkerja;
    final hkVal = bkmHK;

    if (modeValidate == 'bkmHK') {
      if (hkVal == null || hkVal < 0) {
        errors.add('HK tidak boleh kurang dari 0!!');
      }
    } else if (modeValidate == 'bkmHasilKerja') {
      if (hasilKerjaVal == null || hasilKerjaVal < 0) {
        errors.add('Hasil Kerja tidak boleh kurang dari 0/Kosong!!');
        _isHkEnabled = true;
      }
    }

    double hasilkerjaVal = double.tryParse(hasilkerja.toString()) ?? 0;
    hasilkerjaVal = (hasilkerjaVal < 0) ? 0 : hasilkerjaVal;

    if (karyawan == '') {
      errors.add(" Karyawan wajib dipilih");
    }

    String qrytahuntanam =
        ''' SELECT luasareaproduktif, jumlahpokok, tahuntanam, statusblok from setup_blok where kodeblok='$kodeblok'   ''';

    final resultTahunTanam = await db.rawQuery(qrytahuntanam);

    final row = resultTahunTanam.first;

    int tahuntanam = int.tryParse(row['tahuntanam'].toString()) ?? 0;
    String statusblok = row['statusblok'].toString();
    double jumlahPokok = double.tryParse(row['jumlahpokok'].toString()) ?? 0.0;
    double luasareaproduktif =
        double.tryParse(row['luasareaproduktif'].toString()) ?? 0.0;

    double hasil =
        (luasareaproduktif != 0) ? (jumlahPokok / luasareaproduktif) : 0.0;

    if (_satuanKerja == 'PKK') {
      double hasil2 = (hasil != 0) ? (hasilkerjaVal / hasil) : 0.0;

      hasil2 = double.parse(hasil2.toStringAsFixed(2));

      if (hasil2 <= 0) {
        hasil2 = 0.0;
      }
    }

    final result = await db.rawQuery(
      "SELECT tahuntanam FROM kebun_5premibkm WHERE kodekegiatan = ?",
      [kodekegiatan],
    );

    int lengthD = 0;
    int lengthD2 = result.length;
    String thntanamLast = '';
    String thntanam0 = '';

    if (result.isNotEmpty) {
      for (var row in result) {
        final tahun = row['tahuntanam'].toString();
        lengthD++;

        thntanamLast = tahun;

        if (tahun == '0') {
          thntanam0 = tahun;
        }
      }
    }

    final resultPremi = await db.rawQuery(
      "SELECT premi FROM setup_kegiatan WHERE kodekegiatan = ?",
      [kodekegiatan],
    );
    final rowPremi = resultPremi.first;
    int valPremi = int.parse(rowPremi['premi'].toString());

    final resultGajiPokok = await db
        .rawQuery("SELECT gajipokok from datakaryawan where nik= '$karyawan' ");
    final rowGajiPokok = resultGajiPokok.first;
    int valGajiPokok = int.parse(rowGajiPokok['gajipokok'].toString());

    // print(resultGajiPokok);

    final usiaTanam = (tahunbkm! + 1) - tahuntanam;

    String kebunPremi =
        ''' SELECT * FROM kebun_5premibkm where kodekegiatan = '$kodekegiatan' ''';

    if (statusblok == 'TBM') {
      if (thntanam0 == '0') {
        kebunPremi += 'limit 1';
      } else {
        kebunPremi += "and tahuntanam= '$usiaTanam' limit 1";
      }
    } else if (statusblok == 'TM') {
      if (thntanam0 == '0') {
        kebunPremi += 'limit 1';
      } else if (thntanamLast == '28') {
        kebunPremi +=
            " AND tahuntanam <= '$usiaTanam' ORDER BY tahuntanam DESC LIMIT 1";
      } else {
        kebunPremi += "and tahuntanam= '$usiaTanam' limit 1";
      }
    } else {
      kebunPremi += 'limit 1';
    }

    final resultKebunpremi = await db.rawQuery(kebunPremi);
    final rowKebunPremi = resultKebunpremi.first;

    final double basis =
        double.tryParse(rowKebunPremi['basis'].toString()) ?? 0.0;
    final double premiBasis =
        double.tryParse(rowKebunPremi['premibasis'].toString()) ?? 0.0;
    final double premiLebihBasis =
        double.tryParse(rowKebunPremi['premilebihbasis'].toString()) ?? 0.0;
    final int extraFooding =
        int.tryParse(rowKebunPremi['extrafooding'].toString()) ?? 0;

    print("Result Kebun Premi: $basis");

    if (basis == 0) {
      _isHkEnabled = false;
      print('iya basis 0 => field atau button bisa di-disable');
      // contoh: kehadiranProvider.setSomeState(disable: true);
    }

    if (hasilkerjaVal > basis) {
      double jml = (((hasilkerja! - basis) / basis) * (valGajiPokok / 25));
      int jmlRounded = jml.round();

      print(jmlRounded);
      hkController?.text = '1';
      extrafoodingController?.text = '$extraFooding';
      _isHkEnabled = false;
      // lakukan kalkulasi premi lebih basis di sini
    }

    return errors;
  }

  void setHkEnable(bool value) {
    _isHkEnabled = value;

    notifyListeners();
  }
}
