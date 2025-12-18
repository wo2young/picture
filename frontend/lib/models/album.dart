// lib/models/album.dart
import 'package:family_app/models/photo.dart';

class Album {
  final String id;
  final String title;
  final String? description;
  final DateTime createdAt;
  final String? coverUrl;
  final int photoCount;
  final List<Photo>? photos;

  const Album({
    required this.id,
    required this.title,
    this.description,
    required this.createdAt,
    this.coverUrl,
    this.photoCount = 0,
    this.photos,
  });

  Album copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? createdAt,
    String? coverUrl,
    int? photoCount,
    List<Photo>? photos,
  }) {
    return Album(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      coverUrl: coverUrl ?? this.coverUrl,
      photoCount: photoCount ?? this.photoCount,
      photos: photos ?? this.photos,
    );
  }

  factory Album.fromJson(Map<String, dynamic> json) {
    return Album(
      id: json['id'].toString(),
      title: json['title'],
      description: json['description'],
      createdAt: DateTime.parse(json['created_at']),
      coverUrl: json['cover_url'],
      photoCount: json['photo_count'] ?? 0,
      photos: json['photos'] != null
          ? (json['photos'] as List)
          .map((e) => Photo.fromJson(e))
          .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'created_at': createdAt.toIso8601String(),
      'cover_url': coverUrl,
      'photo_count': photoCount,
    };
  }
}
