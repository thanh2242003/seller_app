import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../services/app_session.dart';
import '../storage/token_storage.dart';

class ShopApiException implements Exception {
  ShopApiException(this.code, this.message, [this.metadata]);

  final int code;
  final String message;
  final dynamic metadata;

  @override
  String toString() => 'ShopApiException(code: $code, message: $message)';
}

class ShopApiService {
  ShopApiService({TokenStorage? tokenStorage, http.Client? client})
    : _tokenStorage = tokenStorage ?? TokenStorage(),
      _client = client ?? http.Client();

  final TokenStorage _tokenStorage;
  final http.Client _client;

  Future<ShopAuthResult> signIn({
    required String email,
    required String password,
  }) async {
    final response = await _sendJson(
      method: 'POST',
      path: '/shop/signin',
      body: {'email': email, 'password': password},
    );
    return ShopAuthResult.fromJson(_metadataMap(response));
  }

  Future<ShopAuthResult> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    final response = await _sendJson(
      method: 'POST',
      path: '/shop/signup',
      body: {'name': name, 'email': email, 'password': password},
    );
    return ShopAuthResult.fromJson(_metadataMap(response));
  }

  Future<ShopStatusInfo> getShopStatus() async {
    final response = await _sendJson(
      method: 'GET',
      path: '/shop/status',
      authRequired: true,
    );
    return ShopStatusInfo.fromJson(_metadataMap(response));
  }

  Future<ShopDashboardMetrics> getDashboard() async {
    final response = await _sendJson(
      method: 'GET',
      path: '/shop/dashboard',
      authRequired: true,
    );
    return ShopDashboardMetrics.fromJson(_metadataMap(response));
  }

  Future<ShopOrdersResult> getOrders({
    int page = 1,
    int limit = 10,
    String? status,
  }) async {
    final queryParameters = <String, String>{
      'page': page.toString(),
      'limit': limit.toString(),
      if (status != null && status.isNotEmpty && status != 'all')
        'status': status,
    };

    final response = await _sendJson(
      method: 'GET',
      path: '/shop/orders',
      authRequired: true,
      queryParameters: queryParameters,
    );
    return ShopOrdersResult.fromJson(_metadataMap(response));
  }

  Future<ShopOrderDetail> getOrderDetail(String id) async {
    final response = await _sendJson(
      method: 'GET',
      path: '/shop/orders/$id',
      authRequired: true,
    );
    return ShopOrderDetail.fromJson(_metadataMap(response));
  }

  Future<ShopOrderDetail> updateOrderStatus({
    required String orderId,
    required String status,
  }) async {
    final response = await _sendJson(
      method: 'PATCH',
      path: '/shop/orders/$orderId/status',
      authRequired: true,
      body: {'status': status},
    );

    final metadata = _metadataMap(response);
    if (metadata.isEmpty) {
      return getOrderDetail(orderId);
    }

    return ShopOrderDetail.fromJson(metadata);
  }

  Future<Map<String, dynamic>> _sendJson({
    required String method,
    required String path,
    Map<String, dynamic>? body,
    Map<String, String>? queryParameters,
    bool authRequired = false,
  }) async {
    final uri = Uri.parse(
      '${ApiConfig.baseUrl}$path',
    ).replace(queryParameters: queryParameters);

    final headers = <String, String>{'Content-Type': 'application/json'};
    if (authRequired) {
      final accessToken = await _tokenStorage.getAccessToken();
      final userId = await _tokenStorage.getUserId();
      if (accessToken == null || accessToken.isEmpty) {
        throw ShopApiException(401, 'Invalid request - missing access token');
      }
      if (userId == null || userId.isEmpty) {
        throw ShopApiException(401, 'Invalid request - missing client ID');
      }
      headers['authorization'] = accessToken;
      headers['x-client-id'] = userId;
    }

    final response = switch (method) {
      'GET' => await _client.get(uri, headers: headers),
      'POST' => await _client.post(
        uri,
        headers: headers,
        body: jsonEncode(body ?? <String, dynamic>{}),
      ),
      'PATCH' => await _client.patch(
        uri,
        headers: headers,
        body: jsonEncode(body ?? <String, dynamic>{}),
      ),
      _ => throw UnsupportedError('Unsupported method: $method'),
    };

    final decoded = _decodeResponse(response.body);
    final code = decoded['code'] is int
        ? decoded['code'] as int
        : response.statusCode;
    final message = decoded['message']?.toString() ?? 'Request failed';

    if (response.statusCode < 200 ||
        response.statusCode >= 300 ||
        code >= 400) {
      throw ShopApiException(code, message, decoded['metadata']);
    }

    return decoded;
  }

  Map<String, dynamic> _decodeResponse(String body) {
    final decoded = jsonDecode(body);
    if (decoded is Map<String, dynamic>) {
      return decoded;
    }
    throw ShopApiException(500, 'Invalid response format from server');
  }

  Map<String, dynamic> _metadataMap(Map<String, dynamic> response) {
    final metadata = response['metadata'];
    if (metadata is Map<String, dynamic>) {
      return metadata;
    }
    if (metadata is Map) {
      return Map<String, dynamic>.from(metadata);
    }
    return <String, dynamic>{};
  }
}

class ShopAuthResult {
  ShopAuthResult({required this.shop, required this.tokens});

  final ShopAccount shop;
  final ShopTokens tokens;

  factory ShopAuthResult.fromJson(Map<String, dynamic> json) {
    return ShopAuthResult(
      shop: ShopAccount.fromJson(
        Map<String, dynamic>.from(json['shop'] as Map),
      ),
      tokens: ShopTokens.fromJson(
        Map<String, dynamic>.from(json['tokens'] as Map),
      ),
    );
  }
}

class ShopAccount {
  ShopAccount({
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

  factory ShopAccount.fromJson(Map<String, dynamic> json) {
    return ShopAccount(
      id: json['_id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      status: json['status']?.toString(),
      verify: json['verify'] == true,
    );
  }
}

class ShopTokens {
  ShopTokens({required this.accessToken, required this.refreshToken});

  final String accessToken;
  final String refreshToken;

  factory ShopTokens.fromJson(Map<String, dynamic> json) {
    return ShopTokens(
      accessToken: json['accessToken']?.toString() ?? '',
      refreshToken: json['refreshToken']?.toString() ?? '',
    );
  }
}

class ShopStatusInfo {
  ShopStatusInfo({
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

  factory ShopStatusInfo.fromJson(Map<String, dynamic> json) {
    return ShopStatusInfo(
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

class ShopDashboardMetrics {
  ShopDashboardMetrics({
    required this.totalRevenue,
    required this.totalOrders,
    required this.totalProducts,
    required this.totalCustomers,
    required this.ordersByStatus,
    required this.topSellingProducts,
    required this.lowStockProducts,
  });

  final int totalRevenue;
  final int totalOrders;
  final int totalProducts;
  final int totalCustomers;
  final Map<String, int> ordersByStatus;
  final List<ShopTopSellingProduct> topSellingProducts;
  final List<ShopLowStockProduct> lowStockProducts;

  factory ShopDashboardMetrics.fromJson(Map<String, dynamic> json) {
    return ShopDashboardMetrics(
      totalRevenue: _intValue(json['totalRevenue']),
      totalOrders: _intValue(json['totalOrders']),
      totalProducts: _intValue(json['totalProducts']),
      totalCustomers: _intValue(json['totalCustomers']),
      ordersByStatus: Map<String, int>.fromEntries(
        (json['ordersByStatus'] as Map<String, dynamic>? ?? {}).entries.map(
          (entry) => MapEntry(entry.key, _intValue(entry.value)),
        ),
      ),
      topSellingProducts: ((json['topSellingProducts'] as List<dynamic>?) ?? [])
          .map(
            (item) => ShopTopSellingProduct.fromJson(
              Map<String, dynamic>.from(item as Map),
            ),
          )
          .toList(),
      lowStockProducts: ((json['lowStockProducts'] as List<dynamic>?) ?? [])
          .map(
            (item) => ShopLowStockProduct.fromJson(
              Map<String, dynamic>.from(item as Map),
            ),
          )
          .toList(),
    );
  }

  static int _intValue(dynamic value) {
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}

class ShopTopSellingProduct {
  ShopTopSellingProduct({
    required this.productId,
    required this.title,
    required this.totalSold,
    required this.revenue,
  });

  final String productId;
  final String title;
  final int totalSold;
  final int revenue;

  factory ShopTopSellingProduct.fromJson(Map<String, dynamic> json) {
    return ShopTopSellingProduct(
      productId: json['productId']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      totalSold: ShopDashboardMetrics._intValue(json['totalSold']),
      revenue: ShopDashboardMetrics._intValue(json['revenue']),
    );
  }
}

class ShopLowStockProduct {
  ShopLowStockProduct({
    required this.productId,
    required this.title,
    required this.currentStock,
  });

  final String productId;
  final String title;
  final int currentStock;

  factory ShopLowStockProduct.fromJson(Map<String, dynamic> json) {
    return ShopLowStockProduct(
      productId: json['productId']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      currentStock: ShopDashboardMetrics._intValue(json['currentStock']),
    );
  }
}

class ShopOrdersResult {
  ShopOrdersResult({required this.orders, required this.pagination});

  final List<ShopOrderSummary> orders;
  final ShopPagination pagination;

  factory ShopOrdersResult.fromJson(Map<String, dynamic> json) {
    return ShopOrdersResult(
      orders: ((json['orders'] as List<dynamic>?) ?? [])
          .map(
            (item) => ShopOrderSummary.fromJson(
              Map<String, dynamic>.from(item as Map),
            ),
          )
          .toList(),
      pagination: ShopPagination.fromJson(
        Map<String, dynamic>.from(json['pagination'] as Map),
      ),
    );
  }
}

class ShopPagination {
  ShopPagination({
    required this.page,
    required this.limit,
    required this.total,
    required this.pages,
  });

  final int page;
  final int limit;
  final int total;
  final int pages;

  factory ShopPagination.fromJson(Map<String, dynamic> json) {
    return ShopPagination(
      page: _intValue(json['page']),
      limit: _intValue(json['limit']),
      total: _intValue(json['total']),
      pages: _intValue(json['pages']),
    );
  }

  static int _intValue(dynamic value) {
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}

class ShopOrderSummary {
  ShopOrderSummary({
    required this.id,
    required this.userId,
    required this.shopId,
    required this.status,
    required this.items,
    required this.totalAmount,
    required this.shippingAddress,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String userId;
  final String shopId;
  final String status;
  final List<ShopOrderSummaryItem> items;
  final int totalAmount;
  final String shippingAddress;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory ShopOrderSummary.fromJson(Map<String, dynamic> json) {
    return ShopOrderSummary(
      id: json['_id']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',
      shopId: json['shopId']?.toString() ?? '',
      status: json['status']?.toString() ?? 'pending',
      items: ((json['items'] as List<dynamic>?) ?? [])
          .map(
            (item) => ShopOrderSummaryItem.fromJson(
              Map<String, dynamic>.from(item as Map),
            ),
          )
          .toList(),
      totalAmount: _intValue(json['totalAmount']),
      shippingAddress: json['shippingAddress']?.toString() ?? '',
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? ''),
      updatedAt: DateTime.tryParse(json['updatedAt']?.toString() ?? ''),
    );
  }

  static int _intValue(dynamic value) {
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}

class ShopOrderSummaryItem {
  ShopOrderSummaryItem({
    required this.productId,
    required this.quantity,
    required this.price,
  });

  final String productId;
  final int quantity;
  final int price;

  factory ShopOrderSummaryItem.fromJson(Map<String, dynamic> json) {
    return ShopOrderSummaryItem(
      productId: json['productId']?.toString() ?? '',
      quantity: ShopOrderSummary._intValue(json['quantity']),
      price: ShopOrderSummary._intValue(json['price']),
    );
  }
}

class ShopOrderDetail {
  ShopOrderDetail({
    required this.id,
    required this.customer,
    required this.shopId,
    required this.status,
    required this.items,
    required this.totalAmount,
    required this.shippingAddress,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final ShopOrderCustomer customer;
  final String shopId;
  final String status;
  final List<ShopOrderDetailItem> items;
  final int totalAmount;
  final String shippingAddress;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory ShopOrderDetail.fromJson(Map<String, dynamic> json) {
    return ShopOrderDetail(
      id: json['_id']?.toString() ?? '',
      customer: ShopOrderCustomer.fromJson(
        Map<String, dynamic>.from(json['userId'] as Map),
      ),
      shopId: json['shopId']?.toString() ?? '',
      status: json['status']?.toString() ?? 'pending',
      items: ((json['items'] as List<dynamic>?) ?? [])
          .map(
            (item) => ShopOrderDetailItem.fromJson(
              Map<String, dynamic>.from(item as Map),
            ),
          )
          .toList(),
      totalAmount: ShopOrderSummary._intValue(json['totalAmount']),
      shippingAddress: json['shippingAddress']?.toString() ?? '',
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? ''),
      updatedAt: DateTime.tryParse(json['updatedAt']?.toString() ?? ''),
    );
  }
}

class ShopOrderCustomer {
  ShopOrderCustomer({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
  });

  final String id;
  final String name;
  final String email;
  final String phone;

  factory ShopOrderCustomer.fromJson(Map<String, dynamic> json) {
    return ShopOrderCustomer(
      id: json['_id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
    );
  }
}

class ShopOrderDetailItem {
  ShopOrderDetailItem({
    required this.product,
    required this.quantity,
    required this.color,
    required this.size,
  });

  final ShopOrderProduct product;
  final int quantity;
  final String color;
  final String size;

  factory ShopOrderDetailItem.fromJson(Map<String, dynamic> json) {
    return ShopOrderDetailItem(
      product: ShopOrderProduct.fromJson(
        json['productId'] is Map
            ? Map<String, dynamic>.from(json['productId'] as Map)
            : <String, dynamic>{'id': json['productId']?.toString() ?? ''},
      ),
      quantity: ShopOrderSummary._intValue(json['quantity']),
      color: json['color']?.toString() ?? '',
      size: json['size']?.toString() ?? '',
    );
  }
}

class ShopOrderProduct {
  ShopOrderProduct({
    required this.id,
    required this.title,
    required this.images,
    required this.price,
  });

  final String id;
  final String title;
  final List<String> images;
  final int price;

  factory ShopOrderProduct.fromJson(Map<String, dynamic> json) {
    return ShopOrderProduct(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      images: ((json['images'] as List<dynamic>?) ?? [])
          .map((item) => item.toString())
          .toList(),
      price: ShopOrderSummary._intValue(json['price']),
    );
  }
}

Future<void> saveAuthenticatedSession({
  required ShopAuthResult authResult,
}) async {
  final tokenStorage = TokenStorage();
  await tokenStorage.saveTokens(
    accessToken: authResult.tokens.accessToken,
    refreshToken: authResult.tokens.refreshToken,
  );
  await tokenStorage.saveUserId(authResult.shop.id);

  AppSession.instance.setAuthenticated(
    userId: authResult.shop.id,
    shopName: authResult.shop.name,
    email: authResult.shop.email,
    status: authResult.shop.status,
    isVerified: authResult.shop.verify,
  );
}
