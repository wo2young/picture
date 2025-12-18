import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// ============================================================================
/// AppSettingsViewModel
/// - 글자 크기 설정 저장/로드 담당
/// ============================================================================
class AppSettingsViewModel extends ChangeNotifier {
  static const _fontScaleKey = 'font_scale';

  double _fontScale = 1.0;
  double get fontScale => _fontScale;

  AppSettingsViewModel() {
    _loadFontScale(); // 앱 시작 시 저장값 불러오기
  }

  /// 글자 크기 변경 + 저장
  Future<void> setFontScale(double scale) async {
    if (_fontScale == scale) return;

    _fontScale = scale;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_fontScaleKey, scale);
  }

  /// 저장된 글자 크기 불러오기
  Future<void> _loadFontScale() async {
    final prefs = await SharedPreferences.getInstance();
    _fontScale = prefs.getDouble(_fontScaleKey) ?? 1.0;
    notifyListeners();
  }
}
