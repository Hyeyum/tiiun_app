import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tiiun/design_system/colors.dart';
import 'package:tiiun/design_system/typography.dart';
import 'package:tiiun/pages/onboarding/lgsignin_page.dart';
import 'signup_page.dart';
import 'package:flutter_svg/flutter_svg.dart';


class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  @override
  void initState() {
    super.initState();
    _forceLogout();
  }

  Future<void> _forceLogout() async {
    try {
      await FirebaseAuth.instance.signOut();
      print('LoginPage: Force logout completed');
    } catch (e) {
      print('LoginPage logout error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              // 중앙 로고 영역 (자동 확장)
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // 로고
                    SvgPicture.asset(
                      'assets/images/logos/tiiun_logo.svg',
                      width: 70.21,
                      height: 35.26,
                    ),
                    const SizedBox(height: 19),
                    SvgPicture.asset(
                      'assets/images/logos/tiiun_buddy_logo.svg',
                      width: 148.32,
                      height: 27.98,
                    ),
                  ],
                ),
              ),

              // 소셜 로그인 버튼들 (하단 고정)
              Column(
                children: [
                  _buildSocialLoginButton(
                    'LG 계정 로그인',
                    'assets/images/logos/lg_logo.png',
                    Color(0xFF97282F),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => LGSigninPage()),
                      );
                    },
                  ),
                  const SizedBox(height: 10),
                  _buildSocialLoginButton(
                    'Google 계정으로 로그인',
                    'assets/images/logos/google_logo.png',
                    Color(0xFF477BDF),
                  ),
                  const SizedBox(height: 10),
                  _buildSocialLoginButton(
                    'Apple 계정으로 로그인',
                    'assets/images/logos/apple_logo.png',
                    Colors.black,
                  ),

                  const SizedBox(height: 24),

                  // 다른 계정으로 로그인
                  GestureDetector(
                    // onTap: _navigateToSignup,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '다른 계정으로 로그인',
                          style: AppTypography.mediumBtn.withColor(AppColors.grey400,),
                        ),
                        const SizedBox(width: 12),
                        Icon(
                          Icons.arrow_forward_ios_rounded,
                          color: AppColors.grey300,
                          size: 10,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 회원가입 페이지로 이동
  void _navigateToSignup() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SignupPage()),
    );
  }

  // HomePage로 이동
  void _navigateToHome() {
    Navigator.pushNamedAndRemoveUntil(
      context,
      '/home',
          (route) => false,
    );
  }

  // 소셜 로그인 버튼
  Widget _buildSocialLoginButton(String text, dynamic iconOrPath, Color color, {VoidCallback? onTap}) {
    return Container(
      width: double.infinity,
      height: 48,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: ElevatedButton(
        onPressed: onTap ?? () {
          print('$text 버튼 클릭됨');
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(60),
          ),
          padding: EdgeInsets.zero,
        ),
        child: Row(
          children: [
            SizedBox(width: 12),
            Image.asset(
              iconOrPath,
              width: 28,
              height: 28,
            ),
            Expanded(
              child: Text(
                text,
                textAlign: TextAlign.center,
                style: AppTypography.largeBtn.withColor(Colors.white,),
              ),
            ),
            SizedBox(width: 28),
          ],
        ),
      ),
    );
  }
}