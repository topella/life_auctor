import 'package:flutter_test/flutter_test.dart';
import 'package:life_auctor/models/item.dart';

void main() {
  group('Item Model Tests', () {
    test('should create an item with all fields', () {
      final now = DateTime.now();
      final item = Item.create(
        name: 'Milk',
        category: 'Dairy',
        expiryDate: now,
        quantity: '1L',
        location: 'Fridge',
        notes: 'Buy organic',
        price: 3.99,
        isFavorite: true,
        createdAt: now,
      );

      expect(item.name, 'Milk');
      expect(item.category, 'Dairy');
      expect(item.expiryDate, now);
      expect(item.quantity, '1L');
      expect(item.location, 'Fridge');
      expect(item.notes, 'Buy organic');
      expect(item.price, 3.99);
      expect(item.isFavorite, true);
      expect(item.createdAt, now);
      expect(item.id, isNotEmpty);
    });

    test('should create an item with only required fields', () {
      final item = Item.create(
        name: 'Bread',
        category: 'Bakery',
      );

      expect(item.name, 'Bread');
      expect(item.category, 'Bakery');
      expect(item.expiryDate, isNull);
      expect(item.quantity, isNull);
      expect(item.location, isNull);
      expect(item.notes, isNull);
      expect(item.price, isNull);
      expect(item.isFavorite, false);
      expect(item.id, isNotEmpty);
    });

    test('should convert item to JSON and back', () {
      final now = DateTime.now();
      final item = Item.create(
        name: 'Cheese',
        category: 'Dairy',
        expiryDate: now,
        quantity: '200g',
        price: 5.49,
        isFavorite: true,
      );

      final json = item.toJson();
      final itemFromJson = Item.fromJson(json);

      expect(itemFromJson.name, item.name);
      expect(itemFromJson.category, item.category);
      expect(itemFromJson.expiryDate?.millisecondsSinceEpoch,
          item.expiryDate?.millisecondsSinceEpoch);
      expect(itemFromJson.quantity, item.quantity);
      expect(itemFromJson.price, item.price);
      expect(itemFromJson.isFavorite, item.isFavorite);
    });

    test('should create a copy with modifications using copyWith', () {
      final item = Item.create(
        name: 'Milk',
        category: 'Dairy',
        isFavorite: false,
      );

      final updatedItem = item.copyWith(
        name: 'Almond Milk',
        isFavorite: true,
      );

      expect(updatedItem.name, 'Almond Milk');
      expect(updatedItem.category, 'Dairy'); // Unchanged
      expect(updatedItem.isFavorite, true);
      expect(updatedItem.id, item.id); // ID should remain the same
    });

    test('should compare items by ID', () {
      final item1 = Item.create(id: 'test-id-1', name: 'A', category: 'Cat1');
      final item2 = Item.create(id: 'test-id-1', name: 'B', category: 'Cat2');
      final item3 = Item.create(id: 'test-id-2', name: 'A', category: 'Cat1');

      expect(item1 == item2, true); // Same ID
      expect(item1 == item3, false); // Different ID
      expect(item1.hashCode, item2.hashCode); // Same hash for same ID
    });

    test('should generate unique IDs for different items', () {
      final item1 = Item.create(name: 'Item1', category: 'Cat1');
      final item2 = Item.create(name: 'Item2', category: 'Cat2');

      expect(item1.id, isNot(item2.id));
    });

    test('should handle null expiry date in JSON conversion', () {
      final item = Item.create(
        name: 'Salt',
        category: 'Spices',
        expiryDate: null,
      );

      final json = item.toJson();
      final itemFromJson = Item.fromJson(json);

      expect(itemFromJson.expiryDate, isNull);
    });

    test('should properly convert boolean to int in JSON', () {
      final item = Item.create(
        name: 'Eggs',
        category: 'Dairy',
        isFavorite: true,
      );

      final json = item.toJson();
      expect(json['isFavorite'], 1);

      final itemNotFavorite = Item.create(
        name: 'Bread',
        category: 'Bakery',
        isFavorite: false,
      );

      final json2 = itemNotFavorite.toJson();
      expect(json2['isFavorite'], 0);
    });

    test('toString should include basic info', () {
      final item = Item.create(
        id: 'test-id',
        name: 'Milk',
        category: 'Dairy',
        isFavorite: true,
      );

      final str = item.toString();
      expect(str, contains('test-id'));
      expect(str, contains('Milk'));
      expect(str, contains('Dairy'));
      expect(str, contains('true'));
    });
  });
}
