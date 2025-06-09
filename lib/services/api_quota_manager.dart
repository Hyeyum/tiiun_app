// lib/services/api_quota_manager.dart
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiQuotaManager {
  static const String _ttsCallsKey = 'tts_calls_today';
  static const String _chatCallsKey = 'chat_calls_today';
  static const String _lastResetKey = 'quota_last_reset';

  // 일일 한도 설정
  static const int maxTtsCallsPerDay = 50;      // TTS 하루 50회
  static const int maxChatCallsPerDay = 100;    // Chat 하루 100회
  static const int maxCallsPerMinute = 5;       // 분당 5회

  static final Map<String, List<DateTime>> _recentCalls = {};
  static bool _quotaExceeded = false;
  static DateTime? _quotaResetTime;

  // 할당량 확인
  static Future<bool> canMakeTtsCall() async {
    await _checkDailyReset();

    if (_quotaExceeded && _quotaResetTime != null) {
      if (DateTime.now().isBefore(_quotaResetTime!)) {
        return false;
      } else {
        _quotaExceeded = false;
      }
    }

    final prefs = await SharedPreferences.getInstance();
    final todayCalls = prefs.getInt(_ttsCallsKey) ?? 0;

    return todayCalls < maxTtsCallsPerDay && _canMakeCallThisMinute('tts');
  }

  static Future<bool> canMakeChatCall() async {
    await _checkDailyReset();

    if (_quotaExceeded && _quotaResetTime != null) {
      if (DateTime.now().isBefore(_quotaResetTime!)) {
        return false;
      } else {
        _quotaExceeded = false;
      }
    }

    final prefs = await SharedPreferences.getInstance();
    final todayCalls = prefs.getInt(_chatCallsKey) ?? 0;

    return todayCalls < maxChatCallsPerDay && _canMakeCallThisMinute('chat');
  }

  // 호출 기록
  static Future<void> recordTtsCall() async {
    final prefs = await SharedPreferences.getInstance();
    final todayCalls = prefs.getInt(_ttsCallsKey) ?? 0;
    await prefs.setInt(_ttsCallsKey, todayCalls + 1);
    _recordMinuteCall('tts');
  }

  static Future<void> recordChatCall() async {
    final prefs = await SharedPreferences.getInstance();
    final todayCalls = prefs.getInt(_chatCallsKey) ?? 0;
    await prefs.setInt(_chatCallsKey, todayCalls + 1);
    _recordMinuteCall('chat');
  }

  // 할당량 초과 처리
  static void handleQuotaExceeded({Duration? retryAfter}) {
    _quotaExceeded = true;
    _quotaResetTime = DateTime.now().add(retryAfter ?? Duration(hours: 1));
    debugPrint('API quota exceeded. Retry after: $_quotaResetTime');
  }

  // 남은 할당량 확인
  static Future<Map<String, int>> getRemainingQuota() async {
    await _checkDailyReset();
    final prefs = await SharedPreferences.getInstance();

    final ttsUsed = prefs.getInt(_ttsCallsKey) ?? 0;
    final chatUsed = prefs.getInt(_chatCallsKey) ?? 0;

    return {
      'tts_remaining': maxTtsCallsPerDay - ttsUsed,
      'chat_remaining': maxChatCallsPerDay - chatUsed,
      'tts_used': ttsUsed,
      'chat_used': chatUsed,
    };
  }

  // 일일 리셋 확인
  static Future<void> _checkDailyReset() async {
    final prefs = await SharedPreferences.getInstance();
    final lastReset = prefs.getString(_lastResetKey);
    final today = DateTime.now().toIso8601String().substring(0, 10);

    if (lastReset != today) {
      await prefs.setInt(_ttsCallsKey, 0);
      await prefs.setInt(_chatCallsKey, 0);
      await prefs.setString(_lastResetKey, today);
    }
  }

  // 분당 호출 제한 확인
  static bool _canMakeCallThisMinute(String type) {
    final now = DateTime.now();
    final key = '${type}_minute';

    _recentCalls[key] ??= [];

    // 1분 이전 호출 제거
    _recentCalls[key]!.removeWhere(
            (time) => now.difference(time).inMinutes >= 1
    );

    return _recentCalls[key]!.length < maxCallsPerMinute;
  }

  // 분당 호출 기록
  static void _recordMinuteCall(String type) {
    final key = '${type}_minute';
    _recentCalls[key] ??= [];
    _recentCalls[key]!.add(DateTime.now());
  }
}
