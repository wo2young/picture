// lib/pages/diary/diary_detail_page.dart

import 'package:flutter/material.dart';

import 'package:family_app/models/diary.dart';
import 'package:family_app/config/app_routes.dart';
import 'package:family_app/utils/formatters.dart';
import 'package:family_app/services/photo_service.dart';
import 'package:family_app/models/photo.dart';
import 'package:provider/provider.dart';
import 'package:family_app/view_models/diary_view_model.dart';

/// ============================================================================
/// DiaryDetailPage
/// ----------------------------------------------------------------------------
/// - 일기 상세 화면
/// - Diary 모델 하나만 사용
/// - photoId가 있을 경우 사진 1장만 표시
/// - 사진 로딩 Future 캐싱 (재빌드 시 재요청 방지)
/// ============================================================================
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
  static final PhotoService _photoService = PhotoService();

  Future<Photo>? _photoFuture;

  @override
  void initState() {
    super.initState();

    if (widget.diary.photoId != null) {
      _photoFuture = _photoService
          .fetchPhotoDetail(widget.diary.photoId!)
          .then((detail) => detail.photo);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('일기 상세'),
        actions: [
          // 수정
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              await Navigator.pushNamed(
                context,
                AppRoutes.diaryWrite,
                arguments: widget.diary,
              );

              if (context.mounted) {
                Navigator.pop(context);
              }
            },
          ),

          // 삭제
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () async {
              final ok = await showDialog<bool>(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('일기 삭제'),
                  content: const Text('이 일기를 삭제할까요?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('취소'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('삭제'),
                    ),
                  ],
                ),
              );

              if (ok == true && context.mounted) {
                await context
                    .read<DiaryViewModel>()
                    .deleteDiary(widget.diary.id);

                if (context.mounted) {
                  Navigator.pop(context);
                }
              }
            },
          ),
        ],
      ),

          body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ============================================================
          // 연결된 사진 (있을 때만)
          // ============================================================
          if (_photoFuture != null) ...[
            FutureBuilder<Photo>(
              future: _photoFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                if (snapshot.hasError) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Text(
                      '사진을 불러오지 못했습니다.',
                      style: theme.textTheme.bodySmall
                          ?.copyWith(color: Colors.grey),
                    ),
                  );
                }

                if (!snapshot.hasData) {
                  return const SizedBox.shrink();
                }

                final photo = snapshot.data!;

                return GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      AppRoutes.photoView,
                      arguments: photo,
                    );
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      photo.thumbnailUrl,
                      fit: BoxFit.cover,
                      height: 220,
                      width: double.infinity,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
          ],

          // ============================================================
          // 제목
          // ============================================================
          Text(
            widget.diary.title,
            style: theme.textTheme.headlineSmall
                ?.copyWith(fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 8),

          // 날짜
          Text(
            Formatters.formatDate(widget.diary.date),
            style: theme.textTheme.bodySmall
                ?.copyWith(color: Colors.grey),
          ),

          const SizedBox(height: 24),

          // ============================================================
          // 내용
          // ============================================================
          Text(
            widget.diary.content,
            style: theme.textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }
}
