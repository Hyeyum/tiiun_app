// lib/utils/benchmark_tool.dart - 최적화 전후 성능 비교 도구
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tiiun/models/conversation_model.dart';
import 'package:tiiun/models/message_model.dart';
import 'package:tiiun/utils/encoding_utils.dart';
import 'package:tiiun/utils/performance_monitor.dart';

/// ✅ 벤치마크 테스트 도구
class BenchmarkTool {
  static BenchmarkTool? _instance;
  static BenchmarkTool get instance => _instance ??= BenchmarkTool._();

  BenchmarkTool._();

  final List<BenchmarkResult> _results = [];
  final Random _random = Random();

  /// ✅ 전체 벤치마크 실행
  Future<BenchmarkReport> runFullBenchmark() async {
    debugPrint('🚀 벤치마크 테스트 시작...');

    final results = <BenchmarkResult>[];

    // 1. 텍스트 인코딩/디코딩 성능 테스트
    results.add(await _benchmarkTextEncoding());

    // 2. 메시지 직렬화 성능 테스트
    results.add(await _benchmarkMessageSerialization());

    // 3. 대화 직렬화 성능 테스트
    results.add(await _benchmarkConversationSerialization());

    // 4. 메모리 사용량 테스트
    results.add(await _benchmarkMemoryUsage());

    // 5. 데이터 크기 비교 테스트
    results.add(await _benchmarkDataSize());

    // 6. 실제 사용 시나리오 테스트
    results.add(await _benchmarkRealWorldScenario());

    final report = BenchmarkReport(
      timestamp: DateTime.now(),
      results: results,
    );

    debugPrint('✅ 벤치마크 테스트 완료');
    debugPrint(report.summary);

    return report;
  }

  /// ✅ 텍스트 인코딩/디코딩 성능 테스트
  Future<BenchmarkResult> _benchmarkTextEncoding() async {
    const iterations = 1000;
    final testTexts = _generateTestTexts();

    // Base64 인코딩/디코딩 시간 측정
    final base64Stopwatch = Stopwatch()..start();
    for (int i = 0; i < iterations; i++) {
      final text = testTexts[i % testTexts.length];
      final encoded = EncodingUtils.encodeToBase64(text);
      EncodingUtils.decodeFromBase64(encoded);
    }
    base64Stopwatch.stop();

    // 직접 저장 시간 측정 (거의 시간이 안 걸림)
    final directStopwatch = Stopwatch()..start();
    for (int i = 0; i < iterations; i++) {
      final text = testTexts[i % testTexts.length];
      // 직접 저장은 단순히 문자열을 그대로 사용
      final normalized = EncodingUtils.normalizeText(text);
      // 실제로는 아무것도 하지 않지만 공정한 비교를 위해 동일한 작업량
    }
    directStopwatch.stop();

    return BenchmarkResult(
      testName: 'Text Encoding/Decoding',
      base64Performance: (base64Stopwatch.elapsedMicroseconds / iterations).toDouble(),
      optimizedPerformance: (directStopwatch.elapsedMicroseconds / iterations).toDouble(),
      improvementPercent: _calculateImprovement(
        (base64Stopwatch.elapsedMicroseconds / iterations).toDouble(),
        (directStopwatch.elapsedMicroseconds / iterations).toDouble(),
      ),
      unit: 'microseconds per operation',
    );
  }

  /// ✅ 메시지 직렬화 성능 테스트
  Future<BenchmarkResult> _benchmarkMessageSerialization() async {
    const iterations = 500;
    final testMessages = _generateTestMessages();

    // Base64 버전 시간 측정 (시뮬레이션)
    final base64Stopwatch = Stopwatch()..start();
    for (int i = 0; i < iterations; i++) {
      final message = testMessages[i % testMessages.length];
      // Base64 인코딩된 버전 시뮬레이션
      final encodedContent = EncodingUtils.encodeToBase64(message.content);
      final data = {
        'content': encodedContent,
        'conversation_id': message.conversationId,
        'created_at': Timestamp.fromDate(message.createdAt),
        'sender': message.sender.toString().split('.').last,
      };
      // JSON 직렬화
      data.toString();
    }
    base64Stopwatch.stop();

    // 최적화된 버전 시간 측정
    final optimizedStopwatch = Stopwatch()..start();
    for (int i = 0; i < iterations; i++) {
      final message = testMessages[i % testMessages.length];
      // 직접 저장 버전
      final data = message.toFirestore();
      // JSON 직렬화
      data.toString();
    }
    optimizedStopwatch.stop();

    return BenchmarkResult(
      testName: 'Message Serialization',
      base64Performance: (base64Stopwatch.elapsedMicroseconds / iterations).toDouble(),
      optimizedPerformance: (optimizedStopwatch.elapsedMicroseconds / iterations).toDouble(),
      improvementPercent: _calculateImprovement(
        (base64Stopwatch.elapsedMicroseconds / iterations).toDouble(),
        (optimizedStopwatch.elapsedMicroseconds / iterations).toDouble(),
      ),
      unit: 'microseconds per message',
    );
  }

  /// ✅ 대화 직렬화 성능 테스트
  Future<BenchmarkResult> _benchmarkConversationSerialization() async {
    const iterations = 300;
    final testConversations = _generateTestConversations();

    // Base64 버전 시간 측정 (시뮬레이션)
    final base64Stopwatch = Stopwatch()..start();
    for (int i = 0; i < iterations; i++) {
      final conversation = testConversations[i % testConversations.length];
      // Base64 인코딩된 버전 시뮬레이션
      final encodedTitle = EncodingUtils.encodeToBase64(conversation.title);
      final encodedSummary = conversation.summary != null
          ? EncodingUtils.encodeToBase64(conversation.summary!)
          : null;
      final data = {
        'title': encodedTitle,
        'summary': encodedSummary,
        'user_id': conversation.userId,
        'created_at': Timestamp.fromDate(conversation.createdAt),
      };
      data.toString();
    }
    base64Stopwatch.stop();

    // 최적화된 버전 시간 측정
    final optimizedStopwatch = Stopwatch()..start();
    for (int i = 0; i < iterations; i++) {
      final conversation = testConversations[i % testConversations.length];
      final data = conversation.toFirestore();
      data.toString();
    }
    optimizedStopwatch.stop();

    return BenchmarkResult(
      testName: 'Conversation Serialization',
      base64Performance: (base64Stopwatch.elapsedMicroseconds / iterations).toDouble(),
      optimizedPerformance: (optimizedStopwatch.elapsedMicroseconds / iterations).toDouble(),
      improvementPercent: _calculateImprovement(
        (base64Stopwatch.elapsedMicroseconds / iterations).toDouble(),
        (optimizedStopwatch.elapsedMicroseconds / iterations).toDouble(),
      ),
      unit: 'microseconds per conversation',
    );
  }

  /// ✅ 메모리 사용량 테스트
  Future<BenchmarkResult> _benchmarkMemoryUsage() async {
    const iterations = 100;
    final testTexts = _generateTestTexts();

    // Base64 버전 메모리 사용량
    final base64Objects = <Map<String, String>>[];
    for (int i = 0; i < iterations; i++) {
      final text = testTexts[i % testTexts.length];
      base64Objects.add({
        'content': EncodingUtils.encodeToBase64(text),
        'title': EncodingUtils.encodeToBase64('테스트 제목 $i'),
      });
    }

    // 최적화된 버전 메모리 사용량
    final optimizedObjects = <Map<String, String>>[];
    for (int i = 0; i < iterations; i++) {
      final text = testTexts[i % testTexts.length];
      optimizedObjects.add({
        'content': text,
        'title': '테스트 제목 $i',
      });
    }

    // 메모리 사용량 대략적 계산
    final base64MemoryUsage = _estimateMemoryUsage(base64Objects);
    final optimizedMemoryUsage = _estimateMemoryUsage(optimizedObjects);

    return BenchmarkResult(
      testName: 'Memory Usage',
      base64Performance: base64MemoryUsage.toDouble(),
      optimizedPerformance: optimizedMemoryUsage.toDouble(),
      improvementPercent: _calculateImprovement(
        base64MemoryUsage.toDouble(),
        optimizedMemoryUsage.toDouble(),
      ),
      unit: 'bytes',
    );
  }

  /// ✅ 데이터 크기 비교 테스트
  Future<BenchmarkResult> _benchmarkDataSize() async {
    final testTexts = _generateTestTexts();

    int totalBase64Size = 0;
    int totalDirectSize = 0;

    for (final text in testTexts) {
      final base64Encoded = EncodingUtils.encodeToBase64(text);
      totalBase64Size += utf8.encode(base64Encoded).length;
      totalDirectSize += utf8.encode(text).length;
    }

    return BenchmarkResult(
      testName: 'Data Size',
      base64Performance: totalBase64Size.toDouble(),
      optimizedPerformance: totalDirectSize.toDouble(),
      improvementPercent: _calculateImprovement(
        totalBase64Size.toDouble(),
        totalDirectSize.toDouble(),
      ),
      unit: 'bytes',
    );
  }

  /// ✅ 실제 사용 시나리오 테스트
  Future<BenchmarkResult> _benchmarkRealWorldScenario() async {
    // 실제 대화 시나리오 시뮬레이션
    const messageCount = 50;
    final conversation = _generateTestConversations().first;
    final messages = _generateTestMessages().take(messageCount).toList();

    // Base64 버전 시나리오
    final base64Stopwatch = Stopwatch()..start();

    // 1. 대화 생성 (Base64)
    final base64ConversationData = {
      'title': EncodingUtils.encodeToBase64(conversation.title),
      'summary': conversation.summary != null
          ? EncodingUtils.encodeToBase64(conversation.summary!)
          : null,
      'user_id': conversation.userId,
    };

    // 2. 메시지들 처리 (Base64)
    final base64MessagesData = <Map<String, dynamic>>[];
    for (final message in messages) {
      base64MessagesData.add({
        'content': EncodingUtils.encodeToBase64(message.content),
        'conversation_id': message.conversationId,
        'created_at': Timestamp.fromDate(message.createdAt),
      });
    }

    // 3. 데이터 읽기 시뮬레이션 (Base64 디코딩)
    for (final data in base64MessagesData) {
      EncodingUtils.decodeFromBase64(data['content'] as String);
    }

    base64Stopwatch.stop();

    // 최적화된 버전 시나리오
    final optimizedStopwatch = Stopwatch()..start();

    // 1. 대화 생성 (직접)
    final optimizedConversationData = conversation.toFirestore();

    // 2. 메시지들 처리 (직접)
    final optimizedMessagesData = <Map<String, dynamic>>[];
    for (final message in messages) {
      optimizedMessagesData.add(message.toFirestore());
    }

    // 3. 데이터 읽기 시뮬레이션 (직접 사용)
    for (final data in optimizedMessagesData) {
      final content = data['content'] as String; // 직접 사용
    }

    optimizedStopwatch.stop();

    return BenchmarkResult(
      testName: 'Real-world Scenario',
      base64Performance: base64Stopwatch.elapsedMicroseconds.toDouble(),
      optimizedPerformance: optimizedStopwatch.elapsedMicroseconds.toDouble(),
      improvementPercent: _calculateImprovement(
        base64Stopwatch.elapsedMicroseconds.toDouble(),
        optimizedStopwatch.elapsedMicroseconds.toDouble(),
      ),
      unit: 'microseconds total',
    );
  }

  /// ✅ 테스트 데이터 생성 메서드들
  List<String> _generateTestTexts() {
    return [
      '안녕하세요! 오늘 기분이 어떠신가요?',
      '좋은 하루 보내세요. 틔운이가 항상 함께 할게요! 😊',
      '스트레스 받는 일이 있으셨나요? 편하게 이야기해보세요.',
      '감정을 표현하는 것은 정말 중요해요. 당신의 마음을 들려주세요.',
      '힘든 시간을 보내고 계시는군요. 제가 도와드릴 수 있는 것이 있을까요?',
      '오늘도 수고 많으셨어요. 잠시 휴식을 취하시는 건 어떨까요?',
      '긍정적인 생각을 해보세요. 모든 일이 잘 풀릴 거예요.',
      '당신은 충분히 잘하고 있어요. 자신을 믿어보세요!',
      '새로운 도전을 해보는 것도 좋을 것 같아요. 어떻게 생각하시나요?',
      '음악을 듣거나 산책을 하는 것도 좋은 방법이에요.',
    ];
  }

  List<Message> _generateTestMessages() {
    final texts = _generateTestTexts();
    return List.generate(texts.length, (index) {
      return Message(
        id: 'test_message_$index',
        conversationId: 'test_conversation',
        userId: 'test_user',
        content: texts[index],
        sender: index % 2 == 0 ? MessageSender.user : MessageSender.agent,
        createdAt: DateTime.now().subtract(Duration(minutes: index)),
      );
    });
  }

  List<Conversation> _generateTestConversations() {
    return List.generate(5, (index) {
      return Conversation(
        id: 'test_conversation_$index',
        userId: 'test_user',
        title: '테스트 대화 제목 $index',
        summary: '이것은 테스트 대화의 요약입니다. 사용자와 AI가 나눈 대화에 대한 간략한 설명이 들어갑니다.',
        lastMessage: '마지막 메시지 내용',
        lastMessageAt: DateTime.now(),
        createdAt: DateTime.now().subtract(Duration(days: index)),
        agentId: 'test_agent',
        messageCount: _random.nextInt(50) + 10,
      );
    });
  }

  /// ✅ 유틸리티 메서드들
  double _calculateImprovement(double before, double after) {
    if (before == 0) return 0;
    return ((before - after) / before) * 100;
  }

  int _estimateMemoryUsage(List<Map<String, String>> objects) {
    int totalSize = 0;
    for (final obj in objects) {
      for (final value in obj.values) {
        totalSize += utf8.encode(value).length;
      }
    }
    return totalSize;
  }
}

/// ✅ 벤치마크 결과 클래스들
class BenchmarkResult {
  final String testName;
  final double base64Performance;
  final double optimizedPerformance;
  final double improvementPercent;
  final String unit;

  BenchmarkResult({
    required this.testName,
    required this.base64Performance,
    required this.optimizedPerformance,
    required this.improvementPercent,
    required this.unit,
  });

  String get improvementDescription {
    if (improvementPercent > 0) {
      return '${improvementPercent.toStringAsFixed(1)}% 개선';
    } else if (improvementPercent < 0) {
      return '${(-improvementPercent).toStringAsFixed(1)}% 저하';
    } else {
      return '변화 없음';
    }
  }

  @override
  String toString() {
    return '''
$testName:
  Base64: ${base64Performance.toStringAsFixed(2)} $unit
  최적화: ${optimizedPerformance.toStringAsFixed(2)} $unit
  개선도: $improvementDescription
''';
  }
}

class BenchmarkReport {
  final DateTime timestamp;
  final List<BenchmarkResult> results;

  BenchmarkReport({
    required this.timestamp,
    required this.results,
  });

  double get averageImprovement {
    if (results.isEmpty) return 0;
    return results
        .map((r) => r.improvementPercent)
        .reduce((a, b) => a + b) / results.length;
  }

  String get summary {
    final buffer = StringBuffer();
    buffer.writeln('📊 벤치마크 보고서');
    buffer.writeln('═══════════════════════════════');
    buffer.writeln('실행 시간: ${timestamp.toString()}');
    buffer.writeln('평균 개선도: ${averageImprovement.toStringAsFixed(1)}%');
    buffer.writeln();

    for (final result in results) {
      buffer.writeln(result.toString());
    }

    buffer.writeln('✅ 전체 결론:');
    if (averageImprovement > 20) {
      buffer.writeln('🚀 성능이 크게 개선되었습니다!');
    } else if (averageImprovement > 10) {
      buffer.writeln('✨ 성능이 개선되었습니다.');
    } else if (averageImprovement > 0) {
      buffer.writeln('👍 약간의 성능 개선이 있었습니다.');
    } else {
      buffer.writeln('📊 성능 변화가 미미합니다.');
    }

    return buffer.toString();
  }

  /// JSON으로 내보내기 (선택사항)
  Map<String, dynamic> toJson() {
    return {
      'timestamp': timestamp.toIso8601String(),
      'average_improvement': averageImprovement,
      'results': results.map((r) => {
        'test_name': r.testName,
        'base64_performance': r.base64Performance,
        'optimized_performance': r.optimizedPerformance,
        'improvement_percent': r.improvementPercent,
        'unit': r.unit,
      }).toList(),
    };
  }
}

/// ✅ 벤치마크 실행을 위한 헬퍼 함수
Future<void> runBenchmarkTest() async {
  if (kDebugMode) {
    final report = await BenchmarkTool.instance.runFullBenchmark();
    debugPrint(report.summary);
  }
}
