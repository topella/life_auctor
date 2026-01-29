import 'package:life_auctor/models/item.dart';

class AnalyticsData {
  final int totalAdded;
  final int expiredItems;
  final int usedBeforeExpiry;
  final double usedPercent;
  final double expiredPercent;

  AnalyticsData({
    required this.totalAdded,
    required this.expiredItems,
    required this.usedBeforeExpiry,
    required this.usedPercent,
    required this.expiredPercent,
  });
}

class ExpenseData {
  final double currentMonthTotal;
  final double prevMonthTotal;
  final double percentChange;
  final List<double> monthlyExpenses;

  ExpenseData({
    required this.currentMonthTotal,
    required this.prevMonthTotal,
    required this.percentChange,
    required this.monthlyExpenses,
  });
}

class FrequentlyExpiredProduct {
  final String name;
  final int count;
  final DateTime lastExpired;

  FrequentlyExpiredProduct({
    required this.name,
    required this.count,
    required this.lastExpired,
  });
}

class AnalyticsCalculator {
  // get start date for selected period
  static DateTime getStartDateForPeriod(String period) {
    final now = DateTime.now();
    switch (period) {
      case 'Week':
        return now.subtract(const Duration(days: 7));
      case 'Month':
        return now.subtract(const Duration(days: 30));
      case 'Quarter':
        return now.subtract(const Duration(days: 90));
      default:
        return DateTime(2000, 1, 1);
    }
  }

  // Calculate product statistics for selected period
  static AnalyticsData calculateProductStats(List<Item> items, String period) {
    final startDate = getStartDateForPeriod(period);
    final filteredItems = items
        .where((item) => item.createdAt.isAfter(startDate))
        .toList();

    final totalAdded = filteredItems.length;
    final expiredItems = filteredItems.where((item) {
      if (item.expiryDate == null) return false;
      return item.expiryDate!.isBefore(DateTime.now());
    }).length;

    final usedBeforeExpiry = totalAdded - expiredItems;
    final usedPercent = totalAdded > 0
        ? (usedBeforeExpiry / totalAdded * 100)
        : 0.0;
    final expiredPercent = totalAdded > 0
        ? (expiredItems / totalAdded * 100)
        : 0.0;

    return AnalyticsData(
      totalAdded: totalAdded,
      expiredItems: expiredItems,
      usedBeforeExpiry: usedBeforeExpiry,
      usedPercent: usedPercent,
      expiredPercent: expiredPercent,
    );
  }

  // EXPENCE HISTORY DATA
  static ExpenseData calculateExpenseHistory(List<Item> items) {
    final now = DateTime.now();

    //MONTH
    final currentMonthStart = DateTime(now.year, now.month, 1);
    final currentMonthItems = items
        .where(
          (item) =>
              item.createdAt.isAfter(currentMonthStart) && item.price != null,
        )
        .toList();
    final currentMonthTotal = currentMonthItems.fold<double>(
      0,
      (sum, item) => sum + (item.price ?? 0),
    );

    // PREVIOUS
    final prevMonthStart = DateTime(
      now.month == 1 ? now.year - 1 : now.year,
      now.month == 1 ? 12 : now.month - 1,
      1,
    );
    final prevMonthEnd = DateTime(now.year, now.month, 0, 23, 59, 59);
    final prevMonthItems = items
        .where(
          (item) =>
              item.createdAt.isAfter(prevMonthStart) &&
              item.createdAt.isBefore(prevMonthEnd) &&
              item.price != null,
        )
        .toList();
    final prevMonthTotal = prevMonthItems.fold<double>(
      0,
      (sum, item) => sum + (item.price ?? 0),
    );

    final percentChange = prevMonthTotal > 0
        ? ((currentMonthTotal - prevMonthTotal) / prevMonthTotal * 100)
        : 0.0;

    // Last 5
    final monthlyExpenses = <double>[];
    for (int i = 4; i >= 0; i--) {
      int targetMonth = now.month - i;
      int targetYear = now.year;

      while (targetMonth <= 0) {
        targetMonth += 12;
        targetYear -= 1;
      }

      final monthStart = DateTime(targetYear, targetMonth, 1);
      final monthEnd = i == 0
          ? now
          : DateTime(targetYear, targetMonth + 1, 0, 23, 59, 59);

      final monthItems = items
          .where(
            (item) =>
                item.createdAt.isAfter(monthStart) &&
                item.createdAt.isBefore(monthEnd) &&
                item.price != null,
          )
          .toList();

      monthlyExpenses.add(
        monthItems.fold<double>(0, (sum, item) => sum + (item.price ?? 0)),
      );
    }

    return ExpenseData(
      currentMonthTotal: currentMonthTotal,
      prevMonthTotal: prevMonthTotal,
      percentChange: percentChange,
      monthlyExpenses: monthlyExpenses,
    );
  }

  // List of frequently expired products/
  static List<FrequentlyExpiredProduct> getFrequentlyExpired(List<Item> items) {
    final expiredItems = items.where((item) {
      if (item.expiryDate == null) return false;
      return item.expiryDate!.isBefore(DateTime.now());
    }).toList();

    final Map<String, List<DateTime>> expiredByName = {};
    for (var item in expiredItems) {
      expiredByName.putIfAbsent(item.name, () => []).add(item.expiryDate!);
    }

    final sortedProducts = expiredByName.entries.toList()
      ..sort((a, b) => b.value.length.compareTo(a.value.length));

    return sortedProducts.take(5).map((entry) {
      final lastExpired = entry.value.reduce((a, b) => a.isAfter(b) ? a : b);
      return FrequentlyExpiredProduct(
        name: entry.key,
        count: entry.value.length,
        lastExpired: lastExpired,
      );
    }).toList();
  }
}
