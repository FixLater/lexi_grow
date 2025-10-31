/// 校园数据模型
class CampusModel {
  final String id;
  final String name;
  final String? address;
  final String? phone;
  final String? description;
  final DateTime? createdAt;

  CampusModel({
    required this.id,
    required this.name,
    this.address,
    this.phone,
    this.description,
    this.createdAt,
  });

  /// 从 JSON 创建模型
  factory CampusModel.fromJson(Map<String, dynamic> json) {
    return CampusModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      address: json['address']?.toString(),
      phone: json['phone']?.toString(),
      description: json['description']?.toString(),
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
    );
  }

  /// 转换为 JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'phone': phone,
      'description': description,
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  /// 复制并修改部分字段
  CampusModel copyWith({
    String? id,
    String? name,
    String? address,
    String? phone,
    String? description,
    DateTime? createdAt,
  }) {
    return CampusModel(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

/// API 响应模型
class ApiResponse<T> {
  final int code;
  final String message;
  final T? data;

  ApiResponse({
    required this.code,
    required this.message,
    this.data,
  });

  bool get isSuccess => code == 200;

  factory ApiResponse.fromJson(
      Map<String, dynamic> json,
      T Function(dynamic)? fromJsonT,
      ) {
    return ApiResponse(
      code: json['code'] ?? 0,
      message: json['message'] ?? '',
      data: json['data'] != null && fromJsonT != null
          ? fromJsonT(json['data'])
          : json['data'],
    );
  }
}