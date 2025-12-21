// lib/main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'config/app_routes.dart';
import 'config/navigation_service.dart';
import 'package:family_app/view_models/app_settings_view_model.dart';
import 'package:family_app/pages/auth/auth_gate.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => AppSettingsViewModel(),
      child: const FamilyApp(),
    ),
  );
}

/// ============================================================================
/// FamilyApp
/// ----------------------------------------------------------------------------
/// - 앱 전체 루트
/// - 테마
/// - 라우팅
/// - 로그인 분기는 AuthGate에서 담당
/// ============================================================================
class FamilyApp extends StatelessWidget {
  const FamilyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<AppSettingsViewModel>();

    return MaterialApp(
      navigatorKey: NavigationService.navigatorKey,
      // 🔥 필수
      title: '가족 사진관',
      debugShowCheckedModeBanner: false,
      theme: _warmCreamTheme(settings.fontScale),
      home: const AuthGate(),
      onGenerateRoute: AppRoutes.generateRoute,
    );
  }
  // ==========================================================================
  // ⭐ 따뜻한 크림톤 + 브라운 포인트 테마
  // ==========================================================================
  ThemeData _warmCreamTheme(double fontScale) {
    const creamLight = Color(0xFFF9F6F1);
    const warmBrown = Color(0xFF8B6F47);
    const beigeGold = Color(0xFFC4A484);
    const darkText = Color(0xFF2F2A26);

    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: creamLight,
      fontFamily: 'Pretendard',

      colorScheme: const ColorScheme.light(
        primary: warmBrown,
        secondary: beigeGold,
        surface: Colors.white,
        onPrimary: Colors.white,
        onSurface: darkText,
      ),

      appBarTheme: const AppBarTheme(
        backgroundColor: creamLight,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: warmBrown,
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: IconThemeData(color: warmBrown),
      ),

      cardTheme: CardTheme(
        color: Colors.white,
        elevation: 0,
        shadowColor: warmBrown.withOpacity(0.12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
      ),

      textTheme: TextTheme(
        titleLarge: TextStyle(
          color: warmBrown,
          fontSize: 24 * fontScale,
          fontWeight: FontWeight.bold,
        ),
        titleMedium: TextStyle(
          color: darkText,
          fontSize: 18 * fontScale,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: TextStyle(
          color: darkText,
          fontSize: 16 * fontScale,
        ),
        bodyMedium: TextStyle(
          color: darkText,
          fontSize: 15 * fontScale,
        ),
        bodySmall: TextStyle(
          color: darkText,
          fontSize: 13 * fontScale,
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: warmBrown,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(48),
          foregroundColor: warmBrown,
          side: const BorderSide(color: warmBrown, width: 1.2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),

      iconTheme: const IconThemeData(color: warmBrown),
    );
  }
}
