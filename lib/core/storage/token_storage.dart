import 'package:shared_preferences/shared_preferences.dart';

class TokenStorage {
  static const String _accessTokenKey = 'accessToken';
  static const String _refreshTokenKey = 'refreshToken';
  static const String _userIdKey = 'userId';
  static const String _shopNameKey = 'shopName';
  static const String _emailKey = 'email';
  static const String _statusKey = 'status';
  static const String _isVerifiedKey = 'isVerified';
  static const String _blockedReasonKey = 'blockedReason';
  static const String _fcmTokenKey = 'fcmToken';

  Future<SharedPreferences> _prefs() async {
    return SharedPreferences.getInstance();
  }

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    final prefs = await _prefs();
    await prefs.setString(_accessTokenKey, accessToken);
    await prefs.setString(_refreshTokenKey, refreshToken);
  }

  Future<void> saveUserId(String userId) async {
    final prefs = await _prefs();
    await prefs.setString(_userIdKey, userId);
  }

  Future<void> saveSession({
    required String accessToken,
    required String refreshToken,
    required String userId,
    required String shopName,
    required String email,
    String? status,
    bool? isVerified,
    String? blockedReason,
  }) async {
    final prefs = await _prefs();
    await prefs.setString(_accessTokenKey, accessToken);
    await prefs.setString(_refreshTokenKey, refreshToken);
    await prefs.setString(_userIdKey, userId);
    await prefs.setString(_shopNameKey, shopName);
    await prefs.setString(_emailKey, email);
    if (status != null) {
      await prefs.setString(_statusKey, status);
    }
    if (isVerified != null) {
      await prefs.setBool(_isVerifiedKey, isVerified);
    }
    if (blockedReason != null) {
      await prefs.setString(_blockedReasonKey, blockedReason);
    }
  }

  Future<String?> getAccessToken() async {
    final prefs = await _prefs();
    return prefs.getString(_accessTokenKey);
  }

  Future<String?> getRefreshToken() async {
    final prefs = await _prefs();
    return prefs.getString(_refreshTokenKey);
  }

  Future<String?> getUserId() async {
    final prefs = await _prefs();
    return prefs.getString(_userIdKey);
  }

  Future<StoredAuthSession?> loadSession() async {
    final prefs = await _prefs();
    final accessToken = prefs.getString(_accessTokenKey);
    final refreshToken = prefs.getString(_refreshTokenKey);
    final userId = prefs.getString(_userIdKey);
    if (accessToken == null || refreshToken == null || userId == null) {
      return null;
    }

    return StoredAuthSession(
      accessToken: accessToken,
      refreshToken: refreshToken,
      userId: userId,
      shopName: prefs.getString(_shopNameKey) ?? 'Aurora Store',
      email: prefs.getString(_emailKey) ?? '',
      status: prefs.getString(_statusKey),
      isVerified: prefs.getBool(_isVerifiedKey) ?? false,
      blockedReason: prefs.getString(_blockedReasonKey),
    );
  }

  Future<void> clearTokens() async {
    final prefs = await _prefs();
    await prefs.remove(_accessTokenKey);
    await prefs.remove(_refreshTokenKey);
    await prefs.remove(_userIdKey);
    await prefs.remove(_shopNameKey);
    await prefs.remove(_emailKey);
    await prefs.remove(_statusKey);
    await prefs.remove(_isVerifiedKey);
    await prefs.remove(_blockedReasonKey);
    await prefs.remove(_fcmTokenKey);
  }

  Future<bool> hasAccessToken() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }

  Future<void> saveFcmToken(String token) async {
    final prefs = await _prefs();
    await prefs.setString(_fcmTokenKey, token);
  }

  Future<String?> getFcmToken() async {
    final prefs = await _prefs();
    return prefs.getString(_fcmTokenKey);
  }

  Future<void> clearFcmToken() async {
    final prefs = await _prefs();
    await prefs.remove(_fcmTokenKey);
  }
}

class StoredAuthSession {
  StoredAuthSession({
    required this.accessToken,
    required this.refreshToken,
    required this.userId,
    required this.shopName,
    required this.email,
    required this.status,
    required this.isVerified,
    required this.blockedReason,
  });

  final String accessToken;
  final String refreshToken;
  final String userId;
  final String shopName;
  final String email;
  final String? status;
  final bool isVerified;
  final String? blockedReason;
}
