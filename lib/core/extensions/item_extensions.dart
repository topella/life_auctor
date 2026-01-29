import 'package:life_auctor/models/item.dart';

extension ItemX on Item {
  /// Check if item is expiring soon (within 3 days)
  bool get isExpiringSoon {
    if (expiryDate == null || isConsumed) return false;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final expiryDay = DateTime(
        expiryDate!.year, expiryDate!.month, expiryDate!.day);
    final days = expiryDay.difference(today).inDays;
    return days >= 0 && days <= 3;
  }

  /// Check if item is expired
  bool get isExpired {
    if (expiryDate == null || isConsumed) return false;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final expiryDay = DateTime(
        expiryDate!.year, expiryDate!.month, expiryDate!.day);
    return expiryDay.isBefore(today);
  }
}

extension ItemListX on List<Item> {
  /// Count items expiring soon
  int get expiringSoon => where((i) => i.isExpiringSoon).length;

  /// Count expired items
  int get expired => where((i) => i.isExpired).length;

  /// Get favorite items
  List<Item> get favorites => where((i) => i.isFavorite).toList();

  /// Filter items by category
  List<Item> byCategory(String cat) {
    if (cat == 'All') return this;
    if (cat == 'Favorites') return favorites;
    return where((i) => i.category == cat).toList();
  }

  /// Search items by query
  List<Item> search(String query) {
    if (query.isEmpty) return this;
    final q = query.toLowerCase();
    return where((i) =>
        i.name.toLowerCase().contains(q) ||
        i.category.toLowerCase().contains(q) ||
        (i.location?.toLowerCase().contains(q) ?? false) ||
        (i.notes?.toLowerCase().contains(q) ?? false)).toList();
  }
}
