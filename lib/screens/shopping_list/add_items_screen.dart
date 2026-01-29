import 'package:flutter/material.dart';
import 'package:life_auctor/utils/app_constants.dart';
import 'package:provider/provider.dart';
import 'package:life_auctor/models/shopping_list.dart';
import 'package:life_auctor/providers/shopping_list_provider_v2.dart';
import 'package:life_auctor/providers/item_provider_v3.dart';

class AddItemsToListScreen extends StatefulWidget {
  final ShoppingList list;

  const AddItemsToListScreen({super.key, required this.list});

  @override
  State<AddItemsToListScreen> createState() => _AddItemsToListScreenState();
}

class _AddItemsToListScreenState extends State<AddItemsToListScreen> {
  String _searchQuery = '';
  final Set<String> _selectedItemIds = {};

  @override
  void initState() {
    super.initState();
    _selectedItemIds.addAll(widget.list.itemIds);
  }

  void _finishAddingItems() async {
    final listProvider = Provider.of<ShoppingListProviderV2>(context, listen: false);

    final updatedList = widget.list.copyWith(itemIds: _selectedItemIds.toList());

    try {
      await listProvider.updateList(updatedList);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('List "${widget.list.name}" created with ${_selectedItemIds.length} items'),
            backgroundColor: AppConstants.primaryGreen,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving list: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : Colors.grey[100],
      appBar: AppBar(
        backgroundColor: AppConstants.primaryGreen,
        title: Text('Add Items to "${widget.list.name}"', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Discard List?'),
                content: const Text('Going back will delete this list. Are you sure?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      if (!mounted) return;
                      final navigator = Navigator.of(context);
                      final listProvider = Provider.of<ShoppingListProviderV2>(context, listen: false);
                      await listProvider.deleteList(widget.list.id);
                      if (mounted) {
                        navigator.pop();
                        navigator.pop();
                      }
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    child: const Text('Discard'),
                  ),
                ],
              ),
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: _finishAddingItems,
            child: const Text('Done', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final padding = constraints.maxWidth * 0.04;

            return Column(
              children: [
                // Step indicator
                Padding(
                  padding: EdgeInsets.all(padding),
                  child: Row(
                    children: [
                      _buildStepDone(1, 'Configure', isDark),
                      Expanded(child: Container(height: 2, color: AppConstants.primaryGreen)),
                      _buildStepActive(2, 'Add Items', isDark),
                    ],
                  ),
                ),

                // Search bar
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: padding),
                  child: Container(
                    height: constraints.maxWidth * 0.11,
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextField(
                      onChanged: (value) => setState(() => _searchQuery = value),
                      style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                      decoration: InputDecoration(
                        hintText: 'Search items to add...',
                        hintStyle: TextStyle(color: isDark ? Colors.grey[600] : Colors.grey[400]),
                        prefixIcon: Icon(Icons.search, color: isDark ? Colors.grey[600] : Colors.grey[400]),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Selected count
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: padding),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Select items to add',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppConstants.primaryGreen,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${_selectedItemIds.length} selected',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),

                // Items list
                Expanded(
                  child: Consumer<ItemProviderV3>(
                    builder: (context, itemProvider, child) {
                      final filteredItems = itemProvider.items.where((item) {
                        return item.name.toLowerCase().contains(_searchQuery.toLowerCase());
                      }).toList();

                      if (filteredItems.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.inventory_2_outlined, size: 80, color: Colors.grey[400]),
                              const SizedBox(height: 16),
                              Text(
                                _searchQuery.isEmpty ? 'No items yet' : 'No items found',
                                style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                              ),
                              if (_searchQuery.isEmpty) ...[
                                const SizedBox(height: 8),
                                Text(
                                  'Add items first in My Items',
                                  style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                                ),
                              ],
                            ],
                          ),
                        );
                      }

                      return ListView.builder(
                        padding: EdgeInsets.symmetric(horizontal: padding),
                        itemCount: filteredItems.length,
                        itemBuilder: (context, index) {
                          final item = filteredItems[index];
                          final isSelected = _selectedItemIds.contains(item.id);

                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected ? AppConstants.primaryGreen : Colors.transparent,
                                width: 2,
                              ),
                            ),
                            child: CheckboxListTile(
                              value: isSelected,
                              onChanged: (value) {
                                setState(() {
                                  if (value == true) {
                                    _selectedItemIds.add(item.id);
                                  } else {
                                    _selectedItemIds.remove(item.id);
                                  }
                                });
                              },
                              title: Text(
                                item.name,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.white : Colors.black87,
                                ),
                              ),
                              subtitle: Text(
                                '${item.category}${item.quantity != null ? ' - ${item.quantity}' : ''}',
                                style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600]),
                              ),
                              secondary: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppConstants.primaryGreen.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  _getCategoryIcon(item.category),
                                  color: AppConstants.primaryGreen,
                                  size: 24,
                                ),
                              ),
                              activeColor: AppConstants.primaryGreen,
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildStepDone(int number, String label, bool isDark) {
    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: const BoxDecoration(
            color: AppConstants.primaryGreen,
            shape: BoxShape.circle,
          ),
          child: const Center(
            child: Icon(Icons.check, color: Colors.white, size: 20),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isDark ? Colors.white : Colors.black87,
            fontWeight: FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildStepActive(int number, String label, bool isDark) {
    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: const BoxDecoration(
            color: AppConstants.primaryGreen,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              '$number',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isDark ? Colors.white : Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'food':
        return Icons.fastfood;
      case 'drinks':
        return Icons.local_drink;
      case 'cleaning':
        return Icons.cleaning_services;
      case 'personal care':
        return Icons.spa;
      case 'health':
        return Icons.health_and_safety;
      default:
        return Icons.category;
    }
  }
}
