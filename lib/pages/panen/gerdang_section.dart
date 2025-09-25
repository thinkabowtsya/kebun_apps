import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_3/providers/panen/prestasi_provider.dart';
import 'package:flutter_application_3/widget/searchable_selector.dart'; // ganti sesuai project-mu

class GerdangSection extends StatefulWidget {
  const GerdangSection({super.key});

  @override
  State<GerdangSection> createState() => _GerdangSectionState();
}

class _GerdangSectionState extends State<GerdangSection> {
  String? _selectedTipePanen;
  String? _selectedKaryawanId;

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<PrestasiProvider>(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Gerdang",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),

        // Dropdown Tipe Panen
        DropdownButtonFormField<String>(
          value: _selectedTipePanen,
          items: provider.tipepanen.map((item) {
            return DropdownMenuItem<String>(
              value: item['key'],
              child: Text(item['val'] ?? ''),
            );
          }).toList(),
          decoration: const InputDecoration(labelText: 'Tipe Panen'),
          onChanged: (val) => setState(() => _selectedTipePanen = val),
        ),
        const SizedBox(height: 8),

        // Selector Karyawan Gerdang
        SearchableSelector(
          data: provider.karyawanPanengerdang.map((item) {
            return {
              'id': item['karyawanid'].toString(),
              'name': item['namakaryawan'],
              'subtitle': "${item['subbagian']} | ${item['nik']}",
            };
          }).toList(),
          labelText: 'Pilih Karyawan Gerdang',
          onSelected: (selectedId) =>
              setState(() => _selectedKaryawanId = selectedId),
        ),
        const SizedBox(height: 8),

        // Tombol Tambah Gerdang
        ElevatedButton(
          onPressed: () {
            if (_selectedTipePanen == null || _selectedKaryawanId == null) {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text('Pilih tipe panen dan karyawan gerdang!'),
              ));
              return;
            }
            final selectedKaryawan = provider.karyawanPanengerdang.firstWhere(
                (k) => k['karyawanid'].toString() == _selectedKaryawanId);

            final alreadyExist =
                provider.listGerdang.any((g) => g.id == _selectedKaryawanId);
            if (alreadyExist) {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text('Gerdang sudah pernah ditambahkan!'),
              ));
              return;
            }

            provider.addGerdang(
              tipeKey: _selectedTipePanen!,
              karyawan: selectedKaryawan,
            );

            setState(() {
              _selectedTipePanen = null;
              _selectedKaryawanId = null;
            });
          },
          child: const Text("Tambahkan Gerdang"),
        ),

        // List Gerdang yang sudah dipilih
        if (provider.listGerdang.isNotEmpty) ...[
          const SizedBox(height: 16),
          ...provider.listGerdang.map((g) => Card(
                margin: const EdgeInsets.symmetric(vertical: 4),
                child: ListTile(
                  title: Text(g.nama),
                  subtitle: Text(g.tipeLabel),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => provider.removeGerdang(g.id),
                  ),
                ),
              )),
        ] else ...[
          const Padding(
            padding: EdgeInsets.only(top: 8),
            child: Text(
              "Belum ada gerdang ditambahkan.",
              style: TextStyle(color: Colors.grey),
            ),
          ),
        ]
      ],
    );
  }
}
