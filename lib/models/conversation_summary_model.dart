// lib/models/conversation_summary_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

/// 상세한 대화 요약 구조 모델
class ConversationSummaryModel {
  /// 요약 ID
  final String id;

  /// 대화 ID
  final String conversationId;

  /// 사용자 ID
  final String userId;

  /// 요약 생성 시간
  final DateTime createdAt;

  /// 대화 개요
  final ConversationOverview overview;

  /// 주요 논의 사항들
  final List<DiscussionPoint> keyDiscussions;

  /// 감정 여정
  final EmotionalJourney emotionalJourney;

  /// 핵심 인사이트들
  final List<KeyInsight> keyInsights;

  /// 달성된 성과들
  final List<Achievement> achievements;

  /// 다음 단계 제안
  final NextSteps nextSteps;

  /// 전반적 평가
  final OverallAssessment overallAssessment;

  ConversationSummaryModel({
    required this.id,
    required this.conversationId,
    required this.userId,
    required this.createdAt,
    required this.overview,
    required this.keyDiscussions,
    required this.emotionalJourney,
    required this.keyInsights,
    required this.achievements,
    required this.nextSteps,
    required this.overallAssessment,
  });

  factory ConversationSummaryModel.fromMap(Map<String, dynamic> map) {
    return ConversationSummaryModel(
      id: map['id'] ?? '',
      conversationId: map['conversation_id'] ?? '',
      userId: map['user_id'] ?? '',
      createdAt: map['created_at'] is Timestamp
          ? (map['created_at'] as Timestamp).toDate()
          : DateTime.parse(map['created_at']),
      overview: ConversationOverview.fromMap(map['overview'] ?? {}),
      keyDiscussions: (map['key_discussions'] as List<dynamic>?)
          ?.map((kd) => DiscussionPoint.fromMap(kd))
          .toList() ?? [],
      emotionalJourney: EmotionalJourney.fromMap(map['emotional_journey'] ?? {}),
      keyInsights: (map['key_insights'] as List<dynamic>?)
          ?.map((ki) => KeyInsight.fromMap(ki))
          .toList() ?? [],
      achievements: (map['achievements'] as List<dynamic>?)
          ?.map((a) => Achievement.fromMap(a))
          .toList() ?? [],
      nextSteps: NextSteps.fromMap(map['next_steps'] ?? {}),
      overallAssessment: OverallAssessment.fromMap(map['overall_assessment'] ?? {}),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'conversation_id': conversationId,
      'user_id': userId,
      'created_at': Timestamp.fromDate(createdAt),
      'overview': overview.toMap(),
      'key_discussions': keyDiscussions.map((kd) => kd.toMap()).toList(),
      'emotional_journey': emotionalJourney.toMap(),
      'key_insights': keyInsights.map((ki) => ki.toMap()).toList(),
      'achievements': achievements.map((a) => a.toMap()).toList(),
      'next_steps': nextSteps.toMap(),
      'overall_assessment': overallAssessment.toMap(),
    };
  }
}

/// 대화 개요
class ConversationOverview {
  /// 대화 제목/주제
  final String title;

  /// 한 줄 요약
  final String oneLinerSummary;

  /// 대화 시간 (분)
  final int durationMinutes;

  /// 메시지 수
  final int messageCount;

  /// 대화 유형 (initial, follow_up, crisis, celebration, etc.)
  final String conversationType;

  /// 대화의 전반적인 톤
  final String overallTone;

  ConversationOverview({
    required this.title,
    required this.oneLinerSummary,
    required this.durationMinutes,
    required this.messageCount,
    required this.conversationType,
    required this.overallTone,
  });

  factory ConversationOverview.fromMap(Map<String, dynamic> map) {
    return ConversationOverview(
      title: map['title'] ?? '',
      oneLinerSummary: map['one_liner_summary'] ?? '',
      durationMinutes: map['duration_minutes'] ?? 0,
      messageCount: map['message_count'] ?? 0,
      conversationType: map['conversation_type'] ?? 'general',
      overallTone: map['overall_tone'] ?? 'neutral',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'one_liner_summary': oneLinerSummary,
      'duration_minutes': durationMinutes,
      'message_count': messageCount,
      'conversation_type': conversationType,
      'overall_tone': overallTone,
    };
  }
}

/// 논의 사항
class DiscussionPoint {
  /// 주제
  final String topic;

  /// 내용 요약
  final String summary;

  /// 중요도 (1-10)
  final int importance;

  /// 해결 정도 (unresolved, partially_resolved, resolved)
  final String resolutionStatus;

  /// 관련 감정들
  final List<String> relatedEmotions;

  /// 논의 순서
  final int discussionOrder;

  DiscussionPoint({
    required this.topic,
    required this.summary,
    required this.importance,
    required this.resolutionStatus,
    required this.relatedEmotions,
    required this.discussionOrder,
  });

  factory DiscussionPoint.fromMap(Map<String, dynamic> map) {
    return DiscussionPoint(
      topic: map['topic'] ?? '',
      summary: map['summary'] ?? '',
      importance: map['importance'] ?? 5,
      resolutionStatus: map['resolution_status'] ?? 'unresolved',
      relatedEmotions: List<String>.from(map['related_emotions'] ?? []),
      discussionOrder: map['discussion_order'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'topic': topic,
      'summary': summary,
      'importance': importance,
      'resolution_status': resolutionStatus,
      'related_emotions': relatedEmotions,
      'discussion_order': discussionOrder,
    };
  }
}

/// 감정 여정
class EmotionalJourney {
  /// 시작 감정 상태
  final EmotionalState startingState;

  /// 종료 감정 상태
  final EmotionalState endingState;

  /// 주요 감정 전환점들
  final List<EmotionalMilestone> milestones;

  /// 감정 변화 요약
  final String journeySummary;

  /// 가장 큰 감정 변화
  final String biggestEmotionalShift;

  EmotionalJourney({
    required this.startingState,
    required this.endingState,
    required this.milestones,
    required this.journeySummary,
    required this.biggestEmotionalShift,
  });

  factory EmotionalJourney.fromMap(Map<String, dynamic> map) {
    return EmotionalJourney(
      startingState: EmotionalState.fromMap(map['starting_state'] ?? {}),
      endingState: EmotionalState.fromMap(map['ending_state'] ?? {}),
      milestones: (map['milestones'] as List<dynamic>?)
          ?.map((m) => EmotionalMilestone.fromMap(m))
          .toList() ?? [],
      journeySummary: map['journey_summary'] ?? '',
      biggestEmotionalShift: map['biggest_emotional_shift'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'starting_state': startingState.toMap(),
      'ending_state': endingState.toMap(),
      'milestones': milestones.map((m) => m.toMap()).toList(),
      'journey_summary': journeySummary,
      'biggest_emotional_shift': biggestEmotionalShift,
    };
  }
}

/// 감정 상태
class EmotionalState {
  /// 주요 감정
  final String primaryEmotion;

  /// 감정 강도 (1-10)
  final int intensity;

  /// 감정 설명
  final String description;

  /// 감정 점수 (0.0-1.0)
  final double score;

  EmotionalState({
    required this.primaryEmotion,
    required this.intensity,
    required this.description,
    required this.score,
  });

  factory EmotionalState.fromMap(Map<String, dynamic> map) {
    return EmotionalState(
      primaryEmotion: map['primary_emotion'] ?? 'neutral',
      intensity: map['intensity'] ?? 5,
      description: map['description'] ?? '',
      score: (map['score'] ?? 0.5).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'primary_emotion': primaryEmotion,
      'intensity': intensity,
      'description': description,
      'score': score,
    };
  }
}

/// 감정적 이정표
class EmotionalMilestone {
  /// 이정표 설명
  final String description;

  /// 발생 시점 (대화 진행률 %)
  final int progressPercentage;

  /// 관련 토픽
  final String relatedTopic;

  /// 감정 변화 유형
  final String changeType;

  EmotionalMilestone({
    required this.description,
    required this.progressPercentage,
    required this.relatedTopic,
    required this.changeType,
  });

  factory EmotionalMilestone.fromMap(Map<String, dynamic> map) {
    return EmotionalMilestone(
      description: map['description'] ?? '',
      progressPercentage: map['progress_percentage'] ?? 0,
      relatedTopic: map['related_topic'] ?? '',
      changeType: map['change_type'] ?? 'gradual',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'description': description,
      'progress_percentage': progressPercentage,
      'related_topic': relatedTopic,
      'change_type': changeType,
    };
  }
}

/// 핵심 인사이트
class KeyInsight {
  /// 인사이트 내용
  final String content;

  /// 인사이트 카테고리
  final String category;

  /// 중요도 (1-10)
  final int importance;

  /// 관련 증거들
  final List<String> supportingEvidence;

  /// 적용 가능성
  final String applicability;

  KeyInsight({
    required this.content,
    required this.category,
    required this.importance,
    required this.supportingEvidence,
    required this.applicability,
  });

  factory KeyInsight.fromMap(Map<String, dynamic> map) {
    return KeyInsight(
      content: map['content'] ?? '',
      category: map['category'] ?? 'general',
      importance: map['importance'] ?? 5,
      supportingEvidence: List<String>.from(map['supporting_evidence'] ?? []),
      applicability: map['applicability'] ?? 'immediate',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'content': content,
      'category': category,
      'importance': importance,
      'supporting_evidence': supportingEvidence,
      'applicability': applicability,
    };
  }
}

/// 달성 성과
class Achievement {
  /// 성과 설명
  final String description;

  /// 성과 유형
  final String type;

  /// 달성도 (1-10)
  final int completionLevel;

  /// 의미
  final String significance;

  Achievement({
    required this.description,
    required this.type,
    required this.completionLevel,
    required this.significance,
  });

  factory Achievement.fromMap(Map<String, dynamic> map) {
    return Achievement(
      description: map['description'] ?? '',
      type: map['type'] ?? 'progress',
      completionLevel: map['completion_level'] ?? 5,
      significance: map['significance'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'description': description,
      'type': type,
      'completion_level': completionLevel,
      'significance': significance,
    };
  }
}

/// 다음 단계 제안
class NextSteps {
  /// 단기 목표들 (1-2주)
  final List<String> shortTermGoals;

  /// 장기 목표들 (1-3개월)
  final List<String> longTermGoals;

  /// 추천 활동들
  final List<String> recommendedActivities;

  /// 지속적 관찰 사항들
  final List<String> monitoringPoints;

  /// 다음 상담 제안 주제들
  final List<String> suggestedTopicsForNextSession;

  NextSteps({
    required this.shortTermGoals,
    required this.longTermGoals,
    required this.recommendedActivities,
    required this.monitoringPoints,
    required this.suggestedTopicsForNextSession,
  });

  factory NextSteps.fromMap(Map<String, dynamic> map) {
    return NextSteps(
      shortTermGoals: List<String>.from(map['short_term_goals'] ?? []),
      longTermGoals: List<String>.from(map['long_term_goals'] ?? []),
      recommendedActivities: List<String>.from(map['recommended_activities'] ?? []),
      monitoringPoints: List<String>.from(map['monitoring_points'] ?? []),
      suggestedTopicsForNextSession: List<String>.from(map['suggested_topics_for_next_session'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'short_term_goals': shortTermGoals,
      'long_term_goals': longTermGoals,
      'recommended_activities': recommendedActivities,
      'monitoring_points': monitoringPoints,
      'suggested_topics_for_next_session': suggestedTopicsForNextSession,
    };
  }
}

/// 전반적 평가
class OverallAssessment {
  /// 대화 효과성 점수 (1-10)
  final int effectivenessScore;

  /// 사용자 참여도 점수 (1-10)
  final int engagementScore;

  /// 진전 정도 점수 (1-10)
  final int progressScore;

  /// 평가 요약
  final String assessmentSummary;

  /// 강점들
  final List<String> strengths;

  /// 개선 영역들
  final List<String> areasForImprovement;

  OverallAssessment({
    required this.effectivenessScore,
    required this.engagementScore,
    required this.progressScore,
    required this.assessmentSummary,
    required this.strengths,
    required this.areasForImprovement,
  });

  factory OverallAssessment.fromMap(Map<String, dynamic> map) {
    return OverallAssessment(
      effectivenessScore: map['effectiveness_score'] ?? 5,
      engagementScore: map['engagement_score'] ?? 5,
      progressScore: map['progress_score'] ?? 5,
      assessmentSummary: map['assessment_summary'] ?? '',
      strengths: List<String>.from(map['strengths'] ?? []),
      areasForImprovement: List<String>.from(map['areas_for_improvement'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'effectiveness_score': effectivenessScore,
      'engagement_score': engagementScore,
      'progress_score': progressScore,
      'assessment_summary': assessmentSummary,
      'strengths': strengths,
      'areas_for_improvement': areasForImprovement,
    };
  }
}
