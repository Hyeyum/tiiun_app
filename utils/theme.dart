import 'package:flutter/material.dart';

/// 앱 전체에서 사용할 테마 정의
class AppTheme {
  // 앱의 기본 색상들
  static const Color primaryColor = Color(0xFF4A6572);
  static const Color primaryLightColor = Color(0xFF7a93a0);
  static const Color primaryDarkColor = Color(0xFF1e3c47);
  
  static const Color secondaryColor = Color(0xFF85CDCA);
  static const Color secondaryLightColor = Color(0xFFb7fffc);
  static const Color secondaryDarkColor = Color(0xFF549c99);
  
  static const Color accentColor = Color(0xFFF9AA33);
  
  static const Color textPrimaryColor = Color(0xFF212121);
  static const Color textSecondaryColor = Color(0xFF757575);
  static const Color textLightColor = Color(0xFFDEE4E7);
  
  static const Color backgroundColor = Color(0xFFF5F5F5);
  static const Color cardColor = Color(0xFFFFFFFF);
  static const Color errorColor = Color(0xFFE53935);
  
  // 감정 색상
  static const Color veryBadColor = Color(0xFFE53935); // 빨강
  static const Color badColor = Color(0xFFFF9800); // 주황
  static const Color neutralColor = Color(0xFFFBC02D); // 노랑
  static const Color goodColor = Color(0xFF8BC34A); // 연두
  static const Color veryGoodColor = Color(0xFF4CAF50); // 초록
  
  // 일관된 요소 크기
  static const double smallRadius = 8.0;
  static const double mediumRadius = 12.0;
  static const double largeRadius = 16.0;
  
  static const double smallPadding = 8.0;
  static const double mediumPadding = 16.0;
  static const double largePadding = 24.0;
  
  static const double smallSpacing = 8.0;
  static const double mediumSpacing = 16.0;
  static const double largeSpacing = 24.0;
  
  // 그림자 스타일
  static List<BoxShadow> get lightShadow => [
    BoxShadow(
      color: Colors.black.withOpacity(0.05),
      blurRadius: 10,
      offset: const Offset(0, 3),
    ),
  ];
  
  static List<BoxShadow> get mediumShadow => [
    BoxShadow(
      color: Colors.black.withOpacity(0.08),
      blurRadius: 15,
      offset: const Offset(0, 5),
    ),
  ];
  
  // 기본 테마
  static ThemeData get lightTheme {
    return ThemeData(
      // 기본 색상 테마
      primaryColor: primaryColor,
      colorScheme: const ColorScheme.light(
        primary: primaryColor,
        secondary: secondaryColor,
        error: errorColor,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: textPrimaryColor,
        onError: Colors.white,
        surface: backgroundColor,
      ),
      scaffoldBackgroundColor: backgroundColor,
      cardColor: cardColor,
      
      // 폰트 설정 - 한글 지원을 위한 Noto Sans KR 폰트 명시
      fontFamily: 'NotoSansKR',
      
      // 텍스트 테마
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          fontFamily: 'NotoSansKR',
        ),
        displayMedium: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          fontFamily: 'NotoSansKR',
        ),
        displaySmall: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w500,
          fontFamily: 'NotoSansKR',
        ),
        headlineLarge: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          fontFamily: 'NotoSansKR',
        ),
        headlineMedium: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: primaryColor,
          fontFamily: 'NotoSansKR',
        ),
        titleLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          fontFamily: 'NotoSansKR',
        ),
        titleMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          fontFamily: 'NotoSansKR',
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          fontFamily: 'NotoSansKR',
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontFamily: 'NotoSansKR',
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          fontFamily: 'NotoSansKR',
        ),
        labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: primaryColor,
          fontFamily: 'NotoSansKR',
        ),
      ),
      
      // Material 3 디자인 활성화
      useMaterial3: true,
      
      // 버튼 테마
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(smallRadius),
          ),
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          textStyle: const TextStyle(
            fontFamily: 'NotoSansKR',
          ),
        ),
      ),
      
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(smallRadius),
          ),
          side: const BorderSide(color: primaryColor, width: 1.5),
          foregroundColor: primaryColor,
          textStyle: const TextStyle(
            fontFamily: 'NotoSansKR',
          ),
        ),
      ),
      
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          foregroundColor: primaryColor,
          textStyle: const TextStyle(
            fontFamily: 'NotoSansKR',
          ),
        ),
      ),
      
      // 앱바 테마
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontFamily: 'NotoSansKR',
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      
      // 카드 테마
      cardTheme: CardTheme(
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(mediumRadius),
        ),
        clipBehavior: Clip.antiAlias,
      ),
      
      // 입력 필드 테마
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(smallRadius),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(smallRadius),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(smallRadius),
          borderSide: const BorderSide(color: primaryColor, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(smallRadius),
          borderSide: const BorderSide(color: errorColor),
        ),
        errorStyle: const TextStyle(
          color: errorColor,
          fontFamily: 'NotoSansKR',
        ),
        hintStyle: const TextStyle(
          fontFamily: 'NotoSansKR',
        ),
        labelStyle: const TextStyle(
          fontFamily: 'NotoSansKR',
        ),
      ),
      
      // 기타 테마
      dividerTheme: DividerThemeData(
        color: Colors.grey.shade300,
        thickness: 1,
      ),
      
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(mediumRadius),
        ),
        contentTextStyle: const TextStyle(
          fontSize: 14, 
          color: Colors.white,
          fontFamily: 'NotoSansKR',
        ),
        backgroundColor: primaryDarkColor,
      ),
      
      dialogTheme: DialogTheme(
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(mediumRadius),
        ),
        titleTextStyle: const TextStyle(
          fontFamily: 'NotoSansKR',
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
        contentTextStyle: const TextStyle(
          fontFamily: 'NotoSansKR',
          fontSize: 14,
        ),
      ),
      
      bottomSheetTheme: const BottomSheetThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(mediumRadius)),
        ),
        backgroundColor: Colors.white,
      ),
      
      // 스위치 및 체크박스 테마
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return primaryColor;
          }
          return Colors.grey.shade400;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return primaryColor.withOpacity(0.5);
          }
          return Colors.grey.shade300;
        }),
      ),
      
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return primaryColor;
          }
          return Colors.grey.shade400;
        }),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
      ),
    );
  }
  
  // 다크 테마
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      // 다크 테마의 추가 속성은 필요에 따라 확장
      primaryColor: primaryColor,
      colorScheme: const ColorScheme.dark(
        primary: primaryLightColor,
        secondary: secondaryLightColor,
        error: Colors.redAccent,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: Colors.white,
        onError: Colors.white,
        surface: Color(0xFF121212),
      ),
      scaffoldBackgroundColor: const Color(0xFF121212),
      cardColor: const Color(0xFF1E1E1E),
      
      // 폰트 설정 - 한글 지원을 위한 Noto Sans KR 폰트 명시
      fontFamily: 'NotoSansKR',
      
      // Material 3 디자인 활성화
      useMaterial3: true,
    );
  }
  
  // 감정 색상 가져오기
  static Color getMoodColor(String mood) {
    switch (mood) {
      case 'very_bad':
        return veryBadColor;
      case 'bad':
        return badColor;
      case 'neutral':
        return neutralColor;
      case 'good':
        return goodColor;
      case 'very_good':
        return veryGoodColor;
      default:
        return neutralColor;
    }
  }
  
  // 감정 아이콘 가져오기
  static IconData getMoodIcon(String mood) {
    switch (mood) {
      case 'very_bad':
        return Icons.sentiment_very_dissatisfied;
      case 'bad':
        return Icons.sentiment_dissatisfied;
      case 'neutral':
        return Icons.sentiment_neutral;
      case 'good':
        return Icons.sentiment_satisfied;
      case 'very_good':
        return Icons.sentiment_very_satisfied;
      default:
        return Icons.sentiment_neutral;
    }
  }
  
  // 감정 아이콘과 색상이 있는 위젯 생성
  static Widget getMoodWidget(String mood, {double size = 24.0}) {
    return Icon(
      getMoodIcon(mood),
      color: getMoodColor(mood),
      size: size,
    );
  }
}
