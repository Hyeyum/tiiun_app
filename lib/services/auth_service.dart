// 새 폴더/lib/services/auth_service.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';
import '../models/backend_user_model.dart';
import '../utils/encoding_utils.dart';
import '../utils/logger.dart';
import 'user_api_service.dart';
import 'api_client.dart';

// 인증 서비스 프로바이더
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

// 현재 사용자 프로바이더
final currentUserProvider = StreamProvider<User?>((ref) {
  return ref.watch(authServiceProvider).authStateChanges;
});

// 현재 사용자 모델 프로바이더
final currentUserModelProvider = FutureProvider<UserModel?>((ref) async {
  final user = await ref.watch(currentUserProvider.future);
  if (user != null) {
    return ref.watch(authServiceProvider).getUserModel(user.uid);
  }
  return null;
});

// 현재 백엔드 사용자 프로바이더
final currentBackendUserProvider = FutureProvider<BackendUser?>((ref) async {
  final user = await ref.watch(currentUserProvider.future);
  if (user != null) {
    return ref.watch(authServiceProvider).getBackendUser();
  }
  return null;
});

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final UserApiService _userApiService = UserApiService();
  // 제거됨: final Logger _logger = Logger(); // 더 이상 필요 없음

  // 인증 상태 변경 스트림
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // 사용자가 로그인되어 있는지 확인
  Future<bool> isUserLoggedIn() async {
    return _auth.currentUser != null;
  }

  // 현재 사용자 ID 가져오기
  String? getCurrentUserId() {
    return _auth.currentUser?.uid;
  }

  // 현재 사용자 가져오기
  User? getCurrentUser() {
    return _auth.currentUser;
  }

  // 이메일과 비밀번호로 등록
  Future<UserCredential> registerWithEmailAndPassword(
      String email, String password, String username) async {
    try {
      // Firebase Auth에 사용자 생성
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Firestore에 사용자 문서 생성
      if (userCredential.user != null) {
        await _createUserDocument(userCredential.user!.uid, email, username); // 닉네임 직접 전달

        // 백엔드와 사용자 동기화
        await _syncWithBackend(userCredential.user!, username: username);
      }

      return userCredential;
    } catch (e) {
      AppLogger.error('registerWithEmailAndPassword 오류: $e');
      rethrow; // 오류를 다시 던져 호출자가 처리하게 함
    }
  }

  // 이메일과 비밀번호로 로그인
  Future<UserCredential> loginWithEmailAndPassword(
      String email, String password) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // 로그인 후 백엔드와 동기화
      if (userCredential.user != null) {
        await _syncWithBackend(userCredential.user!);
      }

      return userCredential;
    } catch (e) {
      AppLogger.error('loginWithEmailAndPassword 오류: $e');
      rethrow; // 오류를 다시 던져 호출자가 처리하게 함
    }
  }

  // Firestore에 사용자 문서 생성
  Future<void> _createUserDocument(String uid, String email, String username) async {
    final now = DateTime.now();
    // Base64 인코딩 제거: username을 직접 저장
    // final encodedUsername = EncodingUtils.encodeToBase64(username); // 이 줄을 제거

    await _firestore.collection('users').doc(uid).set({
      'user_name': username, // 인코딩 없이 직접 저장
      'email': email,
      'phoneNumber': null,
      'birthDate': null,
      'profile_image_url': null,
      'preferred_voice': 'default',
      'notification_yn': true,
      'dailyCheckInReminder': false,
      'weeklySummaryEnabled': true,
      'created_at': now,
      'language': 'ko',
      'preferred_activities': [],
      'use_whisper_api_yn': false,
      'theme_mode': 'light',
      'auto_save_conversations_yn': true,
      'age_group': null,
      'emailNotifications': true,
    });
    AppLogger.info('Firestore 사용자 문서 생성 완료: $uid');
  }

  // 로그아웃
  Future<void> logout() async {
    try {
      await _auth.signOut();
    } catch (e) {
      AppLogger.error('logout 오류: $e');
      rethrow;
    }
  }

  // 비밀번호 재설정
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      AppLogger.error('resetPassword 오류: $e');
      rethrow;
    }
  }

  // 사용자 프로필 업데이트
  Future<void> updateProfile({
    String? displayName,
    String? photoURL,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await user.updateDisplayName(displayName);
        await user.updatePhotoURL(photoURL);
        AppLogger.info('Firebase 사용자 프로필 업데이트 완료: ${user.uid}');
      }
    } catch (e) {
      AppLogger.error('updateProfile 오류: $e');
      rethrow;
    }
  }

  // 테스트를 위한 폴백이 있는 사용자 모델 가져오기
  Future<UserModel> getUserModel(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return UserModel.fromFirestore(doc.data()!, uid, doc.data()!['email'] ?? '');
      } else {
        // 사용자 데이터가 없는 경우(테스트 환경에서) 필요한 기본 사용자 데이터 생성
        await _createDefaultUserDocument(uid);

        // 생성된 기본 사용자 데이터 반환
        final newDoc = await _firestore.collection('users').doc(uid).get();
        if (newDoc.exists) {
          return UserModel.fromFirestore(newDoc.data()!, uid, newDoc.data()!['email'] ?? '');
        } else {
          // 그래도 사용자 데이터가 없는 경우 기본값 사용
          AppLogger.warning('Firestore에서 사용자 문서 생성 후에도 데이터를 찾을 수 없어 기본 UserModel 반환: $uid');
          return _createDefaultUserModel(uid);
        }
      }
    } catch (e) {
      AppLogger.error('사용자 정보 가져오기 오류: $e', e);
      // 오류 발생 시 기본 사용자 모델 반환
      return _createDefaultUserModel(uid);
    }
  }

  // 기본 사용자 데이터 생성 (Firestore에 저장)
  Future<void> _createDefaultUserDocument(String uid) async {
    try {
      final user = _auth.currentUser;
      final now = DateTime.now();

      // Base64 인코딩 제거: username을 직접 저장
      // final encodedUsername = EncodingUtils.encodeToBase64(user?.displayName ?? '사용자'); // 이 줄을 제거

      await _firestore.collection('users').doc(uid).set({
        'user_name': user?.displayName ?? '사용자', // 인코딩 없이 직접 저장
        'email': user?.email ?? 'user@example.com',
        'phoneNumber': null,
        'birthDate': null,
        'profile_image_url': null,
        'preferred_voice': 'default',
        'notification_yn': true,
        'dailyCheckInReminder': false,
        'weeklySummaryEnabled': true,
        'created_at': now,
        'language': 'ko',
        'preferred_activities': [],
        'use_whisper_api_yn': false,
        'theme_mode': 'light',
        'auto_save_conversations_yn': true,
        'age_group': null,
        'emailNotifications': true,
      });

      AppLogger.info('기본 사용자 데이터 Firestore에 생성 완료: $uid');
    } catch (e) {
      AppLogger.error('기본 사용자 데이터 생성 오류: $e', e);
    }
  }

  // 기본 사용자 모델 생성 (Firestore에 저장하지 않음)
  UserModel _createDefaultUserModel(String uid) {
    final user = _auth.currentUser;
    final now = DateTime.now();

    return UserModel(
      uid: uid,
      email: user?.email ?? 'user@example.com',
      userName: user?.displayName ?? '사용자',
      createdAt: now,
      preferredVoice: 'default',
      notificationYn: true,
      gender: null,
      language: 'ko',
      preferredActivities: [],
      profileImageUrl: null,
      useWhisperApiYn: true,
      themeMode: 'light',
      autoSaveConversationsYn: true,
      ageGroup: '20s',
      emailNotifications: true,
      dailyCheckInReminder: false,
      weeklySummaryEnabled: true,
    );
  }

  // 사용자 모델 업데이트
  Future<void> updateUserModel(UserModel userModel) async {
    try {
      // Base64 인코딩 제거: userModel.userName을 직접 저장
      // final encodedUsername = EncodingUtils.encodeToBase64(userModel.userName); // 이 줄을 제거
      await _firestore.collection('users').doc(userModel.uid).update(
        // userModel.toMap()은 user_name을 인코딩된 상태로 포함할 수 있으므로, 직접 덮어쓰거나, UserModel.toMap() 로직을 변경해야 합니다.
        // 현재 UserModel.toMap()에서 user_name을 인코딩하지 않도록 되어 있으므로, userModel.toMap()을 사용해도 됩니다.
        // 다만, 확실한 Base64 제거를 위해 명시적으로 user_name을 업데이트하는 것도 고려할 수 있습니다.
        userModel.toMap()..addAll({'user_name': userModel.userName}), // user_name을 직접 저장
      );
      AppLogger.info('Firestore 사용자 모델 업데이트 완료: ${userModel.uid}');
    } catch (e) {
      AppLogger.error('updateUserModel 오류: $e');
      rethrow;
    }
  }


  // Firebase 사용자와 백엔드 동기화 (재시도 로직 포함)
  Future<void> _syncWithBackend(User firebaseUser, {String? username}) async {
    try {
      // Firebase 토큰이 준비될 때까지 잠시 대기
      await Future.delayed(Duration(milliseconds: 500));

      // Firebase 토큰 확인
      final idToken = await firebaseUser.getIdToken(true); // 강제 새로고침
      if (idToken == null || idToken.isEmpty) {
        AppLogger.warning('Firebase 토큰을 가져올 수 없어 백엔드 동기화를 건너뜁니다.');
        return;
      }

      // username이 전달되지 않은 경우 Firestore에서 가져오기 시도
      String? finalUsername = username ?? firebaseUser.displayName;
      if (finalUsername == null || finalUsername.isEmpty) {
        try {
          final doc = await _firestore.collection('users').doc(firebaseUser.uid).get();
          if (doc.exists) {
            final userData = doc.data()!;
            final fetchedUsername = userData['user_name']; // Base64 디코딩 없이 직접 가져오기
            // 마이그레이션이 완료되지 않은 경우를 대비하여 isBase64Encoded 체크 후 디코딩할 수 있습니다.
            if (fetchedUsername != null && EncodingUtils.isBase64Encoded(fetchedUsername)) {
              finalUsername = EncodingUtils.decodeFromBase64(fetchedUsername);
            } else {
              finalUsername = fetchedUsername; // 이미 디코딩된 상태 또는 Base64가 아닌 경우
            }
          }
        } catch (e) {
          AppLogger.warning('Firestore에서 username 가져오기 실패: $e');
        }
      }

      final request = CreateUserRequest(
        email: firebaseUser.email!,
        username: finalUsername, // 백엔드 CreateUserRequest의 username 필드에 직접 전달
        displayName: finalUsername,
        photoUrl: firebaseUser.photoURL,
      );

      // 최대 3번 재시도
      for (int attempt = 1; attempt <= 3; attempt++) {
        try {
          final response = await _userApiService.createOrUpdateUser(request);
          if (response.isSuccess) {
            AppLogger.info('백엔드와 동기화 성공 (시도 $attempt): ${response.data?.userId}');

            // 활성 시간 업데이트 시도 (실패해도 무시)
            try {
              await _userApiService.updateLastActiveTime();
              AppLogger.debug('마지막 활성 시간 업데이트 성공');
            } catch (activeTimeError) {
              AppLogger.warning('마지막 활성 시간 업데이트 실패: $activeTimeError');
            }

            return; // 성공하면 함수 종료
          } else {
            AppLogger.warning('백엔드 동기화 실패 (시도 $attempt): ${response.error}');
            if (attempt < 3) {
              await Future.delayed(Duration(seconds: attempt));
            }
          }
        } catch (apiError) {
          AppLogger.warning('백엔드 동기화 API 오류 (시도 $attempt): $apiError');
          if (attempt < 3) {
            await Future.delayed(Duration(seconds: attempt));
          }
        }
      }

      // 모든 재시도 실패
      AppLogger.error('백엔드 동기화 최종 실패 - 앱 사용에는 문제없음: ${firebaseUser.uid}');

    } catch (e) {
      AppLogger.error('백엔드 동기화 중 예외 발생: $e', e);
    }
  }

  // 백엔드 사용자 정보 가져오기
  Future<BackendUser?> getBackendUser() async {
    try {
      final response = await _userApiService.getCurrentUser();
      if (response.isSuccess) {
        AppLogger.debug('백엔드 사용자 정보 가져오기 성공');
        return response.data;
      } else {
        AppLogger.error('백엔드 사용자 정보 가져오기 실패: ${response.error}');
        return null;
      }
    } catch (e) {
      AppLogger.error('백엔드 사용자 정보 가져오기 중 오류: $e', e);
      return null;
    }
  }

  // 백엔드 사용자 정보 업데이트
  Future<bool> updateBackendUser(UpdateUserRequest request) async {
    try {
      final response = await _userApiService.updateUser(request);
      if (response.isSuccess) {
        AppLogger.info('백엔드 사용자 정보 업데이트 성공');
        return true;
      } else {
        AppLogger.error('백엔드 사용자 정보 업데이트 실패: ${response.error}');
        return false;
      }
    } catch (e) {
      AppLogger.error('백엔드 사용자 정보 업데이트 중 오류: $e', e);
      return false;
    }
  }

  // 백엔드에서 사용자 삭제 (계정 비활성화)
  Future<bool> deleteBackendUser() async {
    try {
      final response = await _userApiService.deleteUser();
      if (response.isSuccess) {
        AppLogger.info('백엔드 사용자 삭제 성공');
        return true;
      } else {
        AppLogger.error('백엔드 사용자 삭제 실패: ${response.error}');
        return false;
      }
    } catch (e) {
      AppLogger.error('백엔드 사용자 삭제 중 오류: $e', e);
      return false;
    }
  }

  // 수동 백엔드 동기화 (앱 실행 중 연결 복구 시 사용)
  Future<bool> manualSyncWithBackend() async {
    final user = _auth.currentUser;
    if (user == null) {
      AppLogger.warning('로그인된 사용자가 없어 백엔드 동기화를 건너뜁니다.');
      return false;
    }

    try {
      await _syncWithBackend(user);
      return true;
    } catch (e) {
      AppLogger.error('수동 백엔드 동기화 실패: $e');
      return false;
    }
  }
}