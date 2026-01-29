class Pagination {
  int page = 0;
  bool hasMore = true;
  final int pageSize;

  Pagination({this.pageSize = 50});

  /// getting current offset for database query
  int get offset => page * pageSize;

  /// reset pagination
  void reset() {
    page = 0;
    hasMore = true;
  }

  /// move to next page
  void next() => page++;

  ///  checking are there more items
  void checkHasMore(int itemsLoaded) {
    if (itemsLoaded < pageSize) hasMore = false;
  }
}
