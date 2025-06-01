import 'package:flutter/material.dart';
import 'package:tiiun/design_system/colors.dart';
import 'package:tiiun/design_system/typography.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tiiun/services/conversation_service.dart';
import 'package:tiiun/models/conversation_model.dart';
import 'package:tiiun/services/sentiment_analysis_service.dart';
import 'package:tiiun/services/conversation_insights_service.dart';
import 'package:tiiun/services/mood_service.dart';
import 'package:tiiun/services/auth_service.dart';
import 'package:tiiun/models/mood_record_model.dart';
import 'package:tiiun/models/conversation_insight_model.dart';
import 'package:tiiun/models/sentiment_analysis_result_model.dart';
import 'package:tiiun/utils/error_handler.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tiiun/pages/home_chatting/full_conversation_history_page.dart';
import 'package:tiiun/pages/home_chatting/activity_detail_page.dart';

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
      final authService = ref.read(authServiceProvider);
      final moodService = ref.read(moodServiceProvider);

      final userId = authService.getCurrentUserId();
      if (userId != null) {
        final userModel = await authService.getUserModel(userId);
        final moodRecords = await moodService.getMoodRecordsByPeriod(7);

        if (mounted) {
          setState(() {
            _userName = userModel.userName;
            _recentMoodRecords = moodRecords;
          });
        }
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
      final conversationService = ref.read(conversationServiceProvider);
      final conversationInsightsService = ref.read(conversationInsightsServiceProvider);
      final authService = ref.read(authServiceProvider);

      final messages = await conversationService.getConversationMessages(widget.conversationId).first;
      final userId = authService.getCurrentUserId();

      if (messages.isNotEmpty && userId != null) {
        final userModel = await authService.getUserModel(userId);
        final userProfile = {
          'ageGroup': userModel.ageGroup,
          'gender': userModel.gender,
          'preferredActivities': userModel.preferredActivities,
        };

        // 인사이트가 이미 존재하지 않으면 새로 생성
        if (_conversationInsights.isEmpty) {
          await conversationInsightsService.generateAndSaveConversationInsight(
            conversationId: widget.conversationId,
            userId: userId,
            messages: messages,
          );
          await _loadActualFireStoreData(); // 새로 생성된 데이터 로드
        }

        final personalizedAdviceResult =
            await conversationInsightsService.generatePersonalizedAdvice(messages, userProfile: userProfile);

        if (mounted) {
          setState(() {
            _isLoadingInsights = false;
            _personalizedAdvice = personalizedAdviceResult['advice'] as String? ?? '조언을 생성할 수 없습니다.';
            _exercises = List<String>.from(personalizedAdviceResult['exercises'] ?? []);
            _resources = List<String>.from(personalizedAdviceResult['resources'] ?? []);
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _isLoadingInsights = false;
            _personalizedAdvice = '대화 내용이 없어 조언을 생성할 수 없습니다.';
          });
        }
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
      width: 90,
      height: 30,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.main100.withOpacity(0.8),
            AppColors.main200.withOpacity(0.6),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.main300.withOpacity(0.5),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.main200.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Text(
          text,
          style: AppTypography.c1.withColor(Colors.black).copyWith(
                fontWeight: FontWeight.w600,
              ),
          textAlign: TextAlign.center,
        ),
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
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 16.0),
                        child: Text(
                          '대화 분석석',
                          style: AppTypography.h4.withColor(AppColors.grey900),
                        ),
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
              labelColor: AppColors.main700,
              unselectedLabelColor: AppColors.grey500,
              indicatorColor: AppColors.main700,
              labelStyle: AppTypography.s2,
              unselectedLabelStyle: AppTypography.s2,
              indicatorSize: TabBarIndicatorSize.tab,
              indicatorWeight: 3,
              tabs: const [
                Tab(text: '감정 분석'),
                Tab(text: '대화 인사이트'),
              ],
            ),
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
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 감정 정보 컨테이너 (여기는 이미 올바른 코드입니다)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.grey50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  _buildInfoRow(
                    '평균 감정 점수',
                    '${_averageSentimentScore.toStringAsFixed(1)}%',
                    showProgress: true,
                  ),
                  const SizedBox(height: 16),
                  _buildInfoRow(
                    '주요 감정',
                    _mainSentiment,
                    iconPath: _getMoodIconPath(_mainSentiment),
                  ),
                  const SizedBox(height: 16),
                  _buildInfoRow(
                    '감정 변화',
                    _sentimentChange,
                    iconPath: _getMoodIconPath(_sentimentChange),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 추천 활동 섹션 (여기도 이미 올바른 코드입니다)
            Text(
              '$_userName님을 위한 추천 활동',
              style: AppTypography.s1.withColor(AppColors.grey900),
            ),
            const SizedBox(height: 16),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _buildActivityCard(
                    'assets/icons/functions/meditation.png', // 명상 이미지
                    '명상을 통한 스트레스 해소',
                    '마음을 집중하고 깊은 호흡을 통해 스트레스를 해소하는 명상을 시도해보세요!',
                    onTap: () {
                      _showActivityDetailModal(
                        imagePath: 'assets/icons/functions/meditation.png',
                        imageTag: '명상',
                        title: '명상을 통한 스트레스 해소',
                        shortDescription: '마음을 집중하고 깊은 호흡을 통해 스트레스를 해소하는 명상을 시도해보세요!',
                        longDescription: '외부 환경에서 오는 스트레스를 해소하는 데 도움이 되고, 마음의 안정과 집중력을 높여 일상에서의 긍정 조절 능력을 향상시키는 데 효과적이에요.',
                        buttonText: '활동 시작하기',
                        onStartActivity: () {
                          Navigator.pop(context); // Close the modal
                          _showSnackBar('명상 활동을 시작합니다!');
                          // Add actual navigation to the meditation activity here
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildActivityCard(
                    'assets/icons/functions/nature_walk.png', // 산책 이미지
                    '가벼운 운동 (산책)',
                    '가까운 공원이나 주변을 가볍게 산책하며 몸과 마음을 환기시켜 보세요.',
                    onTap: () {
                      _showActivityDetailModal(
                        imagePath: 'assets/icons/functions/nature_walk.png',
                        imageTag: '산책',
                        title: '가벼운 운동 (산책)',
                        shortDescription: '가까운 공원이나 주변을 가볍게 산책하며 몸과 마음을 환기시켜 보세요.',
                        longDescription: '자연 속에서 걷는 것은 기분 전환에 좋고, 신체 활동은 스트레스 호르몬을 줄이는 데 도움이 됩니다. 규칙적인 산책은 전반적인 건강 증진에도 기여합니다.',
                        buttonText: '활동 시작하기',
                        onStartActivity: () {
                          Navigator.pop(context); // Close the modal
                          _showSnackBar('산책 활동을 시작합니다!');
                          // Add actual navigation to the nature walk activity here
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildActivityCard(
                    'assets/icons/functions/music.png', // 음악 이미지
                    '음악으로 마음의 휴식 찾기',
                    '좋아하는 음악을 들으며 편안함을 느끼고 스트레스를 해소해 보세요.',
                    onTap: () {
                      _showActivityDetailModal(
                        imagePath: 'assets/icons/functions/music.png',
                        imageTag: '음악 감상',
                        title: '음악으로 마음의 휴식 찾기',
                        shortDescription: '좋아하는 음악을 들으며 편안함을 느끼고 스트레스를 해소해 보세요.',
                        longDescription: '음악은 정서적 안정과 스트레스 감소에 효과적인 도구입니다. 차분한 음악은 긴장을 완화하고, 활기찬 음악은 기분을 북돋아 줄 수 있습니다. 나만의 플레이리스트를 만들어보세요.',
                        buttonText: '활동 시작하기',
                        onStartActivity: () {
                          Navigator.pop(context); // Close the modal
                          _showSnackBar('음악 감상 활동을 시작합니다!');
                          // Add actual navigation to the music activity here
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildActivityCard(
                    'assets/icons/functions/view_point.png', // 전망 이미지
                    '아름다운 풍경 감상',
                    '창밖 풍경을 보거나 자연 속에서 새로운 시각을 얻어보세요.',
                    onTap: () {
                      _showActivityDetailModal(
                        imagePath: 'assets/icons/functions/view_point.png',
                        imageTag: '풍경 감상',
                        title: '아름다운 풍경 감상',
                        shortDescription: '창밖 풍경을 보거나 자연 속에서 새로운 시각을 얻어보세요.',
                        longDescription: '아름다운 풍경을 보는 것은 마음을 평온하게 하고 스트레스를 줄이는 데 도움을 줍니다. 잠시 일상에서 벗어나 자연의 아름다움에 집중하며 긍정적인 에너지를 충전해보세요.',
                        buttonText: '활동 시작하기',
                        onStartActivity: () {
                          Navigator.pop(context); // Close the modal
                          _showSnackBar('풍경 감상 활동을 시작합니다!');
                          // Add actual navigation to the view point activity here
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
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
                    spacing: 8.0,
                    runSpacing: 8.0,
                    alignment: WrapAlignment.center,
                    children: _getActualInsightTags().map((tag) => _buildTag(tag)).toList(),
                  ),
                ),
                const SizedBox(height: 24),

                // 맞춤형 조언 섹션
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.main100.withOpacity(0.8),
                        AppColors.main100.withOpacity(0.4),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.main200.withOpacity(0.6),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: SvgPicture.asset(
                              'assets/icons/functions/lightbulb.svg',
                              width: 16,
                              height: 16,
                              
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            '$_userName님을 위한 조언',
                            style: AppTypography.s1.withColor(AppColors.grey900).copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _personalizedAdvice,
                          style: AppTypography.b3.withColor(AppColors.grey700).copyWith(height: 1.4),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // 대화 요약 - 실제 데이터 사용
                Text(
                  '대화 요약',
                  style: AppTypography.s1.withColor(AppColors.grey900),
                ),
                const SizedBox(height: 16),

                _buildSummaryItem(
                  '주요 주제', 
                  _actualKeyTopics.isNotEmpty ? _actualKeyTopics : '대화에서 논의된 주요 주제들'
                ),
                const SizedBox(height: 12),
                Divider(color: AppColors.grey200, height: 1),
                const SizedBox(height: 12),
                _buildSummaryItem(
                  '$_userName님의 감정', 
                  _actualOverallMood.isNotEmpty ? _getMoodLabel(_actualOverallMood) : _mainSentiment
                ),
                const SizedBox(height: 12),
                Divider(color: AppColors.grey200, height: 1),
                const SizedBox(height: 12),
                _buildSummaryItem(
                  '통찰', 
                  _insights
                ),
                const SizedBox(height: 12),
                Divider(color: AppColors.grey200, height: 1),
                const SizedBox(height: 12),
                _buildSummaryItem(
                  '조언', 
                  _personalizedAdvice
                ),
                const SizedBox(height: 60),
              ],
            ),
          ),
        ),

        // 하단 고정 버튼
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          decoration: const BoxDecoration(
            color: Colors.transparent,
          ),
          child: Container(
            width: double.infinity,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.main600.withOpacity(0.92),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: AppColors.main600.withOpacity(0.25),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const FullConversationHistoryPage()),
                  );
                },
                child: Center(
                  child: Text(
                    '전체 대화 보고서 보러가기',
                    style: AppTypography.b2.withColor(Colors.white).copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
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
          style: AppTypography.b4.withColor(AppColors.grey600),
        ),
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (showProgress) ...[
                Text(
                  value,
                  style: AppTypography.b2.withColor(AppColors.main600),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  width: 100,
                  child: LinearProgressIndicator(
                    value: _averageSentimentScore / 100,
                    backgroundColor: AppColors.grey200,
                    color: AppColors.main500,
                    minHeight: 6,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ] else ...[
                if (iconPath != null) ...[
                  SvgPicture.asset(
                    iconPath,
                    width: 16,
                    height: 16,
                    colorFilter: ColorFilter.mode(AppColors.grey500, BlendMode.srcIn),
                  ),
                  const SizedBox(width: 8),
                ],
                Text(
                  value,
                  style: AppTypography.b2.withColor(AppColors.grey900),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActivityCard(String imagePath, String title, String shortDescription, {String? description, VoidCallback? onTap}) {
    final bool isSvg = imagePath.toLowerCase().endsWith('.svg');

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.grey50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.grey200,
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 242, 247, 247),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: isSvg
                          ? SvgPicture.asset(
                              imagePath,
                              width: 30,
                              height: 30,
                              fit: BoxFit.contain,
                              colorFilter: const ColorFilter.mode(AppColors.main600, BlendMode.srcIn),
                            )
                          : Image.asset(
                              imagePath,
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                            ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: AppTypography.s2.withColor(AppColors.grey900),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        shortDescription,
                        style: AppTypography.b4.withColor(AppColors.grey600),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (description != null) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  description,
                  style: AppTypography.c1.withColor(AppColors.grey600).copyWith(height: 1.3),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}