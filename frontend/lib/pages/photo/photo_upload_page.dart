// lib/pages/photo/photo_upload_page.dart
import 'package:flutter/material.dart';

import 'package:family_app/models/album.dart';
import 'package:family_app/services/photo_service.dart';
import 'package:family_app/utils/validators.dart';
import 'package:family_app/widgets/custom_button.dart';

class PhotoUploadPage extends StatefulWidget {
  final Album? targetAlbum;

  const PhotoUploadPage({
    super.key,
    this.targetAlbum,
  });

  @override
  State<PhotoUploadPage> createState() => _PhotoUploadPageState();
}

class _PhotoUploadPageState extends State<PhotoUploadPage> {
  final _formKey = GlobalKey<FormState>();
  final _urlController = TextEditingController();
  final _captionController = TextEditingController();
  final _locationController = TextEditingController();

  final PhotoService _photoService = PhotoService();

  bool _isSubmitting = false;

  // ---------------------------------------------------------------------------
  // 업로드 처리
  // ---------------------------------------------------------------------------
  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final album = widget.targetAlbum;
    if (album == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('앨범 정보가 없습니다.')),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      await _photoService.uploadPhoto(
        albumId: album.id,
        originalUrl: _urlController.text.trim(),
        thumbnailUrl: _urlController.text.trim(), // mock 단계에서는 동일
        description: _captionController.text.trim(),
        place: _locationController.text.trim(),
      );

      if (mounted) {
        Navigator.of(context).pop(); // 업로드 후 이전 화면으로
      }
    } catch (e) {
      // 업로드 실패 시 사용자 피드백
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('사진 업로드에 실패했습니다.')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _urlController.dispose();
    _captionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final albumTitle = widget.targetAlbum?.title ?? '선택된 앨범 없음';

    return Scaffold(
      appBar: AppBar(
        title: const Text('사진 업로드'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '대상 앨범: $albumTitle',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            const SizedBox(height: 16),

            // ---------------------------------------------------------------
            // 입력 폼
            // ---------------------------------------------------------------
            Form(
              key: _formKey,
              child: Expanded(
                child: ListView(
                  children: [
                    TextFormField(
                      controller: _urlController,
                      decoration: const InputDecoration(
                        labelText: '이미지 URL',
                      ),
                      validator: (value) =>
                          Validators.required(value, fieldName: '이미지 URL'),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _captionController,
                      decoration: const InputDecoration(
                        labelText: '사진 설명',
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _locationController,
                      decoration: const InputDecoration(
                        labelText: '위치 (예: 제주도 함덕 해변)',
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),
            CustomButton(
              label: _isSubmitting ? '업로드 중...' : '업로드',
              onPressed: _isSubmitting ? null : _submit,
            ),
          ],
        ),
      ),
    );
  }
}
