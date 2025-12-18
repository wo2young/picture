// lib/models/diary.dart

import 'photo.dart';

/// ============================================================================
/// Diary
/// ----------------------------------------------------------------------------
/// - 일기 단일 모델
/// - 목록 / 상세 / 작성 / 수정 전부 이 모델 하나로 처리
/// - 소규모 앱에 맞게 구조 단순화
///
/// ✔ 대표 사진(photoId) 유지
/// ✔ 다중 사진 연결용 photos 추가 (선택)
/// ============================================================================
class Diary {
  final String id;
  final String title;
  final String content;
  final DateTime date;

  /// 대표 사진 (있으면 썸네일용)
  final String? photoId;

  /// 연결된 앨범
  final String? albumId;

  /// ⭐ 이 일기에 연결된 사진들 (상세 화면용)
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
    String? id,
    String? title,
    String? content,
    DateTime? date,
    String? photoId,
    String? albumId,
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
      id: json['id'].toString(),
      title: json['title'] as String,
      content: json['content'] as String,

      // ⚠️ 백엔드 컬럼명에 맞춤
      date: DateTime.parse(
        json['diary_date'] ?? json['date'],
      ),

      photoId: json['photo_id']?.toString(),
      albumId: json['album_id']?.toString(),

      // ⭐ 상세 조회 시만 내려오는 photos
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
