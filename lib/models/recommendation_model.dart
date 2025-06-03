// lib/models/recommendation_model.dart
import 'package:cloud_firestore/cloud_firestore.dart'; //

class Recommendation {
  final String id; //
  final String userId; //
  final String? conversationId; //
  final String activityType; //
  final String title; //
  final String description; //
  final int duration; //
  final String? userRating; // 문자열 (평점)
  final DateTime createdAt; //

  Recommendation({
    required this.id,
    required this.userId,
    this.conversationId,
    required this.activityType,
    required this.title,
    required this.description,
    required this.duration,
    this.userRating,
    required this.createdAt,
  });

  factory Recommendation.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>; //
    return Recommendation(
      id: doc.id, //
      userId: data['user_id'] ?? '', //
      conversationId: data['conversation_id'], //
      activityType: data['activity_type'] ?? '', //
      title: data['title'] ?? '', //
      description: data['description'] ?? '', //
      duration: (data['duration'] as num?)?.toInt() ?? 0, //
      userRating: data['user_rating'], //
      createdAt: (data['created_at'] as Timestamp).toDate(), //
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'user_id': userId, //
      'conversation_id': conversationId, //
      'activity_type': activityType, //
      'title': title, //
      'description': description, //
      'duration': duration, //
      'user_rating': userRating, //
      'created_at': Timestamp.fromDate(createdAt), //
    };
  }

  Recommendation copyWith({
    String? id,
    String? userId,
    String? conversationId,
    String? activityType,
    String? title,
    String? description,
    int? duration,
    String? userRating,
    DateTime? createdAt,
  }) {
    return Recommendation(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      conversationId: conversationId ?? this.conversationId,
      activityType: activityType ?? this.activityType,
      title: title ?? this.title,
      description: description ?? this.description,
      duration: duration ?? this.duration,
      userRating: userRating ?? this.userRating,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}