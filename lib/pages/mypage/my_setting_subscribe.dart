import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:tiiun/design_system/colors.dart';
import 'package:tiiun/design_system/typography.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tiiun/pages/mypage/settings_page.dart';

class MySettingSubscribePage extends StatelessWidget {
  const MySettingSubscribePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        toolbarHeight: 56,
        leadingWidth: 56,
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false, // 기본 뒤로가기 버튼 제거
        actions: [
          Container(
            margin: EdgeInsets.only(right: 20),
            child: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: SvgPicture.asset(
                'assets/icons/community/Close_MD.svg',
                width: 24,
                height: 24,
                color: AppColors.grey700,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [

              // 틔운버디 멤버십
              Container(
                padding: EdgeInsets.all(20),
                child: Column(
                  children: [
                    Text(
                      '틔운버디 멤버십',
                      style: AppTypography.b4.withColor(AppColors.main700),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 4),
                    Text(
                      '기간별 감정 분석부터\n나의 유형 분석까지 한 눈에',
                      style: AppTypography.h5.withColor(AppColors.grey900),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 16),
                    Image.asset(
                      'assets/images/mypage/unlock.png',
                      width: 140,
                      filterQuality: FilterQuality.high,
                    ),
                  ],
                ),
              ),

              // 혜택
              Container(
                padding: EdgeInsets.all(20),
                child: Column(
                  children: [
                    Text(
                      '혜택',
                      style: AppTypography.b4.withColor(AppColors.main700),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 4),
                    Text(
                      '멤버십이 제공하는 기능',
                      style: AppTypography.h5.withColor(AppColors.grey900),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 16),

                    // 각 혜택 항목들
                    _buildBenefitItem(
                      'AI 공감형 대화 업그레이드',
                      '나를 더 깊게 이해하고 공감하는 버디와 대화해요',
                      'assets/images/mypage/chatting_bubble.png',
                      272,
                      142,
                    ),

                    SizedBox(height: 16),

                    _buildBenefitItem(
                      '틔운 버디 프리미엄 테마',
                      '버디 기기 디스플레이를 더 예쁘게 꾸며보아요',
                      'assets/images/mypage/premium_theme.png',
                      272,
                      142,
                    ),

                    SizedBox(height: 16),

                    _buildBenefitItem(
                      '심층 감정 변동 분석',
                      '기간별로 바뀌는 나의 감정을 이해해요',
                      'assets/images/mypage/premium_graph.png',
                      272,
                      142,
                    ),

                    SizedBox(height: 16),

                    _buildBenefitItem(
                      '감정 기반 심리 유형 분석',
                      '대화를 기반으로 나의 유형을 분석하고 조언 받아요',
                      'assets/images/mypage/premium_analysis.png',
                      272,
                      142,
                    ),
                  ],
                ),
              ),

              // 언제든 해지 가능
              Container(
                padding: EdgeInsets.all(20),
                child: Column(
                  children: [
                    Text('언제든 해지 가능', style: AppTypography.b4.withColor(AppColors.main700),),
                    SizedBox(height: 4),
                    Text(
                      '멤버십 혜택 한눈에 확인하기',
                      style: AppTypography.h5.withColor(AppColors.grey900),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 16),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
'''
\u{2714} AI 공감형 대화 업그레이드
\u{2714} 틔운 버디 프리미엄 테마
\u{2714} 심층 감정 변동 분석
\u{2714} 감정 기반 심리 유형 분석
''',
                        style: AppTypography.c1.withColor(AppColors.grey900),
                      ),
                    ),
                    SizedBox(height: 4),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        '월 3,900원',
                        style: AppTypography.b2.withColor(AppColors.main700),
                      ),
                    ),



                  ],
                ),
              ),

              // 멤버십 유의사항
              Container(
                padding: EdgeInsets.all(20),
                child: Column(
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        '멤버십 유의사항',
                        style: AppTypography.c2.withColor(AppColors.grey900),
                      ),
                    ),
                    SizedBox(height: 4),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '구매 안내',
                            style: AppTypography.c3.withColor(AppColors.grey700),
                          ),
                          ...([
                            '결제 금액은 부가세(VAT)와 수수료가 포함된 가격입니다.',
                            '결제 금액은 Google Play 결제 시에만 적용되는 가격입니다.',
                            '등록하신 결제 수단으로 매월 정기 결제일에 멤버십 이용 금액이 자동으로 결제됩니다.',
                            '멤버십은 언제든 해지할 수 있으며 해지해도 결제 만료일까지 사용 가능합니다.',
                            '멤버십은 쿠폰, 무료 체험 등의 비과금 혜택과 중복으로 이용할 수 없으며 상기의 혜택을 이용 중에 멤버십을 구매할 경우 남은 비과금 혜택은 사라지게 되고 복원할 수 없습니다.',
                            '미성년 회원의 결제는 원칙적으로 법정 대리인의 명의 또는 동의를 받고 이루어져야 하고, 법정 대리인은 본인 동의 없이 체결된 자녀(미성년자)의 계약을 취소할 수 있습니다.',
                          ].map((text) => Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                ' · ',
                                style: AppTypography.c3.withColor(AppColors.grey900),
                              ),
                              Expanded(
                                child: Text(
                                  text,
                                  style: AppTypography.c3.withColor(AppColors.grey700),
                                ),
                              ),
                            ],
                          ))),
                        ],
                      ),
                    ),
                    SizedBox(height: 4,),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '환불 안내',
                            style: AppTypography.c3.withColor(AppColors.grey700),
                          ),
                          ...([
                            '환불은 멤버십 해당 서비스를 이용하지 않은 경우 결제 후 7일 이내에 LG전자 고객센터를 통해 가능합니다.',
                            '멤버십 사용 중에는 남은 기간에 대한 금액은 환불되지 않습니다.',
                          ].map((text) => Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                ' · ',
                                style: AppTypography.c3.withColor(AppColors.grey900),
                              ),
                              Expanded(
                                child: Text(
                                  text,
                                  style: AppTypography.c3.withColor(AppColors.grey700),
                                ),
                              ),
                            ],
                          ))),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 4,),

            ],
          ),
        ),
      ),

      // 하단 버튼
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.transparent,
        ),
        padding: EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: Container(
          width: 320,
          height: 48,
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 13),
          decoration: BoxDecoration(
            color: AppColors.main700,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '멤버십 시작하기',
            style: AppTypography.s2.withColor(Colors.white),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  Widget _buildBenefitItem(String title, String description, String imagePath, double width, double height) {
    return Column(
      children: [
        Text(
          title,
          style: AppTypography.s2.withColor(AppColors.grey900),
          textAlign: TextAlign.center,
        ),
        Text(
          description,
          style: AppTypography.c2.withColor(AppColors.grey500),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 8),
        Image.asset(
          imagePath,
          width: width,
          height: height,
          filterQuality: FilterQuality.high,
        ),
      ],
    );
  }
}