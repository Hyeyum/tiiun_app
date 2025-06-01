/// 문자열 유틸리티 함수 모음
class StringUtils {
  /// 문자열에서 첫 글자 추출 (안전하게)
  static String? getInitial(String? text) {
    if (text == null || text.isEmpty) {
      return null;
    }
    return text.substring(0, 1).toUpperCase();
  }
  
  /// 특정 길이로 문자열 자르기 (안전하게)
  static String truncate(String text, int maxLength) {
    if (text.length <= maxLength) {
      return text;
    }
    return '${text.substring(0, maxLength)}...';
  }
  
  /// 이메일 유효성 검사
  static bool isValidEmail(String email) {
    final emailRegExp = RegExp(r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+');
    return emailRegExp.hasMatch(email);
  }
  
  /// 비밀번호 유효성 검사 (최소 8자, 특수문자/숫자 각 1개 이상)
  static bool isValidPassword(String password) {
    if (password.length < 8) return false;
    
    final hasNumber = RegExp(r'[0-9]').hasMatch(password);
    final hasSpecial = RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password);
    
    return hasNumber && hasSpecial;
  }
  
  /// 글자 수 계산
  static int countCharacters(String text) {
    return text.length;
  }
  
  /// 단어 수 계산
  static int countWords(String text) {
    final words = text.trim().split(RegExp(r'\s+'));
    return words.where((word) => word.isNotEmpty).length;
  }
}
