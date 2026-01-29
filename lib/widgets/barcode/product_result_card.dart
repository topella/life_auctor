import 'package:flutter/material.dart';

enum ProductResultState { loading, notFound, found }

class ProductResultCard extends StatelessWidget {
  final ProductResultState state;
  final String? barcode;
  final Map<String, String>? productData;
  final VoidCallback onAddManually;
  final VoidCallback onScanAgain;
  final VoidCallback onAddItem;

  const ProductResultCard({
    super.key,
    required this.state,
    this.barcode,
    this.productData,
    required this.onAddManually,
    required this.onScanAgain,
    required this.onAddItem,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 24,
      right: 24,
      bottom: 24,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    switch (state) {
      case ProductResultState.loading:
        return const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: Color(0xFF8AC926)),
            SizedBox(height: 16),
            Text(
              'Looking up product...',
              style: TextStyle(fontSize: 16, color: Colors.black87),
            ),
          ],
        );

      case ProductResultState.notFound:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(
              icon: Icons.error_outline,
              color: Colors.orange.shade400,
              title: 'Product Not Found',
            ),
            const SizedBox(height: 16),
            Text(
              'Barcode: $barcode',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            Text(
              'This product is not found in our database. Please add it manually.',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 20),
            _buildActions(
              primaryText: 'Add Manually',
              primaryAction: onAddManually,
              secondaryText: 'Scan Again',
              secondaryAction: onScanAgain,
            ),
          ],
        );

      case ProductResultState.found:
        final details = [
          if (productData?['quantity']?.isNotEmpty == true) productData!['quantity'],
          if (productData?['category']?.isNotEmpty == true) productData!['category'],
          if (productData?['brand']?.isNotEmpty == true) productData!['brand'],
        ].where((s) => s != null && s.isNotEmpty).join(' • ');

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(
              icon: Icons.check_circle,
              color: const Color(0xFF8AC926),
              title: 'Product Found!',
            ),
            const SizedBox(height: 16),
            Text(
              productData?['name'] ?? 'Unknown Product',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            if (details.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(details, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
            ],
            const SizedBox(height: 20),
            _buildActions(
              primaryText: 'Add Item',
              primaryAction: onAddItem,
              secondaryText: 'Scan Again',
              secondaryAction: onScanAgain,
              secondaryColor: const Color(0xFFE6A817),
            ),
          ],
        );
    }
  }

  Widget _buildHeader({
    required IconData icon,
    required Color color,
    required String title,
  }) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildActions({
    required String primaryText,
    required VoidCallback primaryAction,
    required String secondaryText,
    required VoidCallback secondaryAction,
    Color? secondaryColor,
  }) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: primaryAction,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF8AC926),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text(
              primaryText,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton(
            onPressed: secondaryAction,
            style: OutlinedButton.styleFrom(
              foregroundColor: secondaryColor ?? Colors.grey[700],
              side: BorderSide(color: secondaryColor ?? Colors.grey[400]!),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text(
              secondaryText,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    );
  }
}
