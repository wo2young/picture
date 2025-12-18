// lib/pages/settings/settings_page.dart
import 'package:flutter/material.dart';
import 'package:family_app/pages/feedback/feedback_list_page.dart';
import 'package:family_app/pages/settings/font_size_sheet.dart';

/// ============================================================================
/// SettingsPage
/// ----------------------------------------------------------------------------
/// 설정 화면
/// - 아직 대부분은 UI만 존재 (기능은 단계적으로 추가)
/// - 부모님 테스트 후 필요한 기능만 선별해서 구현 예정
/// ============================================================================
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('설정'),
      ),
      body: ListView(
        children: [
          // ------------------------------------------------------------------
          // 테마 설정 (추후 다크 모드 / 색상 옵션)
          // ------------------------------------------------------------------
          _toggleTile(
            icon: Icons.palette,
            title: '테마 설정',
            subtitle: '다크 모드, 컬러 등',
            onTap: null, // 아직 미구현
          ),

          const Divider(height: 0),

          // ------------------------------------------------------------------
          // 앱 정보
          // ------------------------------------------------------------------
          _toggleTile(
            icon: Icons.info,
            title: '앱 정보',
            subtitle: '버전, 제작자 등',
            onTap: null, // 아직 미구현
          ),

          const Divider(height: 0),

          // ------------------------------------------------------------------
          // ⭐ 건의사항 / 버그 신고
          // ------------------------------------------------------------------
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
        ],
      ),
    );
  }

  // 공통 ListTile 위젯
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
      trailing: onTap != null
          ? const Icon(Icons.chevron_right)
          : null,
      onTap: onTap,
    );
  }
}
