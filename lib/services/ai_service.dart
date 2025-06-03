// lib/services/ai_service.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/conversation_model.dart';
import '../models/message_model.dart'; // MessageModel import (app_message prefix 제거)
import 'firebase_service.dart'; // FirebaseService import
import 'voice_service.dart';
import 'conversation_service.dart';
import 'langchain_service.dart';
import 'package:flutter/foundation.dart'; // For debugPrint
import 'package:tiiun/services/remote_config_service.dart'; // Import RemoteConfigService

// AI 응답 클래스
class AIResponse {
  final String text;
  final String? voiceFileUrl;
  final double? voiceDuration;
  final String? voiceId;
  final String? ttsSource; // Added to match LangchainResponse

  AIResponse({
    required this.text,
    this.voiceFileUrl,
    this.voiceDuration,
    this.voiceId,
    this.ttsSource,
  });
}

class AiService {
  final FirebaseService _firebaseService; // AuthService 대신 FirebaseService 사용
  final ConversationService _conversationService;
  final LangchainService _langchainService;
  final RemoteConfigService _remoteConfigService; // RemoteConfigService 추가

  AiService(
      this._firebaseService, // FirebaseService로 변경
      this._conversationService,
      this._langchainService,
      this._remoteConfigService, // 생성자에 추가
      );

  // 사용자 메시지에 대한 AI 응답 생성
  // 내부적으로 LangchainService 사용
  Future<AIResponse> getResponse({
    required String conversationId,
    required String userMessage,
  }) async {
    debugPrint("AiService: Requesting response from LangchainService.");
    try {
      // LangchainService를 사용하여 응답 생성
      final langchainResponse = await _langchainService.getResponse(
        conversationId: conversationId,
        userMessage: userMessage,
      );

      // LangchainResponse를 AIResponse로 변환
      return AIResponse(
        text: langchainResponse.text,
        voiceFileUrl: langchainResponse.voiceFileUrl,
        voiceDuration: langchainResponse.voiceDuration,
        voiceId: langchainResponse.voiceId,
        ttsSource: langchainResponse.ttsSource,
      );
    } catch (e) {
      debugPrint('AiService: Error getting response from LangchainService: $e');
      throw Exception('AI 응답을 생성하는 중 오류가 발생했습니다: $e');
    }
  }

  // 대화 기록 가져오기
  Future<List<MessageModel>> _getConversationHistory(String conversationId) async {
    final messagesStream = _firebaseService.getMessages(conversationId); // FirebaseService의 getMessages 사용
    final messages = await messagesStream.first;
    if (messages.length > 10) {
      return messages.sublist(messages.length - 10);
    }
    return messages;
  }

  // 메시지를 OpenAI API 형식으로 변환
  Map<String, dynamic> _messageToJson(MessageModel msg) {
    String role;
    // MessageModel의 sender 필드는 'user' 또는 'ai'
    if (msg.sender == 'user') {
      role = 'user';
    } else if (msg.sender == 'ai') {
      role = 'assistant';
    } else {
      role = 'system';
    }
    return {
      'content': msg.content,
      'role': role,
    };
  }

  // 감정 분석 - Delegated to LangchainService
  Future<Map<String, dynamic>> analyzeSentiment(String text) async {
    try {
      return await _langchainService.analyzeSentimentWithLangChain(text);
    } catch (e) {
      debugPrint('AiService: Error analyzing sentiment via LangchainService: $e');
      throw Exception('감정 분석 중 오류가 발생했습니다: $e');
    }
  }
}

// FirebaseService Provider (만약 정의되어 있지 않다면 추가)
final firebaseServiceProvider = Provider<FirebaseService>((ref) {
  return FirebaseService();
});

// Provider for the AI service
final aiServiceProvider = Provider<AiService>((ref) {
  // FirebaseService provider 사용
  final firebaseService = ref.watch(firebaseServiceProvider);
  final conversationService = ref.watch(conversationServiceProvider);
  final langchainService = ref.watch(langchainServiceProvider);
  final remoteConfigService = ref.watch(remoteConfigServiceProvider);

  return AiService(
    firebaseService, // FirebaseService 전달
    conversationService,
    langchainService,
    remoteConfigService, // RemoteConfigService 전달
  );
});