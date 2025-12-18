import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:family_app/view_models/app_settings_view_model.dart';

/// ============================================================================
/// FontSizeSheet
/// ----------------------------------------------------------------------------
/// 설정 > 글자 크기 선택용 BottomSheet
/// - 작게 / 보통 / 크게
/// ============================================================================
class FontSizeSheet extends StatelessWidget {
  const FontSizeSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<AppSettingsViewModel>();

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '글자 크기',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),

            _option(
              context,
              label: '작게',
              scale: 0.9,
              current: settings.fontScale,
            ),
            _option(
              context,
              label: '보통',
              scale: 1.0,
              current: settings.fontScale,
            ),
            _option(
              context,
              label: '크게',
              scale: 1.15,
              current: settings.fontScale,
            ),
          ],
        ),
      ),
    );
  }

  Widget _option(
      BuildContext context, {
        required String label,
        required double scale,
        required double current,
      }) {
    final isSelected = scale == current;

    return ListTile(
      title: Text(label),
      trailing: isSelected
          ? const Icon(Icons.check_circle)
          : const Icon(Icons.circle_outlined),
      onTap: () {
        context.read<AppSettingsViewModel>().setFontScale(scale);
        Navigator.pop(context);
      },
    );
  }
}
