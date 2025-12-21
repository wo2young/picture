// lib/pages/album/album_list_page.dart
import 'package:flutter/material.dart';

import 'package:family_app/models/album.dart';
import 'package:family_app/services/album_service.dart';
import 'package:family_app/widgets/album_card.dart';

class AlbumListPage extends StatefulWidget {
  const AlbumListPage({super.key});

  @override
  State<AlbumListPage> createState() => _AlbumListPageState();
}

class _AlbumListPageState extends State<AlbumListPage> {
  final AlbumService _albumService = AlbumService();
  final TextEditingController _albumNameController =
  TextEditingController();

  // TODO: 로그인 붙으면 교체
  static const int _familyId = 1;

  bool _isLoading = false;
  List<Album> _albums = [];

  @override
  void initState() {
    super.initState();
    _loadAlbums();
  }

  @override
  void dispose() {
    _albumNameController.dispose();
    super.dispose();
  }

  // --------------------------------------------------
  // 앨범 목록 로딩
  // --------------------------------------------------
  Future<void> _loadAlbums() async {
    setState(() => _isLoading = true);

    try {
      final list = await _albumService.fetchAlbums(
        familyId: _familyId,
      );
      if (!mounted) return;
      setState(() => _albums = list);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // --------------------------------------------------
  // 앨범 생성 다이얼로그
  // --------------------------------------------------
  void _showCreateAlbumDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('새 앨범 만들기'),
        content: TextField(
          controller: _albumNameController,
          decoration: const InputDecoration(
            hintText: '앨범 이름',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              _albumNameController.clear();
              Navigator.pop(context);
            },
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: _createAlbum,
            child: const Text('만들기'),
          ),
        ],
      ),
    );
  }

  Future<void> _createAlbum() async {
    final title = _albumNameController.text.trim();
    if (title.isEmpty) return;

    try {
      final album = await _albumService.createAlbum(
        familyId: _familyId,
        title: title,
      );

      if (!mounted) return;

      _albumNameController.clear();
      Navigator.pop(context);           // 다이얼로그 닫기
      Navigator.pop(context, album.id); // ✅ 선택 결과 반환
    } catch (_) {
      // TODO: 에러 스낵바
    }
  }

  // --------------------------------------------------
  // UI
  // --------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('앨범 선택'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: '앨범 추가',
            onPressed: _showCreateAlbumDialog,
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
          return AlbumCard(
            album: album,
            onTap: () {
              // ✅ 앨범 선택 후 돌아가기
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
          const Text('사진을 정리하려면 앨범을 만들어주세요.'),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _showCreateAlbumDialog,
            icon: const Icon(Icons.add),
            label: const Text('새 앨범 만들기'),
          ),
        ],
      ),
    );
  }
}
