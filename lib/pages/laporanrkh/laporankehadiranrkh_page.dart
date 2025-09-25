// lib/pages/rkh_detail_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_application_3/providers/laporanrkh/laporanrkh_provider.dart';
import 'package:provider/provider.dart';

class RkhDetailPage extends StatefulWidget {
  final String? id;

  const RkhDetailPage({super.key, this.id});

  @override
  State<RkhDetailPage> createState() => _RkhDetailPageState();
}

class _RkhDetailPageState extends State<RkhDetailPage> {
  bool _initialized = false;
  late String _id;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initialized = true;

      _id = (widget.id ?? '').toString();
      if (_id.isEmpty) return;

      // preload list detail (baris-baris kegiatan)
      Future.microtask(() => context.read<LaporanrkhProvider>().listRkh(_id));
    }
  }

  // ===== MODAL DETAIL ala Cordova =====
  Future<void> _openDetailModal({
    required String kodeBlok,
    required String kodeKegiatan,
  }) async {
    final p = context.read<LaporanrkhProvider>();

    // Ambil detail header & material untuk kombinasi (id, kodeblok, kodekegiatan)
    await p.detailRKH(id: _id, kodeblok: kodeBlok, kodekegiatan: kodeKegiatan);

    if (!mounted) return;
    final header = p.headerList.isNotEmpty ? p.headerList.first : null;
    final materials = p.materialList;

    // Helper aman ambil angka
    num toNum(dynamic v) {
      if (v == null) return 0;
      if (v is num) return v;
      return num.tryParse(v.toString()) ?? 0;
    }

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        final kodeblok      = (header?['kodeblok'] ?? '').toString();
        final mandorNama    = (header?['namakaryawan'] ?? '-').toString();
        final namakegiatan  = (header?['namakegiatan'] ?? '-').toString();
        final luas          = (header?['luasareaproduktif'] ?? '').toString();
        final pokok         = (header?['jumlahpokok'] ?? '').toString();
        final rotasi        = (header?['rotasi'] ?? '').toString();

        final satuan        = (header?['satuan'] ?? '').toString();
        final jumlahPrestasi= (header?['target'] ?? header?['jumlah'] ?? header?['kwantitas'] ?? '').toString();

        final hkPb  = toNum(header?['hk_pb']);
        final hkKht = toNum(header?['hk_kht']);
        final hkKhl = toNum(header?['hk_khl']);
        final hkBor = toNum(header?['hk_bor']);
        final hkTotal = hkPb + hkKht + hkKhl + hkBor;

        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.85,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (_, controller) {
            TableRow row2(String a, String b) => TableRow(children: [
              Padding(padding: const EdgeInsets.all(10), child: Text(a)),
              Padding(padding: const EdgeInsets.all(10), child: Text(b, textAlign: TextAlign.right)),
            ]);

            Widget sectionTitle(String t) => Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF2ECD71),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(t, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
            );

            return SingleChildScrollView(
              controller: controller,
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Blok
                  Text(
                    kodeblok.isEmpty ? '(Tanpa Blok)' : kodeblok,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 12),

                  // Tabel Informasi Utama
                  Table(
                    border: TableBorder.all(color: Colors.black12),
                    columnWidths: const {0: FlexColumnWidth(1.2), 1: FlexColumnWidth(2)},
                    children: [
                      row2('Mandor',   mandorNama),
                      row2('Kegiatan', namakegiatan),
                      row2('Luas',     luas),
                      row2('Pokok',    pokok),
                      row2('Rotasi',   rotasi),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Prestasi
                  sectionTitle('Prestasi'),
                  const SizedBox(height: 8),
                  Table(
                    border: TableBorder.all(color: Colors.black12),
                    columnWidths: const {0: FlexColumnWidth(1), 1: FlexColumnWidth(1)},
                    children: [
                      TableRow(
                        decoration: const BoxDecoration(color: Color(0xFFEFFAF2)),
                        children: const [
                          Padding(padding: EdgeInsets.all(10), child: Text('Satuan', style: TextStyle(fontWeight: FontWeight.w600))),
                          Padding(padding: EdgeInsets.all(10), child: Text('Jumlah', style: TextStyle(fontWeight: FontWeight.w600), textAlign: TextAlign.right)),
                        ],
                      ),
                      row2(satuan, jumlahPrestasi),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Tenaga Kerja
                  sectionTitle('Tenaga Kerja'),
                  const SizedBox(height: 8),
                  Table(
                    border: TableBorder.all(color: Colors.black12),
                    columnWidths: const {
                      0: FlexColumnWidth(1),
                      1: FlexColumnWidth(1),
                      2: FlexColumnWidth(1),
                      3: FlexColumnWidth(1),
                      4: FlexColumnWidth(1),
                    },
                    children: [
                      TableRow(
                        decoration: const BoxDecoration(color: Color(0xFFEFFAF2)),
                        children: const [
                          Padding(padding: EdgeInsets.all(10), child: Text('NS',  style: TextStyle(fontWeight: FontWeight.w600))),
                          Padding(padding: EdgeInsets.all(10), child: Text('KHT', style: TextStyle(fontWeight: FontWeight.w600))),
                          Padding(padding: EdgeInsets.all(10), child: Text('PHL', style: TextStyle(fontWeight: FontWeight.w600))),
                          Padding(padding: EdgeInsets.all(10), child: Text('BOR', style: TextStyle(fontWeight: FontWeight.w600))),
                          Padding(padding: EdgeInsets.all(10), child: Text('Total', style: TextStyle(fontWeight: FontWeight.w600))),
                        ],
                      ),
                      TableRow(children: [
                        Padding(padding: const EdgeInsets.all(10), child: Text('$hkPb',  textAlign: TextAlign.center)),
                        Padding(padding: const EdgeInsets.all(10), child: Text('$hkKht', textAlign: TextAlign.center)),
                        Padding(padding: const EdgeInsets.all(10), child: Text('$hkKhl', textAlign: TextAlign.center)),
                        Padding(padding: const EdgeInsets.all(10), child: Text('$hkBor', textAlign: TextAlign.center)),
                        Padding(padding: const EdgeInsets.all(10), child: Text('$hkTotal', textAlign: TextAlign.center)),
                      ]),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Material
                  sectionTitle('Material'),
                  const SizedBox(height: 8),
                  Table(
                    border: TableBorder.all(color: Colors.black12),
                    columnWidths: const {
                      0: FlexColumnWidth(2),
                      1: FlexColumnWidth(1),
                      2: FlexColumnWidth(1),
                    },
                    children: [
                      TableRow(
                        decoration: const BoxDecoration(color: Color(0xFFEFFAF2)),
                        children: const [
                          Padding(padding: EdgeInsets.all(10), child: Text('Nama Barang', style: TextStyle(fontWeight: FontWeight.w600))),
                          Padding(padding: EdgeInsets.all(10), child: Text('Satuan', style: TextStyle(fontWeight: FontWeight.w600))),
                          Padding(padding: EdgeInsets.all(10), child: Text('Jumlah', style: TextStyle(fontWeight: FontWeight.w600), textAlign: TextAlign.right)),
                        ],
                      ),
                      // baris material
                      ...materials.map((m) {
                        final nama    = (m['namabarang'] ?? m['nama'] ?? '').toString();
                        final satuanM = (m['satuan'] ?? m['satuanbarang'] ?? '').toString();
                        final jumlahM = (m['jumlah'] ?? m['kwantitas'] ?? m['qty'] ?? '').toString();
                        return TableRow(children: [
                          Padding(padding: const EdgeInsets.all(10), child: Text(nama)),
                          Padding(padding: const EdgeInsets.all(10), child: Text(satuanM, textAlign: TextAlign.center)),
                          Padding(padding: const EdgeInsets.all(10), child: Text(jumlahM, textAlign: TextAlign.right)),
                        ]);
                      }),
                      if (materials.isEmpty)
                        const TableRow(children: [
                          Padding(padding: EdgeInsets.all(10), child: Text('—')),
                          Padding(padding: EdgeInsets.all(10), child: Text('—', textAlign: TextAlign.center)),
                          Padding(padding: EdgeInsets.all(10), child: Text('—', textAlign: TextAlign.right)),
                        ]),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Detail RKH #$_id')),
      body: Consumer<LaporanrkhProvider>(
        builder: (context, p, _) {
          final data = p.kehadiranList;

          return RefreshIndicator(
            onRefresh: () => p.listRkh(_id),
            child: data.isEmpty
                ? ListView(
                    children: const [
                      SizedBox(height: 120),
                      Center(child: Text('Belum ada detail')),
                    ],
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(12),
                    itemCount: data.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, i) {
                      final row = data[i];
                      final kegiatan     = (row['namakegiatan'] ?? '(tanpa nama kegiatan)').toString();
                      final kodeKegiatan = (row['kodekegiatan'] ?? '').toString();
                      final kodeBlok     = (row['kodeblok'] ?? '').toString();
                      final mandorNama   = (row['namakaryawan'] ?? '-').toString();
                      final mandorId     = (row['mandor'] ?? '').toString();

                      return Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          title: Text(kegiatan, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Kode Kegiatan: $kodeKegiatan'),
                                if (kodeBlok.isNotEmpty) Text('Blok: $kodeBlok'),
                                Text('Mandor: $mandorNama ($mandorId)'),
                              ],
                            ),
                          ),
                          onTap: () => _openDetailModal(
                            kodeBlok: kodeBlok,
                            kodeKegiatan: kodeKegiatan,
                          ),
                        ),
                      );
                    },
                  ),
          );
        },
      ),
    );
  }
}
