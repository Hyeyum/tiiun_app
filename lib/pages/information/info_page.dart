import 'package:flutter/material.dart';
import 'package:tiiun/design_system/colors.dart';
import 'package:tiiun/design_system/typography.dart';
import 'package:flutter_svg/flutter_svg.dart';

class InfoPage extends StatelessWidget {
  const InfoPage({super.key});

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
              Container(
                width: double.infinity,
                height: 64,
                alignment: Alignment.center,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '정보',
                      style: AppTypography.s1.withColor(AppColors.grey900),
                    ),

                    // 오른쪽 아이콘 두 개
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                          },
                          child: SvgPicture.asset(
                            'assets/icons/functions/icon_search.svg',
                            width: 24,
                            height: 24,
                          ),
                        ),

                        SizedBox(width: 12,),

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