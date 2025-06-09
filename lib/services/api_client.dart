// 새 폴더/lib/services/api_client.dart
import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../utils/constants.dart';
import '../utils/logger.dart';

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;
  ApiClient._internal();
  late final Dio _dio;

  // 제거됨: final _logger = Logger(); // 더 이상 필요 없음

  void initialize() {
    _dio = Dio(BaseOptions(
      baseUrl: ApiConstants.dynamicBackendBaseUrl,
      connectTimeout: Duration(milliseconds: ApiConstants.connectionTimeout),
      receiveTimeout: Duration(milliseconds: ApiConstants.receiveTimeout),
      headers: {
        ApiConstants.contentTypeHeader: ApiConstants.applicationJson,
        ApiConstants.acceptHeader: ApiConstants.applicationJson,
      },
    ));

    AppLogger.info('API 클라이언트 초기화 - Base URL: ${ApiConstants.dynamicBackendBaseUrl}');

    // 요청 인터셉터
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        // Firebase Auth Token 추가
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          try {
            final idToken = await user.getIdToken(true); // 강제 새로고침
            if (idToken != null && idToken.isNotEmpty) {
              options.headers[ApiConstants.authHeader] = 'Bearer $idToken';
              AppLogger.debug('Firebase 토큰 헤더 추가 성공 - 토큰 길이: ${idToken.length}');
            } else {
              AppLogger.warning('Firebase 토큰이 null 또는 빈 문자열입니다');
            }
          } catch (e) {
            AppLogger.error('Firebase 토큰 가져오기 실패: $e');
          }
        } else {
          AppLogger.warning('현재 로그인된 Firebase 사용자가 없습니다');
        }

        AppLogger.debug('요청 헤더: ${options.headers}');
        AppLogger.info('API 요청: ${options.method} ${options.uri}');
        if (options.data != null) {
          AppLogger.debug('요청 데이터: ${options.data}');
        }

        handler.next(options);
      },
      onResponse: (response, handler) {
        AppLogger.info('API 응답: ${response.statusCode} ${response.requestOptions.uri}');
        AppLogger.debug('응답 데이터: ${response.data}');
        handler.next(response);
      },
      onError: (error, handler) {
        AppLogger.error('API 오류: ${error.response?.statusCode} ${error.requestOptions.uri}');
        AppLogger.error('오류 메시지: ${error.message}');
        if (error.response?.data != null) {
          AppLogger.error('오류 데이터: ${error.response?.data}');
        }
        handler.next(error);
      },
    ));
  }

  // GET 요청
  Future<ApiResponse<T>> get<T>(
      String path, {
        Map<String, dynamic>? queryParameters,
        T Function(Map<String, dynamic>)? fromJson,
      }) async {
    try {
      final response = await _dio.get(
        path,
        queryParameters: queryParameters,
      );
      return _handleResponse<T>(response, fromJson);
    } catch (e) {
      return _handleError<T>(e);
    }
  }

  // POST 요청
  Future<ApiResponse<T>> post<T>(
      String path, {
        dynamic data,
        Map<String, dynamic>? queryParameters,
        T Function(Map<String, dynamic>)? fromJson,
      }) async {
    try {
      final response = await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
      );
      return _handleResponse<T>(response, fromJson);
    } catch (e) {
      return _handleError<T>(e);
    }
  }

  // PUT 요청
  Future<ApiResponse<T>> put<T>(
      String path, {
        dynamic data,
        Map<String, dynamic>? queryParameters,
        T Function(Map<String, dynamic>)? fromJson,
      }) async {
    try {
      final response = await _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
      );
      return _handleResponse<T>(response, fromJson);
    } catch (e) {
      return _handleError<T>(e);
    }
  }

  // DELETE 요청
  Future<ApiResponse<T>> delete<T>(
      String path, {
        Map<String, dynamic>? queryParameters,
        T Function(Map<String, dynamic>)? fromJson,
      }) async {
    try {
      final response = await _dio.delete(
        path,
        queryParameters: queryParameters,
      );
      return _handleResponse<T>(response, fromJson);
    } catch (e) {
      return _handleError<T>(e);
    }
  }

  // GET 요청 (리스트)
  Future<ApiListResponse<T>> getList<T>(
      String path, {
        Map<String, dynamic>? queryParameters,
        T Function(Map<String, dynamic>)? fromJson,
      }) async {
    try {
      final response = await _dio.get(
        path,
        queryParameters: queryParameters,
      );
      return _handleListResponse<T>(response, fromJson);
    } catch (e) {
      return _handleListError<T>(e);
    }
  }

  // 응답 처리
  ApiResponse<T> _handleResponse<T>(
      Response response,
      T Function(Map<String, dynamic>)? fromJson,
      ) {
    if (response.statusCode! >= 200 && response.statusCode! < 300) {
      if (fromJson != null && response.data != null) {
        try {
          final data = fromJson(response.data as Map<String, dynamic>);
          return ApiResponse.success(data);
        } catch (e) {
          AppLogger.error('JSON 파싱 오류: $e');
          return ApiResponse.error('데이터 파싱 중 오류가 발생했습니다.');
        }
      } else {
        return ApiResponse.success(response.data as T);
      }
    } else {
      return ApiResponse.error(_getErrorMessage(response));
    }
  }

  // 리스트 응답 처리
  ApiListResponse<T> _handleListResponse<T>(
      Response response,
      T Function(Map<String, dynamic>)? fromJson,
      ) {
    if (response.statusCode! >= 200 && response.statusCode! < 300) {
      if (fromJson != null && response.data != null) {
        try {
          final List<dynamic> dataList = response.data as List<dynamic>;
          final List<T> items = dataList
              .map((item) => fromJson(item as Map<String, dynamic>))
              .toList();
          return ApiListResponse.success(items);
        } catch (e) {
          AppLogger.error('JSON 파싱 오류: $e');
          return ApiListResponse.error('데이터 파싱 중 오류가 발생했습니다.');
        }
      } else {
        return ApiListResponse.success(response.data as List<T>);
      }
    } else {
      return ApiListResponse.error(_getErrorMessage(response));
    }
  }

  // 오류 처리
  ApiResponse<T> _handleError<T>(dynamic error) {
    AppLogger.error('API 클라이언트 개별 요청 오류: $error');
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.receiveTimeout:
          return ApiResponse.error('연결 시간이 초과되었습니다.');
        case DioExceptionType.connectionError:
          return ApiResponse.error('네트워크 연결을 확인해주세요.');
        case DioExceptionType.badResponse:
          return ApiResponse.error(_getErrorMessage(error.response));
        case DioExceptionType.cancel:
          return ApiResponse.error('요청이 취소되었습니다.');
        case DioExceptionType.badCertificate:
          return ApiResponse.error('안전하지 않은 서버 인증서입니다.');
        case DioExceptionType.sendTimeout:
          return ApiResponse.error('데이터 전송 시간이 초과되었습니다.');
        default:
          return ApiResponse.error('알 수 없는 오류가 발생했습니다.');
      }
    } else {
      return ApiResponse.error('예상치 못한 오류가 발생했습니다.');
    }
  }

  // 리스트 오류 처리
  ApiListResponse<T> _handleListError<T>(dynamic error) {
    AppLogger.error('API 클라이언트 리스트 요청 오류: $error');
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.receiveTimeout:
          return ApiListResponse.error('연결 시간이 초과되었습니다.');
        case DioExceptionType.connectionError:
          return ApiListResponse.error('네트워크 연결을 확인해주세요.');
        case DioExceptionType.badResponse:
          return ApiListResponse.error(_getErrorMessage(error.response));
        case DioExceptionType.cancel:
          return ApiListResponse.error('요청이 취소되었습니다.');
        case DioExceptionType.badCertificate:
          return ApiListResponse.error('안전하지 않은 서버 인증서입니다.');
        case DioExceptionType.sendTimeout:
          return ApiListResponse.error('데이터 전송 시간이 초과되었습니다.');
        default:
          return ApiListResponse.error('알 수 없는 오류가 발생했습니다.');
      }
    } else {
      return ApiListResponse.error('예상치 못한 오류가 발생했습니다.');
    }
  }

  // 오류 메시지 추출
  String _getErrorMessage(Response? response) {
    if (response == null) return '서버 응답이 없습니다.';

    try {
      final data = response.data;
      if (data is Map<String, dynamic>) {
        AppLogger.warning('응답 데이터에서 오류 메시지 파싱 시도: $data');
        return data['message'] ?? data['error'] ?? '서버 오류가 발생했습니다.';
      } else if (data is String) {
        AppLogger.warning('응답 데이터가 문자열입니다: $data');
        return data;
      }
    } catch (e) {
      AppLogger.warning('응답 데이터에서 오류 메시지 파싱 중 오류 발생: $e');
    }

    return 'HTTP ${response.statusCode}: 서버 오류가 발생했습니다.';
  }
}

// API 응답 클래스
class ApiResponse<T> {
  final bool success;
  final T? data;
  final String? error;

  ApiResponse._({
    required this.success,
    this.data,
    this.error,
  });

  factory ApiResponse.success(T data) {
    return ApiResponse._(success: true, data: data);
  }

  factory ApiResponse.error(String error) {
    return ApiResponse._(success: false, error: error);
  }

  bool get isSuccess => success;
  bool get isError => !success;
}

// API 리스트 응답 클래스
class ApiListResponse<T> {
  final bool success;
  final List<T>? data;
  final String? error;

  ApiListResponse._({
    required this.success,
    this.data,
    this.error,
  });

  factory ApiListResponse.success(List<T> data) {
    return ApiListResponse._(success: true, data: data);
  }

  factory ApiListResponse.error(String error) {
    return ApiListResponse._(success: false, error: error);
  }

  bool get isSuccess => success;
  bool get isError => !success;
}