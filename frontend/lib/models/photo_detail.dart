// lib/models/photo_detail.dart

import 'photo.dart';
import 'diary.dart';

class PhotoDetail {
  final Photo photo;
  final List<Diary> diaries;

  PhotoDetail({
    required this.photo,
    required this.diaries,
  });

  factory PhotoDetail.fromJson(Map<String, dynamic> json) {
    return PhotoDetail(
      photo: Photo.fromJson(json['photo']),
      diaries: (json['diaries'] as List<dynamic>? ?? [])
          .map((e) => Diary.fromJson(e))
          .toList(),
    );
  }
}
