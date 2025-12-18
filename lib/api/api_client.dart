import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiClient {
  // ★ 여기만 나중에 바꾼다
  static const String baseUrl = 'http://10.0.2.2:8000';

  // ---------------------------
  // GET
  // ---------------------------
  static Future<dynamic> get(String path) async {
    final uri = Uri.parse('$baseUrl$path');

    final response = await http.get(uri);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(utf8.decode(response.bodyBytes));
    } else {
      throw Exception('GET 실패: ${response.statusCode}');
    }
  }

  // ---------------------------
  // POST
  // ---------------------------
  static Future<dynamic> post(String path, Map<String, dynamic> body) async {
    final uri = Uri.parse('$baseUrl$path');

    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(utf8.decode(response.bodyBytes));
    } else {
      throw Exception('POST 실패: ${response.statusCode}');
    }
  }

  // ---------------------------
  // PUT
  // ---------------------------
  static Future<dynamic> put(String path, Map<String, dynamic> body) async {
    final uri = Uri.parse('$baseUrl$path');

    final response = await http.put(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(utf8.decode(response.bodyBytes));
    } else {
      throw Exception('PUT 실패: ${response.statusCode}');
    }
  }

  // ---------------------------
  // DELETE
  // ---------------------------
  static Future<void> delete(String path) async {
    final uri = Uri.parse('$baseUrl$path');

    final response = await http.delete(uri);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('DELETE 실패: ${response.statusCode}');
    }
  }
}
