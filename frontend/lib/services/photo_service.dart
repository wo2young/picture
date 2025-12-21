// lib/services/photo_service.dart
import 'dart:async';
import 'package:flutter/foundation.dart';

import 'package:family_app/api/api_client.dart';
import 'package:family_app/models/photo.dart';
import 'package:family_app/models/photo_detail.dart';

/// ============================================================================
/// PhotoService
/// ----------------------------------------------------------------------------
/// - 사진 관련 API 호출 전담
/// - 상태는 들고 있지 않음 (ViewModel / Page 책임)
/// - FastAPI /photos 엔드포인트와 1:1 매칭
///
/// ✔ 모든 ID는 int 기준
/// ✔ create / read / update / delete 구조 완성
/// ============================================================================
class PhotoService {
  // ---------------------------------------------------------------------------
  // 사진 생성 (DB 저장)
  // POST /photos
  // ---------------------------------------------------------------------------
  Future<void> createPhoto({
    required int albumId,
    required String originalUrl,
    required String thumbnailUrl,
    String? description,
    String? place,
  }) async {
    try {
      await ApiClient.post(
        '/photos',
        {
          'album_id': albumId,
          'uploader_id': 1, // TODO: 로그인 연동 시 교체
          'original_url': originalUrl,
          'thumbnail_url': thumbnailUrl,
          'description': description,
          'place': place,
        },
      );
    } catch (e, stack) {
      debugPrint('createPhoto 오류: $e\n$stack');
      rethrow;
    }
  }

  // ---------------------------------------------------------------------------
  // 앨범별 사진 목록 조회
  // GET /photos/album/{albumId}
  // ---------------------------------------------------------------------------
  Future<List<Photo>> fetchPhotosByAlbum(int albumId) async {
    try {
      final data = await ApiClient.get(
        '/photos/album/$albumId',
      ) as List<dynamic>;

      return data
          .map((e) => Photo.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e, stack) {
      debugPrint('fetchPhotosByAlbum 오류: $e\n$stack');
      rethrow;
    }
  }

  // ---------------------------------------------------------------------------
  // 사진 상세 + 연결된 일기
  // GET /photos/{photoId}
  // ---------------------------------------------------------------------------
  Future<PhotoDetail> fetchPhotoDetail(int photoId) async {
    try {
      final data = await ApiClient.get(
        '/photos/$photoId',
      ) as Map<String, dynamic>;

      return PhotoDetail.fromJson(data);
    } catch (e, stack) {
      debugPrint('fetchPhotoDetail 오류: $e\n$stack');
      rethrow;
    }
  }

  // ---------------------------------------------------------------------------
  // 사진 수정 (설명 / 장소)
  // PUT /photos/{photoId}
  // ---------------------------------------------------------------------------
  Future<void> updatePhoto({
    required int photoId,
    String? description,
    String? place,
  }) async {
    try {
      await ApiClient.put(
        '/photos/$photoId',
        {
          'description': description,
          'place': place,
        },
      );
    } catch (e, stack) {
      debugPrint('updatePhoto 오류: $e\n$stack');
      rethrow;
    }
  }

  // ---------------------------------------------------------------------------
  // 사진 삭제 (soft delete)
  // DELETE /photos/{photoId}
  // ---------------------------------------------------------------------------
  Future<void> deletePhoto(int photoId) async {
    try {
      await ApiClient.delete('/photos/$photoId');
    } catch (e, stack) {
      debugPrint('deletePhoto 오류: $e\n$stack');
      rethrow;
    }
  }
}
