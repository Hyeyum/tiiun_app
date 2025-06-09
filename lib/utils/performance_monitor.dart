// lib/utils/performance_monitor.dart - 성능 모니터링 유틸리티
import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// ✅ 성능 모니터링 매니저
class PerformanceMonitor {
  static PerformanceMonitor? _instance;
  static PerformanceMonitor get instance => _instance ??= PerformanceMonitor._();

  PerformanceMonitor._();

  // 메트릭 수집
  final Map<String, List<double>> _metrics = {};
  final Map<String, DateTime> _operationStartTimes = {};
  final List<MemorySnapshot> _memorySnapshots = [];

  // 설정
  bool _isEnabled = true;
  int _maxMetricHistory = 100;
  Timer? _memoryMonitorTimer;

  /// ✅ 모니터링 시작
  void startMonitoring() {
    if (!_isEnabled) return;

    // 메모리 모니터링 시작 (10초마다)
    _memoryMonitorTimer = Timer.periodic(
      const Duration(seconds: 10),
          (timer) => _captureMemorySnapshot(),
    );

    debugPrint('🔍 성능 모니터링 시작됨');
  }

  /// ✅ 모니터링 중지
  void stopMonitoring() {
    _memoryMonitorTimer?.cancel();
    _memoryMonitorTimer = null;
    debugPrint('🔍 성능 모니터링 중지됨');
  }

  /// ✅ 작업 시작 시간 기록
  void startOperation(String operationName) {
    if (!_isEnabled) return;
    _operationStartTimes[operationName] = DateTime.now();
  }

  /// ✅ 작업 완료 시간 기록
  void endOperation(String operationName) {
    if (!_isEnabled) return;

    final startTime = _operationStartTimes.remove(operationName);
    if (startTime != null) {
      final duration = DateTime.now().difference(startTime);
      recordMetric(operationName, duration.inMilliseconds.toDouble());
    }
  }

  /// ✅ 메트릭 기록
  void recordMetric(String metricName, double value) {
    if (!_isEnabled) return;

    _metrics.putIfAbsent(metricName, () => <double>[]);
    _metrics[metricName]!.add(value);

    // 히스토리 크기 제한
    if (_metrics[metricName]!.length > _maxMetricHistory) {
      _metrics[metricName]!.removeAt(0);
    }
  }

  /// ✅ 메모리 스냅샷 캡처
  Future<void> _captureMemorySnapshot() async {
    try {
      // 플랫폼별 메모리 정보 수집
      MemoryInfo? memoryInfo;

      if (Platform.isAndroid) {
        memoryInfo = await _getAndroidMemoryInfo();
      } else if (Platform.isIOS) {
        memoryInfo = await _getIOSMemoryInfo();
      }

      if (memoryInfo != null) {
        final snapshot = MemorySnapshot(
          timestamp: DateTime.now(),
          memoryInfo: memoryInfo,
        );

        _memorySnapshots.add(snapshot);

        // 스냅샷 히스토리 제한
        if (_memorySnapshots.length > _maxMetricHistory) {
          _memorySnapshots.removeAt(0);
        }

        // 메모리 경고 체크
        _checkMemoryWarnings(memoryInfo);
      }
    } catch (e) {
      debugPrint('메모리 스냅샷 캡처 실패: $e');
    }
  }

  /// ✅ Android 메모리 정보 수집
  Future<MemoryInfo?> _getAndroidMemoryInfo() async {
    try {
      const platform = MethodChannel('performance_monitor');
      final result = await platform.invokeMethod('getMemoryInfo');

      return MemoryInfo(
        usedMemoryMB: (result['usedMemory'] as num).toDouble() / (1024 * 1024),
        totalMemoryMB: (result['totalMemory'] as num).toDouble() / (1024 * 1024),
        freeMemoryMB: (result['freeMemory'] as num).toDouble() / (1024 * 1024),
      );
    } catch (e) {
      debugPrint('Android 메모리 정보 수집 실패: $e');
      return null;
    }
  }

  /// ✅ iOS 메모리 정보 수집
  Future<MemoryInfo?> _getIOSMemoryInfo() async {
    try {
      const platform = MethodChannel('performance_monitor');
      final result = await platform.invokeMethod('getMemoryInfo');

      return MemoryInfo(
        usedMemoryMB: (result['usedMemory'] as num).toDouble() / (1024 * 1024),
        totalMemoryMB: (result['totalMemory'] as num).toDouble() / (1024 * 1024),
        freeMemoryMB: (result['freeMemory'] as num).toDouble() / (1024 * 1024),
      );
    } catch (e) {
      debugPrint('iOS 메모리 정보 수집 실패: $e');
      return null;
    }
  }

  /// ✅ 메모리 경고 체크
  void _checkMemoryWarnings(MemoryInfo memoryInfo) {
    final usagePercent = (memoryInfo.usedMemoryMB / memoryInfo.totalMemoryMB) * 100;

    if (usagePercent > 90) {
      debugPrint('🚨 심각한 메모리 부족: ${usagePercent.toStringAsFixed(1)}%');
      // 메모리 정리 트리거
      _triggerMemoryCleanup();
    } else if (usagePercent > 75) {
      debugPrint('⚠️ 메모리 사용량 높음: ${usagePercent.toStringAsFixed(1)}%');
    }
  }

  /// ✅ 메모리 정리 트리거
  void _triggerMemoryCleanup() {
    // 캐시 정리 등 메모리 정리 작업
    debugPrint('🧹 메모리 정리 실행');
  }

  /// ✅ 성능 통계 생성
  PerformanceStats generateStats() {
    final stats = <String, MetricStats>{};

    _metrics.forEach((metricName, values) {
      if (values.isNotEmpty) {
        stats[metricName] = MetricStats.fromValues(values);
      }
    });

    final memoryTrend = _calculateMemoryTrend();

    return PerformanceStats(
      metricStats: stats,
      memorySnapshots: List.from(_memorySnapshots),
      memoryTrend: memoryTrend,
      monitoringDuration: _getMonitoringDuration(),
    );
  }

  /// ✅ 메모리 추세 계산
  MemoryTrend _calculateMemoryTrend() {
    if (_memorySnapshots.length < 2) {
      return MemoryTrend.stable;
    }

    final recent = _memorySnapshots.length <= 10
        ? _memorySnapshots
        : _memorySnapshots.sublist(_memorySnapshots.length - 10);
    final usages = recent.map((s) => s.memoryInfo.usagePercent).toList();

    double trend = 0;
    for (int i = 1; i < usages.length; i++) {
      trend += usages[i] - usages[i - 1];
    }

    if (trend > 5) return MemoryTrend.increasing;
    if (trend < -5) return MemoryTrend.decreasing;
    return MemoryTrend.stable;
  }

  /// ✅ 모니터링 지속 시간 계산
  Duration _getMonitoringDuration() {
    if (_memorySnapshots.isEmpty) return Duration.zero;

    final first = _memorySnapshots.first.timestamp;
    final last = _memorySnapshots.last.timestamp;
    return last.difference(first);
  }

  /// ✅ 특정 메트릭의 최근 성능 체크
  MetricHealth checkMetricHealth(String metricName) {
    final values = _metrics[metricName];
    if (values == null || values.isEmpty) {
      return MetricHealth.unknown;
    }

    final recent = values.length <= 10
        ? values
        : values.sublist(values.length - 10);
    final stats = MetricStats.fromValues(recent);

    // 임계값 기반 판단 (조정 가능)
    if (stats.average < 100) return MetricHealth.excellent;
    if (stats.average < 500) return MetricHealth.good;
    if (stats.average < 1000) return MetricHealth.warning;
    return MetricHealth.critical;
  }

  /// ✅ 성능 보고서 생성
  String generateReport() {
    final stats = generateStats();
    final buffer = StringBuffer();

    buffer.writeln('📊 성능 모니터링 보고서');
    buffer.writeln('════════════════════════════');
    buffer.writeln('모니터링 기간: ${stats.monitoringDuration.inMinutes}분');
    buffer.writeln('메모리 추세: ${stats.memoryTrend.description}');
    buffer.writeln();

    // 메트릭 통계
    buffer.writeln('📈 메트릭 통계:');
    stats.metricStats.forEach((name, metricStats) {
      final health = checkMetricHealth(name);
      buffer.writeln('  $name: ${health.emoji} 평균 ${metricStats.average.toStringAsFixed(1)}ms');
    });
    buffer.writeln();

    // 메모리 정보
    if (stats.memorySnapshots.isNotEmpty) {
      final latest = stats.memorySnapshots.last;
      buffer.writeln('💾 현재 메모리:');
      buffer.writeln('  사용량: ${latest.memoryInfo.usagePercent.toStringAsFixed(1)}%');
      buffer.writeln('  사용 메모리: ${latest.memoryInfo.usedMemoryMB.toStringAsFixed(1)}MB');
      buffer.writeln('  총 메모리: ${latest.memoryInfo.totalMemoryMB.toStringAsFixed(1)}MB');
    }

    return buffer.toString();
  }

  /// ✅ 설정
  void configure({
    bool? enabled,
    int? maxMetricHistory,
  }) {
    _isEnabled = enabled ?? _isEnabled;
    _maxMetricHistory = maxMetricHistory ?? _maxMetricHistory;
  }

  /// ✅ 리셋
  void reset() {
    _metrics.clear();
    _operationStartTimes.clear();
    _memorySnapshots.clear();
  }
}

/// ✅ 데이터 클래스들
class MemoryInfo {
  final double usedMemoryMB;
  final double totalMemoryMB;
  final double freeMemoryMB;

  MemoryInfo({
    required this.usedMemoryMB,
    required this.totalMemoryMB,
    required this.freeMemoryMB,
  });

  double get usagePercent => (usedMemoryMB / totalMemoryMB) * 100;
}

class MemorySnapshot {
  final DateTime timestamp;
  final MemoryInfo memoryInfo;

  MemorySnapshot({
    required this.timestamp,
    required this.memoryInfo,
  });
}

class MetricStats {
  final double average;
  final double min;
  final double max;
  final double median;
  final double standardDeviation;
  final int count;

  MetricStats({
    required this.average,
    required this.min,
    required this.max,
    required this.median,
    required this.standardDeviation,
    required this.count,
  });

  factory MetricStats.fromValues(List<double> values) {
    if (values.isEmpty) {
      return MetricStats(
        average: 0,
        min: 0,
        max: 0,
        median: 0,
        standardDeviation: 0,
        count: 0,
      );
    }

    final sorted = List<double>.from(values)..sort();
    final sum = values.reduce((a, b) => a + b);
    final average = sum / values.length;

    final median = sorted.length % 2 == 0
        ? (sorted[sorted.length ~/ 2 - 1] + sorted[sorted.length ~/ 2]) / 2
        : sorted[sorted.length ~/ 2];

    final variance = values.map((x) => pow(x - average, 2)).reduce((a, b) => a + b) / values.length;
    final standardDeviation = sqrt(variance);

    return MetricStats(
      average: average,
      min: sorted.first,
      max: sorted.last,
      median: median,
      standardDeviation: standardDeviation,
      count: values.length,
    );
  }
}

class PerformanceStats {
  final Map<String, MetricStats> metricStats;
  final List<MemorySnapshot> memorySnapshots;
  final MemoryTrend memoryTrend;
  final Duration monitoringDuration;

  PerformanceStats({
    required this.metricStats,
    required this.memorySnapshots,
    required this.memoryTrend,
    required this.monitoringDuration,
  });
}

enum MemoryTrend {
  increasing('증가'),
  decreasing('감소'),
  stable('안정');

  const MemoryTrend(this.description);
  final String description;
}

enum MetricHealth {
  excellent('🟢', '매우 좋음'),
  good('🟡', '좋음'),
  warning('🟠', '주의'),
  critical('🔴', '위험'),
  unknown('⚫', '알 수 없음');

  const MetricHealth(this.emoji, this.description);
  final String emoji;
  final String description;
}

/// ✅ 성능 모니터링 위젯 확장
extension PerformanceMonitorWidget on PerformanceMonitor {
  /// 위젯 성능 측정 래퍼
  Widget measureWidget({
    required String name,
    required Widget child,
  }) {
    return _PerformanceMeasuredWidget(
      name: name,
      child: child,
    );
  }
}

class _PerformanceMeasuredWidget extends StatefulWidget {
  final String name;
  final Widget child;

  const _PerformanceMeasuredWidget({
    required this.name,
    required this.child,
  });

  @override
  State<_PerformanceMeasuredWidget> createState() => _PerformanceMeasuredWidgetState();
}

class _PerformanceMeasuredWidgetState extends State<_PerformanceMeasuredWidget> {
  @override
  void initState() {
    super.initState();
    PerformanceMonitor.instance.startOperation('widget_${widget.name}_build');
  }

  @override
  void dispose() {
    PerformanceMonitor.instance.endOperation('widget_${widget.name}_dispose');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    PerformanceMonitor.instance.endOperation('widget_${widget.name}_build');
    return widget.child;
  }
}
