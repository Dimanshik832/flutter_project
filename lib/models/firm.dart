import 'package:cloud_firestore/cloud_firestore.dart';

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
      'name': name,
      'ownerId': ownerId,
      'categories': categories,
      'workerIds': workerIds,
      'createdAt': createdAt,
    };
  }

  factory Firm.fromMap(Map<String, dynamic> map, String id) {
    return Firm(
      id: id,
      name: map['name'] ?? '',
      ownerId: map['ownerId'] ?? '',
      categories: List<String>.from(map['categories'] ?? []),
      workerIds: List<String>.from(map['workerIds'] ?? []),
      createdAt: map['createdAt'] ?? Timestamp.now(),
    );
  }
}
