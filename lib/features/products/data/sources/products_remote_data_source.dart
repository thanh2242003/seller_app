import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

import '../../../../core/config/api_config.dart';
import '../../../../core/storage/token_storage.dart';
import '../models/product_models.dart';

class ProductsRemoteDataSource {
  ProductsRemoteDataSource({TokenStorage? tokenStorage, http.Client? client})
    : _tokenStorage = tokenStorage ?? TokenStorage(),
      _client = client ?? http.Client();

  final TokenStorage _tokenStorage;
  final http.Client _client;

  // ============ Get Products Lists ============

  Future<ProductsListResultModel> getDraftProducts({
    int page = 1,
    int limit = 10,
  }) async {
    final response = await _sendAuthenticatedGet(
      path: '/product/shop/drafts',
      queryParameters: {'page': page.toString(), 'limit': limit.toString()},
    );
    return ProductsListResultModel.fromJson(response);
  }

  Future<ProductsListResultModel> getPublishedProducts({
    int page = 1,
    int limit = 10,
  }) async {
    final response = await _sendAuthenticatedGet(
      path: '/product/shop/published',
      queryParameters: {'page': page.toString(), 'limit': limit.toString()},
    );
    return ProductsListResultModel.fromJson(response);
  }

  Future<ProductsListResultModel> getDeletedProducts({
    int page = 1,
    int limit = 10,
  }) async {
    final response = await _sendAuthenticatedGet(
      path: '/product/shop/deleted',
      queryParameters: {'page': page.toString(), 'limit': limit.toString()},
    );
    return ProductsListResultModel.fromJson(response);
  }

  // ============ Create Product ============

  Future<ProductDetailModel> createProduct({
    required CreateProductRequest request,
  }) async {
    final response = await _sendMultipart(
      method: 'POST',
      path: '/product',
      fields: request.toFormFields(),
      imagePaths: request.imagePaths,
      authRequired: true,
    );
    return ProductDetailModel.fromJson(_metadataMap(response));
  }

  // ============ Get Product Detail ============

  Future<ProductDetailModel> getProductDetail(String productId) async {
    final response = await _sendAuthenticatedGet(path: '/product/$productId');
    return ProductDetailModel.fromJson(_metadataMap(response));
  }

  // ============ Update Product ============

  Future<ProductDetailModel> updateProduct({
    required String productId,
    required Map<String, dynamic> updates,
  }) async {
    final payload = _toMultipartPayload(updates);
    final response = await _sendMultipart(
      method: 'PATCH',
      path: '/product/$productId',
      fields: payload.fields,
      imagePaths: payload.imagePaths,
      authRequired: true,
    );
    return ProductDetailModel.fromJson(_metadataMap(response));
  }

  // ============ Publish / Unpublish ============

  Future<ProductDetailModel> publishProduct(String productId) async {
    final response = await _sendJson(
      method: 'PATCH',
      path: '/product/$productId/publish',
      authRequired: true,
    );
    return ProductDetailModel.fromJson(_metadataMap(response));
  }

  Future<ProductDetailModel> unpublishProduct(String productId) async {
    final response = await _sendJson(
      method: 'PATCH',
      path: '/product/$productId/unpublish',
      authRequired: true,
    );
    return ProductDetailModel.fromJson(_metadataMap(response));
  }

  // ============ Soft Delete / Restore ============

  Future<ProductDetailModel> softDeleteProduct(String productId) async {
    final response = await _sendJson(
      method: 'PATCH',
      path: '/product/$productId/soft-delete',
      authRequired: true,
    );
    return ProductDetailModel.fromJson(_metadataMap(response));
  }

  Future<ProductDetailModel> restoreProduct(String productId) async {
    final response = await _sendJson(
      method: 'PATCH',
      path: '/product/$productId/restore',
      authRequired: true,
    );
    return ProductDetailModel.fromJson(_metadataMap(response));
  }

  // ============ Delete Product ============

  Future<void> deleteProduct(String productId) async {
    await _sendJson(
      method: 'DELETE',
      path: '/product/$productId',
      authRequired: true,
    );
  }

  Future<void> permanentlyDeleteProduct(String productId) async {
    await _sendJson(
      method: 'DELETE',
      path: '/product/$productId/permanent',
      authRequired: true,
    );
  }

  // ============ Get Categories ============

  Future<List<CategoryModel>> getCategories() async {
    final response = await _sendJson(
      method: 'GET',
      path: '/category/',
      authRequired: false,
    );
    final categoriesData = response['metadata'] ?? response;
    if (categoriesData is List) {
      return categoriesData
          .map(
            (item) =>
                CategoryModel.fromJson(Map<String, dynamic>.from(item as Map)),
          )
          .toList();
    }
    return [];
  }

  // ============ HTTP Helpers ============

  Future<Map<String, dynamic>> _sendAuthenticatedGet({
    required String path,
    Map<String, String>? queryParameters,
  }) async {
    final uri = Uri.parse(
      '${ApiConfig.baseUrl}$path',
    ).replace(queryParameters: queryParameters);

    final accessToken = await _tokenStorage.getAccessToken();
    final userId = await _tokenStorage.getUserId();
    if (accessToken == null || accessToken.isEmpty) {
      throw ProductException(401, 'Invalid request - missing access token');
    }
    if (userId == null || userId.isEmpty) {
      throw ProductException(401, 'Invalid request - missing client ID');
    }

    final response = await _client.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'authorization': accessToken,
        'x-client-id': userId,
      },
    );

    final decoded = _decodeResponse(response.body);
    final code = decoded['code'] is int
        ? decoded['code'] as int
        : response.statusCode;
    final message = decoded['message']?.toString() ?? 'Request failed';

    if (response.statusCode < 200 ||
        response.statusCode >= 300 ||
        code >= 400) {
      throw ProductException(code, message, decoded['metadata']);
    }

    return decoded;
  }

  Future<Map<String, dynamic>> _sendJson({
    required String method,
    required String path,
    Map<String, dynamic>? body,
    bool authRequired = false,
  }) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}$path');

    final headers = <String, String>{'Content-Type': 'application/json'};
    if (authRequired) {
      final accessToken = await _tokenStorage.getAccessToken();
      final userId = await _tokenStorage.getUserId();
      if (accessToken == null || accessToken.isEmpty) {
        throw ProductException(401, 'Invalid request - missing access token');
      }
      if (userId == null || userId.isEmpty) {
        throw ProductException(401, 'Invalid request - missing client ID');
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
      'DELETE' => await _client.delete(uri, headers: headers),
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
      throw ProductException(code, message, decoded['metadata']);
    }

    return decoded;
  }

  Future<Map<String, dynamic>> _sendMultipart({
    required String method,
    required String path,
    Map<String, String>? fields,
    List<String>? imagePaths,
    bool authRequired = false,
  }) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}$path');
    final request = http.MultipartRequest(method, uri);

    if (fields != null) {
      request.fields.addAll(fields);
    }

    if (imagePaths != null) {
      for (final imagePath in imagePaths) {
        if (imagePath.trim().isEmpty) {
          continue;
        }
        request.files.add(
          await http.MultipartFile.fromPath(
            'images',
            imagePath,
            contentType: _mediaTypeForPath(imagePath),
          ),
        );
      }
    }

    if (authRequired) {
      request.headers.addAll(await _authHeaders());
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    final decoded = _decodeResponse(response.body);
    final code = decoded['code'] is int
        ? decoded['code'] as int
        : response.statusCode;
    final message = decoded['message']?.toString() ?? 'Request failed';

    if (response.statusCode < 200 ||
        response.statusCode >= 300 ||
        code >= 400) {
      throw ProductException(code, message, decoded['metadata']);
    }

    return decoded;
  }

  Future<Map<String, String>> _authHeaders() async {
    final accessToken = await _tokenStorage.getAccessToken();
    final userId = await _tokenStorage.getUserId();
    if (accessToken == null || accessToken.isEmpty) {
      throw ProductException(401, 'Invalid request - missing access token');
    }
    if (userId == null || userId.isEmpty) {
      throw ProductException(401, 'Invalid request - missing client ID');
    }

    return {'authorization': accessToken, 'x-client-id': userId};
  }

  _MultipartPayload _toMultipartPayload(Map<String, dynamic> updates) {
    final fields = <String, String>{};
    final imagePaths = <String>[];

    updates.forEach((key, value) {
      if (value == null) {
        return;
      }

      if (key == 'images') {
        if (value is Iterable) {
          imagePaths.addAll(value.map((item) => item.toString()));
        } else {
          imagePaths.add(value.toString());
        }
        return;
      }

      if (value is String) {
        fields[key] = value;
      } else if (value is num || value is bool) {
        fields[key] = value.toString();
      } else {
        fields[key] = jsonEncode(value);
      }
    });

    return _MultipartPayload(fields: fields, imagePaths: imagePaths);
  }

  MediaType? _mediaTypeForPath(String path) {
    final lowerPath = path.toLowerCase();
    if (lowerPath.endsWith('.jpg') || lowerPath.endsWith('.jpeg')) {
      return MediaType('image', 'jpeg');
    }
    if (lowerPath.endsWith('.png')) {
      return MediaType('image', 'png');
    }
    if (lowerPath.endsWith('.gif')) {
      return MediaType('image', 'gif');
    }
    if (lowerPath.endsWith('.webp')) {
      return MediaType('image', 'webp');
    }
    return null;
  }

  Map<String, dynamic> _decodeResponse(String body) {
    final decoded = jsonDecode(body);
    if (decoded is Map<String, dynamic>) {
      return decoded;
    }
    throw ProductException(500, 'Invalid response format from server');
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

class _MultipartPayload {
  _MultipartPayload({required this.fields, required this.imagePaths});

  final Map<String, String> fields;
  final List<String> imagePaths;
}
