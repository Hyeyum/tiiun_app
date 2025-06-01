// lib/models/message_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:tiiun/utils/encoding_utils.dart';
import 'package:tiiun/models/sentiment_analysis_result_model.dart';


/// 메시지 모델
///
/// 대화 내의 개별 메시지를 나타냅니다.
class Message {
  /// 고유 ID (Document ID)
  final String id;

  /// 대화 ID (FireStore 필수 필드)
  final String conversation_id;

  /// 메시지 내용 (FireStore 필수 필드)
  final String content;

  /// 발신자 유형 (FireStore 필수 필드)
  final MessageSender sender;

  /// 생성 시간 (FireStore 필수 필드)
  final DateTime created_at;

  /// 메시지 유형 (FireStore 필수 필드)
  final MessageType type;

  // ========== 추가 기능 필드들 (FireStore 스키마에는 없지만 앱 기능상 필요) ==========
  
  /// 사용자 ID (앱 기능상 필요)
  final String user_id;

  /// 읽음 여부 (앱 기능상 필요)
  final bool is_read;

  /// 오디오 URL (음성 메시지인 경우)
  final String? audio_url;

  /// 오디오 길이 (초, 음성 메시지인 경우)
  final int? audio_duration;

  /// 감정 분석 결과 (앱 기능상 필요)
  final SentimentAnalysisResult? sentiment;

  /// 메시지 첨부 파일 (앱 기능상 필요)
  final List<MessageAttachment> attachments;

  /// 메시지 상태 (앱 기능상 필요)
  final MessageStatus status;

  /// 오류 메시지 (전송 실패 시)
  final String? error_message;

  /// 메타데이터 (앱 기능상 필요)
  final Map<String, dynamic>? metadata;

  Message({
    required this.id,
    required this.conversation_id,
    required this.content,
    required this.sender,
    required this.created_at,
    this.type = MessageType.text,
    // 추가 기능 필드들
    required this.user_id,
    this.is_read = false,
    this.audio_url,
    this.audio_duration,
    this.sentiment,
    this.attachments = const [],
    this.status = MessageStatus.sent,
    this.error_message,
    this.metadata,
  });

  /// 빈 메시지 생성
  factory Message.empty() {
    return Message(
      id: '',
      conversation_id: '',
      user_id: '',
      content: '',
      sender: MessageSender.user,
      created_at: DateTime.now(),
    );
  }

  /// Firestore 데이터에서 객체 생성
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

      // 텍스트 필드 자동 디코딩 처리
      String content = data['content'] ?? '';
      String? error_message = data['errorMessage'];

      content = EncodingUtils.tryAllFixMethods(content);

      if (error_message != null) {
        error_message = EncodingUtils.tryAllFixMethods(error_message);
      }

      List<MessageAttachment> attachments = [];
      try {
        if (data['attachments'] != null) {
          attachments = (data['attachments'] as List)
              .map((attachment) => MessageAttachment.fromMap(attachment))
              .toList();
        }
      } catch (e) {
        debugPrint('메시지 첨부파일 처리 오류: $e');
      }

      return Message(
        id: doc.id,
        // FireStore 스키마 필수 필드들
        conversation_id: data['conversation_id'] ?? '',
        content: content,
        sender: MessageSender.values.firstWhere(
          (e) => e.toString().split('.').last == (data['sender'] ?? 'user'),
          orElse: () => MessageSender.user,
        ),
        created_at: data['created_at'] is Timestamp
            ? (data['created_at'] as Timestamp).toDate()
            : DateTime.now(),
        type: MessageType.values.firstWhere(
          (e) => e.toString().split('.').last == (data['type'] ?? 'text'),
          orElse: () => MessageType.text,
        ),
        // 추가 기능 필드들
        user_id: data['userId'] ?? '',
        is_read: data['isRead'] ?? false,
        audio_url: data['audioUrl'],
        audio_duration: data['audioDuration'],
        sentiment: data['sentiment'] != null
            ? SentimentAnalysisResult.fromMap(data['sentiment'] as Map<String, dynamic>)
            : null,
        attachments: attachments,
        status: MessageStatus.values.firstWhere(
          (e) => e.toString().split('.').last == (data['status'] ?? 'sent'),
          orElse: () => MessageStatus.sent,
        ),
        error_message: error_message,
        metadata: data['metadata'],
      );
    } catch (e) {
      debugPrint('Message.fromFirestore 오류: $e, documentId: ${doc.id}');

      return Message(
        id: doc.id,
        conversation_id: '',
        user_id: '',
        content: '메시지를 불러올 수 없습니다',
        sender: MessageSender.system,
        created_at: DateTime.now(),
        type: MessageType.system,
      );
    }
  }

  /// Firestore에 저장할 데이터로 변환 (FireStore 스키마 필드만 포함)
  Map<String, dynamic> toFirestore() {
    String encoded_content = EncodingUtils.encodeToBase64(content);
    String? encoded_error_message = error_message != null ? EncodingUtils.encodeToBase64(error_message!) : null;

    return {
      // FireStore 스키마 필수 필드들
      'content': encoded_content,
      'conversation_id': conversation_id,
      'created_at': Timestamp.fromDate(created_at),
      'sender': sender.toString().split('.').last,
      'type': type.toString().split('.').last,
      // 추가 기능 필드들 (앱에서 사용)
      'userId': user_id,
      'isRead': is_read,
      'audioUrl': audio_url,
      'audioDuration': audio_duration,
      'sentiment': sentiment?.toFirestore(),
      'attachments': attachments.map((attachment) => attachment.toMap()).toList(),
      'status': status.toString().split('.').last,
      'errorMessage': encoded_error_message,
      'metadata': metadata,
    };
  }

  /// 객체 복사본 생성 (일부 속성 수정)
  Message copyWith({
    String? id,
    String? conversation_id,
    String? user_id,
    String? content,
    MessageSender? sender,
    DateTime? created_at,
    bool? is_read,
    String? audio_url,
    int? audio_duration,
    SentimentAnalysisResult? sentiment,
    List<MessageAttachment>? attachments,
    MessageStatus? status,
    String? error_message,
    MessageType? type,
    Map<String, dynamic>? metadata,
  }) {
    return Message(
      id: id ?? this.id,
      conversation_id: conversation_id ?? this.conversation_id,
      user_id: user_id ?? this.user_id,
      content: content ?? this.content,
      sender: sender ?? this.sender,
      created_at: created_at ?? this.created_at,
      is_read: is_read ?? this.is_read,
      audio_url: audio_url ?? this.audio_url,
      audio_duration: audio_duration ?? this.audio_duration,
      sentiment: sentiment ?? this.sentiment,
      attachments: attachments ?? this.attachments,
      status: status ?? this.status,
      error_message: error_message ?? this.error_message,
      type: type ?? this.type,
      metadata: metadata ?? this.metadata,
    );
  }

  factory Message.fromJson(Map<String, dynamic> json) {
    String content = json['content'] as String;
    String? error_message = json['error_message'] as String?;

    content = EncodingUtils.tryAllFixMethods(content);

    if (error_message != null) {
      error_message = EncodingUtils.tryAllFixMethods(error_message);
    }

    return Message(
      id: json['id'] as String,
      conversation_id: json['conversation_id'] as String,
      user_id: json['user_id'] as String,
      content: content,
      sender: MessageSender.values.firstWhere(
        (e) => e.toString().split('.').last == (json['sender'] as String),
        orElse: () => MessageSender.user,
      ),
      created_at: DateTime.parse(json['created_at'] as String),
      is_read: json['is_read'] as bool? ?? false,
      audio_url: json['audio_url'] as String?,
      audio_duration: json['audio_duration'] as int?,
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
      error_message: error_message,
      type: MessageType.values.firstWhere(
        (e) => e.toString().split('.').last == (json['type'] as String? ?? 'text'),
        orElse: () => MessageType.text,
      ),
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    String encoded_content = EncodingUtils.encodeToBase64(content);
    String? encoded_error_message = error_message != null ? EncodingUtils.encodeToBase64(error_message!) : null;

    return {
      'id': id,
      'conversation_id': conversation_id,
      'user_id': user_id,
      'content': encoded_content,
      'sender': sender.toString().split('.').last,
      'created_at': created_at.toIso8601String(),
      'is_read': is_read,
      'audio_url': audio_url,
      'audio_duration': audio_duration,
      'sentiment': sentiment?.toJson(),
      'attachments': attachments.map((e) => e.toMap()).toList(),
      'status': status.toString().split('.').last,
      'error_message': encoded_error_message,
      'type': type.toString().split('.').last,
      'metadata': metadata,
    };
  }

  bool get is_user => sender == MessageSender.user;
  bool get is_agent => sender == MessageSender.agent;
  bool get is_system => sender == MessageSender.system;

  String get formatted_time {
    final hour = created_at.hour;
    final minute = created_at.minute;
    final period = hour >= 12 ? '오후' : '오전';
    final display_hour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);

    return '$period ${display_hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
  }
}

// ========== 관련 Enum 및 클래스들 ==========

/// 메시지 첨부 파일
class MessageAttachment {
  final String url;
  final String type; // 'image', 'audio', 'file'
  final String? file_name;
  final int? file_size;

  MessageAttachment({
    required this.url,
    required this.type,
    this.file_name,
    this.file_size,
  });

  factory MessageAttachment.fromMap(Map<String, dynamic> map) {
    return MessageAttachment(
      url: map['url'] ?? '',
      type: map['type'] ?? 'file',
      file_name: map['fileName'],
      file_size: map['fileSize'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'url': url,
      'type': type,
      'fileName': file_name,
      'fileSize': file_size,
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
