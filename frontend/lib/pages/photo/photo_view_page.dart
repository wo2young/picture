// lib/pages/photo/photo_view_page.dart

import 'package:flutter/material.dart';
import 'package:family_app/models/photo.dart';
import 'package:family_app/models/diary.dart';
import 'package:family_app/models/photo_detail.dart';
import 'package:family_app/services/photo_service.dart';
import 'package:family_app/config/app_routes.dart';

class PhotoViewPage extends StatefulWidget {
  final Photo photo;

  const PhotoViewPage({
    super.key,
    required this.photo,
  });

  @override
  State<PhotoViewPage> createState() => _PhotoViewPageState();
}

class _PhotoViewPageState extends State<PhotoViewPage> {
  final PhotoService _photoService = PhotoService();

  PhotoDetail? _detail;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final detail =
    await _photoService.fetchPhotoDetail(widget.photo.id);

    setState(() {
      _detail = detail;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final photo = _detail!.photo;
    final List<Diary> diaries = _detail!.diaries;

    return Scaffold(
      appBar: AppBar(title: const Text('사진 보기')),
      body: ListView(
        children: [
          // ------------------------------------------------------------
          // 1️⃣ 사진
          // ------------------------------------------------------------
          AspectRatio(
            aspectRatio: 1,
            child: Image.network(
              photo.originalUrl,
              fit: BoxFit.cover,
            ),
          ),

          // ------------------------------------------------------------
          // 2️⃣ 설명
          // ------------------------------------------------------------
          if (photo.description != null)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(photo.description!),
            ),

          const Divider(),

          // ------------------------------------------------------------
          // 3️⃣ 연결된 일기
          // ------------------------------------------------------------
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              '이 사진이 포함된 일기',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),

          if (diaries.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('연결된 일기가 없습니다.'),
            )
          else
            ...diaries.map(
                  (diary) => ListTile(
                title: Text(diary.title),
                subtitle: Text(
                  diary.date.toString().substring(0, 10),
                ),

                // ⭐ 핵심
                onTap: () {
                  Navigator.of(context).pushNamed(
                    AppRoutes.diaryDetail,
                    arguments: diary,
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
