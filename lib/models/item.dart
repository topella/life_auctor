import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

@immutable
class Item {
  final String id;
  final String name;
  final String category;
  final DateTime? expiryDate;
  final String? quantity;
  final String? location;
  final String? notes;
  final double? price;
  final bool isFavorite;
  final bool isConsumed;
  final DateTime createdAt;

  static const Uuid _uuid = Uuid();

  const Item({
    required this.id,
    required this.name,
    required this.category,
    this.expiryDate,
    this.quantity,
    this.location,
    this.notes,
    this.price,
    this.isFavorite = false,
    this.isConsumed = false,
    required this.createdAt,
  });

  // ID and createdAt
  factory Item.create({
    String? id,
    required String name,
    required String category,
    DateTime? expiryDate,
    String? quantity,
    String? location,
    String? notes,
    double? price,
    bool isFavorite = false,
    bool isConsumed = false,
    DateTime? createdAt,
  }) {
    return Item(
      id: id ?? _uuid.v4(),
      name: name,
      category: category,
      expiryDate: expiryDate,
      quantity: quantity,
      location: location,
      notes: notes,
      price: price,
      isFavorite: isFavorite,
      isConsumed: isConsumed,
      createdAt: createdAt ?? DateTime.now(),
    );
  }

  /// SQLite JSON (uses int for bools)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'expiryDate': expiryDate?.millisecondsSinceEpoch,
      'quantity': quantity,
      'location': location,
      'notes': notes,
      'price': price,
      'isFavorite': isFavorite ? 1 : 0, // SQLite: int
      'isConsumed': isConsumed ? 1 : 0, // SQLite: int
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }

  // Firestore JSON (uses bool for bools)
  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'expiryDate': expiryDate != null ? Timestamp.fromDate(expiryDate!) : null,
      'quantity': quantity,
      'location': location,
      'notes': notes,
      'price': price,
      'isFavorite': isFavorite, // Firestore: bool
      'isConsumed': isConsumed, // Firestore: bool
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  // from SQLite JSON
  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      id: json['id'] as String,
      name: json['name'] as String,
      category: json['category'] as String,
      expiryDate: json['expiryDate'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['expiryDate'] as int)
          : null,
      quantity: json['quantity'] as String?,
      location: json['location'] as String?,
      notes: json['notes'] as String?,
      price: json['price'] != null ? (json['price'] as num).toDouble() : null,
      isFavorite: (json['isFavorite'] as int?) == 1,
      isConsumed: (json['isConsumed'] as int?) == 1,
      createdAt: DateTime.fromMillisecondsSinceEpoch(json['createdAt'] as int),
    );
  }

  // from Firestore document
  factory Item.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Item(
      id: data['id'] as String,
      name: data['name'] as String,
      category: data['category'] as String,
      expiryDate: data['expiryDate'] != null
          ? (data['expiryDate'] as Timestamp).toDate()
          : null,
      quantity: data['quantity'] as String?,
      location: data['location'] as String?,
      notes: data['notes'] as String?,
      price: data['price'] != null ? (data['price'] as num).toDouble() : null,
      isFavorite: data['isFavorite'] as bool? ?? false,
      isConsumed: data['isConsumed'] as bool? ?? false,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Item copyWith({
    String? id,
    String? name,
    String? category,
    DateTime? expiryDate,
    String? quantity,
    String? location,
    String? notes,
    double? price,
    bool? isFavorite,
    bool? isConsumed,
    DateTime? createdAt,
  }) {
    return Item(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      expiryDate: expiryDate ?? this.expiryDate,
      quantity: quantity ?? this.quantity,
      location: location ?? this.location,
      notes: notes ?? this.notes,
      price: price ?? this.price,
      isFavorite: isFavorite ?? this.isFavorite,
      isConsumed: isConsumed ?? this.isConsumed,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Item && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Item(id: $id, name: $name, category: $category, isFavorite: $isFavorite, isConsumed: $isConsumed)';
  }
}
