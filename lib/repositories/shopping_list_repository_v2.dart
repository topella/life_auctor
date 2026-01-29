import 'package:life_auctor/models/shopping_list.dart';
import 'package:life_auctor/repositories/base_repository.dart';

class ShoppingListRepositoryV2 extends BaseRepository<ShoppingList> {
  ShoppingListRepositoryV2(
    super.db,
    super.fire,
    super.auth,
    super.sync,
    super.conn,
  );

  @override
  String get tableName => 'shopping_lists';

  @override
  String getId(ShoppingList entity) => entity.id;

  @override
  Map<String, dynamic> toJson(ShoppingList entity) => entity.toJson();

  @override
  ShoppingList fromJson(Map<String, dynamic> json) => ShoppingList.fromJson(json);

  @override
  Future<List<ShoppingList>> loadFromFirestore() => fire.getLists(uid);

  @override
  Future<void> addToFirestore(ShoppingList entity) => fire.addList(uid, entity);

  @override
  Future<void> updateInFirestore(ShoppingList entity) => fire.updateList(uid, entity);

  @override
  Future<void> deleteFromFirestore(String id) => fire.deleteList(uid, id);
}
