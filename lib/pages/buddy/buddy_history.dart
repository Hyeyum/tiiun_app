import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tiiun/design_system/colors.dart';
import 'package:tiiun/design_system/typography.dart';
import '../../models/plant_model.dart';
import '../../services/backend_providers.dart';
import '../../utils/plant_data.dart';
import 'buddy_history_detail.dart';

class BuddyHistoryPage extends ConsumerStatefulWidget {
  const BuddyHistoryPage({super.key});

  @override
  ConsumerState<BuddyHistoryPage> createState() => _BuddyHistoryPageState();
}

class _BuddyHistoryPageState extends ConsumerState<BuddyHistoryPage> {
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  String? selectedPlantId;
  List<Plant> _plants = [];
  List<Plant> _inactivePlants = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadPlants();
  }

  Future<void> _loadPlants() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final plantService = ref.read(plantApiServiceProvider);

      // 활성 식물 목록 가져오기
      final activeResponse = await plantService.getMyPlants(isActive: true);
      // 비활성 식물 목록 가져오기 (히스토리)
      final inactiveResponse = await plantService.getMyPlants(isActive: false);

      if (activeResponse.isSuccess && inactiveResponse.isSuccess) {
        setState(() {
          _plants = activeResponse.data ?? [];
          _inactivePlants = inactiveResponse.data ?? [];
          _isLoading = false;

          // 첫 번째 식물을 기본 선택
          if (_plants.isNotEmpty) {
            selectedPlantId = _plants.first.plantId;
          } else if (_inactivePlants.isNotEmpty) {
            selectedPlantId = _inactivePlants.first.plantId;
          }
        });
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = '식물 목록을 불러오는데 실패했습니다.';
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = '식물 목록을 불러오는 중 오류가 발생했습니다: $e';
      });
    }
  }

  void _toggleOverlay() {
    if (_overlayEntry != null) {
      _overlayEntry?.remove();
      _overlayEntry = null;
      return;
    }

    final allPlants = [..._plants, ..._inactivePlants];
    if (allPlants.isEmpty) return;

    RenderBox renderBox = context.findRenderObject() as RenderBox;
    Offset position = renderBox.localToGlobal(Offset.zero);

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        width: 150,
        height: (allPlants.length * 30.0 + 18).clamp(0, 150), // 최대 높이 제한
        left: position.dx + (renderBox.size.width / 2) - 75, // 중앙 정렬
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
                  children: allPlants.map((plant) {
                    final displayName = plant.nickname ?? _getPlantDisplayName(plant);
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedPlantId = plant.plantId;
                        });
                        _toggleOverlay();
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 7),
                        child: Text(
                          displayName,
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

  String _getPlantDisplayName(Plant plant) {
    final plantData = PlantDataUtils.getPlantByName(plant.speciesName);
    return plantData?.displayName ?? plant.speciesName;
  }

  String _getPlantImagePath(Plant plant) {
    if (plant.imageUrl != null && plant.imageUrl!.isNotEmpty) {
      return plant.imageUrl!;
    }
    return PlantDataUtils.getImagePath(plant.speciesName);
  }

  String _formatPeriod(Plant plant) {
    if (plant.plantedDate == null) return '날짜 정보 없음';

    final startDate = plant.plantedDate!;
    final endDate = plant.isActive
        ? DateTime.now()
        : (plant.updatedAt ?? DateTime.now());

    return '${_formatDate(startDate)} ~ ${_formatDate(endDate)}';
  }

  String _formatDate(DateTime date) {
    return '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}';
  }

  void _navigateToDetail(Plant plant) {
    final displayName = plant.nickname ?? _getPlantDisplayName(plant);
    final daysPlanted = plant.plantedDate != null
        ? DateTime.now().difference(plant.plantedDate!).inDays
        : 0;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BuddyHistoryDetailPage(),
      ),
    );
  }

  @override
  void dispose() {
    _overlayEntry?.remove();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selectedPlant = selectedPlantId != null
    ? [..._plants, ..._inactivePlants].where((p) => p.plantId == selectedPlantId).isNotEmpty
    ? [..._plants, ..._inactivePlants].where((p) => p.plantId == selectedPlantId).first
        : null
        : null;
    final selectedPlantName = selectedPlant != null
    ? (selectedPlant.nickname ?? _getPlantDisplayName(selectedPlant))
        : '식물 선택';

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
    onTap: _isLoading ? null : _toggleOverlay,
    child: Row(
    mainAxisSize: MainAxisSize.min,
    children: [
    Text(
    selectedPlantName,
    style: AppTypography.b2.withColor(AppColors.grey900),
    ),
    if (!_isLoading)
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
    body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.main600),
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _errorMessage!,
              style: AppTypography.b3.withColor(AppColors.grey600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadPlants,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.main600,
                foregroundColor: Colors.white,
              ),
              child: const Text('다시 시도'),
            ),
          ],
        ),
      );
    }

    final allPlants = [..._plants, ..._inactivePlants];

    if (allPlants.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              'assets/icons/functions/icon_buddy.svg',
              width: 64,
              height: 64,
              color: AppColors.grey400,
            ),
            const SizedBox(height: 16),
            Text(
              '등록된 식물이 없어요',
              style: AppTypography.s2.withColor(AppColors.grey600),
            ),
            const SizedBox(height: 8),
            Text(
              '첫 번째 식물을 등록해보세요!',
              style: AppTypography.b3.withColor(AppColors.grey500),
            ),
          ],
        ),
      );
    }

    // 선택된 식물의 히스토리만 표시하거나, 모든 비활성 식물 표시
    final plantsToShow = selectedPlantId != null
        ? allPlants.where((p) => p.plantId == selectedPlantId).toList()
        : _inactivePlants;

    return SingleChildScrollView(
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

            // 식물 히스토리 목록
            ...plantsToShow.map((plant) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _buildPlantHistoryItem(plant: plant),
            )).toList(),

            if (plantsToShow.isEmpty)
              Container(
                padding: EdgeInsets.symmetric(vertical: 60),
                child: Column(
                  children: [
                    Icon(
                      Icons.history,
                      size: 48,
                      color: AppColors.grey400,
                    ),
                    SizedBox(height: 16),
                    Text(
                      selectedPlantId != null
                          ? '선택한 식물의 히스토리가 없습니다'
                          : '식물 히스토리가 없습니다',
                      style: AppTypography.s2.withColor(AppColors.grey500),
                    ),
                  ],
                ),
              ),

            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildPlantHistoryItem({required Plant plant}) {
    final displayName = plant.nickname ?? _getPlantDisplayName(plant);
    final period = _formatPeriod(plant);
    final imagePath = _getPlantImagePath(plant);

    return GestureDetector(
      onTap: () => _navigateToDetail(plant),
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
                child: Stack(
                  children: [
                    // 배경 그라데이션
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Color(0xFFD2F7D2),
                            Color(0xFFE8F6F6),
                          ],
                        ),
                      ),
                    ),
                    // 식물 이미지 (중앙에 배치)
                    Center(
                      child: Image.asset(
                        imagePath,
                        width: 120,
                        height: 120,
                        fit: BoxFit.contain,
                        filterQuality: FilterQuality.high,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            Icons.local_florist,
                            size: 80,
                            color: Colors.white.withOpacity(0.7),
                          );
                        },
                      ),
                    ),
                    // 상태 배지 (활성/비활성)
                    if (!plant.isActive)
                      Positioned(
                        top: 12,
                        right: 12,
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.grey600.withOpacity(0.8),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '완료',
                            style: AppTypography.c1.withColor(Colors.white),
                          ),
                        ),
                      ),
                  ],
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
                      displayName,
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