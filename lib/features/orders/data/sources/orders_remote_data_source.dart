import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../../core/config/api_config.dart';
import '../../../../core/storage/token_storage.dart';
import '../models/orders_models.dart';

class OrdersRemoteDataSource {
  OrdersRemoteDataSource({TokenStorage? tokenStorage, http.Client? client})
    : _tokenStorage = tokenStorage ?? TokenStorage(),
      _client = client ?? http.Client();

  final TokenStorage _tokenStorage;
  final http.Client _client;

  Future<OrdersResultModel> getOrders({
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
      queryParameters: queryParameters,
    );

    return OrdersResultModel.fromJson(_metadataMap(response));
  }

  Future<OrderDetailModel> getOrderDetail(String id) async {
    final response = await _sendJson(method: 'GET', path: '/shop/orders/$id');
    return OrderDetailModel.fromJson(_metadataMap(response));
  }

  Future<OrderDetailModel> updateOrderStatus({
    required String orderId,
    required String status,
  }) async {
    final response = await _sendJson(
      method: 'PATCH',
      path: '/shop/orders/$orderId/status',
      body: {'status': status},
    );

    final metadata = _metadataMap(response);
    if (metadata.isEmpty) {
      return getOrderDetail(orderId);
    }

    return OrderDetailModel.fromJson(metadata);
  }

  Future<Map<String, dynamic>> _sendJson({
    required String method,
    required String path,
    Map<String, dynamic>? body,
    Map<String, String>? queryParameters,
  }) async {
    final uri = Uri.parse(
      '${ApiConfig.baseUrl}$path',
    ).replace(queryParameters: queryParameters);

    final accessToken = await _tokenStorage.getAccessToken();
    final userId = await _tokenStorage.getUserId();
    if (accessToken == null || accessToken.isEmpty) {
      throw OrdersException(401, 'Invalid request - missing access token');
    }
    if (userId == null || userId.isEmpty) {
      throw OrdersException(401, 'Invalid request - missing client ID');
    }

    final headers = <String, String>{
      'Content-Type': 'application/json',
      'authorization': accessToken,
      'x-client-id': userId,
    };

    final response = switch (method) {
      'GET' => await _client.get(uri, headers: headers),
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
      throw OrdersException(code, message, decoded['metadata']);
    }

    return decoded;
  }

  Map<String, dynamic> _decodeResponse(String body) {
    final decoded = jsonDecode(body);
    if (decoded is Map<String, dynamic>) {
      return decoded;
    }
    throw OrdersException(500, 'Invalid response format from server');
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
