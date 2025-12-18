// lib/services/photo_service.dart
import 'dart:async';
import 'dart:math';
import 'package:family_app/models/photo.dart';
import 'package:family_app/api/api_client.dart';
import 'package:family_app/models/photo_detail.dart';

class PhotoService {
  // 임시 사진 데이터 (백엔드 스키마 기준)
  final List<Photo> _photos = [
    Photo(
      id: 'p1',
      albumId: '1',
      originalUrl: 'https://picsum.photos/800?1',
      thumbnailUrl: 'https://picsum.photos/400?1',
      description: '예시 사진 1',
      takenAt: DateTime.now().subtract(const Duration(days: 1)),
      place: '제주',
    ),
    Photo(
      id: 'p2',
      albumId: '1',
      originalUrl: 'https://picsum.photos/800?2',
      thumbnailUrl: 'https://picsum.photos/400?2',
      description: '예시 사진 2',
      takenAt: DateTime.now().subtract(const Duration(days: 2)),
      place: '부산',
    ),
    Photo(
      id: 'p3',
      albumId: '2',
      originalUrl: 'https://picsum.photos/800?3',
      thumbnailUrl: 'https://picsum.photos/400?3',
      description: '예시 사진 3',
      takenAt: DateTime.now(),
      place: '서울',
    ),
  ];

  // --------------------------------
  // 앨범별 사진 조회
  // --------------------------------
  Future<List<Photo>> fetchPhotosByAlbum(String albumId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _photos.where((p) => p.albumId == albumId).toList();
  }

  // --------------------------------
  // 사진 업로드 (mock)
  // --------------------------------
  Future<Photo> uploadPhoto({
    required String albumId,
    required String originalUrl,
    required String thumbnailUrl,
    String? description,
    String? place,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));

    final newPhoto = Photo(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      albumId: albumId,
      originalUrl: originalUrl,
      thumbnailUrl: thumbnailUrl,
      description: description,
      place: place,
      takenAt: DateTime.now(),
    );

    _photos.insert(0, newPhoto);
    return newPhoto;
  }

  // --------------------------------
  // 설명 수정
  // --------------------------------
  Future<Photo> updatePhotoDescription(
      Photo photo,
      String newDescription,
      ) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final updated = photo.copyWith(description: newDescription);
    final index = _photos.indexWhere((p) => p.id == photo.id);
    if (index != -1) _photos[index] = updated;

    return updated;
  }

  // --------------------------------
  // 추천 사진 1장 (랜덤)
  // --------------------------------
  Future<Photo?> fetchRandomFeaturedPhoto({String? exceptId}) async {
    if (_photos.isEmpty) return null;

    await Future.delayed(const Duration(milliseconds: 200));

    final candidates = exceptId == null
        ? _photos
        : _photos.where((p) => p.id != exceptId).toList();

    if (candidates.isEmpty) return null;

    final rnd = Random();
    return candidates[rnd.nextInt(candidates.length)];
  }

  // 사진 상세 + 연결된 일기
  Future<PhotoDetail> fetchPhotoDetail(String photoId) async {
    final res = await ApiClient.get('/photos/$photoId');
    return PhotoDetail.fromJson(res);
  }
}
