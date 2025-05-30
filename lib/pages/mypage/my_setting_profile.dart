import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tiiun/design_system/colors.dart';
import 'package:tiiun/design_system/typography.dart';

class MySettingProfilePage extends StatelessWidget {
  const MySettingProfilePage({super.key});

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
            icon: Icon(Icons.arrow_back_ios, color: AppColors.grey700, size: 20),
            onPressed: () => Navigator.pop(context),
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
                  onTap: () {
                    // 알림 설정 페이지로 이동
                  },
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
}