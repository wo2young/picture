// lib/pages/photo/photo_select_page.dart
import 'package:flutter/material.dart';

import 'package:family_app/models/photo.dart';
import 'package:family_app/services/photo_service.dart';

class PhotoSelectPage extends StatefulWidget {
  final int albumId;

  const PhotoSelectPage({
    super.key,
    required this.albumId,
  });

  @override
  State<PhotoSelectPage> createState() => _PhotoSelectPageState();
}

class _PhotoSelectPageState extends State<PhotoSelectPage> {
  final PhotoService _photoService = PhotoService();

  bool _isLoading = true;
  List<Photo> _photos = [];

  Photo? _selectedPhoto;

  @override
  void initState() {
    super.initState();
    _loadPhotos();
  }

  Future<void> _loadPhotos() async {
    try {
      final list =
      await _photoService.fetchPhotosByAlbum(widget.albumId);

      if (!mounted) return;

      setState(() {
        _photos = list;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() => _isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('사진을 불러오지 못했습니다.')),
      );
    }
  }

  void _confirm() {
    if (_selectedPhoto == null) return;
    Navigator.pop(context, _selectedPhoto);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('사진 선택'),
        actions: [
          TextButton(
            onPressed: _selectedPhoto == null ? null : _confirm,
            child: const Text('선택'),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : GridView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _photos.length,
        gridDelegate:
        const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        itemBuilder: (context, index) {
          final photo = _photos[index];
          final isSelected = _selectedPhoto?.id == photo.id;

          return GestureDetector(
            onTap: () {
              setState(() => _selectedPhoto = photo);
            },
            child: Stack(
              children: [
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      photo.thumbnailUrl,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),

                // ✅ 선택 표시
                if (isSelected)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.check_circle,
                          color: Colors.white,
                          size: 36,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
