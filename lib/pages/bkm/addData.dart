import 'package:flutter/material.dart';
import 'package:flutter_application_3/pages/widget/essential.dart';
import 'package:flutter_application_3/providers/bkm/absensi_provider.dart';
import 'package:flutter_application_3/providers/bkm/bkm_provider.dart';
import 'package:flutter_application_3/providers/bkm/kehadiran_provider.dart';
import 'package:flutter_application_3/providers/bkm/prestasi_provider.dart';
import 'package:flutter_application_3/providers/tambahdata_bkm_provider.dart';
// import 'package:flutter_application_3/services/FormMode.dart';
import 'package:flutter_application_3/services/notransaksihelper.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum BkmFormMode {
  add,
  edit,
}

class AddDataPage extends StatelessWidget {
  final BkmFormMode mode;
  final String? initialNoTransaksi;
  final DateTime? initialTanggal;

  const AddDataPage({
    super.key,
    this.mode = BkmFormMode.add,
    this.initialNoTransaksi,
    this.initialTanggal,
  });

  @override
  Widget build(BuildContext context) {
    print(mode);
    return Scaffold(
      appBar: AppBar(
        title:
            Text(mode == BkmFormMode.add ? 'Transaksi Baru' : 'Edit Transaksi'),
        backgroundColor: const Color.fromARGB(255, 87, 173, 243),
      ),
      body: AddDataBody(
        mode: mode,
        initialNoTransaksi: initialNoTransaksi,
        initialTanggal: initialTanggal,
      ),
    );
  }
}

class AddDataBody extends StatefulWidget {
  final BkmFormMode mode;
  final String? initialNoTransaksi;
  final DateTime? initialTanggal;

  const AddDataBody({
    super.key,
    this.mode = BkmFormMode.add,
    this.initialNoTransaksi,
    this.initialTanggal,
  });

  @override
  State<AddDataBody> createState() => _AddDataBodyState();
}

class _AddDataBodyState extends State<AddDataBody> {
  final TextEditingController _noTransaksiController = TextEditingController();
  String _username = '';
  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialTanggal ?? DateTime.now();
    _loadUsername();
    final prestasiProvider =
        Provider.of<PrestasiProvider>(context, listen: false);
    final absensiProvider =
        Provider.of<AbsensiProvider>(context, listen: false);
    Future.microtask(() {
      prestasiProvider.fetchPrestasiByTransaksi(_noTransaksiController.text);
    });
    final provider = Provider.of<BkmProvider>(context, listen: false);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (widget.mode == BkmFormMode.edit &&
          widget.initialNoTransaksi != null) {
        _noTransaksiController.text = widget.initialNoTransaksi!;
        _selectedDate = widget.initialTanggal ?? DateTime.now();

        provider.fetchDataMandorWithDefault();
        provider.fetchDataMandor1();
        provider.fetchDataAsisten();

        final fetchHeader =
            await provider.fetchByTrans(_noTransaksiController.text);

        final fetchTransaksi = await prestasiProvider
            .fetchPrestasiByTransaksi(_noTransaksiController.text);

        await absensiProvider.fetchLoadAbsensi(
            notrans: _noTransaksiController.text);

        // if (fetchHeader.isNotEmpty) {
        provider.setInitialHeaderData(fetchHeader[0]);

        // }

        setState(() {
          _showDetailTable = true;
          _selectedDate = provider.selectedDate;
        });
      } else {
        provider.resetForm();
        provider.fetchDataMandorWithDefault();
        provider.fetchDataMandor1();
        provider.fetchDataAsisten();
        provider.createTableBKM();
        // final notransaksi = await NoTransaksiHelper().generateNoTransaksi(nametable: 'kebun_aktifitas');
        final no1 = await NoTransaksiHelper().generate();
        _noTransaksiController.text = no1;

        // await prestasiProvider.fetchPrestasiByTransaksi(notransaksi);
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final provider = Provider.of<AbsensiProvider>(context, listen: false);
    final prestasiProvider =
        Provider.of<PrestasiProvider>(context, listen: false);
    final bkmProv = Provider.of<BkmProvider>(context, listen: false);

    // print(provider.shouldRefresh);
    if (provider.shouldRefresh) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        provider.fetchLoadAbsensi(
          notrans: _noTransaksiController.text,
        );
        // provider.fetchKehadiranByTransaksi(
        //     notransaksi: noTransaksi,
        //     kodekegiatan: kodekegiatanTemp,
        //     kodeorg: kodeorgTemp,
        //     kelompok: luasareaproduktifTemp.toString(),
        //     luasareaproduktif: luaspokokTemp.toString());
        provider.setShouldRefresh(false);
      });
    }

    if (prestasiProvider.shouldRefresh) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        prestasiProvider.fetchPrestasiByTransaksi(
          _noTransaksiController.text,
        );

        prestasiProvider.setShouldRefresh(false);
      });
    }
    // print('refresh material');
  }

  @override
  void dispose() {
    _noTransaksiController.dispose();
    super.dispose();
  }

  DateTime _selectedDate = DateTime.now();

  Future<void> _loadUsername() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _username = prefs.getString('username')?.trim() ?? '';
    });
  }

  Future<void> _showDatePicker() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  bool _showDetailTable = false;
  @override
  Widget build(BuildContext context) {
    String noTrans = _noTransaksiController.text;

    final data = context.watch<PrestasiProvider>().prestasiList;
    final dataAbsensi = context.watch<AbsensiProvider>().absensiFull;

    return Consumer3<BkmProvider, PrestasiProvider, AbsensiProvider>(
      builder: (context, provider, prestasiProvider, absensiProvider, _) {
        if (provider.isLoadingMandor ||
            provider.isLoadingMandor1 ||
            provider.isLoadingAsisten) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "No Transaksi",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.start,
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _noTransaksiController,
                  enabled: false,
                  textAlign: TextAlign.start,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey, width: 2.0),
                    ),
                  ),
                  focusNode: FocusNode(canRequestFocus: false),
                ),
                const SizedBox(height: 16),
                const Text(
                  "Mandor",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.start,
                ),
                const SizedBox(height: 8),
                DropdownButtonHideUnderline(
                  child: DropdownButton(
                    isExpanded: true,
                    value: provider.selectedMandorValue,
                    items: _buildDropdownItems(provider.mandor),
                    onChanged: widget.mode == BkmFormMode.edit
                        ? null
                        : (value) {
                            provider.setSelectedMandorValue(value.toString());
                          },
                    hint: const Text("Pilih Mandor"),
                    isDense: false,
                    elevation: 1,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  "Mandor 1",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.start,
                ),
                const SizedBox(height: 8),
                DropdownButtonHideUnderline(
                  child: DropdownButton(
                    isExpanded: true,
                    value: provider.selectedMandor1Value,
                    items: _mandor1Items(provider.mandor1),
                    onChanged: widget.mode == BkmFormMode.edit
                        ? null
                        : (value) {
                            provider.setSelectedMandor1Value(value.toString());
                          },
                    hint: const Text("Pilih Mandor 1"),
                    isDense: false,
                    elevation: 1,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  "Asisten",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.start,
                ),
                const SizedBox(height: 8),
                DropdownButtonHideUnderline(
                  child: DropdownButton(
                    isExpanded: true,
                    value: provider.selectedAsistenValue,
                    items: _buildAsistenItems(provider.asisten),
                    onChanged: widget.mode == BkmFormMode.edit
                        ? null
                        : (value) {
                            provider.setSelectedAsistenValue(value.toString());
                          },
                    hint: const Text("Pilih Asisten"),
                    isDense: false,
                    elevation: 1,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  "Tanggal",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.start,
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap:
                      widget.mode != BkmFormMode.edit ? _showDatePicker : null,
                  child: AbsorbPointer(
                    child: TextField(
                      readOnly: true, // biar user gak bisa ketik manual
                      enabled: widget.mode != BkmFormMode.edit, // style disable
                      decoration: InputDecoration(
                        hintText: '${_selectedDate.toLocal()}'.split(' ')[0],
                        suffixIcon: const Icon(Icons.calendar_today),
                        border: const OutlineInputBorder(),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                if (!_showDetailTable) ...[
                  _buildSaveButton(provider),
                ] else ...[
                  const SectionTitle('Data Prestasi'),
                  ActionButton(
                    label: 'TAMBAH',
                    onPressed: () async {
                      final result = await Navigator.of(context)
                          .pushNamed('/add-prestasi');
                      if (result is Map && result['success'] == true) {
                        if (context.mounted) {
                          await prestasiProvider
                              .fetchPrestasiByTransaksi(noTrans);
                        }
                      }
                    },
                  ),
                  _buildDetailSection(context, prestasiProvider, data),
                  const SizedBox(height: 20),
                  const SectionTitle('Data Kehadiran Umum'),
                  ActionButton(
                    label: 'TAMBAH',
                    onPressed: () async {
                      print('kehadiran');
                      await Navigator.of(context).pushNamed('/add-absensi');
                    },
                  ),
                  _buildPrestasiSection(context, absensiProvider, dataAbsensi)
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSaveButton(BkmProvider provider) {
    return TextButton(
      onPressed: () async {
        try {
          provider.setNotransaksi(_noTransaksiController.text);
          await provider.addHeader(
              notransaksi: _noTransaksiController.text,
              tanggal: _selectedDate,
              context: context);

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Data berhasil disimpan')),
          );

          Provider.of<BkmProvider>(context, listen: false)
              .setShouldRefresh(true);

          setState(() {
            _showDetailTable = true;
          });
        } on Exception catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(e.toString().contains('sudah ada')
                  ? 'Mandor sudah ada di tanggal tersebut'
                  : 'Error: ${e.toString()}'),
            ),
          );
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Terjadi kesalahan')),
          );
        }
      },
      style: TextButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: Colors.blue,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(2),
        ),
      ),
      child: const Align(
        alignment: Alignment.center,
        child: Text(
          'SIMPAN',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildPrestasiSection(
      BuildContext context, AbsensiProvider absensiProvider, datas) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        border: TableBorder.all(color: Colors.grey),
        headingRowColor: WidgetStateProperty.all(Colors.blueGrey[700]),
        headingTextStyle:
            const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        dataRowHeight: 32,
        headingRowHeight: 40,
        columns: const [
          DataColumn(label: Text('Keterangan                      ')),
          DataColumn(label: Text('Jumlah                   ')),
        ],
        rows: [
          ...datas.map((item) {
            return DataRow(cells: [
              DataCell(Text(item['keterangan'].toString())),
              DataCell(Text(item['jumlah'].toString())),
            ]);
          }).toList(),
          DataRow(
            color: WidgetStateProperty.all(Colors.grey[300]),
            cells: [
              const DataCell(
                Text(
                  'TOTAL',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              DataCell(
                Text(
                  absensiProvider.absensiFull
                      .fold<num>(
                        0,
                        (sum, item) => sum + (item['jumlah'] ?? 0),
                      )
                      .toString(),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailSection(
      BuildContext context, PrestasiProvider prestasiProvider, datas) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        showCheckboxColumn: false,
        border: TableBorder.all(color: Colors.grey),
        headingRowColor: WidgetStateProperty.all(Colors.blueGrey[700]),
        headingTextStyle:
            const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        dataRowHeight: 32,
        headingRowHeight: 40,
        columns: const [
          DataColumn(label: Text('Kegiatan')),
          DataColumn(label: Text('Blok')),
          DataColumn(label: Text('Jmlh HK')),
          DataColumn(label: Text('Hasil Kerja')),
        ],
        rows: [
          ...datas.map((item) {
            return DataRow(
              onSelectChanged: (selected) {
                if (selected == true) {
                  showModalBottomSheet(
                    context: context,
                    builder: (context) {
                      return SafeArea(
                        child: Wrap(
                          children: [
                            ListTile(
                              leading: const Icon(Icons.info),
                              title: const Text('Detail'),
                              onTap: () async {
                                final providerBkm = Provider.of<BkmProvider>(
                                    context,
                                    listen: false);

                                String kodekegiatan = item['kodekegiatan'];
                                String kodeorg = item['kodeorg'];
                                double? luasareaproduktif =
                                    item['luasareaproduktif'];
                                double? jumlahpokok = item['jumlahpokok'];

                                providerBkm.setNotransaksi(
                                    _noTransaksiController.text);
                                providerBkm.setKodekegiatantemp(kodekegiatan);
                                providerBkm.setKodeorgtemp(kodeorg);
                                providerBkm
                                    .setLuasproduktiftemp(luasareaproduktif);
                                providerBkm.setLuaspokoktemp(jumlahpokok);

                                print(providerBkm.selectedMandor1Value);

                                await Navigator.of(context).pushNamed(
                                  '/edit-prestasi',
                                  arguments: {
                                    'kodekegiatan': item['kodekegiatan'],
                                  },
                                );
                              },
                            ),
                            ListTile(
                              leading:
                                  const Icon(Icons.delete, color: Colors.red),
                              title: const Text('Hapus'),
                              onTap: () async {
                                Navigator.pop(context);
                                final confirm = await showDialog<bool>(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text('Konfirmasi Hapus'),
                                    content: const Text(
                                        'Yakin ingin menghapus data ini?'),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(context, false),
                                        child: const Text('Batal'),
                                      ),
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(context, true),
                                        child: const Text('Hapus'),
                                      ),
                                    ],
                                  ),
                                );

                                if (confirm == true) {
                                  await prestasiProvider.deletePrestasi(
                                    notransaksi: item['notransaksi'],
                                    kodeorg: item['kodeorg'],
                                    kodekegiatan: item['kodekegiatan'],
                                  );
                                  await prestasiProvider
                                      .fetchPrestasiByTransaksi(
                                          item['notransaksi']);

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Data berhasil dihapus'),
                                    ),
                                  );
                                }
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  );
                }
              },
              cells: [
                DataCell(Text(item['namakegiatan'].toString())),
                DataCell(Text(item['kodeorg'].substring(6, 10).toString())),
                DataCell(Text(item['jhk'].toString())),
                DataCell(Text(item['hasilkerja'].toString())),
              ],
            );
          }).toList(),
          DataRow(
            color: WidgetStateProperty.all(Colors.grey[300]),
            cells: [
              const DataCell(
                Text(
                  'TOTAL',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              const DataCell(Text('-')),
              DataCell(
                Text(
                  prestasiProvider.prestasiList
                      .fold<num>(
                        0,
                        (sum, item) => sum + (item['jhk'] ?? 0),
                      )
                      .toString(),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              DataCell(
                Text(
                  prestasiProvider.prestasiList
                      .fold<num>(
                        0,
                        (sum, item) => sum + (item['hasilkerja'] ?? 0),
                      )
                      .toString(),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<DropdownMenuItem<String>> _buildDropdownItems(
      List<Map<String, dynamic>> data) {
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
              "${item['lokasitugas']} | ${item['nik']}",
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

  List<DropdownMenuItem<String>> _mandor1Items(
      List<Map<String, dynamic>> data) {
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
              "${item['lokasitugas']} | ${item['nik']}",
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

  List<DropdownMenuItem<String>> _buildAsistenItems(
      List<Map<String, dynamic>> data) {
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
              "${item['lokasitugas']} | ${item['nik']}",
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
}
