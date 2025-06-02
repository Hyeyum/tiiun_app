// lib/services/profile_service.dart
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as path;
import 'package:uuid/uuid.dart';
import 'firebase_service.dart'; // FirebaseService로 변경
import 'package:firebase_auth/firebase_auth.dart'; // Explicitly import firebase_auth
import 'package:cloud_firestore/cloud_firestore.dart'; // Explicitly import cloud_firestore
import '../models/user_model.dart'; // UserModel import 추가

// Provider for the profile service
final profileServiceProvider = Provider<ProfileService>((ref) {
  final firebaseService = FirebaseService(); // FirebaseService 직접 생성
  return ProfileService(firebaseService);
});

class ProfileService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseService _firebaseService; // FirebaseService로 변경
  final Uuid _uuid = const Uuid();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance; // Add Firestore instance

  ProfileService(this._firebaseService); // FirebaseService로 변경

  // 프로필 이미지 업로드
  Future<String> uploadProfileImage(File imageFile) async {
    final userId = _firebaseService.currentUserId; // FirebaseService 메서드 사용
    if (userId == null) {
      throw Exception('사용자 로그인이 필요합니다');
    }

    final String fileExtension = path.extension(imageFile.path);
    final fileName = '${_uuid.v4()}$fileExtension';
    final ref = _storage.ref().child('profile_images/$userId/$fileName');

    try {
      final task = await ref.putFile(imageFile);
      final downloadUrl = await task.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      throw Exception('이미지 업로드 중 오류가 발생했습니다: $e');
    }
  }

  // 프로필 이미지 삭제
  Future<void> deleteProfileImage(String imageUrl) async {
    try {
      // Firebase Storage의 URL에서 파일 경로 추출
      final ref = _storage.refFromURL(imageUrl);
      await ref.delete();
    } catch (e) {
      throw Exception('이미지 삭제 중 오류가 발생했습니다: $e');
    }
  }

  // 비밀번호 변경
  Future<void> changePassword(String currentPassword, String newPassword) async {
    try {
      final user = _firebaseService.currentUser; // FirebaseService 프로퍼티 사용
      if (user == null) {
        throw Exception('사용자 로그인이 필요합니다');
      }

      if (user.email == null) {
        throw Exception('이메일 정보가 없습니다');
      }

      // 현재 비밀번호로 재인증
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );
      await user.reauthenticateWithCredential(credential);

      // 새 비밀번호로 업데이트
      await user.updatePassword(newPassword);
    } catch (e) {
      if (e is FirebaseAuthException) {
        switch (e.code) {
          case 'wrong-password':
            throw Exception('현재 비밀번호가 올바르지 않습니다');
          case 'weak-password':
            throw Exception('새 비밀번호가 너무 약합니다');
          default:
            throw Exception('비밀번호 변경 중 오류가 발생했습니다: ${e.message}');
        }
      } else {
        throw Exception('비밀번호 변경 중 오류가 발생했습니다: $e');
      }
    }
  }

  // 사용자 이름 업데이트
  Future<void> updateUsername(String username) async {
    final userId = _firebaseService.currentUserId; // FirebaseService 메서드 사용
    if (userId == null) {
      throw Exception('사용자 로그인이 필요합니다');
    }

    if (username.trim().isEmpty) {
      throw Exception('사용자 이름은 비워둘 수 없습니다');
    }

    try {
      // Firebase Auth 표시 이름 업데이트
      final user = _firebaseService.currentUser;
      if (user != null) {
        await user.updateDisplayName(username);
      }

      // Firestore 사용자 문서 업데이트 (UserModel의 실제 필드명 사용)
      await _firestore.collection('users').doc(userId).update({
        'user_name': username, // UserModel의 실제 필드명 사용
      });
    } catch (e) {
      throw Exception('사용자 이름 업데이트 중 오류가 발생했습니다: $e');
    }
  }

  // 프로필 이미지 URL 업데이트
  Future<void> updateProfileImageUrl(String imageUrl) async {
    final userId = _firebaseService.currentUserId;
    if (userId == null) {
      throw Exception('사용자 로그인이 필요합니다');
    }

    try {
      // Firebase Auth 프로필 사진 업데이트
      final user = _firebaseService.currentUser;
      if (user != null) {
        await user.updatePhotoURL(imageUrl);
      }

      // Firestore 사용자 문서 업데이트 (UserModel의 실제 필드명 사용)
      await _firestore.collection('users').doc(userId).update({
        'profile_image_url': imageUrl, // UserModel의 실제 필드명 사용
      });
    } catch (e) {
      throw Exception('프로필 이미지 업데이트 중 오류가 발생했습니다: $e');
    }
  }

  // 알림 설정 업데이트
  Future<void> updateNotificationSettings(bool notificationYn) async {
    final userId = _firebaseService.currentUserId;
    if (userId == null) {
      throw Exception('사용자 로그인이 필요합니다');
    }

    try {
      await _firestore.collection('users').doc(userId).update({
        'notification_yn': notificationYn,
      });
    } catch (e) {
      throw Exception('알림 설정 업데이트 중 오류가 발생했습니다: $e');
    }
  }

  // 테마 모드 업데이트
  Future<void> updateThemeMode(String themeMode) async {
    final userId = _firebaseService.currentUserId;
    if (userId == null) {
      throw Exception('사용자 로그인이 필요합니다');
    }

    try {
      await _firestore.collection('users').doc(userId).update({
        'theme_mode': themeMode,
      });
    } catch (e) {
      throw Exception('테마 설정 업데이트 중 오류가 발생했습니다: $e');
    }
  }

  // 선호 음성 업데이트
  Future<void> updatePreferredVoice(String preferredVoice) async {
    final userId = _firebaseService.currentUserId;
    if (userId == null) {
      throw Exception('사용자 로그인이 필요합니다');
    }

    try {
      await _firestore.collection('users').doc(userId).update({
        'preferred_voice': preferredVoice,
      });
    } catch (e) {
      throw Exception('선호 음성 업데이트 중 오류가 발생했습니다: $e');
    }
  }

  // 언어 설정 업데이트
  Future<void> updateLanguage(String language) async {
    final userId = _firebaseService.currentUserId;
    if (userId == null) {
      throw Exception('사용자 로그인이 필요합니다');
    }

    try {
      await _firestore.collection('users').doc(userId).update({
        'language': language,
      });
    } catch (e) {
      throw Exception('언어 설정 업데이트 중 오류가 발생했습니다: $e');
    }
  }

  // 성별 업데이트
  Future<void> updateGender(String? gender) async {
    final userId = _firebaseService.currentUserId;
    if (userId == null) {
      throw Exception('사용자 로그인이 필요합니다');
    }

    try {
      await _firestore.collection('users').doc(userId).update({
        'gender': gender,
      });
    } catch (e) {
      throw Exception('성별 설정 업데이트 중 오류가 발생했습니다: $e');
    }
  }

  // 연령대 업데이트
  Future<void> updateAgeGroup(String? ageGroup) async {
    final userId = _firebaseService.currentUserId;
    if (userId == null) {
      throw Exception('사용자 로그인이 필요합니다');
    }

    try {
      await _firestore.collection('users').doc(userId).update({
        'age_group': ageGroup,
      });
    } catch (e) {
      throw Exception('연령대 설정 업데이트 중 오류가 발생했습니다: $e');
    }
  }

  // 선호 활동 업데이트
  Future<void> updatePreferredActivities(List<String> preferredActivities) async {
    final userId = _firebaseService.currentUserId;
    if (userId == null) {
      throw Exception('사용자 로그인이 필요합니다');
    }

    try {
      await _firestore.collection('users').doc(userId).update({
        'preferred_activities': preferredActivities,
      });
    } catch (e) {
      throw Exception('선호 활동 업데이트 중 오류가 발생했습니다: $e');
    }
  }

  // Whisper API 사용 설정 업데이트
  Future<void> updateWhisperApiUsage(bool useWhisperApiYn) async {
    final userId = _firebaseService.currentUserId;
    if (userId == null) {
      throw Exception('사용자 로그인이 필요합니다');
    }

    try {
      await _firestore.collection('users').doc(userId).update({
        'use_whisper_api_yn': useWhisperApiYn,
      });
    } catch (e) {
      throw Exception('Whisper API 설정 업데이트 중 오류가 발생했습니다: $e');
    }
  }

  // 자동 대화 저장 설정 업데이트
  Future<void> updateAutoSaveConversations(bool autoSaveConversationsYn) async {
    final userId = _firebaseService.currentUserId;
    if (userId == null) {
      throw Exception('사용자 로그인이 필요합니다');
    }

    try {
      await _firestore.collection('users').doc(userId).update({
        'auto_save_conversations_yn': autoSaveConversationsYn,
      });
    } catch (e) {
      throw Exception('자동 저장 설정 업데이트 중 오류가 발생했습니다: $e');
    }
  }

  // 이메일 변경 (이메일 인증 필요)
  Future<void> updateEmail(String newEmail, String password) async {
    try {
      final user = _firebaseService.currentUser; // FirebaseService 프로퍼티 사용
      if (user == null) {
        throw Exception('사용자 로그인이 필요합니다');
      }

      if (user.email == null) {
        throw Exception('이메일 정보가 없습니다');
      }

      // 현재 비밀번호로 재인증
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: password,
      );
      await user.reauthenticateWithCredential(credential);

      // 이메일 업데이트
      await user.updateEmail(newEmail);

      // Firestore 사용자 문서는 직접 업데이트
      // UserModel에서 email 필드는 생성자에서만 설정되므로 직접 업데이트
      // 실제로는 Firebase Auth의 email이 primary이므로 Firestore 업데이트는 선택사항
    } catch (e) {
      if (e is FirebaseAuthException) {
        switch (e.code) {
          case 'email-already-in-use':
            throw Exception('이미 사용 중인 이메일입니다');
          case 'wrong-password':
            throw Exception('비밀번호가 올바르지 않습니다');
          case 'invalid-email':
            throw Exception('유효하지 않은 이메일 형식입니다');
          case 'requires-recent-login':
            throw Exception('보안을 위해 재로그인이 필요합니다');
          default:
            throw Exception('이메일 변경 중 오류가 발생했습니다: ${e.message}');
        }
      } else {
        throw Exception('이메일 변경 중 오류가 발생했습니다: $e');
      }
    }
  }

  // 계정 삭제
  Future<void> deleteAccount(String password) async {
    try {
      final userId = _firebaseService.currentUserId; // FirebaseService 메서드 사용
      if (userId == null) {
        throw Exception('사용자 로그인이 필요합니다');
      }

      // For security, Firebase requires re-authentication for sensitive operations like account deletion.
      final currentUser = _firebaseService.currentUser; // FirebaseService 프로퍼티 사용
      if (currentUser == null) {
        throw Exception('사용자 로그인이 필요합니다.');
      }
      if (currentUser.email == null) {
        throw Exception('이메일 정보가 없어 재인증할 수 없습니다.');
      }

      AuthCredential credential = EmailAuthProvider.credential(
        email: currentUser.email!,
        password: password,
      );

      await currentUser.reauthenticateWithCredential(credential);

      // 사용자 데이터 및 계정 삭제
      // 데이터 삭제는 Cloud Functions에서 처리하는 것이 일반적이지만,
      // 여기서는 클라이언트 측에서 가능한 범위 내에서 사용자 문서 삭제를 포함.
      await _firestore.collection('users').doc(userId).delete(); // Use userId here
      await currentUser.delete();
      // Additional cleanup for conversations, mood records etc. would be ideal
      // to do via Cloud Functions or in dedicated service calls here.

    } catch (e) {
      if (e is FirebaseAuthException) {
        switch (e.code) {
          case 'wrong-password':
            throw Exception('비밀번호가 올바르지 않습니다.');
          case 'requires-recent-login':
            throw Exception('보안을 위해 재로그인이 필요합니다.');
          case 'user-mismatch':
            throw Exception('잘못된 사용자 정보입니다.');
          default:
            throw Exception('계정 삭제 중 오류가 발생했습니다: ${e.message}');
        }
      } else {
        throw Exception('계정 삭제 중 오류가 발생했습니다: $e');
      }
    }
  }

  // 사용자 데이터 가져오기 (편의 메서드)
  Future<UserModel?> getCurrentUserData() async {
    final userId = _firebaseService.currentUserId;
    if (userId == null) return null;

    return await _firebaseService.getUserData(userId);
  }
}