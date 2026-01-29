import 'package:flutter_test/flutter_test.dart';
import 'package:life_auctor/models/item.dart';
import 'package:life_auctor/core/extensions/item_extensions.dart';

void main() {
  group('Item Extensions Tests', () {
    group('ItemX (single item)', () {
      test('isExpired should return true for past dates', () {
        final item = Item.create(
          name: 'Expired Milk',
          category: 'Dairy',
          expiryDate: DateTime.now().subtract(const Duration(days: 1)),
        );

        expect(item.isExpired, true);
        expect(item.isExpiringSoon, false);
      });

      test('isExpired should return false for future dates', () {
        final item = Item.create(
          name: 'Fresh Milk',
          category: 'Dairy',
          expiryDate: DateTime.now().add(const Duration(days: 10)),
        );

        expect(item.isExpired, false);
      });

      test('isExpiringSoon should return true for items expiring within 3 days', () {
        final item = Item.create(
          name: 'Milk',
          category: 'Dairy',
          expiryDate: DateTime.now().add(const Duration(days: 2)),
        );

        expect(item.isExpiringSoon, true);
        expect(item.isExpired, false);
      });

      test('isExpiringSoon should return false for items expiring after 3 days', () {
        final item = Item.create(
          name: 'Milk',
          category: 'Dairy',
          expiryDate: DateTime.now().add(const Duration(days: 5)),
        );

        expect(item.isExpiringSoon, false);
      });

      test('isExpiringSoon should return false for expired items', () {
        final item = Item.create(
          name: 'Expired Milk',
          category: 'Dairy',
          expiryDate: DateTime.now().subtract(const Duration(days: 1)),
        );

        expect(item.isExpiringSoon, false);
      });

      test('isExpired and isExpiringSoon should return false for null expiryDate', () {
        final item = Item.create(
          name: 'Salt',
          category: 'Spices',
          expiryDate: null,
        );

        expect(item.isExpired, false);
        expect(item.isExpiringSoon, false);
      });
    });

    group('ItemListX (list of items)', () {
      late List<Item> items;

      setUp(() {
        items = [
          Item.create(
            name: 'Expired Milk',
            category: 'Dairy',
            expiryDate: DateTime.now().subtract(const Duration(days: 2)),
            isFavorite: true,
          ),
          Item.create(
            name: 'Expiring Soon Bread',
            category: 'Bakery',
            expiryDate: DateTime.now().add(const Duration(days: 1)),
            isFavorite: false,
          ),
          Item.create(
            name: 'Fresh Cheese',
            category: 'Dairy',
            expiryDate: DateTime.now().add(const Duration(days: 10)),
            isFavorite: true,
          ),
          Item.create(
            name: 'Another Expired',
            category: 'Food',
            expiryDate: DateTime.now().subtract(const Duration(days: 5)),
            isFavorite: false,
          ),
        ];
      });

      test('expired should return count of expired items', () {
        expect(items.expired, 2);
      });

      test('expiringSoon should return count of items expiring soon', () {
        expect(items.expiringSoon, 1);
      });

      test('favorites should return list of favorite items', () {
        final favorites = items.favorites;

        expect(favorites.length, 2);
        expect(favorites.every((item) => item.isFavorite), true);
      });

      test('byCategory should filter items by category', () {
        final dairyItems = items.byCategory('Dairy');

        expect(dairyItems.length, 2);
        expect(dairyItems.every((item) => item.category == 'Dairy'), true);
      });

      test('byCategory should return empty list for non-existent category', () {
        final result = items.byCategory('Electronics');

        expect(result.isEmpty, true);
      });

      test('search should find items by name', () {
        final result = items.search('Milk');

        expect(result.length, 1);
        expect(result.first.name, 'Expired Milk');
      });

      test('search should be case insensitive', () {
        final result = items.search('milk');

        expect(result.length, 1);
      });

      test('search should find items by category', () {
        final result = items.search('Dairy');

        expect(result.length, 2);
      });

      test('search should return empty list for no matches', () {
        final result = items.search('xyz123');

        expect(result.isEmpty, true);
      });

      test('empty list should return zero counts', () {
        final emptyList = <Item>[];

        expect(emptyList.expired, 0);
        expect(emptyList.expiringSoon, 0);
        expect(emptyList.favorites.isEmpty, true);
      });
    });
  });
}
