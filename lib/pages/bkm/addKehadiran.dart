// ignore_for_file: unrelated_type_equality_checks

import 'package:flutter/material.dart';
import 'package:flutter_application_3/providers/bkm/bkm_provider.dart';
import 'package:flutter_application_3/providers/bkm/kehadiran_provider.dart';
import 'package:flutter_application_3/providers/bkm/prestasi_provider.dart';
import 'package:flutter_application_3/providers/tambahdata_bkm_provider.dart';
import 'package:flutter_application_3/widget/searchable_selector.dart';
// import 'package:flutter_application_3/services/FormMode.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum KehadairanFormMode {
  add,
  edit,
}

class TambahKehadiranPage extends StatelessWidget {
  final KehadairanFormMode mode;
  final Map<String, dynamic>? dataList;
  const TambahKehadiranPage(
      {super.key, this.mode = KehadairanFormMode.add, this.dataList});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(mode == KehadairanFormMode.add
            ? 'Transaksi Baru'
            : 'Edit Kehadiran'),
        backgroundColor: const Color.fromARGB(255, 87, 173, 243),
      ),
      body: TambahKehadiranBody(mode: mode, dataList: dataList),
    );
  }
}

class TambahKehadiranBody extends StatefulWidget {
  final KehadairanFormMode mode;
  final Map<String, dynamic>? dataList;

  const TambahKehadiranBody(
      {super.key, this.mode = KehadairanFormMode.add, this.dataList});

  @override
  State<TambahKehadiranBody> createState() => _TambahKehadiranBodyState();
}

class _TambahKehadiranBodyState extends State<TambahKehadiranBody> {
  int _selectedPresenceOption = 2;
  String _username = '';
  final TextEditingController _hasilKerjaController = TextEditingController();
  final TextEditingController _hkController = TextEditingController();
  final TextEditingController _premiController = TextEditingController();
  final TextEditingController _extrafoodingController = TextEditingController();
  bool _isHasilKerjaValid = false;

  String? selectedKaryawan;

  @override
  void dispose() {
    _hasilKerjaController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _loadUsername();

    Future.microtask(() {
      final provider = Provider.of<KehadiranProvider>(context, listen: false);
      provider.loadKaryawan(2).then((_) {});

      final kehadiranProvider =
          Provider.of<KehadiranProvider>(context, listen: false);
      kehadiranProvider.fetchKehadiranByTransaksi();

      setState(() {
        _selectedPresenceOption = 2;
      });
    });

    final provider = Provider.of<BkmProvider>(context, listen: false);
    final kehadiranProvider =
        Provider.of<KehadiranProvider>(context, listen: false);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final noTransaksi = provider.notransaksi;
      String? kodekegiatanTemp = provider.kodekegiatanTemp;
      String? kodeorgTemp = provider.kodeorgTemp;
      String? kodeorg = provider.kodeorgTemp.toString().substring(0, 3);
      double? luasareaproduktifTemp = provider.luasproduktifTemp;
      double? luaspokokTemp = provider.luaspokokTemp;
      int extrafooding = kehadiranProvider.extrafooding;
      DateTime tglbkm = provider.selectedDate;
      String tahunString = tglbkm.toString().substring(0, 4);
      int tahun = int.tryParse(tahunString) ?? DateTime.now().year;
      int tahuntanam = kehadiranProvider.tahuntanam;
      String statusblok = kehadiranProvider.statusblok;

      if (widget.mode == KehadairanFormMode.edit) {
        _hasilKerjaController.text = widget.dataList?['hasilkerja'];
        _hkController.text = widget.dataList!['jhk'].toString();
        // final jhk = widget.dataList!['jhk'];

        // if (jhk is double && jhk == jhk.toInt()) {
        //   _hkController.text = jhk.toInt().toString(); // jika 1.0 → jadi "1"
        // } else {
        //   _hkController.text =
        //       jhk.toString(); // biarkan default jika bukan bulat
        // }
        _premiController.text = widget.dataList?['premi']?.toString() ?? '0.0';
        // _extrafoodingController.text =
        //     (widget.dataList?['extrafooding'] ?? 0.0).toString();
        var extraVal = widget.dataList?['extrafooding'];

        if (extraVal == null ||
            extraVal.toString().toLowerCase() == 'null' ||
            extraVal.toString().isEmpty) {
          _extrafoodingController.text = '0.0';
        } else {
          _extrafoodingController.text = extraVal.toString();
        }

        print('list dari widget');
        print(widget.dataList);

        kehadiranProvider.setHasilPremiLebihBasis(
            int.tryParse(widget.dataList?['premilebihbasis']) ?? 0);

        kehadiranProvider.setSelectedKaryawanValue(widget.dataList?['nik']);

        selectedKaryawan = kehadiranProvider.selectedKaryawanValue;

        // print(widget.dataList);
      } else {
        kehadiranProvider.resetForm();
        kehadiranProvider.initialize(
            notransaksi: noTransaksi,
            kodeKegiatan: kodekegiatanTemp,
            kodeOrg: kodeorgTemp,
            tanggal: tglbkm,
            luasareaproduktif: luasareaproduktifTemp,
            luaspokok: luaspokokTemp,
            extrafooding: extrafooding,
            tahun: tahun,
            statusblok: statusblok);
      }
    });
  }

  Future<void> _loadUsername() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _username = prefs.getString('username') ?? '';
    });
  }

  Widget build(BuildContext context) {
    return Consumer3<BkmProvider, PrestasiProvider, KehadiranProvider>(
        builder: (context, provider, prestasiProvider, kehadiranProvider, _) {
      return SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Kehadiran",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Column(
                children: [
                  RadioListTile(
                    value: 1,
                    groupValue: _selectedPresenceOption,
                    title: const Text("Seluruhnya"),
                    onChanged: (value) {
                      kehadiranProvider.loadKaryawan(value);
                      setState(() {
                        _selectedPresenceOption = value!;
                        kehadiranProvider.loadKaryawan(1);
                      });
                    },
                  ),
                  RadioListTile(
                    value: 2,
                    groupValue: _selectedPresenceOption,
                    title: Text(
                        "Hanya Kemandoran (${_username.isNotEmpty ? _username.toUpperCase() : '...'})"),
                    onChanged: (value) {
                      setState(() {
                        kehadiranProvider.loadKaryawan(value);

                        _selectedPresenceOption = value!;
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 10),
              const Text("Karyawan",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              SearchableSelector(
                data: kehadiranProvider.karyawan.map((item) {
                  return {
                    'id': item['karyawanid'].toString(),
                    'name': item['namakaryawan'],
                    'subtitle': "${item['subbagian']} | ${item['nik']}",
                  };
                }).toList(),
                labelText: 'Pilih Pemanen',
                // initialId: widget.nik, //
                onSelected: (selectedId) {
                  kehadiranProvider
                      .setSelectedKaryawanValue(selectedId.toString());

                  setState(() {
                    selectedKaryawan = selectedId;

                    if (kehadiranProvider.showDetail == false) {
                      kehadiranProvider.setHkEnable(true);
                    } else {
                      kehadiranProvider.setHkEnable(true);
                    }
                  });
                },
              ),
              const SizedBox(height: 10),
              if (kehadiranProvider.showDetail) ...[
                Text(
                  "Basis : ${kehadiranProvider.nilaiBasis <= 0 ? 0 : kehadiranProvider.nilaiBasis}",
                  style: const TextStyle(fontSize: 15),
                ),
                Text(
                  "Extra Fooding : ${kehadiranProvider.extrafooding <= 0 ? 0 : kehadiranProvider.extrafooding}",
                  style: const TextStyle(fontSize: 15),
                ),
                Text(
                  "Premi Lebih Basis : ${kehadiranProvider.premilebihbasis <= 0 ? 0 : kehadiranProvider.premilebihbasis}",
                  style: const TextStyle(fontSize: 15),
                ),
                Text(
                  "Hasil Premi Lebih Basis : ${kehadiranProvider.hasilpremiLebihBasis <= 0 ? 0 : kehadiranProvider.hasilpremiLebihBasis}",
                  style: const TextStyle(fontSize: 15),
                ),
              ],
              const SizedBox(height: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      _InputFieldCard(
                        hint: '0',
                        label: 'Hasil Kerja',
                        labelHeader:
                            'Hasil Kerja (${kehadiranProvider.satuankerja.isNotEmpty ? kehadiranProvider.satuankerja : '-'})',
                        controller: _hasilKerjaController,
                        enabled: true,
                        onChanged: (val) {
                          print('on change');

                          final parsedDouble = double.tryParse(
                              val.replaceAll(',', '.')); // terima koma juga
                          final isValid =
                              parsedDouble != null && parsedDouble > 0;

                          setState(() {
                            _isHasilKerjaValid = isValid;
                          });

                          String satuan = kehadiranProvider.satuankerja;
                          String satuanPremi = kehadiranProvider.satuanpremi;

                          if (satuan.trim() == satuanPremi.trim()) {
                            kehadiranProvider.setBkmPremiPrestasi(
                                _hasilKerjaController.text);
                          }

                          // panggil dengan double, jangan int.parse
                          context
                              .read<KehadiranProvider>()
                              .updateHasilKerja(parsedDouble ?? 0.0);

                          // panggilan _checkPremiBkm tetap bisa kirim teks controller
                          _checkPremiBkm(
                            provider: kehadiranProvider,
                            kodekegiatan: provider.kodekegiatanTemp,
                            hasilkerja: _hasilKerjaController.text,
                            kodeblok: provider.kodeorgTemp,
                            karyawan: selectedKaryawan,
                            tglbkm: provider.selectedDate,
                            modeValidate: 'bkmHasilKerja',
                            hkController: _hkController,
                            hasilKerjaController: _hasilKerjaController,
                            extrafoodingController: _extrafoodingController,
                            premiController: _premiController,
                          );
                        },
                      ),
                      _InputFieldCard(
                        hint: '0',
                        label: 'HK',
                        labelHeader: 'HK',
                        controller: _hkController,
                        enabled: kehadiranProvider.bkmhk,
                        onChanged: (val) {
                          _checkPremiBkm(
                              provider: kehadiranProvider,
                              kodekegiatan: provider.kodekegiatanTemp,
                              bkmHK: _hkController.text,
                              kodeblok: provider.kodeorgTemp,
                              karyawan: selectedKaryawan,
                              tglbkm: provider.selectedDate,
                              modeValidate: 'bkmHK',
                              hkController: _hkController,
                              hasilKerjaController: _hasilKerjaController,
                              extrafoodingController: _extrafoodingController,
                              premiController: _premiController);
                        },
                      ),
                      _InputFieldCard(
                        hint: '0',
                        label: 'Premi',
                        controller: _premiController,
                        labelHeader: 'Premi',
                        enabled: false,
                      ),
                      _InputFieldCard(
                        hint: '0',
                        controller: _extrafoodingController,
                        label: 'Extra Fooding',
                        labelHeader: 'Extra Fooding',
                        enabled: false,
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () async {
                  String hasilkerja = _hasilKerjaController.text;
                  String hk = _hkController.text;
                  String premi = _premiController.text;
                  String extrafooding = _extrafoodingController.text;

                  final result = _submit(
                      provider: provider,
                      prestasiprovider: prestasiProvider,
                      kehadiranprovider: kehadiranProvider,
                      hasilkerja: hasilkerja,
                      bkmhk: hk,
                      bkmpremi: premi,
                      bkmextrafooding: extrafooding,
                      selectedKaryawan:
                          kehadiranProvider.selectedKaryawanValue);

                  // Provider.of<KehadiranProvider>(context, listen: false)
                  //     .setShouldRefresh(true);

                  if (await result) {
                    // ScaffoldMessenger.of(context).showSnackBar(
                    //   const SnackBar(
                    //     content: Text("Data berhasil disimpan."),
                    //     backgroundColor: Colors.green,
                    //   ),
                    // );

                    // Navigator.pop(context, true);
                  }
                },
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.blue,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                child: const Align(
                  alignment: Alignment.center,
                  child: Text(
                    'SELESAI',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Future<bool> _submit(
      {required BkmProvider provider,
      required PrestasiProvider prestasiprovider,
      required KehadiranProvider kehadiranprovider,
      String? hasilkerja,
      String? bkmhk,
      String? bkmpremi,
      String? bkmextrafooding,
      String? selectedKaryawan}) async {
    final noTransaksi = provider.notransaksi;
    String? kodekegiatanTemp = provider.kodekegiatanTemp;
    String? kodeorgTemp = provider.kodeorgTemp;
    double? luasareaproduktifTemp = provider.luasproduktifTemp;
    double? luaspokokTemp = provider.luaspokokTemp;

    String? bkmAsisten = provider.selectedAsistenValue;

    String? bkmMandor = provider.selectedMandorValue;
    String? bkmMandor1 = provider.selectedMandor1Value;

    String bkmPremiPrestasi = kehadiranprovider.premiPrestasi;

    String? idkehadiranBkm = 'H';

    DateTime tglbkm = provider.selectedDate;

    // final errors = <String>[];

    int bkmHk = bkmhk!.trim().isEmpty ? 0 : int.tryParse(bkmhk.trim()) ?? 0;
    // int bkmOT = bkm!.trim().isEmpty ? 0 : int.tryParse(bkmhk.trim()) ?? 0;
    int bkmPremi =
        bkmpremi!.trim().isEmpty ? 0 : int.tryParse(bkmpremi.trim()) ?? 0;
    int bkmHasilKerja =
        hasilkerja!.trim().isEmpty ? 0 : int.tryParse(hasilkerja.trim()) ?? 0;

    DateTime bkmTgl = tglbkm;

    String? karyawanBkm = selectedKaryawan;

    final errors = await kehadiranprovider.simpanKehadiran(
        notrans: noTransaksi,
        nikkaryawan: karyawanBkm,
        kodekegiatanTemp: kodekegiatanTemp,
        kodeorgTemp: kodeorgTemp,
        luasareaproduktifTemp: luasareaproduktifTemp,
        luaspokokTemp: luaspokokTemp,
        bkmexstrafooding: bkmextrafooding,
        bkmhk: double.parse(bkmhk.toString()),
        bkmhasilkerja: hasilkerja,
        bkmpremi: bkmpremi ?? '0',
        bkmAsisten: bkmAsisten,
        bkmMandor1: bkmMandor1,
        bkmMandor: bkmMandor,
        bkmPremiPrestasi: bkmPremiPrestasi,
        context: context);

    if (errors.isNotEmpty) {
      await showDialog(
        context: context,
        useRootNavigator:
            false, // ini penting karena kamu pakai custom Navigator
        builder: (_) => AlertDialog(
          title: const Text('Validasi Gagal'),
          content: Text(errors.join('\n')),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            )
          ],
        ),
      );

      return false;
    }

    return true;
  }

  Future<bool> _checkPremiBkm({
    required KehadiranProvider provider,
    String? kodekegiatan,
    String? hasilkerja,
    String? kodeblok,
    String? karyawan,
    String? bkmHK,
    String? modeValidate,
    required DateTime tglbkm,
    TextEditingController? hkController,
    TextEditingController? hasilKerjaController,
    TextEditingController? extrafoodingController,
    TextEditingController? premiController,
  }) async {
    int tahun = int.tryParse(tglbkm.toString()) ?? DateTime.now().year;
    int gajipokok = 0;
    int tahuntanam = 0;
    String statusblok = '';

    // if () {
    print('iya ini false');
    // }

    // final errors = <String>[];

    final hasilKerjaVal = double.tryParse(hasilkerja ?? '');
    final hkVal = double.tryParse(bkmHK ?? '');

    final errors = await provider.validatePremiBkmLogic(
        kodekegiatan: kodekegiatan,
        hasilkerja: hasilKerjaVal,
        kodeblok: kodeblok,
        karyawan: karyawan,
        bkmHK: hkVal,
        modeValidate: modeValidate,
        tahunbkm: tahun,
        hkController: hkController,
        hasilKerjaController: hasilKerjaController,
        extrafoodingController: extrafoodingController,
        premiController: premiController);

    if (errors.isNotEmpty) {
      // Reset field sesuai mode validasi
      if (modeValidate == 'bkmHK' && hkController != null) {
        hkController.text = '0';
        // provider.setHkEnable(false);
      } else if (modeValidate == 'bkmHasilKerja' &&
          hasilKerjaController != null) {
        hasilKerjaController.text = '0';
      }

      await showDialog(
        context: context,
        useRootNavigator: false,
        builder: (_) => AlertDialog(
          title: const Text('Validasi Gagal'),
          content: Text(errors.join('\n')),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            )
          ],
        ),
      );

      return false;
    }

    return true;
  }
}

List<DropdownMenuItem<String>> _buildKaryawanItems(
    List<Map<String, dynamic>> data) {
  print('data');

  return data.map((item) {
    return DropdownMenuItem(
      value: item['karyawanid'].toString(),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "${item['namakaryawan']}",
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            "${item['subbagian']} | ${item['nik']}",
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }).toList();
}

class _InputFieldCard extends StatelessWidget {
  final String hint;
  final String label;
  final String labelHeader;
  final bool enabled;
  final TextEditingController? controller;
  final void Function(String)? onChanged;

  const _InputFieldCard({
    required this.hint,
    required this.label,
    required this.labelHeader,
    this.enabled = true,
    this.controller,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: enabled ? Colors.white : Colors.grey.shade200,
        border: Border.all(color: const Color(0xFFBDBDBD)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Text(
              labelHeader,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 6),
          Center(
            child: TextFormField(
              controller: controller,
              onChanged: onChanged,
              enabled: enabled,
              decoration: InputDecoration(
                hintText: hint,
                isDense: true,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                  borderSide: BorderSide(
                    color: enabled
                        ? const Color(0xFFDBDBDB)
                        : Colors.grey.shade400,
                  ),
                ),
              ),
              keyboardType: TextInputType.number,
            ),
          ),
          const SizedBox(height: 6),
          Center(
            child: Text(
              label,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }
}
