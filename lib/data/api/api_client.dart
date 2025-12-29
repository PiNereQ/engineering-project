import 'dart:convert';
import 'package:flutter/foundation.dart';

import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

class ApiClient {
  final String baseUrl;
  final http.Client _client;

  ApiClient({required this.baseUrl, http.Client? client}) : _client = client ?? http.Client();

  /// Constructs a [Uri] for the given [path] and optional [queryParameters].
  /// Ensures the path starts with '/'.
  /// Merges any existing query parameters in the path with those provided.
  /// Automatically includes user_id if [useAuthToken] is true and Firebase user exists.
  Uri _uri(String path, {Map<String, String>? queryParameters, bool useAuthToken = false}) {
    // Ensure path starts with '/'
    final p = path.startsWith('/') ? path : '/$path';
    final uri = Uri.parse('$baseUrl$p');
    
    // Build merged query parameters
    final mergedParams = {...uri.queryParameters, ...?queryParameters};
    
    // Add user_id if useAuthToken is true and Firebase user exists
    if (useAuthToken) {
      final firebaseUser = FirebaseAuth.instance.currentUser;
      if (firebaseUser?.uid != null) {
        mergedParams['user_id'] = firebaseUser!.uid;
      }
    }
    debugPrint('Final URL params: $mergedParams');
    return uri.replace(queryParameters: mergedParams.isNotEmpty ? mergedParams : null);
  }

  /// Sends a GET request to the given [path] with optional [queryParameters].
  /// Returns the decoded JSON response on success.
  /// Throws an [Exception] if the request fails.
  Future<dynamic> get(String path, {Map<String, String>? queryParameters, bool useAuthToken = false}) async {
    final uri = _uri(path, queryParameters: queryParameters, useAuthToken: useAuthToken);

    Map<String, String> headers = {};
    if (useAuthToken) {
      final user = FirebaseAuth.instance.currentUser;
      final token = await user?.getIdToken();
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }
    final resp = await _client.get(uri, headers: headers);

    if (resp.statusCode >= 200 && resp.statusCode < 300) {
      return jsonDecode(resp.body);
    }
    if (resp.statusCode == 400) {
      try {
        final body = jsonDecode(resp.body);
        if (body is Map && body.containsKey('message')) {
          throw Exception(body['message']);
        }
      } catch (_) {}
    }
    throw Exception('GET $path failed: ${resp.statusCode} ${resp.reasonPhrase}');
  }

  /// Sends a POST request to the given [path] with optional [queryParameters] and JSON [body].
  /// Returns the decoded JSON response on success.
  /// Throws an [Exception] if the request fails.
  Future<dynamic> post(String path, {Map<String, String>? queryParameters, Map<String, dynamic>? body, bool useAuthToken = false}) async {
    final uri = _uri(path, queryParameters: queryParameters, useAuthToken: useAuthToken);

    Map<String, String> headers = {};
    if (body != null && body.isNotEmpty) headers['Content-Type'] = 'application/json';
    if (useAuthToken) {
      final user = FirebaseAuth.instance.currentUser;
      final token = await user?.getIdToken();
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }
    
    final resp = await _client.post(
      uri,
      headers: headers,
      body: jsonEncode(body),
    );

    if (resp.statusCode >= 200 && resp.statusCode < 300) {
      return jsonDecode(resp.body);
    }
    if (resp.statusCode == 400) {
      try {
        final body = jsonDecode(resp.body);
        if (body is Map && body.containsKey('message')) {
          throw Exception(body['message']);
        }
      } catch (_) {}
    }
    debugPrint('POST $path failed: ${resp.statusCode} ${resp.reasonPhrase}');
    debugPrint('Response body: ${resp.body}');
    throw Exception('POST $path failed: ${resp.statusCode} ${resp.reasonPhrase}\nResponse: ${resp.body}');
  }

  /// Sends a PUT request to the given [path] with optional [queryParameters] and JSON [body].
  /// Returns the decoded JSON response on success.
  /// Throws an [Exception] if the request fails.
  Future<dynamic> put(String path, {Map<String, String>? queryParameters, Map<String, dynamic>? body, bool useAuthToken = false}) async {
    final uri = _uri(path, queryParameters: queryParameters, useAuthToken: useAuthToken);

    Map<String, String> headers = {};
    if (body != null && body.isNotEmpty) headers['Content-Type'] = 'application/json';
    
    if (useAuthToken) {
      final user = FirebaseAuth.instance.currentUser;
      final token = await user?.getIdToken();
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }
    
    final resp = await _client.put(
      uri,
      headers: headers,
      body: jsonEncode(body),
    );
    if (resp.statusCode >= 200 && resp.statusCode < 300) {
      return jsonDecode(resp.body);
    }
    if (resp.statusCode == 400) {
      try {
        final body = jsonDecode(resp.body);
        if (body is Map && body.containsKey('message')) {
          throw Exception(body['message']);
        }
      } catch (_) {}
    }
    throw Exception('PUT $path failed: ${resp.statusCode} ${resp.reasonPhrase}');
  }

  /// Sends a PATCH request to the given [path] with optional [queryParameters] and JSON [body].
  /// Returns the decoded JSON response on success.
  /// Throws an [Exception] if the request fails.
  Future<dynamic> patch(String path, {Map<String, String>? queryParameters, Map<String, dynamic>? body, bool useAuthToken = false}) async {
    final uri = _uri(path, queryParameters: queryParameters, useAuthToken: useAuthToken);

    Map<String, String> headers = {};
    if (body != null && body.isNotEmpty) headers['Content-Type'] = 'application/json';
    if (useAuthToken) {
      final user = FirebaseAuth.instance.currentUser;
      final token = await user?.getIdToken();
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }
    
    final resp = await _client.patch(
      uri,
      headers: headers,
      body: jsonEncode(body),
    );

    if (resp.statusCode >= 200 && resp.statusCode < 300) {
      return jsonDecode(resp.body);
    }
    if (resp.statusCode == 400) {
      try {
        final body = jsonDecode(resp.body);
        if (body is Map && body.containsKey('message')) {
          throw Exception(body['message']);
        }
      } catch (_) {}
    }
    throw Exception('PATCH $path failed: ${resp.statusCode} ${resp.reasonPhrase}');
  }

  /// Sends a DELETE request to the given [path] with optional [queryParameters].
  /// Returns the decoded JSON response on success.
  /// Throws an [Exception] if the request fails.
  Future<dynamic> delete(String path, {Map<String, String>? queryParameters, bool useAuthToken = false}) async {
    final uri = _uri(path, queryParameters: queryParameters, useAuthToken: useAuthToken);
    Map<String, String> headers = {};
    if (useAuthToken) {
      final user = FirebaseAuth.instance.currentUser;
      final token = await user?.getIdToken();
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }
    
    final resp = await _client.delete(
      uri,
      headers: headers,
    );
    
    if (resp.statusCode >= 200 && resp.statusCode < 300) {
      return jsonDecode(resp.body);
    }
    if (resp.statusCode == 400) {
      try {
        final body = jsonDecode(resp.body);
        if (body is Map && body.containsKey('message')) {
          throw Exception(body['message']);
        }
      } catch (_) {}
    }
    throw Exception('DELETE $path failed: ${resp.statusCode} ${resp.reasonPhrase}');

  }
}
