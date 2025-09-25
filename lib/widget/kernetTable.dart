import 'package:flutter/material.dart';
import 'package:flutter_application_3/pages/widget/essential.dart';
import 'package:flutter_application_3/providers/spb/spb_provider.dart';
import 'package:flutter_application_3/widget/searchable_selector.dart';

class KernetTable extends StatefulWidget {
  final SpbProvider provider;
  final void Function(List<Map<String, String>>) onChanged;

  /// ← NEW: baris kernet yang sudah tersimpan di DB (hasil SELECT kebun_spbtkbm)
  /// Bentuk elemen minimal:
  ///   { 'karyawanid': '000123', 'namakaryawan': 'Budi' }
  final List<Map<String, dynamic>>? initialRows;

  const KernetTable({
    super.key,
    required this.provider,
    required this.onChanged,
    this.initialRows, // ← NEW
  });

  @override
  State<KernetTable> createState() => _KernetTableState();
}

class _KernetTableState extends State<KernetTable> {
  // yang dibutuhkan SearchableSelector: {"id": "...", "nama": "..."}
  List<Map<String, String>> _rows = [
    {"id": "", "nama": ""}
  ];

  // --- helpers ---
  List<Map<String, String>> _normalizeInitial(List<Map<String, dynamic>>? src) {
    if (src == null || src.isEmpty) {
      return [
        {"id": "", "nama": ""}
      ];
    }
    // Ambil maksimal 2 kernet
    final rows = src.take(2).map((r) {
      final id = (r['karyawanid'] ?? r['id'] ?? '').toString();
      final nama =
          (r['namakaryawan'] ?? r['nama'] ?? r['name'] ?? '').toString();
      return {"id": id, "nama": nama};
    }).toList();
    return rows.isEmpty
        ? [
            {"id": "", "nama": ""}
          ]
        : rows;
  }

  @override
  void initState() {
    super.initState();
    // inisialisasi dari initialRows kalau sudah ada
    _rows = _normalizeInitial(widget.initialRows);
  }

  @override
  void didUpdateWidget(covariant KernetTable oldWidget) {
    super.didUpdateWidget(oldWidget);
    // kalau parent (edit) baru selesai load data dari DB, initialRows akan berubah → re-init
    if (!identical(oldWidget.initialRows, widget.initialRows)) {
      final next = _normalizeInitial(widget.initialRows);
      // hanya update kalau memang berbeda
      final changed = next.length != _rows.length ||
          next.asMap().entries.any((e) =>
              e.value['id'] != _rows[e.key]['id'] ||
              e.value['nama'] != _rows[e.key]['nama']);
      if (changed) {
        setState(() {
          _rows = next;
        });
        // kirim ke parent biar provider tahu ada nilai edit bawaan
        widget.onChanged(_rows);
      }
    }
  }

  void _addRow() {
    if (_rows.length >= 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Maksimal hanya 2 kernet')),
      );
      return;
    }
    setState(() {
      _rows.add({"id": "", "nama": ""});
      widget.onChanged(_rows);
    });
  }

  void _removeRow(int index) {
    setState(() {
      _rows.removeAt(index);
      if (_rows.isEmpty) _rows.add({"id": "", "nama": ""});
      widget.onChanged(_rows);
    });
  }

  void _updateRow(int index, Map<String, String> row) {
    setState(() {
      _rows[index] = row;
      widget.onChanged(_rows);
    });
  }

  @override
  Widget build(BuildContext context) {
    // master list untuk pilihan kernet
    final kandidat = widget.provider.kernetList.map((item) {
      return {
        "id": item['karyawanid'].toString(),
        "name": item['namakaryawan'],
        "subtitle": "${item['subbagian']} | ${item['nik']}",
      };
    }).toList();

    return Column(
      children: [
        Table(
          border: TableBorder.all(color: Colors.grey.shade300),
          columnWidths: const {
            0: FlexColumnWidth(2),
            1: FlexColumnWidth(4),
            2: FlexColumnWidth(1),
          },
          children: [
            const TableRow(
              decoration: BoxDecoration(color: Colors.blueGrey),
              children: [
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text("ID Kary", style: TextStyle(color: Colors.white)),
                ),
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text("Nama", style: TextStyle(color: Colors.white)),
                ),
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text("Aksi", style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
            ..._rows.asMap().entries.map((entry) {
              final index = entry.key;
              final row = entry.value;
              return TableRow(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(row["id"] ?? ""),
                  ),
                  SearchableSelector(
                    key: ValueKey(
                        'kernet-${row["id"] ?? ""}'), // re-init jika id berubah
                    data: kandidat,
                    labelText: 'Pilih Kernet',
                    initialId: row["id"] ?? '',
                    onSelected: (selectedId) {
                      final selected = kandidat.firstWhere(
                        (item) => item['id'] == selectedId,
                        orElse: () => {
                          "id": selectedId,
                          "name": selectedId,
                          "subtitle": "",
                        },
                      );
                      _updateRow(index, {
                        "id": selected["id"] ?? "",
                        "nama": selected["name"] ?? "",
                      });
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: IconButton(
                      icon: const Icon(Icons.close, color: Colors.red),
                      onPressed: () => _removeRow(index),
                    ),
                  ),
                ],
              );
            }),
          ],
        ),
        const SizedBox(height: 10),
        ActionButton(
          label: 'Add Row',
          onPressed: _addRow,
          color: Colors.green,
        ),
      ],
    );
  }
}
