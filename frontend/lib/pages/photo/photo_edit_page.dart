// lib/pages/photo/photo_edit_page.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:family_app/models/photo.dart';
import 'package:family_app/services/photo_service.dart';

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
  late final TextEditingController _descriptionController;
  late final TextEditingController _placeController;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _descriptionController =
        TextEditingController(text: widget.photo.description ?? '');
    _placeController =
        TextEditingController(text: widget.photo.place ?? '');
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _placeController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _isSaving = true);

    try {
      await context.read<PhotoService>().updatePhoto(
        photoId: widget.photo.id, // ✅ int 그대로
        description: _descriptionController.text.trim(),
        place: _placeController.text.trim(),
      );

      if (mounted) {
        Navigator.pop(context, true);
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('사진 수정'),
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _save,
            child: _isSaving
                ? const CircularProgressIndicator()
                : const Text('저장'),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: '설명'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _placeController,
              decoration: const InputDecoration(labelText: '장소'),
            ),
          ],
        ),
      ),
    );
  }
}
