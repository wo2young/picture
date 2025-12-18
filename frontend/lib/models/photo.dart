// lib/models/photo.dart

class Photo {
  final String id;
  final String albumId;
  final String originalUrl;
  final String thumbnailUrl;
  final String? description;
  final DateTime? takenAt;
  final String? place;

  const Photo({
    required this.id,
    required this.albumId,
    required this.originalUrl,
    required this.thumbnailUrl,
    this.description,
    this.takenAt,
    this.place,
  });

  // ✅ 이거 추가
  Photo copyWith({
    String? id,
    String? albumId,
    String? originalUrl,
    String? thumbnailUrl,
    String? description,
    DateTime? takenAt,
    String? place,
  }) {
    return Photo(
      id: id ?? this.id,
      albumId: albumId ?? this.albumId,
      originalUrl: originalUrl ?? this.originalUrl,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      description: description ?? this.description,
      takenAt: takenAt ?? this.takenAt,
      place: place ?? this.place,
    );
  }

  factory Photo.fromJson(Map<String, dynamic> json) {
    return Photo(
      id: json['id'].toString(),
      albumId: json['album_id'].toString(),
      originalUrl: json['original_url'] as String,
      thumbnailUrl: json['thumbnail_url'] as String,
      description: json['description'] as String?,
      takenAt: json['taken_at'] != null
          ? DateTime.parse(json['taken_at'])
          : null,
      place: json['place'] as String?,
    );
  }
}
