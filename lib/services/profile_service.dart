// lib/services/profile_service.dart
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as path;
import 'package:uuid/uuid.dart';
import 'auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Explicitly import firebase_auth
import 'package:cloud_firestore/cloud_firestore.dart'; // Explicitly import cloud_firestore

// Provider for the profile service
final profileServiceProvider = Provider<ProfileService>((ref) {
  final authService = ref.watch(authServiceProvider);
  return ProfileService(authService);
});

class ProfileService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final AuthService _authService;
  final Uuid _uuid = const Uuid();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance; // Add Firestore instance

  ProfileService(this._authService);

  // 프로필 이미지 업로드
  Future<String> uploadProfileImage(File imageFile) async {
    final userId = _authService.getCurrentUserId();
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
      final user = _authService.getCurrentUser();
      if (user == null) {
        throw Exception('사용자 로그인이 필요합니다');
      }

      if (user.email == null) {
        throw Exception('이메일 정보가 없습니다');
      }

      // 현재 비밀번호로 로그인 시도하여 확인
      await _authService.loginWithEmailAndPassword(
        user.email!,
        currentPassword,
      );

      // 새 비밀번호로 업데이트
      await user.updatePassword(newPassword);
    } catch (e) {
      if (e.toString().contains('wrong-password')) {
        throw Exception('현재 비밀번호가 올바르지 않습니다');
      } else {
        rethrow; // Rethrow other exceptions from AuthService.loginWithEmailAndPassword
      }
    }
  }

  // 알림 설정 업데이트
  Future<void> updateNotificationSettings({
    required bool emailNotifications,
    required bool dailyCheckInReminder,
    required bool weeklySummaryEnabled,
  }) async {
    final userId = _authService.getCurrentUserId();
    if (userId == null) {
      throw Exception('사용자 로그인이 필요합니다');
    }

    try {
      final user = await _authService.getUserModel(userId);
      final updatedUser = user.copyWith(
        emailNotifications: emailNotifications,
        dailyCheckInReminder: dailyCheckInReminder,
        weeklySummaryEnabled: weeklySummaryEnabled,
      );

      await _authService.updateUserModel(updatedUser);
    } catch (e) {
      throw Exception('알림 설정 업데이트 중 오류가 발생했습니다: $e');
    }
  }

  // 사용자 이름 업데이트
  Future<void> updateUsername(String username) async {
    final userId = _authService.getCurrentUserId();
    if (userId == null) {
      throw Exception('사용자 로그인이 필요합니다');
    }

    if (username.trim().isEmpty) {
      throw Exception('사용자 이름은 비워둘 수 없습니다');
    }

    try {
      // Firebase Auth 표시 이름 업데이트
      await _authService.updateProfile(displayName: username);

      // Firestore 사용자 문서 업데이트 (AuthService will handle encoding)
      final user = await _authService.getUserModel(userId);
      final updatedUser = user.copyWith(userName: username);

      await _authService.updateUserModel(updatedUser);
    } catch (e) {
      throw Exception('사용자 이름 업데이트 중 오류가 발생했습니다: $e');
    }
  }

  // 이메일 변경 (이메일 인증 필요)
  Future<void> updateEmail(String newEmail, String password) async {
    try {
      final user = _authService.getCurrentUser();
      if (user == null) {
        throw Exception('사용자 로그인이 필요합니다');
      }

      if (user.email == null) {
        throw Exception('이메일 정보가 없습니다');
      }

      // 현재 비밀번호로 로그인 시도하여 확인
      await _authService.loginWithEmailAndPassword(
        user.email!,
        password,
      );

      // 이메일 업데이트
      await user.updateEmail(newEmail);

      // Firestore 사용자 문서 업데이트
      final userModel = await _authService.getUserModel(user.uid);
      final updatedUser = userModel.copyWith(email: newEmail);

      await _authService.updateUserModel(updatedUser);
    } catch (e) {
      if (e.toString().contains('email-already-in-use')) {
        throw Exception('이미 사용 중인 이메일입니다');
      } else if (e.toString().contains('wrong-password')) {
        throw Exception('비밀번호가 올바르지 않습니다');
      } else if (e.toString().contains('invalid-email')) {
        throw Exception('유효하지 않은 이메일 형식입니다');
      } else if (e.toString().contains('requires-recent-login')) {
        throw Exception('보안을 위해 재로그인이 필요합니다');
      } else {
        rethrow; // Rethrow other exceptions
      }
    }
  }

  // 계정 삭제
  Future<void> deleteAccount(String password) async {
    try {
      final userId = _authService.getCurrentUserId();
      if (userId == null) {
        throw Exception('사용자 로그인이 필요합니다');
      }

      // For security, Firebase requires re-authentication for sensitive operations like account deletion.
      // Firebase provides a method to reauthenticate a user.
      final currentUser = _authService.getCurrentUser();
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
      // Example: _ref.read(conversationServiceProvider).deleteAllConversations(); // if dependencies allow

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
}