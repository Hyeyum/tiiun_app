import 'package:flutter/material.dart';

class AppShadows {
  // Shadow 100 - 가장 약한 그림자 (두 개 레이어)
  static List<BoxShadow> shadow100 = [
    // 첫 번째 레이어
    BoxShadow(
      color: Color(0x1F131927), // 12%
      offset: Offset(0, 2),
      blurRadius: 4,
      spreadRadius: -2,
    ),
    // 두 번째 레이어
    BoxShadow(
      color: Color(0x14131927), // 8%
      offset: Offset(0, 4),
      blurRadius: 4,
      spreadRadius: -2,
    ),
  ];

  // Shadow 200
  static List<BoxShadow> shadow200 = [
    BoxShadow(
      color: Color(0x1F131927),
      offset: Offset(0, 4),
      blurRadius: 6,
      spreadRadius: -4,
    ),
    BoxShadow(
      color: Color(0x14131927),
      offset: Offset(0, 8),
      blurRadius: 8,
      spreadRadius: -4,
    ),
  ];

  // Shadow 300
  static List<BoxShadow> shadow300 = [
    BoxShadow(
      color: Color(0x1F131927),
      offset: Offset(0, 6),
      blurRadius: 8,
      spreadRadius: -6,
    ),
    BoxShadow(
      color: Color(0x14131927),
      offset: Offset(0, 8),
      blurRadius: 16,
      spreadRadius: -6,
    ),
  ];

  // Shadow 400
  static List<BoxShadow> shadow400 = [
    BoxShadow(
      color: Color(0x1F131927),
      offset: Offset(0, 6),
      blurRadius: 12,
      spreadRadius: -6,
    ),
    BoxShadow(
      color: Color(0x14131927),
      offset: Offset(0, 8),
      blurRadius: 24,
      spreadRadius: -4,
    ),
  ];

  // Shadow 500
  static List<BoxShadow> shadow500 = [
    BoxShadow(
      color: Color(0x1F131927),
      offset: Offset(0, 6),
      blurRadius: 14,
      spreadRadius: -6,
    ),
    BoxShadow(
      color: Color(0x14131927),
      offset: Offset(0, 10),
      blurRadius: 32,
      spreadRadius: -4,
    ),
  ];

  // Shadow 600
  static List<BoxShadow> shadow600 = [
    BoxShadow(
      color: Color(0x1F131927),
      offset: Offset(0, 8),
      blurRadius: 18,
      spreadRadius: -6,
    ),
    BoxShadow(
      color: Color(0x14131927),
      offset: Offset(0, 12),
      blurRadius: 42,
      spreadRadius: -4,
    ),
  ];

  // Shadow 700
  static List<BoxShadow> shadow700 = [
    BoxShadow(
      color: Color(0x1F131927),
      offset: Offset(0, 8),
      blurRadius: 22,
      spreadRadius: -6,
    ),
    BoxShadow(
      color: Color(0x14131927),
      offset: Offset(0, 14),
      blurRadius: 64,
      spreadRadius: -4,
    ),
  ];

  // Shadow 800 - 가장 강한 그림자
  static List<BoxShadow> shadow800 = [
    BoxShadow(
      color: Color(0x1F131927),
      offset: Offset(0, 8),
      blurRadius: 28,
      spreadRadius: -6,
    ),
    BoxShadow(
      color: Color(0x14131927),
      offset: Offset(0, 18),
      blurRadius: 88,
      spreadRadius: -4,
    ),
  ];
}
