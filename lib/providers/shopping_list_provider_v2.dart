import 'package:life_auctor/models/shopping_list.dart';
import 'package:life_auctor/repositories/shopping_list_repository_v2.dart';
import 'package:life_auctor/services/connectivity_service.dart';
import 'package:life_auctor/services/sync_queue_service.dart';
import 'package:life_auctor/core/errors/app_error.dart';
import 'package:life_auctor/core/result.dart';
import 'package:life_auctor/providers/base_data_provider.dart';

class ShoppingListProviderV2 extends BaseDataProvider<ShoppingList> {
  final ShoppingListRepositoryV2 _repo;
  final ConnectivityService _conn;
  final SyncQueueService _sync;

  // lookup cache
  final Map<String, ShoppingList> _listsById = {};

  ShoppingListProviderV2({
    required ShoppingListRepositoryV2 repository,
    required ConnectivityService connectivity,
    required SyncQueueService syncQueue,
  }) : _repo = repository,
       _conn = connectivity,
       _sync = syncQueue;

  @override
  String getId(ShoppingList entity) => entity.id;

  @override
  Future<Result<List<ShoppingList>>> loadFromRepository({
    bool refresh = false,
  }) async {
    if (refresh) {
      final syncResult = await _repo.syncFromCloud();
      if (syncResult is Failure) {
        return Failure(syncResult.error);
      }
    }
    return _repo.load();
  }

  @override
  Future<Result<void>> addToRepository(ShoppingList item) => _repo.add(item);

  @override
  Future<Result<void>> updateInRepository(ShoppingList item) =>
      _repo.update(item);

  @override
  Future<Result<void>> deleteFromRepository(String id) => _repo.delete(id);

  // Load lists and update cache
  Future<void> loadLists({bool refresh = false}) async {
    if (refresh) {
      _listsById.clear();
    }

    await load(refresh: refresh);

    // Update cache
    for (final list in items) {
      _listsById[list.id] = list;
    }
  }

  //lookup by ID using cache
  @override
  ShoppingList? getById(String id) => _listsById[id];

  // to modify list items
  Future<void> _modifyListItems(
    String listId,
    List<String> Function(List<String> currentIds) modifier,
  ) async {
    final list = _listsById[listId];
    if (list != null) {
      final updatedItemIds = modifier(list.itemIds);
      final updatedList = list.copyWith(itemIds: updatedItemIds);
      await update(updatedList);
      _listsById[listId] = updatedList;
    }
  }

  // Add item to shopping list
  Future<void> addItemToList(String listId, String itemId) async {
    await _modifyListItems(listId, (ids) => [...ids, itemId]);
  }

  // Remove item from shopping list
  Future<void> removeItemFromList(String listId, String itemId) async {
    await _modifyListItems(
      listId,
      (ids) => ids.where((id) => id != itemId).toList(),
    );
  }

  // Update list stats
  Future<void> updateListStats(
    String listId,
    int inStockCount,
    int runOutCount,
  ) async {
    final list = _listsById[listId];
    if (list != null) {
      final updatedList = list.copyWith(
        inStockCount: inStockCount,
        runOutCount: runOutCount,
      );
      await update(updatedList);
      _listsById[listId] = updatedList;
    }
  }

  // Manual sync with cloud
  Future<void> manualSync() async {
    if (_conn.isOffline) {
      throw const NetworkError(message: 'Cannot sync while offline');
    }

    await loadLists(refresh: true);
    await _sync.manualSync();
  }

  // getter for lists
  List<ShoppingList> get lists => items;

  Future<void> addList(ShoppingList list) => add(list);
  Future<void> updateList(ShoppingList list) => update(list);
  Future<void> deleteList(String id) => delete(id);
}
