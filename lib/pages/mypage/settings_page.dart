import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tiiun/design_system/colors.dart';
import 'package:tiiun/design_system/typography.dart';
import 'package:tiiun/pages/mypage/my_setting_buddy.dart';
import 'package:tiiun/pages/mypage/my_setting_chatting.dart';
import 'package:tiiun/pages/mypage/my_setting_language.dart';
import 'package:tiiun/pages/mypage/my_setting_notification.dart';
import 'package:tiiun/pages/mypage/my_setting_profile.dart';
import 'package:tiiun/pages/mypage/my_setting_scrap.dart';
import 'package:tiiun/pages/mypage/my_setting_serviceinfo.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

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
            '설정',
            style: AppTypography.b2.withColor(AppColors.grey900),
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 프로필 섹션
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              color: Colors.white,
              child: Row(
                children: [
                  // 프로필 이미지
                  SvgPicture.asset(
                    'assets/images/mypage/Profile_image.svg',
                    height: 60,
                    width: 60,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '유시은',
                          style: AppTypography.b1.withColor(AppColors.grey900),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'sein00@naver.com',
                          style: AppTypography.b3.withColor(AppColors.grey600),
                        ),
                      ],
                    ),
                  ),

                  GestureDetector(
                    onTap: () {
                      // ProfilePage로 이동
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const MySettingProfilePage(),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(4), // 터치 영역 확대
                      child: SvgPicture.asset(
                        'assets/icons/functions/Edit_Pencil_01.svg',
                        width: 24,
                        height: 24,
                      ),
                    ),
                  ),

                ],
              ),
            ),

            // 구분선
            Container(
              width: double.infinity,
              height: 24.5,
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Container(
                height: 0.5,
                color: AppColors.grey300,
              ),
            ),

            // 설정 메뉴 리스트
            Column(
              children: [
                _buildMenuItem(
                  iconPath: 'assets/icons/functions/bookmark.svg',
                  title: '스크랩',
                  onTap: () => {
                    // 스크랩 페이지로 이동
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const MySettingScrapPage(),
                      ),
                    ),
                  },
                ),
                _buildDivider(),
                _buildMenuItem(
                  iconPath: 'assets/icons/functions/icon_buddy.svg',
                  title: '버디 설정',
                  onTap: () {
                    // 버디 설정 페이지로 이동
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const MySettingBuddyPage(),
                      ),
                    );
                  },
                ),
                _buildDivider(),
                _buildMenuItem(
                  iconPath: 'assets/icons/functions/icon_language.svg',
                  title: '언어',
                  onTap: () {
                    // 언어 설정 페이지로 이동
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const MySettingLanguagePage(),
                      ),
                    );
                  },
                ),
                _buildDivider(),
                _buildMenuItem(
                  iconPath: 'assets/icons/functions/notification_off.svg',
                  title: '알림',
                  onTap: () {
                    // 알림 설정 페이지로 이동
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const MySettingNotificationPage(),
                      ),
                    );
                  },
                ),
                _buildDivider(),
                _buildMenuItem(
                  iconPath: 'assets/icons/functions/icon_chat.svg',
                  title: '채팅',
                  onTap: () {
                    // 채팅 설정 페이지로 이동
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                        builder: (context) => const MySettingChattingPage(),
                      ),
                    );
                  },
                ),
                _buildDivider(),
                _buildMenuItem(
                  iconPath: 'assets/icons/functions/icon_chat.svg',
                  title: '유료 구독',
                  onTap: () {
                    // 유료 구독 페이지로 이동
                  },
                ),
                _buildDivider(),
                _buildMenuItem(
                  iconPath: 'assets/icons/functions/icon_info.svg',
                  title: '서비스 정보',
                  onTap: () {
                    // 서비스 정보 페이지로 이동
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const MySettingServiceinfoPage(),
                      ),
                    );
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
    required String iconPath,
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
              SvgPicture.asset(
                iconPath,
                width: 24,
                height: 24,
              ),
              const SizedBox(width: 16),
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
}