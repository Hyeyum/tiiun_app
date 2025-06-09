// lib/pages/admin/benchmark_page.dart - 벤치마크 테스트 실행 페이지
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:tiiun/utils/benchmark_tool.dart';
import 'package:tiiun/design_system/colors.dart';
import 'package:tiiun/design_system/typography.dart';

class BenchmarkPage extends StatefulWidget {
  const BenchmarkPage({super.key});

  @override
  State<BenchmarkPage> createState() => _BenchmarkPageState();
}

class _BenchmarkPageState extends State<BenchmarkPage> {
  bool _isRunning = false;
  BenchmarkReport? _lastReport;
  String _currentStatus = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('성능 벤치마크', style: AppTypography.h5),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 설명
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.main100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '🚀 성능 최적화 효과 측정',
                    style: AppTypography.s1.withColor(AppColors.main700),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Base64 인코딩 제거와 성능 최적화의 효과를 측정합니다.',
                    style: AppTypography.b3.withColor(AppColors.main600),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // 벤치마크 실행 버튼
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _isRunning ? null : _runBenchmark,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.main600,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isRunning
                    ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text('벤치마크 실행 중...', style: AppTypography.largeBtn),
                  ],
                )
                    : Text('🔬 벤치마크 시작', style: AppTypography.largeBtn),
              ),
            ),

            const SizedBox(height: 16),

            // 현재 상태 표시
            if (_currentStatus.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.grey50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.grey200),
                ),
                child: Row(
                  children: [
                    const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    const SizedBox(width: 12),
                    Text(_currentStatus, style: AppTypography.b3),
                  ],
                ),
              ),

            const SizedBox(height: 24),

            // 결과 표시
            if (_lastReport != null) ...[
              Text('📊 벤치마크 결과', style: AppTypography.s1),
              const SizedBox(height: 12),

              // 전체 요약
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _getImprovementColor(_lastReport!.averageImprovement),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '전체 성능 개선',
                      style: AppTypography.s2.withColor(Colors.white),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${_lastReport!.averageImprovement.toStringAsFixed(1)}%',
                      style: AppTypography.h4.withColor(Colors.white),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // 개별 테스트 결과
              Expanded(
                child: ListView.builder(
                  itemCount: _lastReport!.results.length,
                  itemBuilder: (context, index) {
                    final result = _lastReport!.results[index];
                    return _buildResultCard(result);
                  },
                ),
              ),

              const SizedBox(height: 16),

              // 상세 보고서 버튼
              SizedBox(
                width: double.infinity,
                height: 40,
                child: OutlinedButton(
                  onPressed: _showDetailedReport,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.main600,
                    side: BorderSide(color: AppColors.main600),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text('📄 상세 보고서 보기', style: AppTypography.b2),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _runBenchmark() async {
    if (!kDebugMode) {
      _showSnackBar('벤치마크는 디버그 모드에서만 실행 가능합니다.', AppColors.point900);
      return;
    }

    setState(() {
      _isRunning = true;
      _currentStatus = '벤치마크 초기화 중...';
    });

    try {
      // 각 테스트별로 상태 업데이트
      final testNames = [
        '텍스트 인코딩/디코딩 테스트',
        '메시지 직렬화 테스트',
        '대화 직렬화 테스트',
        '메모리 사용량 테스트',
        '데이터 크기 비교 테스트',
        '실제 사용 시나리오 테스트',
      ];

      for (int i = 0; i < testNames.length; i++) {
        setState(() {
          _currentStatus = '${testNames[i]} 실행 중... (${i + 1}/${testNames.length})';
        });

        // 각 테스트 사이에 약간의 지연을 주어 UI 업데이트 시간 확보
        await Future.delayed(const Duration(milliseconds: 100));
      }

      final report = await BenchmarkTool.instance.runFullBenchmark();

      setState(() {
        _lastReport = report;
        _isRunning = false;
        _currentStatus = '';
      });

      if (report.averageImprovement > 0) {
        _showSnackBar('✅ 벤치마크 완료! ${report.averageImprovement.toStringAsFixed(1)}% 성능 개선', AppColors.main600);
      } else {
        _showSnackBar('📊 벤치마크 완료', AppColors.grey600);
      }

    } catch (e) {
      setState(() {
        _isRunning = false;
        _currentStatus = '';
      });
      _showSnackBar('❌ 벤치마크 실행 실패: $e', AppColors.point900);
    }
  }

  Widget _buildResultCard(BenchmarkResult result) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.grey200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  result.testName,
                  style: AppTypography.b1.withColor(AppColors.grey900),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getImprovementColor(result.improvementPercent).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  result.improvementDescription,
                  style: AppTypography.c1.withColor(_getImprovementColor(result.improvementPercent)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Base64 버전', style: AppTypography.c2.withColor(AppColors.grey600)),
                    Text(
                      '${result.base64Performance.toStringAsFixed(2)} ${result.unit}',
                      style: AppTypography.b3.withColor(AppColors.grey800),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('최적화 버전', style: AppTypography.c2.withColor(AppColors.grey600)),
                    Text(
                      '${result.optimizedPerformance.toStringAsFixed(2)} ${result.unit}',
                      style: AppTypography.b3.withColor(AppColors.main700),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getImprovementColor(double improvement) {
    if (improvement > 20) return AppColors.main600;
    if (improvement > 10) return AppColors.main500;
    if (improvement > 0) return AppColors.main400;
    if (improvement < -10) return AppColors.point900;
    if (improvement < 0) return AppColors.point600;
    return AppColors.grey500;
  }

  void _showDetailedReport() {
    if (_lastReport == null) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('상세 벤치마크 보고서', style: AppTypography.s1),
        content: SingleChildScrollView(
          child: Container(
            width: double.maxFinite,
            child: Text(
              _lastReport!.summary,
              style: AppTypography.c1.withColor(AppColors.grey800),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('닫기', style: AppTypography.b2.withColor(AppColors.main600)),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
      ),
    );
  }
}
