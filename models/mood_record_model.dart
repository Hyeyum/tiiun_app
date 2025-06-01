import 'package:cloud_firestore/cloud_firestore.dart';

class MoodRecord {
  final String id;
  final String userId;
  final String moodLabel; // mood -> moodLabel
  final double moodScore; // 추가
  final String notes; // note -> notes
  final String? conversationId; // 추가
  final DateTime recordedAt;
  final DateTime createdAt;
  
  MoodRecord({
    required this.id,
    required this.userId,
    required this.moodLabel,
    required this.moodScore,
    this.notes = '',
    this.conversationId, // 추가
    required this.recordedAt,
    required this.createdAt,
  });
  
  // 빈 기록 생성
  factory MoodRecord.empty() {
    return MoodRecord(
      id: '',
      userId: '',
      moodLabel: 'neutral',
      moodScore: 0.0, // 기본값 설정
      recordedAt: DateTime.now(),
      createdAt: DateTime.now(),
    );
  }
  
  // Firestore 데이터에서 객체 생성
  factory MoodRecord.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return MoodRecord(
      id: doc.id,
      userId: data['user_id'] ?? '', // user_id (스키마 반영)
      moodLabel: data['mood_label'] ?? 'neutral', // mood_label (스키마 반영)
      moodScore: (data['mood_score'] as num?)?.toDouble() ?? 0.0, // mood_score (스키마 반영)
      notes: data['notes'] ?? '', // notes (스키마 반영)
      conversationId: data['conversation_id'], // conversation_id (스키마 반영)
      recordedAt: (data['recorded_at'] as Timestamp).toDate(), // recorded_at (스키마 반영)
      createdAt: (data['created_at'] as Timestamp).toDate(), // created_at (스키마 반영)
    );
  }
  
  // Firestore에 저장할 데이터로 변환
  Map<String, dynamic> toFirestore() {
    return {
      'user_id': userId, // user_id (스키마 반영)
      'mood_label': moodLabel, // mood_label (스키마 반영)
      'mood_score': moodScore, // mood_score (스키마 반영)
      'notes': notes, // notes (스키마 반영)
      'conversation_id': conversationId, // conversation_id (스키마 반영)
      'recorded_at': Timestamp.fromDate(recordedAt), // recorded_at (스키마 반영)
      'created_at': Timestamp.fromDate(createdAt), // created_at (스키마 반영)
    };
  }
  
  // 객체 복사본 생성 (일부 속성 수정)
  MoodRecord copyWith({
    String? id,
    String? userId,
    String? moodLabel,
    double? moodScore,
    String? notes,
    String? conversationId,
    DateTime? recordedAt,
    DateTime? createdAt,
  }) {
    return MoodRecord(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      moodLabel: moodLabel ?? this.moodLabel,
      moodScore: moodScore ?? this.moodScore,
      notes: notes ?? this.notes,
      conversationId: conversationId ?? this.conversationId,
      recordedAt: recordedAt ?? this.recordedAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

// 감정 분석 결과 모델 (필드명 변경 없음)
class MoodAnalysis {
  final String dominantMood; // 가장 많이 나타난 감정
  final double averageMoodScore; // 평균 감정 점수 (1~5)
  final Map<String, int> moodCounts; // 감정별 빈도
  final Map<String, List<String>> commonTags; // 감정별 자주 사용된 태그
  final List<MoodTrend> weeklyTrends; // 주간 감정 추이
  
  MoodAnalysis({
    required this.dominantMood,
    required this.averageMoodScore,
    required this.moodCounts,
    required this.commonTags,
    required this.weeklyTrends,
  });
  
  // 분석 데이터를 기반으로 감정 상태에 대한 간단한 해석 제공
  String getInsight() {
    if (averageMoodScore >= 4.0) {
      return '최근 감정 상태가 매우 긍정적입니다. 이런 상태를 유지하기 위한 활동이 도움이 될 수 있습니다.';
    } else if (averageMoodScore >= 3.0) {
      return '전반적으로 균형 잡힌 감정 상태를 유지하고 있습니다. 작은 긍정적인 활동을 더해보세요.';
    } else if (averageMoodScore >= 2.0) {
      return '약간의 부정적인 감정이 많았습니다. 자기 돌봄과 스트레스 관리에 시간을 투자해보세요.';
    } else {
      return '감정 상태가 다소 좋지 않은 시기를 겪고 있습니다. 필요하다면 주변의 도움을 요청하는 것이 좋습니다.';
    }
  }
}

// 감정 추이 모델 (필드명 변경 없음)
class MoodTrend {
  final DateTime date;
  final double averageScore;
  final String dominantMood;
  final int recordCount;
  
  MoodTrend({
    required this.date,
    required this.averageScore,
    required this.dominantMood,
    required this.recordCount,
  });
}

// 감정 태그 모델 (필드명 변경 없음)
class MoodTag {
  final String name;
  final int count; // 사용 빈도
  final String category; // 예: '활동', '사람', '장소' 등
  
  MoodTag({
    required this.name,
    required this.count,
    required this.category,
  });
}