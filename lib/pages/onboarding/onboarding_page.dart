import 'package:flutter/material.dart';
import 'package:tiiun/design_system/colors.dart';
import 'package:tiiun/design_system/typography.dart';
import 'signup_page.dart';
import 'login_page.dart';
import 'package:flutter_svg/flutter_svg.dart';


class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  _OnboardingPageState createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  // 언어 설정
  String _selectedLanguage = '언어 변경';
  final List<String> _languages = [
    '한국어',
    'English',
    '中国话',
    '日本語',
  ];

  // 회원가입 페이지로 이동
  void _navigateToSignup() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SignupPage()),
    );
  }

  // 로그인 페이지로 이동
  void _navigateToLogin() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }

  // 언어 선택 다이얼로그 표시
  // 언어 선택 다이얼로그 표시 - 이 부분만 수정
  void _showLanguageSelector() {
    showDialog(
      context: context,
      barrierColor: Color.fromRGBO(0, 0, 0, 0.5),
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          contentPadding: EdgeInsets.all(20), // 패딩 추가
          content: Container(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min, // 내용에 맞게 크기 조절
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 상단 헤더 (제목 + X 버튼)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '언어 설정',
                      style: AppTypography.h5.withColor(Color(0xFF1B1C1A),),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        width: 24,
                        height: 24,
                        child: Icon(
                          Icons.close,
                          size: 24,
                          color: AppColors.grey800,
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 16),

                // 언어 목록
                Column(
                  children: _languages.asMap().entries.map((entry) {
                    int index = entry.key;
                    String language = entry.value;

                    return Column(
                      children: [
                        InkWell(
                          onTap: () {
                            setState(() {
                              _selectedLanguage = language;
                            });
                            Navigator.of(context).pop();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  '$language 선택됨 (데모용)',
                                  style: AppTypography.b1,
                                ),
                                duration: const Duration(seconds: 1),
                              ),
                            );
                          },
                          child: Container(
                            width: double.infinity,
                            padding: EdgeInsets.symmetric(vertical: 16),
                            child: Text(
                              language,
                              style: AppTypography.b2,
                            ),
                          ),
                        ),
                        // 마지막 항목이 아니면 구분선 추가
                        if (index < _languages.length - 1)
                          Divider(
                            height: 1,
                            thickness: 1,
                            color: AppColors.grey200,
                          ),
                      ],
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // 상단 언어 설정
              Row(
                children: [
                  const SizedBox(width: 103), // 왼쪽 여백
                  Expanded(
                    child: GestureDetector(
                      onTap: _showLanguageSelector,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _selectedLanguage,
                            style: AppTypography.b4.withColor(AppColors.grey400,),
                          ),
                          const Icon(
                            Icons.keyboard_arrow_down,
                            color: AppColors.grey300,
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 103), // 오른쪽 여백
                ],
              ),

              // 중앙 로고 영역
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // 로고
                    Container(
                      child: SvgPicture.asset(
                        'assets/images/tiiun_logo.svg', width: 70.21, height: 35.26,
                      ),
                    ),

                    const SizedBox(height: 19),

                    // 타이틀
                    Container(
                      child: SvgPicture.asset(
                          'assets/images/tiiun_buddy_logo.svg', width: 148.32, height: 27.98
                      ),
                    ),
                  ],
                ),
              ),

              // 하단 버튼들
              Column(
                children: [
                  // 회원가입 버튼
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _navigateToSignup,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.main700,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        '회원가입',
                        style: AppTypography.s2.withColor(Colors.white,),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // 기존 회원 버튼
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: OutlinedButton(
                      onPressed: _navigateToLogin,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.main700,
                        side: BorderSide(color: AppColors.main700, width: 1.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        '기존 회원',
                        style: AppTypography.b2.withColor(AppColors.main900,),
                      ),
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
}