import 'package:family_app/api/api_client.dart';

class AuthService {
  // 로그인
  static Future<String> login(String phone) async {
    final res = await ApiClient.post(
      '/auth/login',
      {
        'phone': phone,
      },
    );

    return res['access_token'];
  }

  // 회원가입
  static Future<String> register(String name, String phone) async {
    final res = await ApiClient.post(
      '/auth/register',
      {
        'name': name,
        'phone': phone,
      },
    );

    return res['access_token'];
  }
}
