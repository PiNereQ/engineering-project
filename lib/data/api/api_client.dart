import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ApiClient {
  final String baseUrl;
  final http.Client _client;

  ApiClient({required this.baseUrl, http.Client? client}) : _client = client ?? http.Client();

  /// Constructs a [Uri] for the given [path] and optional [queryParameters].
  /// Ensures the path starts with '/'.
  /// Merges any existing query parameters in the path with those provided.
  Uri _uri(String path, {Map<String, String>? queryParameters}) {
    // Ensure path starts with '/'
    final p = path.startsWith('/') ? path : '/$path';
    final uri = Uri.parse('$baseUrl$p');
    if (queryParameters != null) {
      return uri.replace(queryParameters: {...uri.queryParameters, ...queryParameters});
    }
    return uri;
  }

  /// Sends a GET request to the given [path] with optional [queryParameters].
  /// Returns the decoded JSON response on success.
  /// Throws an [Exception] if the request fails.
  Future<dynamic> getJson(String path, {Map<String, String>? queryParameters}) async {
    final uri = _uri(path, queryParameters: queryParameters);
    
    final resp = await _client.get(uri);

    if (resp.statusCode >= 200 && resp.statusCode < 300) {
      return jsonDecode(resp.body);
    }
    throw Exception('GET $path failed: ${resp.statusCode} ${resp.reasonPhrase}');
  }

  /// Sends a POST request to the given [path] with optional [queryParameters] and JSON [body].
  /// Returns the decoded JSON response on success.
  /// Throws an [Exception] if the request fails.
  Future<dynamic> postJson(String path, {Map<String, String>? queryParameters, Map<String, dynamic>? body}) async {
    final uri = _uri(path, queryParameters: queryParameters);

    debugPrint('POST $path with body: ${jsonEncode(body)}');
    final resp = await _client.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
    if (resp.statusCode >= 200 && resp.statusCode < 300) {
      return jsonDecode(resp.body);
    }
    debugPrint('POST $path failed: ${resp.statusCode} ${resp.reasonPhrase}');
    debugPrint('Response body: ${resp.body}');
    throw Exception('POST $path failed: ${resp.statusCode} ${resp.reasonPhrase}\nResponse: ${resp.body}');
  }

  /// Sends a PUT request to the given [path] with optional [queryParameters] and JSON [body].
  /// Returns the decoded JSON response on success.
  /// Throws an [Exception] if the request fails.
  Future<dynamic> putJson(String path, {Map<String, String>? queryParameters, Map<String, dynamic>? body}) async {
    final uri = _uri(path, queryParameters: queryParameters);

    final resp = await _client.put(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
    if (resp.statusCode >= 200 && resp.statusCode < 300) {
      return jsonDecode(resp.body);
    }
    throw Exception('PUT $path failed: ${resp.statusCode} ${resp.reasonPhrase}');
  }

  /// Sends a PATCH request to the given [path] with optional [queryParameters] and JSON [body].
  /// Returns the decoded JSON response on success.
  /// Throws an [Exception] if the request fails.
  Future<dynamic> patchJson(String path, {Map<String, String>? queryParameters, Map<String, dynamic>? body}) async {
    final uri = _uri(path, queryParameters: queryParameters);

    final resp = await _client.patch(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
    if (resp.statusCode >= 200 && resp.statusCode < 300) {
      return jsonDecode(resp.body);
    }
    throw Exception('PUT $path failed: ${resp.statusCode} ${resp.reasonPhrase}');
  }

  /// Sends a DELETE request to the given [path] with optional [queryParameters].
  /// Returns the decoded JSON response on success.
  /// Throws an [Exception] if the request fails.
  Future<dynamic> deleteJson(String path, {Map<String, String>? queryParameters}) async {
    final uri = _uri(path, queryParameters: queryParameters);
    final resp = await _client.delete(uri);
    if (resp.statusCode >= 200 && resp.statusCode < 300) {
      return jsonDecode(resp.body);
    }
    throw Exception('DELETE $path failed: ${resp.statusCode} ${resp.reasonPhrase}');

  }
}
