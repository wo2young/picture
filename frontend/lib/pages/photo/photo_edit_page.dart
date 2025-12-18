// lib/pages/photo/photo_edit_page.dart
import 'package:flutter/material.dart';

import 'package:family_app/models/photo.dart';
import 'package:family_app/services/photo_service.dart';
import 'package:family_app/utils/validators.dart';
import 'package:family_app/widgets/custom_button.dart';

class PhotoEditPage extends StatefulWidget {
  final Photo photo;

  const PhotoEditPage({
    super.key,
    required this.photo,
  });

  @override
  State<PhotoEditPage> createState() => _PhotoEditPageState();
}

class _PhotoEditPageState extends State<PhotoEditPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _captionController;
  final PhotoService _photoService = PhotoService();

  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _captionController =
        TextEditingController(text: widget.photo.description ?? '');
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      await _photoService.updatePhotoDescription(
        widget.photo,
        _captionController.text.trim(),
      );
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      // 에러 처리 위치
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
    _captionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('사진 편집'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 사진 미리보기 자리
            Container(
              height: 200,
              width: double.infinity,
              color: Colors.grey.shade300,
              child: Image.network(
                widget.photo.thumbnailUrl,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 16),
            Form(
              key: _formKey,
              child: TextFormField(
                controller: _captionController,
                decoration: const InputDecoration(
                  labelText: '설명',
                ),
                validator: (value) =>
                    Validators.maxLength(value, 200, fieldName: '설명'),
              ),
            ),
            const Spacer(),
            CustomButton(
              label: _isSubmitting ? '저장 중...' : '저장',
              onPressed: _isSubmitting ? null : _submit,
            ),
          ],
        ),
      ),
    );
  }
}
