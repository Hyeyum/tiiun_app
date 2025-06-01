import 'package:intl/intl.dart';

/// 날짜 포맷팅 유틸리티
/// 
/// 앱에서 사용하는 다양한 날짜 형식을 일관되게 표시하기 위한 유틸리티 클래스입니다.
class DateFormatter {
  /// 기본 날짜 형식 (yyyy-MM-dd)
  static String formatDate(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }
  
  /// 한국어 날짜 형식 (yyyy년 MM월 dd일)
  static String formatKoreanDate(DateTime date) {
    return DateFormat('yyyy년 MM월 dd일').format(date);
  }
  
  /// 연월일 요일 형식 (yyyy년 MM월 dd일 (요일))
  static String formatDateWithWeekday(DateTime date) {
    final weekdays = ['월', '화', '수', '목', '금', '토', '일'];
    final weekday = weekdays[date.weekday - 1];
    return '${DateFormat('yyyy년 MM월 dd일').format(date)} ($weekday)';
  }
  
  /// 시간 형식 (HH:mm)
  static String formatTime(DateTime date) {
    return DateFormat('HH:mm').format(date);
  }
  
  /// 시간 초 형식 (HH:mm:ss)
  static String formatTimeWithSeconds(DateTime date) {
    return DateFormat('HH:mm:ss').format(date);
  }
  
  /// 날짜 시간 형식 (yyyy-MM-dd HH:mm 또는 MM/dd HH:mm)
  static String formatDateTime(DateTime date, {bool short = false}) {
    if (short) {
      return formatShortDateTime(date);
    }
    return DateFormat('yyyy-MM-dd HH:mm').format(date);
  }
  
  /// 날짜 시간 초 형식 (yyyy-MM-dd HH:mm:ss)
  static String formatDateTimeWithSeconds(DateTime date) {
    return DateFormat('yyyy-MM-dd HH:mm:ss').format(date);
  }
  
  /// 짧은 날짜 형식 (MM/dd)
  static String formatShortDate(DateTime date) {
    return DateFormat('MM/dd').format(date);
  }
  
  /// 짧은 날짜 시간 형식 (MM/dd HH:mm)
  static String formatShortDateTime(DateTime date) {
    return DateFormat('MM/dd HH:mm').format(date);
  }
  
  /// 상대적 시간 형식 (방금 전, 5분 전, 1시간 전, 어제, 3일 전, ...)
  static String formatRelativeTime(DateTime date, {DateTime? now}) {
    now ??= DateTime.now();
    
    final difference = now.difference(date);
    
    if (difference.inSeconds < 60) {
      return '방금 전';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}분 전';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}시간 전';
    } else if (difference.inDays < 7) {
      if (difference.inDays == 1) {
        return '어제';
      }
      return '${difference.inDays}일 전';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks주 전';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return '$months개월 전';
    } else {
      final years = (difference.inDays / 365).floor();
      return '$years년 전';
    }
  }
  
  /// 상세 상대적 시간 형식 (오늘, 어제, 그 외는 날짜)
  static String formatDetailedRelativeDate(DateTime date, {DateTime? now}) {
    now ??= DateTime.now();
    
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final targetDate = DateTime(date.year, date.month, date.day);
    
    if (targetDate == today) {
      return '오늘 ${formatTime(date)}';
    } else if (targetDate == yesterday) {
      return '어제 ${formatTime(date)}';
    } else if (today.difference(targetDate).inDays < 7) {
      return formatDateWithWeekday(date);
    } else {
      return formatKoreanDate(date);
    }
  }
  
  /// 메시지 타임스탬프 형식 (오늘이면 시간만, 다른 날이면 날짜와 시간)
  static String formatMessageTimestamp(DateTime date, {DateTime? now}) {
    now ??= DateTime.now();
    
    final today = DateTime(now.year, now.month, now.day);
    final targetDate = DateTime(date.year, date.month, date.day);
    
    if (targetDate == today) {
      return formatTime(date);
    } else {
      return formatShortDateTime(date);
    }
  }
  
  /// 월 이름 가져오기
  static String getMonthName(int month) {
    final months = [
      '1월', '2월', '3월', '4월', '5월', '6월',
      '7월', '8월', '9월', '10월', '11월', '12월'
    ];
    
    if (month < 1 || month > 12) {
      throw ArgumentError('Month must be between 1 and 12');
    }
    
    return months[month - 1];
  }
  
  /// 요일 이름 가져오기
  static String getWeekdayName(int weekday) {
    final weekdays = ['월요일', '화요일', '수요일', '목요일', '금요일', '토요일', '일요일'];
    
    if (weekday < 1 || weekday > 7) {
      throw ArgumentError('Weekday must be between 1 and 7');
    }
    
    return weekdays[weekday - 1];
  }
  
  /// 짧은 요일 이름 가져오기
  static String getShortWeekdayName(int weekday) {
    final weekdays = ['월', '화', '수', '목', '금', '토', '일'];
    
    if (weekday < 1 || weekday > 7) {
      throw ArgumentError('Weekday must be between 1 and 7');
    }
    
    return weekdays[weekday - 1];
  }
  
  /// 문자열을 DateTime으로 파싱
  static DateTime? tryParse(String dateStr) {
    try {
      return DateTime.parse(dateStr);
    } catch (e) {
      return null;
    }
  }
  
  /// 날짜 범위 포맷팅 (yyyy.MM.dd ~ꯦ.MM.dd)
  static String formatDateRange(DateTime start, DateTime end) {
    final startStr = DateFormat('yyyy.MM.dd').format(start);
    final endStr = DateFormat('yyyy.MM.dd').format(end);
    return '$startStr ~ $endStr';
  }
  
  /// ISO 8601 형식으로 변환
  static String toIso8601String(DateTime date) {
    return date.toIso8601String();
  }
  
  /// ISO 8601 문자열에서 DateTime 복원
  static DateTime fromIso8601String(String dateStr) {
    return DateTime.parse(dateStr);
  }
  
  /// 두 날짜 사이의 일수 계산
  static int daysBetween(DateTime from, DateTime to) {
    final fromDate = DateTime(from.year, from.month, from.day);
    final toDate = DateTime(to.year, to.month, to.day);
    return toDate.difference(fromDate).inDays;
  }
  
  /// 해당 월의 일수 계산
  static int daysInMonth(int year, int month) {
    return DateTime(year, month + 1, 0).day;
  }
  
  /// 해당 날짜가 오늘인지 확인
  static bool isToday(DateTime date, {DateTime? now}) {
    now ??= DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }
  
  /// 해당 날짜가 어제인지 확인
  static bool isYesterday(DateTime date, {DateTime? now}) {
    now ??= DateTime.now();
    final yesterday = now.subtract(const Duration(days: 1));
    return date.year == yesterday.year && date.month == yesterday.month && date.day == yesterday.day;
  }
  
  /// 해당 날짜가 이번 주인지 확인
  static bool isThisWeek(DateTime date, {DateTime? now}) {
    now ??= DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final startDate = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
    final endDate = startDate.add(const Duration(days: 7));
    return date.isAfter(startDate.subtract(const Duration(days: 1))) && date.isBefore(endDate);
  }
  
  /// 해당 날짜가 이번 달인지 확인
  static bool isThisMonth(DateTime date, {DateTime? now}) {
    now ??= DateTime.now();
    return date.year == now.year && date.month == now.month;
  }
  
  /// 해당 날짜가 올해인지 확인
  static bool isThisYear(DateTime date, {DateTime? now}) {
    now ??= DateTime.now();
    return date.year == now.year;
  }
  
  /// 시간대 문자열 변환 (오전/오후)
  static String formatAmPm(DateTime date) {
    return date.hour < 12 ? '오전 ${date.hour == 0 ? 12 : date.hour}시' : '오후 ${date.hour == 12 ? 12 : date.hour - 12}시';
  }
}