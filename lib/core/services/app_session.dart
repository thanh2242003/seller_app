class AppSession {
  AppSession._();

  static final AppSession instance = AppSession._();

  bool _isAuthenticated = false;
  String _shopName = 'Aurora Store';
  String _sellerName = 'Nguyen Minh';
  String? _userId;
  String? _email;
  String? _status;
  bool _isVerified = false;
  String? _blockedReason;

  bool get isAuthenticated => _isAuthenticated;
  String get shopName => _shopName;
  String get sellerName => _sellerName;
  String? get userId => _userId;
  String? get email => _email;
  String? get status => _status;
  bool get isVerified => _isVerified;
  String? get blockedReason => _blockedReason;
  bool get isActive => _status == 'active';
  bool get isPending => _status == 'inactive';
  bool get isBlocked => _status == 'blocked';

  void setAuthenticated({
    required String userId,
    required String shopName,
    required String email,
    String? status,
    bool? isVerified,
    String? blockedReason,
  }) {
    _isAuthenticated = true;
    _userId = userId;
    _shopName = shopName;
    _sellerName = shopName;
    _email = email;
    _status = status;
    _isVerified = isVerified ?? false;
    _blockedReason = blockedReason;
  }

  void updateStatus({String? status, bool? isVerified, String? blockedReason}) {
    if (status != null) {
      _status = status;
    }
    if (isVerified != null) {
      _isVerified = isVerified;
    }
    if (blockedReason != null) {
      _blockedReason = blockedReason;
    }
  }

  void signOut() {
    _isAuthenticated = false;
    _userId = null;
    _email = null;
    _status = null;
    _isVerified = false;
    _blockedReason = null;
  }
}
