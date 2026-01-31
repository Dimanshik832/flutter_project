import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firestore_paths.dart';

class Firm {
  final String? id;
  final String name;
  final String ownerId;
  final List<String> categories;
  final List<String> workerIds;
  final Timestamp createdAt;

  Firm({
    this.id,
    required this.name,
    required this.ownerId,
    required this.categories,
    required this.workerIds,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      FirestoreFirmFields.name: name,
      FirestoreFirmFields.ownerId: ownerId,
      'categories': categories,
      FirestoreFirmFields.workerIds: workerIds,
      FirestoreFirmFields.createdAt: createdAt,
    };
  }

  factory Firm.fromMap(Map<String, dynamic> map, String id) {
    return Firm(
      id: id,
      name: map[FirestoreFirmFields.name] ?? '',
      ownerId: map[FirestoreFirmFields.ownerId] ?? '',
      categories: List<String>.from(map['categories'] ?? []),
      workerIds: List<String>.from(map[FirestoreFirmFields.workerIds] ?? []),
      createdAt: map[FirestoreFirmFields.createdAt] ?? Timestamp.now(),
    );
  }
}
