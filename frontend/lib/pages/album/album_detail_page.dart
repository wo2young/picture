// lib/pages/album/album_detail_page.dart

import 'package:flutter/material.dart';

import 'package:family_app/models/album.dart';
import 'package:family_app/models/photo.dart';
import 'package:family_app/config/app_routes.dart';

/// ============================================================================
/// AlbumDetailPage
/// ----------------------------------------------------------------------------
/// - 앨범 상세 화면
/// - 앨범 정보 + 사진 목록만 담당
/// - ❌ 일기 상세 / DiaryDetailPage 없음
/// ============================================================================
class AlbumDetailPage extends StatelessWidget {
  final Album? album;

  const AlbumDetailPage({
    super.key,
    required this.album,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // 방어 코드 (arguments 누락 대비)
    if (album == null) {
      return const Scaffold(
        body: Center(child: Text('앨범 정보를 불러올 수 없습니다.')),
      );
    }

    final List<Photo> photos = album!.photos ?? [];

    return Scaffold(
      appBar: AppBar(
        title: Text(album!.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_a_photo),
            onPressed: () {
              Navigator.pushNamed(
                context,
                AppRoutes.photoUpload,
                arguments: album,
              );
            },
          ),
        ],
      ),

      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ============================================================
          // 앨범 설명
          // ============================================================
          if (album!.description != null &&
              album!.description!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Text(
                album!.description!,
                style: theme.textTheme.bodyMedium,
              ),
            ),

          // ============================================================
          // 사진 목록
          // ============================================================
          if (photos.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.only(top: 40),
                child: Text('아직 사진이 없습니다.'),
              ),
            )
          else
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: photos.length,
              gridDelegate:
              const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemBuilder: (context, index) {
                final photo = photos[index];

                return GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      AppRoutes.photoView,
                      arguments: photo,
                    );
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      photo.thumbnailUrl,
                      fit: BoxFit.cover,
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
