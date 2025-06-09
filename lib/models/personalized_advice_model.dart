// lib/models/personalized_advice_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

/// 구조화된 맞춤형 조언 모델
class PersonalizedAdviceModel {
  /// 조언 ID
  final String id;

  /// 대화 ID
  final String conversationId;

  /// 사용자 ID
  final String userId;

  /// 생성 시간
  final DateTime createdAt;

  /// 주요 조언 내용
  final AdviceContent mainAdvice;

  /// 실행 가능한 제안들
  final List<ActionableRecommendation> actionableRecommendations;

  /// 추천 리소스들
  final List<RecommendedResource> recommendedResources;

  /// 조언의 근거
  final AdviceRationale rationale;

  /// 개인화 요소들
  final AdvicePersonalization personalization;

  /// 우선순위 점수 (1-10)
  final int priorityScore;

  PersonalizedAdviceModel({
    required this.id,
    required this.conversationId,
    required this.userId,
    required this.createdAt,
    required this.mainAdvice,
    required this.actionableRecommendations,
    required this.recommendedResources,
    required this.rationale,
    required this.personalization,
    required this.priorityScore,
  });

  factory PersonalizedAdviceModel.fromMap(Map<String, dynamic> map) {
    return PersonalizedAdviceModel(
      id: map['id'] ?? '',
      conversationId: map['conversation_id'] ?? '',
      userId: map['user_id'] ?? '',
      createdAt: map['created_at'] is Timestamp
          ? (map['created_at'] as Timestamp).toDate()
          : DateTime.parse(map['created_at']),
      mainAdvice: AdviceContent.fromMap(map['main_advice'] ?? {}),
      actionableRecommendations: (map['actionable_recommendations'] as List<dynamic>?)
          ?.map((ar) => ActionableRecommendation.fromMap(ar))
          .toList() ?? [],
      recommendedResources: (map['recommended_resources'] as List<dynamic>?)
          ?.map((rr) => RecommendedResource.fromMap(rr))
          .toList() ?? [],
      rationale: AdviceRationale.fromMap(map['rationale'] ?? {}),
      personalization: AdvicePersonalization.fromMap(map['personalization'] ?? {}),
      priorityScore: map['priority_score'] ?? 5,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'conversation_id': conversationId,
      'user_id': userId,
      'created_at': Timestamp.fromDate(createdAt),
      'main_advice': mainAdvice.toMap(),
      'actionable_recommendations': actionableRecommendations.map((ar) => ar.toMap()).toList(),
      'recommended_resources': recommendedResources.map((rr) => rr.toMap()).toList(),
      'rationale': rationale.toMap(),
      'personalization': personalization.toMap(),
      'priority_score': priorityScore,
    };
  }
}

/// 조언 내용
class AdviceContent {
  /// 핵심 메시지
  final String coreMessage;

  /// 상세 설명
  final String detailedExplanation;

  /// 예상 효과
  final String expectedOutcome;

  /// 적용 시기
  final String timeframe;

  /// 난이도 (easy, medium, hard)
  final String difficulty;

  AdviceContent({
    required this.coreMessage,
    required this.detailedExplanation,
    required this.expectedOutcome,
    required this.timeframe,
    required this.difficulty,
  });

  factory AdviceContent.fromMap(Map<String, dynamic> map) {
    return AdviceContent(
      coreMessage: map['core_message'] ?? '',
      detailedExplanation: map['detailed_explanation'] ?? '',
      expectedOutcome: map['expected_outcome'] ?? '',
      timeframe: map['timeframe'] ?? 'immediate',
      difficulty: map['difficulty'] ?? 'medium',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'core_message': coreMessage,
      'detailed_explanation': detailedExplanation,
      'expected_outcome': expectedOutcome,
      'timeframe': timeframe,
      'difficulty': difficulty,
    };
  }
}

/// 실행 가능한 추천사항
class ActionableRecommendation {
  /// 추천사항 제목
  final String title;

  /// 설명
  final String description;

  /// 구체적인 단계들
  final List<String> steps;

  /// 카테고리 (mindfulness, exercise, social, creative, etc.)
  final String category;

  /// 예상 소요 시간 (분)
  final int estimatedDurationMinutes;

  /// 우선순위 (1-5)
  final int priority;

  /// 효과성 점수 (1-10)
  final int effectivenessScore;

  ActionableRecommendation({
    required this.title,
    required this.description,
    required this.steps,
    required this.category,
    required this.estimatedDurationMinutes,
    required this.priority,
    required this.effectivenessScore,
  });

  factory ActionableRecommendation.fromMap(Map<String, dynamic> map) {
    return ActionableRecommendation(
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      steps: List<String>.from(map['steps'] ?? []),
      category: map['category'] ?? 'general',
      estimatedDurationMinutes: map['estimated_duration_minutes'] ?? 10,
      priority: map['priority'] ?? 3,
      effectivenessScore: map['effectiveness_score'] ?? 7,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'steps': steps,
      'category': category,
      'estimated_duration_minutes': estimatedDurationMinutes,
      'priority': priority,
      'effectiveness_score': effectivenessScore,
    };
  }
}

/// 추천 리소스
class RecommendedResource {
  /// 리소스 제목
  final String title;

  /// 설명
  final String description;

  /// 리소스 타입 (book, article, video, app, etc.)
  final String type;

  /// URL (있는 경우)
  final String? url;

  /// 관련 주제들
  final List<String> relatedTopics;

  /// 추천 이유
  final String recommendationReason;

  RecommendedResource({
    required this.title,
    required this.description,
    required this.type,
    this.url,
    required this.relatedTopics,
    required this.recommendationReason,
  });

  factory RecommendedResource.fromMap(Map<String, dynamic> map) {
    return RecommendedResource(
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      type: map['type'] ?? 'general',
      url: map['url'],
      relatedTopics: List<String>.from(map['related_topics'] ?? []),
      recommendationReason: map['recommendation_reason'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'type': type,
      'url': url,
      'related_topics': relatedTopics,
      'recommendation_reason': recommendationReason,
    };
  }
}

/// 조언의 근거
class AdviceRationale {
  /// 분석된 주요 이슈들
  final List<String> identifiedIssues;

  /// 감정 패턴 근거
  final String emotionPatternEvidence;

  /// 대화 내용 근거
  final List<String> conversationEvidence;

  /// 사용자 프로필 고려사항
  final List<String> profileConsiderations;

  /// 연구/이론적 근거
  final String theoreticalBasis;

  /// 성공 가능성 (1-10)
  final int successProbability;

  AdviceRationale({
    required this.identifiedIssues,
    required this.emotionPatternEvidence,
    required this.conversationEvidence,
    required this.profileConsiderations,
    required this.theoreticalBasis,
    required this.successProbability,
  });

  factory AdviceRationale.fromMap(Map<String, dynamic> map) {
    return AdviceRationale(
      identifiedIssues: List<String>.from(map['identified_issues'] ?? []),
      emotionPatternEvidence: map['emotion_pattern_evidence'] ?? '',
      conversationEvidence: List<String>.from(map['conversation_evidence'] ?? []),
      profileConsiderations: List<String>.from(map['profile_considerations'] ?? []),
      theoreticalBasis: map['theoretical_basis'] ?? '',
      successProbability: map['success_probability'] ?? 7,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'identified_issues': identifiedIssues,
      'emotion_pattern_evidence': emotionPatternEvidence,
      'conversation_evidence': conversationEvidence,
      'profile_considerations': profileConsiderations,
      'theoretical_basis': theoreticalBasis,
      'success_probability': successProbability,
    };
  }
}

/// 조언 개인화 정보
class AdvicePersonalization {
  /// 개인화 적용 영역들
  final List<String> personalizationAreas;

  /// 사용자 특성 고려사항
  final Map<String, String> userCharacteristics;

  /// 선호도 반영 사항들
  final List<String> preferenceConsiderations;

  /// 과거 응답 패턴 고려
  final String historicalResponsePattern;

  /// 문화적 고려사항
  final List<String> culturalConsiderations;

  AdvicePersonalization({
    required this.personalizationAreas,
    required this.userCharacteristics,
    required this.preferenceConsiderations,
    required this.historicalResponsePattern,
    required this.culturalConsiderations,
  });

  factory AdvicePersonalization.fromMap(Map<String, dynamic> map) {
    return AdvicePersonalization(
      personalizationAreas: List<String>.from(map['personalization_areas'] ?? []),
      userCharacteristics: Map<String, String>.from(map['user_characteristics'] ?? {}),
      preferenceConsiderations: List<String>.from(map['preference_considerations'] ?? []),
      historicalResponsePattern: map['historical_response_pattern'] ?? 'unknown',
      culturalConsiderations: List<String>.from(map['cultural_considerations'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'personalization_areas': personalizationAreas,
      'user_characteristics': userCharacteristics,
      'preference_considerations': preferenceConsiderations,
      'historical_response_pattern': historicalResponsePattern,
      'cultural_considerations': culturalConsiderations,
    };
  }
}
