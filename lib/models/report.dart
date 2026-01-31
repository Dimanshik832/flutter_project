import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firestore_paths.dart';

class Report {
  final String? id;
  final String title;
  final String description;
  final String status;
  final String room; 
  final String category;
  final List<String> imageUrls;
  final Timestamp createdAt;
  final String userId;

  Report({
    this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.room,       
    required this.category,
    required this.imageUrls,
    required this.createdAt,
    required this.userId,
  });

  Map<String, dynamic> toMap() {
    return {
      FirestoreReportFields.title: title,
      'description': description,
      'status': status,
      'room': room,            
      'category': category,
      FirestoreReportFields.images: imageUrls,
      FirestoreReportFields.createdAt: createdAt,
      FirestoreReportFields.userId: userId,
    };
  }

  factory Report.fromMap(Map<String, dynamic> map, String id) {
    return Report(
      id: id,
      title: map[FirestoreReportFields.title] ?? '',
      description: map['description'] ?? '',
      status: map['status'] ?? 'Submitted',

      
      room: map['room'] ?? map[FirestoreReportFields.roomNumber] ?? '',

      category: map['category'] ?? 'Other',
      imageUrls: List<String>.from(map[FirestoreReportFields.images] ?? []),
      createdAt: map[FirestoreReportFields.createdAt] ?? Timestamp.now(),
      userId: map[FirestoreReportFields.userId] ?? '',
    );
  }
}
