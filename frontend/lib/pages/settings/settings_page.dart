// lib/pages/settings/settings_page.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:family_app/pages/auth/auth_gate.dart'; // ✅ 추가
import 'package:family_app/pages/feedback/feedback_list_page.dart';
import 'package:family_app/pages/settings/font_size_sheet.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  // -----------------------------
  // 로그아웃 처리
  // -----------------------------
  Future<void> _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');

    if (!context.mounted) return;

    // ✅ AuthGate로 이동 (로그인 분기 재평가)
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const AuthGate()),
          (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('설정'),
      ),
      body: ListView(
        children: [
          _toggleTile(
            icon: Icons.palette,
            title: '테마 설정',
            subtitle: '다크 모드, 컬러 등',
            onTap: null,
          ),
          const Divider(height: 0),

          _toggleTile(
            icon: Icons.info,
            title: '앱 정보',
            subtitle: '버전, 제작자 등',
            onTap: null,
          ),
          const Divider(height: 0),

          _toggleTile(
            icon: Icons.support_agent,
            title: '건의사항 / 버그 신고',
            subtitle: '불편한 점을 알려주세요',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const FeedbackListPage(),
                ),
              );
            },
          ),

          const Divider(height: 0),

          ListTile(
            leading: const Icon(Icons.text_fields),
            title: const Text('글자 크기'),
            subtitle: const Text('작게 / 보통 / 크게'),
            onTap: () {
              showModalBottomSheet(
                context: context,
                builder: (_) => const FontSizeSheet(),
              );
            },
          ),

          const Divider(height: 24),

          // ==========================
          // 🔥 로그아웃
          // ==========================
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.redAccent),
            title: const Text(
              '로그아웃',
              style: TextStyle(
                color: Colors.redAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
            onTap: () => _logout(context),
          ),
        ],
      ),
    );
  }

  Widget _toggleTile({
    required IconData icon,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: onTap != null ? const Icon(Icons.chevron_right) : null,
      onTap: onTap,
    );
  }
}
