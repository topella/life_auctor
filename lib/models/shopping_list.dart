import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

@immutable
class ShoppingList {
  final String id;
  final String name;
  final String? description;
  final String? category;
  final String? priority;
  final List<String> itemIds;
  final bool enableNotifications;
  final bool autoAddToCalendar;
  final String? tags;
  final DateTime createdAt;
  final int inStockCount;
  final int runOutCount;

  const ShoppingList({
    required this.id,
    required this.name,
    this.description,
    this.category,
    this.priority,
    required this.itemIds,
    this.enableNotifications = false,
    this.autoAddToCalendar = false,
    this.tags,
    required this.createdAt,
    this.inStockCount = 0,
    this.runOutCount = 0,
  });

  // factory constructor with uuid
  factory ShoppingList.create({
    String? id,
    required String name,
    String? description,
    String? category,
    String? priority,
    List<String>? itemIds,
    bool enableNotifications = false,
    bool autoAddToCalendar = false,
    String? tags,
    DateTime? createdAt,
    int inStockCount = 0,
    int runOutCount = 0,
  }) {
    return ShoppingList(
      id: id ?? const Uuid().v4(),
      name: name,
      description: description,
      category: category,
      priority: priority,
      itemIds: itemIds ?? [],
      enableNotifications: enableNotifications,
      autoAddToCalendar: autoAddToCalendar,
      tags: tags,
      createdAt: createdAt ?? DateTime.now(),
      inStockCount: inStockCount,
      runOutCount: runOutCount,
    );
  }

  // helper to parse itemIds from different formats
  static List<String> _parseItemIds(dynamic value) {
    if (value == null) return [];
    if (value is List) return value.cast<String>();
    if (value is String)
      return value.split(',').where((e) => e.isNotEmpty).toList();
    return [];
  }

  // SQLite JSon
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category': category,
      'priority': priority,
      'itemIds': itemIds.join(','), // comma-separated string
      'enableNotifications': enableNotifications ? 1 : 0,
      'autoAddToCalendar': autoAddToCalendar ? 1 : 0,
      'tags': tags,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'inStockCount': inStockCount,
      'runOutCount': runOutCount,
    };
  }

  /// Firestore JSON uses array for itemIds, bool for bools
  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category': category,
      'priority': priority,
      'itemIds': itemIds, // Firestore array
      'enableNotifications': enableNotifications,
      'autoAddToCalendar': autoAddToCalendar,
      'tags': tags,
      'createdAt': Timestamp.fromDate(createdAt),
      'inStockCount': inStockCount,
      'runOutCount': runOutCount,
    };
  }

  // from SQLite JSON
  factory ShoppingList.fromJson(Map<String, dynamic> json) {
    return ShoppingList(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      category: json['category'] as String?,
      priority: json['priority'] as String?,
      itemIds: _parseItemIds(json['itemIds']), // Handles both string and array
      enableNotifications: (json['enableNotifications'] as int?) == 1,
      autoAddToCalendar: (json['autoAddToCalendar'] as int?) == 1,
      tags: json['tags'] as String?,
      createdAt: DateTime.fromMillisecondsSinceEpoch(json['createdAt'] as int),
      inStockCount: json['inStockCount'] as int? ?? 0,
      runOutCount: json['runOutCount'] as int? ?? 0,
    );
  }

  // from Firestore document
  factory ShoppingList.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ShoppingList(
      id: data['id'] as String,
      name: data['name'] as String,
      description: data['description'] as String?,
      category: data['category'] as String?,
      priority: data['priority'] as String?,
      itemIds: _parseItemIds(data['itemIds']), // handles both formats
      enableNotifications: data['enableNotifications'] as bool? ?? false,
      autoAddToCalendar: data['autoAddToCalendar'] as bool? ?? false,
      tags: data['tags'] as String?,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      inStockCount: data['inStockCount'] as int? ?? 0,
      runOutCount: data['runOutCount'] as int? ?? 0,
    );
  }

  ShoppingList copyWith({
    String? name,
    String? description,
    String? category,
    String? priority,
    List<String>? itemIds,
    bool? enableNotifications,
    bool? autoAddToCalendar,
    String? tags,
    int? inStockCount,
    int? runOutCount,
  }) {
    return ShoppingList(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      priority: priority ?? this.priority,
      itemIds: itemIds ?? this.itemIds,
      enableNotifications: enableNotifications ?? this.enableNotifications,
      autoAddToCalendar: autoAddToCalendar ?? this.autoAddToCalendar,
      tags: tags ?? this.tags,
      createdAt: createdAt,
      inStockCount: inStockCount ?? this.inStockCount,
      runOutCount: runOutCount ?? this.runOutCount,
    );
  }
}
