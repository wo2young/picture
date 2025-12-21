import 'package:flutter/foundation.dart';
import 'package:family_app/models/album.dart';
import 'package:family_app/api/api_client.dart';

class AlbumService {
  // ---------------------------
  // 앨범 목록 조회
  // GET /albums?family_id=1
  // ---------------------------
  Future<List<Album>> fetchAlbums({
    required int familyId,
  }) async {
    try {
      final data = await ApiClient.get(
        '/albums?family_id=$familyId',
      );

      final List list = data as List;
      return list.map((e) => Album.fromJson(e)).toList();
    } catch (e, stack) {
      debugPrint('fetchAlbums 오류: $e\n$stack');
      rethrow;
    }
  }

  // ---------------------------
  // 앨범 단건 조회
  // GET /albums/{id}
  // ---------------------------
  Future<Album?> getAlbumById(int id) async {
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
  // POST /albums
  // ---------------------------
  Future<Album> createAlbum({
    required int familyId,
    required String title,
    String? description,
    int? folderId,
  }) async {
    try {
      final data = await ApiClient.post(
        '/albums',
        {
          'family_id': familyId,
          'title': title,
          'description': description,
          'folder_id': folderId,
        },
      );

      return Album.fromJson(data);
    } catch (e, stack) {
      debugPrint('createAlbum 오류: $e\n$stack');
      rethrow;
    }
  }
}
