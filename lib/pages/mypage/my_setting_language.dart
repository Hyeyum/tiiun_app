import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tiiun/design_system/colors.dart';
import 'package:tiiun/design_system/typography.dart';
import 'package:tiiun/pages/home_chatting/conversation_list_page.dart';
import 'package:tiiun/pages/mypage/my_setting_scrap.dart';

class MySettingLanguagePage extends StatefulWidget {
  const MySettingLanguagePage({super.key});

  @override
  State<MySettingLanguagePage> createState() => _MySettingLanguagePageState();
}

class _MySettingLanguagePageState extends State<MySettingLanguagePage> {
  String selectedLanguage = '시스템 기본 언어'; // 초기 선택값

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
          padding: const EdgeInsets.only(top: 0),
          child: Text(
            '언어',
            style: AppTypography.b2.withColor(AppColors.grey900),
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 8),
            Column(
              children: [
                _buildMenuItemWithRadio(
                  title: '시스템 기본 언어',
                  value: '시스템 기본 언어',
                  groupValue: selectedLanguage,
                  onTap: () {
                    setState(() {
                      selectedLanguage = '시스템 기본 언어';
                    });
                  },
                ),
                _buildDivider(),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.fromLTRB(20, 18, 20, 4),
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "사용자 설정",
                    style: AppTypography.c1.withColor(AppColors.grey800),
                  ),
                ),
                _buildMenuItemWithRadio(
                  title: '한국어',
                  value: '한국어',
                  groupValue: selectedLanguage,
                  onTap: () {
                    setState(() {
                      selectedLanguage = '한국어';
                    });
                  },
                ),
                _buildDivider(),
                _buildMenuItem(
                  title: '미설치 언어',
                  onTap: () {
                    // 미설치 언어 페이지로 이동
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // 라디오 버튼이 있는 메뉴 아이템
  Widget _buildMenuItemWithRadio({
    required String title,
    required String value,
    required String groupValue,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      child: InkWell(
        onTap: onTap,
        child: Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: AppTypography.b4.withColor(AppColors.grey800),
                ),
              ),
              Radio<String>(
                value: value,
                groupValue: groupValue,
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() {
                      selectedLanguage = newValue;
                    });
                  }
                },
                activeColor: AppColors.grey800, // 선택된 라디오 버튼 색상
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 일반 메뉴 아이템 (라디오 버튼 없음)
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