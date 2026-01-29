import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:life_auctor/models/item.dart';
import 'package:life_auctor/models/shopping_list.dart';
import 'package:life_auctor/providers/item_provider_v3.dart';
import 'package:life_auctor/providers/shopping_list_provider_v2.dart';
import 'package:life_auctor/screens/edit_shopping_list_screen.dart';
import 'package:life_auctor/utils/app_constants.dart';
import 'package:life_auctor/utils/app_strings.dart';
import 'package:life_auctor/utils/app_screen.dart';
import 'package:life_auctor/utils/theme_extensions.dart';

class ScanItemButton extends StatelessWidget {
  final Function(int)? onNavigate;

  const ScanItemButton({super.key, this.onNavigate});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: AppConstants.spacing8),
      child: OutlinedButton(
        onPressed: () {
          if (onNavigate != null) {
            onNavigate!(AppScreen.barcode.value);
          }
        },
        style: OutlinedButton.styleFrom(
          padding: EdgeInsets.symmetric(
            horizontal: AppConstants.spacing16,
            vertical: AppConstants.spacing12,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.borderRadius12),
          ),
          side: BorderSide(
            color: context.adaptiveBorderColor,
            width: 1,
          ),
          backgroundColor: context.adaptiveBackgroundColor,
        ),
        child: Row(
          children: [
            Container(
              margin: EdgeInsets.symmetric(horizontal: AppConstants.spacing6),
              child: SvgPicture.asset(
                'assets/icons/scan_icon.svg',
                width: AppConstants.quickActionIconSize,
                height: AppConstants.quickActionIconSize,
                colorFilter: const ColorFilter.mode(
                  Colors.orange,
                  BlendMode.srcIn,
                ),
              ),
            ),
            Text(
              AppStrings.scanItem,
              style: TextStyle(
                color: context.adaptiveTextColor,
                fontSize: AppConstants.fontSize14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AddNewItemButton extends StatelessWidget {
  final Function(int)? onNavigate;

  const AddNewItemButton({super.key, this.onNavigate});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: () => _showAddItemDialog(context),
      style: OutlinedButton.styleFrom(
        padding: EdgeInsets.symmetric(
          horizontal: AppConstants.spacing18,
          vertical: AppConstants.spacing4,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius12),
        ),
        side: BorderSide(
          color: context.adaptiveBorderColor,
          width: 1,
        ),
        backgroundColor: context.adaptiveBackgroundColor,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            margin: EdgeInsets.symmetric(
              horizontal: AppConstants.spacing12,
              vertical: AppConstants.spacing8,
            ),
            child: SvgPicture.asset(
              'assets/icons/add_new_icon.svg',
              width: AppConstants.quickActionIconSize,
              height: AppConstants.quickActionIconSize,
              colorFilter: const ColorFilter.mode(
                Colors.green,
                BlendMode.srcIn,
              ),
            ),
          ),
          Text(
            AppStrings.addNewItem,
            style: TextStyle(
              color: context.adaptiveTextColor,
              fontSize: AppConstants.fontSize14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _showAddItemDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) => const AddItemDialog(),
    );
  }
}

class AddItemDialog extends StatefulWidget {
  const AddItemDialog({super.key});

  @override
  State<AddItemDialog> createState() => _AddItemDialogState();
}

class _AddItemDialogState extends State<AddItemDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _quantityController = TextEditingController();
  final _locationController = TextEditingController();
  final _priceController = TextEditingController();

  String _selectedCategory = 'Food';
  DateTime? _expiryDate;
  bool _isFavorite = false;
  String? _selectedListId;

  final List<String> _categories = ['Food', 'Tech', 'Makeup', 'Home', 'Other'];

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    _locationController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  InputDecoration _buildInputDecoration(BuildContext context, String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: context.adaptiveSecondaryTextColor),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadius8),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadius8),
        borderSide: BorderSide(color: context.adaptiveBorderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadius8),
        borderSide: BorderSide(color: AppConstants.primaryGreen),
      ),
    );
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
            colorScheme: ColorScheme.light(
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
    if (_formKey.currentState!.validate()) {
      final itemProvider = Provider.of<ItemProviderV3>(context, listen: false);
      final shoppingListProvider = Provider.of<ShoppingListProviderV2>(
        context,
        listen: false,
      );

      final priceText = _priceController.text.trim();
      final price = priceText.isEmpty ? null : double.tryParse(priceText);

      final newItem = Item.create(
        name: _nameController.text,
        category: _selectedCategory,
        expiryDate: _expiryDate,
        quantity: _quantityController.text.isEmpty
            ? null
            : _quantityController.text,
        location: _locationController.text.isEmpty
            ? null
            : _locationController.text,
        price: price,
        isFavorite: _isFavorite,
      );

      await itemProvider.addItem(newItem);

      if (_selectedListId != null) {
        final list = shoppingListProvider.lists.firstWhere(
          (l) => l.id == _selectedListId,
        );
        final updatedList = list.copyWith(
          itemIds: [...list.itemIds, newItem.id],
        );
        await shoppingListProvider.updateList(updatedList);
      }

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppStrings.itemAddedSuccess),
            backgroundColor: AppConstants.primaryGreen,
          ),
        );
      }
    }
  }

  void _showCreateListDialog() {
    Navigator.of(context).pop();

    final newList = ShoppingList.create(
      name: '',
      itemIds: [],
    );

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => EditShoppingListScreen(
          list: newList,
          onBack: () => Navigator.of(context).pop(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final shoppingListProvider = Provider.of<ShoppingListProviderV2>(context);
    final lists = shoppingListProvider.lists;

    return AlertDialog(
      backgroundColor: context.adaptiveBackgroundColor,
      title: Text(
        AppStrings.addNewItemTitle,
        style: TextStyle(
          color: context.adaptiveTextColor,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: _buildInputDecoration(context, AppStrings.itemName),
                style: TextStyle(color: context.adaptiveTextColor),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return AppStrings.pleaseEnterItemName;
                  }
                  return null;
                },
              ),
              SizedBox(height: AppConstants.spacing16),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: _buildInputDecoration(context, AppStrings.category),
                dropdownColor: context.adaptiveBackgroundColor,
                style: TextStyle(color: context.adaptiveTextColor),
                items: _categories.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (value) =>
                    setState(() => _selectedCategory = value!),
              ),
              SizedBox(height: AppConstants.spacing16),
              TextFormField(
                controller: _quantityController,
                decoration: _buildInputDecoration(context, AppStrings.quantity),
                style: TextStyle(color: context.adaptiveTextColor),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: AppConstants.spacing16),
              TextFormField(
                controller: _locationController,
                decoration: _buildInputDecoration(
                  context,
                  AppStrings.locationOptional,
                ),
                style: TextStyle(color: context.adaptiveTextColor),
              ),
              SizedBox(height: AppConstants.spacing16),
              TextFormField(
                controller: _priceController,
                decoration: _buildInputDecoration(context, 'Price'),
                style: TextStyle(color: context.adaptiveTextColor),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
              ),
              SizedBox(height: AppConstants.spacing16),
              InkWell(
                onTap: _selectDate,
                child: InputDecorator(
                  decoration: _buildInputDecoration(
                    context,
                    AppStrings.expiryDate,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _expiryDate != null
                            ? '${_expiryDate!.day}/${_expiryDate!.month}/${_expiryDate!.year}'
                            : AppStrings.selectDate,
                        style: TextStyle(
                          color: _expiryDate != null
                              ? context.adaptiveTextColor
                              : context.adaptiveSecondaryTextColor,
                        ),
                      ),
                      Icon(
                        Icons.calendar_today,
                        color: context.adaptiveSecondaryTextColor,
                        size: AppConstants.quickActionDateIconSize,
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: AppConstants.spacing16),
              Row(
                children: [
                  Checkbox(
                    value: _isFavorite,
                    activeColor: AppConstants.primaryGreen,
                    onChanged: (value) =>
                        setState(() => _isFavorite = value ?? false),
                  ),
                  Text(
                    AppStrings.markAsFavorite,
                    style: TextStyle(color: context.adaptiveTextColor),
                  ),
                ],
              ),
              SizedBox(height: AppConstants.spacing16),
              Text(
                AppStrings.addToShoppingList,
                style: TextStyle(
                  color: context.adaptiveTextColor,
                  fontWeight: FontWeight.w600,
                  fontSize: AppConstants.fontSize14,
                ),
              ),
              SizedBox(height: AppConstants.spacing8),
              if (lists.isEmpty)
                OutlinedButton.icon(
                  onPressed: _showCreateListDialog,
                  icon: Icon(Icons.add, color: AppConstants.primaryGreen),
                  label: Text(
                    AppStrings.createShoppingList,
                    style: TextStyle(color: AppConstants.primaryGreen),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: AppConstants.primaryGreen),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        AppConstants.borderRadius8,
                      ),
                    ),
                  ),
                )
              else
                Column(
                  children: [
                    DropdownButtonFormField<String>(
                      value: _selectedListId,
                      decoration: _buildInputDecoration(
                        context,
                        AppStrings.selectList,
                      ),
                      dropdownColor: context.adaptiveBackgroundColor,
                      style: TextStyle(color: context.adaptiveTextColor),
                      items: [
                        DropdownMenuItem<String>(
                          value: null,
                          child: Text(
                            AppStrings.none,
                            style: TextStyle(
                              color: context.adaptiveSecondaryTextColor,
                            ),
                          ),
                        ),
                        ...lists.map((list) {
                          return DropdownMenuItem(
                            value: list.id,
                            child: Text(list.name),
                          );
                        }),
                      ],
                      onChanged: (value) =>
                          setState(() => _selectedListId = value),
                    ),
                    SizedBox(height: AppConstants.spacing8),
                    TextButton.icon(
                      onPressed: _showCreateListDialog,
                      icon: Icon(
                        Icons.add,
                        color: AppConstants.primaryGreen,
                        size: AppConstants.quickActionIconSize18,
                      ),
                      label: Text(
                        AppStrings.createNewList,
                        style: TextStyle(color: AppConstants.primaryGreen),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            AppStrings.cancel,
            style: TextStyle(color: context.adaptiveSecondaryTextColor),
          ),
        ),
        ElevatedButton(
          onPressed: _saveItem,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppConstants.primaryGreen,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppConstants.borderRadius8),
            ),
          ),
          child: Text(AppStrings.addItem),
        ),
      ],
    );
  }
}
