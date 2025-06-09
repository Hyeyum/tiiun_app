// 새 폴더/lib/main.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:tiiun/firebase_options.dart';
import 'package:tiiun/pages/home_chatting/home_page.dart';
import 'package:tiiun/pages/onboarding/login_page.dart';
import 'package:tiiun/design_system/colors.dart';
import 'package:tiiun/design_system/typography.dart';
import 'package:tiiun/pages/onboarding/onboarding_page.dart';
import 'package:tiiun/pages/onboarding/splash_page.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tiiun/services/api_client.dart';
import 'package:tiiun/utils/logger.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // 백엔드 통신을 위한 API 클라이언트 초기화
  ApiClient().initialize();
  AppLogger.info('✅ API 클라이언트가 성공적으로 초기화되었습니다.');

  // 더 나은 오류 처리로 Firebase Remote Config 초기화
  try {
    final remoteConfig = FirebaseRemoteConfig.instance;
    await remoteConfig.setConfigSettings(RemoteConfigSettings(
      fetchTimeout: const Duration(minutes: 1),
      minimumFetchInterval: const Duration(hours: 1), // 프로덕션용으로 조정
    ));
    // 가져오기 실패 또는 값이 설정되지 않은 경우 API 키에 대한 기본값 설정
    await remoteConfig.setDefaults({
      'openai_api_key': '', // 빈 기본값, 장치 음성 인식으로 폴백됨
    });

    // 오류 처리와 함께 값 가져오기 및 활성화
    await remoteConfig.fetchAndActivate();

    final apiKey = remoteConfig.getString('openai_api_key');
    if (apiKey.isNotEmpty) {
      AppLogger.info('✅ OpenAI API 키가 Remote Config에서 성공적으로 로드되었습니다.');
    } else {
      AppLogger.warning('⚠️ OpenAI API 키가 Remote Config에서 발견되지 않았습니다 - 장치 음성 인식을 사용합니다.');
    }
  } catch (e) {
    AppLogger.error('❌ Remote Config 초기화 실패: $e');
    AppLogger.info('🔄 앱이 폴백으로 장치 음성 인식을 사용합니다.');
  }

  // Firebase Auth 완전 초기화 - 자동로그인 끄는 코드 (의도하지 않았다면 주석 처리 상태 유지)
  // await FirebaseAuth.instance.signOut();
  // print('앱 시작 시 Firebase Auth 재설정됨');

  runApp(const ProviderScope(child: TiiunApp()));
}

class TiiunApp extends StatelessWidget {
  const TiiunApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tiiun',
      theme: ThemeData(
        fontFamily: AppTypography.fontFamily,
      ),
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
      routes: {
        '/onboarding': (context) => const OnboardingPage(),
        '/login': (context) => const LoginPage(),
        '/home': (context) => const HomePage(),
      },
    );
  }
}