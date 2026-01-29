import 'package:life_auctor/models/item.dart';
import 'package:life_auctor/core/result.dart';
import 'package:life_auctor/repositories/base_repository.dart';

class ItemRepositoryV2 extends BaseRepository<Item> {
  ItemRepositoryV2(
    super.db,
    super.fire,
    super.auth,
    super.sync,
    super.conn,
  );
  @override
  String get tableName => 'items';
  @override
  String getId(Item entity) => entity.id;
  @override
  Map<String, dynamic> toJson(Item entity) => entity.toJson();
  @override
  Item fromJson(Map<String, dynamic> json) => Item.fromJson(json);
  @override
  Future<List<Item>> loadFromFirestore() => fire.getItems(uid);
  @override
  Future<void> addToFirestore(Item entity) => fire.addItem(uid, entity);
  @override
  Future<void> updateInFirestore(Item entity) => fire.updateItem(uid, entity);
  @override
  Future<void> deleteFromFirestore(String id) => fire.deleteItem(uid, id);

  // loading with pagination to ItemRepository
  Future<Result<List<Item>>> loadPaginated(int offset, int limit) async {
    return dbOp((db) async {
      final maps = await db.query(
        tableName,
        orderBy: 'createdAt DESC',
        limit: limit,
        offset: offset,
      );
      return maps.map((m) => fromJson(m)).toList();
    });
  }
}
