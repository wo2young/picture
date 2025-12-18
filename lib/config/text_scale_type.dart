// lib/config/text_scale_type.dart

enum TextScaleType {
  small,
  normal,
  large,
  xlarge,
}

extension TextScaleTypeX on TextScaleType {
  double get scale {
    switch (this) {
      case TextScaleType.small:
        return 0.9;
      case TextScaleType.normal:
        return 1.0;
      case TextScaleType.large:
        return 1.15;
      case TextScaleType.xlarge:
        return 1.3;
    }
  }

  String get label {
    switch (this) {
      case TextScaleType.small:
        return '작게';
      case TextScaleType.normal:
        return '보통';
      case TextScaleType.large:
        return '크게';
      case TextScaleType.xlarge:
        return '아주 크게';
    }
  }
}
