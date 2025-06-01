// lib/models/conversation_model.dart
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:tiiun/utils/encoding_utils.dart';
import 'package:tiiun/models/message_model.dart'; // Message 모델 import

/// 대화 모델
///
/// 사용자와 AI 에이전트 간의 대화를 나타냅니다.
class Conversation {
  // ========== 추가 기능 필드들 (앱 UI 및 로직용) ==========
  
  /// 고유 ID (Document ID 저장용)
  final String id;
  
  /// 대화 제목 (UI 표시용)
  final String title;
  
  /// 마지막 메시지 내용 (UI 표시용)
  final String lastMessage;
  
  /// 마지막 메시지 시간 (UI 표시용)
  final DateTime lastMessageAt;
  
  /// AI 에이전트 ID (앱 로직용)
  final String agentId;
  
  /// 평균 감정 점수 (1-5) (분석 기능용)
  final double? averageMoodScore;
  
  /// 감정 변화 감지 여부 (분석 기능용)
  final bool? moodChangeDetected;
  
  /// 대화 태그 (분류 기능용)
  final List<String> tags;
  
  /// 마지막 메시지가 사용자가 보낸 것인지 여부 (UI 로직용)
  final bool? isLastMessageFromUser;
  
  /// 음성 대화 여부 (기능 구분용)
  final bool isVoiceConversation;
  
  /// 대화 지속 시간 (초) (통계용)
  final int? duration;
  
  /// 완료 여부 (상태 관리용)
  final bool isCompleted;

  // ========== FireStore 스키마 필수 필드들 ==========
  
  /// 사용자 ID (FireStore 필수)
  final String userId;
  
  /// 대화 요약 (FireStore 필수)
  final String? summary;
  
  /// 마지막 메시지 ID (FireStore 필수)
  final String? lastMessageId;
  
  /// 생성 시간 (FireStore 필수)
  final DateTime createdAt;
  
  /// 업데이트 시간 (FireStore 필수)
  final DateTime? updatedAt;
  
  /// 메시지 수 (FireStore 필수)
  final int messageCount;
  
  /// 플랜트 ID (FireStore 필수)
  final String? plantId;

  Conversation({
    // 추가 기능 필드들
    required this.id,
    required this.title,
    required this.lastMessage,
    required this.lastMessageAt,
    required this.agentId,
    this.averageMoodScore,
    this.moodChangeDetected,
    this.tags = const [],
    this.isLastMessageFromUser,
    this.isVoiceConversation = false,
    this.duration,
    this.isCompleted = false,
    // FireStore 스키마 필수 필드들
    required this.userId,
    this.summary,
    this.lastMessageId,
    required this.createdAt,
    this.updatedAt,
    required this.messageCount,
    this.plantId,
  });

  /// 빈 대화 생성
  factory Conversation.empty() {
    final now = DateTime.now();
    return Conversation(
      id: '',
      userId: '',
      title: '새 대화',
      lastMessage: '',
      lastMessageAt: now,
      createdAt: now,
      agentId: '',
      messageCount: 0,
      lastMessageId: null,
      plantId: null,
    );
  }

  /// Firestore 데이터에서 객체 생성 (스키마에 맞게 수정)
  factory Conversation.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    String title = data['title'] ?? '제목 없음';
    String? summary = data['summary'];

    title = EncodingUtils.tryAllFixMethods(title);

    if (summary != null && summary.isNotEmpty) {
      summary = EncodingUtils.tryAllFixMethods(summary);
    }

    return Conversation(
      id: doc.id,
      // ✅ 모든 Firebase 필드를 snake_case에서 읽어 camelCase 변수로 매핑
      userId: data['user_id'] ?? '',
      title: title,
      summary: summary,
      plantId: data['plant_id'],
      createdAt: data['created_at'] != null 
          ? (data['created_at'] as Timestamp).toDate()
          : DateTime.now(),
      updatedAt: data['updated_at'] != null
          ? (data['updated_at'] as Timestamp).toDate()
          : null,
      lastMessageId: data['last_message_id'] as String?,
      messageCount: data['message_count'] ?? 0,
      
      // 기본값들 (스키마에 없는 필드들)
      lastMessage: '', // 빈 문자열로 초기화
      lastMessageAt: data['updated_at'] != null 
          ? (data['updated_at'] as Timestamp).toDate()
          : DateTime.now(), // updated_at을 lastMessageAt으로 사용
      agentId: 'default_agent', // 기본값
      averageMoodScore: null,
      moodChangeDetected: null,
      tags: [], // 빈 리스트
      isLastMessageFromUser: null,
      isVoiceConversation: false,
      duration: null,
      isCompleted: false,
    );
  }

  /// Firestore에 저장할 데이터로 변환 (스키마에 맞게 수정)
  Map<String, dynamic> toFirestore() {
    String encodedTitle = EncodingUtils.encodeToBase64(title);
    String? encodedSummary = summary != null ? EncodingUtils.encodeToBase64(summary!) : null;

    return {
      // ✅ 모든 Firebase 필드를 snake_case로 저장
      'user_id': userId,
      'title': encodedTitle,
      'summary': encodedSummary ?? '',
      'plant_id': plantId ?? '',
      'created_at': Timestamp.fromDate(createdAt),
      'updated_at': updatedAt != null ? Timestamp.fromDate(updatedAt!) : Timestamp.fromDate(DateTime.now()),
      'conversation_type': 'chat', // 기본값으로 'chat' 설정
      'last_message_id': lastMessageId,
      'message_count': messageCount,
    };
  }

  /// 객체 복사본 생성 (일부 속성 수정)
  Conversation copyWith({
    String? id,
    String? userId,
    String? title,
    String? summary,
    String? lastMessage,
    DateTime? lastMessageAt,
    String? lastMessageId,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? agentId,
    int? messageCount,
    double? averageMoodScore,
    bool? moodChangeDetected,
    List<String>? tags,
    bool? isLastMessageFromUser,
    bool? isVoiceConversation,
    int? duration,
    bool? isCompleted,
    String? plantId,
  }) {
    return Conversation(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      summary: summary ?? this.summary,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageAt: lastMessageAt ?? this.lastMessageAt,
      lastMessageId: lastMessageId ?? this.lastMessageId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      agentId: agentId ?? this.agentId,
      messageCount: messageCount ?? this.messageCount,
      averageMoodScore: averageMoodScore ?? this.averageMoodScore,
      moodChangeDetected: moodChangeDetected ?? this.moodChangeDetected,
      tags: tags ?? this.tags,
      isLastMessageFromUser: isLastMessageFromUser ?? this.isLastMessageFromUser,
      isVoiceConversation: isVoiceConversation ?? this.isVoiceConversation,
      duration: duration ?? this.duration,
      isCompleted: isCompleted ?? this.isCompleted,
      plantId: plantId ?? this.plantId,
    );
  }
}

// Message 모델은 별도 파일 (message_model.dart)로 분리됨
