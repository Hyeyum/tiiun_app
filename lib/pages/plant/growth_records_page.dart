import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/growth_record_model.dart';
import '../../models/plant_model.dart';
import '../../services/backend_providers.dart';
import '../../services/growth_record_api_service.dart';
import '../../design_system/colors.dart';
import '../../design_system/typography.dart';
import '../../utils/constants.dart';

class GrowthRecordsPage extends ConsumerStatefulWidget {
  final Plant plant;

  const GrowthRecordsPage({super.key, required this.plant});

  @override
  ConsumerState<GrowthRecordsPage> createState() => _GrowthRecordsPageState();
}

class _GrowthRecordsPageState extends ConsumerState<GrowthRecordsPage> {
  List<GrowthRecord> _records = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadGrowthRecords();
  }

  Future<void> _loadGrowthRecords() async {
    setState(() => _isLoading = true);

    try {
      final growthRecordService = ref.read(growthRecordApiServiceProvider);
      final response = await growthRecordService.getGrowthRecordsByPlant(
        widget.plant.plantId,
      );

      if (response.isSuccess && response.data != null) {
        setState(() {
          _records = response.data!;
        });
      } else {
        _showErrorSnackBar('성장 기록을 불러오는데 실패했습니다: ${response.error}');
      }
    } catch (e) {
      _showErrorSnackBar('성장 기록을 불러오는 중 오류가 발생했습니다: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.grey50,
      appBar: AppBar(
        title: Text(
          '${widget.plant.nickname ?? widget.plant.speciesName} 성장 기록',
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
            onPressed: () => _showAddRecordDialog(),
          ),
        ],
      ),
      body: Column(
        children: [
          // 식물 정보 카드
          _buildPlantInfoCard(),

          // 성장 기록 목록
          Expanded(
            child: _isLoading
                ? const Center(
              child: CircularProgressIndicator(color: AppColors.main600),
            )
                : _records.isEmpty
                ? _buildEmptyState()
                : _buildRecordsList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddRecordDialog(),
        backgroundColor: AppColors.main600,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildPlantInfoCard() {
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
          // 식물 이미지
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppColors.main600.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: widget.plant.imageUrl != null && widget.plant.imageUrl!.isNotEmpty
                ? ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                widget.plant.imageUrl!,
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
                  widget.plant.nickname ?? widget.plant.speciesName,
                  style: AppTypography.s1.copyWith(
                    color: AppColors.grey900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.plant.speciesName,
                  style: AppTypography.b2.copyWith(
                    color: AppColors.grey600,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _buildStatusChip(
                      widget.plant.growthStage ?? '알 수 없음',
                      AppColors.point600,
                    ),
                    const SizedBox(width: 8),
                    _buildStatusChip(
                      widget.plant.healthStatus ?? '정상',
                      Colors.green,
                    ),
                  ],
                ),
              ],
            ),
          ),

          // 통계 정보
          Column(
            children: [
              Text(
                '총 기록',
                style: AppTypography.c1.copyWith(
                  color: AppColors.grey600,
                ),
              ),
              Text(
                '${_records.length}개',
                style: AppTypography.s1.copyWith(
                  color: AppColors.main600,
                  fontWeight: FontWeight.bold,
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

  Widget _buildRecordsList() {
    return RefreshIndicator(
      onRefresh: _loadGrowthRecords,
      color: AppColors.main500,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _records.length,
        itemBuilder: (context, index) {
          final record = _records[index];
          return _buildRecordCard(record);
        },
      ),
    );
  }

  Widget _buildRecordCard(GrowthRecord record) {
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 날짜와 성장 단계
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _formatDate(record.recordDate),
                style: AppTypography.s2.copyWith(
                  color: AppColors.main500,
                ),
              ),
              if (record.growthStage != null)
                _buildStatusChip(record.growthStage!, AppColors.main800),
            ],
          ),

          if (record.notes != null && record.notes!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              record.notes!,
              style: AppTypography.b2.copyWith(
                color: AppColors.main800,
              ),
            ),
          ],

          // 치수 정보
          if (record.height != null || record.width != null) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                if (record.height != null) ...[
                  const Icon(Icons.height, size: 16, color: AppColors.main600),
                  const SizedBox(width: 4),
                  Text(
                    '높이: ${record.height!.toStringAsFixed(1)}cm',
                    style: AppTypography.c1.copyWith(
                      color: AppColors.grey600,
                    ),
                  ),
                  const SizedBox(width: 16),
                ],
                if (record.width != null) ...[
                  const Icon(Icons.width_normal, size: 16, color: AppColors.main600),
                  const SizedBox(width: 4),
                  Text(
                    '너비: ${record.width!.toStringAsFixed(1)}cm',
                    style: AppTypography.c1.copyWith(
                      color: AppColors.grey600,
                    ),
                  ),
                ],
              ],
            ),
          ],

          // 이미지 갤러리
          if (record.imageUrls.isNotEmpty) ...[
            const SizedBox(height: 12),
            SizedBox(
              height: 80,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: record.imageUrls.length,
                itemBuilder: (context, index) {
                  return Container(
                    margin: const EdgeInsets.only(right: 8),
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: AppColors.main900.withOpacity(0.1),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        record.imageUrls[index],
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(
                            Icons.image,
                            color: AppColors.main900,
                          );
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
          ],

          // 건강 상태
          if (record.healthStatus != null) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.health_and_safety, size: 16, color: Colors.green),
                const SizedBox(width: 4),
                Text(
                  '건강 상태: ${record.healthStatus}',
                  style: AppTypography.c1.copyWith(
                    color: AppColors.main800,
                  ),
                ),
              ],
            ),
          ],

          // 액션 버튼
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton.icon(
                onPressed: () => _showEditRecordDialog(record),
                icon: const Icon(Icons.edit, size: 16),
                label: const Text('수정'),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.main600,
                ),
              ),
              TextButton.icon(
                onPressed: () => _showDeleteConfirmation(record),
                icon: const Icon(Icons.delete, size: 16),
                label: const Text('삭제'),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.red,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.timeline,
            size: 80,
            color: AppColors.grey600.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            '아직 성장 기록이 없어요',
            style: AppTypography.s1.copyWith(
              color: AppColors.grey600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '첫 번째 성장 기록을 남겨보세요!',
            style: AppTypography.b2.copyWith(
              color: AppColors.grey600,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _showAddRecordDialog(),
            icon: const Icon(Icons.add),
            label: const Text('성장 기록 추가'),
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

  String _formatDate(DateTime date) {
    return '${date.year}년 ${date.month}월 ${date.day}일';
  }

  void _showAddRecordDialog() {
    // TODO: 성장 기록 추가 다이얼로그 구현
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('성장 기록 추가 기능은 곧 구현 예정입니다.'),
        backgroundColor: AppColors.main600,
      ),
    );
  }

  void _showEditRecordDialog(GrowthRecord record) {
    // TODO: 성장 기록 수정 다이얼로그 구현
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${_formatDate(record.recordDate)} 기록 수정 기능은 곧 구현 예정입니다.'),
        backgroundColor: AppColors.main600,
      ),
    );
  }

  void _showDeleteConfirmation(GrowthRecord record) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('성장 기록 삭제'),
        content: Text('${_formatDate(record.recordDate)}의 성장 기록을 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteRecord(record);
            },
            child: const Text('삭제', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _deleteRecord(GrowthRecord record) async {
    try {
      final growthRecordService = ref.read(growthRecordApiServiceProvider);
      final response = await growthRecordService.deleteGrowthRecord(record.recordId);

      if (response.isSuccess) {
        setState(() {
          _records.removeWhere((r) => r.recordId == record.recordId);
        });
        _showSuccessSnackBar('성장 기록이 삭제되었습니다.');
      } else {
        _showErrorSnackBar('삭제 실패: ${response.error}');
      }
    } catch (e) {
      _showErrorSnackBar('삭제 중 오류가 발생했습니다: $e');
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
