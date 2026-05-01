class AuthException implements Exception {
  AuthException(this.code, this.message, [this.metadata]);

  final int code;
  final String message;
  final dynamic metadata;

  @override
  String toString() => message;
}

class AuthResultModel {
  AuthResultModel({required this.shop, required this.tokens});

  final AuthShopModel shop;
  final AuthTokensModel tokens;

  factory AuthResultModel.fromJson(Map<String, dynamic> json) {
    return AuthResultModel(
      shop: AuthShopModel.fromJson(
        Map<String, dynamic>.from(json['shop'] as Map),
      ),
      tokens: AuthTokensModel.fromJson(
        Map<String, dynamic>.from(json['tokens'] as Map),
      ),
    );
  }
}

class AuthShopModel {
  AuthShopModel({
    required this.id,
    required this.name,
    required this.email,
    this.status,
    this.verify,
  });

  final String id;
  final String name;
  final String email;
  final String? status;
  final bool? verify;

  factory AuthShopModel.fromJson(Map<String, dynamic> json) {
    return AuthShopModel(
      id: json['_id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      status: json['status']?.toString(),
      verify: json['verify'] == true,
    );
  }
}

class AuthTokensModel {
  AuthTokensModel({required this.accessToken, required this.refreshToken});

  final String accessToken;
  final String refreshToken;

  factory AuthTokensModel.fromJson(Map<String, dynamic> json) {
    return AuthTokensModel(
      accessToken: json['accessToken']?.toString() ?? '',
      refreshToken: json['refreshToken']?.toString() ?? '',
    );
  }
}

class AuthStatusModel {
  AuthStatusModel({
    required this.status,
    required this.isActive,
    required this.isBlocked,
    required this.isPending,
    required this.verify,
    required this.verifiedAt,
    required this.verifiedBy,
    required this.blockedAt,
    required this.blockedReason,
  });

  final String status;
  final bool isActive;
  final bool isBlocked;
  final bool isPending;
  final bool verify;
  final DateTime? verifiedAt;
  final String? verifiedBy;
  final DateTime? blockedAt;
  final String blockedReason;

  factory AuthStatusModel.fromJson(Map<String, dynamic> json) {
    return AuthStatusModel(
      status: json['status']?.toString() ?? 'inactive',
      isActive: json['isActive'] == true,
      isBlocked: json['isBlocked'] == true,
      isPending: json['isPending'] == true,
      verify: json['verify'] == true,
      verifiedAt: _parseDate(json['verifiedAt']),
      verifiedBy: json['verifiedBy']?.toString(),
      blockedAt: _parseDate(json['blockedAt']),
      blockedReason: json['blockedReason']?.toString() ?? '',
    );
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) {
      return null;
    }
    return DateTime.tryParse(value.toString());
  }
}
