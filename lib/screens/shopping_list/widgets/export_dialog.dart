import 'package:flutter/material.dart';
import 'package:life_auctor/utils/date_formatter.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:life_auctor/models/shopping_list.dart';
import 'package:life_auctor/models/item.dart';
import 'package:life_auctor/providers/item_provider_v3.dart';

class ExportListDialog extends StatefulWidget {
  final List<ShoppingList> lists;

  const ExportListDialog({super.key, required this.lists});

  @override
  State<ExportListDialog> createState() => _ExportListDialogState();
}

class _ExportListDialogState extends State<ExportListDialog> {
  String? _selectedListId;

  void _exportList() async {
    if (_selectedListId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a list to export'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final list = widget.lists.firstWhere((l) => l.id == _selectedListId);
    final itemProvider = Provider.of<ItemProviderV3>(context, listen: false);

    final items = list.itemIds
        .map((id) => itemProvider.items.where((item) => item.id == id).firstOrNull)
        .whereType<Item>()
        .toList();

    final exportText = '''
Shopping List: ${list.name}
${list.description != null ? 'Description: ${list.description}\n' : ''}
Created: ${DateFormatter.formatDate(list.createdAt)}
Total Items: ${items.length}

Items:
${items.map((item) => '- ${item.name}${item.quantity != null ? ' (${item.quantity})' : ''}').join('\n')}
''';

    try {
      await Share.share(
        exportText,
        subject: 'Shopping List: ${list.name}',
      );

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error exporting list: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400, maxHeight: 500),
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Colors.orange,
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.ios_share, color: Colors.white, size: 28),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Export Shopping List',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  Text(
                    'Select a list to export:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...widget.lists.map((list) {
                    final isSelected = _selectedListId == list.id;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF2A2A2A) : Colors.grey[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected ? Colors.orange : (isDark ? Colors.grey[700]! : Colors.grey[300]!),
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: RadioListTile<String>(
                        value: list.id,
                        groupValue: _selectedListId,
                        onChanged: (value) => setState(() => _selectedListId = value),
                        title: Text(
                          list.name,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                        subtitle: Text(
                          '${list.itemIds.length} items',
                          style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600]),
                        ),
                        activeColor: Colors.orange,
                      ),
                    );
                  }),
                ],
              ),
            ),

            // Actions
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF2A2A2A) : Colors.grey[50],
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    child: Text('Cancel', style: TextStyle(fontSize: 16, color: isDark ? Colors.white : Colors.black87)),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _exportList,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('Export', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
