import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tiiun/design_system/colors.dart';
import 'package:tiiun/design_system/typography.dart';
import '../../models/growth_record_model.dart';
import '../../services/backend_providers.dart';
import '../../utils/plant_data.dart';
import 'dart:ui';

class BuddyDiaryPage extends ConsumerStatefulWidget {
  final String plantName;
  final String plantVariety;
  final String plantedDate;
  final String plantImage;
  final int daysPlanted;
  final String? plantId; // 식물 ID 추가

  const BuddyDiaryPage({
    super.key,
    required this.plantName,
    required this.plantVariety,
    required this.plantedDate,
    required this.plantImage,
    required this.daysPlanted,
    this.plantId,
  });

  @override
  ConsumerState<BuddyDiaryPage> createState() => _BuddyDiaryPageState();
}

class _BuddyDiaryPageState extends ConsumerState<BuddyDiaryPage> {
  List<GrowthRecord> _growthRecords = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadGrowthRecords();
  }

  Future<void> _loadGrowthRecords() async {
    if (widget.plantId == null) {
      setState(() {
        _isLoading = false;
        _errorMessage = '식물 정보가 없습니다.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final growthRecordService = ref.read(growthRecordApiServiceProvider);
      final response = await growthRecordService.getGrowthRecordsByPlant(widget.plantId!);

      if (response.isSuccess && response.data != null) {
        setState(() {
          _growthRecords = response.data!;
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = response.error ?? '성장 기록을 불러오는데 실패했습니다.';
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = '성장 기록을 불러오는 중 오류가 발생했습니다: $e';
      });
    }
  }

  // 식물 카테고리에 따른 성장 단계 정보 가져오기
  Map<String, String> _getGrowthStages(String plantVariety) {
    if (plantVariety.contains('토마토') || plantVariety.contains('과채')) {
      return {
        '발아기': '약 5-10일',
        '성장기': '약 45-60일',
        '수확기': '약 70-85일',
      };
    } else if (plantVariety.contains('바질') || plantVariety.contains('라벤더') || plantVariety.contains('허브')) {
      return {
        '발아기': '약 10-21일',
        '성장기': '약 30-50일',
        '수확기': '약 60-80일',
      };
    } else {
      return {
        '발아기': '약 7-14일',
        '성장기': '약 20-40일',
        '개화기': '약 50-70일',
      };
    }
  }

  // 성장 단계 진행률 계산
  double _calculateProgress() {
    if (widget.daysPlanted <= 14) return 0.3;
    if (widget.daysPlanted <= 40) return 0.6;
    return 0.9;
  }

  // 개화 예상 시기 계산
  String _getExpectedBloomPeriod() {
    final plantedDate = DateTime.tryParse(widget.plantedDate.replaceAll('.', '-'));
    if (plantedDate == null) return '정보 없음';

    final expectedStart = plantedDate.add(Duration(days: 50));
    final expectedEnd = plantedDate.add(Duration(days: 70));

    return '${_formatDate(expectedStart)} - ${_formatDate(expectedEnd)}';
  }

  String _formatDate(DateTime date) {
    return '${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}';
  }

  String _formatFullDate(DateTime date) {
    return '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final growthStages = _getGrowthStages(widget.plantVariety);
    final progress = _calculateProgress();
    final expectedBloom = _getExpectedBloomPeriod();

    return Scaffold(
      backgroundColor: Color(0xFFE8F6F6),
      appBar: AppBar(
        backgroundColor: Color(0xFFE8F6F6),
        elevation: 0,
        scrolledUnderElevation: 0,
        toolbarHeight: 56,
        leadingWidth: 56,
        leading: Padding(
          padding: const EdgeInsets.only(left: 4),
          child: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: SvgPicture.asset(
              'assets/icons/functions/back.svg',
              width: 24,
              height: 24,
              color: AppColors.grey700,
            ),
          ),
        ),
        title: Padding(
          padding: const EdgeInsets.only(top: 0),
          child: Text(
            '성장일지',
            style: AppTypography.b2.withColor(AppColors.grey900),
          ),
        ),
        centerTitle: true,
        actions: [
          // 새 기록 추가 버튼
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: IconButton(
              onPressed: _showAddRecordDialog,
              icon: Icon(
                Icons.add,
                color: AppColors.main600,
                size: 24,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 식물 기본 정보 Container
            Container(
              margin: EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          margin: EdgeInsets.only(top: 3, bottom: 13,),
                          child: Text(
                            widget.plantName,
                            style: AppTypography.h5.withColor(AppColors.grey900),
                          ),
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '함께한 지',
                                  style: AppTypography.c2.withColor(AppColors.grey400),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  '${widget.daysPlanted}일째',
                                  style: AppTypography.b1.withColor(AppColors.grey700),
                                ),
                              ],
                            ),
                            SizedBox(width: 54),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '품종',
                                  style: AppTypography.c2.withColor(AppColors.grey400),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  widget.plantVariety,
                                  style: AppTypography.b1.withColor(AppColors.grey700),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Text(
                          '${widget.plantedDate} ~',
                          style: AppTypography.c3.withColor(AppColors.grey500),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 20),
                  ClipRect(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                      child: Container(
                        width: 100,
                        height: 100,
                        padding: EdgeInsets.symmetric(horizontal: 14, vertical: 20),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(28),
                          border: Border.all(
                            color: Colors.white,
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Color(0xFF131927).withOpacity(0.08),
                              offset: Offset(0, 8),
                              blurRadius: 16,
                              spreadRadius: -6,
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          child: Image.asset(
                            widget.plantImage,
                            fit: BoxFit.contain,
                            filterQuality: FilterQuality.high,
                            errorBuilder: (context, error, stackTrace) {
                              return Center(
                                child: Icon(
                                  Icons.local_florist,
                                  size: 40,
                                  color: AppColors.main600,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // 위쪽 둥근 Container (개화 예상 시기 + 일기 섹션)
            Container(
              padding: EdgeInsets.only(top: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. 개화 예상 시기 섹션
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '개화 예상 시기 : $expectedBloom',
                          style: AppTypography.c1.withColor(AppColors.grey400),
                        ),
                        Container(
                          margin: EdgeInsets.symmetric(vertical: 8),
                          child: Text(
                            '버디가 잘 자라고 있어요. 어떤 꽃이 필까요?',
                            style: AppTypography.b3.withColor(AppColors.grey900),
                          ),
                        ),
                        Container(
                            padding: EdgeInsets.fromLTRB(12, 20, 12, 0),
                            child: Column(
                              children: [
                                // 발아기, 성장기, 개화기/수확기
                                Container(
                                  margin: EdgeInsets.symmetric(horizontal: 8),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: growthStages.entries.map((entry) {
                                      return Column(
                                        children: [
                                          Text(
                                            entry.key,
                                            style: AppTypography.b4.withColor(AppColors.grey900),
                                          ),
                                          SizedBox(height: 3),
                                          Text(
                                            entry.value,
                                            style: AppTypography.c1.withColor(AppColors.grey400),
                                          ),
                                        ],
                                      );
                                    }).toList(),
                                  ),
                                ),
                                SizedBox(height: 8),
                                // 프로그레스 바
                                Container(
                                    height: 32,
                                    child: LayoutBuilder(
                                        builder: (context, constraints) {
                                          return Stack(
                                            children: [
                                              Container(
                                                width: double.infinity,
                                                height: 8,
                                                decoration: BoxDecoration(
                                                  color: AppColors.grey100,
                                                  borderRadius: BorderRadius.circular(16),
                                                ),
                                              ),
                                              FractionallySizedBox(
                                                alignment: Alignment.centerLeft,
                                                widthFactor: progress,
                                                child: Container(
                                                  height: 8,
                                                  decoration: BoxDecoration(
                                                    gradient: const LinearGradient(
                                                      colors: [
                                                        Color(0xFF72ED98),
                                                        Color(0xFF10BEBE)
                                                      ],
                                                      stops: [0.4, 1.0],
                                                      begin: Alignment.centerLeft,
                                                      end: Alignment.centerRight,
                                                    ),
                                                    borderRadius: BorderRadius.circular(16),
                                                  ),
                                                ),
                                              ),
                                              // 아이콘 (진행률 지점에)
                                              Positioned(
                                                left: (constraints.maxWidth * progress) - 12,
                                                top: 8,
                                                child: SvgPicture.asset(
                                                  'assets/icons/buddy/full_bottle.svg',
                                                  width: 24,
                                                  height: 24,
                                                ),
                                              ),
                                            ],
                                          );
                                        }
                                    )
                                ),
                              ],
                            )
                        ),
                      ],
                    ),
                  ),

                  // 2. 구분선 섹션
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 20),
                    color: AppColors.grey200,
                    height: 0.5,
                  ),

                  // 3. 일기 섹션
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 20),
                          child: Row(
                            children: [
                              Text(
                                '일기',
                                style: AppTypography.h5.withColor(AppColors.grey900),
                              ),
                              Spacer(),
                              SvgPicture.asset(
                                'assets/icons/buddy/Calendar.svg',
                                width: 24,
                                height: 24,
                              ),
                            ],
                          ),
                        ),

                        _buildDiaryContent(),
                      ],
                    ),
                  ),

                  SizedBox(height: 16,),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDiaryContent() {
    if (_isLoading) {
      return Container(
        padding: EdgeInsets.symmetric(vertical: 40),
        child: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.main600),
          ),
        ),
      );
    }

    if (_errorMessage != null) {
      return Container(
        padding: EdgeInsets.symmetric(vertical: 40),
        child: Center(
          child: Column(
            children: [
              Text(
                _errorMessage!,
                style: AppTypography.b3.withColor(AppColors.grey600),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadGrowthRecords,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.main600,
                  foregroundColor: Colors.white,
                ),
                child: Text('다시 시도'),
              ),
            ],
          ),
        ),
      );
    }

    if (_growthRecords.isEmpty) {
      return Container(
        padding: EdgeInsets.symmetric(vertical: 60),
        child: Center(
          child: Column(
            children: [
              Icon(
                Icons.book,
                size: 48,
                color: AppColors.grey400,
              ),
              SizedBox(height: 16),
              Text(
                '아직 성장 기록이 없어요',
                style: AppTypography.s2.withColor(AppColors.grey500),
              ),
              SizedBox(height: 8),
              Text(
                '버디의 성장 과정을 기록해보세요!',
                style: AppTypography.b3.withColor(AppColors.grey400),
              ),
            ],
          ),
        ),
      );
    }

    // 날짜 순으로 정렬 (최신순)
    final sortedRecords = List<GrowthRecord>.from(_growthRecords)
      ..sort((a, b) => b.recordDate.compareTo(a.recordDate));

    return Column(
      children: sortedRecords.asMap().entries.map((entry) {
        final index = entry.key;
        final record = entry.value;
        final isLast = index == sortedRecords.length - 1;

        return _buildDiaryItem(
          record: record,
          isLast: isLast,
        );
      }).toList(),
    );
  }

  Widget _buildDiaryItem({
    required GrowthRecord record,
    bool isLast = false,
  }) {
    final date = record.recordDate;
    final formattedDate = _formatFullDate(date);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 타임라인 부분
          Container(
            child: Column(
              children: [
                // 원형 점
                Container(
                  width: 5,
                  height: 5,
                  decoration: BoxDecoration(
                    color: AppColors.main700,
                    shape: BoxShape.circle,
                  ),
                ),
                // 세로 라인 (마지막 아이템이 아닌 경우에만)
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 1,
                      color: AppColors.main700,
                    ),
                  ),
              ],
            ),
          ),

          SizedBox(width: 15),

          // 콘텐츠 부분
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      formattedDate,
                      style: AppTypography.b1.withColor(AppColors.grey900),
                    ),
                    Spacer(),
                    // 성장 단계 표시
                    if (record.growthStage != null)
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.main100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          record.growthStage!,
                          style: AppTypography.c1.withColor(AppColors.main700),
                        ),
                      ),
                  ],
                ),
                SizedBox(height: 10),

                // 이미지가 있는 경우 표시
                if (record.imageUrls.isNotEmpty) ...[
                  Container(
                    width: double.infinity,
                    height: 200,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        record.imageUrls.first,
                        fit: BoxFit.cover,
                        filterQuality: FilterQuality.high,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: AppColors.grey100,
                            child: Center(
                              child: Icon(
                                Icons.image,
                                color: AppColors.grey400,
                                size: 40,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                ],

                // 성장 기록 내용
                if (record.notes != null && record.notes!.isNotEmpty)
                  Text(
                    record.notes!,
                    style: AppTypography.b1.withColor(AppColors.grey900),
                  ),

                // 측정 데이터 표시
                if (record.height != null || record.width != null) ...[
                  SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      if (record.height != null)
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.grey100,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '키: ${record.height}cm',
                            style: AppTypography.c1.withColor(AppColors.grey700),
                          ),
                        ),
                      if (record.width != null)
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.grey100,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '폭: ${record.width}cm',
                            style: AppTypography.c1.withColor(AppColors.grey700),
                          ),
                        ),
                    ],
                  ),
                ],

                SizedBox(height: 16), // 다음 아이템과의 간격
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 새 기록 추가 다이얼로그
  void _showAddRecordDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            '성장 기록 추가',
            style: AppTypography.s1.withColor(AppColors.grey900),
          ),
          content: Text(
            '새로운 성장 기록을 추가하시겠습니까?\n\n이 기능은 아직 개발 중입니다.',
            style: AppTypography.b3.withColor(AppColors.grey700),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                '취소',
                style: AppTypography.s2.withColor(AppColors.grey600),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('성장 기록 추가 기능은 준비 중입니다.'),
                    backgroundColor: AppColors.main600,
                  ),
                );
              },
              child: Text(
                '확인',
                style: AppTypography.s2.withColor(AppColors.main700),
              ),
            ),
          ],
        );
      },
    );
  }
}