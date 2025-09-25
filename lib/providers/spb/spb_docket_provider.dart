// lib/providers/panen/spb_docket_provider.dart
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter_application_3/services/db_helper.dart';

class SpbDocketProvider extends ChangeNotifier {
  final DBHelper _dbHelper = DBHelper();

  /// Jumlah print per “versi cetak”. Sama seperti Cordova (newCetak % cetakCounter).
  final int cetakCounter;

  SpbDocketProvider({this.cetakCounter = 2});

  // ================= STATE =================
  bool isLoading = false;
  String? error;

  bool splitted = false; // SPB punya split?
  bool splitButNotPrinted = false; // ada split cetakan < 1?

  // Header
  String notransaksi = "";
  String tanggal = "";
  String driver = "";
  String nopol = "";
  String estate = "";
  String divisi = "";
  String penerimaTbs = "";
  int cetakanVersi = 0; // hasil perhitungan versi cetak
  int cetakanRaw = 0; // nilai cetakan dari header

  // Total
  int jjgTotal = 0;
  double brondolanTotal = 0.0;

  // TT gabungan (unik, dipisah ;)
  String tahunTanamCSV = "";

  // Kernet
  final List<String> kernetIds = [];

  // Agregat blok & ref
  final List<_BlokAgg> blokAgg = [];
  final List<_RefAgg> refAgg = [];

  // Output final
  String detailText = "";
  String dataPrintSpb = "";
  String qrCompact = "";
  String qrLegacy = "";

  // ================ PUBLIC API =================

  Future<void> prepare(String spbNo) async {
    isLoading = true;
    error = null;
    notifyListeners();

    final Database? db = await _dbHelper.database;
    if (db == null) {
      error = "DB tidak tersedia";
      isLoading = false;
      notifyListeners();
      return;
    }

    try {
      // 1) VALIDASI SPLIT
      await _validateSplit(db, spbNo);
      if (splitButNotPrinted) {
        throw Exception("Pastikan semua SPB Split sudah di print.");
      }

      // 2) KERNET
      await _loadKernet(db, spbNo);

      // 3) DETAIL SPB
      await _loadDetailAndAggregate(db, spbNo);

      // 4) HITUNG CETAKAN & SUSUN OUTPUT
      _composeOutputs();

      isLoading = false;
      notifyListeners();
    } catch (e) {
      error = e.toString();
      isLoading = false;
      notifyListeners();
    }
  }

  // ================ INTERNAL STEPS =================

  Future<void> _validateSplit(Database db, String spbNo) async {
    const strCheck = '''
      SELECT a.*, b.cetakan AS cetakan_split
      FROM kebun_spbht AS a
      JOIN kebun_spb_split AS b ON a.nospb = substr(b.nospb, 1, 14)
      WHERE a.nospb = ?
    ''';
    final rs = await db.rawQuery(strCheck, [spbNo]);
    splitted = rs.isNotEmpty;
    splitButNotPrinted = false;
    if (splitted) {
      for (final r in rs) {
        final cs = _toInt(r['cetakan_split']);
        if (cs < 1) {
          splitButNotPrinted = true;
          break;
        }
      }
    }
  }

  Future<void> _loadKernet(Database db, String spbNo) async {
    kernetIds.clear();
    const strKernet = '''
      SELECT b.karyawanid
      FROM kebun_spbtkbm b
      WHERE b.nospb = ?
      GROUP BY b.karyawanid
    ''';
    final rs = await db.rawQuery(strKernet, [spbNo]);
    for (final r in rs) {
      final id = (r['karyawanid'] ?? '').toString();
      if (id.isNotEmpty) kernetIds.add(id);
    }
  }

  Future<void> _loadDetailAndAggregate(Database db, String spbNo) async {
    final strSelt = '''
      SELECT
        ifnull(a.blok,"") as blok,
        ifnull(a.nik,"") as nik,
        ifnull(a.rotasi,"1") as rotasi,
        ifnull(a.nospbref,"") as nospbref,
        ifnull(a.tglpanen,"") as tglpanen,

        ifnull((a.jjg - f.jjg), a.jjg) as jjg,
        ifnull(a.jjg,"") as jjg_a,
        ifnull((a.brondolan - f.brondolan), a.brondolan) as brondolan,
        ifnull(a.brondolan,"") as brondolan_a,

        ifnull(a.mentah,"") as mentah,
        ifnull(a.busuk,"") as busuk,
        ifnull(a.matang,"") as matang,
        ifnull(a.lewatmatang,"") as lewatmatang,

        ifnull(a.tahuntanam,"") as tahuntanam,
        ifnull(b.penerimatbs,"") as penerimatbs,
        b.tanggal,
        ifnull(b.cetakan,0) as cetakan,
        b.afdeling,
        ifnull(b.nopol,"") as nopol,
        ifnull(c.namakaryawan, b.driver) as driver,
        ifnull(d.tahuntanam,"") as tt,
        ifnull(e.sertifikat,"0") as sertifikat
      FROM  kebun_spbdt a
      LEFT JOIN kebun_spbht b ON a.nospb = b.nospb
      LEFT JOIN datakaryawan c ON b.driver = c.karyawanid
      LEFT JOIN setup_blok d ON substr(a.blok,1,10) = d.kodeblok
      LEFT JOIN organisasi e ON substr(b.afdeling,1,4) = e.kodeorganisasi
      LEFT JOIN kebun_spb_split f ON f.nospbref = a.nospbref
      WHERE a.nospb = ?
      ORDER BY a.blok
    ''';

    final rs = await db.rawQuery(strSelt, [spbNo]);

    if (rs.isEmpty) {
      throw Exception("Data SPB tidak ditemukan.");
    }

    // reset
    notransaksi = spbNo;
    jjgTotal = 0;
    brondolanTotal = 0.0;
    tanggal = "";
    driver = "";
    nopol = "";
    penerimaTbs = "";
    estate = "";
    divisi = "";
    cetakanRaw = 0;
    cetakanVersi = 0;
    blokAgg.clear();
    refAgg.clear();

    final Set<String> allTT = {};

    for (final row in rs) {
      // header (ambil sekali—praktisnya sama di semua row)
      tanggal = row['tanggal']?.toString() ?? tanggal;
      nopol = row['nopol']?.toString() ?? nopol;
      driver = row['driver']?.toString() ?? driver;
      penerimaTbs = row['penerimatbs']?.toString() ?? penerimaTbs;

      final afd = row['afdeling']?.toString() ?? "";
      if (afd.length >= 6) {
        estate = afd.substring(0, 4);
        divisi = afd.substring(4, 6);
      } else {
        estate = afd;
        divisi = "";
      }

      final int jjg = _toInt(row['jjg']);
      final double brd = _toDouble(row['brondolan']);
      jjgTotal += jjg;
      brondolanTotal += brd;

      // TT
      final tt = (row['tt']?.toString() ?? "");
      if (tt.isNotEmpty) {
        allTT.add(tt);
      } else {
        final tahuntanam = (row['tahuntanam']?.toString() ?? "");
        if (tahuntanam.isNotEmpty) {
          for (final part in tahuntanam.split(";")) {
            final p = part.trim();
            if (p.isNotEmpty) allTT.add(p);
          }
        }
      }

      // Agregasi per blok (blokShort + TT)
      final blok = (row['blok']?.toString() ?? "");
      final ttKey = tt.isNotEmpty ? tt : "";
      String blokKey;
      if (blok.length >= 10) {
        blokKey = "${blok.substring(6, 10)}_$ttKey";
      } else {
        blokKey = "${blok}_$ttKey";
      }

      if (blok.isNotEmpty) {
        final idx = blokAgg.indexWhere((e) => e.key == blokKey);
        if (idx < 0) {
          blokAgg.add(_BlokAgg(
            key: blokKey,
            blokShort: blok.length >= 10 ? blok.substring(6, 10) : blok,
            tahunTanam: ttKey,
            jjg: jjg,
            brondolan: brd,
          ));
        } else {
          blokAgg[idx] = blokAgg[idx].copyWith(
            jjg: blokAgg[idx].jjg + jjg,
            brondolan: blokAgg[idx].brondolan + brd,
          );
        }
      } else {
        // Baris referensi (SPB ref)
        final ref = (row['nospbref']?.toString() ?? "");
        final jjgA = _toInt(row['jjg_a']);
        final brdA = _toDouble(row['brondolan_a']);
        final ttRow = (row['tahuntanam']?.toString() ?? "");
        if (ref.isNotEmpty) {
          refAgg.add(_RefAgg(
            refNo: ref,
            jjg: jjgA,
            brondolan: brdA,
            tahunTanam: ttRow,
          ));
        }
      }

      // cetakan raw dari header
      cetakanRaw = _toInt(row['cetakan']);
    }

    // TT unik → CSV
    tahunTanamCSV = allTT.isEmpty ? "" : allTT.join(";");

    // versi cetakan (ala Cordova)
    final int newCetak = cetakanRaw + 1;
    final int mod = cetakCounter == 0 ? 0 : (newCetak % cetakCounter);
    final double hasil = cetakCounter == 0 ? 0 : (newCetak / cetakCounter);
    cetakanVersi = (mod == 0) ? hasil.toInt() : hasil.ceil();
  }

  void _composeOutputs() {
    final buf = StringBuffer();

    // Header
    buf.writeln("{br}");
    buf.writeln("{left}{b}${_col2('Tanggal#:', tanggal)}{/b}{br}");
    buf.writeln("{left}{b}${_col2('No. Pol#:', nopol)}{/b}{br}");
    buf.writeln("{left}{b}${_col2('Supir#:', driver)}{/b}{br}");
    buf.writeln("{left}{b}${_col2('Estate#:', estate)}{/b}{br}");
    buf.writeln("{left}{b}${_col2('Divisi#:', divisi)}{/b}{br}");
    buf.writeln(
        "{left}{b}${_col2('Cetakan#:', cetakanVersi.toString())}{/b}{br}");
    buf.writeln("{left}{b}${_col2('JJG TTL#:', jjgTotal.toString())}{/b}{br}");
    buf.writeln("{left}{b}${_col2('Brd TTL#:', _fmt(brondolanTotal))}{/b}{br}");

    // Blok / Janjang / Brd / TT
    if (blokAgg.isNotEmpty) {
      buf.writeln("{br}");
      buf.writeln("------------------------------{br}");
      buf.writeln("{left}{b}Blok / Janjang / Brd / TT{/b}{br}");
      buf.writeln("------------------------------{br}");
      for (final b in blokAgg) {
        final line = _col2(
          b.blokShort,
          "${b.jjg}    ${_fmt(b.brondolan)}    ${b.tahunTanam}",
        );
        buf.writeln("{left}{b}$line{/b}{br}");
      }
    }

    // SPB Ref / Jjg / Brd / TT
    if (refAgg.isNotEmpty) {
      buf.writeln("------------------------------{br}");
      buf.writeln("{left}{b}SPB Ref       / Jjg / Brd / TT{/b}{br}");
      buf.writeln("------------------------------{br}");
      for (final r in refAgg) {
        final line =
            _col2(r.refNo, "${r.jjg}  ${_fmt(r.brondolan)}  ${r.tahunTanam}");
        buf.writeln("{left}{b}$line{/b}{br}");
      }
    }

    buf.writeln("{br}{br}{br}");
    detailText = buf.toString();

    // dataPrintSpb (urutan seperti Cordova)
    final blokLines = blokAgg
        .map((b) => _col2(
            b.blokShort, "${b.jjg}    ${_fmt(b.brondolan)}    ${b.tahunTanam}",
            terse: true))
        .join();
    final refLines = refAgg
        .map((r) => _col2(
            r.refNo, "${r.jjg}  ${_fmt(r.brondolan)}  ${r.tahunTanam}",
            terse: true))
        .join();

    dataPrintSpb =
        "$notransaksi#${cetakanVersi.toString()}#$tanggal#$divisi#$estate#$driver#$nopol#$penerimaTbs#${jjgTotal.toString()}#${_fmt(brondolanTotal)}"
        "${blokLines.isNotEmpty ? "#$blokLines" : ""}"
        "${refLines.isNotEmpty ? "#$refLines" : ""}";

    // QR compact (tanpa *$)
    final kernetCSV = kernetIds.join(",");
    final nopolCompact = nopol.replaceAll(' ', '');
    final base =
        "$notransaksi#$driver#$nopolCompact#${jjgTotal.toString()}#$tahunTanamCSV#${_fmt(brondolanTotal)}#$estate#$divisi#$kernetCSV";
    qrCompact = base;

    qrLegacy = "*$base\$";
  }

  // ================ HELPERS =================

  static int _toInt(Object? v) {
    if (v == null) return 0;
    if (v is int) return v;
    if (v is double) return v.toInt();
    return int.tryParse(v.toString()) ?? 0;
  }

  static double _toDouble(Object? v) {
    if (v == null) return 0.0;
    if (v is double) return v;
    if (v is int) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0.0;
  }

  static String _fmt(num n) {
    if (n % 1 == 0) return n.toInt().toString();
    return n.toString();
  }

  String _col2(String left, String right, {bool terse = false}) {
    const width = 28;
    final l = left.replaceAll('#', ':');
    final r = right;
    final pad = (width - (l.length + r.length)).clamp(1, 20);
    final spaces = ' ' * pad;
    final out = "$l$spaces$r";
    return terse ? out : out;
  }
}

// ======== MODEL INTERNAL ========

class _BlokAgg {
  final String key; // "<blokShort>_<TT>"
  final String blokShort; // substring(6,10) atau fallback
  final String tahunTanam; // bisa kosong
  final int jjg;
  final double brondolan;

  _BlokAgg({
    required this.key,
    required this.blokShort,
    required this.tahunTanam,
    required this.jjg,
    required this.brondolan,
  });

  _BlokAgg copyWith({
    String? key,
    String? blokShort,
    String? tahunTanam,
    int? jjg,
    double? brondolan,
  }) =>
      _BlokAgg(
        key: key ?? this.key,
        blokShort: blokShort ?? this.blokShort,
        tahunTanam: tahunTanam ?? this.tahunTanam,
        jjg: jjg ?? this.jjg,
        brondolan: brondolan ?? this.brondolan,
      );
}

class _RefAgg {
  final String refNo;
  final int jjg;
  final double brondolan;
  final String tahunTanam;
  _RefAgg({
    required this.refNo,
    required this.jjg,
    required this.brondolan,
    required this.tahunTanam,
  });
}
