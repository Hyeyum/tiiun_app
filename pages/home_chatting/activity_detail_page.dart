// lib/pages/activity_detail_page.dart
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
      height: MediaQuery.of(context).size.height * 0.9, // Adjust height as needed
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          // Drag indicator
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12.0),
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.grey300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          // Top AppBar with back button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios),
                  color: AppColors.grey900,
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                const Spacer(),
                // Bookmark icon (optional, based on your design)
                // IconButton(
                //   icon: const Icon(Icons.bookmark_border),
                //   color: AppColors.grey900,
                //   onPressed: () {
                //     // Handle bookmark action
                //   },
                // ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center, // Center for the image/tag
                children: [
                  Container(
                    // Increased size of the image container
                    width: 160, // Original was 100
                    height: 160, // Original was 100
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 246, 248, 248).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Center(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: isSvg
                            ? SvgPicture.asset(
                                imagePath,
                                // Increased SVG image size
                                width: 150, // Original was 60
                                height: 150, // Original was 60
                                fit: BoxFit.contain,
                                colorFilter: const ColorFilter.mode(AppColors.main600, BlendMode.srcIn),
                              )
                            : Image.asset(
                                imagePath,
                                // Increased PNG/other image size
                                width: 80, // Original was 60
                                height: 80, // Original was 60
                                fit: BoxFit.cover,
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    imageTag,
                    style: AppTypography.s2.withColor(AppColors.grey600), // Using s3 style
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    title,
                    style: AppTypography.h4.withColor(AppColors.grey900), // Using h4 style
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    shortDescription,
                    style: AppTypography.b2.withColor(AppColors.grey700), // Using b2 style
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  Align(
                    alignment: Alignment.centerLeft,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    longDescription,
                    style: AppTypography.b3.withColor(AppColors.grey700).copyWith(height: 1.6), // Using b3 style
                  ),
                  // Add more content here if needed, like benefits, steps, etc.
                  const SizedBox(height: 60), // Space for the floating button
                ],
              ),
            ),
          ),
          // Fixed bottom button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: onStartActivity,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.main600,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  buttonText,
                  style: AppTypography.s1.withColor(Colors.white).copyWith( // Using s1 style
                        fontWeight: FontWeight.w700, // Ensure w700 for ElevatedButton
                      ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}