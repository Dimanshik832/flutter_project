import 'package:cloud_firestore/cloud_firestore.dart';

class Report {
  final String? id;
  final String title;
  final String description;
  final String status;
  final String roomNumber;
  final String category;
  final List<String> imageUrls;
  final Timestamp createdAt;
  final String userId;

  Report({
    this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.roomNumber,
    required this.category,
    required this.imageUrls,
    required this.createdAt,
    required this.userId,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'status': status,
      'roomNumber': roomNumber,
      'category': category,
      'images': imageUrls,
      'createdAt': createdAt,
      'userId': userId,
    };
  }

  factory Report.fromMap(Map<String, dynamic> map, String id) {
    return Report(
      id: id,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      status: map['status'] ?? 'Submitted',
      roomNumber: map['roomNumber'] ?? '',
      category: map['category'] ?? 'Other',
      imageUrls: List<String>.from(map['images'] ?? []),
      createdAt: map['createdAt'] ?? Timestamp.now(),
      userId: map['userId'] ?? '',
    );
  }
}
