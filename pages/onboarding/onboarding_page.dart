import 'package:flutter/material.dart';
import 'package:tiiun/design_system/colors.dart';
import 'package:tiiun/design_system/typography.dart';
import 'signup_page.dart';
import 'login_page.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tiiun/utils/constants.dart'; // Import AppConstants for onboardingPages

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  _OnboardingPageState createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  String _selectedLanguage = '한국어'; // Default to Korean
  final List<String> _languages = [
    '한국어',
    'English',
    '中国话',
    '日本語',
  ];

  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      setState(() {
        _currentPage = _pageController.page?.round() ?? 0;
      });
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _navigateToSignup() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SignupPage()),
    );
  }

  void _navigateToLogin() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }

  void _showLanguageSelector() {
    showDialog(
      context: context,
      barrierColor: const Color.fromRGBO(0, 0, 0, 0.5),
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          contentPadding: const EdgeInsets.all(20),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '언어 설정',
                      style: AppTypography.h5.withColor(const Color(0xFF1B1C1A)),
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
                const SizedBox(height: 16),
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
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            child: Text(
                              language,
                              style: AppTypography.b2,
                            ),
                          ),
                        ),
                        if (index < _languages.length - 1)
                          const Divider(
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
              Row(
                children: [
                  const SizedBox(width: 103),
                  Expanded(
                    child: GestureDetector(
                      onTap: _showLanguageSelector,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _selectedLanguage,
                            style: AppTypography.b4.withColor(AppColors.grey400),
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
                  const SizedBox(width: 103),
                ],
              ),
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: AppConstants.onboardingPages.length,
                  itemBuilder: (context, index) {
                    final pageData = AppConstants.onboardingPages[index];
                    return Column(
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
                        const SizedBox(height: 50), // Added spacing
                        Image.asset(
                          pageData['image']!,
                          height: 200,
                        ),
                        const SizedBox(height: 30), // Added spacing
                        Text(
                          pageData['title']!,
                          style: AppTypography.h4.withColor(AppColors.grey900),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          pageData['description']!,
                          style: AppTypography.b3.withColor(AppColors.grey600),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    );
                  },
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(AppConstants.onboardingPages.length, (index) {
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    height: 8,
                    width: _currentPage == index ? 24 : 8,
                    decoration: BoxDecoration(
                      color: _currentPage == index ? AppColors.main700 : AppColors.grey300,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 24),
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
                    style: AppTypography.s2.withColor(Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton(
                  onPressed: _navigateToLogin,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.main700,
                    side: const BorderSide(color: AppColors.main700, width: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    '기존 회원',
                    style: AppTypography.b2.withColor(AppColors.main900),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}