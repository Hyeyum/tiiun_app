// lib/services/remote_config_service.dart
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final remoteConfigServiceProvider = Provider<RemoteConfigService>((ref) {
  return RemoteConfigService();
});

class RemoteConfigService {
  final FirebaseRemoteConfig _remoteConfig = FirebaseRemoteConfig.instance;

  Future<void> initialize() async {
    try {
      await _remoteConfig.setConfigSettings(RemoteConfigSettings(
        fetchTimeout: const Duration(minutes: 1),
        minimumFetchInterval: const Duration(hours: 1),
      ));
      await _remoteConfig.setDefaults({
        'openai_api_key': '', // Set a default empty string
        // API 한도 설정
        'max_tts_calls_per_day': 50,
        'max_chat_calls_per_day': 100,
        'max_calls_per_minute': 5,
        'enable_quota_management': true,
        // 모델 설정
        'chat_model': 'gpt-4o-mini', // 비용 절감을 위해 mini 버전 사용
        'tts_model': 'tts-1', // 기본 모델로 다운그레이드
        'max_tokens_chat': 800, // 토큰 수 제한
        'max_tokens_analysis': 600,
        // 재시도 설정
        'max_retries': 2, // 재시도 횟수 감소
        'retry_delay_seconds': 3,
      });
      await _remoteConfig.fetchAndActivate();
      debugPrint('Remote Config initialized and fetched.');
    } catch (e) {
      debugPrint('Error initializing or fetching Remote Config: $e');
    }
  }

  String getOpenAIApiKey() {
    return _remoteConfig.getString('openai_api_key');
  }

  // API 한도 설정
  int getMaxTtsCallsPerDay() {
    return _remoteConfig.getInt('max_tts_calls_per_day');
  }

  int getMaxChatCallsPerDay() {
    return _remoteConfig.getInt('max_chat_calls_per_day');
  }

  int getMaxCallsPerMinute() {
    return _remoteConfig.getInt('max_calls_per_minute');
  }

  bool isQuotaManagementEnabled() {
    return _remoteConfig.getBool('enable_quota_management');
  }

  // 모델 설정
  String getChatModel() {
    return _remoteConfig.getString('chat_model');
  }

  String getTtsModel() {
    return _remoteConfig.getString('tts_model');
  }

  int getMaxTokensChat() {
    return _remoteConfig.getInt('max_tokens_chat');
  }

  int getMaxTokensAnalysis() {
    return _remoteConfig.getInt('max_tokens_analysis');
  }

  // 재시도 설정
  int getMaxRetries() {
    return _remoteConfig.getInt('max_retries');
  }

  int getRetryDelaySeconds() {
    return _remoteConfig.getInt('retry_delay_seconds');
  }
}