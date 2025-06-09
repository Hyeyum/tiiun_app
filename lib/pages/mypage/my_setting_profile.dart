import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tiiun/design_system/colors.dart';
import 'package:tiiun/design_system/typography.dart';
import 'package:tiiun/services/auth_service.dart';
import 'package:tiiun/pages/onboarding/onboarding_page.dart';
import 'package:tiiun/utils/logger.dart';

class MySettingProfilePage extends ConsumerStatefulWidget {
  const MySettingProfilePage({super.key});

  @override
  ConsumerState<MySettingProfilePage> createState() => _MySettingProfilePageState();
}

class _MySettingProfilePageState extends ConsumerState<MySettingProfilePage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        toolbarHeight: 56,
        leadingWidth: 56,
        leading: Padding(
          padding: const EdgeInsets.only(left: 4),
          child: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: SvgPicture.asset(
              'assets/icons/functions/back.svg',
              width: 24,
              height: 24,
              color: AppColors.grey700,
            ),
          ),
        ),
        title: Padding(
          padding: const EdgeInsets.only(top: 0), // 타이틀 위치 조정
          child: Text(
            '내 정보 관리',
            style: AppTypography.b2.withColor(AppColors.grey900),
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 프로필 섹션
            SizedBox(height: 8,),
            // 설정 메뉴 리스트
            Column(
              children: [
                _buildMenuItem(
                  title: '이메일',
                  onTap: () => {
                  },
                ),
                _buildDivider(),
                _buildMenuItem(
                  title: '구독 관리',
                  onTap: () {
                    // 버디 설정 페이지로 이동
                  },
                ),
                _buildDivider(),
                _buildMenuItem(
                  title: '비밀번호 설정',
                  onTap: () {
                    // 언어 설정 페이지로 이동
                  },
                ),
                _buildDivider(),
                _buildMenuItem(
                  title: '로그아웃',
                  onTap: () => _showLogoutDialog(),
                ),
                _buildDivider(),
                _buildMenuItem(
                  title: '서비스 탈퇴',
                  onTap: () {
                    // 채팅 설정 페이지로 이동
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required String title,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: AppTypography.b4.withColor(AppColors.grey800),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      height: 0.5,
      color: AppColors.grey100,
    );
  }

  // 로그아웃 확인 다이얼로그 표시
  void _showLogoutDialog() {
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
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 로그아웃 아이콘 (선택사항)
              const SizedBox(height: 16),
              Text(
                '로그아웃',
                style: AppTypography.h5.withColor(AppColors.grey900),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                '정말 로그아웃 하시겠습니까?',
                style: AppTypography.b2.withColor(AppColors.grey700),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              // 버튼들
              Row(
                children: [
                  // 취소 버튼
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.grey600,
                          side: BorderSide(color: AppColors.grey300, width: 1),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          '취소',
                          style: AppTypography.b2.withColor(AppColors.grey600),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // 로그아웃 버튼
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop(); // 다이얼로그 닫기
                          _performLogout(); // 로그아웃 실행
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.main700,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          '로그아웃',
                          style: AppTypography.b2.withColor(Colors.white),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // 로그아웃 실행
  Future<void> _performLogout() async {
    try {
      // 로딩 표시 (선택사항)
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '로그아웃 중...',
              style: AppTypography.b2.withColor(Colors.white),
            ),
            backgroundColor: AppColors.grey600,
            duration: const Duration(seconds: 1),
          ),
        );
      }

      // AuthService를 통해 로그아웃 실행
      final authService = ref.read(authServiceProvider);
      await authService.logout();

      AppLogger.info('로그아웃 성공');

      // 온보딩 페이지로 이동 (모든 이전 페이지 스택 제거)
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const OnboardingPage()),
              (Route<dynamic> route) => false,
        );
      }
    } catch (e) {
      AppLogger.error('로그아웃 오류: $e');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '로그아웃 중 오류가 발생했습니다. 다시 시도해주세요.',
              style: AppTypography.b2.withColor(Colors.white),
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }
}