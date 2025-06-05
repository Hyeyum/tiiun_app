import 'dart:ui';

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
      color: Color(0xFFE8F6F6),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // 상단바
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              child: Row(
                children: [
                  SvgPicture.asset(
                    'assets/images/mypage/Profile_image.svg',
                    width: 36,
                    height: 36,
                  ),
                  Spacer(),
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
            ),

            // 하늘색과 흰색 사이에 걸쳐있는 3개 container
            Expanded(
              child: SingleChildScrollView(
                child: Stack(
                  children: [
                    // 하늘색 배경 영역
                    Container(
                      height: 93,
                      color: Color(0xFFE8F6F6),
                    ),

                    // 하단 흰색 container
                    Container(
                      margin: const EdgeInsets.only(top: 93),
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(16),
                          topRight: Radius.circular(16),
                        ),
                      ),
                      child: Column(
                        children: [
                          const SizedBox(height: 47),

                          // 감정 점수 박스
                          Container(
                            padding: EdgeInsets.all(20),
                            child: Container(
                              height: 128,
                              padding: EdgeInsets.fromLTRB(20, 20, 20, 12),
                              decoration: BoxDecoration(
                                color: AppColors.grey50,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Text('평균 감정 점수', style: AppTypography.b1.withColor(AppColors.grey900)),
                                      Spacer(),
                                      Container(
                                        margin: EdgeInsets.symmetric(horizontal: 8),
                                        child: Text('60.0', style: AppTypography.c2.withColor(AppColors.main700),),
                                      ),
                                      SizedBox(
                                        width: 134,
                                        child: LinearProgressIndicator(
                                          value: 60.0 / 100,
                                          backgroundColor: AppColors.grey200,
                                          color: AppColors.main700,
                                          minHeight: 12,
                                          borderRadius: BorderRadius.circular(16),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 12,),
                                  Row(
                                    children: [
                                      Text('주요 감정', style: AppTypography.b1.withColor(AppColors.grey900),),
                                      Spacer(),
                                      Container(
                                        margin: EdgeInsets.symmetric(horizontal: 10),
                                        child: SvgPicture.asset(
                                          'assets/icons/sentiment/neutral.svg',
                                          width: 24,
                                          height: 24,
                                        ),
                                      ),
                                      Text('중립', style: AppTypography.b2.withColor(AppColors.grey400),),
                                    ],
                                  ),
                                  SizedBox(height: 12,),
                                  Row(
                                    children: [
                                      Text('감정 변화', style: AppTypography.b1.withColor(AppColors.grey900),),
                                      Spacer(),
                                      Container(
                                        margin: EdgeInsets.symmetric(horizontal: 10),
                                        child: SvgPicture.asset(
                                          'assets/icons/sentiment/stable.svg',
                                          width: 24,
                                          height: 24,
                                        ),
                                      ),
                                      Text('안정', style: AppTypography.b2.withColor(AppColors.grey400),),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // 감정 변동 리포트
                          Container(
                            padding: EdgeInsets.symmetric(vertical: 12),
                            child: Column(
                              children: [
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 20),
                                  child: Row(
                                    children: [
                                      Image.asset(
                                        'assets/images/display/lock.png',
                                        width: 24,
                                        height: 24,
                                        filterQuality: FilterQuality.high,
                                      ),
                                      SizedBox(width: 4,),
                                      Text('감정 변동 리포트', style: AppTypography.s1.withColor(AppColors.grey900),),
                                      Spacer(),
                                      Text('멤버십 가입 시 사용 가능해요!', style: AppTypography.c1.withColor(AppColors.grey500),)
                                    ],
                                  ),
                                ),
                                SizedBox(height: 12,),
                                Stack(
                                  children: [
                                    Image.asset(
                                      'assets/images/mypage/report_example.png',
                                      filterQuality: FilterQuality.high,
                                      width: 360,
                                      height: 355,
                                    ),
                                    // 이미지 위에 텍스트 추가
                                    Positioned(
                                      top: 120,  // 위에서부터의 거리
                                      left: 97, // 왼쪽에서부터의 거리
                                      child: Text(
                                        '기간 별로 바뀌는\n나의 감정을 이해해요',
                                        style: AppTypography.h5.withColor(AppColors.grey900),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),

                          // 구분선
                          Container(
                            margin: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                            height: 0.5,
                            color: AppColors.grey100,
                          ),

                          // 내 유형 분석
                          Container(
                            padding: EdgeInsets.symmetric(vertical: 12),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              child: Row(
                                children: [
                                  Image.asset(
                                    'assets/images/display/lock.png',
                                    width: 24,
                                    height: 24,
                                    filterQuality: FilterQuality.high,
                                  ),
                                  SizedBox(width: 4,),
                                  Text('내 유형 분석', style: AppTypography.s1.withColor(AppColors.grey900),),
                                  Spacer(),
                                  Text('멤버십 가입 시 사용 가능해요!', style: AppTypography.c1.withColor(AppColors.grey500),)
                                ],
                              ),
                            ),
                          ),
                          Stack(
                            children: [
                              Image.asset(
                                'assets/images/mypage/type_analysis_example.png',
                                filterQuality: FilterQuality.high,
                                width: 360,
                                height: 187,
                              ),
                              // 이미지 위에 텍스트 추가
                              Positioned(
                                top: 60,  // 위에서부터의 거리
                                left: 80, // 왼쪽에서부터의 거리
                                child: Text(
                                  '내 유형을 이해하고\n적합한 조언을 받아보세요',
                                  style: AppTypography.h5.withColor(AppColors.grey900),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ),

                          // 구분선
                          Container(
                            margin: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                            height: 0.5,
                            color: AppColors.grey100,
                          ),

                          // 콜렉션
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                              child:
                                Text('콜렉션', style: AppTypography.s1.withColor(AppColors.grey900),
                              ),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 20),
                            child: Row(
                              // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Image.asset(
                                  'assets/images/mypage/collection1.png',
                                  width: 88,
                                  height: 88,
                                  filterQuality: FilterQuality.high,
                                ),
                                SizedBox(width: 12),
                                Image.asset(
                                  'assets/images/mypage/collection2.png',
                                  width: 100,
                                  height: 100,
                                  filterQuality: FilterQuality.high,
                                ),
                                SizedBox(width: 12),
                                Image.asset(
                                  'assets/images/mypage/collection3.png',
                                  width: 100,
                                  height: 100,
                                  filterQuality: FilterQuality.high,
                                ),
                              ],
                            ),
                          ),

                          SizedBox(height: 56),
                        ],
                      ),
                    ),

                    // 틔운 기기 container들 (하늘색과 흰색 사이에 걸쳐짐)
                    Positioned(
                      top: 20,
                      left: 0,
                      right: 0,
                      child: Container(
                        height: 100,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          children: [
                            _buildDeviceBox('assets/images/shop/image_pureum.png'),
                            SizedBox(width: 8),
                            _buildDeviceBox('assets/images/shop/image_geumuh_yell.png'),
                            SizedBox(width: 8),
                            _buildDeviceBox('assets/images/shop/image_tomato.png'),
                            SizedBox(width: 8),
                            _buildAddDeviceBox(),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),



          ],
        ),
      ),
    );
  }

  Widget _buildDeviceBox(String imagePath) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(32),
            color: Colors.white.withOpacity(0.6),
            border: Border.all(
              color: AppColors.grey200,
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                offset: Offset(0, 8),
                blurRadius: 16,
                spreadRadius: -6,
                color: Color(0xFF131927).withOpacity(0.08),
              ),
            ],
          ),
          child: Image.asset(
            imagePath,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: AppColors.grey100,
                child: Icon(
                  Icons.image_not_supported,
                  color: AppColors.grey400,
                  size: 24,
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildAddDeviceBox() {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(32),
            color: Colors.white.withOpacity(0.6),
            border: Border.all(
              color: AppColors.grey200,
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                offset: Offset(0, 8),
                blurRadius: 16,
                spreadRadius: -6,
                color: Color(0xFF131927).withOpacity(0.08),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                'assets/icons/functions/icon_plus.svg',
                width: 24,
                height: 24,
              ),
              SizedBox(height: 4),
              Text(
                '기기 추가',
                style: AppTypography.b3.withColor(AppColors.grey500),
              ),
            ],
          ),
        ),
      ),
    );
  }

}