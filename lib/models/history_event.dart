import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

enum HistoryEventType {
  addedItem,
  scannedBarcode,
  itemExpired,
  createdList,
  outOfStock,
}

@immutable
class HistoryEvent {
  final String id;
  final HistoryEventType type;
  final String title;
  final String? subtitle;
  final DateTime timestamp;
  final String? itemId;
  final String? listId;

  const HistoryEvent({
    required this.id,
    required this.type,
    required this.title,
    this.subtitle,
    required this.timestamp,
    this.itemId,
    this.listId,
  });

  //factory constructor with uuid
  factory HistoryEvent.create({
    String? id,
    required HistoryEventType type,
    required String title,
    String? subtitle,
    DateTime? timestamp,
    String? itemId,
    String? listId,
  }) {
    return HistoryEvent(
      id: id ?? const Uuid().v4(),
      type: type,
      title: title,
      subtitle: subtitle,
      timestamp: timestamp ?? DateTime.now(),
      itemId: itemId,
      listId: listId,
    );
  }

  String get timeString {
    final hour = timestamp.hour.toString().padLeft(2, '0');
    final minute = timestamp.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  String get dateGroup {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return 'Last Week';
    } else if (difference.inDays < 30) {
      return 'Last Month';
    } else {
      return 'Earlier';
    }
  }

  HistoryEvent copyWith({
    String? id,
    HistoryEventType? type,
    String? title,
    String? subtitle,
    DateTime? timestamp,
    String? itemId,
    String? listId,
  }) {
    return HistoryEvent(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      timestamp: timestamp ?? this.timestamp,
      itemId: itemId ?? this.itemId,
      listId: listId ?? this.listId,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'title': title,
      'subtitle': subtitle,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'itemId': itemId,
      'listId': listId,
    };
  }

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'type': type.name,
      'title': title,
      'subtitle': subtitle,
      'timestamp': Timestamp.fromDate(timestamp),
      'itemId': itemId,
      'listId': listId,
    };
  }

  factory HistoryEvent.fromJson(Map<String, dynamic> json) {
    return HistoryEvent(
      id: json['id'] as String,
      type: HistoryEventType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => HistoryEventType.addedItem,
      ),
      title: json['title'] as String,
      subtitle: json['subtitle'] as String?,
      timestamp: DateTime.fromMillisecondsSinceEpoch(json['timestamp'] as int),
      itemId: json['itemId'] as String?,
      listId: json['listId'] as String?,
    );
  }

  // creating historyEvent from Firestore document
  factory HistoryEvent.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return HistoryEvent(
      id: data['id'] as String,
      type: HistoryEventType.values.firstWhere(
        (e) => e.name == data['type'],
        orElse: () => HistoryEventType.addedItem,
      ),
      title: data['title'] as String,
      subtitle: data['subtitle'] as String?,
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      itemId: data['itemId'] as String?,
      listId: data['listId'] as String?,
    );
  }
}
