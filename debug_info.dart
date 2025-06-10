import 'package:flutter/material.dart';

// 디버그 정보 출력용 위젯
class DebugInfo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final textScaler = MediaQuery.textScalerOf(context);
    
    print('=== 기기 정보 ===');
    print('화면 크기: ${mediaQuery.size}');
    print('픽셀 비율: ${mediaQuery.devicePixelRatio}');
    print('텍스트 스케일: ${textScaler.scale(1.0)}');
    print('패딩 (SafeArea): ${mediaQuery.padding}');
    print('뷰 인셋: ${mediaQuery.viewInsets}');
    print('뷰 패딩: ${mediaQuery.viewPadding}');
    print('시스템 설정: ${mediaQuery.platformBrightness}');
    
    return Container();
  }
}
