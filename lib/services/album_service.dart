// lib/services/album_service.dart
import 'package:flutter/foundation.dart';
import 'package:family_app/models/album.dart';
import 'package:family_app/api/api_client.dart';

class AlbumService {

  // ---------------------------
  // 앨범 목록 조회
  // ---------------------------
  Future<List<Album>> fetchAlbums() async {
    try {
      final data = await ApiClient.get('/albums');

      return (data as List)
          .map((json) => Album.fromJson(json))
          .toList();
    } catch (e, stack) {
      debugPrint('fetchAlbums 오류: $e\n$stack');
      rethrow;
    }
  }

  // ---------------------------
  // 앨범 단건 조회
  // ---------------------------
  Future<Album?> getAlbumById(String id) async {
    try {
      final data = await ApiClient.get('/albums/$id');
      return Album.fromJson(data);
    } catch (e, stack) {
      debugPrint('getAlbumById 오류: $e\n$stack');
      return null;
    }
  }

  // ---------------------------
  // 앨범 생성
  // ---------------------------
  Future<Album> createAlbum({
    required String title,
    String? description,
  }) async {
    try {
      final data = await ApiClient.post('/albums', {
        'title': title,
        'description': description,
      });

      return Album.fromJson(data);
    } catch (e, stack) {
      debugPrint('createAlbum 오류: $e\n$stack');
      rethrow;
    }
  }
}
