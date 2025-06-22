import 'package:dio/dio.dart';

class ApiService {
  late final Dio _dio;
  static const String baseUrl = 'https://api.yourapp.com'; // 실제 API URL로 변경

  ApiService() {
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    _setupInterceptors();
  }

  void _setupInterceptors() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          // 요청 로깅
          print('REQUEST[${options.method}] => PATH: ${options.path}');
          handler.next(options);
        },
        onResponse: (response, handler) {
          // 응답 로깅
          print(
              'RESPONSE[${response.statusCode}] => PATH: ${response.requestOptions.path}');
          handler.next(response);
        },
        onError: (error, handler) {
          // 에러 로깅
          print(
              'ERROR[${error.response?.statusCode}] => PATH: ${error.requestOptions.path}');
          handler.next(error);
        },
      ),
    );
  }

  // GET 요청
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.get<T>(
        path,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // POST 요청
  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // PUT 요청
  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.put<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // DELETE 요청
  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.delete<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // 에러 처리
  Exception _handleError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return Exception('연결 시간이 초과되었습니다.');
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        final message = error.response?.data?['message'] ?? '서버 오류가 발생했습니다.';
        return Exception('서버 오류 ($statusCode): $message');
      case DioExceptionType.cancel:
        return Exception('요청이 취소되었습니다.');
      default:
        return Exception('네트워크 오류가 발생했습니다.');
    }
  }
}
