import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'encoding_utils.dart';

// 인코딩 문제 진단용 메서드
void debugEncoding() {
  // 테스트용 한글 텍스트
  const testKorean = "안녕하세요";

  // Dart UTF-8 기본 인코딩/디코딩 테스트
  final bytes1 = utf8.encode(testKorean);
  final decoded1 = utf8.decode(bytes1);
  debugPrint('=== 기본 UTF-8 테스트 ===');
  debugPrint('원본: $testKorean');
  debugPrint('UTF-8 바이트: $bytes1');
  debugPrint('디코딩 결과: $decoded1');
  debugPrint('원본과 일치: ${testKorean == decoded1}');

  // Base64 인코딩/디코딩 테스트
  final base64Str = base64.encode(bytes1);
  debugPrint('=== Base64 테스트 ===');
  debugPrint('Base64 인코딩: $base64Str');

  try {
    final decodedBytes = base64.decode(base64Str);
    final decoded2 = utf8.decode(decodedBytes);
    debugPrint('Base64 디코딩 결과: $decoded2');
    debugPrint('원본과 일치: ${testKorean == decoded2}');
  } catch (e) {
    debugPrint('Base64 디코딩 오류: $e');
  }

  // isBase64Encoded 테스트
  debugPrint('=== isBase64Encoded 테스트 ===');
  debugPrint('Base64 문자열 확인: ${EncodingUtils.isBase64Encoded(base64Str)}');
  debugPrint('일반 문자열 확인: ${EncodingUtils.isBase64Encoded(testKorean)}');

  // encodeToBase64 메서드 테스트
  debugPrint('=== encodeToBase64 테스트 ===');
  final encoded = EncodingUtils.encodeToBase64(testKorean);
  debugPrint('encodeToBase64 결과: $encoded');
  debugPrint('Base64 인코딩 맞는지: ${EncodingUtils.isBase64Encoded(encoded)}');

  // decodeFromBase64 메서드 테스트
  debugPrint('=== decodeFromBase64 테스트 ===');
  final decoded = EncodingUtils.decodeFromBase64(encoded);
  debugPrint('decodeFromBase64 결과: $decoded');
  debugPrint('원본과 일치: ${testKorean == decoded}');

}