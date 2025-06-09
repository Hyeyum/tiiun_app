// lib/utils/encoding_utils.dart - 최적화 버전
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';

/// 인코딩 유틸리티 클래스 - Base64 의존성 제거 및 성능 최적화
class EncodingUtils {
  // ✅ Base64 패턴 캐시 (성능 최적화)
  static final RegExp _base64Pattern = RegExp(r'^[A-Za-z0-9+/]*={0,2}$');

  // ✅ 이미 체크한 문자열 캐시 (중복 체크 방지)
  static final Map<String, bool> _base64CheckCache = <String, bool>{};
  static const int _maxCacheSize = 1000; // 캐시 크기 제한

  /// ✅ Base64 인코딩 (호환성을 위해 유지하지만 사용 권장하지 않음)
  @Deprecated('Use direct UTF-8 storage instead')
  static String encodeToBase64(String input) {
    if (input.isEmpty) return '';

    try {
      final bytes = utf8.encode(input);
      return base64Encode(bytes);
    } catch (e) {
      debugPrint('Base64 인코딩 실패: $e');
      return input; // 실패 시 원본 반환
    }
  }

  /// ✅ Base64 디코딩 (기존 데이터 호환성을 위해 유지)
  static String decodeFromBase64(String encoded) {
    if (encoded.isEmpty) return '';

    try {
      final bytes = base64Decode(encoded);
      return utf8.decode(bytes);
    } catch (e) {
      debugPrint('Base64 디코딩 실패: $e');
      return encoded; // 실패 시 원본 반환
    }
  }

  /// ✅ 최적화된 Base64 체크 (캐싱 적용)
  static bool isBase64Encoded(String input) {
    if (input.isEmpty) return false;

    // 캐시에서 확인
    if (_base64CheckCache.containsKey(input)) {
      return _base64CheckCache[input]!;
    }

    // 캐시 크기 관리
    if (_base64CheckCache.length >= _maxCacheSize) {
      _base64CheckCache.clear();
    }

    bool result = _checkBase64Format(input);
    _base64CheckCache[input] = result;

    return result;
  }

  /// ✅ 실제 Base64 형식 체크 로직
  static bool _checkBase64Format(String input) {
    // 길이 체크 (Base64는 4의 배수)
    if (input.length % 4 != 0) return false;

    // 패턴 체크
    if (!_base64Pattern.hasMatch(input)) return false;

    // 실제 디코딩 시도 (가장 확실한 방법)
    try {
      base64Decode(input);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// ✅ 손상된 텍스트 체크 (성능 최적화)
  static bool isCorruptedText(String input) {
    if (input.isEmpty) return false;

    // 일반적인 손상 패턴들 체크
    const corruptedPatterns = [
      '�', // 유니코드 대체 문자
      '\uFFFD', // 대체 문자
      'Ã', // UTF-8 인코딩 문제
      '½', // 인코딩 문제
    ];

    for (final pattern in corruptedPatterns) {
      if (input.contains(pattern)) return true;
    }

    // 비정상적인 제어 문자 체크
    final runes = input.runes;
    int controlCharCount = 0;
    for (final rune in runes) {
      if (rune < 32 && rune != 9 && rune != 10 && rune != 13) {
        controlCharCount++;
        if (controlCharCount > 2) return true; // 제어 문자가 너무 많으면 손상된 것으로 판단
      }
    }

    return false;
  }

  /// ✅ 모든 복구 방법 시도 (기존 Base64 데이터 마이그레이션용)
  static String tryAllFixMethods(String input) {
    if (input.isEmpty) return input;

    // 1. 이미 정상적인 텍스트인 경우
    if (!isBase64Encoded(input) && !isCorruptedText(input)) {
      return input;
    }

    // 2. Base64 디코딩 시도
    if (isBase64Encoded(input)) {
      try {
        final decoded = decodeFromBase64(input);
        if (!isCorruptedText(decoded)) {
          return decoded;
        }
      } catch (e) {
        debugPrint('Base64 디코딩 실패: $e');
      }
    }

    // 3. 다양한 인코딩 복구 시도
    final fixedText = _tryMultipleEncodingFixes(input);
    if (fixedText != input && !isCorruptedText(fixedText)) {
      return fixedText;
    }

    // 4. 모든 방법 실패 시 원본 반환
    return input;
  }

  /// ✅ 다중 인코딩 복구 시도
  static String _tryMultipleEncodingFixes(String input) {
    final fixMethods = [
      _fixDoubleUtf8Encoding,
      _fixLatin1ToUtf8,
      _fixWindowsEncoding,
      _removeControlCharacters,
    ];

    for (final method in fixMethods) {
      try {
        final result = method(input);
        if (result != input && !isCorruptedText(result)) {
          return result;
        }
      } catch (e) {
        debugPrint('인코딩 복구 실패: $e');
        continue;
      }
    }

    return input;
  }

  /// ✅ 이중 UTF-8 인코딩 복구
  static String _fixDoubleUtf8Encoding(String input) {
    try {
      // UTF-8 → Latin-1 → UTF-8 변환으로 이중 인코딩 복구
      final latin1Bytes = latin1.encode(input);
      return utf8.decode(latin1Bytes);
    } catch (e) {
      return input;
    }
  }

  /// ✅ Latin-1 → UTF-8 변환
  static String _fixLatin1ToUtf8(String input) {
    try {
      final utf8Bytes = utf8.encode(input);
      return utf8.decode(utf8Bytes);
    } catch (e) {
      return input;
    }
  }

  /// ✅ Windows 인코딩 문제 복구
  static String _fixWindowsEncoding(String input) {
    // Windows-1252 → UTF-8 변환 시도
    const windowsToUtf8 = {
      'â€™': "'", // 아포스트로피
      'â€œ': '"', // 열린 따옴표
      'â€': '"',  // 닫힌 따옴표
      'â€"': '–', // en dash
      'Ã©': 'é',  // e acute
      'Ã¡': 'á',  // a acute
      'Ã³': 'ó',  // o acute
    };

    String result = input;
    windowsToUtf8.forEach((wrong, correct) {
      result = result.replaceAll(wrong, correct);
    });

    return result;
  }

  /// ✅ 제어 문자 제거
  static String _removeControlCharacters(String input) {
    // 유니코드 제어 문자 제거 (탭, 줄바꿈, 캐리지 리턴 제외)
    return input.replaceAll(RegExp(r'[\x00-\x08\x0B\x0C\x0E-\x1F\x7F]'), '');
  }

  /// ✅ 텍스트 정규화 (권장 방법)
  static String normalizeText(String input) {
    if (input.isEmpty) return input;

    // 1. 기본 정리
    String result = input.trim();

    // 2. 연속된 공백 정리
    result = result.replaceAll(RegExp(r'\s+'), ' ');

    // 3. 특수 공백 문자들을 일반 공백으로 변환
    result = result.replaceAll(RegExp(r'[\u00A0\u2000-\u200B\u2028\u2029]'), ' ');

    // 4. 제어 문자 제거 (탭, 줄바꿈 제외)
    result = _removeControlCharacters(result);

    return result;
  }

  /// ✅ 안전한 텍스트 저장 준비
  static String prepareForStorage(String input) {
    // Base64 인코딩 대신 정규화만 수행
    return normalizeText(input);
  }

  /// ✅ 안전한 텍스트 로드
  static String prepareFromStorage(String stored) {
    if (stored.isEmpty) return stored;

    // 기존 Base64 데이터 호환성 체크
    if (isBase64Encoded(stored)) {
      return tryAllFixMethods(stored);
    }

    // 이미 정상적인 텍스트면 그대로 반환
    return stored;
  }

  /// ✅ 마이그레이션 헬퍼 - Base64 → 직접 저장
  static Map<String, String> migrateBase64Fields(Map<String, dynamic> data, List<String> fieldNames) {
    final migrations = <String, String>{};

    for (final fieldName in fieldNames) {
      final value = data[fieldName];
      if (value is String && value.isNotEmpty && isBase64Encoded(value)) {
        try {
          final decoded = decodeFromBase64(value);
          migrations[fieldName] = decoded;
        } catch (e) {
          debugPrint('필드 $fieldName 마이그레이션 실패: $e');
        }
      }
    }

    return migrations;
  }

  /// ✅ 성능 통계
  static Map<String, int> getPerformanceStats() {
    return {
      'base64_cache_size': _base64CheckCache.length,
      'cache_max_size': _maxCacheSize,
    };
  }

  /// ✅ 캐시 정리
  static void clearCache() {
    _base64CheckCache.clear();
  }

  /// ✅ 텍스트 크기 비교 (Base64 vs 직접 저장)
  static Map<String, int> compareSizes(String text) {
    final directSize = utf8.encode(text).length;
    final base64Size = utf8.encode(encodeToBase64(text)).length;
    final savings = base64Size - directSize;
    final savingsPercent = ((savings / base64Size) * 100).round();

    return {
      'direct_bytes': directSize,
      'base64_bytes': base64Size,
      'savings_bytes': savings,
      'savings_percent': savingsPercent,
    };
  }
}

/// ✅ 텍스트 품질 분석기
class TextQualityAnalyzer {
  /// 텍스트 품질 점수 계산 (0-100)
  static int calculateQualityScore(String text) {
    if (text.isEmpty) return 0;

    int score = 100;

    // 1. Base64 인코딩 감점 (-30점)
    if (EncodingUtils.isBase64Encoded(text)) {
      score -= 30;
    }

    // 2. 손상된 텍스트 감점 (-50점)
    if (EncodingUtils.isCorruptedText(text)) {
      score -= 50;
    }

    // 3. 제어 문자 감점 (-10점)
    final controlCharCount = text.runes.where((rune) =>
    rune < 32 && rune != 9 && rune != 10 && rune != 13).length;
    if (controlCharCount > 0) {
      score -= 10;
    }

    // 4. 과도한 공백 감점 (-5점)
    if (text.contains(RegExp(r'\s{3,}'))) {
      score -= 5;
    }

    return score.clamp(0, 100);
  }

  /// 텍스트 품질 보고서
  static Map<String, dynamic> analyzeText(String text) {
    return {
      'quality_score': calculateQualityScore(text),
      'is_base64': EncodingUtils.isBase64Encoded(text),
      'is_corrupted': EncodingUtils.isCorruptedText(text),
      'size_comparison': EncodingUtils.compareSizes(text),
      'character_count': text.length,
      'byte_count': utf8.encode(text).length,
    };
  }
}
