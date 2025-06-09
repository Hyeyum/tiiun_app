// lib/services/conversation_service_optimized.dart - 성능 최적화 버전
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import '../models/conversation_model.dart';
import '../models/message_model.dart'; // Message 모델 import 추가
import 'auth_service.dart';
import '../utils/encoding_utils.dart'; // Ensure EncodingUtils is available
import '../utils/error_handler.dart'; // ✅ ErrorHandler import 추가

// 디버깅 로그 활성화 (개발 중에만 사용)
const bool _enableDebugLog = true;

// ✅ 성능 최적화: 페이지네이션 상수
const int DEFAULT_MESSAGE_LIMIT = 50;
const int DEFAULT_CONVERSATION_LIMIT = 20;

// 대화 서비스 Provider
final conversationServiceProvider = Provider<ConversationService>((ref) {
  final authService = ref.watch(authServiceProvider);
  return ConversationService(FirebaseFirestore.instance, authService);
});

// 사용자 대화 목록 Provider - 페이지네이션 적용
final userConversationsProvider = StreamProvider<List<Conversation>>((ref) {
  final conversationService = ref.watch(conversationServiceProvider);
  return conversationService.getConversations(limit: DEFAULT_CONVERSATION_LIMIT);
});

// ✅ 성능 최적화: 스트림 캐싱을 위한 Provider
final conversationStreamCacheProvider = StateNotifierProvider<ConversationStreamCache, Map<String, Stream<List<Message>>>>((ref) {
  return ConversationStreamCache();
});

/// ✅ 스트림 캐싱 클래스 - 중복 스트림 방지
class ConversationStreamCache extends StateNotifier<Map<String, Stream<List<Message>>>> {
  ConversationStreamCache() : super({});

  Stream<List<Message>> getOrCreateStream(String conversationId, Stream<List<Message>> Function() createStream) {
    if (state.containsKey(conversationId)) {
      return state[conversationId]!;
    }

    final stream = createStream();
    state = {...state, conversationId: stream};
    return stream;
  }

  void removeStream(String conversationId) {
    final newState = Map<String, Stream<List<Message>>>.from(state);
    newState.remove(conversationId);
    state = newState;
  }

  void clearAllStreams() {
    state = {};
  }
}

class ConversationService {
  final FirebaseFirestore _firestore;
  final AuthService _authService;

  // ✅ 성능 최적화: 쿼리 캐시
  final Map<String, DateTime> _lastFetchTimes = {};
  final Map<String, List<Conversation>> _conversationCache = {};
  final Map<String, List<Message>> _messageCache = {};

  // ✅ 스트림 구독 관리
  final Map<String, StreamSubscription> _activeSubscriptions = {};

  ConversationService(this._firestore, this._authService);

  /// 리소스 정리
  void dispose() {
    for (final subscription in _activeSubscriptions.values) {
      subscription.cancel();
    }
    _activeSubscriptions.clear();
    _conversationCache.clear();
    _messageCache.clear();
    _lastFetchTimes.clear();
  }

  /// 대화 목록 가져오기 (Stream) - 마지막 메시지 포함
  Stream<List<Conversation>> getConversations({int limit = DEFAULT_CONVERSATION_LIMIT}) {
    final userId = _authService.getCurrentUserId();
    if (userId == null) {
      return Stream.value([]);
    }

    return _firestore
        .collection('conversations')
        .where('user_id', isEqualTo: userId)
        .orderBy('updated_at', descending: true)
        .limit(limit)
        .snapshots()
        .asyncMap((snapshot) async {

      final conversations = <Conversation>[];

      for (final doc in snapshot.docs) {
        final conversation = Conversation.fromFirestore(doc);

        // 각 대화의 마지막 메시지 가져오기
        String lastMessage = '';
        if (conversation.lastMessageId != null && conversation.lastMessageId!.isNotEmpty) {
          try {
            final lastMessageDoc = await _firestore
                .collection('messages')
                .doc(conversation.lastMessageId!)
                .get();

            if (lastMessageDoc.exists) {
              final messageData = lastMessageDoc.data()!;
              lastMessage = messageData['content'] ?? '';

              // Base64 디코딩이 필요한 경우
              if (lastMessage.isNotEmpty && EncodingUtils.isBase64Encoded(lastMessage)) {
                try {
                  lastMessage = EncodingUtils.decodeFromBase64(lastMessage);
                } catch (e) {
                  debugPrint('마지막 메시지 디코딩 실패: $e');
                }
              }
            }
          } catch (e) {
            debugPrint('마지막 메시지 가져오기 실패: $e');
          }
        }

        // 마지막 메시지가 없으면 최신 메시지 하나 가져오기
        if (lastMessage.isEmpty) {
          try {
            final recentMessageSnapshot = await _firestore
                .collection('messages')
                .where('conversation_id', isEqualTo: conversation.id)
                .orderBy('created_at', descending: true)
                .limit(1)
                .get();

            if (recentMessageSnapshot.docs.isNotEmpty) {
              final messageData = recentMessageSnapshot.docs.first.data();
              lastMessage = messageData['content'] ?? '';

              // Base64 디코딩이 필요한 경우
              if (lastMessage.isNotEmpty && EncodingUtils.isBase64Encoded(lastMessage)) {
                try {
                  lastMessage = EncodingUtils.decodeFromBase64(lastMessage);
                } catch (e) {
                  debugPrint('최신 메시지 디코딩 실패: $e');
                }
              }
            }
          } catch (e) {
            debugPrint('최신 메시지 가져오기 실패: $e');
          }
        }

        // 마지막 메시지를 포함한 새 대화 객체 생성
        conversations.add(conversation.copyWith(lastMessage: lastMessage));
      }

      return conversations;
    });
  }

  /// 대화 목록 가져오기 (Future) - 성능 최적화
  Future<List<Conversation>> getUserConversations({int limit = DEFAULT_CONVERSATION_LIMIT}) async {
    final userId = _authService.getCurrentUserId();
    if (userId == null) {
      return [];
    }

    try {
      // ✅ 캐시 확인
      final cacheKey = '${userId}_conversations';
      final lastFetch = _lastFetchTimes[cacheKey];
      final now = DateTime.now();

      if (lastFetch != null &&
          now.difference(lastFetch).inMinutes < 5 &&
          _conversationCache.containsKey(cacheKey)) {
        return _conversationCache[cacheKey]!;
      }

      final snapshot = await _firestore
          .collection('conversations')
          .where('user_id', isEqualTo: userId) // user_id로 수정
          .orderBy('updated_at', descending: true) // updated_at으로 수정
          .limit(limit) // ✅ 페이지네이션 적용
          .get();

      final conversations = snapshot.docs.map((doc) {
        // Firestore 데이터에서 객체 생성시 Conversation.fromFirestore에서 자동 디코딩 처리
        return Conversation.fromFirestore(doc);
      }).toList();

      // ✅ 캐시 업데이트
      _conversationCache[cacheKey] = conversations;
      _lastFetchTimes[cacheKey] = now;

      return conversations;
    } catch (e) {
      debugPrint('대화 목록 가져오기 오류: $e');
      return [];
    }
  }

  /// 대화 가져오기 - 캐싱 적용
  Future<Conversation?> getConversation(String conversationId) async {
    try {
      // ✅ 캐시 확인
      final cacheKey = 'conversation_$conversationId';
      final lastFetch = _lastFetchTimes[cacheKey];
      final now = DateTime.now();

      if (lastFetch != null &&
          now.difference(lastFetch).inMinutes < 2) {
        // 대화 상세 정보는 2분 캐시
        final cached = _conversationCache.values
            .expand((conversations) => conversations)
            .where((c) => c.id == conversationId)
            .firstOrNull;
        if (cached != null) return cached;
      }

      final doc = await _firestore
          .collection('conversations')
          .doc(conversationId)
          .get();

      if (!doc.exists) {
        return null;
      }

      final conversation = Conversation.fromFirestore(doc);
      _lastFetchTimes[cacheKey] = now;

      return conversation;
    } catch (e) {
      debugPrint('대화 가져오기 실패: $e');
      return null;
    }
  }

  /// 새 대화 생성 및 대화 ID 확인 로직 추가 - Base64 인코딩 제거
  Future<Conversation> createConversation({
    required String title,
    required String agentId,
    String? specificId,  // 특정 ID를 사용하고 싶을 때
    String? plantId, // plant_id 추가
  }) async {
    try {
      final userId = _authService.getCurrentUserId();
      if (userId == null) {
        throw Exception('사용자가 로그인되어 있지 않습니다.');
      }

      // ✅ Base64 인코딩 제거 - 원본 텍스트 직접 저장
      final newConversation = Conversation(
        id: specificId ?? '', // ID는 Firestore에서 생성되거나 specificId 사용
        userId: userId,
        title: title, // 원본 제목 직접 저장
        lastMessage: '',
        lastMessageAt: DateTime.now(),
        lastMessageId: null, // 초기 생성 시 null
        createdAt: DateTime.now(),
        agentId: agentId,
        messageCount: 0,
        isCompleted: false,
        plantId: plantId, // plant_id 추가
      );

      DocumentReference docRef;

      // 특정 ID를 요청한 경우 해당 ID로 문서 생성 시도
      if (specificId != null && specificId.isNotEmpty) {
        // 해당 ID의 문서가 존재하는지 확인
        final existingDoc = await _firestore
            .collection('conversations')
            .doc(specificId)
            .get();

        if (existingDoc.exists) {
          // 이미 존재하는 경우 해당 대화 반환
          debugPrint('이미 존재하는 대화 ID: $specificId');
          return Conversation.fromFirestore(existingDoc);
        } else {
          // 존재하지 않는 경우 새로 생성
          docRef = _firestore.collection('conversations').doc(specificId);
          await docRef.set(newConversation.toFirestore()); // 직접 저장 (Base64 인코딩 제거)
        }
      } else {
        // 새 문서 ID 자동 생성
        docRef = await _firestore
            .collection('conversations')
            .add(newConversation.toFirestore()); // 직접 저장 (Base64 인코딩 제거)
      }

      // ✅ 캐시 무효화
      _invalidateConversationCache();

      // 생성된 대화의 ID를 업데이트하고 반환
      return newConversation.copyWith(id: docRef.id);
    } catch (e) {
      debugPrint('대화 생성 오류: $e');
      throw Exception('대화를 생성할 수 없습니다: $e');
    }
  }

  /// 대화에 메시지 추가 - Base64 인코딩 제거 및 성능 최적화
  Future<Message> addMessage({
    required String conversationId,
    required String content,
    required MessageSender sender,
    String? audioUrl,
    int? audioDuration,
    MessageType type = MessageType.text,
    List<MessageAttachment>? attachments, // 첨부파일 추가
  }) async {
    try {
      final userId = _authService.getCurrentUserId();
      if (userId == null) {
        throw Exception('사용자가 로그인되어 있지 않습니다.');
      }

      // 대화 존재 여부 확인 (필요한 경우 생성)
      final conversationDoc = await _firestore
          .collection('conversations')
          .doc(conversationId)
          .get();

      if (!conversationDoc.exists) {
        // 대화가 존재하지 않으면 새로 생성
        debugPrint('대화가 존재하지 않아 새로 생성합니다: $conversationId');
        await createConversation(
          title: '새 대화', // 임시 제목
          agentId: 'default',
          specificId: conversationId,
        );
      }

      // ✅ Base64 인코딩 제거 - 원본 텍스트 직접 저장
      final newMessage = Message(
        id: '', // ID는 Firestore에서 생성됨
        conversationId: conversationId,
        userId: userId,
        content: content, // 원본 내용 직접 저장
        sender: sender,
        createdAt: DateTime.now(),
        isRead: false,
        audioUrl: audioUrl,
        audioDuration: audioDuration,
        status: MessageStatus.sent,
        type: type,
        attachments: attachments ?? [], // 첨부파일 추가
      );

      // Firestore에 새 메시지 추가
      final messageRef = await _firestore
          .collection('messages')
          .add(newMessage.toFirestore()); // 직접 저장 (Base64 인코딩 제거)

      // 대화 정보 업데이트 (스키마에 맞게 수정)
      await _firestore
          .collection('conversations')
          .doc(conversationId)
          .update({
        'updated_at': Timestamp.fromDate(DateTime.now()), // updated_at 업데이트
        'last_message_id': messageRef.id, // last_message_id 업데이트
        'message_count': FieldValue.increment(1), // message_count 업데이트
      });

      // ✅ 캐시 무효화
      _invalidateMessageCache(conversationId);
      _invalidateConversationCache();

      // 메시지 객체 반환 (원본 내용 반환)
      return newMessage.copyWith(id: messageRef.id);
    } catch (e) {
      debugPrint('메시지 추가 오류: $e');
      throw Exception('메시지를 추가할 수 없습니다: $e');
    }
  }

  /// 대화의 메시지 목록 가져오기 - 성능 최적화 및 페이지네이션
  Stream<List<Message>> getConversationMessages(String conversationId, {int limit = DEFAULT_MESSAGE_LIMIT}) {
    // ✅ conversationId 유효성 검사
    if (conversationId.isEmpty) {
      return Stream.error('Invalid conversation ID');
    }

    return _firestore
        .collection('messages')
        .where('conversation_id', isEqualTo: conversationId) // 필드명 반영
        .orderBy('created_at', descending: true) // 최신 메시지부터
        .limit(limit) // ✅ 페이지네이션 적용
        .snapshots()
        .map((snapshot) {
      if (_enableDebugLog) {
        debugPrint('---------- 메시지 로드 시작 ----------');
        debugPrint('메시지 갯수: ${snapshot.docs.length}');
      }

      final messages = <Message>[];

      for (final doc in snapshot.docs) {
        try {
          // ✅ 각 메시지별로 개별 에러 처리
          final message = Message.fromFirestore(doc);
          messages.add(message);
        } catch (e) {
          debugPrint('메시지 변환 오류: $e, documentId: ${doc.id}');
          // ✅ 오류 발생한 메시지는 스킵하고 계속 진행
          continue;
        }
      }

      // ✅ 메시지 캐시 업데이트
      _messageCache[conversationId] = messages;
      _lastFetchTimes['messages_$conversationId'] = DateTime.now();

      return messages;
    })
        .handleError((error) {
      debugPrint('메시지 스트림 오류: $error');
      throw ErrorHandler.handleException(error);
    });
  }

  /// ✅ 페이지네이션을 위한 추가 메시지 로드
  Future<List<Message>> loadMoreMessages(String conversationId, {
    required DocumentSnapshot lastDocument,
    int limit = DEFAULT_MESSAGE_LIMIT,
  }) async {
    try {
      final snapshot = await _firestore
          .collection('messages')
          .where('conversation_id', isEqualTo: conversationId)
          .orderBy('created_at', descending: true)
          .startAfterDocument(lastDocument)
          .limit(limit)
          .get();

      return snapshot.docs.map((doc) => Message.fromFirestore(doc)).toList();
    } catch (e) {
      debugPrint('추가 메시지 로드 오류: $e');
      return [];
    }
  }

  /// 대화 제목 업데이트 - Base64 인코딩 제거
  Future<void> updateConversationTitle(String conversationId, String newTitle) async {
    try {
      // ✅ Base64 인코딩 제거 - 직접 저장
      await _firestore
          .collection('conversations')
          .doc(conversationId)
          .update({
        'title': newTitle, // 직접 저장
        'updated_at': Timestamp.fromDate(DateTime.now()), // updated_at로 수정
      });

      // ✅ 캐시 무효화
      _invalidateConversationCache();
    } catch (e) {
      debugPrint('대화 제목 업데이트 오류: $e');
      throw Exception('대화 제목을 업데이트할 수 없습니다: $e');
    }
  }

  /// 대화 요약 업데이트 - Base64 인코딩 제거
  Future<void> updateConversationSummary(String conversationId, String summary) async {
    try {
      // ✅ Base64 인코딩 제거 - 직접 저장
      await _firestore
          .collection('conversations')
          .doc(conversationId)
          .update({
        'summary': summary, // 직접 저장
        'updated_at': Timestamp.fromDate(DateTime.now()), // updated_at로 수정
      });

      // ✅ 캐시 무효화
      _invalidateConversationCache();
    } catch (e) {
      debugPrint('대화 요약 업데이트 오류: $e');
      throw Exception('대화 요약을 업데이트할 수 없습니다: $e');
    }
  }

  /// 대화 태그 업데이트 - Base64 인코딩 제거
  Future<void> updateConversationTags(String conversationId, List<String> tags) async {
    try {
      // ✅ Base64 인코딩 제거 - 태그 직접 저장
      await _firestore
          .collection('conversations')
          .doc(conversationId)
          .update({
        'tags': tags, // 직접 저장
        'updatedAt': DateTime.now(),
      });

      // ✅ 캐시 무효화
      _invalidateConversationCache();
    } catch (e) {
      debugPrint('대화 태그 업데이트 오류: $e');
      throw Exception('대화 태그를 업데이트할 수 없습니다: $e');
    }
  }

  /// 대화 감정 점수 업데이트
  Future<void> updateConversationMoodScore(String conversationId, double moodScore, bool moodChanged) async {
    try {
      await _firestore
          .collection('conversations')
          .doc(conversationId)
          .update({
        'averageMoodScore': moodScore,
        'moodChangeDetected': moodChanged,
        'updatedAt': DateTime.now(),
      });

      // ✅ 캐시 무효화
      _invalidateConversationCache();
    } catch (e) {
      debugPrint('대화 감정 점수 업데이트 오류: $e');
      throw Exception('대화 감정 점수를 업데이트할 수 없습니다: $e');
    }
  }

  /// 대화 완료 상태 업데이트
  Future<void> completeConversation(String conversationId) async {
    try {
      await _firestore
          .collection('conversations')
          .doc(conversationId)
          .update({
        'isCompleted': true,
        'updatedAt': DateTime.now(),
      });

      // ✅ 캐시 무효화
      _invalidateConversationCache();
    } catch (e) {
      debugPrint('대화 완료 상태 업데이트 오류: $e');
      throw Exception('대화 완료 상태를 업데이트할 수 없습니다: $e');
    }
  }

  /// 대화 삭제 - 배치 처리 최적화
  Future<void> deleteConversation(String conversationId) async {
    try {
      // ✅ 배치 처리로 성능 최적화
      final batch = _firestore.batch();

      // 대화 문서 삭제
      batch.delete(_firestore.collection('conversations').doc(conversationId));

      // 관련 메시지 삭제
      final messagesSnapshot = await _firestore
          .collection('messages')
          .where('conversation_id', isEqualTo: conversationId) // 필드명 반영
          .get();

      for (final doc in messagesSnapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();

      // ✅ 캐시 무효화
      _invalidateConversationCache();
      _invalidateMessageCache(conversationId);
    } catch (e) {
      debugPrint('대화 삭제 오류: $e');
      throw Exception('대화를 삭제할 수 없습니다: $e');
    }
  }

  /// 여러 대화 삭제 - 배치 처리 최적화
  Future<void> deleteMultipleConversations(List<String> conversationIds) async {
    if (conversationIds.isEmpty) return;

    try {
      final userId = _authService.getCurrentUserId();
      if (userId == null) {
        throw Exception('사용자가 로그인되어 있지 않습니다.');
      }

      // ✅ 배치 처리 최적화 - 500개 제한 고려
      for (int i = 0; i < conversationIds.length; i += 400) {
        final batchIds = conversationIds.skip(i).take(400).toList();
        await _deleteBatchConversations(batchIds);
      }

      // ✅ 캐시 무효화
      _invalidateConversationCache();
      for (final id in conversationIds) {
        _invalidateMessageCache(id);
      }

      debugPrint('${conversationIds.length}개의 대화가 삭제되었습니다.');
    } catch (e) {
      debugPrint('여러 대화 삭제 오류: $e');
      throw Exception('대화를 삭제할 수 없습니다: $e');
    }
  }

  /// 배치 단위 대화 삭제
  Future<void> _deleteBatchConversations(List<String> conversationIds) async {
    final batch = _firestore.batch();
    int operationCount = 0;

    for (final conversationId in conversationIds) {
      // 대화 문서 삭제 작업 추가
      batch.delete(_firestore.collection('conversations').doc(conversationId));
      operationCount++;

      // 관련 메시지 검색 및 삭제
      final messagesSnapshot = await _firestore
          .collection('messages')
          .where('conversation_id', isEqualTo: conversationId)
          .get();

      for (final messageDoc in messagesSnapshot.docs) {
        if (operationCount >= 400) break; // 배치 제한
        batch.delete(messageDoc.reference);
        operationCount++;
      }

      if (operationCount >= 400) break;
    }

    if (operationCount > 0) {
      await batch.commit();
    }
  }

  /// 메시지 읽음 상태 업데이트 - 배치 처리 최적화
  Future<void> markMessagesAsRead(String conversationId) async {
    try {
      final userId = _authService.getCurrentUserId();
      if (userId == null) {
        throw Exception('사용자가 로그인되어 있지 않습니다.');
      }

      // 읽지 않은 메시지 조회
      final messagesSnapshot = await _firestore
          .collection('messages')
          .where('conversation_id', isEqualTo: conversationId) // 필드명 반영
          .where('isRead', isEqualTo: false)
          .where('sender', isEqualTo: MessageSender.agent.toString().split('.').last)
          .get();

      if (messagesSnapshot.docs.isEmpty) {
        return; // 읽지 않은 메시지가 없음
      }

      // ✅ 배치 처리로 성능 최적화
      final batch = _firestore.batch();
      for (final doc in messagesSnapshot.docs) {
        batch.update(doc.reference, {'isRead': true});
      }

      await batch.commit();

      // ✅ 캐시 무효화
      _invalidateMessageCache(conversationId);
    } catch (e) {
      debugPrint('메시지 읽음 상태 업데이트 오류: $e');
      throw Exception('메시지 읽음 상태를 업데이트할 수 없습니다: $e');
    }
  }

  /// 모든 대화 삭제
  Future<void> deleteAllConversations() async {
    try {
      final userId = _authService.getCurrentUserId();
      if (userId == null) {
        throw Exception('사용자가 로그인되어 있지 않습니다.');
      }

      // 사용자의 모든 대화 가져오기 (스키마에 맞게 수정)
      final conversationsSnapshot = await _firestore
          .collection('conversations')
          .where('user_id', isEqualTo: userId) // user_id로 수정
          .get();

      // 대화가 없으면 종료
      if (conversationsSnapshot.docs.isEmpty) {
        return;
      }

      // 모든 대화 ID 목록
      final conversationIds = conversationsSnapshot.docs.map((doc) => doc.id).toList();

      // 여러 대화 삭제 메서드 호출 (배치 처리 최적화)
      await deleteMultipleConversations(conversationIds);

      debugPrint('모든 대화가 삭제되었습니다.');
    } catch (e) {
      debugPrint('모든 대화 삭제 오류: $e');
      throw Exception('모든 대화를 삭제할 수 없습니다: $e');
    }
  }

  /// ✅ 캐시 무효화 메서드들
  void _invalidateConversationCache() {
    _conversationCache.clear();
    _lastFetchTimes.removeWhere((key, value) => key.contains('conversations'));
  }

  void _invalidateMessageCache(String conversationId) {
    _messageCache.remove(conversationId);
    _lastFetchTimes.remove('messages_$conversationId');
  }

  /// ✅ 수동 캐시 클리어 (메모리 관리)
  void clearAllCaches() {
    _conversationCache.clear();
    _messageCache.clear();
    _lastFetchTimes.clear();
  }

  /// ✅ 메모리 사용량 체크
  int getCacheSize() {
    int totalSize = 0;
    totalSize += _conversationCache.values.fold(0, (sum, list) => sum + list.length);
    totalSize += _messageCache.values.fold(0, (sum, list) => sum + list.length);
    return totalSize;
  }

  // 기존의 인코딩 문제 해결 메소드들은 Base64 제거로 인해 더 이상 필요하지 않음
  // 하지만 기존 데이터 마이그레이션을 위해 유지

  /// 인코딩 문제 해결을 위한 데이터 정비 메소드 (마이그레이션용)
  Future<Map<String, dynamic>> fixConversationEncodings(String conversationId) async {
    try {
      int messagesFixed = 0;
      int fieldsFixed = 0;

      // 1. 대화 정보 가져오기
      final conversationDoc = await _firestore
          .collection('conversations')
          .doc(conversationId)
          .get();

      if (!conversationDoc.exists) {
        throw Exception('대화를 찾을 수 없습니다: $conversationId');
      }

      // 2. 대화 필드 정비 (Base64 → 직접 저장으로 마이그레이션)
      final data = conversationDoc.data()!;
      Map<String, dynamic> updates = {};

      // 제목 정비
      if (data['title'] != null) {
        final title = data['title'] as String;
        if (EncodingUtils.isBase64Encoded(title)) {
          try {
            final decodedTitle = EncodingUtils.decodeFromBase64(title);
            updates['title'] = decodedTitle; // 직접 저장
            fieldsFixed++;
          } catch (e) {
            debugPrint('Title 디코딩 실패: $e');
          }
        }
      }

      // 요약 정비
      if (data['summary'] != null) {
        final summary = data['summary'] as String;
        if (EncodingUtils.isBase64Encoded(summary)) {
          try {
            final decodedSummary = EncodingUtils.decodeFromBase64(summary);
            updates['summary'] = decodedSummary; // 직접 저장
            fieldsFixed++;
          } catch (e) {
            debugPrint('Summary 디코딩 실패: $e');
          }
        }
      }

      // 대화 업데이트 필요시 실행
      if (updates.isNotEmpty) {
        updates['updatedAt'] = DateTime.now();
        await _firestore
            .collection('conversations')
            .doc(conversationId)
            .update(updates);

        debugPrint('대화 정보 Base64 → 직접 저장 마이그레이션 완료: $fieldsFixed 필드 수정');
      }

      // 3. 메시지 정비 (Base64 → 직접 저장으로 마이그레이션)
      final messagesSnapshot = await _firestore
          .collection('messages')
          .where('conversation_id', isEqualTo: conversationId)
          .get();

      for (final messageDoc in messagesSnapshot.docs) {
        final messageData = messageDoc.data();
        final content = messageData['content'] as String? ?? '';

        if (content.isNotEmpty && EncodingUtils.isBase64Encoded(content)) {
          try {
            final decodedContent = EncodingUtils.decodeFromBase64(content);

            await _firestore
                .collection('messages')
                .doc(messageDoc.id)
                .update({
              'content': decodedContent, // 직접 저장
              'updatedAt': DateTime.now(),
            });

            messagesFixed++;
          } catch (e) {
            debugPrint('메시지 마이그레이션 오류 (${messageDoc.id}): $e');
          }
        }
      }

      // ✅ 캐시 무효화
      _invalidateConversationCache();
      _invalidateMessageCache(conversationId);

      debugPrint('Base64 → 직접 저장 마이그레이션 완료 - 대화: $conversationId, 메시지: $messagesFixed개');

      return {
        'conversationId': conversationId,
        'fieldsFixed': fieldsFixed,
        'messagesFixed': messagesFixed,
        'totalFixed': fieldsFixed + messagesFixed,
      };
    } catch (e) {
      debugPrint('마이그레이션 오류: $e');
      throw Exception('데이터 마이그레이션을 수행할 수 없습니다: $e');
    }
  }

  /// 모든 대화 정보 마이그레이션
  Future<Map<String, dynamic>> fixAllConversationsEncodings() async {
    try {
      final userId = _authService.getCurrentUserId();
      if (userId == null) {
        throw Exception('사용자가 로그인되어 있지 않습니다.');
      }

      // 모든 대화 가져오기
      final conversationsSnapshot = await _firestore
          .collection('conversations')
          .where('user_id', isEqualTo: userId)
          .get();

      int totalConversations = conversationsSnapshot.docs.length;
      int fixedConversations = 0;
      int totalFieldsFixed = 0;
      int totalMessagesFixed = 0;
      List<String> failedConversations = [];

      debugPrint('Base64 → 직접 저장 마이그레이션 시작: $totalConversations개 대화');

      for (final doc in conversationsSnapshot.docs) {
        try {
          final result = await fixConversationEncodings(doc.id);

          totalFieldsFixed += (result['fieldsFixed'] as num).toInt();
          totalMessagesFixed += (result['messagesFixed'] as num).toInt();

          if (result['totalFixed'] > 0) {
            fixedConversations++;
          }
        } catch (e) {
          debugPrint('대화 마이그레이션 실패 (${doc.id}): $e');
          failedConversations.add(doc.id);
        }
      }

      return {
        'totalConversations': totalConversations,
        'fixedConversations': fixedConversations,
        'totalFieldsFixed': totalFieldsFixed,
        'totalMessagesFixed': totalMessagesFixed,
        'totalFixed': totalFieldsFixed + totalMessagesFixed,
        'failedConversations': failedConversations,
      };
    } catch (e) {
      debugPrint('전체 마이그레이션 오류: $e');
      throw Exception('모든 대화의 마이그레이션을 수행할 수 없습니다: $e');
    }
  }
}
