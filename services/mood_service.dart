// lib/services/mood_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../models/mood_record_model.dart'; // MoodRecord 모델이 이미 수정되었다고 가정
import 'auth_service.dart';
import '../utils/encoding_utils.dart'; // Import EncodingUtils for mood, note, tags

// Provider for the mood service
final moodServiceProvider = Provider<MoodService>((ref) {
  final authService = ref.watch(authServiceProvider);
  return MoodService(authService);
});

class MoodService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthService _authService;
  final Uuid _uuid = const Uuid();

  MoodService(this._authService);

  // 사용자의 감정 기록 스트림 가져오기
  Stream<List<MoodRecord>> getUserMoodRecords() {
    final userId = _authService.getCurrentUserId();
    if (userId == null) {
      return Stream.value([]);
    }

    return _firestore
        .collection('mood_tracking') // 컬렉션명 mood_tracking (스키마 반영)
        .where('user_id', isEqualTo: userId) // user_id (스키마 반영)
        .orderBy('recorded_at', descending: true) // recorded_at (스키마 반영)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => MoodRecord.fromFirestore(doc)).toList();
    });
  }

  // 새 감정 기록 추가
  Future<MoodRecord> addMoodRecord({
    required String moodLabel, // mood -> moodLabel
    required double moodScore, // mood_score 추가
    String? notes, // note -> notes
    String? conversationId, // conversation_id 추가
  }) async {
    final userId = _authService.getCurrentUserId();
    if (userId == null) {
      throw Exception('사용자 로그인이 필요합니다');
    }

    final recordId = _uuid.v4();
    final now = DateTime.now();

    final moodRecord = MoodRecord(
      id: recordId,
      userId: userId,
      moodLabel: moodLabel,
      moodScore: moodScore,
      notes: notes ?? '',
      conversationId: conversationId, // conversation_id 추가
      recordedAt: now,
      createdAt: now,
    );

    await _firestore
        .collection('mood_tracking') // 컬렉션명 mood_tracking (스키마 반영)
        .doc(recordId)
        .set(moodRecord.toFirestore()); // MoodRecord.toFirestore will handle encoding

    // 사용자 문서에 최근 감정 상태 업데이트 (스키마에 맞게 필드명 변경)
    // 'lastMood' 필드도 인코딩 필요
    await _firestore.collection('users').doc(userId).update({
      'last_mood': EncodingUtils.encodeToBase64(moodLabel), // last_mood (스키마 반영)
      'last_mood_recorded_at': now, // last_mood_recorded_at (스키마 반영)
    });

    return moodRecord;
  }

  // 감정 기록 삭제
  Future<void> deleteMoodRecord(String recordId) async {
    await _firestore.collection('mood_tracking').doc(recordId).delete(); // 컬렉션명 mood_tracking (스키मा 반영)
  }

  // 감정 기록 업데이트
  Future<void> updateMoodRecord({
    required String recordId,
    String? moodLabel, // mood -> moodLabel (선택적 업데이트)
    double? moodScore, // mood_score (선택적 업데이트)
    String? notes, // note -> notes (선택적 업데이트)
    String? conversationId, // conversation_id (선택적 업데이트)
  }) async {
    final updates = <String, dynamic>{
      'updatedAt': DateTime.now(), // updatedAt 필드는 Firestore 스키마에 없지만, 관례상 추가
    };

    if (moodLabel != null) {
      updates['mood_label'] = EncodingUtils.encodeToBase64(moodLabel); // mood_label (스키마 반영)
    }
    if (moodScore != null) {
      updates['mood_score'] = moodScore; // mood_score (스키마 반영)
    }
    if (notes != null) {
      updates['notes'] = EncodingUtils.encodeToBase64(notes); // notes (스키마 반영)
    }
    if (conversationId != null) {
      updates['conversation_id'] = conversationId; // conversation_id (스키마 반영)
    }

    await _firestore.collection('mood_tracking').doc(recordId).update(updates); // 컬렉션명 mood_tracking (스키마 반영)
  }

  // 특정 기간의 감정 기록 가져오기
  Future<List<MoodRecord>> getMoodRecordsByPeriod(int days) async {
    final userId = _authService.getCurrentUserId();
    if (userId == null) {
      throw Exception('사용자 로그인이 필요합니다');
    }

    final now = DateTime.now();
    final startDate = now.subtract(Duration(days: days));

    final snapshot = await _firestore
        .collection('mood_tracking') // 컬렉션명 mood_tracking (스키마 반영)
        .where('user_id', isEqualTo: userId) // user_id (스키마 반영)
        .where('recorded_at', isGreaterThanOrEqualTo: startDate) // recorded_at (스키마 반영)
        .orderBy('recorded_at', descending: true) // recorded_at (스키마 반영)
        .get();

    return snapshot.docs.map((doc) => MoodRecord.fromFirestore(doc)).toList();
  }

  // 감정 통계 계산
  Future<Map<String, dynamic>> getMoodStatistics(int days) async {
    final records = await getMoodRecordsByPeriod(days);

    if (records.isEmpty) {
      return {
        'averageMood': 'neutral',
        'moodCounts': {},
        'totalCount': 0,
        'topMood': 'neutral',
      };
    }

    // 각 감정별 개수 집계
    final moodCounts = <String, int>{};
    for (final record in records) {
      moodCounts[record.moodLabel] = (moodCounts[record.moodLabel] ?? 0) + 1; // moodLabel 사용
    }

    // 가장 많은 감정 찾기
    String topMood = 'neutral';
    int maxCount = 0;
    moodCounts.forEach((mood, count) {
      if (count > maxCount) {
        maxCount = count;
        topMood = mood;
      }
    });

    // 평균 감정 점수 계산 (moodScore 사용)
    double totalScore = 0;
    for (final record in records) {
      totalScore += record.moodScore; // moodScore 사용
    }

    // 평균 점수를 감정으로 변환 (스키마에 맞게 0~100 스케일 고려)
    final averageScore = totalScore / records.length;
    String averageMood;
    if (averageScore <= 20) { // 0-20 매우 나쁨
      averageMood = 'bad';
    } else if (averageScore <= 40) { // 21-40 나쁨
      averageMood = 'bad';
    } else if (averageScore <= 60) { // 41-60 보통
      averageMood = 'neutral';
    } else if (averageScore <= 80) { // 61-80 좋음
      averageMood = 'good';
    } else { // 81-100 매우 좋음
      averageMood = 'good';
    }

    return {
      'averageMood': averageMood,
      'moodCounts': moodCounts,
      'totalCount': records.length,
      'topMood': topMood,
    };
  }

  // 주간 감정 요약
  Future<String> getWeeklySummary() async {
    final stats = await getMoodStatistics(7);
    final moodCounts = stats['moodCounts'] as Map<String, int>;
    final totalCount = stats['totalCount'] as int;
    final topMood = stats['topMood'] as String;
    final averageMood = stats['averageMood'] as String;

    String topMoodText;
    switch (topMood) {
      case 'good':
        topMoodText = '좋음';
        break;
      case 'neutral':
        topMoodText = '보통';
        break;
      case 'bad':
        topMoodText = '나쁨';
        break;
      default:
        topMoodText = '알 수 없음';
    }

    String averageMoodText;
    switch (averageMood) {
      case 'good':
        averageMoodText = '좋음';
        break;
      case 'neutral':
        averageMoodText = '보통';
        break;
      case 'bad':
        averageMoodText = '나쁨';
        break;
      default:
        averageMoodText = '알 수 없음';
    }

    if (totalCount == 0) {
      return '이번 주에는 기록된 감정이 없습니다.';
    }

    return '''
지난 7일 동안 총 $totalCount개의 감정을 기록하셨습니다.
가장 많이 느끼신 감정은 '$topMoodText'(${moodCounts[topMood] ?? 0}회)이었으며,
평균적인 감정 상태는 '$averageMoodText'입니다.
''';
  }
}