// lib/config/app_settings.dart
import 'package:flutter/foundation.dart';
import 'text_scale_type.dart';

class AppSettings extends ChangeNotifier {
  TextScaleType _textScale = TextScaleType.normal;

  TextScaleType get textScale => _textScale;
  double get textScaleFactor => _textScale.scale;

  void setTextScale(TextScaleType scale) {
    _textScale = scale;
    notifyListeners();
  }
}
