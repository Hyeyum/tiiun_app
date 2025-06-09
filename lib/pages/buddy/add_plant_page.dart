import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../design_system/colors.dart';
import '../../design_system/typography.dart';
import '../../models/plant_model.dart';
import '../../services/backend_providers.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../utils/constants.dart';

class AddPlantPage extends ConsumerStatefulWidget {
  const AddPlantPage({super.key});

  @override
  ConsumerState<AddPlantPage> createState() => _AddPlantPageState();
}

class _AddPlantPageState extends ConsumerState<AddPlantPage> {
  final _formKey = GlobalKey<FormState>();
  final _speciesNameController = TextEditingController();
  final _nicknameController = TextEditingController();
  final _locationController = TextEditingController();
  final _notesController = TextEditingController();

  String _selectedGrowthStage = '씨앗';
  String _selectedHealthStatus = '건강';
  DateTime _plantedDate = DateTime.now();
  bool _isLoading = false;

  final List<String> _growthStages = ['씨앗', '새싹', '성장', '개화', '열매'];
  final List<String> _healthStatuses = ['건강', '주의', '위험'];

  @override
  void dispose() {
    _speciesNameController.dispose();
    _nicknameController.dispose();
    _locationController.dispose();
    _notesController.dispose();
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
        title: Padding(
          padding: const EdgeInsets.only(top: 0), // 타이틀 위치 조정
          child: Text(
            '새 버디 등록',
            style: AppTypography.b2.withColor(AppColors.grey900),
          ),
        ),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInputCard(
                title: '기본 정보',
                children: [
                  _buildTextFormField(
                    controller: _speciesNameController,
                    label: '식물 종류',
                    hint: '예: 금어초, 방울토마토, 바질',
                    isRequired: true,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return '식물 종류를 입력해주세요';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),
                  _buildTextFormField(
                    controller: _nicknameController,
                    label: '애칭 (선택)',
                    hint: '예: 누렁이, 푸름이',
                  ),
                ],
              ),

              const SizedBox(height: 12),

              _buildInputCard(
                title: '재배 정보',
                children: [
                  _buildDatePicker(),
                  const SizedBox(height: 10),
                  _buildDropdownField(
                    label: '성장 단계',
                    value: _selectedGrowthStage,
                    items: _growthStages,
                    onChanged: (value) => setState(() => _selectedGrowthStage = value!),
                  ),
                  const SizedBox(height: 10),
                  _buildDropdownField(
                    label: '건강 상태',
                    value: _selectedHealthStatus,
                    items: _healthStatuses,
                    onChanged: (value) => setState(() => _selectedHealthStatus = value!),
                  ),
                  const SizedBox(height: 10),
                  _buildTextFormField(
                    controller: _locationController,
                    label: '재배 위치 (선택)',
                    hint: '예: 베란다, 거실 창가 등',
                  ),
                ],
              ),

              const SizedBox(height: 12),

              _buildInputCard(
                title: '추가 메모',
                children: [
                  _buildTextFormField(
                    controller: _notesController,
                    label: '메모 (선택)',
                    hint: '식물에 대한 특별한 정보나 관리 방법을 적어보세요',
                    maxLines: 3,
                  ),
                ],
              ),

              const SizedBox(height: 10),

              _buildSubmitButton(),

              const SizedBox(height: 22),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputCard({required String title, required List<Widget> children}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTypography.s2.withColor(AppColors.grey900),
          ),
          const SizedBox(height: 8),
          ...children,
        ],
      ),
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String label,
    String? hint,
    bool isRequired = false,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: label,
            style: AppTypography.b2.withColor(AppColors.grey800),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          validator: validator,
          style: AppTypography.b1.withColor(AppColors.grey900),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTypography.b1.withColor(AppColors.grey400),
            filled: true,
            fillColor: AppColors.grey100,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            // enabledBorder: OutlineInputBorder(
            //   borderRadius: BorderRadius.circular(12),
            //   borderSide: BorderSide(color: AppColors.grey200, width: 1),
            // ),
            // focusedBorder: OutlineInputBorder(
            //   borderRadius: BorderRadius.circular(12),
            //   borderSide: BorderSide(color: AppColors.main600, width: 2),
            // ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.b2.withColor(AppColors.grey800),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: AppColors.grey100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              dropdownColor: Colors.white,
              borderRadius: BorderRadius.circular(12),
              elevation: 8, // 그림자 높이
              style: AppTypography.b1.withColor(AppColors.grey900),
              items: items.map((item) {
                return DropdownMenuItem<String>(
                  value: item,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Text(
                      item,
                      style: AppTypography.b1.withColor(AppColors.grey700),
                    ),
                  ),
                );
              }).toList(),
              onChanged: onChanged,
              icon: SvgPicture.asset(
                'assets/icons/buddy/Caret_Down_MD.svg',
                width: 24,
                height: 24,
              ),
              menuMaxHeight: 300,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDatePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '심은 날짜',
          style: AppTypography.b2.withColor(AppColors.grey800),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _selectDate,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.grey100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${_plantedDate.year}.${_plantedDate.month.toString().padLeft(2, '0')}.${_plantedDate.day.toString().padLeft(2, '0')}',
                  style: AppTypography.b1.withColor(AppColors.grey900),
                ),
                SvgPicture.asset(
                  'assets/icons/buddy/Calendar.svg',
                  width: 24,
                  height: 24,
                )
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _submitPlant,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.main700,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: _isLoading
            ? const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        )
            : Text(
          '버디 등록하기',
          style: AppTypography.s2.withColor(Colors.white),
        ),
      ),
    );
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _plantedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.main600, // 선택된 날짜 색상
              onPrimary: Colors.white, // 선택된 날짜 텍스트 색상
              surface: Colors.white, // 캘린더 배경색
              onSurface: AppColors.grey900, // 일반 텍스트 색상
            ),
            dialogTheme: DialogThemeData( // DialogTheme → DialogThemeData
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: AppColors.main600,
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _plantedDate) {
      setState(() {
        _plantedDate = picked;
      });
    }
  }
  Future<void> _submitPlant() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final plantService = ref.read(plantApiServiceProvider);

      // 🔥 추가 유효성 검사
      final speciesName = _speciesNameController.text.trim();
      if (speciesName.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('식물 종류를 입력해주세요.'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() { _isLoading = false; });
        return;
      }

      final request = CreatePlantRequest(
        speciesName: speciesName,
        nickname: _nicknameController.text.trim().isEmpty
            ? null
            : _nicknameController.text.trim(),
        plantedDate: _plantedDate,
        growthStage: _selectedGrowthStage,
        healthStatus: _selectedHealthStatus,
        location: _locationController.text.trim().isEmpty
            ? null
            : _locationController.text.trim(),
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
      );

      // 🔍 디버깅: 요청 데이터 출력
      print('🔍 Creating plant with data:');
      print('  speciesName: "${request.speciesName}"');
      print('  nickname: "${request.nickname}"');
      print('  growthStage: "${request.growthStage}"');
      print('  healthStatus: "${request.healthStatus}"');
      print('  location: "${request.location}"');
      print('  plantedDate: ${request.plantedDate}');
      print('  JSON: ${request.toJson()}');

      final response = await plantService.createPlant(request);

      if (response.isSuccess) {
        // 성공적으로 등록되었을 때
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${request.nickname ?? request.speciesName}이(가) 성공적으로 등록되었습니다!',
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );

        // 이전 페이지로 돌아가기
        Navigator.pop(context);
      } else {
        // 오류가 발생했을 때
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.error ?? '식물 등록 중 오류가 발생했습니다.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('식물 등록 중 오류가 발생했습니다: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}
