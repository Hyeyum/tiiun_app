import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tiiun/design_system/colors.dart';
import 'package:tiiun/design_system/typography.dart';
import 'package:flutter/cupertino.dart';

class MySettingNotificationPage extends StatefulWidget {
  const MySettingNotificationPage({super.key});

  @override
  State<MySettingNotificationPage> createState() => _MySettingNotificationPageState();
}

class _MySettingNotificationPageState extends State<MySettingNotificationPage> {
  // 토글 상태 관리
  bool isMessageNotificationEnabled = true;
  bool isSoundEnabled = true;
  bool isVibrationEnabled = false;

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
            '알림',
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
                  title: '메시지 알림',
                  value: isMessageNotificationEnabled,
                  onChanged: (bool value) {
                    setState(() {
                      isMessageNotificationEnabled = value;
                    });
                  },
                ),
                _buildDivider(),
                _buildMenuItemWithToggle(
                  title: '소리',
                  value: isSoundEnabled,
                  onChanged: (bool value) {
                    setState(() {
                      isSoundEnabled = value;
                    });
                  },
                ),
                _buildDivider(),
                _buildMenuItemWithValue(
                  title: '알림음',
                  value: '실로폰',
                  onTap: () {
                    // 알림음 선택 페이지로 이동
                  },
                ),

                _buildDivider(),
                _buildMenuItemWithToggle(
                  title: '진동',
                  value: isVibrationEnabled,
                  onChanged: (bool value) {
                    setState(() {
                      isVibrationEnabled = value;
                    });
                  },
                ),

                _buildDivider(),
                _buildMenuItemWithValue(
                  title: '진동 패턴',
                  value: '지그재그',
                  onTap: () {
                    // 진동 패턴 선택 페이지로 이동
                  },
                  titleColor: AppColors.grey400, // 진동 패턴은 grey400
                  valueColor: AppColors.grey400,
                ),
                _buildDivider(),
                _buildMenuItemWithValue(
                  title: '알림 표시',
                  value: '항상 받기',
                  onTap: () {
                    // 알림 표시 설정 페이지로 이동
                  },
                ),
                _buildDivider(),
                _buildMenuItemWithValue(
                  title: '방해금지 시간대 설정',
                  value: '사용 안함',
                  onTap: () {
                    // 방해금지 시간 설정 페이지로 이동
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
    Color? valueColor,
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
                style: AppTypography.c1.withColor(valueColor ?? AppColors.grey800),
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