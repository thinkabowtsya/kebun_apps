import 'package:flutter/material.dart';
import 'package:flutter_application_3/widget/custom_seacrh_modal.dart';

class SearchableSelector extends StatefulWidget {
  final List<Map<String, dynamic>> data;
  final String labelText;
  final void Function(String id)? onSelected;
  final String? initialId;

  const SearchableSelector({
    Key? key,
    required this.data,
    required this.labelText,
    this.onSelected,
    this.initialId,
  }) : super(key: key);

  @override
  State<SearchableSelector> createState() => _SearchableSelectorState();
}

class _SearchableSelectorState extends State<SearchableSelector> {
  final TextEditingController _controller = TextEditingController();
  String? selectedId;

  void _openSearchModal() async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => CustomSearchModal(data: widget.data),
    );

    if (result != null) {
      setState(() {
        selectedId = result['id'];
        _controller.text = result['name'] ?? '';
      });

      if (widget.onSelected != null) {
        widget.onSelected!(selectedId!);
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (widget.initialId != null) {
        selectedId = widget.initialId;
        final initialItem = widget.data.firstWhere(
          (item) => item['id'] == widget.initialId,
          orElse: () => {},
        );
        if (initialItem.isNotEmpty) {
          _controller.text = initialItem['name'] ?? '';
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.lightBlue.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              readOnly: true,
              decoration: InputDecoration(
                labelText: widget.labelText,
                border: InputBorder.none,
              ),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            decoration: BoxDecoration(
              color: Colors.blue.shade600,
              borderRadius: BorderRadius.circular(8),
            ),
            child: IconButton(
              onPressed: _openSearchModal,
              icon: const Icon(Icons.search, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
