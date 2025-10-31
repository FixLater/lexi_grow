import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// HTTP 请求工具类
class HttpRequest {
  static final HttpRequest _instance = HttpRequest._internal();
  factory HttpRequest() => _instance;

  late Dio _dio;

  HttpRequest._internal() {
    _dio = _createDio();
  }

  /// 创建 Dio 实例
  Dio _createDio() {
    final dio = Dio();

    // 基础配置
    dio.options = BaseOptions(
      baseUrl: 'http://192.168.50.134:8200', // 替换为你的 API 地址
      connectTimeout: const Duration(seconds: 200),
      receiveTimeout: const Duration(seconds: 200),
      headers: {
        'Content-Type': 'application/json;charset=UTF-8',
      },
    );

    // 添加拦截器
    dio.interceptors.add(_createInterceptor());

    return dio;
  }

  /// 创建拦截器
  Interceptor _createInterceptor() {
    return InterceptorsWrapper(
      onRequest: (options, handler) async {
        // 请求拦截：添加 token
        final token = await _getToken();
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = token;
        }

        // 可以添加语言设置
        // options.headers['Accept-Language'] = 'zh_CN';

        debugPrint('请求URL: ${options.uri}');
        debugPrint('请求方法: ${options.method}');
        debugPrint('请求参数: ${options.data}');

        handler.next(options);
      },

      onResponse: (response, handler) {
        // 响应拦截
        debugPrint('响应数据: ${response.data}');

        // 处理特殊响应类型（如文件下载）
        final contentType = response.headers.value('content-type');
        final contentDisposition = response.headers.value('content-disposition');

        if (contentDisposition != null ||
            (contentType != null && !contentType.contains('application/json'))) {
          handler.next(response);
          return;
        }

        // 处理业务错误码
        if (response.data is Map) {
          final code = response.data['code'];
          final message = response.data['message'] ?? '未知错误';

          if (code != null && code != 200) {
            _showErrorMessage(message);
            // 可以选择继续传递或拒绝
            // handler.reject(DioException(
            //   requestOptions: response.requestOptions,
            //   response: response,
            //   type: DioExceptionType.badResponse,
            //   message: message,
            // ));
          }
        }

        handler.next(response);
      },

      onError: (error, handler) {
        // 错误拦截
        debugPrint('请求错误: ${error.message}');

        String errorMessage = '请求超时，服务器无响应！';

        if (error.response != null) {
          switch (error.response!.statusCode) {
            case 401:
              errorMessage = '登录状态已过期，需要重新登录';
              _clearAuthAndRedirect();
              break;
            case 403:
              errorMessage = '没有权限访问该资源';
              break;
            case 404:
              errorMessage = '服务器资源不存在';
              break;
            case 424:
              errorMessage = '登录状态失效，请重新登录';
              _clearAuthAndRedirect();
              break;
            case 500:
              errorMessage = '服务器内部错误';
              break;
            case 502:
              errorMessage = '服务器内部错误';
              break;
            case 503:
              errorMessage = '服务器正在更新，请稍后重试';
              break;
            default:
              errorMessage = error.response?.data?['message'] ?? '未知错误！';
          }
        }

        _showErrorMessage(errorMessage);
        handler.next(error);
      },
    );
  }

  /// 获取 Token（需要根据实际情况实现）
  Future<String?> _getToken() async {
    // TODO: 从本地存储获取 token
    // 使用 SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token') ?? "testapp";
  }

  /// 清除认证信息并重定向
  Future<void> _clearAuthAndRedirect() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  /// 显示错误消息
  void _showErrorMessage(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
    );
  }

  /// 通用请求方法
  Future<Response> request({
    required String url,
    required String method,
    Map<String, dynamic>? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    String? baseURL,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      // 如果指定了 baseURL，临时修改
      final tempBaseURL = _dio.options.baseUrl;
      if (baseURL != null) {
        _dio.options.baseUrl = baseURL;
      }

      final response = await _dio.request(
        url,
        data: data,
        queryParameters: queryParameters,
        options: (options ?? Options()).copyWith(method: method),
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );

      // 恢复原来的 baseURL
      if (baseURL != null) {
        _dio.options.baseUrl = tempBaseURL;
      }

      return response;
    } catch (e) {
      rethrow;
    }
  }

  /// GET 请求
  Future<Response> get(
      String url, {
        Map<String, dynamic>? queryParameters,
        Options? options,
        String? baseURL,
        CancelToken? cancelToken,
        ProgressCallback? onReceiveProgress,
      }) {
    return request(
      url: url,
      method: 'GET',
      queryParameters: queryParameters,
      options: options,
      baseURL: baseURL,
      cancelToken: cancelToken,
      onReceiveProgress: onReceiveProgress,
    );
  }

  /// POST 请求
  Future<Response> post(
      String url, {
        dynamic data,
        Map<String, dynamic>? queryParameters,
        Options? options,
        String? baseURL,
        CancelToken? cancelToken,
        ProgressCallback? onSendProgress,
        ProgressCallback? onReceiveProgress,
      }) {
    return request(
      url: url,
      method: 'POST',
      data: data,
      queryParameters: queryParameters,
      options: options,
      baseURL: baseURL,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );
  }

  /// PUT 请求
  Future<Response> put(
      String url, {
        dynamic data,
        Map<String, dynamic>? queryParameters,
        Options? options,
        String? baseURL,
        CancelToken? cancelToken,
        ProgressCallback? onSendProgress,
        ProgressCallback? onReceiveProgress,
      }) {
    return request(
      url: url,
      method: 'PUT',
      data: data,
      queryParameters: queryParameters,
      options: options,
      baseURL: baseURL,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );
  }

  /// DELETE 请求
  Future<Response> delete(
      String url, {
        dynamic data,
        Map<String, dynamic>? queryParameters,
        Options? options,
        String? baseURL,
        CancelToken? cancelToken,
      }) {
    return request(
      url: url,
      method: 'DELETE',
      data: data,
      queryParameters: queryParameters,
      options: options,
      baseURL: baseURL,
      cancelToken: cancelToken,
    );
  }
}

/// 导出单例实例
final httpRequest = HttpRequest();