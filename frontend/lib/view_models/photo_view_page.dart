// lib/pages/photo/photo_view_page.dart

import 'package:flutter/material.dart';
import 'package:family_app/models/photo.dart';
import 'package:family_app/models/diary.dart';
import 'package:family_app/services/photo_service.dart';
import 'package:family_app/config/app_routes.dart';

import '../../models/photo_detail.dart';

class PhotoViewPage extends StatefulWidget {
  final Photo photo;

  const PhotoViewPage({super.key, required this.photo});

  @override
  State<PhotoViewPage> createState() => _PhotoViewPageState();
}

class _PhotoViewPageState extends State<PhotoViewPage> {
  final PhotoService _photoService = PhotoService();

  PhotoDetail? _detail;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final detail =
    await _photoService.fetchPhotoDetail(widget.photo.id);

    if (!mounted) return;

    setState(() {
      _detail = detail;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
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
          // ------------------------------------------------------------------
          // 1) 사진
          // ------------------------------------------------------------------
          AspectRatio(
            aspectRatio: 1,
            child: Image.network(
              photo.originalUrl,
              fit: BoxFit.cover,
            ),
          ),

          // ------------------------------------------------------------------
          // 2) 설명
          // ------------------------------------------------------------------
          if (photo.description != null)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(photo.description!),
            ),

          const Divider(),

          // ------------------------------------------------------------------
          // 3) 연결된 일기
          // ------------------------------------------------------------------
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
                  (Diary d) => ListTile(
                title: Text(d.title),
                subtitle: Text(
                  d.date.toString().substring(0, 10),
                ),
                onTap: () {
                  // ✅ 여기서 일기 상세로 이동 (완성)
                  Navigator.pushNamed(
                    context,
                    AppRoutes.diaryDetail,
                    arguments: d,
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
