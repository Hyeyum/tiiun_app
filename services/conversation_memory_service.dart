// lib/services/conversation_memory_service.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:langchain/langchain.dart';
import '../models/conversation_model.dart' as app_models;
import '../models/message_model.dart' as app_message; // Message 모델 import with prefix

// 대화 메모리 서비스 Provider
final conversationMemoryServiceProvider = Provider<ConversationMemoryService>((ref) {
  return ConversationMemoryService();
});

class ConversationMemoryService {
  // 대화 ID에 대한 메모리 맵
  final Map<String, ConversationBufferMemory> _memories = {};

  // 대화에 대한 메모리 가져오기 또는 생성
  ConversationBufferMemory getOrCreateMemoryForConversation(String conversationId) {
    if (!_memories.containsKey(conversationId)) {
      _memories[conversationId] = ConversationBufferMemory(
        returnMessages: true,
        inputKey: 'input',
        outputKey: 'output',
        memoryKey: 'chat_history',
      );
    }

    return _memories[conversationId]!;
  }

  // 대화 기록을 메모리에 추가
  Future<void> addMessagePairToMemory(
    String conversationId,
    String userMessage,
    String aiResponse,
  ) async {
    final memory = getOrCreateMemoryForConversation(conversationId);

    // userMessage와 aiResponse는 LangChain 서비스에서 전달받은 디코딩된 일반 텍스트이므로
    // 메모리에 추가할 때 추가적인 인코딩/디코딩은 불필요.
    await memory.saveContext(
      inputValues: {'input': userMessage},
      outputValues: {'output': aiResponse},
    );
  }

  // 메시지 모델을 LangChain 메모리로 변환
  Future<void> loadMessagesIntoMemory(
    String conversationId,
    List<app_message.Message> messages,
  ) async {
    // 메모리 초기화
    if (_memories.containsKey(conversationId)) {
      _memories.remove(conversationId);
    }

    final memory = getOrCreateMemoryForConversation(conversationId);

    // messages[i].content는 이미 Message 모델에서 디코딩된 상태
    // 메시지를 순서대로 쌍으로 처리 (사용자 메시지, AI 응답)
    for (int i = 0; i < messages.length - 1; i++) {
      if (messages[i].sender == app_message.MessageSender.user &&
          messages[i + 1].sender == app_message.MessageSender.agent) {
        await memory.saveContext(
          inputValues: {'input': messages[i].content},
          outputValues: {'output': messages[i + 1].content},
        );
        i++; // AI 응답은 이미 처리했으므로 다음 쌍으로 이동
      }
    }
  }

  // 대화 기록 가져오기
  Future<List<ChatMessage>> getMemoryMessages(String conversationId) async {
    final memory = getOrCreateMemoryForConversation(conversationId);
    final memoryVariables = await memory.loadMemoryVariables({});

    if (memoryVariables.containsKey('chat_history')) {
      // 반환되는 ChatMessage 객체의 content는 일반 텍스트.
      return memoryVariables['chat_history'] as List<ChatMessage>;
    }

    return [];
  }

  // 대화 메모리 초기화
  void clearMemory(String conversationId) {
    if (_memories.containsKey(conversationId)) {
      _memories.remove(conversationId);
    }
  }

  // 모든 대화 메모리 초기화
  void clearAllMemories() {
    _memories.clear();
  }
}