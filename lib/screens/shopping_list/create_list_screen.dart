import 'package:flutter/material.dart';
import 'package:life_auctor/utils/app_constants.dart';
import 'package:provider/provider.dart';
import 'package:life_auctor/models/shopping_list.dart';
import 'package:life_auctor/providers/shopping_list_provider_v2.dart';
import 'package:life_auctor/screens/shopping_list/add_items_screen.dart';

class CreateShoppingListScreen extends StatefulWidget {
  final Function(int)? onNavigate;

  const CreateShoppingListScreen({super.key, this.onNavigate});

  @override
  State<CreateShoppingListScreen> createState() => _CreateShoppingListScreenState();
}

class _CreateShoppingListScreenState extends State<CreateShoppingListScreen> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _tagsController = TextEditingController();

  bool _enableNotifications = true;
  bool _autoAddToCalendar = false;

  String _selectedCategory = 'General';
  String _selectedPriority = 'Medium';

  final List<String> _categories = ['General', 'Groceries', 'Party', 'Travel', 'Home', 'Personal'];
  final List<String> _priorities = ['Low', 'Medium', 'High', 'Urgent'];

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  void _createList() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a list name'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final listProvider = Provider.of<ShoppingListProviderV2>(context, listen: false);

    final newList = ShoppingList.create(
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim().isEmpty ? null : _descriptionController.text.trim(),
      category: _selectedCategory,
      priority: _selectedPriority,
      itemIds: [],
      enableNotifications: _enableNotifications,
      autoAddToCalendar: _autoAddToCalendar,
      tags: _tagsController.text.trim().isEmpty ? null : _tagsController.text.trim(),
    );

    try {
      await listProvider.addList(newList);

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => AddItemsToListScreen(list: newList),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error creating list: $e'),
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
        title: const Text('Create Shopping List', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: EdgeInsets.all(constraints.maxWidth * 0.04),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStepIndicator(isDark),
                  const SizedBox(height: 24),

                  // List Name
                  TextField(
                    controller: _nameController,
                    style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                    decoration: InputDecoration(
                      labelText: 'List Name *',
                      labelStyle: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600]),
                      hintText: 'e.g., Weekly Groceries',
                      hintStyle: TextStyle(color: isDark ? Colors.grey[600] : Colors.grey[400]),
                      prefixIcon: const Icon(Icons.title, color: AppConstants.primaryGreen),
                      filled: true,
                      fillColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppConstants.primaryGreen, width: 2),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: isDark ? Colors.grey[700]! : Colors.grey[300]!),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Description
                  TextField(
                    controller: _descriptionController,
                    maxLines: 3,
                    style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                    decoration: InputDecoration(
                      labelText: 'Description (optional)',
                      labelStyle: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600]),
                      hintText: 'Add details about this list...',
                      hintStyle: TextStyle(color: isDark ? Colors.grey[600] : Colors.grey[400]),
                      prefixIcon: const Icon(Icons.description_outlined, color: AppConstants.primaryGreen),
                      filled: true,
                      fillColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppConstants.primaryGreen, width: 2),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: isDark ? Colors.grey[700]! : Colors.grey[300]!),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Category
                  DropdownButtonFormField<String>(
                    value: _selectedCategory,
                    dropdownColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                    style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                    decoration: InputDecoration(
                      labelText: 'Category',
                      labelStyle: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600]),
                      prefixIcon: const Icon(Icons.category_outlined, color: AppConstants.primaryGreen),
                      filled: true,
                      fillColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppConstants.primaryGreen, width: 2),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: isDark ? Colors.grey[700]! : Colors.grey[300]!),
                      ),
                    ),
                    items: _categories.map((cat) => DropdownMenuItem(value: cat, child: Text(cat))).toList(),
                    onChanged: (value) => setState(() => _selectedCategory = value!),
                  ),
                  const SizedBox(height: 16),

                  // Priority
                  DropdownButtonFormField<String>(
                    value: _selectedPriority,
                    dropdownColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                    style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                    decoration: InputDecoration(
                      labelText: 'Priority',
                      labelStyle: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600]),
                      prefixIcon: const Icon(Icons.flag_outlined, color: AppConstants.primaryGreen),
                      filled: true,
                      fillColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppConstants.primaryGreen, width: 2),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: isDark ? Colors.grey[700]! : Colors.grey[300]!),
                      ),
                    ),
                    items: _priorities.map((priority) => DropdownMenuItem(value: priority, child: Text(priority))).toList(),
                    onChanged: (value) => setState(() => _selectedPriority = value!),
                  ),
                  const SizedBox(height: 20),

                  // Tags
                  TextField(
                    controller: _tagsController,
                    style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                    decoration: InputDecoration(
                      labelText: 'Tags (optional)',
                      labelStyle: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600]),
                      hintText: 'e.g., weekly, groceries',
                      hintStyle: TextStyle(color: isDark ? Colors.grey[600] : Colors.grey[400]),
                      prefixIcon: const Icon(Icons.tag, color: AppConstants.primaryGreen),
                      filled: true,
                      fillColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppConstants.primaryGreen, width: 2),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: isDark ? Colors.grey[700]! : Colors.grey[300]!),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Settings
                  Text(
                    'Settings',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        SwitchListTile(
                          value: _enableNotifications,
                          onChanged: (value) => setState(() => _enableNotifications = value),
                          title: const Text('Enable Notifications'),
                          subtitle: const Text('Get notified when items run out'),
                          secondary: const Icon(Icons.notifications_outlined, color: AppConstants.primaryGreen),
                          activeColor: AppConstants.primaryGreen,
                        ),
                        const Divider(height: 1),
                        SwitchListTile(
                          value: _autoAddToCalendar,
                          onChanged: (value) => setState(() => _autoAddToCalendar = value),
                          title: const Text('Add to Calendar'),
                          subtitle: const Text('Auto-create shopping reminders'),
                          secondary: const Icon(Icons.calendar_month_outlined, color: AppConstants.primaryGreen),
                          activeColor: AppConstants.primaryGreen,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Continue Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _createList,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppConstants.primaryGreen,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text(
                        'Continue to Add Items',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildStepIndicator(bool isDark) {
    return Row(
      children: [
        _buildStep(1, 'Configure', true, isDark),
        Expanded(child: Container(height: 2, color: Colors.grey[400])),
        _buildStep(2, 'Add Items', false, isDark),
      ],
    );
  }

  Widget _buildStep(int number, String label, bool isActive, bool isDark) {
    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: isActive ? AppConstants.primaryGreen : Colors.grey[400],
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
            color: isActive ? (isDark ? Colors.white : Colors.black87) : Colors.grey[600],
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}
