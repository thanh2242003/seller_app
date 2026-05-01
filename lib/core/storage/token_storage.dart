class TokenStorage {
  static const String _accessTokenKey = 'accessToken';
  static const String _refreshTokenKey = 'refreshToken';
  static const String _userIdKey = 'userId';
  static const String _fcmTokenKey = 'fcmToken';

  static final Map<String, String> _storage = <String, String>{};

  /// Save both access token and refresh token
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    _storage[_accessTokenKey] = accessToken;
    _storage[_refreshTokenKey] = refreshToken;
  }

  /// 🔥 thêm
  Future<void> saveUserId(String userId) async {
    _storage[_userIdKey] = userId;
  }

  /// Get access token
  Future<String?> getAccessToken() async {
    return _storage[_accessTokenKey];
  }

  /// Get refresh token
  Future<String?> getRefreshToken() async {
    return _storage[_refreshTokenKey];
  }

  /// 🔥 thêm
  Future<String?> getUserId() async {
    return _storage[_userIdKey];
  }

  /// Clear all tokens
  Future<void> clearTokens() async {
    _storage.remove(_accessTokenKey);
    _storage.remove(_refreshTokenKey);
    _storage.remove(_userIdKey);
    _storage.remove(_fcmTokenKey);
  }

  /// Check if access token exists
  Future<bool> hasAccessToken() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }

  Future<void> saveFcmToken(String token) async {
    _storage[_fcmTokenKey] = token;
  }

  Future<String?> getFcmToken() async {
    return _storage[_fcmTokenKey];
  }

  Future<void> clearFcmToken() async {
    _storage.remove(_fcmTokenKey);
  }
}
