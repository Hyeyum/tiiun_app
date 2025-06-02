import 'package:cloud_firestore/cloud_firestore.dart';

class MessageModel {
  final String? messageId;
  final String content;
  final String conversationId;
  final DateTime createdAt;
  final String sender; // 'user' 또는 'ai'
  final String type; // 'text', 'voice', 'image' 등
  final String? imageUrl;
  final String? audioUrl;

  MessageModel({
    this.messageId,
    required this.content,
    required this.conversationId,
    required this.createdAt,
    required this.sender,
    this.type = 'text',
    this.imageUrl,
    this.audioUrl,
  });

  // Firestore에서 데이터 가져올 때 사용
  factory MessageModel.fromFirestore(
      Map<String, dynamic> data,
      String id,
      ) {
    return MessageModel(
      messageId: id,
      content: data['content'] ?? '',
      conversationId: data['conversation_id'] ?? '',
      createdAt: data['created_at'] != null
          ? (data['created_at'] as Timestamp).toDate()
          : DateTime.now(),
      sender: data['sender'] ?? 'user',
      type: data['type'] ?? 'text',
      imageUrl: data['image_url'],
      audioUrl: data['audio_url'],
    );
  }

  // Firestore에 저장할 때 사용
  Map<String, dynamic> toFirestore() {
    return {
      'content': content,
      'conversation_id': conversationId,
      'created_at': Timestamp.fromDate(createdAt),
      'sender': sender,
      'type': type,
      'image_url': imageUrl,
      'audio_url': audioUrl,
    };
  }

  // 새 메시지 생성 (일반)
  factory MessageModel.create({
    required String conversationId,
    required String content,
    required String sender,
    String type = 'text',
  }) {
    return MessageModel(
      conversationId: conversationId,
      content: content,
      createdAt: DateTime.now(),
      sender: sender,
      type: type,
    );
  }

  // 메시지 타입별 판별
  bool get isText => type == 'text';
  bool get isVoice => type == 'voice';
  bool get isImage => type == 'image';
  bool get isUser => sender == 'user';
  bool get isAi => sender == 'ai';

  // 복사본 생성
  MessageModel copyWith({
    String? messageId,
    String? content,
    String? conversationId,
    DateTime? createdAt,
    String? sender,
    String? type,
  }) {
    return MessageModel(
      messageId: messageId ?? this.messageId,
      content: content ?? this.content,
      conversationId: conversationId ?? this.conversationId,
      createdAt: createdAt ?? this.createdAt,
      sender: sender ?? this.sender,
      type: type ?? this.type,
    );
  }

  // 시간 포맷팅
  String get formattedTime {
    final hour = createdAt.hour;
    final minute = createdAt.minute;
    final period = hour >= 12 ? '오후' : '오전';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);

    return '$period ${displayHour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
  }

  @override
  String toString() {
    return 'MessageModel(id: $messageId, type: $type, sender: $sender, content: ${content.length > 30 ? '${content.substring(0, 30)}...' : content})';
  }
}