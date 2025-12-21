// lib/pages/album/album_detail_page.dart

import 'package:flutter/material.dart';

import 'package:family_app/models/album.dart';
import 'package:family_app/models/photo.dart';
import 'package:family_app/config/app_routes.dart';
import 'package:family_app/services/photo_service.dart';

/// ============================================================================
/// AlbumDetailPage
/// ----------------------------------------------------------------------------
/// - 앨범 상세 화면
/// - 앨범 정보 + 사진 목록만 담당
/// - 서버 기준으로 사진 목록 관리
///
/// [규칙]
/// - PhotoDetailPage 이동 시: photoId(int)만 전달
/// - PhotoUploadPage 이동 시: albumId(int)만 전달 (권장)
/// ============================================================================
class AlbumDetailPage extends StatefulWidget {
  final Album album;

  const AlbumDetailPage({
    super.key,
    required this.album,
  });

  @override
  State<AlbumDetailPage> createState() => _AlbumDetailPageState();
}

class _AlbumDetailPageState extends State<AlbumDetailPage> {
  final PhotoService _photoService = PhotoService();

  List<Photo> _photos = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPhotos();
  }

  // --------------------------------------------------
  // 사진 목록 서버 재조회
  // --------------------------------------------------
  Future<void> _loadPhotos() async {
    setState(() => _isLoading = true);

    try {
      final photos = await _photoService.fetchPhotosByAlbum(widget.album.id);

      if (!mounted) return;

      setState(() {
        _photos = photos;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() => _isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('사진 목록을 불러오지 못했습니다.')),
      );
    }
  }

  // --------------------------------------------------
  // 사진 추가 → 업로드 페이지로 이동
  // --------------------------------------------------
  Future<void> _goToPhotoUpload() async {
    final refreshed = await Navigator.pushNamed(
      context,
      AppRoutes.photoUpload,
      arguments: widget.album.id, // albumId만 전달 (추천)
    );

    if (!mounted) return;

    if (refreshed == true) {
      await _loadPhotos();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final albumData = widget.album;

    return Scaffold(
      appBar: AppBar(
        title: Text(albumData.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_a_photo),
            tooltip: '사진 추가',
            onPressed: _goToPhotoUpload,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadPhotos,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (albumData.description?.isNotEmpty == true)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text(
                  albumData.description!,
                  style: theme.textTheme.bodyMedium,
                ),
              ),

            if (_isLoading)
              const Padding(
                padding: EdgeInsets.only(top: 60),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_photos.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 60),
                child: Center(
                  child: Text(
                    '아직 사진이 없습니다.',
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
              )
            else
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _photos.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemBuilder: (context, index) {
                  final photo = _photos[index];

                  return GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        AppRoutes.photoView,
                        arguments: photo.id, // photoId만 전달
                      );
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        photo.thumbnailUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const ColoredBox(
                          color: Colors.black12,
                          child: Center(child: Icon(Icons.broken_image)),
                        ),
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}

/*
[전체 정리]

- AlbumDetailPage에서 PhotoDetailPage로 이동할 때는 photoId(int)만 넘긴다.
- PhotoUploadPage로 이동할 때도 albumId(int)만 넘기는 것이 구조가 깔끔하다.
- 업로드 후 true를 반환받으면 _loadPhotos로 재조회하여 화면을 갱신한다.

[실무 포인트]
- 화면 이동 arguments는 "필요 최소값(id)"이 가장 안정적이다.
- 객체 전체 전달은 타입 오염/의존도 증가/라우트 결합도가 커지기 쉽다.
*/
