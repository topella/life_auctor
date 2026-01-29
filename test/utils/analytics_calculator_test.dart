import 'package:flutter_test/flutter_test.dart';
import 'package:life_auctor/models/item.dart';
import 'package:life_auctor/utils/analytics_calculator.dart';

void main() {
  group('AnalyticsCalculator Tests', () {
    group('getStartDateForPeriod', () {
      test('should return 7 days ago for Week', () {
        final result = AnalyticsCalculator.getStartDateForPeriod('Week');
        final expected = DateTime.now().subtract(const Duration(days: 7));

        expect(result.day, expected.day);
        expect(result.month, expected.month);
      });

      test('should return 30 days ago for Month', () {
        final result = AnalyticsCalculator.getStartDateForPeriod('Month');
        final expected = DateTime.now().subtract(const Duration(days: 30));

        expect(result.day, expected.day);
        expect(result.month, expected.month);
      });

      test('should return 90 days ago for Quarter', () {
        final result = AnalyticsCalculator.getStartDateForPeriod('Quarter');
        final expected = DateTime.now().subtract(const Duration(days: 90));

        expect(result.day, expected.day);
      });

      test('should return year 2000 for unknown period', () {
        final result = AnalyticsCalculator.getStartDateForPeriod('Unknown');

        expect(result.year, 2000);
        expect(result.month, 1);
        expect(result.day, 1);
      });
    });

    group('calculateProductStats', () {
      test('should return zero stats for empty list', () {
        final result = AnalyticsCalculator.calculateProductStats([], 'Week');

        expect(result.totalAdded, 0);
        expect(result.expiredItems, 0);
        expect(result.usedBeforeExpiry, 0);
        expect(result.usedPercent, 0.0);
        expect(result.expiredPercent, 0.0);
      });

      test('should calculate correct stats for items in period', () {
        final items = [
          Item.create(
            name: 'Expired Item',
            category: 'Food',
            expiryDate: DateTime.now().subtract(const Duration(days: 1)),
            createdAt: DateTime.now().subtract(const Duration(days: 3)),
          ),
          Item.create(
            name: 'Fresh Item',
            category: 'Food',
            expiryDate: DateTime.now().add(const Duration(days: 10)),
            createdAt: DateTime.now().subtract(const Duration(days: 2)),
          ),
        ];

        final result = AnalyticsCalculator.calculateProductStats(items, 'Week');

        expect(result.totalAdded, 2);
        expect(result.expiredItems, 1);
        expect(result.usedBeforeExpiry, 1);
        expect(result.expiredPercent, 50.0);
        expect(result.usedPercent, 50.0);
      });

      test('should filter items outside period', () {
        final items = [
          Item.create(
            name: 'Old Item',
            category: 'Food',
            createdAt: DateTime.now().subtract(const Duration(days: 30)),
          ),
          Item.create(
            name: 'Recent Item',
            category: 'Food',
            createdAt: DateTime.now().subtract(const Duration(days: 2)),
          ),
        ];

        final result = AnalyticsCalculator.calculateProductStats(items, 'Week');

        expect(result.totalAdded, 1); // Only recent item
      });

      test('should handle items with null expiry date', () {
        final items = [
          Item.create(
            name: 'Salt',
            category: 'Spices',
            expiryDate: null,
            createdAt: DateTime.now(),
          ),
        ];

        final result = AnalyticsCalculator.calculateProductStats(items, 'Week');

        expect(result.totalAdded, 1);
        expect(result.expiredItems, 0);
        expect(result.usedBeforeExpiry, 1);
      });
    });

    group('calculateExpenseHistory', () {
      test('should return zero for empty list', () {
        final result = AnalyticsCalculator.calculateExpenseHistory([]);

        expect(result.currentMonthTotal, 0);
        expect(result.prevMonthTotal, 0);
        expect(result.percentChange, 0.0);
        expect(result.monthlyExpenses.length, 5);
        expect(result.monthlyExpenses.every((e) => e == 0), true);
      });

      test('should calculate current month total', () {
        final items = [
          Item.create(
            name: 'Item 1',
            category: 'Food',
            price: 10.0,
            createdAt: DateTime.now(),
          ),
          Item.create(
            name: 'Item 2',
            category: 'Food',
            price: 20.0,
            createdAt: DateTime.now(),
          ),
        ];

        final result = AnalyticsCalculator.calculateExpenseHistory(items);

        expect(result.currentMonthTotal, 30.0);
      });

      test('should handle items with null price', () {
        final items = [
          Item.create(
            name: 'Item with price',
            category: 'Food',
            price: 15.0,
            createdAt: DateTime.now(),
          ),
          Item.create(
            name: 'Item without price',
            category: 'Food',
            price: null,
            createdAt: DateTime.now(),
          ),
        ];

        final result = AnalyticsCalculator.calculateExpenseHistory(items);

        expect(result.currentMonthTotal, 15.0);
      });

      test('should return 5 monthly expenses', () {
        final result = AnalyticsCalculator.calculateExpenseHistory([]);

        expect(result.monthlyExpenses.length, 5);
      });
    });

    group('getFrequentlyExpired', () {
      test('should return empty list for no expired items', () {
        final items = [
          Item.create(
            name: 'Fresh Item',
            category: 'Food',
            expiryDate: DateTime.now().add(const Duration(days: 10)),
          ),
        ];

        final result = AnalyticsCalculator.getFrequentlyExpired(items);

        expect(result.isEmpty, true);
      });

      test('should group expired items by name', () {
        final items = [
          Item.create(
            name: 'Milk',
            category: 'Dairy',
            expiryDate: DateTime.now().subtract(const Duration(days: 1)),
          ),
          Item.create(
            name: 'Milk',
            category: 'Dairy',
            expiryDate: DateTime.now().subtract(const Duration(days: 5)),
          ),
          Item.create(
            name: 'Bread',
            category: 'Bakery',
            expiryDate: DateTime.now().subtract(const Duration(days: 2)),
          ),
        ];

        final result = AnalyticsCalculator.getFrequentlyExpired(items);

        expect(result.length, 2);
        expect(result.first.name, 'Milk');
        expect(result.first.count, 2);
      });

      test('should return max 5 products', () {
        final items = List.generate(10, (i) => Item.create(
          name: 'Product $i',
          category: 'Food',
          expiryDate: DateTime.now().subtract(const Duration(days: 1)),
        ));

        final result = AnalyticsCalculator.getFrequentlyExpired(items);

        expect(result.length, 5);
      });

      test('should sort by count descending', () {
        final items = [
          // 3x Milk
          ...List.generate(3, (_) => Item.create(
            name: 'Milk',
            category: 'Dairy',
            expiryDate: DateTime.now().subtract(const Duration(days: 1)),
          )),
          // 1x Bread
          Item.create(
            name: 'Bread',
            category: 'Bakery',
            expiryDate: DateTime.now().subtract(const Duration(days: 1)),
          ),
          // 2x Cheese
          ...List.generate(2, (_) => Item.create(
            name: 'Cheese',
            category: 'Dairy',
            expiryDate: DateTime.now().subtract(const Duration(days: 1)),
          )),
        ];

        final result = AnalyticsCalculator.getFrequentlyExpired(items);

        expect(result[0].name, 'Milk');
        expect(result[0].count, 3);
        expect(result[1].name, 'Cheese');
        expect(result[1].count, 2);
        expect(result[2].name, 'Bread');
        expect(result[2].count, 1);
      });

      test('should skip items with null expiry date', () {
        final items = [
          Item.create(
            name: 'Salt',
            category: 'Spices',
            expiryDate: null,
          ),
          Item.create(
            name: 'Expired Milk',
            category: 'Dairy',
            expiryDate: DateTime.now().subtract(const Duration(days: 1)),
          ),
        ];

        final result = AnalyticsCalculator.getFrequentlyExpired(items);

        expect(result.length, 1);
        expect(result.first.name, 'Expired Milk');
      });
    });
  });
}
