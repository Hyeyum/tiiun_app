// lib/screens/write_post_screen.dart
import 'package:flutter/material.dart';
import 'package:tiiun/design_system/colors.dart';
import 'package:tiiun/design_system/typography.dart';
import 'package:flutter_svg/flutter_svg.dart';

class WritePostScreen extends StatelessWidget {
  const WritePostScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.grey900),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          '글쓰기',
          style: AppTypography.s1.withColor(AppColors.grey900),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: () {
              // TODO: Implement post submission logic
              Navigator.pop(context); // For now, just pop after "등록" (Register) is pressed
            },
            child: Text(
              '등록',
              style: AppTypography.b1.withColor(AppColors.main600), // Assuming AppColors.main600 for active button
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: GestureDetector(
              onTap: () {
                // TODO: Implement category selection
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.grey100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '인테리어', // This should likely be dynamic based on selection
                      style: AppTypography.b2.withColor(AppColors.grey900),
                    ),
                    const Icon(
                      Icons.chevron_right,
                      color: AppColors.grey600,
                    ),
                  ],
                ),
              ),
            ),
          ),
          const Divider(height: 1, thickness: 1, color: AppColors.grey100),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '제목을 입력해주세요.',
                  style: AppTypography.b1.withColor(AppColors.grey900),
                ),
                const SizedBox(height: 8),
                Text(
                  '자유롭게 의견을 남겨주세요.\n#반려식물 #식물팁 #인테리어...',
                  style: AppTypography.b4.withColor(AppColors.grey400),
                ),
                const SizedBox(height: 24), // Adjust spacing as needed
                // Text input fields would go here
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: '내용을 입력하세요...', // Or whatever placeholder is appropriate
                      hintStyle: AppTypography.b4.withColor(AppColors.grey400),
                    ),
                    maxLines: null, // Allows multiline input
                    expands: true, // Allows the text field to expand
                    keyboardType: TextInputType.multiline,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        height: 56, // Adjust height as needed
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(color: AppColors.grey100, width: 1),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              GestureDetector(
                onTap: () {
                  // TODO: Implement image selection
                },
                child: SvgPicture.asset(
                  'assets/icons/functions/icon_image_line.svg', // Assuming an image icon exists
                  width: 24,
                  height: 24,
                  colorFilter: const ColorFilter.mode(AppColors.grey600, BlendMode.srcIn),
                ),
              ),
              const SizedBox(width: 16),
              GestureDetector(
                onTap: () {
                  // TODO: Implement hashtag functionality
                },
                child: SvgPicture.asset(
                  'assets/icons/functions/icon_hashtag.svg', // Assuming a hashtag icon exists
                  width: 24,
                  height: 24,
                  colorFilter: const ColorFilter.mode(AppColors.grey600, BlendMode.srcIn),
                ),
              ),
              // Add other bottom bar icons/functionality here
            ],
          ),
        ),
      ),
    );
  }
}