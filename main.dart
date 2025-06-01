import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart'; // Import Remote Config
import 'package:tiiun/firebase_options.dart';
import 'package:tiiun/pages/home_chatting/home_page.dart';
import 'package:tiiun/pages/onboarding/login_page.dart';
import 'package:tiiun/design_system/colors.dart';
import 'package:tiiun/design_system/typography.dart';
import 'package:tiiun/pages/onboarding/onboarding_page.dart';
import 'package:tiiun/pages/onboarding/splash_page.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Import for ProviderScope

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialize Firebase Remote Config with better error handling
  try {
    final remoteConfig = FirebaseRemoteConfig.instance;
    await remoteConfig.setConfigSettings(RemoteConfigSettings(
      fetchTimeout: const Duration(minutes: 1),
      minimumFetchInterval: const Duration(hours: 1), // Adjust for production
    ));
    // Set default value for the API key in case fetch fails or value is not set
    await remoteConfig.setDefaults({
      'openai_api_key': '', // Empty default, will fallback to device speech recognition
    });
    
    // Fetch and activate values with error handling
    await remoteConfig.fetchAndActivate();
    
    final apiKey = remoteConfig.getString('openai_api_key');
    if (apiKey.isNotEmpty) {
      print('✅ OpenAI API Key loaded successfully from Remote Config');
    } else {
      print('⚠️ OpenAI API Key not found in Remote Config - using device speech recognition');
    }
  } catch (e) {
    print('❌ Remote Config initialization failed: $e');
    print('🔄 App will use device speech recognition as fallback');
  }

  // Firebase Auth 완전 초기화 - 자동로그인 끄는 코드
  // await FirebaseAuth.instance.signOut();
  // print('Firebase Auth reset at app start');

  runApp(const ProviderScope(child: TiiunApp())); // Wrap with ProviderScope
}

class TiiunApp extends StatelessWidget {
  const TiiunApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tiiun',
      theme: ThemeData(
        // Pretendard 폰트를 기본 폰트로 설정
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