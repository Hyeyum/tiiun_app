// lib/models/conversation_analysis_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

/// 대화의 종합적 분석 결과를 담는 모델
class ConversationAnalysisModel {
  /// 분석 ID
  final String id;

  /// 대화 ID
  final String conversationId;

  /// 사용자 ID
  final String userId;

  /// 분석 생성 시간
  final DateTime createdAt;

  /// 감정 변화 패턴 분석
  final EmotionPatternAnalysis emotionPattern;

  /// 대화 주제 분석
  final TopicAnalysis topicAnalysis;

  /// 사용자 성장 지표
  final UserGrowthIndicators growthIndicators;

  /// 대화 품질 지표
  final ConversationQualityMetrics qualityMetrics;

  /// 개인화 요소들
  final PersonalizationFactors personalizationFactors;

  ConversationAnalysisModel({
    required this.id,
    required this.conversationId,
    required this.userId,
    required this.createdAt,
    required this.emotionPattern,
    required this.topicAnalysis,
    required this.growthIndicators,
    required this.qualityMetrics,
    required this.personalizationFactors,
  });

  factory ConversationAnalysisModel.fromMap(Map<String, dynamic> map) {
    return ConversationAnalysisModel(
      id: map['id'] ?? '',
      conversationId: map['conversation_id'] ?? '',
      userId: map['user_id'] ?? '',
      createdAt: map['created_at'] is Timestamp
          ? (map['created_at'] as Timestamp).toDate()
          : DateTime.parse(map['created_at']),
      emotionPattern: EmotionPatternAnalysis.fromMap(map['emotion_pattern'] ?? {}),
      topicAnalysis: TopicAnalysis.fromMap(map['topic_analysis'] ?? {}),
      growthIndicators: UserGrowthIndicators.fromMap(map['growth_indicators'] ?? {}),
      qualityMetrics: ConversationQualityMetrics.fromMap(map['quality_metrics'] ?? {}),
      personalizationFactors: PersonalizationFactors.fromMap(map['personalization_factors'] ?? {}),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'conversation_id': conversationId,
      'user_id': userId,
      'created_at': Timestamp.fromDate(createdAt),
      'emotion_pattern': emotionPattern.toMap(),
      'topic_analysis': topicAnalysis.toMap(),
      'growth_indicators': growthIndicators.toMap(),
      'quality_metrics': qualityMetrics.toMap(),
      'personalization_factors': personalizationFactors.toMap(),
    };
  }
}

/// 감정 변화 패턴 분석
class EmotionPatternAnalysis {
  /// 전반적 감정 트렌드 (improving, stable, declining)
  final String overallTrend;

  /// 감정 변동성 (low, medium, high)
  final String volatility;

  /// 주요 감정 상태들
  final List<String> dominantEmotions;

  /// 감정 전환점들
  final List<EmotionTurningPoint> turningPoints;

  /// 시작 감정 점수
  final double startingScore;

  /// 종료 감정 점수
  final double endingScore;

  /// 평균 감정 점수
  final double averageScore;

  EmotionPatternAnalysis({
    required this.overallTrend,
    required this.volatility,
    required this.dominantEmotions,
    required this.turningPoints,
    required this.startingScore,
    required this.endingScore,
    required this.averageScore,
  });

  factory EmotionPatternAnalysis.fromMap(Map<String, dynamic> map) {
    return EmotionPatternAnalysis(
      overallTrend: map['overall_trend'] ?? 'stable',
      volatility: map['volatility'] ?? 'medium',
      dominantEmotions: List<String>.from(map['dominant_emotions'] ?? []),
      turningPoints: (map['turning_points'] as List<dynamic>?)
          ?.map((tp) => EmotionTurningPoint.fromMap(tp))
          .toList() ?? [],
      startingScore: (map['starting_score'] ?? 0.0).toDouble(),
      endingScore: (map['ending_score'] ?? 0.0).toDouble(),
      averageScore: (map['average_score'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'overall_trend': overallTrend,
      'volatility': volatility,
      'dominant_emotions': dominantEmotions,
      'turning_points': turningPoints.map((tp) => tp.toMap()).toList(),
      'starting_score': startingScore,
      'ending_score': endingScore,
      'average_score': averageScore,
    };
  }
}

/// 감정 전환점
class EmotionTurningPoint {
  /// 전환점 시간
  final DateTime timestamp;

  /// 이전 감정
  final String fromEmotion;

  /// 변화된 감정
  final String toEmotion;

  /// 변화 강도 (0.0 ~ 1.0)
  final double changeIntensity;

  /// 변화 원인 (추정)
  final String? trigger;

  EmotionTurningPoint({
    required this.timestamp,
    required this.fromEmotion,
    required this.toEmotion,
    required this.changeIntensity,
    this.trigger,
  });

  factory EmotionTurningPoint.fromMap(Map<String, dynamic> map) {
    return EmotionTurningPoint(
      timestamp: map['timestamp'] is Timestamp
          ? (map['timestamp'] as Timestamp).toDate()
          : DateTime.parse(map['timestamp']),
      fromEmotion: map['from_emotion'] ?? '',
      toEmotion: map['to_emotion'] ?? '',
      changeIntensity: (map['change_intensity'] ?? 0.0).toDouble(),
      trigger: map['trigger'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'timestamp': Timestamp.fromDate(timestamp),
      'from_emotion': fromEmotion,
      'to_emotion': toEmotion,
      'change_intensity': changeIntensity,
      'trigger': trigger,
    };
  }
}

/// 주제 분석
class TopicAnalysis {
  /// 주요 토픽들 (중요도 순)
  final List<String> mainTopics;

  /// 토픽별 감정 연관성
  final Map<String, String> topicEmotionMapping;

  /// 토픽 전환 패턴
  final List<String> topicProgression;

  /// 해결된 주제들
  final List<String> resolvedTopics;

  /// 지속적인 관심 주제들
  final List<String> ongoingConcerns;

  TopicAnalysis({
    required this.mainTopics,
    required this.topicEmotionMapping,
    required this.topicProgression,
    required this.resolvedTopics,
    required this.ongoingConcerns,
  });

  factory TopicAnalysis.fromMap(Map<String, dynamic> map) {
    return TopicAnalysis(
      mainTopics: List<String>.from(map['main_topics'] ?? []),
      topicEmotionMapping: Map<String, String>.from(map['topic_emotion_mapping'] ?? {}),
      topicProgression: List<String>.from(map['topic_progression'] ?? []),
      resolvedTopics: List<String>.from(map['resolved_topics'] ?? []),
      ongoingConcerns: List<String>.from(map['ongoing_concerns'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'main_topics': mainTopics,
      'topic_emotion_mapping': topicEmotionMapping,
      'topic_progression': topicProgression,
      'resolved_topics': resolvedTopics,
      'ongoing_concerns': ongoingConcerns,
    };
  }
}

/// 사용자 성장 지표
class UserGrowthIndicators {
  /// 자기 인식 수준 (1-10)
  final int selfAwarenessLevel;

  /// 감정 조절 능력 (1-10)
  final int emotionalRegulationLevel;

  /// 문제 해결 접근법 개선도 (1-10)
  final int problemSolvingImprovement;

  /// 의사소통 스킬 발전도 (1-10)
  final int communicationSkillDevelopment;

  /// 긍정적 변화 영역들
  final List<String> positiveChangeAreas;

  /// 개선이 필요한 영역들
  final List<String> improvementNeededAreas;

  UserGrowthIndicators({
    required this.selfAwarenessLevel,
    required this.emotionalRegulationLevel,
    required this.problemSolvingImprovement,
    required this.communicationSkillDevelopment,
    required this.positiveChangeAreas,
    required this.improvementNeededAreas,
  });

  factory UserGrowthIndicators.fromMap(Map<String, dynamic> map) {
    return UserGrowthIndicators(
      selfAwarenessLevel: map['self_awareness_level'] ?? 5,
      emotionalRegulationLevel: map['emotional_regulation_level'] ?? 5,
      problemSolvingImprovement: map['problem_solving_improvement'] ?? 5,
      communicationSkillDevelopment: map['communication_skill_development'] ?? 5,
      positiveChangeAreas: List<String>.from(map['positive_change_areas'] ?? []),
      improvementNeededAreas: List<String>.from(map['improvement_needed_areas'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'self_awareness_level': selfAwarenessLevel,
      'emotional_regulation_level': emotionalRegulationLevel,
      'problem_solving_improvement': problemSolvingImprovement,
      'communication_skill_development': communicationSkillDevelopment,
      'positive_change_areas': positiveChangeAreas,
      'improvement_needed_areas': improvementNeededAreas,
    };
  }
}

/// 대화 품질 지표
class ConversationQualityMetrics {
  /// 참여도 점수 (1-10)
  final int engagementScore;

  /// 개방성 점수 (1-10)
  final int opennessScore;

  /// 깊이 점수 (1-10)
  final int depthScore;

  /// 일관성 점수 (1-10)
  final int consistencyScore;

  /// 대화 흐름 품질 (1-10)
  final int flowQuality;

  ConversationQualityMetrics({
    required this.engagementScore,
    required this.opennessScore,
    required this.depthScore,
    required this.consistencyScore,
    required this.flowQuality,
  });

  factory ConversationQualityMetrics.fromMap(Map<String, dynamic> map) {
    return ConversationQualityMetrics(
      engagementScore: map['engagement_score'] ?? 5,
      opennessScore: map['openness_score'] ?? 5,
      depthScore: map['depth_score'] ?? 5,
      consistencyScore: map['consistency_score'] ?? 5,
      flowQuality: map['flow_quality'] ?? 5,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'engagement_score': engagementScore,
      'openness_score': opennessScore,
      'depth_score': depthScore,
      'consistency_score': consistencyScore,
      'flow_quality': flowQuality,
    };
  }
}

/// 개인화 요소들
class PersonalizationFactors {
  /// 사용자 연령대
  final String ageGroup;

  /// 성별
  final String gender;

  /// 선호하는 활동들
  final List<String> preferredActivities;

  /// 주요 관심사
  final List<String> mainInterests;

  /// 의사소통 스타일
  final String communicationStyle;

  /// 스트레스 대처 방식
  final String stressCopingStyle;

  PersonalizationFactors({
    required this.ageGroup,
    required this.gender,
    required this.preferredActivities,
    required this.mainInterests,
    required this.communicationStyle,
    required this.stressCopingStyle,
  });

  factory PersonalizationFactors.fromMap(Map<String, dynamic> map) {
    return PersonalizationFactors(
      ageGroup: map['age_group'] ?? 'unknown',
      gender: map['gender'] ?? 'unknown',
      preferredActivities: List<String>.from(map['preferred_activities'] ?? []),
      mainInterests: List<String>.from(map['main_interests'] ?? []),
      communicationStyle: map['communication_style'] ?? 'balanced',
      stressCopingStyle: map['stress_coping_style'] ?? 'adaptive',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'age_group': ageGroup,
      'gender': gender,
      'preferred_activities': preferredActivities,
      'main_interests': mainInterests,
      'communication_style': communicationStyle,
      'stress_coping_style': stressCopingStyle,
    };
  }
}
