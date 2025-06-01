import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tiiun/design_system/colors.dart';
import 'package:tiiun/design_system/typography.dart';
import 'package:tiiun/pages/onboarding/lgsignin_page.dart';
import 'package:tiiun/pages/onboarding/signup_page.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tiiun/utils/logger.dart'; // Import AppLogger

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
      AppLogger.info('LoginPage: Force logout completed');
    } catch (e) {
      AppLogger.error('LoginPage logout error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: AppColors.grey800),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SvgPicture.asset(
                      'assets/images/tiiun_logo.svg',
                      width: 70.21,
                      height: 35.26,
                    ),
                    const SizedBox(height: 19),
                    SvgPicture.asset(
                      'assets/images/tiiun_buddy_logo.svg',
                      width: 148.32,
                      height: 27.98,
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  _buildSocialLoginButton(
                    'LG 계정 로그인',
                    'assets/images/lg_logo.png',
                    const Color(0xFF97282F),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const LGSigninPage()),
                      );
                    },
                  ),
                  const SizedBox(height: 10),
                  _buildSocialLoginButton(
                    'Google 계정으로 로그인',
                    'assets/images/google_logo.png',
                    const Color(0xFF477BDF),
                    onTap: () {
                      AppLogger.info('Google Login button clicked');
                      // TODO: Implement Google Sign-In logic here using AuthService
                    },
                  ),
                  const SizedBox(height: 10),
                  _buildSocialLoginButton(
                    'Apple 계정으로 로그인',
                    'assets/images/apple_logo.png',
                    Colors.black,
                    onTap: () {
                      AppLogger.info('Apple Login button clicked');
                      // TODO: Implement Apple Sign-In logic here using AuthService
                    },
                  ),
                  const SizedBox(height: 24),
                  GestureDetector(
                    onTap: _navigateToSignup,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '다른 계정으로 로그인',
                          style: AppTypography.mediumBtn.withColor(AppColors.grey400),
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

  void _navigateToSignup() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SignupPage()),
    );
  }

  Widget _buildSocialLoginButton(String text, String iconPath, Color color, {VoidCallback? onTap}) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: onTap ?? () {
          AppLogger.info('$text button clicked');
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
            const SizedBox(width: 12),
            Image.asset(
              iconPath,
              width: 28,
              height: 28,
            ),
            Expanded(
              child: Text(
                text,
                textAlign: TextAlign.center,
                style: AppTypography.largeBtn.withColor(Colors.white),
              ),
            ),
            const SizedBox(width: 28),
          ],
        ),
      ),
    );
  }
}