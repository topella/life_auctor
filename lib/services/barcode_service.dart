import 'dart:convert';
import 'package:http/http.dart' as http;

class BarcodeService {
  static const String _baseUrl = 'https://world.openfoodfacts.org/api/v0/product';
  static const Duration _requestTimeout = Duration(seconds: 10);
  static const Duration _cacheExpiration = Duration(hours: 24);
  static const int _maxCacheSize = 100;

  // In-memory cache: barcode -> (data, timestamp)
  final Map<String, _CachedProduct> _cache = {};

  // Category mapping (simplified and maintainable)
  static const _categoryKeywords = {
    'Makeup': ['beauty', 'cosmetic', 'skincare', 'makeup'],
    'Home': ['cleaning', 'household', 'detergent', 'soap'],
  };

  /// Get product information by barcode from Open Food Facts API
  Future<Map<String, String>?> getProductByBarcode(String barcode) async {
    // Check cache first
    if (_cache.containsKey(barcode)) {
      final cached = _cache[barcode]!;
      if (DateTime.now().difference(cached.timestamp) < _cacheExpiration) {
        return cached.data;
      } else {
        _cache.remove(barcode);
      }
    }

    try {
      final url = Uri.parse('$_baseUrl/$barcode.json');
      final response = await http.get(url).timeout(_requestTimeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['status'] == 1 && data['product'] != null) {
          final product = data['product'];

          final String? productName = product['product_name'] ?? product['product_name_en'];
          final String? brand = product['brands'];
          final category = _extractCategory(product['categories']);
          final String? quantity = product['quantity'];

          if (productName == null || productName.isEmpty) {
            return null;
          }

          final result = {
            'name': _buildProductName(productName, brand),
            'category': category,
            'quantity': quantity ?? '',
            'brand': brand ?? '',
          };

          _cache[barcode] = _CachedProduct(data: result, timestamp: DateTime.now());
          _cleanCacheIfNeeded();

          return result;
        }
      }

      _cache[barcode] = _CachedProduct(data: null, timestamp: DateTime.now());
      _cleanCacheIfNeeded();
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Clean cache if it exceeds max size (keeps newest 50%)
  void _cleanCacheIfNeeded() {
    if (_cache.length <= _maxCacheSize) return;

    final entries = _cache.entries.toList()
      ..sort((a, b) => b.value.timestamp.compareTo(a.value.timestamp));

    _cache.clear();
    for (var i = 0; i < _maxCacheSize ~/ 2; i++) {
      _cache[entries[i].key] = entries[i].value;
    }
  }

  /// Clear the cache
  void clearCache() => _cache.clear();

  /// Build product name with brand if available
  String _buildProductName(String name, String? brand) {
    if (brand != null && brand.isNotEmpty) {
      if (!name.toLowerCase().contains(brand.toLowerCase())) {
        return '$name ($brand)';
      }
    }
    return name;
  }

  /// Extract and map category using keyword matching
  String _extractCategory(String? categories) {
    if (categories == null || categories.isEmpty) {
      return 'Food';
    }

    final lowerCategories = categories.toLowerCase();

    // Check each category and its keywords
    for (final entry in _categoryKeywords.entries) {
      if (entry.value.any((keyword) => lowerCategories.contains(keyword))) {
        return entry.key;
      }
    }

    return 'Food'; // Default for all food-related or unknown items
  }
}

class _CachedProduct {
  final Map<String, String>? data;
  final DateTime timestamp;

  _CachedProduct({required this.data, required this.timestamp});
}
