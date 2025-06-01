import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tiiun/design_system/colors.dart';
import 'package:tiiun/design_system/typography.dart';

class CommunityWritePage extends StatefulWidget {
  const CommunityWritePage({super.key});

  @override
  State<CommunityWritePage> createState() => _CommunityWritePageState();
}

class _CommunityWritePageState extends State<CommunityWritePage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  final FocusNode _titleFocusNode = FocusNode();
  final FocusNode _contentFocusNode = FocusNode();

  // 스크롤 컨트롤러 추가
  final ScrollController _scrollController = ScrollController();

  String? _selectedCategory; // 기본 선택 카테고리
  List<XFile> _selectedImages = [];
  final ImagePicker _picker = ImagePicker();
  bool _isAnonymous = false;

  // 키보드 상태
  bool _isKeyboardVisible = false;

  // 카테고리 목록 (인기 제외)
  final List<Map<String, String>> _categories = [
    {'name': '재배 팁', 'icon': 'assets/icons/community/icon_cate_tips.svg'},
    {'name': '상담', 'icon': 'assets/icons/community/icon_cate_advice.svg'},
    {'name': '일상', 'icon': 'assets/icons/community/icon_cate_daylife.svg'},
    {'name': '인테리어', 'icon': 'assets/icons/community/icon_cate_interior.svg'},
    {'name': '자랑', 'icon': 'assets/icons/community/icon_cate_brag.svg'},
    {'name': '레시피', 'icon': 'assets/icons/community/icon_cate_recipe.svg'},
    {'name': '가틔', 'icon': 'assets/icons/community/icon_cate_gatuii.svg'},
    {'name': '이벤트', 'icon': 'assets/icons/community/icon_cate_event.svg'},
  ];

  @override
  void initState() {
    super.initState();

    // 포커스 노드 리스너 추가
    _titleFocusNode.addListener(_onFocusChange);
    _contentFocusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _titleFocusNode.dispose();
    _contentFocusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // 포커스 변화 감지
  void _onFocusChange() {
    setState(() {
      _isKeyboardVisible = _titleFocusNode.hasFocus || _contentFocusNode.hasFocus;
    });
  }

  // 키보드 내리기
  void _hideKeyboard() {
    FocusScope.of(context).unfocus();
  }

  // 이미지 선택
  Future<void> _pickImages() async {
    try {
      final List<XFile> images = await _picker.pickMultiImage(
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );

      if (images.isNotEmpty) {
        setState(() {
          // 최대 5장까지 제한
          if (_selectedImages.length + images.length <= 5) {
            _selectedImages.addAll(images);
          } else {
            int remainingSlots = 5 - _selectedImages.length;
            _selectedImages.addAll(images.take(remainingSlots));
            _showImageLimitSnackBar();
          }
        });
      }
    } catch (e) {
      print('이미지 선택 오류: $e');
    }
  }

  // 이미지 제한 안내
  void _showImageLimitSnackBar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '이미지는 최대 5장까지 선택할 수 있습니다.',
          style: AppTypography.b4.withColor(Colors.white),
        ),
        backgroundColor: AppColors.grey800,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // 이미지 삭제
  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  // 카테고리 선택 바텀시트
  void _showCategoryBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      barrierColor: Colors.black.withOpacity(0.6),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 제목
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              alignment: Alignment.centerLeft,
              child: Text(
                '게시글 주제를 선택해주세요',
                style: AppTypography.h5.withColor(AppColors.grey900),
              ),
            ),
            const SizedBox(height: 24),

            // 카테고리 목록
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: _categories.length,
                separatorBuilder: (context, index) => Container(
                  width: 320,
                  height: 0.5,
                  margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 20),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  color: AppColors.grey100,
                ),
                itemBuilder: (context, index) {
                  final category = _categories[index];
                  final categoryName = category['name']!;
                  final categoryIcon = category['icon']!;
                  final isSelected = categoryName == _selectedCategory;

                  return ListTile(
                    leading: Container(
                      margin: EdgeInsets.fromLTRB(0, 12, 12, 12),
                      padding: EdgeInsets.zero,
                      width: 24,
                      height: 24,
                      child: SvgPicture.asset(
                        categoryIcon,
                        color: AppColors.grey700,
                      ),
                    ),
                    title: Container(
                      padding: EdgeInsets.zero,
                      child: Text(
                        categoryName,
                        style: AppTypography.b4.withColor(AppColors.grey800),
                      ),
                    ),
                    onTap: () {
                      setState(() {
                        _selectedCategory = categoryName;
                      });
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 글 작성 완료
  void _submitPost() {
    if (_titleController.text.trim().isEmpty) {
      _showSnackBar('제목을 입력해주세요.');
      return;
    }

    if (_contentController.text.trim().isEmpty) {
      _showSnackBar('내용을 입력해주세요.');
      return;
    }

    // 글 작성 완료에서 카테고리 검증 추가
    if (_selectedCategory == null) {
      _showSnackBar('카테고리를 선택해주세요.');
      return;
    }

    // TODO: 실제 글 작성 API 호출
    // 여기서 서버에 글을 전송하는 로직을 구현하면 됩니다.

    // 성공 후 이전 화면으로 돌아가기
    Navigator.pop(context, true); // true를 반환하여 새 글이 작성되었음을 알림

    _showSnackBar('글이 성공적으로 작성되었습니다.');
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: AppTypography.b4.withColor(Colors.white),
        ),
        backgroundColor: AppColors.grey800,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // 작성 가능 여부 확인
  bool get _canSubmit {
    return _selectedCategory != null && // 카테고리 선택 필수
        _titleController.text.trim().isNotEmpty &&
        _contentController.text.trim().isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        toolbarHeight: 56,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            padding: EdgeInsets.fromLTRB(20, 20, 0, 12),
            child: SvgPicture.asset(
              'assets/icons/community/Close_MD.svg',
              width: 24,
              height: 24,
            ),
          ),
        ),
        title: Container(
          padding: EdgeInsets.fromLTRB(0, 20, 0, 12),
          child: Text(
            '글쓰기',
            style: AppTypography.b2.withColor(AppColors.grey900),
          ),
        ),
        centerTitle: true,
        actions: [
          Container(
            padding: EdgeInsets.fromLTRB(0, 20, 20, 12),
            child: GestureDetector(
              onTap: _canSubmit ? _submitPost : null,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Text(
                  '등록',
                  style: AppTypography.b4.withColor(AppColors.grey700),
                ),
              ),
            ),
          ),
        ],
      ),
      body: GestureDetector(
        onTap: () {
          // 빈 영역 터치 시 키보드 숨기기
          FocusScope.of(context).unfocus();
        },
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 12),
                    // 카테고리 선택
                    _buildCategorySelector(),

                    // 제목 입력
                    _buildTitleInput(),

                    // 내용 입력
                    _buildContentInput(),

                    // 선택된 이미지 미리보기
                    _buildImagePreview(),

                    const SizedBox(height: 48),

                  ],
                ),
              ),
            ),
            // 하단바 추가
            _buildBottomBar(),
          ],
        ),
      ),
    );
  }

  // 카테고리 선택기
  Widget _buildCategorySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: _showCategoryBottomSheet,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 12, 12, 12),
            margin: EdgeInsets.zero,
            decoration: BoxDecoration(
              color: AppColors.grey100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _selectedCategory ?? '주제를 선택해주세요',
                  style: AppTypography.b3.withColor(AppColors.grey700),
                ),
                SvgPicture.asset(
                  'assets/icons/functions/more.svg',
                  width: 24,
                  height: 24,
                  color: AppColors.grey500,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // 제목 입력 필드
  Widget _buildTitleInput() {
    return Container(
      padding: EdgeInsets.only(top: 24),
      margin: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _titleController,
            focusNode: _titleFocusNode,
            maxLength: 50,
            onTap: () {
              _scrollController.animateTo(
                150.0, // 제목 입력란까지의 거리
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            },
            decoration: InputDecoration(
              hintText: '제목을 입력해주세요.',
              hintStyle: AppTypography.h5.withColor(AppColors.grey500),
              border: InputBorder.none, // 모든 테두리 제거
              enabledBorder: InputBorder.none, // 활성화 상태 테두리 제거
              focusedBorder: InputBorder.none, // 포커스 상태 테두리 제거
              contentPadding: EdgeInsets.zero, // 패딩 제거
              counterText: '',
            ),
            style: AppTypography.h5.withColor(AppColors.grey800),
            onChanged: (value) {
              setState(() {}); // 완료 버튼 상태 업데이트
            },
          ),
        ],
      ),
    );
  }

  // 내용 입력 필드
  Widget _buildContentInput() {
    return Container(
      padding: EdgeInsets.only(top: 12),
      margin: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _contentController,
            focusNode: _contentFocusNode,
            maxLines: 10,
            maxLength: 1000,
            onTap: () {
              _scrollController.animateTo(
                250.0, // 내용 입력란까지의 거리
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            },
            decoration: InputDecoration(
              hintText: '자유롭게 의견을 남겨주세요.\n#일상 #상담 #인테리어...',
              hintStyle: AppTypography.b3.withColor(AppColors.grey500),
              border: InputBorder.none, // 모든 테두리 제거
              enabledBorder: InputBorder.none, // 활성화 상태 테두리 제거
              focusedBorder: InputBorder.none, // 포커스 상태 테두리 제거
              contentPadding: EdgeInsets.zero, // 패딩 제거
              counterText: '',
            ),
            style: AppTypography.b3.withColor(AppColors.grey900),
            onChanged: (value) {
              setState(() {}); // 완료 버튼 상태 업데이트
            },
          ),
        ],
      ),
    );
  }

  // 하단바
  Widget _buildBottomBar() {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        border: Border(
          top: BorderSide(
            color: AppColors.grey200,
            width: 1,
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(
          children: [
            // 사진 추가 버튼
            GestureDetector(
              onTap: _pickImages,
              child: Container(
                child: SvgPicture.asset(
                  'assets/icons/community/Image_02.svg',
                  width: 24,
                  height: 24,
                  color: AppColors.grey700,
                ),
              ),
            ),
            const SizedBox(width: 12),
            // 해시태그 버튼
            GestureDetector(
              onTap: _insertHashtag,
              child: Container(
                child: SvgPicture.asset(
                  'assets/icons/community/icon_tag.svg',
                  width: 24,
                  height: 24,
                  color: AppColors.grey700,
                ),
              ),
            ),
            const Spacer(),

            // 키보드가 올라와 있을 때만 키보드 다운 버튼 표시
            if (_isKeyboardVisible)
              GestureDetector(
                onTap: _hideKeyboard,
                child: Container(
                  child: SizedBox(
                    width: 32,
                    height: 32,
                    child: SvgPicture.asset(
                      'assets/icons/community/hide_keyboard.svg',
                      width: 24,
                      height: 24,
                      fit: BoxFit.contain,
                      color: AppColors.grey700,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // 해시태그 삽입
  void _insertHashtag() {
    final currentText = _contentController.text;
    final cursorPosition = _contentController.selection.start;

    String newText;
    int newCursorPosition;

    if (cursorPosition == -1) {
      // 커서 위치가 없으면 맨 끝에 추가
      newText = '$currentText #';
      newCursorPosition = newText.length;
    } else {
      // 커서 위치에 해시태그 삽입
      newText = currentText.substring(0, cursorPosition) + '#' + currentText.substring(cursorPosition);
      newCursorPosition = cursorPosition + 1;
    }

    _contentController.text = newText;
    _contentController.selection = TextSelection.fromPosition(
      TextPosition(offset: newCursorPosition),
    );

    // 내용 입력란에 포커스 주기
    _contentFocusNode.requestFocus();
  }

  // 이미지 미리보기
  Widget _buildImagePreview() {
    if (_selectedImages.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(top: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '첨부된 이미지 (${_selectedImages.length}/5)',
            style: AppTypography.b4.withColor(AppColors.grey700),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 80,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _selectedImages.length,
              itemBuilder: (context, index) {
                return Container(
                  margin: const EdgeInsets.only(right: 8),
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          File(_selectedImages[index].path),
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: GestureDetector(
                          onTap: () => _removeImage(index),
                          child: Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.6),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.close,
                              size: 14,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

}