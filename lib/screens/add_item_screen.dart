import 'package:flutter/material.dart';
import 'package:life_auctor/utils/app_constants.dart';
import 'package:provider/provider.dart';
import 'package:life_auctor/models/item.dart';
import 'package:life_auctor/providers/item_provider_v3.dart';
import 'package:life_auctor/widgets/nav_bar/app_bar.dart';
import 'package:life_auctor/widgets/nav_bar/bottom_bar.dart';
import 'package:life_auctor/widgets/form/form_label.dart';
import 'package:life_auctor/widgets/form/form_text_field.dart';
import 'package:life_auctor/widgets/form/form_dropdown.dart';
import 'package:life_auctor/widgets/form/date_picker_field.dart';
import 'package:life_auctor/widgets/form/favorite_toggle.dart';
import 'package:life_auctor/utils/form_validators.dart';
import 'package:life_auctor/constants/app_categories.dart';

class AddItemScreen extends StatefulWidget {
  final VoidCallback? onBack;
  final Function(int)? onNavigate;
  final String? scannedBarcode;
  final Map<String, String>? prefilledData;

  const AddItemScreen({
    super.key,
    this.onBack,
    this.onNavigate,
    this.scannedBarcode,
    this.prefilledData,
  });

  @override
  State<AddItemScreen> createState() => _AddItemScreenState();
}

class _AddItemScreenState extends State<AddItemScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _quantityController = TextEditingController();
  final _locationController = TextEditingController();
  final _priceController = TextEditingController();

  String _selectedCategory = AppCategories.food;
  DateTime? _expiryDate;
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    _prefillData();
  }

  void _prefillData() {
    if (widget.prefilledData != null) {
      _nameController.text = widget.prefilledData!['name'] ?? '';
      _quantityController.text = widget.prefilledData!['quantity'] ?? '';
      if (widget.prefilledData!['category'] != null) {
        _selectedCategory = widget.prefilledData!['category']!;
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    _locationController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _expiryDate ?? DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppConstants.primaryGreen,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() => _expiryDate = picked);
    }
  }

  Future<void> _saveItem() async {
    if (!_formKey.currentState!.validate()) return;

    final priceText = _priceController.text.trim();
    final price = priceText.isEmpty ? null : double.tryParse(priceText);

    final newItem = Item.create(
      name: _nameController.text.trim(),
      category: _selectedCategory,
      quantity: _quantityController.text.trim().isEmpty
          ? null
          : _quantityController.text.trim(),
      location: _locationController.text.trim().isEmpty
          ? null
          : _locationController.text.trim(),
      expiryDate: _expiryDate,
      price: price,
      isFavorite: _isFavorite,
    );

    await context.read<ItemProviderV3>().addItem(newItem);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${newItem.name} added successfully!'),
        backgroundColor: AppConstants.primaryGreen,
        duration: const Duration(seconds: 2),
      ),
    );

    widget.onBack?.call();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : Colors.grey[100],
      appBar: CustomAppBar(showBackButton: true, onBack: widget.onBack),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Add New Item',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 24),

                const FormLabel('Product Name *'),
                FormTextField(
                  controller: _nameController,
                  hint: 'e.g., Milk, Bread, Shampoo',
                  validator: FormValidators.required('product name'),
                ),
                const SizedBox(height: 16),

                const FormLabel('Category'),
                FormDropdown(
                  value: _selectedCategory,
                  items: AppCategories.all,
                  onChanged: (value) =>
                      setState(() => _selectedCategory = value!),
                ),
                const SizedBox(height: 16),

                const FormLabel('Quantity'),
                FormTextField(
                  controller: _quantityController,
                  hint: 'e.g., 1 liter, 500g, 2 pieces',
                ),
                const SizedBox(height: 16),

                const FormLabel('Location'),
                FormTextField(
                  controller: _locationController,
                  hint: 'e.g., Fridge, Pantry, Bathroom',
                ),
                const SizedBox(height: 16),

                const FormLabel('Price'),
                FormTextField(
                  controller: _priceController,
                  hint: 'e.g., 2.99',
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                ),
                const SizedBox(height: 16),

                const FormLabel('Expiry Date'),
                DatePickerField(
                  selectedDate: _expiryDate,
                  onTap: _selectDate,
                  placeholder: 'Select expiry date (optional)',
                ),
                const SizedBox(height: 16),

                FavoriteToggle(
                  isFavorite: _isFavorite,
                  onTap: () => setState(() => _isFavorite = !_isFavorite),
                ),
                const SizedBox(height: 32),

                _buildActionButtons(isDark),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomBar(
        currentIndex: 1,
        onTap: (index) {
          widget.onBack?.call();
          widget.onNavigate?.call(index);
        },
      ),
    );
  }

  Widget _buildActionButtons(bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: 130,
          height: 50,
          child: OutlinedButton(
            onPressed: widget.onBack,
            style: OutlinedButton.styleFrom(
              foregroundColor: isDark ? Colors.grey[400] : Colors.grey[600],
              side: BorderSide(
                color: isDark ? Colors.grey[700]! : Colors.grey[200]!,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Cancel',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ),
        const SizedBox(width: 16),
        SizedBox(
          width: 130,
          height: 50,
          child: ElevatedButton(
            onPressed: _saveItem,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConstants.primaryGreen,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Add Item',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    );
  }
}
