// ignore_for_file: unrelated_type_equality_checks

import 'package:flutter/material.dart';
import 'package:flutter_application_3/providers/bkm/bkm_provider.dart';
import 'package:flutter_application_3/providers/bkm/kehadiran_provider.dart';
import 'package:flutter_application_3/providers/bkm/prestasi_provider.dart';
import 'package:flutter_application_3/providers/tambahdata_bkm_provider.dart';
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
        _premiController.text = widget.dataList!['premi'].toString();
        _extrafoodingController.text = widget.dataList?['extrafooding'];

        kehadiranProvider.setSelectedKaryawanValue(widget.dataList?['nik']);

        selectedKaryawan = kehadiranProvider.selectedKaryawanValue;

        // print(widget.dataList);
      } else {
        print('add');
        kehadiranProvider.resetForm();
      }

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
                  RadioListTile(
                    value: 3,
                    groupValue: _selectedPresenceOption,
                    title: const Text("Scan Jari"),
                    onChanged: (value) {
                      setState(() {
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
              DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  isExpanded: true,
                  value: kehadiranProvider.selectedKaryawanValue,
                  // value: selectedKaryawan,
                  items: _buildKaryawanItems(kehadiranProvider.karyawan),
                  onChanged: (value) {
                    // if (value != null) {
                    kehadiranProvider
                        .setSelectedKaryawanValue(value.toString());
                    // }
                    setState(() {
                      selectedKaryawan = value;
                    });
                  },
                  hint: const Text("Pilih Karyawan"),
                ),
              ),
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
                          final isValid = double.tryParse(val) != null &&
                              double.parse(val) > 0;
                          setState(() {
                            _isHasilKerjaValid = isValid;
                            // _modeValidate = 'bkmHK';
                          });

                          String satuan = kehadiranProvider.satuankerja;
                          String satuanPremi = kehadiranProvider.satuanpremi;

                          if (satuan.trim() == satuanPremi.trim()) {
                            kehadiranProvider.setBkmPremiPrestasi(
                                _hasilKerjaController.text);
                          }

                          _validate(
                              provider: prestasiProvider,
                              hasilkerja: _hasilKerjaController.text,
                              modeValidate: 'bkmHasilKerja');

                          if (selectedKaryawan == null) {
                            _hasilKerjaController.text = '0';
                            showDialog(
                              context: context,
                              useRootNavigator: false,
                              builder: (_) => AlertDialog(
                                title: const Text('Validasi Gagal'),
                                content: const Text('karyawan wajib diisi'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('OK'),
                                  )
                                ],
                              ),
                            );
                          }
                        },
                      ),
                      _InputFieldCard(
                        hint: '0',
                        label: 'HK',
                        labelHeader: 'HK',
                        controller: _hkController,
                        enabled: _isHasilKerjaValid,
                        onChanged: (val) {
                          _validate(
                              provider: prestasiProvider,
                              bkmHK: _hkController.text,
                              modeValidate: 'bkmHK');
                        },
                      ),
                      const _InputFieldCard(
                        hint: '0',
                        label: 'Premi',
                        labelHeader: 'Premi',
                        enabled: false,
                      ),
                      const _InputFieldCard(
                        hint: '0',
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
                  // print('press');
                
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

                  Provider.of<KehadiranProvider>(context, listen: false)
                      .setShouldRefresh(true);

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
    print(selectedKaryawan);
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

    final errors = <String>[];

    // ignore: unrelated_type_equality_checks
    if (hasilkerja == '' || hasilkerja == null || hasilkerja == 0) {
      errors.add('Hasil Kerja Tidak Boleh Kosong !');
    }

    if ((bkmpremi == '' || bkmpremi == null || bkmpremi == 0) &&
        (bkmhk == '' || bkmhk == null || bkmhk == 0)) {
      errors.add('Premi/HK Tidak Boleh Kosong !');
    }

    int bkmHk = bkmhk!.trim().isEmpty ? 0 : int.tryParse(bkmhk.trim()) ?? 0;
    // int bkmOT = bkm!.trim().isEmpty ? 0 : int.tryParse(bkmhk.trim()) ?? 0;
    int bkmPremi =
        bkmpremi!.trim().isEmpty ? 0 : int.tryParse(bkmpremi.trim()) ?? 0;
    int bkmHasilKerja =
        hasilkerja!.trim().isEmpty ? 0 : int.tryParse(hasilkerja.trim()) ?? 0;

    DateTime bkmTgl = tglbkm;

    print(bkmhk);

    String? karyawanBkm = selectedKaryawan;

    if (karyawanBkm == '') {
      errors.add('Silahkan Pilih Karyawan !');
    } else if (karyawanBkm == bkmAsisten ||
        karyawanBkm == bkmMandor ||
        karyawanBkm == bkmMandor1) {
      errors.add('Karyawan sudah dipakai di header transaksi');
    } else if (double.parse(bkmhk) > 1 || double.parse(bkmhk) < 0) {
      errors.add('Jumlah HK salah !');
    } else if (kehadiranprovider.satuanpremi == 'HA' &&
        bkmHasilKerja > luasareaproduktifTemp!) {
      errors.add(
          'Hasil kerja HA $bkmHasilKerja melebih luas blok $luasareaproduktifTemp');
    } else if (bkmPremi < 0) {
      errors.add('Jumlah Premi Tidak Boleh lebih kecil dari 0');
    } else {
      kehadiranprovider.simpanKehadiran(
          notrans: noTransaksi,
          nikkaryawan: karyawanBkm,
          kodekegiatanTemp: kodekegiatanTemp,
          kodeorgTemp: kodeorgTemp,
          luasareaproduktifTemp: luasareaproduktifTemp,
          luaspokokTemp: luaspokokTemp,
          bkmexstrafooding: bkmextrafooding,
          bkmhk: double.parse(bkmhk),
          bkmhasilkerja: hasilkerja,
          bkmpremi: bkmpremi,
          context: context);
    }

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

  Future<bool> _validate(
      {required PrestasiProvider provider,
      String? hasilkerja,
      String? bkmHK,
      String? modeValidate}) async {
    final errors = <String>[];

    final hasilKerjaVal = double.tryParse(hasilkerja ?? '');
    final hkVal = double.tryParse(bkmHK ?? '');

    if (modeValidate == 'bkmHK') {
      if (hkVal == null || hkVal < 0) {
        errors.add('HK tidak boleh kurang dari 0!!');
        _hkController.text = '0';
        _extrafoodingController.text = '0';
      }
    } else if (modeValidate == 'bkmHasilKerja') {
      if (hasilKerjaVal == null || hasilKerjaVal < 0) {
        errors.add('Hasil Kerja tidak boleh kurang dari 0/Kosong!!');
        _hasilKerjaController.text = '0';
      }
    }

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
}

List<DropdownMenuItem<String>> _buildKaryawanItems(
    List<Map<String, dynamic>> data) {
  return data.map((item) {
    return DropdownMenuItem(
      value: item['nik'].toString(),
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
