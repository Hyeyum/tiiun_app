import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'export_format.dart';
/// 대화 설정 모델
/// 대화 목록과 관련된 모든 설정을 관리합니다.
class ConversationSettings {
  /// 자동 저장 사용 여부
  bool enableAutoSave;
  
  /// 자동 저장 간격 (분)
  int autoSaveInterval;
  
  /// 내보내기 형식 
  ExportFormat exportFormat;
  
  /// 기본 저장 경로
  String? defaultSavePath;
  
  /// 대화 내역 저장 기간 제한 (일)
  /// 0이면 무제한
  int historyRetentionDays;
  
  /// 대화 태그 목록
  List<String> availableTags;
  
  /// 대화 자동 태그 지정 사용 여부
  bool enableAutoTagging;
  
  /// 대화 백업 사용 여부
  bool enableBackups;
  
  /// 마지막 백업 날짜
  DateTime? lastBackupDate;
  
  /// 마지막 내보내기 날짜
  DateTime? lastExportDate;
  
  ConversationSettings({
    this.enableAutoSave = false,
    this.autoSaveInterval = 30,
    this.exportFormat = ExportFormat.json,
    this.defaultSavePath,
    this.historyRetentionDays = 0,
    this.availableTags = const [],
    this.enableAutoTagging = true,
    this.enableBackups = false,
    this.lastBackupDate,
    this.lastExportDate,
  });
  
  /// 기본 설정값으로 초기화
  factory ConversationSettings.defaultSettings() {
    return ConversationSettings(
      enableAutoSave: false,
      autoSaveInterval: 30,
      exportFormat: ExportFormat.json,
      historyRetentionDays: 0,
      availableTags: [
        '중요',
        '긍정적',
        '부정적',
        '질문',
        '상담',
        '감정',
        '일상',
        '목표',
        '성취',
        '도전',
      ],
      enableAutoTagging: true,
      enableBackups: false,
    );
  }
  
  /// JSON 데이터에서 객체 생성
  factory ConversationSettings.fromJson(Map<String, dynamic> json) {
    return ConversationSettings(
      enableAutoSave: json['enableAutoSave'] ?? false,
      autoSaveInterval: json['autoSaveInterval'] ?? 30,
      exportFormat: ExportFormat.values.firstWhere(
        (e) => e.toString().split('.').last == (json['exportFormat'] ?? 'json'),
        orElse: () => ExportFormat.json,
      ),
      defaultSavePath: json['defaultSavePath'],
      historyRetentionDays: json['historyRetentionDays'] ?? 0,
      availableTags: List<String>.from(json['availableTags'] ?? []),
      enableAutoTagging: json['enableAutoTagging'] ?? true,
      enableBackups: json['enableBackups'] ?? false,
      lastBackupDate: json['lastBackupDate'] != null 
          ? DateTime.parse(json['lastBackupDate']) 
          : null,
      lastExportDate: json['lastExportDate'] != null 
          ? DateTime.parse(json['lastExportDate']) 
          : null,
    );
  }
  
  /// JSON 데이터로 변환
  Map<String, dynamic> toJson() {
    return {
      'enableAutoSave': enableAutoSave,
      'autoSaveInterval': autoSaveInterval,
      'exportFormat': exportFormat.toString().split('.').last,
      'defaultSavePath': defaultSavePath,
      'historyRetentionDays': historyRetentionDays,
      'availableTags': availableTags,
      'enableAutoTagging': enableAutoTagging,
      'enableBackups': enableBackups,
      'lastBackupDate': lastBackupDate?.toIso8601String(),
      'lastExportDate': lastExportDate?.toIso8601String(),
    };
  }
  
  /// SharedPreferences에 설정 저장
  Future<bool> saveToPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = jsonEncode(toJson());
      return await prefs.setString('conversation_settings', jsonString);
    } catch (e) {
      print('설정 저장 오류: $e');
      return false;
    }
  }
  
  /// SharedPreferences에서 설정 로드
  static Future<ConversationSettings> loadFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString('conversation_settings');
      
      if (jsonString == null || jsonString.isEmpty) {
        return ConversationSettings.defaultSettings();
      }
      
      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      return ConversationSettings.fromJson(json);
    } catch (e) {
      print('설정 로드 오류: $e');
      return ConversationSettings.defaultSettings();
    }
  }
}

// /// 내보내기 형식
// enum ExportFormat {
//   /// JSON 형식 (기본값)
//   json,
  
//   /// 마크다운 형식
//   markdown,
  
//   /// 텍스트 형식
//   text,
  
//   /// HTML 형식
//   html,
  
//   /// CSV 형식
//   csv,
  
//   /// PDF 형식
//   pdf,
// }
