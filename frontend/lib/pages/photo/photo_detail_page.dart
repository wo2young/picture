// lib/pages/photo/photo_detail_page.dart
import 'package:flutter/material.dart';
import 'package:family_app/models/photo_detail.dart';
import 'package:family_app/services/photo_service.dart';
import 'package:family_app/config/app_routes.dart';
import 'package:family_app/models/diary.dart';

class PhotoDetailPage extends StatefulWidget {
  final int photoId;

  const PhotoDetailPage({
    super.key,
    required this.photoId,
  });

  @override
  State<PhotoDetailPage> createState() => _PhotoDetailPageState();
}

class _PhotoDetailPageState extends State<PhotoDetailPage> {
  final PhotoService _photoService = PhotoService();

  bool _isLoading = true;
  PhotoDetail? _detail;

  @override
  void initState() {
    super.initState();
    _loadDetail();
  }

  // --------------------------------------------------
  // 사진 상세 + 연결된 일기 로딩
  // --------------------------------------------------
  Future<void> _loadDetail() async {
    setState(() => _isLoading = true);

    try {
      final detail =
      await _photoService.fetchPhotoDetail(widget.photoId);

      if (!mounted) return;

      setState(() {
        _detail = detail;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  // --------------------------------------------------
  // 이 사진으로 새 일기 작성
  // --------------------------------------------------
  Future<void> _writeDiary() async {
    final result = await Navigator.pushNamed(
      context,
      AppRoutes.diaryWrite,
      arguments: {
        'albumId': _detail!.photo.albumId,
        'photoId': _detail!.photo.id,
      },
    );

    if (result == true) {
      _loadDetail();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_detail == null) {
      return const Scaffold(
        body: Center(child: Text('사진을 불러오지 못했습니다.')),
      );
    }

    final photo = _detail!.photo;
    final diaries = _detail!.diaries;

    return Scaffold(
      appBar: AppBar(
        title: const Text('사진 상세'),
      ),
      body: ListView(
        children: [
          // -----------------------------
          // 사진
          // -----------------------------
          Image.network(
            photo.originalUrl,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => const SizedBox(
              height: 240,
              child: Center(child: Icon(Icons.broken_image)),
            ),
          ),

          const SizedBox(height: 12),

          // -----------------------------
          // 메타 정보
          // -----------------------------
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (photo.takenAt != null)
                  Text(
                    '촬영일 · ${photo.takenAt!.toLocal().toString().split(' ').first}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                if (photo.place != null)
                  Text(
                    '장소 · ${photo.place}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // -----------------------------
          // 이 사진으로 일기 쓰기 버튼 (핵심 UX)
          // -----------------------------
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ElevatedButton.icon(
              icon: const Icon(Icons.edit),
              label: const Text('이 사진으로 일기 쓰기'),
              onPressed: _writeDiary,
            ),
          ),

          const SizedBox(height: 24),

          // -----------------------------
          // 연결된 일기
          // -----------------------------
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              '이 사진으로 쓴 일기',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(height: 8),

          if (diaries.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                '이 사진으로 남긴 일기가 아직 없어요.\n위 버튼을 눌러 기록해보세요.',
                style: TextStyle(color: Colors.grey),
              ),
            )
          else
            ...diaries.map(
                  (Diary diary) => Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 6,
                ),
                child: Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    title: Text(
                      diary.title,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      diary.content,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        AppRoutes.diaryDetail,
                        arguments: diary,
                      );
                    },
                  ),
                ),
              ),
            ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
