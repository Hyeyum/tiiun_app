// lib/services/recommendation_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../models/recommendation_model.dart';
import 'auth_service.dart';
import '../utils/encoding_utils.dart';
import 'package:flutter/foundation.dart';

// Provider for the recommendation service
final recommendationServiceProvider = Provider<RecommendationService>((ref) {
  final authService = ref.watch(authServiceProvider);
  return RecommendationService(authService);
});

class RecommendationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthService _authService;
  final Uuid _uuid = const Uuid();

  RecommendationService(this._authService);

  // 사용자의 추천 활동 스트림 가져오기
  Stream<List<Recommendation>> getUserRecommendations() {
    final userId = _authService.getCurrentUserId();
    if (userId == null) {
      return Stream.value([]);
    }

    return _firestore
        .collection('recommendations') // FireStore 스키마 컬렉션명
        .where('user_id', isEqualTo: userId) // user_id (스키마 반영)
        .orderBy('created_at', descending: true) // created_at (스키마 반영)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Recommendation.fromFirestore(doc)).toList();
    });
  }

  // 새 추천 활동 추가
  Future<Recommendation> addRecommendation({
    required String activityType, // activity_type (스키마 반영)
    required String title,
    required String description,
    required int duration,
    String? conversationId, // conversation_id (스키마 반영)
    String? userRating, // user_rating (스키마 반영)
  }) async {
    final userId = _authService.getCurrentUserId();
    if (userId == null) {
      throw Exception('사용자 로그인이 필요합니다');
    }

    final recommendationId = _uuid.v4();
    final now = DateTime.now();

    final recommendation = Recommendation(
      id: recommendationId,
      userId: userId,
      conversationId: conversationId,
      activityType: activityType,
      title: title,
      description: description,
      duration: duration,
      userRating: userRating,
      createdAt: now,
    );

    await _firestore
        .collection('recommendations') // 컬렉션명 recommendations (스키마 반영)
        .doc(recommendationId)
        .set(recommendation.toFirestore()); // Recommendation.toFirestore에서 인코딩 처리

    debugPrint('추천 활동 추가 완료: $title');
    return recommendation;
  }

  // 추천 활동 삭제
  Future<void> deleteRecommendation(String recommendationId) async {
    try {
      await _firestore
          .collection('recommendations')
          .doc(recommendationId)
          .delete();
      debugPrint('추천 활동 삭제 완료: $recommendationId');
    } catch (e) {
      debugPrint('추천 활동 삭제 오류: $e');
      throw Exception('추천 활동을 삭제할 수 없습니다: $e');
    }
  }

  // 추천 활동 업데이트
  Future<void> updateRecommendation({
    required String recommendationId,
    String? activityType,
    String? title,
    String? description,
    int? duration,
    String? userRating,
  }) async {
    try {
      final updates = <String, dynamic>{};

      if (activityType != null) {
        updates['activity_type'] = activityType; // activity_type (스키마 반영)
      }
      if (title != null) {
        updates['title'] = EncodingUtils.encodeToBase64(title); // title 인코딩
      }
      if (description != null) {
        updates['description'] = EncodingUtils.encodeToBase64(description); // description 인코딩
      }
      if (duration != null) {
        updates['duration'] = duration;
      }
      if (userRating != null) {
        updates['user_rating'] = userRating; // user_rating (스키마 반영)
      }

      if (updates.isNotEmpty) {
        await _firestore
            .collection('recommendations')
            .doc(recommendationId)
            .update(updates);
        debugPrint('추천 활동 업데이트 완료: $recommendationId');
      }
    } catch (e) {
      debugPrint('추천 활동 업데이트 오류: $e');
      throw Exception('추천 활동을 업데이트할 수 없습니다: $e');
    }
  }

  // 특정 대화의 추천 활동 가져오기
  Future<List<Recommendation>> getRecommendationsByConversation(String conversationId) async {
    final userId = _authService.getCurrentUserId();
    if (userId == null) {
      throw Exception('사용자 로그인이 필요합니다');
    }

    try {
      final snapshot = await _firestore
          .collection('recommendations')
          .where('user_id', isEqualTo: userId) // user_id (스키마 반영)
          .where('conversation_id', isEqualTo: conversationId) // conversation_id (스키마 반영)
          .orderBy('created_at', descending: true) // created_at (스키마 반영)
          .get();

      return snapshot.docs.map((doc) => Recommendation.fromFirestore(doc)).toList();
    } catch (e) {
      debugPrint('대화별 추천 활동 가져오기 오류: $e');
      return [];
    }
  }

  // 활동 유형별 추천 가져오기
  Future<List<Recommendation>> getRecommendationsByType(String activityType) async {
    final userId = _authService.getCurrentUserId();
    if (userId == null) {
      throw Exception('사용자 로그인이 필요합니다');
    }

    try {
      final snapshot = await _firestore
          .collection('recommendations')
          .where('user_id', isEqualTo: userId) // user_id (스키마 반영)
          .where('activity_type', isEqualTo: activityType) // activity_type (스키마 반영)
          .orderBy('created_at', descending: true) // created_at (스키마 반영)
          .get();

      return snapshot.docs.map((doc) => Recommendation.fromFirestore(doc)).toList();
    } catch (e) {
      debugPrint('유형별 추천 활동 가져오기 오류: $e');
      return [];
    }
  }

  // 사용자 평가 업데이트
  Future<void> updateUserRating(String recommendationId, String rating) async {
    try {
      await _firestore
          .collection('recommendations')
          .doc(recommendationId)
          .update({
            'user_rating': rating, // user_rating (스키마 반영)
          });
      debugPrint('추천 활동 평가 업데이트 완료: $recommendationId -> $rating');
    } catch (e) {
      debugPrint('추천 활동 평가 업데이트 오류: $e');
      throw Exception('평가를 업데이트할 수 없습니다: $e');
    }
  }

  // 추천 통계 가져오기
  Future<Map<String, dynamic>> getRecommendationStats() async {
    final userId = _authService.getCurrentUserId();
    if (userId == null) {
      throw Exception('사용자 로그인이 필요합니다');
    }

    try {
      final snapshot = await _firestore
          .collection('recommendations')
          .where('user_id', isEqualTo: userId) // user_id (스키마 반영)
          .get();

      final recommendations = snapshot.docs
          .map((doc) => Recommendation.fromFirestore(doc))
          .toList();

      if (recommendations.isEmpty) {
        return {
          'totalCount': 0,
          'typeStats': <String, int>{},
          'avgDuration': 0,
          'ratedCount': 0,
        };
      }

      // 유형별 통계
      final typeStats = <String, int>{};
      int totalDuration = 0;
      int ratedCount = 0;

      for (final rec in recommendations) {
        typeStats[rec.activityType] = (typeStats[rec.activityType] ?? 0) + 1;
        totalDuration += rec.duration;
        if (rec.userRating != null && rec.userRating!.isNotEmpty) {
          ratedCount++;
        }
      }

      return {
        'totalCount': recommendations.length,
        'typeStats': typeStats,
        'avgDuration': recommendations.isNotEmpty ? totalDuration / recommendations.length : 0,
        'ratedCount': ratedCount,
      };
    } catch (e) {
      debugPrint('추천 통계 가져오기 오류: $e');
      return {
        'totalCount': 0,
        'typeStats': <String, int>{},
        'avgDuration': 0,
        'ratedCount': 0,
      };
    }
  }

  // 최근 추천 활동 가져오기 (개수 제한)
  Future<List<Recommendation>> getRecentRecommendations({int limit = 10}) async {
    final userId = _authService.getCurrentUserId();
    if (userId == null) {
      throw Exception('사용자 로그인이 필요합니다');
    }

    try {
      final snapshot = await _firestore
          .collection('recommendations')
          .where('user_id', isEqualTo: userId) // user_id (스키마 반영)
          .orderBy('created_at', descending: true) // created_at (스키마 반영)
          .limit(limit)
          .get();

      return snapshot.docs.map((doc) => Recommendation.fromFirestore(doc)).toList();
    } catch (e) {
      debugPrint('최근 추천 활동 가져오기 오류: $e');
      return [];
    }
  }

  // 모든 추천 활동 삭제
  Future<void> deleteAllRecommendations() async {
    final userId = _authService.getCurrentUserId();
    if (userId == null) {
      throw Exception('사용자 로그인이 필요합니다');
    }

    try {
      final snapshot = await _firestore
          .collection('recommendations')
          .where('user_id', isEqualTo: userId) // user_id (스키마 반영)
          .get();

      if (snapshot.docs.isEmpty) {
        return;
      }

      // 배치 삭제
      final batch = _firestore.batch();
      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
      debugPrint('모든 추천 활동 삭제 완료: ${snapshot.docs.length}개');
    } catch (e) {
      debugPrint('모든 추천 활동 삭제 오류: $e');
      throw Exception('모든 추천 활동을 삭제할 수 없습니다: $e');
    }
  }

  // AI 기반 맞춤형 추천 생성 (예시 로직)
  Future<List<String>> generatePersonalizedRecommendations({
    required String currentMood,
    required List<String> preferredActivities,
    int? availableTime,
  }) async {
    try {
      // 현재 기분과 선호 활동을 기반으로 추천 생성
      List<String> recommendations = [];

      // 기분별 추천 로직
      switch (currentMood.toLowerCase()) {
        case 'stressed':
        case 'anxious':
          recommendations.addAll([
            '심호흡 명상 (5분)',
            '가벼운 산책',
            '차분한 음악 감상',
            '따뜻한 차 마시기',
          ]);
          break;
        case 'sad':
        case 'depressed':
          recommendations.addAll([
            '감사 일기 쓰기',
            '친구와 대화하기',
            '좋아하는 영화 보기',
            '취미 활동',
          ]);
          break;
        case 'angry':
        case 'frustrated':
          recommendations.addAll([
            '운동하기',
            '일기 쓰기',
            '음악 듣기',
            '차분한 환경에서 휴식',
          ]);
          break;
        case 'happy':
        case 'excited':
          recommendations.addAll([
            '새로운 도전하기',
            '창작 활동',
            '사람들과 시간 보내기',
            '야외 활동',
          ]);
          break;
        default:
          recommendations.addAll([
            '독서',
            '가벼운 운동',
            '명상',
            '취미 활동',
          ]);
      }

      // 사용 가능한 시간에 따른 필터링
      if (availableTime != null && availableTime <= 15) {
        recommendations = recommendations
            .where((rec) => rec.contains('5분') || rec.contains('10분') || rec.contains('짧은'))
            .toList();
      }

      // 선호 활동과 매칭
      if (preferredActivities.isNotEmpty) {
        final filteredRecs = <String>[];
        for (final pref in preferredActivities) {
          final matchingRecs = recommendations
              .where((rec) => rec.toLowerCase().contains(pref.toLowerCase()))
              .toList();
          filteredRecs.addAll(matchingRecs);
        }
        if (filteredRecs.isNotEmpty) {
          recommendations = filteredRecs;
        }
      }

      return recommendations.take(5).toList(); // 최대 5개 추천
    } catch (e) {
      debugPrint('맞춤형 추천 생성 오류: $e');
      return ['휴식하기', '깊게 숨쉬기', '물 마시기']; // 기본 추천
    }
  }
}
