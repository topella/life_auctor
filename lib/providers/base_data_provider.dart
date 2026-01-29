import 'package:flutter/foundation.dart';
import 'package:life_auctor/core/errors/app_error.dart';
import 'package:life_auctor/core/result.dart';

abstract class BaseDataProvider<T> extends ChangeNotifier {
  final List<T> _items = [];
  bool _loading = false;
  AppError? _error;

  List<T> get items => List.unmodifiable(_items);
  bool get isLoading => _loading;
  AppError? get error => _error;
  bool get hasError => _error != null;
  bool get isEmpty => _items.isEmpty;
  int get count => _items.length;

  // Get entity ID
  String getId(T entity);

  // Load items from repository
  Future<Result<List<T>>> loadFromRepository({bool refresh = false});
  // Add item to repository
  Future<Result<void>> addToRepository(T item);

  // Update item in repository
  Future<Result<void>> updateInRepository(T item);

  // Delete item from repository
  Future<Result<void>> deleteFromRepository(String id);

  // Load items
  Future<void> load({bool refresh = false}) async {
    _loading = true;
    _error = null;

    final result = await loadFromRepository(refresh: refresh);

    switch (result) {
      case Success():
        _items.clear();
        _items.addAll(result.data);
      case Failure():
        _error = result.error;
    }

    _loading = false;
    notifyListeners();
  }

  // Add item
  Future<void> add(T item) async {
    _error = null;
    final result = await addToRepository(item);

    await _handleResult(
      result,
      onSuccess: () => _items.insert(0, item),
    );
  }

  // update item
  Future<void> update(T item) async {
    _error = null;
    final result = await updateInRepository(item);

    await _handleResult(
      result,
      onSuccess: () {
        final idx = _findIndex(getId(item));
        if (idx != -1) {
          _items[idx] = item;
        }
      },
    );
  }

  // Delete item
  Future<void> delete(String id) async {
    _error = null;
    final result = await deleteFromRepository(id);

    await _handleResult(
      result,
      onSuccess: () => _items.removeWhere((i) => getId(i) == id),
    );
  }

  // get item by ID (O(1) with caching in subclass if needed)
  T? getById(String id) {
    try {
      return _items.firstWhere((item) => getId(item) == id);
    } catch (e) {
      return null;
    }
  }

  // Find item index by ID
  int _findIndex(String id) {
    return _items.indexWhere((i) => getId(i) == id);
  }

  //eliminates duplication
  Future<void> _handleResult(
    Result<void> result, {
    required VoidCallback onSuccess,
  }) async {
    switch (result) {
      case Success():
        onSuccess();
        notifyListeners();
      case Failure(error: final e):
        if (e is! SyncError) {
          _error = e;
          notifyListeners();
          throw e;
        }
        notifyListeners();
    }
  }

  // Clear data
  void clear() {
    _items.clear();
    _error = null;
    _loading = false;
    notifyListeners();
  }

  // to reset error state
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
