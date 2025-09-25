import 'package:flutter/material.dart';
import 'package:flutter_application_3/providers/bkm/bkm_provider.dart';
import 'package:flutter_application_3/providers/cekRKH_provider.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'package:flutter_application_3/pages/bkm/addData.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BukuKerjaMandorPage extends StatelessWidget {
  const BukuKerjaMandorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Buku Kerja Mandor'),
      ),
      body: const BukuKerjaMandorBody(),
    );
  }
}

class BukuKerjaMandorBody extends StatefulWidget {
  const BukuKerjaMandorBody({super.key});

  @override
  State<BukuKerjaMandorBody> createState() => _BukuKerjaMandorBodyState();
}

class _BukuKerjaMandorBodyState extends State<BukuKerjaMandorBody>
    with RouteAware {
  DateTime selectedDate = DateTime.now();
  // String username = "suliana";
  String username = '';
  bool rkh = false;
  @override
  void initState() {
    super.initState();
    _loadUsername();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final provider = Provider.of<BkmProvider>(context, listen: false);

      // print(cekrkh.cekRKHA());
      String cleanDate = DateFormat('yyyy-MM-dd').format(selectedDate).trim();
      provider.tampilkanListBKM(username, cleanDate);
      provider.createTableBKM();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // print(selectedDate.toString());

    final provider = Provider.of<BkmProvider>(context, listen: false);

    if (provider.shouldRefresh) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        provider.tampilkanListBKM(
            username, DateFormat('yyyy-MM-dd').format(selectedDate));

        provider.setShouldRefresh(false);
      });
    }
  }

  Future<void> _loadUsername() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      username = prefs.getString('username')?.trim() ?? '';
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<BkmProvider>(context, listen: false);
    final bkmProvider = context.watch<BkmProvider>();
    final dataList = bkmProvider.bkmList;

    return Column(
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                TextButton(
                  onPressed: () async {
                    final cekrkh =
                        Provider.of<CekRkhProvider>(context, listen: false);
                    final errors = await cekrkh.cekRKHA();

                    if (errors.isNotEmpty) {
                      // kalau ada error → tampilkan pesan
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text("Peringatan"),
                          content: Text(errors.join("\n")),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx),
                              child: const Text("OK"),
                            ),
                          ],
                        ),
                      );
                    } else {
                      Navigator.pushNamed(context, '/add').then((value) {
                        if (value == true) {
                          provider.tampilkanListBKM(
                              username); // trigger refresh kalau kembali dari form
                        }
                      });
                    }
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  child: const Text('Transaksi Baru'),
                ),
                const SizedBox(width: 16),
                OutlinedButton(
                  onPressed: () {
                    // TODO: implement sinkronisasi
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.blue,
                    side: const BorderSide(color: Colors.blue),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  child: const Text('Sinkronisasi'),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: GestureDetector(
              onTap: () async {
                final DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: selectedDate,
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2030),
                );
                if (picked != null && picked != selectedDate) {
                  setState(() {
                    selectedDate = picked;
                  });

                  provider.tampilkanListBKM(
                    username,
                    DateFormat('yyyy-MM-dd').format(picked),
                  );
                }
              },
              child: AbsorbPointer(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: DateFormat('yyyy-MM-dd').format(selectedDate),
                    suffixIcon: const Icon(Icons.calendar_today),
                  ),
                ),
              ),
            ),
          ),
        ),
        Expanded(
          child: Consumer<BkmProvider>(
            builder: (context, provider, child) {
              final list = provider.bkmList;

              if (list.isEmpty) {
                return const Center(child: Text('Tidak ada data.'));
              }

              return SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: DataTable(
                      showCheckboxColumn: false,
                      border: TableBorder.all(color: Colors.grey),
                      headingRowColor:
                          WidgetStateProperty.all(Colors.blueGrey[700]),
                      headingTextStyle: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      dataRowHeight: 32,
                      headingRowHeight: 40,
                      columns: const [
                        DataColumn(label: Text('Tanggal')),
                        DataColumn(label: Text('Nama')),
                        DataColumn(label: Text('No Transaksi')),
                        DataColumn(label: Text('Sinkron')),
                      ],
                      rows: dataList.map((data) {
                        return DataRow(
                          onSelectChanged: (selected) {
                            if (selected == true) {
                              // TODO: BottomSheet untuk detail atau hapus
                              showModalBottomSheet(
                                context: context,
                                builder: (context) {
                                  return SafeArea(
                                    child: Wrap(
                                      children: [
                                        if (data['synchronized'] == '')
                                          ListTile(
                                            leading: const Icon(Icons.sync,
                                                color: Colors.green),
                                            title: const Text('Sinkronisasi'),
                                            onTap: () async {
                                              Navigator.of(context)
                                                  .pushNamed('/sinkronisasi')
                                                  .then((value) {
                                                provider
                                                    .tampilkanListBKM(username);
                                              });
                                            },
                                          ),
                                        if (data['synchronized'] == '')
                                          ListTile(
                                            leading: const Icon(Icons.edit,
                                                color: Colors.green),
                                            title: const Text('Edit'),
                                            onTap: () async {
                                              print('tapps');

                                              Navigator.of(context).pushNamed(
                                                '/edit',
                                                arguments: {
                                                  'mode': BkmFormMode.edit,
                                                  'noTransaksi':
                                                      data['notransaksi'],
                                                },
                                              );
                                            },
                                          ),
                                        ListTile(
                                          leading: const Icon(Icons.info),
                                          title: const Text('View'),
                                          onTap: () {
                                            // Navigator.of(context)
                                            //     .pushNamed('/lihat-bkm');

                                            Navigator.of(context).pushNamed(
                                              '/lihat-bkm',
                                              arguments: {
                                                'noTransaksi':
                                                    data['notransaksi'],
                                              },
                                            );
                                          },
                                        ),
                                        if (data['synchronized'] == '')
                                          ListTile(
                                            leading: const Icon(Icons.delete,
                                                color: Colors.red),
                                            title: const Text('Hapus'),
                                            onTap: () async {
                                              Navigator.pop(
                                                  context); // Tutup bottom sheet dulu

                                              // Tunggu sebentar biar konteks stabil
                                              await Future.delayed(
                                                  const Duration(
                                                      milliseconds: 200));

                                              final confirm =
                                                  await showDialog<bool>(
                                                context: context,
                                                builder: (context) =>
                                                    AlertDialog(
                                                  title: const Text(
                                                      'Konfirmasi Hapus'),
                                                  content: const Text(
                                                      'Yakin ingin menghapus data ini?'),
                                                  actions: [
                                                    TextButton(
                                                      onPressed: () =>
                                                          Navigator.pop(
                                                              context, false),
                                                      child:
                                                          const Text('Batal'),
                                                    ),
                                                    TextButton(
                                                      onPressed: () =>
                                                          Navigator.pop(
                                                              context, true),
                                                      child:
                                                          const Text('Hapus'),
                                                    ),
                                                  ],
                                                ),
                                              );

                                              if (confirm == true) {
                                                // print(true);
                                                await provider.deleteBkm(
                                                    notransaksi:
                                                        data['notransaksi'],
                                                    context: context);

                                                provider.setShouldRefresh(true);
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
                            DataCell(Text(data['tanggal']?.toString() ?? '-')),
                            DataCell(
                                Text(data['namakaryawan']?.toString() ?? '-')),
                            DataCell(
                                Text(data['notransaksi']?.toString() ?? '-')),
                            DataCell(
                              Icon(
                                (data['synchronized'] == null ||
                                        data['synchronized'] == '')
                                    ? Icons.close
                                    : Icons.check_circle,
                                color: (data['synchronized'] == null ||
                                        data['synchronized'] == '')
                                    ? Colors.red
                                    : Colors.green,
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
