import 'dart:async';
import 'package:flutter/foundation.dart';

import 'package:family_app/models/feed_item.dart';
import 'package:family_app/models/home_photo_item.dart';
import 'package:family_app/services/feed_service.dart';
import 'package:family_app/services/photo_service.dart';
import 'package:family_app/api/api_client.dart';

/// ============================================================================
/// HomeViewModel
/// ----------------------------------------------------------------------------
/// - Home 화면 전용 ViewModel
/// - Feed 기반 최신 사진 표시
/// - Home 전용 모델(HomePhotoItem)만 사용
/// - ❌ Photo 도메인 모델 생성 금지
///
/// [A안 적용]
/// - 오늘의 추천 사진에 실제 썸네일 표시
/// - featuredPhotoId + featuredImageUrl만 관리
/// - ⭐ 가족 존재 여부 판단 추가
/// ============================================================================
class HomeViewModel extends ChangeNotifier {
  final FeedService _feedService;
  final PhotoService _photoService = PhotoService();

  HomeViewModel({
    FeedService? feedService,
  }) : _feedService = feedService ?? FeedService();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  /// ⭐ 가족 생성 필요 여부 (이거 하나로 충분)
  bool _needCreateFamily = false;
  bool get needCreateFamily => _needCreateFamily;

  List<HomePhotoItem> _recentPhotos = [];
  List<HomePhotoItem> get recentPhotos => _recentPhotos;

  int? _featuredPhotoId;
  int? get featuredPhotoId => _featuredPhotoId;

  String? _featuredImageUrl;
  String? get featuredImageUrl => _featuredImageUrl;

  Timer? _featuredTimer;

  // ---------------------------------------------------------------------------
  // Home 전체 로딩
  // ---------------------------------------------------------------------------
  Future<void> loadHome() async {
    _isLoading = true;
    notifyListeners();

    try {
      // 0️⃣ 가족 존재 여부 확인
      final List<dynamic> families = await ApiClient.get('/families');

      if (families.isEmpty) {
        _needCreateFamily = true;

        // 홈 데이터 초기화
        _recentPhotos = [];
        _featuredPhotoId = null;
        _featuredImageUrl = null;

        _featuredTimer?.cancel(); // ⭐ 중요
        return;
      }

      _needCreateFamily = false;

      const int userId = 1; // TODO: 로그인 연동 시 제거

      // 1️⃣ 최신 Feed
      final List<FeedItem> latestFeed =
      await _feedService.fetchLatestFeed(userId);

      final List<HomePhotoItem> items = [];

      for (final item
      in latestFeed.where((e) => e.type == 'photo').take(9)) {
        bool hasDiary = false;

        try {
          final detail =
          await _photoService.fetchPhotoDetail(item.contentId);
          hasDiary = detail.diaries.isNotEmpty;
        } catch (_) {}

        items.add(
          HomePhotoItem(
            photoId: item.contentId,
            imageUrl: item.value,
            takenAt: item.sortDate,
            hasDiary: hasDiary,
          ),
        );
      }

      _recentPhotos = items;

      await _loadFeaturedPhoto(userId);
      _startFeaturedTimer(userId);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadFeaturedPhoto(int userId) async {
    final List<FeedItem> randomFeed =
    await _feedService.fetchRandomFeed(userId);

    for (final item in randomFeed) {
      if (item.type == 'photo') {
        if (_featuredPhotoId == item.contentId) return;

        _featuredPhotoId = item.contentId;
        _featuredImageUrl = item.value;
        notifyListeners();
        return;
      }
    }
  }

  void _startFeaturedTimer(int userId) {
    _featuredTimer?.cancel();
    _featuredTimer = Timer.periodic(
      const Duration(minutes: 3),
          (_) => _loadFeaturedPhoto(userId),
    );
  }

  @override
  void dispose() {
    _featuredTimer?.cancel();
    super.dispose();
  }
}
