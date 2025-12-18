// lib/main.dart
import 'package:flutter/material.dart';
import 'config/app_routes.dart';
import 'package:provider/provider.dart';
import 'package:family_app/view_models/app_settings_view_model.dart';

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
/// 앱 전체를 감싸는 최상위 위젯
/// - 테마
/// - 라우팅
/// - 공통 UI 스타일을 한 번에 관리
/// ============================================================================
class FamilyApp extends StatelessWidget {
  const FamilyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<AppSettingsViewModel>();
    return MaterialApp(
      title: '가족 사진관',
      debugShowCheckedModeBanner: false,

      // ⭐ 전체 테마 적용
      theme: _warmCreamTheme(settings.fontScale),

      // 앱 시작 화면
      initialRoute: AppRoutes.home,

      // 모든 화면 이동은 AppRoutes.generateRoute 에서 관리
      onGenerateRoute: AppRoutes.generateRoute,
    );
  }

  // ==========================================================================
  // ⭐ 따뜻한 크림톤 + 브라운 포인트 테마
  // - 어른(40~60대) 기준 가독성 / 안정감 우선
  // ==========================================================================
  ThemeData _warmCreamTheme(double fontScale) {
    // 색상 정의
    const creamLight = Color(0xFFF9F6F1); // 배경용 크림색
    const warmBrown = Color(0xFF8B6F47); // 메인 포인트 색
    const beigeGold = Color(0xFFC4A484); // 보조 포인트
    const darkText = Color(0xFF2F2A26);  // 텍스트 기본색

    return ThemeData(
      useMaterial3: true,

      // 전체 배경색
      scaffoldBackgroundColor: creamLight,

      // ⭐ 전역 폰트
      fontFamily: 'Pretendard',

      // 색상 스킴
      colorScheme: const ColorScheme.light(
        primary: warmBrown,
        secondary: beigeGold,
        surface: Colors.white,
        onPrimary: Colors.white,
        onSurface: darkText,
      ),

      // ----------------------------------------------------------------------
      // AppBar 스타일
      // ----------------------------------------------------------------------
      appBarTheme: const AppBarTheme(
        backgroundColor: creamLight,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: warmBrown,
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: IconThemeData(
          color: warmBrown,
        ),
      ),

      // ----------------------------------------------------------------------
      // 카드 스타일 (앨범 카드, 사진 카드 등)
      // ----------------------------------------------------------------------
      cardTheme: CardTheme(
        color: Colors.white,
        elevation: 0,
        shadowColor: warmBrown.withOpacity(0.12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
      ),

      // ----------------------------------------------------------------------
      // 텍스트 스타일
      // ----------------------------------------------------------------------
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

      // ----------------------------------------------------------------------
      // 버튼 스타일
      // ----------------------------------------------------------------------
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

      // ----------------------------------------------------------------------
      // 아이콘 기본 색
      // ----------------------------------------------------------------------
      iconTheme: const IconThemeData(
        color: warmBrown,
      ),
    );
  }
}
