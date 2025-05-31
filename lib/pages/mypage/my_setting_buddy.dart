import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tiiun/design_system/colors.dart';
import 'package:tiiun/design_system/typography.dart';
import 'package:tiiun/pages/home_chatting/conversation_list_page.dart';

class MySettingBuddyPage extends StatelessWidget {
  const MySettingBuddyPage({super.key});

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
            '버디 설정',
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
                  title: '네트워크 설정',
                  onTap: () => {
                  },
                ),
                _buildDivider(),
                _buildMenuItem(
                  title: '기기 조명',
                  onTap: () {
                  },
                ),
                _buildDivider(),
                _buildMenuItem(
                  title: '디스플레이',
                  onTap: () {
                  },
                ),
                _buildDivider(),
                _buildMenuItem(
                  title: '대화 기록',
                  onTap: () {
                    // 대화 기록 페이지로 이동
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ConversationListPage(),
                      ),
                    );
                  },
                ),
                _buildDivider(),
                _buildMenuItem(
                  title: '버디 성격',
                  onTap: () {
                  },
                ),
                _buildDivider(),
                _buildMenuItem(
                  title: 'AI 버전',
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