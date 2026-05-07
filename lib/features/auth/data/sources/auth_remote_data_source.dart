import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../../core/config/api_config.dart';
import '../../../../core/storage/token_storage.dart';
import '../models/auth_models.dart';

class AuthRemoteDataSource {
  AuthRemoteDataSource({TokenStorage? tokenStorage, http.Client? client})
    : _tokenStorage = tokenStorage ?? TokenStorage(),
      _client = client ?? http.Client();

  final TokenStorage _tokenStorage;
  final http.Client _client;

  Future<AuthResultModel> signIn({
    required String email,
    required String password,
  }) async {
    final response = await _sendJson(
      method: 'POST',
      path: '/shop/signin',
      body: {'email': email, 'password': password},
    );
    return AuthResultModel.fromJson(_metadataMap(response));
  }

  Future<AuthResultModel> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    final response = await _sendJson(
      method: 'POST',
      path: '/shop/signup',
      body: {'name': name, 'email': email, 'password': password},
    );
    return AuthResultModel.fromJson(_metadataMap(response));
  }

  Future<AuthResultModel> refreshTokens() async {
    final response = await _sendJson(
      method: 'POST',
      path: '/handlerRefreshToken',
      authRequired: true,
      includeRefreshToken: true,
    );
    return AuthResultModel.fromJson(_metadataMap(response));
  }

  Future<AuthStatusModel> getShopStatus() async {
    final response = await _sendJson(
      method: 'GET',
      path: '/shop/status',
      authRequired: true,
    );
    return AuthStatusModel.fromJson(_metadataMap(response));
  }

  Future<Map<String, dynamic>> _sendJson({
    required String method,
    required String path,
    Map<String, dynamic>? body,
    bool authRequired = false,
    bool includeRefreshToken = false,
  }) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}$path');

    final headers = <String, String>{'Content-Type': 'application/json'};
    if (authRequired) {
      final accessToken = await _tokenStorage.getAccessToken();
      final userId = await _tokenStorage.getUserId();
      if (accessToken == null || accessToken.isEmpty) {
        throw AuthException(401, 'Invalid request - missing access token');
      }
      if (userId == null || userId.isEmpty) {
        throw AuthException(401, 'Invalid request - missing client ID');
      }
      headers['authorization'] = accessToken;
      headers['x-client-id'] = userId;
      if (includeRefreshToken) {
        final refreshToken = await _tokenStorage.getRefreshToken();
        if (refreshToken == null || refreshToken.isEmpty) {
          throw AuthException(401, 'Invalid request - missing refresh token');
        }
        headers['x-rtoken-id'] = refreshToken;
      }
    }

    final response = switch (method) {
      'GET' => await _client.get(uri, headers: headers),
      'POST' => await _client.post(
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
      throw AuthException(code, message, decoded['metadata']);
    }

    return decoded;
  }

  Map<String, dynamic> _decodeResponse(String body) {
    final decoded = jsonDecode(body);
    if (decoded is Map<String, dynamic>) {
      return decoded;
    }
    throw AuthException(500, 'Invalid response format from server');
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
