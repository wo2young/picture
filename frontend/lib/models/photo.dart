// lib/models/photo.dart

class Photo {
  final int id;
  final int albumId;              // ✅ int로 통일
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

  Photo copyWith({
    int? id,
    int? albumId,
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
      id: json['id'].toInt(),
      albumId: json['album_id'].toInt(),   // ✅ int
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
