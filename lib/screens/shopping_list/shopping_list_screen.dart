import 'package:flutter/material.dart';
import 'package:life_auctor/utils/date_formatter.dart';
import 'package:life_auctor/utils/app_constants.dart';
import 'package:provider/provider.dart';
import 'package:life_auctor/widgets/nav_bar/app_bar.dart';
import 'package:life_auctor/providers/shopping_list_provider_v2.dart';
import 'package:life_auctor/widgets/guest_banner.dart';
import 'package:life_auctor/screens/shopping_list/create_list_screen.dart';
import 'package:life_auctor/screens/shopping_list/detail_screen.dart';
import 'package:life_auctor/screens/shopping_list/widgets/export_dialog.dart';

class ShoppingListScreen extends StatefulWidget {
  final Function(int)? onNavigate;
  final VoidCallback? onBack;

  const ShoppingListScreen({super.key, this.onNavigate, this.onBack});

  @override
  State<ShoppingListScreen> createState() => _ShoppingListScreenState();
}

class _ShoppingListScreenState extends State<ShoppingListScreen> {
  String _searchQuery = '';

  void _showCreateListDialog() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateShoppingListScreen(
          onNavigate: widget.onNavigate,
        ),
      ),
    );
  }

  void _showExportDialog() {
    final listProvider = Provider.of<ShoppingListProviderV2>(
      context,
      listen: false,
    );

    if (listProvider.lists.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No lists available to export'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => ExportListDialog(lists: listProvider.lists),
    );
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
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final padding = width * 0.04;
            final titleSize = width * 0.072;
            final searchBarHeight = width * 0.11;
            final searchFontSize = width * 0.037;
            final buttonFontSize = width * 0.037;
            final listTitleSize = width * 0.045;
            final listSubtitleSize = width * 0.035;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Guest banner
                const GuestBanner(
                  message:
                      'Guest mode: you can create lists, but cannot share them with other users.',
                  icon: Icons.share_outlined,
                ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.all(padding),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSearchBar(
                          searchBarHeight,
                          searchFontSize,
                          padding,
                          isDark,
                        ),
                        SizedBox(height: padding),
                        Text(
                          'Shopping Lists',
                          style: TextStyle(
                            fontSize: titleSize,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                        SizedBox(height: padding),
                        _buildActionButtons(padding, buttonFontSize),
                        SizedBox(height: padding * 1.5),
                        Text(
                          'My Lists',
                          style: TextStyle(
                            fontSize: listTitleSize,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                        SizedBox(height: padding),
                        Expanded(
                          child: _buildListsView(
                            padding,
                            listTitleSize,
                            listSubtitleSize,
                            isDark,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildSearchBar(
    double height,
    double fontSize,
    double padding,
    bool isDark,
  ) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        onChanged: (value) => setState(() => _searchQuery = value),
        style: TextStyle(
          fontSize: fontSize,
          color: isDark ? Colors.white : Colors.black87,
        ),
        decoration: InputDecoration(
          hintText: 'Search lists...',
          hintStyle: TextStyle(
            color: isDark ? Colors.grey[600] : Colors.grey[400],
            fontSize: fontSize,
          ),
          prefixIcon: Icon(
            Icons.search,
            color: isDark ? Colors.grey[600] : Colors.grey[400],
            size: fontSize * 1.7,
          ),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: Icon(
                    Icons.clear,
                    color: isDark ? Colors.grey[500] : Colors.grey[600],
                    size: fontSize * 1.7,
                  ),
                  onPressed: () => setState(() => _searchQuery = ''),
                )
              : null,
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: height * 0.27),
        ),
      ),
    );
  }

  Widget _buildActionButtons(double padding, double fontSize) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _showCreateListDialog,
            icon: Icon(
              Icons.add_circle_outline,
              color: AppConstants.primaryGreen,
              size: fontSize * 1.5,
            ),
            label: Text(
              'Create new list',
              style: TextStyle(
                fontSize: fontSize,
                color: AppConstants.primaryGreen,
              ),
            ),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(
                color: AppConstants.primaryGreen,
                width: 2,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: EdgeInsets.symmetric(vertical: padding),
            ),
          ),
        ),
        SizedBox(width: padding),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _showExportDialog,
            icon: Icon(
              Icons.ios_share,
              color: Colors.orange,
              size: fontSize * 1.5,
            ),
            label: Text(
              'Export list',
              style: TextStyle(fontSize: fontSize, color: Colors.orange),
            ),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.orange, width: 2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: EdgeInsets.symmetric(vertical: padding),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildListsView(
    double padding,
    double titleSize,
    double subtitleSize,
    bool isDark,
  ) {
    return Consumer<ShoppingListProviderV2>(
      builder: (context, listProvider, child) {
        if (listProvider.isLoading) {
          return const Center(
            child: CircularProgressIndicator(color: AppConstants.primaryGreen),
          );
        }

        final filteredLists = listProvider.lists.where((list) {
          return list.name.toLowerCase().contains(_searchQuery.toLowerCase());
        }).toList();

        if (filteredLists.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.shopping_cart_outlined,
                  size: 80,
                  color: Colors.grey[400],
                ),
                SizedBox(height: padding),
                Text(
                  _searchQuery.isEmpty
                      ? 'No shopping lists yet'
                      : 'No lists found',
                  style: TextStyle(
                    fontSize: titleSize * 0.7,
                    color: Colors.grey[600],
                  ),
                ),
                if (_searchQuery.isEmpty) ...[
                  SizedBox(height: padding * 0.5),
                  Text(
                    'Tap "Create new list" to get started',
                    style: TextStyle(
                      fontSize: subtitleSize,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ],
            ),
          );
        }

        return ListView.builder(
          itemCount: filteredLists.length,
          itemBuilder: (context, index) {
            final list = filteredLists[index];
            return Dismissible(
              key: Key(list.id),
              direction: DismissDirection.endToStart,
              background: Container(
                alignment: Alignment.centerRight,
                padding: EdgeInsets.only(right: padding),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.delete, color: Colors.white, size: 32),
              ),
              confirmDismiss: (direction) async {
                return await showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Delete List'),
                    content: Text(
                      'Are you sure you want to delete "${list.name}"?',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancel'),
                      ),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context, true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),
                        child: const Text('Delete'),
                      ),
                    ],
                  ),
                );
              },
              onDismissed: (direction) async {
                if (!mounted) return;
                final messenger = ScaffoldMessenger.of(context);
                final listName = list.name;
                await listProvider.deleteList(list.id);
                if (mounted) {
                  messenger.showSnackBar(
                    SnackBar(content: Text('"$listName" deleted')),
                  );
                }
              },
              child: Container(
                margin: EdgeInsets.only(bottom: padding),
                padding: EdgeInsets.all(padding),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            ShoppingListDetailScreen(list: list),
                      ),
                    );
                  },
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              list.name,
                              style: TextStyle(
                                fontSize: titleSize,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                            ),
                            SizedBox(height: padding * 0.3),
                            Text(
                              '${list.itemIds.length} items - created ${DateFormatter.formatDate(list.createdAt)}',
                              style: TextStyle(
                                fontSize: subtitleSize,
                                color: isDark
                                    ? Colors.grey[400]
                                    : Colors.grey[600],
                              ),
                            ),
                            if (list.category != null) ...[
                              SizedBox(height: padding * 0.2),
                              Row(
                                children: [
                                  Icon(
                                    Icons.category_outlined,
                                    size: subtitleSize,
                                    color: Colors.grey[500],
                                  ),
                                  SizedBox(width: padding * 0.2),
                                  Text(
                                    list.category!,
                                    style: TextStyle(
                                      fontSize: subtitleSize * 0.9,
                                      color: isDark
                                          ? Colors.grey[500]
                                          : Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                            if (list.inStockCount > 0 ||
                                list.runOutCount > 0) ...[
                              SizedBox(height: padding * 0.2),
                              Text(
                                list.runOutCount > 0
                                    ? '${list.runOutCount} items run out'
                                    : '${list.inStockCount} items in stock',
                                style: TextStyle(
                                  fontSize: subtitleSize,
                                  color: list.runOutCount > 0
                                      ? Colors.orange
                                      : AppConstants.primaryGreen,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios,
                        color: isDark ? Colors.grey[600] : Colors.grey[400],
                        size: titleSize * 0.7,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
