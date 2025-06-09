import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tiiun/design_system/colors.dart';
import 'package:tiiun/design_system/typography.dart'; // Import your AppTypography

class ActivityDetailPage extends StatelessWidget {
  final String imagePath;
  final String imageTag; // For the text below the image (e.g., '명상')
  final String title;
  final String shortDescription;
  final String longDescription;
  final String buttonText;
  final VoidCallback onStartActivity;

  const ActivityDetailPage({
    super.key,
    required this.imagePath,
    required this.imageTag,
    required this.title,
    required this.shortDescription,
    required this.longDescription,
    required this.buttonText,
    required this.onStartActivity,
  });

  @override
  Widget build(BuildContext context) {
    final bool isSvg = imagePath.toLowerCase().endsWith('.svg');

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      height: MediaQuery.of(context).size.height - 56, // Adjust height as needed
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Column(
        children: [
          // Top AppBar with back button
          Container(
            child: Row(
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                  child: SvgPicture.asset(
                    'assets/icons/functions/back.svg',
                    width: 24,
                    height: 24,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () {
                  },
                  child: SvgPicture.asset(
                    'assets/icons/functions/Bookmark.svg',
                    width: 24,
                    height: 24,
                  ),
                )
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 149, 24, 185),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center, // Center for the image/tag
                children: [
                  Container(
                    // Increased size of the image container
                    width: 80, // Original was 100
                    height: 80, // Original was 100
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.grey50,
                        width: 1,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8), // 패딩을 줄여서 이미지를 더 크게
                      child: Image.asset(
                        imagePath,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.grey100,
                      borderRadius: BorderRadius.circular(32),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    child: Text(
                      imageTag,
                      style: AppTypography.c1.withColor(AppColors.grey700),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: [
                        Text(
                          title,
                          style: AppTypography.s1.withColor(AppColors.grey900),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          shortDescription,
                          style: AppTypography.b3.withColor(AppColors.grey700),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 22),
                        Text(
                          longDescription,
                          style: AppTypography.c1.withColor(AppColors.grey600),
                          textAlign: TextAlign.left,
                        ),
                      ],
                    ),
                  ),
                  // Add more content here if needed, like benefits, steps, etc.
                  const SizedBox(height: 72), // Space for the floating button
                ],
              ),
            ),
          ),

          // 하단 고정 버튼
          Container(
            margin: const EdgeInsets.fromLTRB(20, 0, 20, 0), // 주변 여백
            child: Container( // 두 번째 코드와 동일하게 GestureDetector 대신 Container로 감싸기
              width: double.infinity,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.main700,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  buttonText,
                  style: AppTypography.s2.withColor(Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}