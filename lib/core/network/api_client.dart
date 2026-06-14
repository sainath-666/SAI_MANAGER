import 'dart:convert';

import 'package:http/http.dart' as http;

class ApiException implements Exception {
  final String message;

  const ApiException(this.message);

  @override
  String toString() => message;
}

class ApiClient {
  static const String baseUrl = String.fromEnvironment(
    'SAI_MANAGER_API_URL',
    defaultValue: 'https://sai-manager-api.onrender.com/api',
  );
  static const String authToken = String.fromEnvironment(
    'SAI_MANAGER_AUTH_TOKEN',
  );

  static bool get isConfigured => authToken.isNotEmpty;

  final http.Client _httpClient;

  ApiClient({http.Client? httpClient}) : _httpClient = httpClient ?? http.Client();

  Future<Map<String, dynamic>> get(String path) {
    return _send('GET', path);
  }

  Future<Map<String, dynamic>> post(String path, Map<String, dynamic> body) {
    return _send('POST', path, body: body);
  }

  Future<Map<String, dynamic>> patch(String path, Map<String, dynamic> body) {
    return _send('PATCH', path, body: body);
  }

  Future<void> delete(String path) async {
    await _send('DELETE', path);
  }

  Future<Map<String, dynamic>> _send(
    String method,
    String path, {
    Map<String, dynamic>? body,
  }) async {
    final uri = Uri.parse('$baseUrl$path');
    final headers = {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      if (authToken.isNotEmpty) 'Authorization': 'Bearer $authToken',
    };

    final response = switch (method) {
      'GET' => await _httpClient.get(uri, headers: headers),
      'POST' => await _httpClient.post(uri, headers: headers, body: jsonEncode(body)),
      'PATCH' => await _httpClient.patch(uri, headers: headers, body: jsonEncode(body)),
      'DELETE' => await _httpClient.delete(uri, headers: headers),
      _ => throw ApiException('Unsupported method $method'),
    };

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode < 200 || response.statusCode >= 300) {
      final error = decoded['error'] as Map<String, dynamic>?;
      throw ApiException(error?['message'] as String? ?? 'API request failed');
    }

    return decoded['data'] as Map<String, dynamic>;
  }
}
