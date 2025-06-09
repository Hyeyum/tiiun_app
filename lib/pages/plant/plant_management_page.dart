import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/plant_model.dart';
import '../../services/backend_providers.dart';
import '../../design_system/colors.dart';
import '../../design_system/typography.dart';
import '../../utils/constants.dart';
import 'growth_records_page.dart'; // 성장 기록 페이지 추가

class PlantManagementPage extends ConsumerStatefulWidget {
  const PlantManagementPage({super.key});

  @override
  ConsumerState<PlantManagementPage> createState() => _PlantManagementPageState();
}

class _PlantManagementPageState extends ConsumerState<PlantManagementPage> {
  @override
  Widget build(BuildContext context) {
    final plantsAsync = ref.watch(myPlantsProvider);
    final plantCountAsync = ref.watch(plantCountProvider);

    return Scaffold(
      backgroundColor: AppColors.grey50,
      appBar: AppBar(
        title: Text(
          '내 식물 관리',
          style: AppTypography.h1.copyWith(
            color: AppColors.grey900,
          ),
        ),
        backgroundColor: AppColors.white100,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: AppColors.main600),
            onPressed: () => _showAddPlantDialog(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // 통계 카드
          _buildStatsCard(plantCountAsync),

          // 식물 목록
          Expanded(
            child: plantsAsync.when(
              data: (plants) => _buildPlantList(plants),
              loading: () => const Center(
                child: CircularProgressIndicator(color: AppColors.main600),
              ),
              error: (error, stack) => _buildErrorWidget(error.toString()),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddPlantDialog(context),
        backgroundColor: AppColors.main600,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildStatsCard(AsyncValue<int> plantCountAsync) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white100,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.grey600.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.main600.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.local_florist,
              color: AppColors.main600,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '등록된 식물',
                  style: AppTypography.b2.copyWith(
                    color: AppColors.grey600,
                  ),
                ),
                const SizedBox(height: 4),
                plantCountAsync.when(
                  data: (count) => Text(
                    '$count개',
                    style: AppTypography.h2.copyWith(
                      color: AppColors.grey900,
                    ),
                  ),
                  loading: () => const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.main600,
                    ),
                  ),
                  error: (_, __) => Text(
                    '-',
                    style: AppTypography.h2.copyWith(
                      color: AppColors.grey900,
                    ),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => _refreshData(),
            icon: const Icon(Icons.refresh, color: AppColors.main600),
          ),
        ],
      ),
    );
  }

  Widget _buildPlantList(List<Plant> plants) {
    if (plants.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: _refreshData,
      color: AppColors.main600,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: plants.length,
        itemBuilder: (context, index) {
          final plant = plants[index];
          return _buildPlantCard(plant);
        },
      ),
    );
  }

  Widget _buildPlantCard(Plant plant) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.grey600.withOpacity(0.1),
        ),
      ),
      child: Row(
        children: [
          // 식물 이미지
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppColors.main600.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: plant.imageUrl != null && plant.imageUrl!.isNotEmpty
                ? ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                plant.imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(
                    Icons.local_florist,
                    color: AppColors.main600,
                  );
                },
              ),
            )
                : const Icon(
              Icons.local_florist,
              color: AppColors.main600,
            ),
          ),
          const SizedBox(width: 16),

          // 식물 정보
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  plant.nickname ?? plant.speciesName,
                  style: AppTypography.s1.copyWith(
                    color: AppColors.grey900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  plant.speciesName,
                  style: AppTypography.b2.copyWith(
                    color: AppColors.grey600,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _buildStatusChip(
                      plant.growthStage ?? '알 수 없음',
                      AppColors.point600,
                    ),
                    const SizedBox(width: 8),
                    _buildStatusChip(
                      plant.healthStatus ?? '정상',
                      _getHealthStatusColor(plant.healthStatus),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // 액션 버튼
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: AppColors.grey600),
            onSelected: (value) {
              switch (value) {
                case 'edit':
                  _showEditPlantDialog(context, plant);
                  break;
                case 'delete':
                  _showDeleteConfirmation(context, plant);
                  break;
                case 'growth':
                  _navigateToGrowthRecords(plant);
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'growth',
                child: Row(
                  children: [
                    Icon(Icons.timeline, color: AppColors.main600),
                    SizedBox(width: 8),
                    Text('성장 기록'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit, color: AppColors.grey600),
                    SizedBox(width: 8),
                    Text('수정'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, color: Colors.red),
                    SizedBox(width: 8),
                    Text('삭제'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: AppTypography.c1.copyWith(
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.local_florist_outlined,
            size: 80,
            color: AppColors.grey600.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            '아직 등록된 식물이 없어요',
            style: AppTypography.s1.copyWith(
              color: AppColors.grey600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '첫 번째 식물을 등록해보세요!',
            style: AppTypography.b2.copyWith(
              color: AppColors.grey600,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _showAddPlantDialog(context),
            icon: const Icon(Icons.add),
            label: const Text('식물 등록하기'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.main600,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red,
          ),
          const SizedBox(height: 16),
          Text(
            '오류가 발생했습니다',
            style: AppTypography.s1.copyWith(
              color: AppColors.grey900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: AppTypography.b2.copyWith(
              color: AppColors.grey600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _refreshData,
            icon: const Icon(Icons.refresh),
            label: const Text('다시 시도'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.main600,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Color _getHealthStatusColor(String? healthStatus) {
    switch (healthStatus?.toLowerCase()) {
      case '건강':
      case 'healthy':
        return Colors.green;
      case '주의':
      case 'warning':
        return Colors.orange;
      case '위험':
      case 'danger':
        return Colors.red;
      default:
        return AppColors.point600;
    }
  }

  Future<void> _refreshData() async {
    ref.invalidate(myPlantsProvider);
    ref.invalidate(plantCountProvider);
  }

  void _showAddPlantDialog(BuildContext context) {
    // TODO: 식물 추가 다이얼로그 구현
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('식물 추가 기능은 곧 구현 예정입니다.'),
        backgroundColor: AppColors.main600,
      ),
    );
  }

  void _showEditPlantDialog(BuildContext context, Plant plant) {
    // TODO: 식물 수정 다이얼로그 구현
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${plant.nickname ?? plant.speciesName} 수정 기능은 곧 구현 예정입니다.'),
        backgroundColor: AppColors.main600,
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, Plant plant) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('식물 삭제'),
        content: Text('${plant.nickname ?? plant.speciesName}을(를) 정말 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deletePlant(plant);
            },
            child: const Text('삭제', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _navigateToGrowthRecords(Plant plant) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GrowthRecordsPage(plant: plant),
      ),
    );
  }

  void _deletePlant(Plant plant) async {
    try {
      final plantService = ref.read(plantApiServiceProvider);
      final response = await plantService.deletePlant(plant.plantId);

      if (response.isSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${plant.nickname ?? plant.speciesName}이(가) 삭제되었습니다.'),
            backgroundColor: Colors.green,
          ),
        );
        _refreshData();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('삭제 실패: ${response.error}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('삭제 중 오류가 발생했습니다: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
