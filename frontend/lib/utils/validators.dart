// lib/utils/validators.dart

// 공통 검증 함수 모음
class Validators {
  static String? required(String? value, {String fieldName = '값'}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName을 입력해 주세요.';
    }
    return null;
  }

  static String? maxLength(String? value, int max, {String fieldName = '값'}) {
    if (value != null && value.trim().length > max) {
      return '$fieldName은(는) 최대 $max자까지 가능합니다.';
    }
    return null;
  }
}
