import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../../core/config/api_config.dart';
import '../../../../core/storage/token_storage.dart';
import '../models/dashboard_models.dart';

class DashboardRemoteDataSource {
  DashboardRemoteDataSource({TokenStorage? tokenStorage, http.Client? client})
    : _tokenStorage = tokenStorage ?? TokenStorage(),
      _client = client ?? http.Client();

  final TokenStorage _tokenStorage;
  final http.Client _client;

  Future<DashboardMetricsModel> getDashboard() async {
    final response = await _sendAuthenticatedGet(path: '/shop/dashboard');
    return DashboardMetricsModel.fromJson(_metadataMap(response));
  }

  Future<Map<String, dynamic>> _sendAuthenticatedGet({
    required String path,
  }) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}$path');

    final accessToken = await _tokenStorage.getAccessToken();
    final userId = await _tokenStorage.getUserId();
    if (accessToken == null || accessToken.isEmpty) {
      throw DashboardException(401, 'Invalid request - missing access token');
    }
    if (userId == null || userId.isEmpty) {
      throw DashboardException(401, 'Invalid request - missing client ID');
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
      throw DashboardException(code, message, decoded['metadata']);
    }

    return decoded;
  }

  Map<String, dynamic> _decodeResponse(String body) {
    final decoded = jsonDecode(body);
    if (decoded is Map<String, dynamic>) {
      return decoded;
    }
    throw DashboardException(500, 'Invalid response format from server');
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
