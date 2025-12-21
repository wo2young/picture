// lib/models/home_photo_item.dart

class HomePhotoItem {
  final int photoId;        // 실제 Photo PK
  final String imageUrl;    // 썸네일/원본 URL
  final DateTime takenAt;
  final bool hasDiary;

  const HomePhotoItem({
    required this.photoId,
    required this.imageUrl,
    required this.takenAt,
    required this.hasDiary,
  });
}
