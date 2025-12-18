// lib/models/feed_item.dart

class FeedItem {
  final String type;        // 'photo' | 'diary'
  final int contentId;      // DB id
  final DateTime sortDate;  // created_at
  final String value;       // photo: original_url, diary: title

  const FeedItem({
    required this.type,
    required this.contentId,
    required this.sortDate,
    required this.value,
  });

  factory FeedItem.fromJson(Map<String, dynamic> json) {
    return FeedItem(
      type: (json['type'] ?? '').toString(),
      contentId: int.parse(json['content_id'].toString()),
      sortDate: DateTime.parse(json['sort_date'].toString()),
      value: (json['value'] ?? '').toString(),
    );
  }
}
