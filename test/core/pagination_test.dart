import 'package:flutter_test/flutter_test.dart';
import 'package:life_auctor/core/pagination.dart';

void main() {
  group('Pagination Tests', () {
    test('should initialize with default values', () {
      final pagination = Pagination();

      expect(pagination.page, 0);
      expect(pagination.hasMore, true);
      expect(pagination.pageSize, 50);
      expect(pagination.offset, 0);
    });

    test('should accept custom page size', () {
      final pagination = Pagination(pageSize: 20);

      expect(pagination.pageSize, 20);
    });

    test('offset should be calculated correctly', () {
      final pagination = Pagination(pageSize: 50);

      expect(pagination.offset, 0); // page 0 * 50 = 0

      pagination.next();
      expect(pagination.offset, 50); // page 1 * 50 = 50

      pagination.next();
      expect(pagination.offset, 100); // page 2 * 50 = 100
    });

    test('next() should increment page', () {
      final pagination = Pagination();

      expect(pagination.page, 0);

      pagination.next();
      expect(pagination.page, 1);

      pagination.next();
      expect(pagination.page, 2);
    });

    test('reset() should restore initial state', () {
      final pagination = Pagination();

      pagination.next();
      pagination.next();
      pagination.checkHasMore(10); // Less than pageSize

      expect(pagination.page, 2);
      expect(pagination.hasMore, false);

      pagination.reset();

      expect(pagination.page, 0);
      expect(pagination.hasMore, true);
    });

    test('checkHasMore() should set hasMore to false when items < pageSize', () {
      final pagination = Pagination(pageSize: 50);

      pagination.checkHasMore(50); // Equal to pageSize
      expect(pagination.hasMore, true);

      pagination.checkHasMore(49); // Less than pageSize
      expect(pagination.hasMore, false);
    });

    test('checkHasMore() should keep hasMore true when items >= pageSize', () {
      final pagination = Pagination(pageSize: 20);

      pagination.checkHasMore(20);
      expect(pagination.hasMore, true);

      pagination.checkHasMore(25);
      expect(pagination.hasMore, true);
    });

    test('should work with small page sizes', () {
      final pagination = Pagination(pageSize: 5);

      expect(pagination.offset, 0);

      pagination.next();
      expect(pagination.offset, 5);

      pagination.next();
      expect(pagination.offset, 10);

      pagination.checkHasMore(3);
      expect(pagination.hasMore, false);
    });
  });
}
