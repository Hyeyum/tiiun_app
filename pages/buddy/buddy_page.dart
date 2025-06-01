import 'package:flutter/material.dart';
import 'package:tiiun/design_system/colors.dart';
import 'package:tiiun/design_system/typography.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tiiun/pages/buddy/buddy_shop_page.dart';
import 'package:tiiun/pages/buddy/buddy_history.dart';

class BuddyPage extends StatelessWidget {
  const BuddyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFD4F5F5), Color(0xFFE8F6F6)],
          stops: [0.6, 1.0],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                height: 64,
                alignment: Alignment.center,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '버디',
                      style: AppTypography.s1.withColor(AppColors.grey900),
                    ),

                    // 오른쪽 아이콘 두 개
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const BuddyShopPage(),
                              ),
                            );
                          },
                          child: SvgPicture.asset(
                            'assets/icons/buddy/Handbag.svg',
                            width: 24,
                            height: 24,
                          ),
                        ),

                        SizedBox(width: 12,),

                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const BuddyHistoryPage(),
                              ),
                            );
                          },
                          child: SvgPicture.asset(
                            'assets/icons/functions/icon_buddy.svg',
                            width: 24,
                            height: 24,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),



              ),
            ],
          ),
        ),
      ),
    );
  }
}