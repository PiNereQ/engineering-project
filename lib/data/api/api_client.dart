import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiClient {
  final String baseUrl;
  final http.Client _client;

  ApiClient({required this.baseUrl, http.Client? client}) : _client = client ?? http.Client();

  Uri _uri(String path) {
    // Ensure path starts with '/'
    final p = path.startsWith('/') ? path : '/$path';
    return Uri.parse('$baseUrl$p');
  }

  Future<dynamic> getJson(String path) async {
    final resp = await _client.get(_uri(path));
    if (resp.statusCode >= 200 && resp.statusCode < 300) {
      return jsonDecode(resp.body);
    }
    throw Exception('GET $path failed: ${resp.statusCode} ${resp.reasonPhrase}');
  }

  Future<dynamic> getJsonById(String path, String id) async {
    final resp = await _client.get(_uri('$path/$id'));
    if (resp.statusCode >= 200 && resp.statusCode < 300) {
      return jsonDecode(resp.body);
    }
    throw Exception('GET $path/$id failed: ${resp.statusCode} ${resp.reasonPhrase}');
  }

  Future<dynamic> postJson(String path, Map<String, dynamic> body) async {
    print('POST $path with body: ${jsonEncode(body)}');
    final resp = await _client.post(
      _uri(path),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
    if (resp.statusCode >= 200 && resp.statusCode < 300) {
      return jsonDecode(resp.body);
    }
    print('POST $path failed: ${resp.statusCode} ${resp.reasonPhrase}');
    print('Response body: ${resp.body}');
    throw Exception('POST $path failed: ${resp.statusCode} ${resp.reasonPhrase}\nResponse: ${resp.body}');
  }

  Future<dynamic> putJson(String path, String id, Map<String, dynamic> body) async {
    final resp = await _client.put(
      _uri('$path/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
    if (resp.statusCode >= 200 && resp.statusCode < 300) {
      return jsonDecode(resp.body);
    }
    throw Exception('PUT $path/$id failed: ${resp.statusCode} ${resp.reasonPhrase}');
  }
}
