import 'package:flutter/material.dart';
import 'package:flutter_application_3/pages/widget/essential.dart';
import 'package:flutter_application_3/providers/panen/panen_provider.dart';
import 'package:flutter_application_3/providers/panen/prestasi_provider.dart';
// import 'package:flutter_application_3/services/FormMode.dart';
import 'package:flutter_application_3/services/notransaksihelper.dart';
import 'package:flutter_application_3/widget/datatable.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum FormPanenMode {
  add,
  edit,
}

class FormPanenPage extends StatelessWidget {
  final FormPanenMode mode;
  final String? initialNoTransaksi;
  final DateTime? initialTanggal;

  const FormPanenPage({
    super.key,
    this.mode = FormPanenMode.add,
    this.initialNoTransaksi,
    this.initialTanggal,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            mode == FormPanenMode.add ? 'Transaksi Baru' : 'Edit Transaksi'),
        backgroundColor: const Color.fromARGB(255, 87, 173, 243),
      ),
      body: FormPanenBody(
        mode: mode,
        initialNoTransaksi: initialNoTransaksi,
        initialTanggal: initialTanggal,
      ),
    );
  }
}

class FormPanenBody extends StatefulWidget {
  final FormPanenMode mode;
  final String? initialNoTransaksi;
  final DateTime? initialTanggal;

  const FormPanenBody({
    super.key,
    this.mode = FormPanenMode.add,
    this.initialNoTransaksi,
    this.initialTanggal,
  });

  @override
  State<FormPanenBody> createState() => _FormPanenBodyState();
}

class _FormPanenBodyState extends State<FormPanenBody> {
  final TextEditingController _noTransaksiController = TextEditingController();
  String _username = '';
  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialTanggal ?? DateTime.now();
    _loadUsername();
    final provider = Provider.of<PanenProvider>(context, listen: false);

    Future.microtask(() {
      provider.fetchPanenEvaluasi(_noTransaksiController.text);
    });

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (widget.mode == FormPanenMode.edit &&
          widget.initialNoTransaksi != null) {
        _noTransaksiController.text = widget.initialNoTransaksi!;
        _selectedDate = widget.initialTanggal ?? DateTime.now();

        provider.fetchMandor();
        provider.fetchDataMandor1();
        provider.fetchDataKraniPanen();

        final fetchHeader =
            await provider.fetchByTrans(_noTransaksiController.text);

        if (fetchHeader.isNotEmpty) {
          await provider.setInitialHeaderData(fetchHeader[0]);
        }

        setState(() {
          _showDetailTable = true;
        });
      } else {
        provider.resetForm();
        provider.fetchMandor();
        provider.fetchDataMandor1();
        provider.fetchDataKraniPanen();

        provider.createTablePanen();
        final notransaksi = await NoTransaksiHelper()
            .generateNoTransaksi(nametable: 'kebun_panen');
        _noTransaksiController.text = notransaksi;
        // await provider.fetchByTrans(_noTransaksiController.text);
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final provider = Provider.of<PanenProvider>(context, listen: false);
    if (provider.shouldRefresh) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context
            .read<PanenProvider>()
            .fetchPanenEvaluasi(_noTransaksiController.text);

        provider.setShouldRefresh(false);
      });
    }
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
    final data = context.watch<PanenProvider>().evaluasipanen;

    return Consumer<PanenProvider>(
      builder: (context, provider, _) {
        // print('state awal');
        // print(context.watch<PanenProvider>().selectedMandor1Value);
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
                const SizedBox(height: 8),
                const Text(
                  "Tanggal",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.start,
                ),
                GestureDetector(
                  onTap: widget.mode != FormPanenMode.edit
                      ? _showDatePicker
                      : null,
                  child: AbsorbPointer(
                    child: TextField(
                      readOnly: true, // biar user gak bisa ketik manual
                      enabled:
                          widget.mode != FormPanenMode.edit, // style disable
                      decoration: InputDecoration(
                        hintText: '${_selectedDate.toLocal()}'.split(' ')[0],
                        suffixIcon: const Icon(Icons.calendar_today),
                        border: const OutlineInputBorder(),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
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
                    items: _buildDropdownMandor1Items(provider.mandor1),
                    onChanged: widget.mode == FormPanenMode.edit
                        ? null
                        : (value) {
                            provider.setMandor1(value.toString());
                          },
                    hint: const Text("Pilih Mandor 1"),
                    isDense: false,
                    elevation: 1,
                  ),
                ),
                const SizedBox(height: 8),
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
                    onChanged: widget.mode == FormPanenMode.edit
                        ? null
                        : (value) {
                            provider.setMandor(value.toString());
                          },
                    hint: const Text("Pilih Mandor"),
                    isDense: false,
                    elevation: 1,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Krani Panen",
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
                    value: provider.selectedKeraniValue,
                    items: _buildDropdownKraniItems(provider.kerani),
                    onChanged: widget.mode == FormPanenMode.edit
                        ? null
                        : (value) {
                            provider.setKrani(value.toString());
                          },
                    hint: const Text("Pilih Krani"),
                    isDense: false,
                    elevation: 1,
                  ),
                ),
                const SizedBox(height: 16),
                if (!_showDetailTable) ...[
                  _buildSaveButton(provider),
                ] else ...[
                  const SectionTitle('Data Detail Panen'),
                  ActionButton(
                    label: 'TAMBAH',
                    onPressed: () async {
                      print('tambah');
                      await Navigator.of(context).pushNamed('/add-prestasi');
                    },
                  ),
                ],
                // Text('masuk')
                CustomDataTableWidget(
                  data: data,
                  columns: const [
                    'namakaryawan',
                    'jjgpanen',
                    'brondolanpanen',
                  ],
                  labelMapping: const {
                    'namakaryawan': 'Mandor',
                    'jjgpanen': 'jjg',
                    'brondolanpanen': 'Brondolan',
                  },
                  enableBottomSheet: true,
                  bottomSheetActions: [
                    {
                      'label': 'Edit',
                      'colors': Colors.blue,
                      'icon': Icons.edit,
                      'onTap': (row) => doEdit(row),
                    },
                    {
                      'label': 'Hapus',
                      'colors': Colors.red,
                      'icon': Icons.delete,
                      'onTap': (row) => doDelete(row, context),
                    },
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void doEdit(row) async {
    print(row);
    await Navigator.of(context).pushNamed(
      '/edit-prestasipanen',
      arguments: {
        'mode': FormPanenMode.edit,
        'noTransaksi': row['notransaksi'],
        'nik': row['nik'],
      },
    );
  }

  void doDelete(row, BuildContext context) async {
    final prestasiProvider =
        Provider.of<PrestasiProvider>(context, listen: false);
    final panenProvider = Provider.of<PanenProvider>(context, listen: false);

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Hapus'),
        content: const Text('Yakin ingin menghapus data ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await prestasiProvider.deleteEvaluasi(
        notransaksi: row['notransaksi'].toString(),
        nik: row['nik'].toString(),
      );

      context
          .read<PanenProvider>()
          .fetchPanenEvaluasi(_noTransaksiController.text);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Data berhasil dihapus'),
        ),
      );
    }
  }

  Widget _buildSaveButton(PanenProvider provider) {
    return TextButton(
      onPressed: () async {
        try {
          provider.setNotransaksi(_noTransaksiController.text);
          provider.setTanggal(_selectedDate);
          final errors = await provider.addHeader(
              notransaksi: _noTransaksiController.text,
              tanggal: _selectedDate,
              usertype: 'user',
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
          }

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

  List<DropdownMenuItem<String>> _buildDropdownMandor1Items(
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

  List<DropdownMenuItem<String>> _buildDropdownKraniItems(
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
