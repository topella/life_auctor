import 'package:life_auctor/models/item.dart';
import 'package:life_auctor/repositories/item_repository_v2.dart';
import 'package:life_auctor/services/connectivity_service.dart';
import 'package:life_auctor/services/sync_queue_service.dart';
import 'package:life_auctor/core/errors/app_error.dart';
import 'package:life_auctor/core/result.dart';
import 'package:life_auctor/core/pagination.dart';
import 'package:life_auctor/core/extensions/item_extensions.dart';
import 'package:life_auctor/providers/base_data_provider.dart';

class ItemProviderV3 extends BaseDataProvider<Item> {
  final ItemRepositoryV2 _repo;
  final ConnectivityService _conn;
  final SyncQueueService _sync;
  final _pagination = Pagination();
  // cache
  final Map<String, Item> _itemsById = {};

  ItemProviderV3({
    required ItemRepositoryV2 repository,
    required ConnectivityService connectivity,
    required SyncQueueService syncQueue,
  }) : _repo = repository,
       _conn = connectivity,
       _sync = syncQueue;

  @override
  String getId(Item entity) => entity.id;

  @override
  Future<Result<List<Item>>> loadFromRepository({bool refresh = false}) async {
    if (refresh) {
      _pagination.reset();
      final syncResult = await _repo.syncFromCloud();
      if (syncResult is Failure) {
        return Failure(syncResult.error);
      }
    }

    return _repo.loadPaginated(_pagination.offset, _pagination.pageSize);
  }

  @override
  Future<Result<void>> addToRepository(Item item) => _repo.add(item);

  @override
  Future<Result<void>> updateInRepository(Item item) => _repo.update(item);

  @override
  Future<Result<void>> deleteFromRepository(String id) => _repo.delete(id);

  // Pagination support
  bool get hasMore => _pagination.hasMore;
  int get currentPage => _pagination.page;

  // Load items with pagination
  Future<void> loadItems({bool refresh = false}) async {
    if (refresh) {
      _pagination.reset();
      _itemsById.clear();
    }

    await load(refresh: refresh);

    // Update cache and pagination
    for (final item in items) {
      _itemsById[item.id] = item;
    }
    _pagination.checkHasMore(items.length);
    if (!refresh) _pagination.next();
  }

  // Stats using extensions
  int get totalItems => count;
  int get expiringSoon => items.expiringSoon;
  int get expired => items.expired;
  List<Item> get favorites => items.favorites;

  @override
  Item? getById(String id) => _itemsById[id];

  // Toggle favorite status
  Future<void> toggleFavorite(String id) async {
    final item = _itemsById[id];
    if (item != null) {
      await update(item.copyWith(isFavorite: !item.isFavorite));
      _itemsById[id] = item.copyWith(isFavorite: !item.isFavorite);
    }
  }

  // Toggle consumed status
  Future<void> toggleConsumed(String id) async {
    final item = _itemsById[id];
    if (item != null) {
      await update(item.copyWith(isConsumed: !item.isConsumed));
      _itemsById[id] = item.copyWith(isConsumed: !item.isConsumed);
    }
  }

  /// Batch
  Future<void> batchUpdateItems(List<Item> itemsToUpdate) async {
    final result = await _repo.batchUpdate(itemsToUpdate);

    switch (result) {
      case Success():
        final updateMap = {for (final item in itemsToUpdate) item.id: item};
        //local state
        final updatedItems = items.map((item) {
          return updateMap[item.id] ?? item;
        }).toList();
        //cache
        for (final item in itemsToUpdate) {
          _itemsById[item.id] = item;
        }

        items.clear();
        items.addAll(updatedItems);
        notifyListeners();

      case Failure(error: final e):
        if (e is! SyncError) {
          throw e;
        }
    }
  }

  /// Batch delete items
  Future<void> batchDeleteItems(List<String> ids) async {
    final result = await _repo.batchDelete(ids);

    switch (result) {
      case Success():
        for (final id in ids) {
          _itemsById.remove(id);
        }
        await delete(ids.first);

      case Failure(error: final e):
        if (e is! SyncError) {
          throw e;
        }
    }
  }

  // Get items by category
  List<Item> getItemsByCategory(String category) => items.byCategory(category);

  // Get count by category
  int getCountByCategory(String category) =>
      getItemsByCategory(category).length;

  // Search items
  List<Item> searchItems(String query) => items.search(query);

  // sync with cloud
  Future<void> manualSync() async {
    if (_conn.isOffline) {
      throw const NetworkError(message: 'Cannot sync while offline');
    }

    await loadItems(refresh: true);
    await _sync.manualSync();
  }

  // Backward compatibility aliases
  Future<void> addItem(Item item) => add(item);
  Future<void> updateItem(Item item) => update(item);
  Future<void> deleteItem(String id) => delete(id);
}
