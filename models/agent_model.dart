import 'package:cloud_firestore/cloud_firestore.dart';

class EmailTemplate {
  final String id;
  final String name;
  final String templateType;
  final String subject;
  final String content;
  final Map<String, dynamic> variables;
  final Map<String, dynamic> conditions;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  static const List<String> templateTypes = [
    'comfort',
    'motivation',
    'reminder',
    'congratulation',
    'weekly_summary',
  ];

  EmailTemplate({
    required this.id,
    required this.name,
    required this.templateType,
    required this.subject,
    required this.content,
    this.variables = const {},
    this.conditions = const {},
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  // Create an email template from a snapshot
  factory EmailTemplate.fromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;
    
    return EmailTemplate(
      id: snapshot.id,
      name: data['name'] ?? '',
      templateType: data['templateType'] ?? 'comfort',
      subject: data['subject'] ?? '',
      content: data['content'] ?? '',
      variables: data['variables'] ?? {},
      conditions: data['conditions'] ?? {},
      isActive: data['isActive'] ?? true,
      createdAt: data['createdAt'] != null 
        ? (data['createdAt'] as Timestamp).toDate() 
        : DateTime.now(),
      updatedAt: data['updatedAt'] != null 
        ? (data['updatedAt'] as Timestamp).toDate() 
        : DateTime.now(),
    );
  }

  // Convert email template to a map
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'templateType': templateType,
      'subject': subject,
      'content': content,
      'variables': variables,
      'conditions': conditions,
      'isActive': isActive,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }
}

class ScheduledEmail {
  final String id;
  final String userId;
  final String? templateId;
  final String? subject;
  final String? content;
  final DateTime scheduledAt;
  final String status;
  final DateTime createdAt;
  final DateTime? sentAt;
  final String? errors;

  static const List<String> statusOptions = [
    'pending',
    'sent',
    'failed',
    'cancelled',
  ];

  ScheduledEmail({
    required this.id,
    required this.userId,
    this.templateId,
    this.subject,
    this.content,
    required this.scheduledAt,
    this.status = 'pending',
    required this.createdAt,
    this.sentAt,
    this.errors,
  });

  // Create a scheduled email from a snapshot
  factory ScheduledEmail.fromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;
    
    return ScheduledEmail(
      id: snapshot.id,
      userId: data['userId'] ?? '',
      templateId: data['templateId'],
      subject: data['subject'],
      content: data['content'],
      scheduledAt: data['scheduledAt'] != null 
        ? (data['scheduledAt'] as Timestamp).toDate() 
        : DateTime.now(),
      status: data['status'] ?? 'pending',
      createdAt: data['createdAt'] != null 
        ? (data['createdAt'] as Timestamp).toDate() 
        : DateTime.now(),
      sentAt: data['sentAt'] != null ? (data['sentAt'] as Timestamp).toDate() : null,
      errors: data['errors'],
    );
  }

  // Convert scheduled email to a map
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'templateId': templateId,
      'subject': subject,
      'content': content,
      'scheduledAt': Timestamp.fromDate(scheduledAt),
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
      'sentAt': sentAt != null ? Timestamp.fromDate(sentAt!) : null,
      'errors': errors,
    };
  }
}

class AgentTask {
  final String id;
  final String userId;
  final String taskType;
  final Map<String, dynamic> parameters;
  final DateTime createdAt;
  final DateTime? scheduledAt;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final String status;
  final Map<String, dynamic>? result;
  final String? errors;

  static const List<String> taskTypes = [
    'comfort_email',
    'mood_analysis',
    'wellness_check',
    'content_recommendation',
    'conversation_summary',
  ];

  static const List<String> statusOptions = [
    'pending',
    'in_progress',
    'completed',
    'failed',
    'cancelled',
  ];

  AgentTask({
    required this.id,
    required this.userId,
    required this.taskType,
    this.parameters = const {},
    required this.createdAt,
    this.scheduledAt,
    this.startedAt,
    this.completedAt,
    this.status = 'pending',
    this.result,
    this.errors,
  });

  // Create an agent task from a snapshot
  factory AgentTask.fromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;
    
    return AgentTask(
      id: snapshot.id,
      userId: data['userId'] ?? '',
      taskType: data['taskType'] ?? '',
      parameters: data['parameters'] ?? {},
      createdAt: data['createdAt'] != null 
        ? (data['createdAt'] as Timestamp).toDate() 
        : DateTime.now(),
      scheduledAt: data['scheduledAt'] != null 
        ? (data['scheduledAt'] as Timestamp).toDate() 
        : null,
      startedAt: data['startedAt'] != null 
        ? (data['startedAt'] as Timestamp).toDate() 
        : null,
      completedAt: data['completedAt'] != null 
        ? (data['completedAt'] as Timestamp).toDate() 
        : null,
      status: data['status'] ?? 'pending',
      result: data['result'],
      errors: data['errors'],
    );
  }

  // Convert agent task to a map
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'taskType': taskType,
      'parameters': parameters,
      'createdAt': Timestamp.fromDate(createdAt),
      'scheduledAt': scheduledAt != null ? Timestamp.fromDate(scheduledAt!) : null,
      'startedAt': startedAt != null ? Timestamp.fromDate(startedAt!) : null,
      'completedAt': completedAt != null ? Timestamp.fromDate(completedAt!) : null,
      'status': status,
      'result': result,
      'errors': errors,
    };
  }
}
