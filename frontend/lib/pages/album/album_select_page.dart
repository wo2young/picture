// lib/pages/album/album_select_page.dart
import 'package:flutter/material.dart';

import 'package:family_app/models/album.dart';
import 'package:family_app/services/album_service.dart';
import 'package:family_app/config/app_routes.dart';

class AlbumSelectPage extends StatefulWidget {
  const AlbumSelectPage({super.key});

  @override
  State<AlbumSelectPage> createState() => _AlbumSelectPageState();
}

class _AlbumSelectPageState extends State<AlbumSelectPage> {
  final AlbumService _albumService = AlbumService();

  // TODO: 로그인 연동 시 실제 familyId로 교체
  static const int _familyId = 1;

  bool _isLoading = true;
  List<Album> _albums = [];

  @override
  void initState() {
    super.initState();
    _loadAlbums();
  }

  Future<void> _loadAlbums() async {
    setState(() => _isLoading = true);

    try {
      final list = await _albumService.fetchAlbums(
        familyId: _familyId, // ✅ 핵심 수정 포인트
      );
      if (!mounted) return;

      setState(() {
        _albums = list;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  // --------------------------------------------------
  // 앨범 생성
  // --------------------------------------------------
  Future<void> _goToCreateAlbum() async {
    final created = await Navigator.pushNamed(
      context,
      AppRoutes.albumCreate,
    );

    if (created == true) {
      _loadAlbums();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('앨범 선택'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: '앨범 만들기',
            onPressed: _goToCreateAlbum,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _albums.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
        itemCount: _albums.length,
        itemBuilder: (context, index) {
          final album = _albums[index];

          return ListTile(
            title: Text(album.title),
            subtitle: album.description?.isNotEmpty == true
                ? Text(album.description!)
                : null,
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // ✅ 선택만 하고 돌아간다
              Navigator.pop(context, album.id);
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            '아직 앨범이 없습니다.',
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 8),
          const Text('사진을 추가하려면 앨범을 먼저 만들어주세요.'),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _goToCreateAlbum,
            icon: const Icon(Icons.add),
            label: const Text('새 앨범 만들기'),
          ),
        ],
      ),
    );
  }
}
