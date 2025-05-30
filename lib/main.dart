import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:tiiun/firebase_options.dart';
import 'package:tiiun/pages/home_chatting/home_page.dart';
import 'package:tiiun/pages/onboarding/login_page.dart';
import 'package:tiiun/design_system/colors.dart';
import 'package:tiiun/design_system/typography.dart';
import 'package:tiiun/pages/onboarding/onboarding_page.dart';
import 'package:tiiun/pages/onboarding/splash_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Firebase Auth 완전 초기화 - 자동로그인 끄는 코드
  // await FirebaseAuth.instance.signOut();
  // print('Firebase Auth reset at app start');

  runApp(const TiiunApp());
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