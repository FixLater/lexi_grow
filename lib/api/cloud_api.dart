import 'package:dio/dio.dart';
import '../utils/http_request.dart';

/// 校园相关 API
class CloudApi {
  /// 更新校园信息
  static Future<Response> updateCampus(Map<String, dynamic> data) {
    return httpRequest.post('/api/xh/campus/update', data: data);
  }

  /// 获取校园列表
  static Future<Response> findResource(Map<String, dynamic> data) {
    return httpRequest.post('/app/cloud-disk/search', data: data);
  }

  /// 获取校园详情
  static Future<Response> getCampusDetail(String id) {
    return httpRequest.get('/api/xh/campus/detail/$id');
  }

  /// 删除校园
  static Future<Response> deleteCampus(String id) {
    return httpRequest.delete('/api/xh/campus/delete', data: {'id': id});
  }

  /// 创建校园
  static Future<Response> createCampus(Map<String, dynamic> data) {
    return httpRequest.post('/api/xh/campus/create', data: data);
  }
}

/// 用户相关 API 示例
class UserApi {
  /// 用户登录
  static Future<Response> login({
    required String username,
    required String password,
  }) {
    return httpRequest.post(
      '/api/user/login',
      data: {'username': username, 'password': password},
    );
  }

  /// 获取用户信息
  static Future<Response> getUserInfo() {
    return httpRequest.get('/api/user/info');
  }

  /// 更新用户信息
  static Future<Response> updateUserInfo(Map<String, dynamic> data) {
    return httpRequest.put('/api/user/update', data: data);
  }

  /// 上传头像（带进度）
  static Future<Response> uploadAvatar(
    String filePath, {
    ProgressCallback? onProgress,
  }) async {
    FormData formData = FormData.fromMap({
      'avatar': await MultipartFile.fromFile(filePath),
    });

    return httpRequest.post(
      '/api/user/avatar',
      data: formData,
      onSendProgress: onProgress,
    );
  }
}

/// 文件相关 API 示例
class FileApi {
  /// 下载文件
  static Future<Response> downloadFile(
    String url,
    String savePath, {
    ProgressCallback? onProgress,
  }) {
    return httpRequest.get(
      url,
      options: Options(
        responseType: ResponseType.bytes,
        followRedirects: false,
      ),
      onReceiveProgress: onProgress,
    );
  }
}
