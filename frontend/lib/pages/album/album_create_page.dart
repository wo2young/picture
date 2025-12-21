// lib/pages/album/album_create_page.dart
import 'package:flutter/material.dart';

import 'package:family_app/services/album_service.dart';
import 'package:family_app/utils/validators.dart';
import 'package:family_app/widgets/custom_button.dart';

class AlbumCreatePage extends StatefulWidget {
  const AlbumCreatePage({super.key});

  @override
  State<AlbumCreatePage> createState() => _AlbumCreatePageState();
}

class _AlbumCreatePageState extends State<AlbumCreatePage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  final AlbumService _albumService = AlbumService();

  bool _isSubmitting = false;

  // TODO: 로그인 연동 시 실제 familyId로 교체
  static const int _familyId = 1;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      await _albumService.createAlbum(
        familyId: _familyId,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
      );

      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('앨범 생성에 실패했습니다.')),
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('새 앨범 만들기'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: '앨범 제목',
                ),
                validator: (value) =>
                    Validators.required(value, fieldName: '앨범 제목'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: '설명 (선택)',
                ),
                maxLines: 3,
              ),
              const Spacer(),
              CustomButton(
                label: _isSubmitting ? '저장 중...' : '저장',
                onPressed: _isSubmitting ? null : _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
