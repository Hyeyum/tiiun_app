// lib/models/message_model.dart - 최적화 버전
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:tiiun/utils/encoding_utils.dart';
import 'package:tiiun/models/sentiment_analysis_result_model.dart';

/// 메시지 모델 - Base64 인코딩 제거 및 성능 최적화
class Message {
  /// 고유 ID (Document ID)
  final String id;

  /// 대화 ID (FireStore 필수 필드)
  final String conversationId;

  /// 메시지 내용 (FireStore 필수 필드) - Base64 인코딩 제거
  final String content;

  /// 발신자 유형 (FireStore 필수 필드)
  final MessageSender sender;

  /// 생성 시간 (FireStore 필수 필드)
  final DateTime createdAt;

  /// 메시지 유형 (FireStore 필수 필드)
  final MessageType type;

  // ========== 추가 기능 필드들 ==========

  /// 사용자 ID (앱 기능상 필요)
  final String userId;

  /// 읽음 여부 (앱 기능상 필요)
  final bool isRead;

  /// 오디오 URL (음성 메시지인 경우)
  final String? audioUrl;

  /// 오디오 길이 (초, 음성 메시지인 경우)
  final int? audioDuration;

  /// 감정 분석 결과 (앱 기능상 필요)
  final SentimentAnalysisResult? sentiment;

  /// 메시지 첨부 파일 (앱 기능상 필요)
  final List<MessageAttachment> attachments;

  /// 메시지 상태 (앱 기능상 필요)
  final MessageStatus status;

  /// 오류 메시지 (전송 실패 시)
  final String? errorMessage;

  /// 메타데이터 (앱 기능상 필요)
  final Map<String, dynamic>? metadata;

  Message({
    required this.id,
    required this.conversationId,
    required this.content,
    required this.sender,
    required this.createdAt,
    this.type = MessageType.text,
    // 추가 기능 필드들
    required this.userId,
    this.isRead = false,
    this.audioUrl,
    this.audioDuration,
    this.sentiment,
    this.attachments = const [],
    this.status = MessageStatus.sent,
    this.errorMessage,
    this.metadata,
  });

  /// 빈 메시지 생성
  factory Message.empty() {
    return Message(
      id: '',
      conversationId: '',
      userId: '',
      content: '',
      sender: MessageSender.user,
      createdAt: DateTime.now(),
    );
  }

  /// Firestore 데이터에서 객체 생성 - 성능 최적화
  factory Message.fromFirestore(DocumentSnapshot doc) {
    try {
      final data = doc.data() as Map<String, dynamic>?;

      if (data == null) {
        throw Exception('Document data is null');
      }

      // FireStore 스키마 필수 필드 확인
      if (!data.containsKey('conversation_id') || !data.containsKey('content')) {
        throw Exception('Required fields missing in document ${doc.id}');
      }

      // ✅ Base64 디코딩 제거 - 직접 텍스트 사용
      String content = data['content'] ?? '';
      String? errorMessage = data['error_message'];

      // ⚠️ 기존 Base64 데이터 호환성을 위한 체크 (점진적 마이그레이션)
      if (content.isNotEmpty && EncodingUtils.isBase64Encoded(content)) {
        try {
          content = EncodingUtils.decodeFromBase64(content);
        } catch (e) {
          debugPrint('Base64 디코딩 실패, 원본 사용: $e');
        }
      }

      if (errorMessage != null && EncodingUtils.isBase64Encoded(errorMessage)) {
        try {
          errorMessage = EncodingUtils.decodeFromBase64(errorMessage);
        } catch (e) {
          debugPrint('Error message Base64 디코딩 실패: $e');
        }
      }

      // 첨부파일 처리 최적화
      List<MessageAttachment> attachments = [];
      try {
        if (data['attachments'] != null) {
          final attachmentList = data['attachments'] as List;
          attachments = attachmentList
              .map((attachment) => MessageAttachment.fromMap(attachment))
              .toList();
        }
      } catch (e) {
        debugPrint('메시지 첨부파일 처리 오류: $e');
        // 첨부파일 오류는 무시하고 빈 리스트 사용
      }

      return Message(
        id: doc.id,
        // ✅ 모든 Firebase 필드를 snake_case에서 읽어 camelCase 변수로 매핑
        conversationId: data['conversation_id'] ?? '',
        content: content,
        sender: MessageSender.values.firstWhere(
              (e) => e.toString().split('.').last == (data['sender'] ?? 'user'),
          orElse: () => MessageSender.user,
        ),
        createdAt: data['created_at'] is Timestamp
            ? (data['created_at'] as Timestamp).toDate()
            : DateTime.now(),
        type: MessageType.values.firstWhere(
              (e) => e.toString().split('.').last == (data['type'] ?? 'text'),
          orElse: () => MessageType.text,
        ),
        // 추가 기능 필드들 - 모두 snake_case에서 읽기
        userId: data['user_id'] ?? '',
        isRead: data['is_read'] ?? false,
        audioUrl: data['audio_url'],
        audioDuration: data['audio_duration'],
        sentiment: data['sentiment'] != null
            ? SentimentAnalysisResult.fromMap(data['sentiment'] as Map<String, dynamic>)
            : null,
        attachments: attachments,
        status: MessageStatus.values.firstWhere(
              (e) => e.toString().split('.').last == (data['status'] ?? 'sent'),
          orElse: () => MessageStatus.sent,
        ),
        errorMessage: errorMessage,
        metadata: data['metadata'],
      );
    } catch (e) {
      debugPrint('Message.fromFirestore 오류: $e, documentId: ${doc.id}');

      return Message(
        id: doc.id,
        conversationId: '',
        userId: '',
        content: '메시지를 불러올 수 없습니다',
        sender: MessageSender.system,
        createdAt: DateTime.now(),
        type: MessageType.system,
      );
    }
  }

  /// Firestore에 저장할 데이터로 변환 - Base64 인코딩 제거
  Map<String, dynamic> toFirestore() {
    // ✅ Base64 인코딩 완전 제거 - UTF-8 직접 저장
    return {
      // ✅ 모든 Firebase 필드를 snake_case로 저장
      'content': content, // 직접 저장 (Base64 인코딩 제거)
      'conversation_id': conversationId,
      'created_at': Timestamp.fromDate(createdAt),
      'sender': sender.toString().split('.').last,
      'type': type.toString().split('.').last,
      // 추가 기능 필드들 - 모두 snake_case로 저장
      'user_id': userId,
      'is_read': isRead,
      'audio_url': audioUrl,
      'audio_duration': audioDuration,
      'sentiment': sentiment?.toFirestore(),
      'attachments': attachments.map((attachment) => attachment.toMap()).toList(),
      'status': status.toString().split('.').last,
      'error_message': errorMessage, // 직접 저장 (Base64 인코딩 제거)
      'metadata': metadata,
    };
  }

  /// 객체 복사본 생성 (일부 속성 수정)
  Message copyWith({
    String? id,
    String? conversationId,
    String? userId,
    String? content,
    MessageSender? sender,
    DateTime? createdAt,
    bool? isRead,
    String? audioUrl,
    int? audioDuration,
    SentimentAnalysisResult? sentiment,
    List<MessageAttachment>? attachments,
    MessageStatus? status,
    String? errorMessage,
    MessageType? type,
    Map<String, dynamic>? metadata,
  }) {
    return Message(
      id: id ?? this.id,
      conversationId: conversationId ?? this.conversationId,
      userId: userId ?? this.userId,
      content: content ?? this.content,
      sender: sender ?? this.sender,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
      audioUrl: audioUrl ?? this.audioUrl,
      audioDuration: audioDuration ?? this.audioDuration,
      sentiment: sentiment ?? this.sentiment,
      attachments: attachments ?? this.attachments,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      type: type ?? this.type,
      metadata: metadata ?? this.metadata,
    );
  }

  // JSON 변환 메서드들도 Base64 인코딩 제거
  factory Message.fromJson(Map<String, dynamic> json) {
    String content = json['content'] as String;
    String? errorMessage = json['error_message'] as String?;

    // 기존 Base64 데이터 호환성 체크
    if (content.isNotEmpty && EncodingUtils.isBase64Encoded(content)) {
      try {
        content = EncodingUtils.decodeFromBase64(content);
      } catch (e) {
        debugPrint('JSON Base64 디코딩 실패: $e');
      }
    }

    if (errorMessage != null && EncodingUtils.isBase64Encoded(errorMessage)) {
      try {
        errorMessage = EncodingUtils.decodeFromBase64(errorMessage);
      } catch (e) {
        debugPrint('Error message JSON Base64 디코딩 실패: $e');
      }
    }

    return Message(
      id: json['id'] as String,
      conversationId: json['conversation_id'] as String,
      userId: json['user_id'] as String,
      content: content,
      sender: MessageSender.values.firstWhere(
            (e) => e.toString().split('.').last == (json['sender'] as String),
        orElse: () => MessageSender.user,
      ),
      createdAt: DateTime.parse(json['created_at'] as String),
      isRead: json['is_read'] as bool? ?? false,
      audioUrl: json['audio_url'] as String?,
      audioDuration: json['audio_duration'] as int?,
      sentiment: json['sentiment'] != null
          ? SentimentAnalysisResult.fromJson(json['sentiment'] as Map<String, dynamic>)
          : null,
      attachments: (json['attachments'] as List<dynamic>?)
          ?.map((e) => MessageAttachment.fromMap(e as Map<String, dynamic>))
          .toList() ?? [],
      status: MessageStatus.values.firstWhere(
            (e) => e.toString().split('.').last == (json['status'] as String? ?? 'sent'),
        orElse: () => MessageStatus.sent,
      ),
      errorMessage: errorMessage,
      type: MessageType.values.firstWhere(
            (e) => e.toString().split('.').last == (json['type'] as String? ?? 'text'),
        orElse: () => MessageType.text,
      ),
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    // Base64 인코딩 제거 - 직접 저장
    return {
      'id': id,
      'conversation_id': conversationId,
      'user_id': userId,
      'content': content, // 직접 저장
      'sender': sender.toString().split('.').last,
      'created_at': createdAt.toIso8601String(),
      'is_read': isRead,
      'audio_url': audioUrl,
      'audio_duration': audioDuration,
      'sentiment': sentiment?.toJson(),
      'attachments': attachments.map((e) => e.toMap()).toList(),
      'status': status.toString().split('.').last,
      'error_message': errorMessage, // 직접 저장
      'type': type.toString().split('.').last,
      'metadata': metadata,
    };
  }

  bool get isUser => sender == MessageSender.user;
  bool get isAgent => sender == MessageSender.agent;
  bool get isSystem => sender == MessageSender.system;

  String get formattedTime {
    final hour = createdAt.hour;
    final minute = createdAt.minute;
    final period = hour >= 12 ? '오후' : '오전';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);

    return '$period ${displayHour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
  }
}

// ========== 관련 Enum 및 클래스들 ==========

/// 메시지 첨부 파일
class MessageAttachment {
  final String url;
  final String type; // 'image', 'audio', 'file'
  final String? fileName;
  final int? fileSize;

  MessageAttachment({
    required this.url,
    required this.type,
    this.fileName,
    this.fileSize,
  });

  factory MessageAttachment.fromMap(Map<String, dynamic> map) {
    return MessageAttachment(
      url: map['url'] ?? '',
      type: map['type'] ?? 'file',
      fileName: map['file_name'] ?? map['fileName'], // 호환성을 위해 둘 다 지원
      fileSize: map['file_size'] ?? map['fileSize'], // 호환성을 위해 둘 다 지원
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'url': url,
      'type': type,
      'file_name': fileName, // snake_case로 저장
      'file_size': fileSize, // snake_case로 저장
    };
  }
}

/// 메시지 상태
enum MessageStatus {
  sent,
  delivered,
  read,
  failed,
}

/// 메시지 유형 (FireStore 스키마 필수)
enum MessageType {
  text,
  audio,
  image,
  file,
  system,
}

/// 메시지 발신자 (FireStore 스키마 필수)
enum MessageSender {
  user,
  agent,
  system,
}
