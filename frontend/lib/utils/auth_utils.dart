import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:family_app/config/app_routes.dart';

Future<void> logout(BuildContext context) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove('access_token');

  if (!context.mounted) return;

  Navigator.pushNamedAndRemoveUntil(
    context,
    AppRoutes.login,
        (route) => false, // 뒤로가기 완전 차단
  );
}
