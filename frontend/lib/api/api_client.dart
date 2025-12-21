// lib/api/api_client.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:family_app/config/app_routes.dart';
import 'package:family_app/config/navigation_service.dart';

class ApiClient {
  static const String baseUrl = 'http://10.0.2.2:8000';

  // ---------------------------
  // 공통 헤더
  // ---------------------------
  static Future<Map<String, String>> _headers() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');

    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // ---------------------------
  // 401 공통 처리
  // ---------------------------
  static Future<void> _handleUnauthorized() async {
    debugPrint('🚨 401 Unauthorized → 자동 로그아웃');

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');

    final navigator = NavigationService.navigatorKey.currentState;
    navigator?.pushNamedAndRemoveUntil(
      AppRoutes.login,
          (route) => false,
    );
  }

  // ---------------------------
  // GET
  // ---------------------------
  static Future<dynamic> get(String path) async {
    final uri = Uri.parse('$baseUrl$path');
    final response = await http.get(uri, headers: await _headers());

    if (response.statusCode == 401) {
      await _handleUnauthorized();
      throw Exception('Unauthorized');
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(utf8.decode(response.bodyBytes));
    } else {
      debugPrint('GET 실패 [$path] → ${response.statusCode}');
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
      headers: await _headers(),
      body: jsonEncode(body),
    );

    if (response.statusCode == 401 && !path.startsWith('/auth')) {
      await _handleUnauthorized();
      throw Exception('Unauthorized');
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(utf8.decode(response.bodyBytes));
    } else {
      debugPrint('POST 실패 [$path] → ${response.statusCode}');
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
      headers: await _headers(),
      body: jsonEncode(body),
    );

    if (response.statusCode == 401) {
      await _handleUnauthorized();
      throw Exception('Unauthorized');
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(utf8.decode(response.bodyBytes));
    } else {
      debugPrint('PUT 실패 [$path] → ${response.statusCode}');
      throw Exception('PUT 실패: ${response.statusCode}');
    }
  }

  // ---------------------------
  // DELETE
  // ---------------------------
  static Future<void> delete(String path) async {
    final uri = Uri.parse('$baseUrl$path');
    final response = await http.delete(
      uri,
      headers: await _headers(),
    );

    if (response.statusCode == 401) {
      await _handleUnauthorized();
      throw Exception('Unauthorized');
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      debugPrint('DELETE 실패 [$path] → ${response.statusCode}');
      throw Exception('DELETE 실패: ${response.statusCode}');
    }
  }
}
