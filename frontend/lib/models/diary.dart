// lib/models/diary.dart

import 'photo.dart';

/// ============================================================================
/// Diary
/// ----------------------------------------------------------------------------
/// - 일기 도메인 모델
/// - ID / 관계 ID는 모두 int 기준
/// - Photo 엔티티와 연결되지만, 소유하지 않음
/// ============================================================================
class Diary {
  final int id;
  final String title;
  final String content;
  final DateTime date;

  /// 대표 사진 ID (썸네일용)
  final int? photoId;

  /// 연결된 앨범 ID
  final int? albumId;

  /// 상세 조회 시만 포함되는 사진들
  final List<Photo> photos;

  const Diary({
    required this.id,
    required this.title,
    required this.content,
    required this.date,
    this.photoId,
    this.albumId,
    this.photos = const [],
  });

  Diary copyWith({
    int? id,
    String? title,
    String? content,
    DateTime? date,
    int? photoId,
    int? albumId,
    List<Photo>? photos,
  }) {
    return Diary(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      date: date ?? this.date,
      photoId: photoId ?? this.photoId,
      albumId: albumId ?? this.albumId,
      photos: photos ?? this.photos,
    );
  }

  factory Diary.fromJson(Map<String, dynamic> json) {
    return Diary(
      id: json['id'].toInt(),
      title: json['title'] as String,
      content: json['content'] as String,
      date: DateTime.parse(
        json['diary_date'] ?? json['date'],
      ),
      photoId: json['photo_id'] != null
          ? json['photo_id'].toInt()
          : null,
      albumId: json['album_id'] != null
          ? json['album_id'].toInt()
          : null,
      photos: (json['photos'] as List<dynamic>?)
          ?.map((e) => Photo.fromJson(e))
          .toList() ??
          const [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'diary_date': date.toIso8601String(),
      'photo_id': photoId,
      'album_id': albumId,
    };
  }
}
