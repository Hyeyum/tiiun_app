import 'package:flutter/material.dart';
import 'package:tiiun/design_system/colors.dart';
import 'package:tiiun/design_system/typography.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tiiun/pages/mypage/settings_page.dart';

class MyPage extends StatelessWidget {
  const MyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: Text(
                    '마이페이지',
                    style: AppTypography.s1.withColor(AppColors.grey900),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const SettingsPage()),
                      );
                    },
                    child: SvgPicture.asset(
                      'assets/icons/functions/icon_setting.svg',
                      width: 24,
                      height: 24,
                    ),
                  )
                ],
              ),

              SizedBox(height: 12,),

              // 프로필 섹션
              Center(
                child: SvgPicture.asset(
                  'assets/images/Profile_image.svg',
                  width: 80,
                  height: 80,
                ),
              ),

              const SizedBox(height: 24),

            ],
          ),
        ),
      ),
    );
  }

}