import 'package:flutter/material.dart';
import 'package:family_app/services/photo_service.dart';
import 'package:family_app/models/photo.dart';

class PhotoSelectPage extends StatefulWidget {
  const PhotoSelectPage({super.key});

  @override
  State<PhotoSelectPage> createState() => _PhotoSelectPageState();
}

class _PhotoSelectPageState extends State<PhotoSelectPage> {
  static final PhotoService _photoService = PhotoService();

  Photo? _selectedPhoto;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('사진 선택'),
        centerTitle: true,
      ),

      body: FutureBuilder<List<Photo>>(
        future: _photoService.fetchPhotosByAlbum('1'), // 임시 albumId
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('사진이 없습니다.'));
          }

          final photos = snapshot.data!;

          return GridView.builder(
            padding: const EdgeInsets.all(12),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: photos.length,
            itemBuilder: (context, index) {
              final photo = photos[index];
              final isSelected = _selectedPhoto?.id == photo.id;

              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedPhoto = photo;
                  });
                },
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        photo.thumbnailUrl,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                      ),
                    ),

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
          );
        },
      ),

      // ------------------------------------------------------------
      // 하단 선택 확정 버튼
      // ------------------------------------------------------------
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: ElevatedButton(
            onPressed: _selectedPhoto == null
                ? null
                : () {
              Navigator.pop(context, _selectedPhoto);
            },
            child: const Text('이 사진 선택'),
          ),
        ),
      ),
    );
  }
}
