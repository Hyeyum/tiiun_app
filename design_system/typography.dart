import 'package:flutter/material.dart';

class AppTypography {
  static const String fontFamily = 'Pretendard';

  // Heading Styles
  static const TextStyle h1 = TextStyle(
    fontSize: 40,
    fontWeight: FontWeight.w600, // Semi Bold
    height: 58/40,
    letterSpacing: 0,
    fontFamily: fontFamily,
  );

  static const TextStyle h2 = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w600,
    height: 48/32,
    letterSpacing: 0,
    fontFamily: fontFamily,
  );

  static const TextStyle h3 = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w600,
    height: 38/28,
    letterSpacing: 0,
    fontFamily: fontFamily,
  );

  static const TextStyle h4 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    height: 34/24,
    letterSpacing: 0,
    fontFamily: fontFamily,
  );

  static const TextStyle h5 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 28/20,
    letterSpacing: 0,
    fontFamily: fontFamily,
  );

  // Subtitle Styles
  static const TextStyle s1 = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.35,
    letterSpacing: 0,

    fontFamily: fontFamily,
  );
  static const TextStyle s2 = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.35,
    letterSpacing: 0,
    fontFamily: fontFamily,
  );

  // Body Styles
  static const TextStyle b1 = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400, // Regular = Normal
    height: 24/16,
    letterSpacing: 0,
    fontFamily: fontFamily,
  );

  static const TextStyle b2 = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500, // Medium
    height: 24/16,
    letterSpacing: 0,
    fontFamily: fontFamily,
  );

  static const TextStyle b3 = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 20/14,
    letterSpacing: 0,
    fontFamily: fontFamily,
  );

  static const TextStyle b4 = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 20/14,
    letterSpacing: 0,
    fontFamily: fontFamily,
  );

  static const TextStyle c1 = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.50,
    letterSpacing: 0,
    fontFamily: fontFamily,
  );

  static const TextStyle c2 = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 16/12,
    letterSpacing: 0,
    fontFamily: fontFamily,
  );

  static const TextStyle c3 = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w500,
    height: 14/10,
    letterSpacing: 0,
    fontFamily: fontFamily,
  );

  // Label Style
  static const TextStyle label = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 16/12,
    letterSpacing: 0,
    fontFamily: fontFamily,
    
  );

  // Button Styles
  static const TextStyle giantBtn = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 24/18,
    letterSpacing: 0,
    fontFamily: fontFamily,
  );

  static const TextStyle largeBtn = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 20/16,
    letterSpacing: 0,
    fontFamily: fontFamily,
  );

  static const TextStyle mediumBtn = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 16/14,
    letterSpacing: 0,
    fontFamily: fontFamily,
  );

  static const TextStyle smallBtn = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    height: 16/12,
    letterSpacing: 0,
    fontFamily: fontFamily,
  );

  static const TextStyle tinyBtn = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w600,
    height: 12/10,
    letterSpacing: 0,
    fontFamily: fontFamily,
  );

}

// Extension for easy color application
extension AppTypographyExtension on TextStyle {
  TextStyle withColor(Color color) {
    return copyWith(
      color: color,
      letterSpacing: letterSpacing ?? 0, // letterSpacing 보장
    );
  }
}