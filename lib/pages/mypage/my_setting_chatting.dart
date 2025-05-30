import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tiiun/design_system/colors.dart';
import 'package:tiiun/design_system/typography.dart';
import 'package:flutter/cupertino.dart';

class MySettingChattingPage extends StatefulWidget {
  const MySettingChattingPage({super.key});

  @override
  State<MySettingChattingPage> createState() => _MySettingChattingPageState();
}

class _MySettingChattingPageState extends State<MySettingChattingPage> {
  // 토글 상태 관리
  bool isReplyBySwipe = true;
  bool isKeyboardToolbar = true;
  bool isSendMessageByEnter = false;

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
          padding: const EdgeInsets.only(top: 0),
          child: Text(
            '채팅',
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
                // 토글 스위치가 있는 메뉴들
                _buildMenuItemWithToggle(
                  title: '스와이프로 답장하기',
                  value: isReplyBySwipe,
                  onChanged: (bool value) {
                    setState(() {
                      isReplyBySwipe = value;
                    });
                  },
                ),
                _buildDivider(),
                _buildMenuItemWithToggle(
                  title: '키보드 툴 바',
                  value: isKeyboardToolbar,
                  onChanged: (bool value) {
                    setState(() {
                      isKeyboardToolbar = value;
                    });
                  },
                ),
                _buildDivider(),
                _buildMenuItemWithToggle(
                  title: 'Enter 키로 메시지 전송',
                  value: isSendMessageByEnter,
                  onChanged: (bool value) {
                    setState(() {
                      isSendMessageByEnter = value;
                    });
                  },
                ),

                _buildDivider(),
                _buildMenuItemWithValue(
                  title: '채팅 방 테마',
                  value: '라이트',
                  onTap: () {
                    // 진동 패턴 선택 페이지로 이동
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // 토글 스위치가 있는 메뉴 아이템
  Widget _buildMenuItemWithToggle({
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Material(
      color: Colors.white,
      child: Container(
        height: 48,
        padding: const EdgeInsets.fromLTRB(20, 14, 12, 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center, // 세로 중앙 정렬
          children: [
            Expanded(
              child: Text(
                title,
                style: AppTypography.b4.withColor(AppColors.grey800),
              ),
            ),
            Transform.scale(
              scale: 0.7,
              child: CupertinoSwitch(
                value: value,
                onChanged: onChanged,
                activeColor: AppColors.main600,
                thumbColor: Colors.white,
                inactiveTrackColor: AppColors.grey200,
                // materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 설정값이 표시되는 메뉴 아이템
  Widget _buildMenuItemWithValue({
    required String title,
    required String value,
    required VoidCallback onTap,
    Color? titleColor,
  }) {
    return Material(
      color: Colors.white,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center, // 세로 중앙 정렬
            children: [
              Expanded(
                child: Text(
                  title,
                  style: AppTypography.b4.withColor(titleColor ?? AppColors.grey800),
                ),
              ),
              Text(
                value,
                style: AppTypography.c1.withColor(AppColors.grey800),
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