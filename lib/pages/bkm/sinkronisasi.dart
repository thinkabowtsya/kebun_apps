// ignore_for_file: unrelated_type_equality_checks

import 'package:flutter/material.dart';
import 'package:flutter_application_3/pages/widget/essential.dart';
import 'package:flutter_application_3/providers/sync_provider.dart';
import 'package:flutter_application_3/widget/custom_seacrh_modal.dart';
import 'package:flutter_application_3/widget/searchable_selector.dart';
import 'package:provider/provider.dart';

class SinkronisasiPage extends StatelessWidget {
  const SinkronisasiPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaksi'),
        backgroundColor: const Color.fromARGB(255, 87, 173, 243),
      ),
      body: const FormSinkronisasiBody(),
    );
  }
}

class FormSinkronisasiBody extends StatefulWidget {
  const FormSinkronisasiBody({super.key});

  @override
  State<FormSinkronisasiBody> createState() => _FormSinkronisasiBodyState();
}

class _FormSinkronisasiBodyState extends State<FormSinkronisasiBody> {
  DateTime _selectedDate = DateTime.now();
  String? _selectedJenisTrans;
  String? _selectedNoTransaksi;
  String? selectedId;
  String? selectedName;
  bool _isLoading = false; // FLAG: menandakan sedang sinkronisasi

  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
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

      final provider = Provider.of<SyncProvider>(context, listen: false);

      final selectedJenis = provider.selectedJenistransaksiValue;
      if (selectedJenis != null && selectedJenis.isNotEmpty) {
        final formattedDate = picked.toIso8601String().split('T').first;
        await provider.setSelectedJenisTransaksi(
          jenis: selectedJenis,
          tglIso8601: formattedDate,
        );
      }
    }
  }

  final List<Map<String, String>> jenisTransaksiList = [
    {'value': 'bkm', 'label': 'BKM'},
    {'value': 'panenha', 'label': 'Prestasi Buku Panen'},
    {'value': 'panen', 'label': 'Buku Panen'},
    {'value': 'panen_checker', 'label': 'Verifikasi Panen'},
    // {'value': 'mutuhancak', 'label': 'Mutu Hancak'},
    {'value': 'spb', 'label': 'SPB'},
    // {'value': 'sensusproduksi', 'label': 'BBC'},
    // {'value': 'taksasi', 'label': 'Taksasi Panen'},
    // {'value': 'mututransport', 'label': 'Mutu Transport'},
    // {'value': 'kranitransport', 'label': 'Krani Transport'},
    // {'value': 'karet', 'label': 'Karet'},
    // {'value': 'sensuspokok', 'label': 'Sensus Pokok'},
  ];

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<SyncProvider>(context, listen: false);

    return Consumer<SyncProvider>(
      builder: (context, provider, _) {
        // PENTING: bungkus Stack dengan SizedBox.expand agar memenuhi layar.
        return SizedBox.expand(
          child: Stack(
            children: [
              // Konten utama diletakkan di bawah overlay.
              // SingleChildScrollView tetap memungkinkan konten di-scroll saat overlay tidak aktif.
              SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Tanggal :",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: _showDatePicker,
                        child: AbsorbPointer(
                          child: TextField(
                            decoration: InputDecoration(
                              hintText:
                                  '${_selectedDate.toLocal()}'.split(' ')[0],
                              suffixIcon: const Icon(Icons.calendar_today),
                              border: const OutlineInputBorder(),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        "Jenis Transaksi :",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          isExpanded: true,
                          value: _selectedJenisTrans,
                          hint: const Text("Pilih Jenis Transaksi"),
                          items: jenisTransaksiList.map((item) {
                            return DropdownMenuItem<String>(
                              value: item['value'],
                              child: Text(item['label'] ?? ''),
                            );
                          }).toList(),
                          onChanged: (value) async {
                            if (value != null && value.isNotEmpty) {
                              final formattedDate = _selectedDate
                                  .toIso8601String()
                                  .split('T')
                                  .first;

                              setState(() {
                                _selectedJenisTrans = value;
                              });
                              await provider.setSelectedJenisTransaksi(
                                jenis: value,
                                tglIso8601: formattedDate,
                              );
                            }
                          },
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        "No Transaksi :",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      SearchableSelector(
                        data: provider.currentList.map((item) {
                          return {
                            'id': item['id'].toString(),
                            'name': "${item['header']} | ${item['detail']}",
                            'subtitle': item['detail2'],
                          };
                        }).toList(),
                        labelText: 'Pilih No Transaksi',
                        onSelected: (selectedId) {
                          provider.setSelectedNotransaksi(selectedId);
                          print('id $selectedId');
                        },
                      ),
                      const SizedBox(height: 8),
                      ActionButton(
                          label: 'Sinkron',
                          onPressed: () async {
                            // tampilkan overlay loading
                            setState(() {
                              _isLoading = true;
                            });

                            String? jenisTransaksi =
                                provider.selectedJenistransaksiValue;
                            String? notransaksi = provider.selectedNotransaksi;
                            print(jenisTransaksi);

                            try {
                              final errors = await provider.syncTrans(
                                  selectedDate: _selectedDate,
                                  jenistransaksi: _selectedJenisTrans,
                                  notransaksi: notransaksi);

                              // setelah selesai, sembunyikan loading
                              if (mounted) {
                                setState(() {
                                  _isLoading = false;
                                });
                              }

                              if (errors.isNotEmpty) {
                                await showDialog(
                                  context: context,
                                  useRootNavigator: false,
                                  builder: (_) => AlertDialog(
                                    title: const Text('Pesan'),
                                    content: Text(errors.join('\n')),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: const Text('OK'),
                                      )
                                    ],
                                  ),
                                );
                              } else {
                                // jika tidak ada error, tampilkan notifikasi singkat
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text('Sinkron sukses')),
                                  );
                                }
                              }
                            } catch (e) {
                              // pastikan loading tertutup bila exception
                              if (mounted) {
                                setState(() {
                                  _isLoading = false;
                                });
                              }
                              // tampilkan error
                              await showDialog(
                                context: context,
                                useRootNavigator: false,
                                builder: (_) => AlertDialog(
                                  title: const Text('Kesalahan'),
                                  content: Text(e.toString()),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text('OK'),
                                    )
                                  ],
                                ),
                              );
                            } finally {
                              // safety: pastikan flag dimatikan jika masih true
                              if (mounted && _isLoading) {
                                setState(() {
                                  _isLoading = false;
                                });
                              }
                            }
                          }),
                      const SizedBox(
                          height:
                              400), // optional: beri ruang agar scroll bisa terlihat saat testing
                    ],
                  ),
                ),
              ),

              // ============================
              // OVERLAY LOADING: PENUHI SELURUH LAYAR
              // ============================
              if (_isLoading)
                // ModalBarrier mencegah interaksi pada seluruh layar
                const Positioned.fill(
                  child: _FullScreenLoading(),
                ),
            ],
          ),
        );
      },
    );
  }
}

/// Widget terpisah untuk overlay loading supaya kode di atas tetap rapi
class _FullScreenLoading extends StatelessWidget {
  const _FullScreenLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // background semi-transparent yang menutupi seluruh layar
        ModalBarrier(
          dismissible: false,
          color: Colors.black45,
        ),
        // spinner + teks di tengah layar
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              CircularProgressIndicator(),
              SizedBox(height: 12),
              Text(
                'Sedang sinkronisasi...',
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
