import 'package:flutter/material.dart';
import 'package:life_auctor/utils/app_constants.dart';
import 'package:provider/provider.dart';
import 'package:life_auctor/models/shopping_list.dart';
import 'package:life_auctor/providers/shopping_list_provider_v2.dart';
import 'package:life_auctor/widgets/nav_bar/app_bar.dart';

class EditShoppingListScreen extends StatefulWidget {
  final ShoppingList list;
  final VoidCallback? onBack;

  const EditShoppingListScreen({
    super.key,
    required this.list,
    this.onBack,
  });

  @override
  State<EditShoppingListScreen> createState() => _EditShoppingListScreenState();
}

class _EditShoppingListScreenState extends State<EditShoppingListScreen> {
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late String _selectedCategory;
  late String _selectedPriority;
  late bool _enableNotifications;
  late bool _autoAddToCalendar;
  late List<String> _tags;
  final TextEditingController _tagController = TextEditingController();

  final List<String> _categories = [
    'Groceries',
    'Household',
    'Personal Care',
    'Electronics',
    'Clothing',
    'Other',
  ];

  final List<String> _priorities = ['Low', 'Normal', 'High'];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.list.name);
    _descriptionController = TextEditingController(
      text: widget.list.description ?? '',
    );
    _selectedCategory = widget.list.category ?? 'Groceries';
    _selectedPriority = widget.list.priority ?? 'Normal';
    _enableNotifications = widget.list.enableNotifications;
    _autoAddToCalendar = widget.list.autoAddToCalendar;
    _tags =
        widget.list.tags
            ?.split(',')
            .where((t) => t.trim().isNotEmpty)
            .toList() ??
        [];
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _tagController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a list name'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final provider = Provider.of<ShoppingListProviderV2>(
      context,
      listen: false,
    );

    final updatedList = widget.list.copyWith(
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
      category: _selectedCategory,
      priority: _selectedPriority,
      enableNotifications: _enableNotifications,
      autoAddToCalendar: _autoAddToCalendar,
      tags: _tags.join(','),
    );

    await provider.updateList(updatedList);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('List updated successfully'),
          backgroundColor: AppConstants.primaryGreen,
        ),
      );
      widget.onBack?.call();
    }
  }

  void _addTag() {
    final tag = _tagController.text.trim();
    if (tag.isNotEmpty && !_tags.contains(tag)) {
      setState(() {
        _tags.add(tag);
        _tagController.clear();
      });
    }
  }

  void _removeTag(String tag) {
    setState(() {
      _tags.remove(tag);
    });
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
            final titleSize = width * 0.065;
            final labelSize = width * 0.04;
            final inputSize = width * 0.042;

            return SingleChildScrollView(
              padding: EdgeInsets.all(padding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    'Edit Shopping List',
                    style: TextStyle(
                      fontSize: titleSize,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  SizedBox(height: padding * 1.5),

                  // Name
                  _buildLabel('List Name *', labelSize, isDark),
                  SizedBox(height: padding * 0.5),
                  _buildTextField(
                    controller: _nameController,
                    hint: 'e.g., Weekly Groceries',
                    isDark: isDark,
                    fontSize: inputSize,
                  ),
                  SizedBox(height: padding),

                  // Description
                  _buildLabel('Description', labelSize, isDark),
                  SizedBox(height: padding * 0.5),
                  _buildTextField(
                    controller: _descriptionController,
                    hint: 'Optional description',
                    isDark: isDark,
                    fontSize: inputSize,
                    maxLines: 3,
                  ),
                  SizedBox(height: padding),

                  // Category
                  _buildLabel('Category', labelSize, isDark),
                  SizedBox(height: padding * 0.5),
                  _buildDropdown(
                    value: _selectedCategory,
                    items: _categories,
                    onChanged: (value) =>
                        setState(() => _selectedCategory = value!),
                    isDark: isDark,
                    fontSize: inputSize,
                  ),
                  SizedBox(height: padding),

                  // Priority
                  _buildLabel('Priority', labelSize, isDark),
                  SizedBox(height: padding * 0.5),
                  _buildDropdown(
                    value: _selectedPriority,
                    items: _priorities,
                    onChanged: (value) =>
                        setState(() => _selectedPriority = value!),
                    isDark: isDark,
                    fontSize: inputSize,
                  ),
                  SizedBox(height: padding * 1.5),

                  // Tags
                  _buildLabel('Tags', labelSize, isDark),
                  SizedBox(height: padding * 0.5),
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          controller: _tagController,
                          hint: 'Add tag',
                          isDark: isDark,
                          fontSize: inputSize,
                        ),
                      ),
                      SizedBox(width: padding * 0.5),
                      IconButton(
                        onPressed: _addTag,
                        icon: const Icon(
                          Icons.add_circle,
                          color: AppConstants.primaryGreen,
                        ),
                        iconSize: padding * 1.5,
                      ),
                    ],
                  ),
                  if (_tags.isNotEmpty) ...[
                    SizedBox(height: padding * 0.5),
                    Wrap(
                      spacing: padding * 0.5,
                      runSpacing: padding * 0.5,
                      children: _tags.map((tag) {
                        return Chip(
                          label: Text(
                            tag,
                            style: TextStyle(fontSize: labelSize * 0.9),
                          ),
                          deleteIcon: const Icon(Icons.close, size: 16),
                          onDeleted: () => _removeTag(tag),
                          backgroundColor: isDark
                              ? const Color(0xFF1E1E1E)
                              : Colors.white,
                          labelStyle: TextStyle(
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                  SizedBox(height: padding * 1.5),

                  // Settings Section
                  _buildLabel('Settings', labelSize, isDark),
                  SizedBox(height: padding),

                  _buildSwitchTile(
                    'Enable Notifications',
                    'Get notified about this list',
                    _enableNotifications,
                    (val) => setState(() => _enableNotifications = val),
                    isDark,
                    labelSize,
                  ),
                  _buildSwitchTile(
                    'Auto-add to Calendar',
                    'Automatically add items to your calendar',
                    _autoAddToCalendar,
                    (val) => setState(() => _autoAddToCalendar = val),
                    isDark,
                    labelSize,
                  ),
                  SizedBox(height: padding * 2),

                  // Save Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _saveChanges,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppConstants.primaryGreen,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: padding),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Save Changes',
                        style: TextStyle(
                          fontSize: inputSize * 1.1,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: padding * 2),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildLabel(String text, double size, bool isDark) {
    return Text(
      text,
      style: TextStyle(
        fontSize: size,
        fontWeight: FontWeight.w600,
        color: isDark ? Colors.white : Colors.black87,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required bool isDark,
    required double fontSize,
    int maxLines = 1,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
        ),
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        style: TextStyle(
          fontSize: fontSize,
          color: isDark ? Colors.white : Colors.black87,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
            color: isDark ? Colors.grey[400] : Colors.grey[500],
            fontSize: fontSize,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String value,
    required List<String> items,
    required Function(String?) onChanged,
    required bool isDark,
    required double fontSize,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          icon: Icon(
            Icons.arrow_drop_down,
            color: isDark ? Colors.white : Colors.black87,
          ),
          style: TextStyle(
            fontSize: fontSize,
            color: isDark ? Colors.white : Colors.black87,
          ),
          dropdownColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          items: items.map((item) {
            return DropdownMenuItem(
              value: item,
              child: Text(item),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildSwitchTile(
    String title,
    String subtitle,
    bool value,
    Function(bool) onChanged,
    bool isDark,
    double fontSize,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: SwitchListTile(
        title: Text(
          title,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontSize: fontSize * 0.85,
            color: isDark ? Colors.grey[400] : Colors.grey[600],
          ),
        ),
        value: value,
        onChanged: onChanged,
        activeColor: AppConstants.primaryGreen,
      ),
    );
  }
}
