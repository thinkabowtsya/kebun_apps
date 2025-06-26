import 'package:flutter/material.dart';
import 'package:flutter_application_3/pages/widget/essential.dart';
import 'package:flutter_application_3/providers/bkm/bkm_provider.dart';
import 'package:flutter_application_3/providers/bkm/material_provider.dart';
import 'package:provider/provider.dart';

enum MaterialFormMode {
  add,
  edit,
}

class FormMaterialPage extends StatelessWidget {
  final MaterialFormMode mode;
  final Map<String, dynamic>? dataList;
  const FormMaterialPage(
      {super.key, this.mode = MaterialFormMode.add, this.dataList});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            mode == MaterialFormMode.add ? 'Transaksi Baru' : 'Edit Material'),
        backgroundColor: const Color.fromARGB(255, 87, 173, 243),
      ),
      body: MaterialBody(mode: mode, dataList: dataList),
    );
  }
}

class MaterialBody extends StatefulWidget {
  final MaterialFormMode mode;
  final Map<String, dynamic>? dataList;
  const MaterialBody(
      {super.key, this.mode = MaterialFormMode.add, this.dataList});

  @override
  State<MaterialBody> createState() => _MaterialBodyState();
}

class _MaterialBodyState extends State<MaterialBody> {
  String? selectedGudang;
  String? selectedMaterial;
  final TextEditingController _quantityController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final bkmprovider = Provider.of<BkmProvider>(context, listen: false);
    final provider = Provider.of<MaterialProvider>(context, listen: false);
    final noTransaksi = bkmprovider.notransaksi;
    String? kodekegiatanTemp = bkmprovider.kodekegiatanTemp;
    String? kodeorgTemp = bkmprovider.kodeorgTemp;

    provider.fetchDataGudang(
        notransaksi: noTransaksi,
        kodekegiatan: kodekegiatanTemp,
        kodeorg: kodeorgTemp);

    // print(bkmprovider.notransaksi);
  }

  @override
  Widget build(BuildContext context) {
    String quantityController = _quantityController.text;
    return Consumer2<MaterialProvider, BkmProvider>(
        builder: (context, provider, bkmProvider, _) {
      return SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Gudang",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.start,
              ),
              DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  isExpanded: true,
                  value: selectedGudang,
                  items: _buildGudangItems(provider.gudang),
                  onChanged: (value) {
                    if (value != null) {
                      // provider.setGudangValue(value);
                      setState(() {
                        selectedGudang = value;
                        selectedMaterial = null;
                      });
                    }
                    String? kodekegiatanTemp = bkmProvider.kodekegiatanTemp;

                    provider.fetchMaterial(
                        val: value!, kodekegiatan: kodekegiatanTemp);
                    print('material');
                    print(provider.material);
                  },
                  hint: const Text("Pilih Gudang"),
                  isDense: false,
                  elevation: 1,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "Material",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.start,
              ),
              DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  isExpanded: true,
                  value: selectedMaterial,
                  items: provider.material != null
                      ? _buildMateriaItems(provider.material)
                      : [], // kosongkan saat belum pilih gudang
                  onChanged: selectedGudang != null
                      ? (value) {
                          if (value != null) {
                            setState(() {
                              selectedMaterial = value;
                            });
                          }
                        }
                      : null, // null = disable Dropdown
                  hint: const Text("Pilih Material"),
                  isDense: false,
                  elevation: 1,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "Quantity",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.start,
              ),
              TextField(
                controller: _quantityController,
                textAlign: TextAlign.start,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey, width: 2.0),
                  ),
                ),
                focusNode: FocusNode(
                    canRequestFocus:
                        false), // ini akan bikin dia gak bisa difokus sama user
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 8),
              ActionButton(
                label: 'SIMPAN',
                onPressed: () async {
                  _submit(
                      provider: provider,
                      gudang: selectedGudang,
                      material: selectedMaterial,
                      qty: _quantityController.text,
                      notrans: bkmProvider.notransaksi,
                      kodekegiatan: bkmProvider.kodekegiatanTemp,
                      kodeorg: bkmProvider.kodeorgTemp);
                },
              ),
            ],
          ),
        ),
      );
    });
  }

  Future<bool> _submit(
      {required MaterialProvider provider,
      String? gudang,
      String? material,
      String? qty,
      String? notrans,
      String? kodekegiatan,
      String? kodeorg}) async {
    final errors = <String>[];

    // print(material);

    if (material == '') {
      errors.add('Pilih Barang !');
    } else if (qty == '') {
      errors.add('Jumlah Barang Salah !');
    } else {
      provider.simpanMaterial(
          gudang: gudang,
          material: material,
          qty: qty,
          notrans: notrans,
          kodekegiatan: kodekegiatan,
          kodeorg: kodeorg,
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

  List<DropdownMenuItem<String>> _buildGudangItems(
      List<Map<String, dynamic>> data) {
    return data.map((item) {
      return DropdownMenuItem<String>(
        value: item['kodegudang'].toString(),
        child: Text(
          "${item['kodegudang']}",
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      );
    }).toList();
  }

  List<DropdownMenuItem<String>> _buildMateriaItems(
      List<Map<String, dynamic>> data) {
    return data.map((item) {
      return DropdownMenuItem<String>(
        value: item['kodebarang'].toString(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "${item['namabarang']}",
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              "${item['satuan']}",
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
