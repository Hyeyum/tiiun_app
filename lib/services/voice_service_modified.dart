import 'dart:io';
import 'dart:async';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:path/path.dart' as path;
import 'package:uuid/uuid.dart';
import 'package:just_audio/just_audio.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart' as record_pkg;
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/foundation.dart';

import 'firebase_service.dart'; // FirebaseService로 변경
import '../utils/simple_speech_recognizer.dart';
import '../utils/encoding_utils.dart';
import 'whisper_service.dart';
import 'openai_tts_service.dart';
import 'voice_service.dart';
import 'package:tiiun/services/remote_config_service.dart'; // Import RemoteConfigService

// 성능 최적화된 음성 서비스 구현
// 이 클래스는 기존 VoiceService에 추가 최적화 기능을 포함합니다
final voiceServiceModifiedProvider = Provider<VoiceServiceModified>((ref) {
  final firebaseService = FirebaseService(); // FirebaseService 직접 생성
  final remoteConfigService = ref.watch(remoteConfigServiceProvider);
  final openAIapiKey = remoteConfigService.getOpenAIApiKey();
  if (openAIapiKey.isEmpty) {
    debugPrint('OPENAI_API_KEY is not set. OpenAI features will be limited.');
  }
  return VoiceServiceModified(firebaseService, openAIapiKey);
});

class VoiceServiceModified extends VoiceService {
  // 기본 생성자는 부모 클래스의 생성자 호출
  VoiceServiceModified(FirebaseService? firebaseService, String openAIapiKey) // FirebaseService로 변경
      : super(firebaseService, openAIapiKey) { // 부모 클래스 생성자 호출
    debugPrint('VoiceServiceModified: 초기화 완료');
  }

  // 비어있는 서비스 생성자
  factory VoiceServiceModified.empty() {
    const String apiKey = String.fromEnvironment('OPENAI_API_KEY', defaultValue: '');
    return VoiceServiceModified(null, apiKey);
  }

  // 캐싱 관련 변수들
  final Map<String, String> _ttsCache = {};
  final Map<String, DateTime> _ttsCacheTimestamps = {};
  static const Duration _cacheDuration = Duration(hours: 1);

  // 캐시 정리 메서드
  void _cleanupCache() {
    final now = DateTime.now();
    final keysToRemove = <String>[];

    _ttsCacheTimestamps.forEach((key, timestamp) {
      if (now.difference(timestamp) > _cacheDuration) {
        keysToRemove.add(key);
      }
    });

    for (final key in keysToRemove) {
      _ttsCache.remove(key);
      _ttsCacheTimestamps.remove(key);
    }

    debugPrint('VoiceServiceModified: ${keysToRemove.length}개의 캐시 항목 정리됨');
  }

  // 오버라이드: TTS 생성 메서드에 캐싱 기능 추가
  @override
  Future<Map<String, dynamic>> textToSpeechFile(String text, [String? voiceId]) async {
    // 캐시 키 생성 (텍스트 + 음성 ID)
    final cacheKey = '$text-${voiceId ?? "default"}';

    // 주기적으로 캐시 정리
    _cleanupCache();

    // 캐시에서 URL 확인
    if (_ttsCache.containsKey(cacheKey)) {
      debugPrint('VoiceServiceModified: TTS 캐시 사용 - $cacheKey');

      // 캐시 타임스탬프 업데이트
      _ttsCacheTimestamps[cacheKey] = DateTime.now();

      // 캐시된 URL 반환
      return {
        'url': _ttsCache[cacheKey]!,
        'duration': text.length / 15.0, // 약 15자당 1초로 예상
        'source': 'cache',
        'error': null,
      };
    }

    // 캐시에 없으면 부모 클래스의 메서드 호출
    final result = await super.textToSpeechFile(text, voiceId);

    // 성공적으로 생성된 경우 캐시에 저장
    if (result['url'] != null && result['url'].isNotEmpty) {
      _ttsCache[cacheKey] = result['url'];
      _ttsCacheTimestamps[cacheKey] = DateTime.now();
      debugPrint('VoiceServiceModified: TTS 결과 캐싱 - $cacheKey');
    }

    return result;
  }

  // 오버라이드: 음성 재생 메서드 최적화
  @override
  Future<void> playAudio(String url, {Function? onComplete, bool isLocalFile = false}) async {
    // 재생 중이지만 같은 URL이면 무시
    if (isPlaying && currentPlayingUrl == url) {
      debugPrint('VoiceServiceModified: 이미 같은 오디오 재생 중');
      return;
    }

    // 부모 클래스 메서드 호출
    await super.playAudio(url, onComplete: onComplete, isLocalFile: isLocalFile);
  }

  // 추가: 현재 재생 중인 URL 가져오기
  @override
  String? get currentPlayingUrl => super.currentPlayingUrl;

  // 추가: 현재 재생 중인지 확인
  @override
  bool get isPlaying => super.isPlaying;

  // 추가: 캐시된 항목 수 반환
  int get cacheSize => _ttsCache.length;

  // 캐시 강제 정리
  void clearCache() {
    _ttsCache.clear();
    _ttsCacheTimestamps.clear();
    debugPrint('VoiceServiceModified: 모든 캐시 정리됨');
  }

  // 캐시 상태 확인
  Map<String, dynamic> getCacheStatus() {
    return {
      'cacheSize': _ttsCache.length,
      'oldestEntry': _ttsCacheTimestamps.values.isNotEmpty
          ? _ttsCacheTimestamps.values.reduce((a, b) => a.isBefore(b) ? a : b).toString()
          : null,
      'newestEntry': _ttsCacheTimestamps.values.isNotEmpty
          ? _ttsCacheTimestamps.values.reduce((a, b) => a.isAfter(b) ? a : b).toString()
          : null,
    };
  }

  // 특정 캐시 항목 제거
  bool removeCacheEntry(String text, [String? voiceId]) {
    final cacheKey = '$text-${voiceId ?? "default"}';
    final removed = _ttsCache.remove(cacheKey) != null;
    _ttsCacheTimestamps.remove(cacheKey);

    if (removed) {
      debugPrint('VoiceServiceModified: 캐시 항목 제거됨 - $cacheKey');
    }

    return removed;
  }

  // dispose 오버라이드 (캐시 정리 포함)
  @override
  void dispose() {
    clearCache();
    super.dispose();
    debugPrint('VoiceServiceModified: 리소스 정리 완료');
  }
}