// lib/models/conversation_insight_model.dart
import 'package:cloud_firestore/cloud_firestore.dart'; //

class ConversationInsight {
  final String id; //
  final String userId; //
  final String conversationId; //
  final DateTime createdAt; //
  final String keyTopics; // FireStore 스키마에 맞춰 문자열로 수정
  final String overallMood; //
  final String sentimentSummary; //
  final bool toUserYn; // to_user_yn (스키마 반영)

  ConversationInsight({
    required this.id,
    required this.userId,
    required this.conversationId,
    required this.createdAt,
    required this.keyTopics,
    required this.overallMood,
    required this.sentimentSummary,
    required this.toUserYn,
  });

  factory ConversationInsight.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>; //
    return ConversationInsight(
      id: doc.id, //
      userId: data['user_id'] ?? '', //
      conversationId: data['conversation_id'] ?? '', //
      createdAt: (data['created_at'] as Timestamp).toDate(), //
      keyTopics: data['key_topics'] ?? '', // key_topics (스키마 반영)
      overallMood: data['overall_mood'] ?? '', //
      sentimentSummary: data['sentiment_summary'] ?? '', //
      toUserYn: data['to_user_yn'] ?? false, // to_user_yn (스키마 반영)
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'user_id': userId, //
      'conversation_id': conversationId, //
      'created_at': Timestamp.fromDate(createdAt), //
      'key_topics': keyTopics, //
      'overall_mood': overallMood, //
      'sentiment_summary': sentimentSummary, //
      'to_user_yn': toUserYn, //
    };
  }

  ConversationInsight copyWith({
    String? id,
    String? userId,
    String? conversationId,
    DateTime? createdAt,
    String? keyTopics,
    String? overallMood,
    String? sentimentSummary,
    bool? toUserYn,
  }) {
    return ConversationInsight(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      conversationId: conversationId ?? this.conversationId,
      createdAt: createdAt ?? this.createdAt,
      keyTopics: keyTopics ?? this.keyTopics,
      overallMood: overallMood ?? this.overallMood,
      sentimentSummary: sentimentSummary ?? this.sentimentSummary,
      toUserYn: toUserYn ?? this.toUserYn,
    );
  }
}