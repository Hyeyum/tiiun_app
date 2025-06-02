import 'package:flutter/material.dart';
import 'package:tiiun/design_system/colors.dart';
import 'package:tiiun/design_system/typography.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tiiun/services/conversation_service.dart';
import 'package:tiiun/models/conversation_model.dart';
import 'package:tiiun/services/sentiment_analysis_service.dart';
import 'package:tiiun/services/conversation_insights_service.dart';
import 'package:tiiun/services/mood_service.dart';
import 'package:tiiun/services/firebase_service.dart';
import 'package:tiiun/models/mood_record_model.dart';
import 'package:tiiun/models/conversation_insight_model.dart';
import 'package:tiiun/models/sentiment_analysis_result_model.dart';
import 'package:tiiun/utils/error_handler.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tiiun/pages/home_chatting/full_conversation_history_page.dart';
import 'package:tiiun/pages/home_chatting/activity_detail_page.dart';
import 'dart:ui';

class ModalAnalysisScreen extends ConsumerStatefulWidget {
  final String conversationId;

  const ModalAnalysisScreen({super.key, required this.conversationId});

  @override
  ConsumerState<ModalAnalysisScreen> createState() => _ModalAnalysisScreenState();
}

class _ModalAnalysisScreenState extends ConsumerState<ModalAnalysisScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // 분석 상태
  bool _isLoadingAnalysis = true;
  bool _isLoadingInsights = true;

  // 감정 분석 데이터
  double _averageSentimentScore = 0.0;
  String _mainSentiment = '분석 중...';
  String _sentimentChange = '분석 중...';
  String _summary = '분석 중...';
  List<Map<String, dynamic>> _emotionTrends = [];

  // 인사이트 데이터
  String _insights = '분석 중...';
  List<String> _insightsTags = [];
  List<String> _suggestions = [];
  String _personalizedAdvice = '분석 중...';
  List<String> _exercises = [];
  List<String> _resources = [];

  // 사용자 데이터
  String _userName = '사용자';
  List<MoodRecord> _recentMoodRecords = [];

  // 실제 FireStore 데이터
  List<ConversationInsight> _conversationInsights = [];
  List<SentimentAnalysisResult> _sentimentResults = [];
  String _actualKeyTopics = '';
  String _actualOverallMood = '';
  String _actualSentimentSummary = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadUserData();
    _loadActualFireStoreData();
    _performComprehensiveAnalysis();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    try {
      // 임시로 기본값 설정
      if (mounted) {
        setState(() {
          _userName = '사용자';
          _recentMoodRecords = [];
        });
      }
    } catch (e) {
      _showErrorSnackBar('사용자 정보를 불러오는 중 오류가 발생했습니다: ${e.toString()}');
    }
  }

  // 실제 FireStore 데이터 로드
  Future<void> _loadActualFireStoreData() async {
    try {
      final conversationInsightsService = ref.read(conversationInsightsServiceProvider);
      final sentimentAnalysisService = ref.read(sentimentAnalysisServiceProvider);

      // 대화 인사이트 가져오기
      final insights = await conversationInsightsService.getInsightsByConversation(widget.conversationId);

      // 감정 분석 결과 가져오기
      final sentiments = await sentimentAnalysisService.getSentimentsByConversation(widget.conversationId);

      if (mounted) {
        setState(() {
          _conversationInsights = insights;
          _sentimentResults = sentiments;

          if (insights.isNotEmpty) {
            final latestInsight = insights.first;
            _actualKeyTopics = latestInsight.keyTopics;
            _actualOverallMood = latestInsight.overallMood;
            _actualSentimentSummary = latestInsight.sentimentSummary;
          }
        });
      }
    } catch (e) {
      print('FireStore 데이터 로드 오류: $e');
    }
  }

  Future<void> _performComprehensiveAnalysis() async {
    await Future.wait([
      _performSentimentAnalysis(),
      _generateConversationInsights(),
    ]);
  }

  Future<void> _performSentimentAnalysis() async {
    setState(() {
      _isLoadingAnalysis = true;
    });

    try {
      final conversationService = ref.read(conversationServiceProvider);
      final sentimentAnalysisService = ref.read(sentimentAnalysisServiceProvider);

      final messages = await conversationService.getConversationMessages(widget.conversationId).first;

      if (messages.isEmpty) {
        if (mounted) {
          setState(() {
            _isLoadingAnalysis = false;
            _mainSentiment = '대화 내용 없음';
            _sentimentChange = '해당 없음';
            _summary = '대화 내용이 없습니다.';
          });
        }
        return;
      }

      final conversationAnalysisResult = await sentimentAnalysisService.analyzeConversation(messages);
      final emotionTrends = await sentimentAnalysisService.trackEmotionTrends(messages);
      final emotionalInsightsResult = await sentimentAnalysisService.generateEmotionalInsights(messages);

      if (mounted) {
        setState(() {
          _isLoadingAnalysis = false;
          _averageSentimentScore = (conversationAnalysisResult['averageMoodScore'] as double? ?? 0.0) * 100;
          _mainSentiment = _getMoodLabel(conversationAnalysisResult['dominantEmotion'] as String? ?? 'neutral');
          _sentimentChange = (conversationAnalysisResult['moodChangeDetected'] as bool? ?? false)
              ? '감정 변화 감지됨'
              : '안정적';
          _summary = conversationAnalysisResult['summary'] as String? ?? '요약 없음';
          _insights = emotionalInsightsResult['insights'] as String? ?? '통찰 없음';
          _suggestions = List<String>.from(emotionalInsightsResult['suggestions'] ?? []);
          _emotionTrends = emotionTrends;
          _insightsTags = _extractKeywordsFromInsight(_insights);
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingAnalysis = false;
          _mainSentiment = '오류 발생';
          _sentimentChange = '분석 실패';
          _summary = '분석 중 오류가 발생했습니다: ${e.toString()}';
          _insights = '분석을 완료할 수 없습니다.';
        });
        _showErrorSnackBar('감정 분석 중 오류가 발생했습니다: ${e.toString()}');
      }
    }
  }

  Future<void> _generateConversationInsights() async {
    setState(() {
      _isLoadingInsights = true;
    });

    try {
      // 임시 데이터로 인사이트 시뮬레이션
      await Future.delayed(const Duration(seconds: 2)); // 로딩 시뮬레이션

      if (mounted) {
        setState(() {
          _isLoadingInsights = false;
          _personalizedAdvice = '${_userName}님은 대화에서 긍정적인 에너지를 보여주고 있습니다. '
              '이러한 긍정적인 마음가짐을 유지하면서 스트레스 관리를 위한 활동들을 꾸준히 실천해보세요. '
              '명상이나 가벼운 운동은 감정의 균형을 유지하는 데 도움이 될 것입니다.';
          _exercises = ['명상', '산책', '음악 감상', '독서'];
          _resources = ['마음챙김 앱', '자연 소리', '긍정 도서'];
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingInsights = false;
          _personalizedAdvice = '조언 생성 중 오류가 발생했습니다: ${e.toString()}';
        });
        _showErrorSnackBar('인사이트 생성 중 오류가 발생했습니다: ${e.toString()}');
      }
    }
  }

  List<String> _extractKeywordsFromInsight(String insightText) {
    if (insightText.isEmpty || insightText == '통찰 없음' || insightText.contains('분석을 완료할 수 없습니다.')) {
      return [];
    }
    final List<String> words = insightText.split(RegExp(r'[,\.\s]+')).where((s) => s.isNotEmpty).toList();
    final List<String> relevantWords = words.where((word) => word.length > 1).toList();
    return relevantWords.take(5).toList();
  }

  // 실제 키 토픽에서 태그 추출 (명사형 키워드로 변환)
  List<String> _getActualInsightTags() {
    List<String> keywords = [];

    // 감정 상태에 따른 키워드 추가
    keywords.addAll(_getEmotionKeywords(_mainSentiment));

    // 실제 키 토픽에서 키워드 추출
    if (_actualKeyTopics.isNotEmpty) {
      keywords.addAll(_extractNounKeywords(_actualKeyTopics));
    }

    // 인사이트에서 키워드 추출
    if (_insights.isNotEmpty && _insights != '분석 중...' && _insights != '통찰 없음') {
      keywords.addAll(_extractNounKeywords(_insights));
    }

    // 중복 제거 및 최대 5개 반환
    return keywords.toSet().take(5).toList();
  }

  // 감정 상태에 따른 관련 키워드 반환
  List<String> _getEmotionKeywords(String emotion) {
    switch (emotion) {
      case '기쁨':
        return ['긍정', '활력', '희망', '성취'];
      case '좋음':
        return ['만족', '안정', '평온', '균형'];
      case '중립':
        return ['일상', '평범', '무난', '보통'];
      case '나쁨':
        return ['스트레스', '피로', '걱정', '불안'];
      default:
        return ['감정', '마음', '상태'];
    }
  }

  // 텍스트에서 명사형 키워드 추출
  List<String> _extractNounKeywords(String text) {
    List<String> keywords = [];

    // 감정 관련 키워드 매핑
    Map<String, List<String>> emotionMapping = {
      '스트레스': ['스트레스', '압박'],
      '불안': ['불안', '걱정'],
      '우울': ['우울', '슬픔'],
      '행복': ['행복', '기쁨'],
      '분노': ['분노', '화'],
      '피로': ['피로', '지침'],
      '외로움': ['외로움', '고독'],
      '사랑': ['사랑', '애정'],
      '희망': ['희망', '기대'],
      '두려움': ['두려움', '공포'],
    };

    // 일반적인 주제 키워드 매핑
    Map<String, List<String>> topicMapping = {
      '일': ['업무', '직장', '일'],
      '관계': ['관계', '인간관계', '소통'],
      '가족': ['가족', '부모', '자녀'],
      '친구': ['친구', '우정'],
      '연애': ['연애', '사랑', '연인'],
      '건강': ['건강', '몸', '운동'],
      '돈': ['돈', '경제', '재정'],
      '미래': ['미래', '계획', '목표'],
      '과거': ['과거', '추억', '경험'],
      '학교': ['학교', '공부', '학습'],
      '취미': ['취미', '여가', '활동'],
      '여행': ['여행', '휴식'],
      '음식': ['음식', '식사'],
      '잠': ['수면', '잠', '휴식'],
    };

    // 텍스트에서 키워드 찾기
    String lowerText = text.toLowerCase();

    emotionMapping.forEach((key, values) {
      if (lowerText.contains(key)) {
        keywords.addAll(values);
      }
    });

    topicMapping.forEach((key, values) {
      if (lowerText.contains(key)) {
        keywords.addAll(values);
      }
    });

    // 기본 키워드가 없으면 텍스트에서 직접 추출
    if (keywords.isEmpty) {
      List<String> words = text.split(RegExp(r'[,\.\s]+')).where((s) => s.length > 1).toList();
      keywords.addAll(words.take(3));
    }

    return keywords;
  }

  String _getMoodLabel(String moodKey) {
    switch (moodKey) {
      case 'bad':
        return '나쁨';
      case 'neutral':
        return '중립';
      case 'good':
        return '좋음';
      case 'joy':
        return '기쁨';
      default:
        return '중립';
    }
  }

  String _getMoodIconPath(String moodLabel) {
    switch (moodLabel) {
      case '나쁨':
        return 'assets/icons/sentiment/negative.svg';
      case '중립':
        return 'assets/icons/sentiment/neutral.svg';
      case '좋음':
        return 'assets/icons/sentiment/positive.svg';
      case '기쁨':
        return 'assets/icons/sentiment/happy.svg';
      default:
        return 'assets/icons/sentiment/neutral.svg';
    }
  }

  Widget _buildTag(String text) {
    return Container(
      // width: 90,
      height: 30,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.grey100,
        borderRadius: BorderRadius.circular(32),
      ),
      child: Text(
        text,
        style: AppTypography.c1.withColor(AppColors.grey700),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildSummaryItem(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTypography.s2.withColor(AppColors.grey900),
        ),
        const SizedBox(height: 4),
        Text(
          content,
          style: AppTypography.b3.withColor(AppColors.grey600).copyWith(height: 1.4),
        ),
      ],
    );
  }

  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.point900,
      ),
    );
  }

  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.grey600,
      ),
    );
  }

  void _showActivityDetailModal({
    required String imagePath,
    required String imageTag,
    required String title,
    required String shortDescription,
    required String longDescription,
    required String buttonText,
    required VoidCallback onStartActivity,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return ActivityDetailPage(
          imagePath: imagePath,
          imageTag: imageTag,
          title: title,
          shortDescription: shortDescription,
          longDescription: longDescription,
          buttonText: buttonText,
          onStartActivity: onStartActivity,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height - 56,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Text(
                        '대화 기록',
                        style: AppTypography.h5.withColor(AppColors.grey900),
                      ),
                      const Spacer(),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            child: TabBar(
              controller: _tabController,
              labelColor: AppColors.grey800,
              unselectedLabelColor: AppColors.grey500,
              indicatorColor: Colors.transparent,
              dividerColor: Colors.transparent,
              indicator: const UnderlineTabIndicator(
                borderSide: BorderSide(width: 3.0, color: AppColors.main700),
                insets: EdgeInsets.symmetric(horizontal: 88), // indicator 길이 조절
              ),
              labelStyle: AppTypography.s2,
              unselectedLabelStyle: AppTypography.s2,
              tabs: const [
                Tab(text: '감정 분석'),
                Tab(text: '대화 인사이트'),
              ],
            )
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildSentimentAnalysisTab(),
                _buildInsightsAndRecommendationsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSentimentAnalysisTab() {
    if (_isLoadingAnalysis) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.main600),
            ),
            const SizedBox(height: 20),
            Text(
              '대화 내용을 분석 중입니다...',
              style: AppTypography.b2.withColor(AppColors.grey600),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 감정 정보 컨테이너
            Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(vertical: 16),
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
              decoration: BoxDecoration(
                color: AppColors.grey50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  _buildInfoRow(
                    '평균 감정 점수',
                    '${_averageSentimentScore.toStringAsFixed(1)}',
                    showProgress: true,
                  ),
                  const SizedBox(height: 12),
                  _buildInfoRow(
                    '주요 감정',
                    _mainSentiment,
                    iconPath: _getMoodIconPath(_mainSentiment),
                  ),
                  const SizedBox(height: 12),
                  _buildInfoRow(
                    '감정 변화',
                    _sentimentChange,
                  ),
                ],
              ),
            ),

            // 추천 활동 섹션
            Text(
              '$_userName님을 위한 추천 활동',
              style: AppTypography.s1.withColor(AppColors.grey900),
            ),
            const SizedBox(height: 8),

            Container(
              width: double.infinity,
              child: Column(
                children: [
                  _buildActivityCard(
                    'assets/images/dialog/meditation.png',
                    '명상을 통한 스트레스 해소',
                    '마음을 집중하고 깊은 호흡을 통해 스트레스를 해소하는 명상을 시도해보세요!',
                    onTap: () {
                      _showActivityDetailModal(
                        imagePath: 'assets/images/dialog/meditation.png',
                        imageTag: '명상',
                        title: '명상을 통한 스트레스 해소',
                        shortDescription: '마음을 집중하고 깊은 호흡을 통해 스트레스를 해소하는 명상을 시도해보세요!',
                        longDescription: '외부 환경에서 오는 스트레스를 해소하는 데 도움이 되고, 마음의 안정과 집중력을 높여 일상에서의 감정 조절 능력을 향상시키는 데 효과적이에요.',
                        buttonText: '활동 시작하기',
                        onStartActivity: () {
                          Navigator.pop(context);
                          _showSnackBar('명상 활동을 시작합니다!');
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 8),
                  _buildActivityCard(
                    'assets/images/dialog/walking.png',
                    '자연 속 산책',
                    '자연 속으로 나가 신선한 공기를 마시며 걷는 것은 마음과 몸에 상쾌한 영향을 주어요.',
                    onTap: () {
                      _showActivityDetailModal(
                        imagePath: 'assets/images/dialog/walking.png',
                        imageTag: '산책',
                        title: '자연 속 산책',
                        shortDescription: '자연 속으로 나가 신선한 공기를 마시며 걷는 것은 마음과 몸에 상쾌한 영향을 주어요.',
                        longDescription: '자연 속에서 걷는 것은 기분 전환에 좋고, 신체 활동은 스트레스 호르몬을 줄이는 데 도움이 됩니다. 규칙적인 산책은 전반적인 건강 증진에도 기여합니다.',
                        buttonText: '활동 시작하기',
                        onStartActivity: () {
                          Navigator.pop(context);
                          _showSnackBar('산책 활동을 시작합니다!');
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 8),
                  _buildActivityCard(
                    'assets/images/dialog/sitting.png',
                    '창 밖의 풍경 감상',
                    '창가에 앉아 밖의 풍경을 바라보며 마음을 편하게 해보세요.',
                    onTap: () {
                      _showActivityDetailModal(
                        imagePath: 'assets/images/dialog/sitting.png',
                        imageTag: '휴식',
                        title: 'assets/images/dialog/sitting.png',
                        shortDescription: '창가에 앉아 밖의 풍경을 바라보며 마음을 편하게 해보세요.',
                        longDescription: '아름다운 풍경을 보는 것은 마음을 평온하게 하고 스트레스를 줄이는 데 도움을 줍니다. 잠시 일상에서 벗어나 자연의 아름다움에 집중하며 긍정적인 에너지를 충전해보세요.',
                        buttonText: '활동 시작하기',
                        onStartActivity: () {
                          Navigator.pop(context);
                          _showSnackBar('풍경 감상 활동을 시작합니다!');
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildActivityCard(
                    'assets/images/dialog/music.png',
                    '평화로운 음악 감상',
                    '음악을 들으며 마음을 안정시키고 편안한 상태로 이어지는 시간을 즐겨 보아요.',
                    onTap: () {
                      _showActivityDetailModal(
                        imagePath: 'assets/images/dialog/music.png',
                        imageTag: '풍경 감상',
                        title: '아름다운 풍경 감상',
                        shortDescription: '음악을 들으며 마음을 안정시키고 편안한 상태로 이어지는 시간을 즐겨 보아요.',
                        longDescription: '음악은 정서적 안정과 스트레스 감소에 효과적인 도구입니다. 차분한 음악은 긴장을 완화하고, 활기찬 음악은 기분을 북돋아 줄 수 있습니다. 나만의 플레이리스트를 만들어보세요.',
                        buttonText: '활동 시작하기',
                        onStartActivity: () {
                          Navigator.pop(context);
                          _showSnackBar('음악 감상 활동을 시작합니다!');
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 42),
          ],
        ),
      ),
    );
  }

  Widget _buildInsightsAndRecommendationsTab() {
    if (_isLoadingInsights) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.main600),
            ),
            const SizedBox(height: 20),
            Text(
              '인사이트를 생성 중입니다...',
              style: AppTypography.b2.withColor(AppColors.grey600),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 실제 데이터에서 가져온 태그들 또는 기본 태그들
                Center(
                  child: Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    alignment: WrapAlignment.center,
                    children: _getActualInsightTags().map((tag) => _buildTag(tag)).toList(),
                  ),
                ),
                const SizedBox(height: 16),

                // 맞춤형 조언 섹션
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.grey50,
                    borderRadius: BorderRadius.circular(12)
                  ),

                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          SvgPicture.asset(
                            'assets/icons/sentiment/advice.svg',
                            width: 24,
                            height: 24,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            '$_userName님을 위한 조언',
                            style: AppTypography.s2.withColor(AppColors.grey900)
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _personalizedAdvice,
                        style: TextStyle(
                          fontFamily: AppTypography.fontFamily,
                          fontSize: 14,
                          color: AppColors.grey900,
                          fontWeight: FontWeight.w400,
                          height: 20/14,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // 대화 요약 - 실제 데이터 사용
                Text(
                  '대화 요약',
                  style: AppTypography.s2.withColor(AppColors.grey900),
                ),
                const SizedBox(height: 12),

                _buildSummaryItem(
                  '주요 주제',
                  _actualKeyTopics.isNotEmpty ? _actualKeyTopics : '대화에서 논의된 주요 주제들'
                ),
                Container(
                  margin: EdgeInsets.symmetric(vertical: 12),
                  color: AppColors.grey200,
                  height: 0.5,
                ),
                _buildSummaryItem(
                  '$_userName님의 감정',
                  _actualOverallMood.isNotEmpty ? _getMoodLabel(_actualOverallMood) : _mainSentiment
                ),
                Container(
                  margin: EdgeInsets.symmetric(vertical: 12),
                  color: AppColors.grey200,
                  height: 0.5,
                ),
                _buildSummaryItem(
                  '통찰',
                  _insights
                ),
                Container(
                  margin: EdgeInsets.symmetric(vertical: 12),
                  color: AppColors.grey200,
                  height: 0.5,
                ),
                _buildSummaryItem(
                  '조언',
                  _personalizedAdvice
                ),
                const SizedBox(height: 90),
              ],
            ),
          ),
        ),

        // 하단 고정 버튼
        Container(
          margin: const EdgeInsets.fromLTRB(20, 0, 20, 20), // 주변 여백
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const FullConversationHistoryPage(),
                ),
              );
            },
            child: Container(
              width: double.infinity,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.main700,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  '전체 대화 리포트 보러가기',
                  style: AppTypography.s2.withColor(Colors.white),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value, {String? iconPath, bool showProgress = false}) {
    return Row(
      children: [
        Text(
          label,
          style: AppTypography.b1.withColor(AppColors.grey900),
        ),
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (showProgress) ...[
                Text(
                  value,
                  style: AppTypography.c2.withColor(AppColors.main700),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 134,
                  child: LinearProgressIndicator(
                    value: _averageSentimentScore / 100,
                    backgroundColor: AppColors.grey200,
                    color: AppColors.main700,
                    minHeight: 12,
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ] else ...[
                if (iconPath != null) ...[
                  SvgPicture.asset(
                    iconPath,
                    width: 24,
                    height: 24,
                  ),
                  const SizedBox(width: 10),
                ],
                Text(
                  value,
                  style: AppTypography.b2.withColor(AppColors.grey400),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActivityCard(String imagePath, String title, String shortDescription, {String? description, VoidCallback? onTap}) {

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.grey50,
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Color(0xFF131927).withOpacity(0.08),
                        blurRadius: 8,
                        spreadRadius: -4,
                        offset: Offset(2, 8),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8), // 패딩을 줄여서 이미지를 더 크게
                    child: Image.asset(
                      imagePath,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),

                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: AppTypography.b4.withColor(AppColors.grey900),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        shortDescription,
                        style: AppTypography.c1.withColor(AppColors.grey700),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                SvgPicture.asset(
                  'assets/icons/functions/more.svg',
                  width: 24,
                  height: 24,
                  colorFilter: ColorFilter.mode(
                    AppColors.grey700,
                    BlendMode.srcIn
                  ),
                )
              ],
            ),
            if (description != null) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                child: Text(
                  description,
                  style: AppTypography.c1.withColor(AppColors.grey700),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}