import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tiiun/design_system/colors.dart';
import 'package:tiiun/design_system/typography.dart';
import 'package:tiiun/pages/mypage/my_setting_buddy.dart';
import 'package:tiiun/pages/mypage/my_setting_chatting.dart';
import 'package:tiiun/pages/mypage/my_setting_language.dart';
import 'package:tiiun/pages/mypage/my_setting_notification.dart';
import 'package:tiiun/pages/mypage/my_setting_profile.dart';
import 'package:tiiun/pages/mypage/my_setting_scrap.dart';
import 'package:tiiun/pages/mypage/my_setting_serviceinfo.dart';
import 'package:tiiun/pages/mypage/my_setting_subscribe.dart';
// 추가된 import
import 'package:tiiun/services/user_api_service.dart';
import 'package:tiiun/models/backend_user_model.dart';
import 'package:tiiun/utils/logger.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final UserApiService _userApiService = UserApiService();
  BackendUser? _currentUser;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final response = await _userApiService.getCurrentUser();

      if (response.isSuccess && response.data != null) {
        setState(() {
          _currentUser = response.data;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = response.error ?? '사용자 정보를 불러올 수 없습니다.';
          _isLoading = false;
        });
        AppLogger.error('사용자 정보 로드 실패: ${response.error}');
      }
    } catch (e) {
      setState(() {
        _errorMessage = '사용자 정보를 불러오는 중 오류가 발생했습니다.';
        _isLoading = false;
      });
      AppLogger.error('사용자 정보 로드 오류: $e');
    }
  }

  // 새로고침 메서드
  Future<void> _refreshUserData() async {
    await _loadUserData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
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
          padding: const EdgeInsets.only(top: 0),
          child: Text(
            '설정',
            style: AppTypography.b2.withColor(AppColors.grey900),
          ),
        ),
        centerTitle: true,
        // 새로고침 버튼 추가
        actions: [
          IconButton(
            onPressed: _refreshUserData,
            icon: Icon(
              Icons.refresh,
              color: AppColors.grey700,
              size: 24,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 프로필 섹션
            _buildProfileSection(),

            // 구분선
            Container(
              width: double.infinity,
              height: 24.5,
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Container(
                height: 0.5,
                color: AppColors.grey300,
              ),
            ),

            // 설정 메뉴 리스트
            Column(
              children: [
                _buildMenuItem(
                  iconPath: 'assets/icons/functions/bookmark.svg',
                  title: '스크랩',
                  onTap: () => {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const MySettingScrapPage(),
                      ),
                    ),
                  },
                ),
                _buildDivider(),
                _buildMenuItem(
                  iconPath: 'assets/icons/functions/icon_buddy.svg',
                  title: '버디 설정',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const MySettingBuddyPage(),
                      ),
                    );
                  },
                ),
                _buildDivider(),
                _buildMenuItem(
                  iconPath: 'assets/icons/functions/icon_language.svg',
                  title: '언어',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const MySettingLanguagePage(),
                      ),
                    );
                  },
                ),
                _buildDivider(),
                _buildMenuItem(
                  iconPath: 'assets/icons/functions/notification_off.svg',
                  title: '알림',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const MySettingNotificationPage(),
                      ),
                    );
                  },
                ),
                _buildDivider(),
                _buildMenuItem(
                  iconPath: 'assets/icons/functions/icon_chat.svg',
                  title: '채팅',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const MySettingChattingPage(),
                      ),
                    );
                  },
                ),
                _buildDivider(),
                _buildMenuItem(
                  iconPath: 'assets/icons/functions/Credit_Card_01.svg',
                  title: '유료 구독',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const MySettingSubscribePage(),
                      ),
                    );
                  },
                ),
                _buildDivider(),
                _buildMenuItem(
                  iconPath: 'assets/icons/functions/icon_info.svg',
                  title: '서비스 정보',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const MySettingServiceinfoPage(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // 프로필 섹션을 별도 위젯으로 분리
  Widget _buildProfileSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      color: Colors.white,
      child: Row(
        children: [
          // 프로필 이미지
          _buildProfileImage(),
          const SizedBox(width: 16),

          // 사용자 정보
          Expanded(
            child: _buildUserInfo(),
          ),

          // 편집 버튼
          GestureDetector(
            onTap: () async {
              // ProfilePage로 이동 후 돌아올 때 사용자 정보 새로고침
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const MySettingProfilePage(),
                ),
              );

              // 프로필 수정 후 돌아온 경우 데이터 새로고침
              if (result == true) {
                _refreshUserData();
              }
            },
            child: Container(
              padding: const EdgeInsets.all(4),
              child: SvgPicture.asset(
                'assets/icons/functions/Edit_Pencil_01.svg',
                width: 24,
                height: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 프로필 이미지 위젯
  Widget _buildProfileImage() {
    if (_currentUser?.hasProfileImage == true) {
      return Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          image: DecorationImage(
            image: NetworkImage(_currentUser!.photoUrl!),
            fit: BoxFit.cover,
          ),
        ),
      );
    } else {
      return SvgPicture.asset(
        'assets/images/mypage/Profile_image.svg',
        height: 60,
        width: 60,
      );
    }
  }

  // 사용자 정보 위젯
  Widget _buildUserInfo() {
    if (_isLoading) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 100,
            height: 20,
            decoration: BoxDecoration(
              color: AppColors.grey200,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 4),
          Container(
            width: 150,
            height: 16,
            decoration: BoxDecoration(
              color: AppColors.grey200,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ],
      );
    }

    if (_errorMessage != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '사용자 정보를 불러올 수 없습니다',
            style: AppTypography.b1.withColor(AppColors.grey500),
          ),
          const SizedBox(height: 4),
          Text(
            _errorMessage!,
            style: AppTypography.b3.withColor(AppColors.grey400),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: _refreshUserData,
            child: Text(
              '다시 시도',
              style: AppTypography.b3.withColor(AppColors.main700),
            ),
          ),
        ],
      );
    }

    if (_currentUser == null) {
      return Text(
        '사용자 정보가 없습니다',
        style: AppTypography.b1.withColor(AppColors.grey500),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _currentUser!.displayTitle,
          style: AppTypography.b1.withColor(AppColors.grey900),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        Text(
          _currentUser!.email,
          style: AppTypography.b3.withColor(AppColors.grey600),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildMenuItem({
    required String iconPath,
    required String title,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          child: Row(
            children: [
              SvgPicture.asset(
                iconPath,
                width: 24,
                height: 24,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: AppTypography.b4.withColor(AppColors.grey800),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      height: 0.5,
      color: AppColors.grey100,
    );
  }
}
