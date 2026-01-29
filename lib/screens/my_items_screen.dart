import 'package:flutter/material.dart';
import 'package:life_auctor/utils/app_constants.dart';
import 'package:provider/provider.dart';
import 'package:life_auctor/models/item.dart';
import 'package:life_auctor/providers/item_provider_v3.dart';
import 'package:life_auctor/screens/my_items_screen/widgets/item_card.dart';
import 'package:life_auctor/screens/my_items_screen/dialogs/edit_item_dialog.dart';
import 'package:life_auctor/widgets/nav_bar.dart/app_bar.dart';
import 'package:life_auctor/widgets/nav_bar.dart/bottom_bar.dart';

class MyItemsScreen extends StatefulWidget {
  final VoidCallback? onBack;
  final Function(int)? onNavigate;

  const MyItemsScreen({super.key, this.onBack, this.onNavigate});

  @override
  State<MyItemsScreen> createState() => _MyItemsScreenState();
}

class _MyItemsScreenState extends State<MyItemsScreen> {
  String _selectedCategory = 'All';
  final String _sortBy = 'Expiring soon';
  final TextEditingController _searchController = TextEditingController();

  final List<String> _categories = ['All', 'Favorites', 'Food', 'Makeup', 'Home', 'Tech', 'Other'];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : Colors.grey[100],
      appBar: CustomAppBar(
        showBackButton: true,
        onBack: widget.onBack,
      ),
      body: SafeArea(
        child: Consumer<ItemProviderV3>(
          builder: (context, itemProvider, child) {
            if (itemProvider.isLoading) {
              return const Center(
                child: CircularProgressIndicator(
                  color: AppConstants.primaryGreen,
                ),
              );
            }

            return LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth;

                // Calculate sizes based on width
                final padding = width * 0.04;
                final titleSize = width * 0.072;
                final searchBarHeight = width * 0.11;
                final searchFontSize = width * 0.037;
                final searchIconSize = width * 0.063;
                final categoryPadding = width * 0.04;
                final categoryFontSize = width * 0.037;
                final categoryIconSize = width * 0.042;
                final sortFontSize = width * 0.037;
                final sortIconSize = width * 0.053;
                final emptyIconSize = width * 0.17;
                final emptyTitleSize = width * 0.042;
                final emptySubtitleSize = width * 0.037;

                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: padding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: padding),
                      _buildSearchBar(context, searchBarHeight, searchFontSize, searchIconSize),
                      SizedBox(height: padding),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'My Items',
                          style: TextStyle(
                            fontSize: titleSize,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                      ),
                      SizedBox(height: padding * 0.75),
                      _buildCategoryFilter(context, itemProvider, categoryPadding, categoryFontSize, categoryIconSize),
                      SizedBox(height: padding * 0.75),
                      _buildSortDropdown(context, padding, sortFontSize, sortIconSize),
                      SizedBox(height: padding * 0.5),
                      Expanded(
                        child: _buildItemsList(
                          context,
                          itemProvider,
                          width,
                          padding,
                          emptyIconSize,
                          emptyTitleSize,
                          emptySubtitleSize,
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
      bottomNavigationBar: BottomBar(
        currentIndex: 1,
        onTap: (index) {
          widget.onBack?.call();
          widget.onNavigate?.call(index);
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          widget.onNavigate?.call(6);
        },
        backgroundColor: AppConstants.primaryGreen,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context, double height, double fontSize, double iconSize) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: height,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: _searchController,
        style: TextStyle(
          fontSize: fontSize,
          color: isDark ? Colors.white : Colors.black87,
        ),
        decoration: InputDecoration(
          hintText: 'Search items...',
          hintStyle: TextStyle(
            color: isDark ? Colors.grey[400] : Colors.grey[400],
            fontSize: fontSize,
          ),
          prefixIcon: Icon(
            Icons.search,
            color: isDark ? Colors.grey[400] : Colors.grey[400],
            size: iconSize,
          ),
          suffixIcon: Icon(
            Icons.tune,
            color: isDark ? Colors.grey[400] : Colors.grey[600],
            size: iconSize,
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: height * 0.27),
        ),
      ),
    );
  }

  Widget _buildCategoryFilter(BuildContext context, ItemProviderV3 itemProvider, double padding, double fontSize, double iconSize) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _categories.map((category) {
          final isSelected = _selectedCategory == category;
          final count = itemProvider.getCountByCategory(category);

          return Padding(
            padding: EdgeInsets.only(right: padding * 0.5),
            child: GestureDetector(
              onTap: () => setState(() => _selectedCategory = category),
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: padding,
                  vertical: padding * 0.5,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? AppConstants.primaryGreen : (isDark ? const Color(0xFF1E1E1E) : Colors.white),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (category == 'Favorites')
                      Padding(
                        padding: EdgeInsets.only(right: padding * 0.25),
                        child: Icon(
                          Icons.star,
                          size: iconSize,
                          color: isSelected ? Colors.white : Colors.amber,
                        ),
                      ),
                    Text(
                      category == 'All' || category == 'Favorites' ? '$category ($count)' : category,
                      style: TextStyle(
                        fontSize: fontSize,
                        color: isSelected ? Colors.white : (isDark ? Colors.white : Colors.black87),
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSortDropdown(BuildContext context, double padding, double fontSize, double iconSize) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: padding * 0.75,
        vertical: padding * 0.5,
      ),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Sort by: $_sortBy',
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black87,
              fontSize: fontSize,
            ),
          ),
          SizedBox(width: padding * 0.25),
          Icon(
            Icons.keyboard_arrow_down,
            color: isDark ? Colors.grey[400] : Colors.grey[600],
            size: iconSize,
          ),
        ],
      ),
    );
  }

  Widget _buildItemsList(
    BuildContext context,
    ItemProviderV3 itemProvider,
    double width,
    double padding,
    double emptyIconSize,
    double emptyTitleSize,
    double emptySubtitleSize,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final filteredItems = itemProvider.getItemsByCategory(_selectedCategory);

    if (filteredItems.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _selectedCategory == 'Favorites' ? Icons.star_border : Icons.inventory_2_outlined,
              size: emptyIconSize,
              color: isDark ? Colors.grey[400] : Colors.grey[400],
            ),
            SizedBox(height: padding),
            Text(
              _selectedCategory == 'Favorites' ? 'No favorite items yet' : 'No items found',
              style: TextStyle(
                fontSize: emptyTitleSize,
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
            SizedBox(height: padding * 0.5),
            Text(
              _selectedCategory == 'Favorites'
                  ? 'Tap the star icon to add favorites'
                  : 'Tap + to add your first item',
              style: TextStyle(
                fontSize: emptySubtitleSize,
                color: isDark ? Colors.grey[500] : Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: filteredItems.length,
      itemBuilder: (context, index) {
        return ItemCard(
          item: filteredItems[index],
          width: width,
          onToggleFavorite: () {
            itemProvider.toggleFavorite(filteredItems[index].id);
          },
          onToggleConsumed: () {
            itemProvider.toggleConsumed(filteredItems[index].id);
          },
          onDelete: () {
            itemProvider.deleteItem(filteredItems[index].id);
          },
          onEdit: () {
            _showEditDialog(context, filteredItems[index], itemProvider);
          },
        );
      },
    );
  }

  void _showEditDialog(BuildContext context, Item item, ItemProviderV3 provider) {
    showDialog(
      context: context,
      builder: (context) => EditItemDialog(
        item: item,
        onSave: (updatedItem) {
          provider.updateItem(updatedItem);
        },
      ),
    );
  }
}
