// lib/pages/auth/login_page.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:family_app/api/api_client.dart';
import 'package:family_app/pages/auth/auth_gate.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _phoneController = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  // ----------------------------
  // 로그인 처리
  // ----------------------------
  Future<void> _login() async {
    final phone = _phoneController.text.trim();

    if (phone.isEmpty) {
      setState(() {
        _error = '전화번호를 입력해주세요.';
      });
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final response = await ApiClient.post(
        '/auth/login',
        {'phone': phone},
      );

      final token = response['access_token'] as String?;

      if (token == null || token.isEmpty) {
        throw Exception('토큰 없음');
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('access_token', token);

      if (!mounted) return;

      // ⭐ AuthGate로 이동 (앱 상태 초기화)
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const AuthGate()),
            (_) => false,
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = '로그인에 실패했습니다.';
      });
    } finally {
      if (!mounted) return;
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('로그인'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 32),

            Text(
              '전화번호로 로그인',
              style: theme.textTheme.titleLarge,
            ),

            const SizedBox(height: 16),

            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: '전화번호',
                hintText: '01012345678',
                border: OutlineInputBorder(),
              ),
            ),

            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(
                _error!,
                style: const TextStyle(color: Colors.red),
              ),
            ],

            const SizedBox(height: 24),

            ElevatedButton(
              onPressed: _loading ? null : _login,
              child: _loading
                  ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
                  : const Text('로그인'),
            ),
          ],
        ),
      ),
    );
  }
}
