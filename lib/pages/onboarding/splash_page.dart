import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:tiiun/design_system/colors.dart';
import 'package:tiiun/design_system/typography.dart';
import 'package:flutter_svg/flutter_svg.dart';


class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthAndNavigate();
  }

  Future<void> _checkAuthAndNavigate() async {
    try {
      await Future.delayed(const Duration(seconds: 3));

      User? currentUser = FirebaseAuth.instance.currentUser;
      print('🔍 Current user in splash: ${currentUser?.email ?? "null"}');

      if (currentUser != null) {
        print('🔍 Going to home');
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        print('🔍 Going to onboarding');
        Navigator.pushReplacementNamed(context, '/onboarding');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        // 그라데이션 배경
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [
              Color(0xFFFFFFFF),
              Color(0xFFEBEDEA),
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                'assets/images/tiiun_logo.svg',
                width: 70.21,
                height: 35.26,
              ), // 로고
              const SizedBox(height: 18.74),
              SvgPicture.asset(
                'assets/images/tiiun_buddy_logo.svg',
                width: 149,
                height: 29,
              ),
            ],
          ),
        ),
      ),
    );
  }
}