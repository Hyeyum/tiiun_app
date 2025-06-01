/// 입력 유효성 검사 유틸리티
/// 
/// 다양한 입력값을 검증하는 함수들을 제공합니다.
library;
import 'package:characters/characters.dart';

class Validators {
  /// 이메일 유효성 검사
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return '이메일을 입력해주세요';
    }
    
    final emailRegex = RegExp(
      r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$'
    );
    
    if (!emailRegex.hasMatch(value)) {
      return '유효한 이메일 주소를 입력해주세요';
    }
    
    return null;
  }
  
  /// 비밀번호 유효성 검사
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return '비밀번호를 입력해주세요';
    }
    
    if (value.length < 8) {
      return '비밀번호는 8자 이상이어야 합니다';
    }
    
    // 비밀번호 복잡성 검사 (최소 1개 이상의 특수문자, 대문자, 소문자, 숫자 포함)
    bool hasUppercase = value.contains(RegExp(r'[A-Z]'));
    bool hasLowercase = value.contains(RegExp(r'[a-z]'));
    bool hasDigit = value.contains(RegExp(r'[0-9]'));
    bool hasSpecialChar = value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
    
    if (!(hasUppercase && hasLowercase && hasDigit && hasSpecialChar)) {
      return '비밀번호는 대문자, 소문자, 숫자, 특수문자를 모두 포함해야 합니다';
    }
    
    return null;
  }
  
  /// 비밀번호 확인 유효성 검사
  static String? validatePasswordConfirm(String? value, String password) {
    if (value == null || value.isEmpty) {
      return '비밀번호 확인을 입력해주세요';
    }
    
    if (value != password) {
      return '비밀번호가 일치하지 않습니다';
    }
    
    return null;
  }
  
  /// 이름 유효성 검사
  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return '이름을 입력해주세요';
    }
    
    if (value.length < 2) {
      return '이름은 2자 이상이어야 합니다';
    }
    
    // 한글, 영문, 숫자만 허용
    final nameRegex = RegExp(r'^[가-힣a-zA-Z0-9 ]+$');
    if (!nameRegex.hasMatch(value)) {
      return '이름은 한글, 영문, 숫자만 사용할 수 있습니다';
    }
    
    return null;
  }
  
  /// 휴대폰 번호 유효성 검사
  static String? validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return '휴대폰 번호를 입력해주세요';
    }
    
    // 숫자만 추출
    final digitsOnly = value.replaceAll(RegExp(r'[^\d]'), '');
    
    // 국내 휴대폰 번호 형식 (10-11자리)
    if (digitsOnly.length < 10 || digitsOnly.length > 11) {
      return '유효한 휴대폰 번호를 입력해주세요';
    }
    
    return null;
  }
  
  /// 필수 입력 필드 유효성 검사
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName을(를) 입력해주세요';
    }
    return null;
  }
  
  /// 날짜 유효성 검사
  static String? validateDate(String? value) {
    if (value == null || value.isEmpty) {
      return '날짜를 입력해주세요';
    }
    
    try {
      final date = DateTime.parse(value);
      final now = DateTime.now();
      
      if (date.isAfter(now)) {
        return '미래 날짜는 선택할 수 없습니다';
      }
      
      return null;
    } catch (e) {
      return '유효한 날짜 형식이 아닙니다';
    }
  }
  
  /// 숫자 유효성 검사
  static String? validateNumber(String? value) {
    if (value == null || value.isEmpty) {
      return '값을 입력해주세요';
    }
    
    if (double.tryParse(value) == null) {
      return '숫자만 입력해주세요';
    }
    
    return null;
  }
  
  /// 정수 유효성 검사
  static String? validateInteger(String? value) {
    if (value == null || value.isEmpty) {
      return '값을 입력해주세요';
    }
    
    if (int.tryParse(value) == null) {
      return '정수만 입력해주세요';
    }
    
    return null;
  }
  
  /// URL 유효성 검사
  static String? validateUrl(String? value) {
    if (value == null || value.isEmpty) {
      return 'URL을 입력해주세요';
    }
    
    final urlRegex = RegExp(
      r'^(http|https)://[a-zA-Z0-9-\.]+\.[a-zA-Z]{2,}(:[0-9]+)?(\/[a-zA-Z0-9-._~:/?#[\]@!$&()*+,;=]*)?$',
    );
    
    if (!urlRegex.hasMatch(value)) {
      return '유효한 URL 형식이 아닙니다';
    }
    
    return null;
  }
  
  /// 최소 길이 유효성 검사
  static String? validateMinLength(String? value, int minLength, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName을(를) 입력해주세요';
    }
    
    if (value.length < minLength) {
      return '$fieldName은(는) 최소 $minLength자 이상이어야 합니다';
    }
    
    return null;
  }
  
  /// 최대 길이 유효성 검사
  static String? validateMaxLength(String? value, int maxLength, String fieldName) {
    if (value == null || value.isEmpty) {
      return null; // 필수 입력이 아닌 경우
    }
    
    if (value.length > maxLength) {
      return '$fieldName은(는) 최대 $maxLength자 이하여야 합니다';
    }
    
    return null;
  }
  
  /// 범위 유효성 검사
  static String? validateRange(String? value, double min, double max, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName을(를) 입력해주세요';
    }
    
    final number = double.tryParse(value);
    if (number == null) {
      return '숫자만 입력해주세요';
    }
    
    if (number < min || number > max) {
      return '$fieldName은(는) $min에서 $max 사이의 값이어야 합니다';
    }
    
    return null;
  }
  
  /// 파일 크기 유효성 검사
  static String? validateFileSize(int fileSize, int maxSizeInBytes) {
    if (fileSize <= 0) {
      return '파일이 비어있습니다';
    }
    
    if (fileSize > maxSizeInBytes) {
      final maxSizeInMB = maxSizeInBytes / (1024 * 1024);
      return '파일 크기는 ${maxSizeInMB.toStringAsFixed(1)}MB 이하여야 합니다';
    }
    
    return null;
  }
  
  /// 파일 형식 유효성 검사
  static String? validateFileType(String fileName, List<String> allowedExtensions) {
    final extension = fileName.split('.').last.toLowerCase();
    
    if (!allowedExtensions.contains(extension)) {
      return '지원되지 않는 파일 형식입니다. (${allowedExtensions.join(', ')})';
    }
    
    return null;
  }
  
  /// 사용자 입력의 위험 스크립트 검사
  static String? validateSafeInput(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }
    
    // 스크립트 태그나 위험한 패턴 검사
    final scriptRegex = RegExp(
      r'<script.*?>|<\/script>|javascript:|on\w+\s*=',
      caseSensitive: false,
    );
    
    if (scriptRegex.hasMatch(value)) {
      return '입력 내용에 허용되지 않는 코드가 포함되어 있습니다';
    }
    
    return null;
  }
  
  /// 한글 이름 검사
  static String? validateKoreanName(String? value) {
    if (value == null || value.isEmpty) {
      return '이름을 입력해주세요';
    }
    
    // 한글 이름 검사 (2~5자)
    final nameRegex = RegExp(r'^[가-힣]{2,5}$');
    if (!nameRegex.hasMatch(value)) {
      return '한글 이름을 2~5자 사이로 입력해주세요';
    }
    
    return null;
  }
  
  /// 글자 수 제한 검사
  static String? validateCharCount(String? value, int maxCount, String fieldName) {
    if (value == null || value.isEmpty) {
      return null; // 필수 입력이 아닌 경우
    }
    
    final charCount = value.characters.length;
    if (charCount > maxCount) {
      return '$fieldName은(는) $maxCount자를 초과할 수 없습니다 (현재 $charCount자)';
    }
    
    return null;
  }
}
