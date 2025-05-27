import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../screens/chat_conversation_screen.dart';
import '../screens/plant/plant_list_screen.dart';
import '../screens/token_shop_screen.dart';
import '../screens/tips_screen.dart';
import '../utils/constants.dart';
import '../services/local_storage_service.dart';
import '../services/plant_service.dart';
import '../routes.dart' as routes;
import 'package:uuid/uuid.dart';

class MainTabScreen extends StatefulWidget {
  const MainTabScreen({super.key});

  @override
  State<MainTabScreen> createState() => _MainTabScreenState();
}

class _MainTabScreenState extends State<MainTabScreen> with TickerProviderStateMixin, WidgetsBindingObserver {
  late TabController _tabController;
  final User? _currentUser = FirebaseAuth.instance.currentUser;
  final Uuid _uuid = const Uuid();
  final PlantService _plantService = PlantService.instance;
  final TextEditingController _chatController = TextEditingController();
  
  int _currentIndex = 0; // 홈이 첫 번째 탭이 되도록
  bool _hasRegisteredPlant = false;
  bool _isCheckingPlants = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        setState(() {
          _currentIndex = _tabController.index;
        });
      }
    });
    _checkPlantRegistration();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _tabController.dispose();
    _chatController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      _checkPlantRegistration();
    }
  }

  Future<void> _checkPlantRegistration() async {
    if (_currentUser?.uid == null) {
      setState(() {
        _hasRegisteredPlant = false;
        _isCheckingPlants = false;
      });
      return;
    }

    try {
      final hasPlantInStorage = LocalStorageService.instance.getBool('has_registered_plant') ?? false;
      final plants = await _plantService.getUserPlants(_currentUser!.uid);
      final hasActualPlants = plants.isNotEmpty;
      final hasPlant = hasPlantInStorage || hasActualPlants;
      
      if (hasActualPlants && !hasPlantInStorage) {
        await LocalStorageService.instance.setBool('has_registered_plant', true);
      } else if (!hasActualPlants && hasPlantInStorage) {
        await LocalStorageService.instance.setBool('has_registered_plant', false);
      }
      
      setState(() {
        _hasRegisteredPlant = hasPlant;
        _isCheckingPlants = false;
      });
    } catch (e) {
      print('식물 상태 확인 중 오류: $e');
      setState(() {
        _hasRegisteredPlant = false;
        _isCheckingPlants = false;
      });
    }
  }

  void _navigateToPlantRegistration() {
    if (_currentUser?.uid != null) {
      Navigator.pushNamed(
        context,
        routes.AppRoutes.addPlant,
        arguments: {'userId': _currentUser!.uid, 'isFirstPlant': true},
      ).then((result) {
        if (result == true) {
          _checkPlantRegistration();
        }
      });
    }
  }

  void _sendMessage() {
    if (_chatController.text.trim().isNotEmpty) {
      final newConversationId = _uuid.v4();
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChatConversationScreen(
            conversationId: newConversationId,
            title: '틔운이와 채팅',
            initialMessage: _chatController.text.trim(),
          ),
        ),
      );
      _chatController.clear();
    }
  }

  void _handleQuickAction(String action) {
    final newConversationId = _uuid.v4();
    String initialMessage = '';
    
    switch (action) {
      case '이전 대화':
        Navigator.pushNamed(context, '/conversation-list');
        return;
      case '자랑거리':
        initialMessage = '오늘 있었던 자랑하고 싶은 일이 있어요';
        break;
      case '고민거리':
        initialMessage = '고민이 있어서 상담받고 싶어요';
        break;
      case '위로가 필요해':
        initialMessage = '힘든 일이 있어서 위로받고 싶어요';
        break;
    }
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatConversationScreen(
          conversationId: newConversationId,
          title: '틔운이와 채팅',
          initialMessage: initialMessage,
        ),
      ),
    );
  }

  Widget _buildEmotionTab() {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // 헤더 - 감성 상태 영역
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.purple.shade400,
                      Colors.blue.shade600,
                    ],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.sentiment_satisfied,
                          color: Colors.white,
                          size: 32,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '오늘의 감성',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                '틔운과 함께하는 감성 케어',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white.withOpacity(0.9),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // 감성 상태 아이콘
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '😊',
                            style: TextStyle(fontSize: 24),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    
                    // 감성 지표 표시
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildEmotionIndicator('기분', '좋음', Colors.yellow.shade300),
                              _buildEmotionIndicator('에너지', '보통', Colors.orange.shade300),
                              _buildEmotionIndicator('스트레스', '낮음', Colors.green.shade300),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // 틔운과 대화하기 섹션
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '틔운과 감성 대화',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: Card(
                            elevation: 3,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            child: InkWell(
                              onTap: _navigateToChatConversation,
                              borderRadius: BorderRadius.circular(12),
                              child: Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.chat_bubble_outline, size: 48, color: Colors.purple.shade600),
                                    const SizedBox(height: 12),
                                    Text(
                                      '채팅으로 대화',
                                      textAlign: TextAlign.center,
                                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '마음속 이야기 나누기',
                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Card(
                            elevation: 3,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            child: InkWell(
                              onTap: _navigateToVoiceConversation,
                              borderRadius: BorderRadius.circular(12),
                              child: Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.mic_none_outlined, size: 48, color: Colors.blue.shade600),
                                    const SizedBox(height: 12),
                                    Text(
                                      '음성으로 대화',
                                      textAlign: TextAlign.center,
                                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '목소리로 감정 표현',
                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // 감성 분석 카드
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Icon(Icons.analytics, color: Colors.indigo.shade600, size: 32),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '감성 분석 리포트',
                                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.indigo.shade700,
                                    ),
                                  ),
                                  Text(
                                    '최근 7일간의 감성 변화 분석',
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/mood-tracking');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.indigo.shade600,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text('감성 리포트 보기'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // 빠른 감정 체크인
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '빠른 감정 체크인',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildEmotionButton('😄', '기쁨', Colors.yellow),
                        _buildEmotionButton('😌', '평온', Colors.green),
                        _buildEmotionButton('😔', '우울', Colors.blue),
                        _buildEmotionButton('😤', '짜증', Colors.red),
                        _buildEmotionButton('😰', '불안', Colors.orange),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmotionIndicator(String label, String value, Color color) {
    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
          child: Icon(
            _getEmotionIcon(label),
            color: Colors.white,
            size: 20,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  IconData _getEmotionIcon(String label) {
    switch (label) {
      case '기분':
        return Icons.sentiment_satisfied;
      case '에너지':
        return Icons.battery_charging_full;
      case '스트레스':
        return Icons.spa;
      default:
        return Icons.favorite;
    }
  }

  Widget _buildEmotionButton(String emoji, String label, Color color) {
    return GestureDetector(
      onTap: () {
        // 감정 기록 로직
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$label 감정이 기록되었습니다')),
        );
      },
      child: Column(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(25),
              border: Border.all(color: color.withOpacity(0.3)),
            ),
            child: Center(
              child: Text(
                emoji,
                style: const TextStyle(fontSize: 24),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlantTab() {
    if (_isCheckingPlants) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (!_hasRegisteredPlant) {
      return Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height - 
                           MediaQuery.of(context).padding.top - 
                           MediaQuery.of(context).padding.bottom - 48,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 40),
                  Icon(
                    Icons.local_florist,
                    size: 80,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    '첫 번째 식물을 등록해보세요!',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '식물을 등록하면 성장 일지를 작성하고\nAI와 대화하며 관리할 수 있어요',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton.icon(
                    onPressed: _navigateToPlantRegistration,
                    icon: const Icon(Icons.add),
                    label: const Text('첫 식물 등록하기'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade600,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return PlantListScreen(userId: _currentUser?.uid ?? '');
  }

  // 이 파일은 새로운 홈 탭과 헬퍼 메서드들을 포함합니다
// main_tab_screen.dart에 붙여넣기 하세요

  Widget _buildHomeTab() {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // 상단 영역 - 알림 아이콘
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const SizedBox(width: 40), // 왼쪽 여백
                    const Spacer(),
                    IconButton(
                      icon: Icon(
                        Icons.notifications_outlined,
                        color: Colors.grey.shade700,
                        size: 28,
                      ),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('알림 기능은 곧 추가될 예정입니다')),
                        );
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // 메인 비주얼 - 중앙 식물 아이콘
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.green.shade100,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.eco,
                  size: 60,
                  color: Colors.green.shade600,
                ),
              ),

              const SizedBox(height: 40),

              // 입력 필드
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(color: const Color(0xFF00C853)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _chatController,
                          decoration: const InputDecoration(
                            hintText: '무엇이든 이야기하세요',
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                          ),
                          onSubmitted: (value) => _sendMessage(),
                        ),
                      ),
                      IconButton(
                        onPressed: _sendMessage,
                        icon: const Icon(
                          Icons.send,
                          color: Color(0xFF00C853),
                          size: 24,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 35),

              // 빠른 기능 버튼들
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildQuickActionButton('이전 대화', Icons.history),
                    _buildQuickActionButton('자랑거리', Icons.celebration),
                    _buildQuickActionButton('고민거리', Icons.help_outline),
                    _buildQuickActionButton('위로가 필요해', Icons.favorite_border),
                  ],
                ),
              ),

              const SizedBox(height: 45),

              // 환경 정보 카드
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Icon(Icons.thermostat, color: Colors.orange.shade600, size: 24),
                            const SizedBox(width: 12),
                            Text(
                              '적정 온도',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey.shade800,
                              ),
                            ),
                            const Spacer(),
                            Icon(Icons.check_circle, color: Colors.green.shade600, size: 20),
                            const SizedBox(width: 8),
                            Icon(Icons.arrow_forward_ios, color: Colors.grey.shade400, size: 16),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Icon(Icons.wb_sunny, color: Colors.yellow.shade600, size: 24),
                            const SizedBox(width: 12),
                            Text(
                              '조명 밝기 낮음',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey.shade800,
                              ),
                            ),
                            const Spacer(),
                            Icon(Icons.warning, color: Colors.orange.shade600, size: 20),
                            const SizedBox(width: 8),
                            Icon(Icons.arrow_forward_ios, color: Colors.grey.shade400, size: 16),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // 콘텐츠 섹션 - 겨울철 식물 관리 팁
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          '겨울철 식물 관리 팁',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '🌨️',
                          style: TextStyle(fontSize: 20),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildTipCard(
                            '겨울철 물주기, 깍지벌레 관리 팁',
                            'https://via.placeholder.com/150x100/4CAF50/FFFFFF?text=Plant1',
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildTipCard(
                            '겨울 걱정 NO! 겨울철 식물 이사 고민 줄여요',
                            'https://via.placeholder.com/150x100/8BC34A/FFFFFF?text=Plant2',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActionButton(String title, IconData icon) {
    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: IconButton(
            onPressed: () => _handleQuickAction(title),
            icon: Icon(
              icon,
              color: Colors.grey.shade400,
              size: 24,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade400,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildTipCard(String title, String imageUrl) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            height: 100,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              gradient: LinearGradient(
                colors: [Colors.green.shade300, Colors.green.shade500],
              ),
            ),
            child: Icon(
              Icons.local_florist,
              color: Colors.white,
              size: 40,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Text(
              title,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade800,
                height: 1.3,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }


  void _navigateToChatConversation() {
    final newConversationId = _uuid.v4();
    Navigator.pushNamed(
      context,
      '/conversation/chat',
      arguments: {
        'conversationId': newConversationId,
        'title': '틔운이와 채팅',
      },
    );
  }

  void _navigateToVoiceConversation() {
    final newConversationId = _uuid.v4();
    Navigator.pushNamed(
      context,
      '/conversation/voice',
      arguments: {
        'conversationId': newConversationId,
        'title': '틔운이와 음성대화',
      },
    );
  }

  Widget _buildQuickActionCard(String title, IconData icon, Color bgColor, Color iconColor, VoidCallback onTap) {
    return Card(
      elevation: 2,
      color: bgColor,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(icon, color: iconColor, size: 32),
              const SizedBox(height: 8),
              Text(
                title,
                style: TextStyle(
                  color: iconColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoTab() {
    return const TipsScreen();
  }

  Widget _buildMyTab() {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // 상단 메뉴
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.purple.shade400, Colors.purple.shade600],
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: Colors.white,
                          child: Icon(
                            Icons.person,
                            size: 36,
                            color: Colors.purple.shade600,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _currentUser?.displayName ?? '사용자',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                'LG 틔운 사용자',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.9),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    
                    // 상단 메뉴 버튼들
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildTopMenuButton('재화', Icons.monetization_on, () {}),
                        _buildTopMenuButton('환경 설정', Icons.settings, () {}),
                        _buildTopMenuButton('내 프로필', Icons.person, () {}),
                      ],
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // 식물 구분 및 추가
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '내 버디 관리',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // 버디 카드들
                    Row(
                      children: [
                        Expanded(
                          child: _buildBedderCard('1번 버디', 2, true),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildBedderCard('2번 버디', 1, false),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // 새 버디 추가 버튼
                    Center(
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.grey.shade400,
                            style: BorderStyle.solid,
                            width: 2,
                          ),
                        ),
                        child: IconButton(
                          onPressed: () {
                            // 새 버디 추가
                          },
                          icon: Icon(
                            Icons.add,
                            size: 32,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    
                    // 마이데이터 섹션
                    Text(
                      '마이데이터',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    _buildMyDataItem('감정 리포트', Icons.sentiment_satisfied, () {}),
                    _buildMyDataItem('달성 뱃지', Icons.emoji_events, () {}),
                    _buildMyDataItem('성장 기록', Icons.trending_up, () {}),
                    _buildMyDataItem('재배 통계', Icons.bar_chart, () {}),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopMenuButton(String title, IconData icon, VoidCallback onTap) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: Colors.white, size: 24),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildBedderCard(String title, int plantCount, bool isActive) {
    return Card(
      elevation: 2,
      color: isActive ? Colors.green.shade50 : Colors.grey.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(
              Icons.eco,
              size: 32,
              color: isActive ? Colors.green.shade600 : Colors.grey.shade500,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isActive ? Colors.green.shade700 : Colors.grey.shade700,
              ),
            ),
            Text(
              '$plantCount개 식물',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMyDataItem(String title, IconData icon, VoidCallback onTap) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: Colors.purple.shade600),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }

  Widget _buildSensorIndicator(String label, String value, Color color) {
    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
          child: Icon(
            _getSensorIcon(label),
            color: Colors.white,
            size: 20,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  IconData _getSensorIcon(String label) {
    switch (label) {
      case '측정 온도':
        return Icons.thermostat;
      case '조명 밝기':
        return Icons.wb_sunny;
      case '조명 시간':
        return Icons.schedule;
      default:
        return Icons.sensors;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _currentIndex == 0 ? null : AppBar(
        title: Text(
          _getTabTitle(_currentIndex),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('알림 기능은 곧 추가될 예정입니다')),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () {
              Navigator.pushNamed(context, '/profile');
            },
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildHomeTab(),       // 홈 (0번째)
          _buildEmotionTab(),    // 감성 (1번째)
          _buildInfoTab(),       // 정보 (2번째)
          _buildMyTab(),         // My (3번째)
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
            _tabController.animateTo(index);
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined, size: 24),
            activeIcon: Icon(Icons.home, size: 24),
            label: '홈',
          ),
          BottomNavigationBarItem(
            icon: ImageIcon(AssetImage('assets/icons/buddy.png')),
            activeIcon: ImageIcon(AssetImage('assets/icons/filled_buddy.png')),
            label: '버디',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.info_outline, size: 24),
            activeIcon: Icon(Icons.info, size: 24),
            label: '정보',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline, size: 24),
            activeIcon: Icon(Icons.person, size: 24),
            label: 'My',
          ),
        ],
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Colors.grey.shade600,
      ),
    );
  }

  String _getTabTitle(int index) {
    switch (index) {
      case 0:
        return '홈';
      case 1:
        return '감성';
      case 2:
        return '정보';
      case 3:
        return 'My';
      default:
        return AppConstants.appName;
    }
  }
}
