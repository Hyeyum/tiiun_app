import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tiiun/design_system/colors.dart';
import 'package:tiiun/design_system/typography.dart';
import 'package:tiiun/pages/home_chatting/conversation_list_page.dart';

class MySettingServiceinfoPage extends StatelessWidget {
  const MySettingServiceinfoPage({super.key});

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
            '서비스 정보',
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
                  title: '서비스 버전 정보',
                  onTap: () => {
                  },
                ),
                _buildDivider(),
                _buildMenuItem(
                  title: '버디 기기 정보',
                  onTap: () {
                  },
                ),
                _buildDivider(),
                _buildMenuItem(
                  title: '오류 보고',
                  onTap: () {
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