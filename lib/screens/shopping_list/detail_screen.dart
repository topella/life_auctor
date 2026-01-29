import 'package:flutter/material.dart';
import 'package:life_auctor/utils/app_constants.dart';
import 'package:provider/provider.dart';
import 'package:life_auctor/models/shopping_list.dart';
import 'package:life_auctor/models/item.dart';
import 'package:life_auctor/providers/item_provider_v3.dart';
import 'package:life_auctor/screens/edit_shopping_list_screen.dart';

class ShoppingListDetailScreen extends StatelessWidget {
  final ShoppingList list;

  const ShoppingListDetailScreen({super.key, required this.list});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : Colors.grey[100],
      appBar: AppBar(
        backgroundColor: AppConstants.primaryGreen,
        title: Text(list.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditShoppingListScreen(
                    list: list,
                    onBack: () => Navigator.pop(context),
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Consumer<ItemProviderV3>(
        builder: (context, itemProvider, child) {
          final items = list.itemIds
              .map((id) => itemProvider.items.where((item) => item.id == id).firstOrNull)
              .whereType<Item>()
              .toList();

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (list.description != null) ...[
                Text(
                  list.description!,
                  style: TextStyle(fontSize: 16, color: isDark ? Colors.grey[400] : Colors.grey[600]),
                ),
                const SizedBox(height: 16),
              ],
              Text(
                'Items (${items.length})',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87),
              ),
              const SizedBox(height: 12),
              if (items.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Text(
                      'No items in this list',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ),
                )
              else
                ...items.map((item) => Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.check_circle_outline, color: Colors.grey[400]),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.name,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: isDark ? Colors.white : Colors.black87,
                                  ),
                                ),
                                if (item.quantity != null)
                                  Text(
                                    item.quantity!,
                                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    )),
            ],
          );
        },
      ),
    );
  }
}
