// lib/pages/album/album_list_page.dart
import 'package:flutter/material.dart';

import 'package:family_app/config/app_routes.dart';
import 'package:family_app/models/album.dart';
import 'package:family_app/services/album_service.dart';
import 'package:family_app/widgets/album_card.dart';
import 'package:family_app/widgets/custom_button.dart';

class AlbumListPage extends StatefulWidget {
  const AlbumListPage({super.key});

  @override
  State<AlbumListPage> createState() => _AlbumListPageState();
}

class _AlbumListPageState extends State<AlbumListPage> {
  final AlbumService _albumService = AlbumService();

  bool _isLoading = false;
  List<Album> _albums = [];

  @override
  void initState() {
    super.initState();
    _loadAlbums();
  }

  Future<void> _loadAlbums() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final list = await _albumService.fetchAlbums();
      setState(() {
        _albums = list;
      });
    } catch (e) {
      // 나중에 Snackbar 등으로 에러 표시 가능
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _goToCreateAlbum() async {
    await Navigator.of(context).pushNamed(AppRoutes.albumCreate);
    // 앨범 생성 후 돌아오면 목록 새로고침
    _loadAlbums();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('앨범 목록'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: _loadAlbums,
        child: ListView.builder(
          itemCount: _albums.length,
          itemBuilder: (context, index) {
            final album = _albums[index];
            return AlbumCard(
              album: album,
              onTap: () {
                Navigator.of(context).pushNamed(
                  AppRoutes.albumDetail,
                  arguments: album,
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _goToCreateAlbum,
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: CustomButton(
          label: '홈으로',
          isPrimary: false,
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
    );
  }
}
