import 'package:flutter/material.dart';

class CustomSearchModal extends StatefulWidget {
  final List<Map<String, dynamic>> data;

  const CustomSearchModal({Key? key, required this.data}) : super(key: key);

  @override
  _CustomSearchModalState createState() => _CustomSearchModalState();
}

class _CustomSearchModalState extends State<CustomSearchModal> {
  String searchText = '';
  List<Map<String, dynamic>> filteredData = [];

  @override
  void initState() {
    super.initState();
    filteredData = widget.data;
  }

  void _filterData(String value) {
    setState(() {
      searchText = value;
      filteredData = widget.data.where((item) {
        return item['name']
            .toString()
            .toLowerCase()
            .contains(value.toLowerCase());
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Pilih Item"),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: const InputDecoration(
                labelText: 'Cari...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: _filterData,
            ),
            const SizedBox(height: 10),
            const Divider(thickness: 1.2),
            const SizedBox(height: 6),
            SizedBox(
              height: 300,
              width: 400,
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: filteredData.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final item = filteredData[index];
                  print(item);
                  return ListTile(
                    leading: const Icon(Icons.label_important_outline),
                    title: Text(
                      item['name'],
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    subtitle: Text('${item['subtitle']}'),
                    onTap: () {
                      Navigator.of(context).pop({
                        'id': item['id'],
                        'name': item['name'],
                      });
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Tutup'),
        ),
      ],
    );
  }
}
