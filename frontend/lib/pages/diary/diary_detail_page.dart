// lib/pages/diary/diary_detail_page.dart
import 'package:flutter/material.dart';

import 'package:family_app/models/diary.dart';
import 'package:family_app/models/photo.dart';
import 'package:family_app/view_models/diary_view_model.dart';
import 'package:family_app/config/app_routes.dart';
import 'package:family_app/utils/formatters.dart';

class DiaryDetailPage extends StatefulWidget {
  final Diary diary;

  const DiaryDetailPage({
    super.key,
    required this.diary,
  });

  @override
  State<DiaryDetailPage> createState() => _DiaryDetailPageState();
}

class _DiaryDetailPageState extends State<DiaryDetailPage> {
  late final DiaryViewModel _viewModel;
  late Diary _diary;

  @override
  void initState() {
    super.initState();
    _viewModel = DiaryViewModel();
    _diary = widget.diary;
  }

  // --------------------------------------------------
  // 일기 수정
  // --------------------------------------------------
  Future<void> _editDiary() async {
    final result = await Navigator.pushNamed(
      context,
      AppRoutes.diaryWrite,
      arguments: {
        'original': _diary,
        'albumId': _diary.albumId,
        'photoId': _diary.photoId,
      },
    );

    if (result == true) {
      // 수정 후 뒤로 가며 상위 화면에서 새로고침
      if (mounted) Navigator.pop(context, true);
    }
  }

  // --------------------------------------------------
  // 일기 삭제
  // --------------------------------------------------
  Future<void> _deleteDiary() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('일기 삭제'),
        content: const Text('이 일기를 삭제하시겠어요?\n삭제하면 복구할 수 없습니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              '삭제',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    await _viewModel.deleteDiary(_diary.id);

    if (mounted) {
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Photo> photos = _diary.photos;

    return Scaffold(
      appBar: AppBar(
        title: const Text('일기'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: '수정',
            onPressed: _editDiary,
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            tooltip: '삭제',
            onPressed: _deleteDiary,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // -----------------------------
          // 날짜
          // -----------------------------
          Text(
            Formatters.formatDate(_diary.date),
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: Colors.grey),
          ),

          const SizedBox(height: 8),

          // -----------------------------
          // 제목
          // -----------------------------
          Text(
            _diary.title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 16),

          // -----------------------------
          // 연결된 사진
          // -----------------------------
          if (photos.isNotEmpty) ...[
            SizedBox(
              height: 120,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: photos.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final photo = photos[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        AppRoutes.photoView,
                        arguments: photo.id,
                      );
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        photo.thumbnailUrl,
                        width: 120,
                        fit: BoxFit.cover,
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
          ],

          // -----------------------------
          // 내용
          // -----------------------------
          Text(
            _diary.content,
            style: const TextStyle(fontSize: 16, height: 1.5),
          ),
        ],
      ),
    );
  }
}
