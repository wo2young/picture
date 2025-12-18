// lib/pages/home/home_view_model.dart

import 'dart:async';
import 'package:flutter/foundation.dart';

import 'package:family_app/models/photo.dart';
import 'package:family_app/models/feed_item.dart';
import 'package:family_app/services/feed_service.dart';

/// ============================================================================
/// HomeViewModel
/// ----------------------------------------------------------------------------
/// Home 화면 전용 ViewModel
/// - 백엔드 Feed API 기반
/// - 앨범 개념은 Home에서 사용하지 않음
/// - 사진 중심(Home UX 단순화)
/// ============================================================================
class HomeViewModel extends ChangeNotifier {
  // ---------------------------------------------------------------------------
  // Service
  // ---------------------------------------------------------------------------
  final FeedService _feedService;

  HomeViewModel({
    FeedService? feedService,
  }) : _feedService = feedService ?? FeedService();

  // ---------------------------------------------------------------------------
  // State
  // ---------------------------------------------------------------------------
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // 최근 사진 목록 (홈 하단 Grid)
  List<Photo> _recentPhotos = [];
  List<Photo> get recentPhotos => _recentPhotos;

  // 오늘의 추천 사진 (상단 Hero)
  Photo? _featuredPhoto;
  Photo? get featuredPhoto => _featuredPhoto;

  // 추천 사진 자동 변경용 타이머
  Timer? _featuredTimer;

  // ---------------------------------------------------------------------------
  // 홈 전체 로딩
  // ---------------------------------------------------------------------------
  Future<void> loadHome() async {
    _isLoading = true;
    notifyListeners();

    try {
      // TODO: 로그인 연동 시 실제 userId로 교체
      const int userId = 1;

      // --------------------------------------------------
      // 1️⃣ 최신 Feed 로딩
      // --------------------------------------------------
      final List<FeedItem> latestFeed =
      await _feedService.fetchLatestFeed(userId);

      // --------------------------------------------------
      // 2️⃣ Feed → Photo 변환 (photo 타입만)
      // --------------------------------------------------
      final List<Photo> photos = latestFeed
          .where((item) => item.type == 'photo')
          .map(
            (item) => Photo(
          id: item.contentId.toString(),

          // Home에서는 앨범 정보가 필요 없으므로
          // 고정 더미 값 사용 (null ❌)
          albumId: 'feed',

          originalUrl: item.value,
          thumbnailUrl: item.value,
          takenAt: item.sortDate,
          description: null,
        ),
      )
          .toList();

      // 최근 사진 9장만 노출
      _recentPhotos = photos.take(9).toList();

      // --------------------------------------------------
      // 3️⃣ 오늘의 추천 사진
      // --------------------------------------------------
      await _loadFeaturedPhoto(userId);

      // --------------------------------------------------
      // 4️⃣ 추천 사진 자동 변경 타이머
      // --------------------------------------------------
      _startFeaturedTimer(userId);
    } catch (e) {
      // debugPrint('HomeViewModel loadHome error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ---------------------------------------------------------------------------
  // 추천 사진 1장 로딩
  // ---------------------------------------------------------------------------
  Future<void> _loadFeaturedPhoto(int userId) async {
    final List<FeedItem> randomFeed =
    await _feedService.fetchRandomFeed(userId);

    // photo 타입 하나만 선택
    FeedItem? selected;
    for (final item in randomFeed) {
      if (item.type == 'photo') {
        selected = item;
        break;
      }
    }
    if (selected == null) return;

    // 같은 사진 연속 방지
    if (_featuredPhoto != null &&
        _featuredPhoto!.id == selected.contentId.toString()) {
      return;
    }

    _featuredPhoto = Photo(
      id: selected.contentId.toString(),
      albumId: 'feed',
      originalUrl: selected.value,
      thumbnailUrl: selected.value,
      takenAt: selected.sortDate,
      description: null,
    );

    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // 추천 사진 3분 주기 변경
  // ---------------------------------------------------------------------------
  void _startFeaturedTimer(int userId) {
    _featuredTimer?.cancel();

    _featuredTimer = Timer.periodic(
      const Duration(minutes: 3),
          (_) async => _loadFeaturedPhoto(userId),
    );
  }

  @override
  void dispose() {
    _featuredTimer?.cancel();
    super.dispose();
  }
}
