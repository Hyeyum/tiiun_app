import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tiiun/design_system/colors.dart';
import 'package:tiiun/design_system/typography.dart';
import 'buddy_history_detail.dart';

class BuddyHistoryPage extends StatefulWidget {
  const BuddyHistoryPage({super.key});

  @override
  State<BuddyHistoryPage> createState() => _BuddyHistoryPageState();
}

class _BuddyHistoryPageState extends State<BuddyHistoryPage> {
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  String selectedBuddy = '푸름이';
  final List<String> buddyOptions = ['푸름이', '하양이', '버디버디'];

  void _toggleOverlay() {
    if (_overlayEntry != null) {
      _overlayEntry?.remove();
      _overlayEntry = null;
      return;
    }

    RenderBox renderBox = context.findRenderObject() as RenderBox;
    Offset position = renderBox.localToGlobal(Offset.zero);

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        width: 120,
        height: 112,
        left: position.dx + (renderBox.size.width / 2) - 50, // 중앙 정렬
        top: 54,
        child: Material(
          color: Colors.transparent,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF131927).withOpacity(0.08),
                      offset: const Offset(2, 8),
                      blurRadius: 8,
                      spreadRadius: -4,
                    ),
                  ],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppColors.grey100,
                    width: 1,
                  ),
                ),
                child: ListView(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 9),
                  physics: const NeverScrollableScrollPhysics(),
                  children: buddyOptions.map((option) {
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedBuddy = option;
                        });
                        _toggleOverlay();
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 7),
                        child: Text(
                          option,
                          style: AppTypography.c1.withColor(AppColors.grey700),
                          textAlign: TextAlign.left,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  void _navigateToDetail(String plantName, String period, String imagePath) {
    // 실제 날짜 계산 (예시로 90일로 설정)
    DateTime plantedDate = DateTime(2024, 12, 22);
    DateTime now = DateTime.now();
    int daysPlanted = now.difference(plantedDate).inDays;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BuddyHistoryDetailPage(),
      ),
    );
  }

  String _getPlantVariety(String plantName) {
    switch (plantName) {
      case '스토크':
        return '스톡';
      case '라벤더':
        return '라벤다';
      case '타임':
        return '허브타임';
      default:
        return '알 수 없음';
    }
  }

  String _getFormattedDate(String plantName) {
    switch (plantName) {
      case '스토크':
        return '2024.12.22';
      case '라벤더':
        return '2024.07.13';
      case '타임':
        return '2024.03.22';
      default:
        return '2024.01.01';
    }
  }

  String _getPlantDetailImage(String plantName) {
    switch (plantName) {
      case '스토크':
        return 'assets/images/plants/stock_detail.png';
      case '라벤더':
        return 'assets/images/plants/lavender_detail.png';
      case '타임':
        return 'assets/images/plants/thyme_detail.png';
      default:
        return 'assets/images/plants/default.png';
    }
  }

  @override
  void dispose() {
    _overlayEntry?.remove();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFE8F6F6),
      appBar: AppBar(
        backgroundColor: Color(0xFFE8F6F6),
        elevation: 0,
        scrolledUnderElevation: 0,
        toolbarHeight: 56,
        leadingWidth: 56,
        leading: Padding(
          padding: const EdgeInsets.only(left: 4),
          child: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: SvgPicture.asset(
              'assets/icons/functions/back.svg',
              width: 24,
              height: 24,
              color: AppColors.grey700,
            ),
          ),
        ),
        title: CompositedTransformTarget(
          link: _layerLink,
          child: GestureDetector(
            onTap: _toggleOverlay,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  selectedBuddy,
                  style: AppTypography.b2.withColor(AppColors.grey900),
                ),
                SvgPicture.asset(
                  'assets/icons/buddy/Caret_Down_MD.svg',
                  width: 24,
                  height: 24,
                  color: AppColors.grey700,
                )
              ],
            ),
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: SvgPicture.asset(
                  'assets/icons/buddy/Slider_02.svg',
                  width: 24,
                  height: 24,
                ),
              ),
              SizedBox(height: 16),

              // 스토크 아이템
              _buildPlantHistoryItem(
                plantName: '스토크',
                period: '2024.12.22 ~ 2025.03.28',
                imagePath: 'assets/images/history/history1.png',
              ),

              SizedBox(height: 16),

              // 라벤더 아이템
              _buildPlantHistoryItem(
                plantName: '라벤더',
                period: '2024.07.13 ~ 2024.12.21',
                imagePath: 'assets/images/history/history2.png',
              ),

              SizedBox(height: 16),

              // 세 번째 식물 아이템 (이름 없음)
              _buildPlantHistoryItem(
                plantName: '타임',
                period: '2024.03.22 ~ 2024.07.02',
                imagePath: 'assets/images/history/history3.png',
              ),

              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlantHistoryItem({
    required String plantName,
    required String period,
    required String imagePath,
  }) {
    return GestureDetector(
      onTap: () => _navigateToDetail(plantName, period, imagePath),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.8),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            // 식물 이미지
            Container(
              height: 204,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
                child: Image.asset(
                  imagePath,
                  fit: BoxFit.cover,
                  filterQuality: FilterQuality.high,
                  errorBuilder: (context, error, stackTrace) {
                    // 이미지 로딩 실패 시 placeholder
                    return Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Color(0xFFD2B48C),
                            Color(0xFFF5E6D3),
                          ],
                        ),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.local_florist,
                          size: 60,
                          color: Colors.white.withOpacity(0.7),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            // 식물 정보
            Container(
              width: double.infinity,
              height: 48,
              padding: EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.8),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Text(
                      plantName,
                      style: AppTypography.b2.withColor(AppColors.grey700),
                    ),
                  ),
                  Spacer(),
                  Center(
                    child: Text(
                      period,
                      style: AppTypography.c1.withColor(AppColors.grey700),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}