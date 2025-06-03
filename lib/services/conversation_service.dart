// lib/services/conversation_service.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import '../models/conversation_model.dart';
import '../models/message_model.dart'; // MessageModel import
import 'firebase_service.dart'; // FirebaseService import로 변경
import '../utils/encoding_utils.dart'; // Ensure EncodingUtils is available
import '../utils/error_handler.dart'; // ✅ ErrorHandler import 추가

// 디버깅 로그 활성화 (개발 중에만 사용)
const bool _enableDebugLog = true;

// 대화 서비스 Provider
final conversationServiceProvider = Provider<ConversationService>((ref) {
  return ConversationService(FirebaseFirestore.instance, FirebaseService()); // 직접 인스턴스 생성
});

// 사용자 대화 목록 Provider
final userConversationsProvider = StreamProvider<List<ConversationModel>>((ref) { // ConversationModel로 변경
  final conversationService = ref.watch(conversationServiceProvider);
  return conversationService.getConversations();
});

class ConversationService {
  final FirebaseFirestore _firestore;
  final FirebaseService _firebaseService; // FirebaseService로 변경

  ConversationService(this._firestore, this._firebaseService);

  // 대화 목록 가져오기 (Stream) - 스키마에 맞게 수정
  Stream<List<ConversationModel>> getConversations() { // ConversationModel로 변경
    final userId = _firebaseService.currentUserId; // FirebaseService 메서드 사용
    if (userId == null) {
      return Stream.value([]);
    }

    return _firestore
        .collection('conversations')
        .where('user_id', isEqualTo: userId) // user_id로 수정
        .orderBy('updated_at', descending: true) // updated_at으로 수정
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        // ConversationModel.fromFirestore 사용
        return ConversationModel.fromFirestore(doc.data(), doc.id);
      }).toList();
    });
  }

  // 대화 목록 가져오기 (Future) - 스키마에 맞게 수정
  Future<List<ConversationModel>> getUserConversations() async { // ConversationModel로 변경
    final userId = _firebaseService.currentUserId; // FirebaseService 메서드 사용
    if (userId == null) {
      return [];
    }

    try {
      final snapshot = await _firestore
          .collection('conversations')
          .where('user_id', isEqualTo: userId) // user_id로 수정
          .orderBy('updated_at', descending: true) // updated_at으로 수정
          .get();

      return snapshot.docs.map((doc) {
        // ConversationModel.fromFirestore 사용
        return ConversationModel.fromFirestore(doc.data(), doc.id);
      }).toList();
    } catch (e) {
      debugPrint('대화 목록 가져오기 오류: $e');
      return [];
    }
  }

  // 대화 가져오기
  Future<ConversationModel?> getConversation(String conversationId) async { // ConversationModel로 변경
    try {
      final doc = await _firestore
          .collection('conversations')
          .doc(conversationId)
          .get();

      if (!doc.exists) {
        return null;
      }

      // ConversationModel.fromFirestore 사용
      return ConversationModel.fromFirestore(doc.data()!, doc.id);
    } catch (e) {
      debugPrint('대화 가져오기 실패: $e');
      return null;
    }
  }

  // 새 대화 생성 및 대화 ID 확인 로직 추가
  Future<ConversationModel> createConversation({ // ConversationModel로 변경
    String? plantId, // plant_id만 유지 (실제 ConversationModel에 있는 필드)
  }) async {
    try {
      final userId = _firebaseService.currentUserId; // FirebaseService 메서드 사용
      if (userId == null) {
        throw Exception('사용자가 로그인되어 있지 않습니다.');
      }

      // ConversationModel.create 사용
      final newConversation = ConversationModel.create(
        userId: userId,
        plantId: plantId,
      );

      // Firestore에 저장
      final docRef = await _firestore
          .collection('conversations')
          .add(newConversation.toFirestore());

      // 생성된 대화의 ID를 업데이트하고 반환
      return newConversation.copyWith(conversationId: docRef.id);
    } catch (e) {
      debugPrint('대화 생성 오류: $e');
      throw Exception('대화를 생성할 수 없습니다: $e');
    }
  }

  // 대화에 메시지 추가 (MessageModel 사용)
  Future<MessageModel> addMessage({ // MessageModel로 변경
    required String conversationId,
    required String content,
    required String sender, // String으로 변경 ('user' 또는 'ai')
    String type = 'text',
  }) async {
    try {
      final userId = _firebaseService.currentUserId; // FirebaseService 메서드 사용
      if (userId == null) {
        throw Exception('사용자가 로그인되어 있지 않습니다.');
      }

      // MessageModel.create 사용
      final newMessage = MessageModel.create(
        conversationId: conversationId,
        content: content,
        sender: sender,
        type: type,
      );

      // Firestore에 새 메시지 추가
      final messageRef = await _firestore
          .collection('messages')
          .add(newMessage.toFirestore());

      // 대화 정보 업데이트 (스키마에 맞게 수정)
      await _firestore
          .collection('conversations')
          .doc(conversationId)
          .update({
        'updated_at': Timestamp.fromDate(DateTime.now()),
        'last_message_id': messageRef.id,
        'message_count': FieldValue.increment(1),
      });

      // 메시지 객체 반환
      return newMessage.copyWith(messageId: messageRef.id);
    } catch (e) {
      debugPrint('메시지 추가 오류: $e');
      throw Exception('메시지를 추가할 수 없습니다: $e');
    }
  }

  // 대화의 메시지 목록 가져오기 - MessageModel 사용
  Stream<List<MessageModel>> getConversationMessages(String conversationId) { // MessageModel로 변경
    // ✅ conversationId 유효성 검사
    if (conversationId.isEmpty) {
      return Stream.error('Invalid conversation ID');
    }

    return _firestore
        .collection('messages')
        .where('conversation_id', isEqualTo: conversationId)
        .orderBy('created_at')
        .snapshots()
        .map((snapshot) {
      if (_enableDebugLog) {
        debugPrint('---------- 메시지 로드 시작 ----------');
        debugPrint('메시지 갯수: ${snapshot.docs.length}');
      }

      final messages = <MessageModel>[];

      for (final doc in snapshot.docs) {
        try {
          // MessageModel.fromFirestore 사용
          final message = MessageModel.fromFirestore(doc.data(), doc.id);
          messages.add(message);
        } catch (e) {
          debugPrint('메시지 변환 오류: $e, documentId: ${doc.id}');
          // ✅ 오류 발생한 메시지는 스킵하고 계속 진행
          continue;
        }
      }

      return messages;
    })
        .handleError((error) {
      debugPrint('메시지 스트림 오류: $error');
      throw ErrorHandler.handleException(error);
    });
  }

  // 대화 요약 업데이트 (ConversationModel의 실제 필드만 사용)
  Future<void> updateConversationSummary(String conversationId, String summary) async {
    try {
      await _firestore
          .collection('conversations')
          .doc(conversationId)
          .update({
        'summary': summary, // ConversationModel에 있는 summary 필드 사용
        'updated_at': Timestamp.fromDate(DateTime.now()),
      });
    } catch (e) {
      debugPrint('대화 요약 업데이트 오류: $e');
      throw Exception('대화 요약을 업데이트할 수 없습니다: $e');
    }
  }

  // 대화 삭제
  Future<void> deleteConversation(String conversationId) async {
    try {
      // 대화 문서 삭제
      await _firestore
          .collection('conversations')
          .doc(conversationId)
          .delete();

      // 관련 메시지 삭제
      final messagesSnapshot = await _firestore
          .collection('messages')
          .where('conversation_id', isEqualTo: conversationId)
          .get();

      final batch = _firestore.batch();
      for (final doc in messagesSnapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
    } catch (e) {
      debugPrint('대화 삭제 오류: $e');
      throw Exception('대화를 삭제할 수 없습니다: $e');
    }
  }

  // 여러 대화 삭제
  Future<void> deleteMultipleConversations(List<String> conversationIds) async {
    if (conversationIds.isEmpty) return;

    try {
      final userId = _firebaseService.currentUserId; // FirebaseService 메서드 사용
      if (userId == null) {
        throw Exception('사용자가 로그인되어 있지 않습니다.');
      }

      // Firestore 배치 처리를 위한 준비
      int batchCount = 0;
      WriteBatch batch = _firestore.batch();

      // 각 대화 ID에 대해 처리
      for (final conversationId in conversationIds) {
        // 대화 문서 참조
        final conversationRef = _firestore.collection('conversations').doc(conversationId);

        // 대화 문서 삭제 작업 추가
        batch.delete(conversationRef);
        batchCount++;

        // 관련 메시지 검색
        final messagesSnapshot = await _firestore
            .collection('messages')
            .where('conversation_id', isEqualTo: conversationId)
            .get();

        // 각 메시지 삭제 작업 추가
        for (final messageDoc in messagesSnapshot.docs) {
          batch.delete(messageDoc.reference);
          batchCount++;

          // Firestore 배치 작업은 500개로 제한되어 있으므로 400개마다 배치 실행 후 새로운 배치 생성
          if (batchCount >= 400) {
            await batch.commit();
            batch = _firestore.batch();
            batchCount = 0;
          }
        }
      }

      // 남은 배치 작업 실행
      if (batchCount > 0) {
        await batch.commit();
      }

      debugPrint('${conversationIds.length}개의 대화가 삭제되었습니다.');
    } catch (e) {
      debugPrint('여러 대화 삭제 오류: $e');
      throw Exception('대화를 삭제할 수 없습니다: $e');
    }
  }

  // 메시지 읽음 상태 업데이트
  Future<void> markMessagesAsRead(String conversationId) async {
    try {
      final userId = _firebaseService.currentUserId; // FirebaseService 메서드 사용
      if (userId == null) {
        throw Exception('사용자가 로그인되어 있지 않습니다.');
      }

      // 읽지 않은 AI 메시지 조회 (sender가 'ai'인 메시지)
      final messagesSnapshot = await _firestore
          .collection('messages')
          .where('conversation_id', isEqualTo: conversationId)
          .where('sender', isEqualTo: 'ai') // AI 메시지만
          .get();

      if (messagesSnapshot.docs.isEmpty) {
        return; // 읽지 않은 메시지가 없음
      }

      // 메시지 읽음 상태 일괄 업데이트 (MessageModel에 isRead 필드가 있다면)
      final batch = _firestore.batch();
      for (final doc in messagesSnapshot.docs) {
        // MessageModel에 읽음 상태 필드가 있다면 업데이트
        // 현재 MessageModel에는 isRead 필드가 없으므로 이 부분은 제거하거나 수정 필요
        // batch.update(doc.reference, {'isRead': true});
      }

      // await batch.commit();
    } catch (e) {
      debugPrint('메시지 읽음 상태 업데이트 오류: $e');
      throw Exception('메시지 읽음 상태를 업데이트할 수 없습니다: $e');
    }
  }

  // 모든 대화 삭제
  Future<void> deleteAllConversations() async {
    try {
      final userId = _firebaseService.currentUserId; // FirebaseService 메서드 사용
      if (userId == null) {
        throw Exception('사용자가 로그인되어 있지 않습니다.');
      }

      // 사용자의 모든 대화 가져오기
      final conversationsSnapshot = await _firestore
          .collection('conversations')
          .where('user_id', isEqualTo: userId)
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
}