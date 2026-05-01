class ShopProfileException implements Exception {
  ShopProfileException(this.code, this.message, [this.metadata]);

  final int code;
  final String message;
  final dynamic metadata;

  @override
  String toString() => message;
}

class ShopProfileStatusModel {
  ShopProfileStatusModel({
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

  factory ShopProfileStatusModel.fromJson(Map<String, dynamic> json) {
    return ShopProfileStatusModel(
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
