// lib/pages/feedback/feedback_write_page.dart

import 'package:flutter/material.dart';
import 'package:family_app/models/feedback_post.dart';
import 'package:family_app/services/feedback_service.dart';

class FeedbackWritePage extends StatefulWidget {
  final FeedbackService service;

  const FeedbackWritePage({
    super.key,
    required this.service,
  });

  @override
  State<FeedbackWritePage> createState() => _FeedbackWritePageState();
}

class _FeedbackWritePageState extends State<FeedbackWritePage> {
  final _titleCtrl = TextEditingController();
  final _contentCtrl = TextEditingController();
  bool _isSaving = false;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _contentCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_isSaving) return;

    setState(() => _isSaving = true);
    try {
      final created = await widget.service.createPost(
        title: _titleCtrl.text,
        content: _contentCtrl.text,
      );
      if (!mounted) return;
      Navigator.of(context).pop<FeedbackPost>(created);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('저장 중 오류가 발생했습니다.')),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('글 작성'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              '불편했던 점을 편하게 적어주세요.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),

            TextField(
              controller: _titleCtrl,
              decoration: const InputDecoration(
                labelText: '제목',
                border: OutlineInputBorder(),
              ),
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 12),

            TextField(
              controller: _contentCtrl,
              decoration: const InputDecoration(
                labelText: '내용',
                border: OutlineInputBorder(),
              ),
              minLines: 6,
              maxLines: 12,
            ),
            const SizedBox(height: 16),

            SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _submit,
                child: _isSaving
                    ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
                    : const Text('보내기'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
