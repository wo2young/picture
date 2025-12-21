// lib/services/feed_service.dart
import 'package:family_app/api/api_client.dart';
import 'package:family_app/models/feed_item.dart';

class FeedService {
  // --------------------------------------------------
  // 최신 피드 (사진 + 일기)
  // GET /feed/latest?user_id=1
  // --------------------------------------------------
  Future<List<FeedItem>> fetchLatestFeed(int userId) async {
    final data = await ApiClient.get(
      '/feed/latest?user_id=$userId',
    );

    final List list = data as List;

    return list
        .map((e) => FeedItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // --------------------------------------------------
  // 랜덤 피드 (사진만)
  // GET /feed/random?user_id=1
  // --------------------------------------------------
  Future<List<FeedItem>> fetchRandomFeed(int userId) async {
    final data = await ApiClient.get(
      '/feed/random?user_id=$userId',
    );

    final List list = data as List;

    return list.map((e) {
      final m = e as Map<String, dynamic>;

      // 1) 이미 feed 형태(type/content_id/...)로 오는 경우
      if (m.containsKey('type') && m.containsKey('content_id')) {
        return FeedItem.fromJson(m);
      }

      // 2) photo 테이블 row(*) 형태로 오는 경우
      return FeedItem(
        type: 'photo',
        contentId: int.parse(m['id'].toString()),
        sortDate: DateTime.parse(
          (m['created_at'] ?? m['taken_at']).toString(),
        ),
        value: (m['original_url'] ?? m['thumbnail_url'] ?? '').toString(),
      );
    }).toList();
  }
}
