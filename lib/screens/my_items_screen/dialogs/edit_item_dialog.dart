import 'package:flutter/material.dart';
import 'package:life_auctor/models/item.dart';
import 'package:life_auctor/utils/app_constants.dart';

class EditItemDialog extends StatefulWidget {
  final Item item;
  final Function(Item) onSave;

  const EditItemDialog({
    super.key,
    required this.item,
    required this.onSave,
  });

  @override
  State<EditItemDialog> createState() => EditItemDialogState();
}

class EditItemDialogState extends State<EditItemDialog> {
  late TextEditingController _nameController;
  late TextEditingController _quantityController;
  late TextEditingController _locationController;
  late TextEditingController _notesController;
  late TextEditingController _priceController;
  late String _selectedCategory;
  late DateTime? _expiryDate;

  final List<String> _categories = ['Food', 'Makeup', 'Home', 'Tech', 'Other'];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.item.name);
    _quantityController = TextEditingController(text: widget.item.quantity ?? '');
    _locationController = TextEditingController(text: widget.item.location ?? '');
    _notesController = TextEditingController(text: widget.item.notes ?? '');
    _priceController = TextEditingController(text: widget.item.price != null ? widget.item.price!.toStringAsFixed(2) : '');
    _selectedCategory = widget.item.category;
    _expiryDate = widget.item.expiryDate;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    _locationController.dispose();
    _notesController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _selectExpiryDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _expiryDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppConstants.primaryGreen,
              onPrimary: Colors.white,
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

  void _saveChanges() {
    if (_nameController.text.isEmpty) return;

    final priceText = _priceController.text.trim();
    final price = priceText.isEmpty ? null : double.tryParse(priceText);

    final updatedItem = Item(
      id: widget.item.id,
      name: _nameController.text,
      category: _selectedCategory,
      quantity: _quantityController.text.isEmpty ? null : _quantityController.text,
      expiryDate: _expiryDate,
      location: _locationController.text.isEmpty ? null : _locationController.text,
      notes: _notesController.text.isEmpty ? null : _notesController.text,
      price: price,
      createdAt: widget.item.createdAt,
      isFavorite: widget.item.isFavorite,
      isConsumed: widget.item.isConsumed,
    );

    widget.onSave(updatedItem);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Container(
            constraints: const BoxConstraints(maxWidth: 500, maxHeight: 700),
            color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
            child: Column(
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    color: AppConstants.primaryGreen,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.edit_note, color: Colors.white, size: 28),
                      const SizedBox(width: 12),
                      const Text(
                        'Edit Item',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),

                // Content
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Item Name
                        TextField(
                          controller: _nameController,
                          style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                          decoration: InputDecoration(
                            labelText: 'Item Name *',
                            labelStyle: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600]),
                            hintText: 'e.g., Milk',
                            hintStyle: TextStyle(color: isDark ? Colors.grey[500] : Colors.grey[400]),
                            prefixIcon: const Icon(Icons.inventory_2_outlined, color: AppConstants.primaryGreen),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: isDark ? Colors.grey[700]! : Colors.grey[300]!),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: AppConstants.primaryGreen, width: 2),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Category
                        DropdownButtonFormField<String>(
                          value: _selectedCategory,
                          style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                          dropdownColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                          decoration: InputDecoration(
                            labelText: 'Category',
                            labelStyle: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600]),
                            prefixIcon: const Icon(Icons.category_outlined, color: AppConstants.primaryGreen),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: isDark ? Colors.grey[700]! : Colors.grey[300]!),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: AppConstants.primaryGreen, width: 2),
                            ),
                          ),
                          items: _categories.map((cat) => DropdownMenuItem(value: cat, child: Text(cat))).toList(),
                          onChanged: (value) => setState(() => _selectedCategory = value!),
                        ),
                        const SizedBox(height: 16),

                        // Quantity
                        TextField(
                          controller: _quantityController,
                          style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                          decoration: InputDecoration(
                            labelText: 'Quantity (optional)',
                            labelStyle: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600]),
                            hintText: 'e.g., 2 bottles, 500g',
                            hintStyle: TextStyle(color: isDark ? Colors.grey[500] : Colors.grey[400]),
                            prefixIcon: const Icon(Icons.numbers_outlined, color: AppConstants.primaryGreen),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: isDark ? Colors.grey[700]! : Colors.grey[300]!),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: AppConstants.primaryGreen, width: 2),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Price
                        TextField(
                          controller: _priceController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                          decoration: InputDecoration(
                            labelText: 'Price (optional)',
                            labelStyle: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600]),
                            hintText: 'e.g., 2.99',
                            hintStyle: TextStyle(color: isDark ? Colors.grey[500] : Colors.grey[400]),
                            prefixIcon: const Icon(Icons.attach_money, color: AppConstants.primaryGreen),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: isDark ? Colors.grey[700]! : Colors.grey[300]!),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: AppConstants.primaryGreen, width: 2),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Expiry Date
                        InkWell(
                          onTap: _selectExpiryDate,
                          child: InputDecorator(
                            decoration: InputDecoration(
                              labelText: 'Expiry Date',
                              labelStyle: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600]),
                              prefixIcon: const Icon(Icons.calendar_today, color: AppConstants.primaryGreen),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: isDark ? Colors.grey[700]! : Colors.grey[300]!),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: AppConstants.primaryGreen, width: 2),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  _expiryDate != null
                                      ? '${_expiryDate!.day.toString().padLeft(2, '0')}.${_expiryDate!.month.toString().padLeft(2, '0')}.${_expiryDate!.year}'
                                      : 'No expiry date',
                                  style: TextStyle(
                                    color: _expiryDate != null ? (isDark ? Colors.white : Colors.black87) : (isDark ? Colors.grey[400] : Colors.grey[600]),
                                  ),
                                ),
                                if (_expiryDate != null)
                                  IconButton(
                                    icon: Icon(Icons.clear, size: 20, color: isDark ? Colors.grey[400] : Colors.grey[600]),
                                    onPressed: () => setState(() => _expiryDate = null),
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                  ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Location
                        TextField(
                          controller: _locationController,
                          style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                          decoration: InputDecoration(
                            labelText: 'Location (optional)',
                            labelStyle: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600]),
                            hintText: 'e.g., Fridge, Pantry',
                            hintStyle: TextStyle(color: isDark ? Colors.grey[500] : Colors.grey[400]),
                            prefixIcon: const Icon(Icons.place_outlined, color: AppConstants.primaryGreen),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: isDark ? Colors.grey[700]! : Colors.grey[300]!),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: AppConstants.primaryGreen, width: 2),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Notes
                        TextField(
                          controller: _notesController,
                          maxLines: 3,
                          style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                          decoration: InputDecoration(
                            labelText: 'Notes (optional)',
                            labelStyle: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600]),
                            hintText: 'Add any additional information...',
                            hintStyle: TextStyle(color: isDark ? Colors.grey[500] : Colors.grey[400]),
                            prefixIcon: const Icon(Icons.note_outlined, color: AppConstants.primaryGreen),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: isDark ? Colors.grey[700]! : Colors.grey[300]!),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: AppConstants.primaryGreen, width: 2),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Actions
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey[900] : Colors.grey[50],
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
                        child: Text('Cancel', style: TextStyle(fontSize: 16, color: isDark ? Colors.grey[300] : Colors.black87)),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: _saveChanges,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppConstants.primaryGreen,
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: const Text('Save Changes', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
