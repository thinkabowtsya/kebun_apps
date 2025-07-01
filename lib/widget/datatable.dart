import 'package:flutter/material.dart';

class CustomDataTableWidget extends StatelessWidget {
  final List<Map<String, dynamic>> data;
  final List<String> columns;
  final Map<String, String>? labelMapping;
  final List<String>? totalColumns;
  final bool enableBottomSheet;
  final List<Map<String, dynamic>>? bottomSheetActions;

  const CustomDataTableWidget({
    super.key,
    required this.data,
    required this.columns,
    this.labelMapping,
    this.totalColumns,
    this.enableBottomSheet = false,
    this.bottomSheetActions,
  });

  @override
  Widget build(BuildContext context) {
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
        columns: columns
            .map((col) => DataColumn(label: Text(labelMapping?[col] ?? col)))
            .toList(),
        rows: [
          ...data.map((row) {
            return DataRow(
              onSelectChanged: (_) {
                if (enableBottomSheet && bottomSheetActions != null) {
                  showModalBottomSheet(
                    context: context,
                    builder: (context) {
                      return SafeArea(
                        child: Wrap(
                          children: bottomSheetActions!
                              .map<Widget>((action) => ListTile(
                                    leading: Icon(action['icon'],
                                        color: Colors.blue),
                                    title: Text(action['label']),
                                    onTap: () {
                                      Navigator.pop(context);
                                      if (action['onTap'] != null) {
                                        action['onTap'](row);
                                      }
                                    },
                                  ))
                              .toList(),
                        ),
                      );
                    },
                  );
                }
              },
              cells: columns.map((col) {
                return DataCell(Text(row[col]?.toString() ?? ''));
              }).toList(),
            );
          }).toList(),
          if (totalColumns != null && totalColumns!.isNotEmpty)
            DataRow(
              color: WidgetStateProperty.all(Colors.grey[300]),
              cells: columns.map((col) {
                if (col == columns.first) {
                  return const DataCell(Text('TOTAL',
                      style: TextStyle(fontWeight: FontWeight.bold)));
                } else if (totalColumns!.contains(col)) {
                  final total = data.fold<num>(
                    0,
                    (sum, item) =>
                        sum + (num.tryParse(item[col]?.toString() ?? '0') ?? 0),
                  );
                  return DataCell(Text(total.toString(),
                      style: const TextStyle(fontWeight: FontWeight.bold)));
                } else {
                  return const DataCell(Text('-'));
                }
              }).toList(),
            ),
        ],
      ),
    );
  }
}
